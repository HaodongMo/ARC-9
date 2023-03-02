function ARC9:PlayerGetAtts(ply, att)
    if !IsValid(ply) then return 0 end
    if GetConVar("arc9_free_atts"):GetBool() then return 999 end

    if att == "" then return 999 end

    local atttbl = ARC9.GetAttTable(att)

    if !atttbl then return 0 end

    if atttbl.Free then return 999 end

    if !IsValid(ply) or !ply:IsPlayer() then return end

    if !ply:IsAdmin() and atttbl.AdminOnly then
        return 0
    end

    if atttbl.InvAtt then att = atttbl.InvAtt end

    if !ply.ARC9_AttInv then return 0 end

    if !ply.ARC9_AttInv[att] then return 0 end

    return ply.ARC9_AttInv[att]
end

function ARC9:PlayerGiveAtt(ply, att, amt)
    amt = amt or 1

    if !IsValid(ply) or !ply:IsPlayer() then return end

    if !ply.ARC9_AttInv then
        ply.ARC9_AttInv = {}
    end

    local atttbl = ARC9.GetAttTable(att)

    if !atttbl then return end
    if atttbl.Free then return end -- You can't give a free attachment, silly
    if atttbl.AdminOnly and !(ply:IsPlayer() and ply:IsAdmin()) then return false end

    if atttbl.InvAtt then att = atttbl.InvAtt end

    if GetConVar("arc9_atts_lock"):GetBool() then
        if ply.ARC9_AttInv[att] == 1 then return end
        ply.ARC9_AttInv[att] = 1
    else
        ply.ARC9_AttInv[att] = (ply.ARC9_AttInv[att] or 0) + amt
    end
end

function ARC9:PlayerTakeAtt(ply, att, amt)
    amt = amt or 1

    if GetConVar("arc9_atts_lock"):GetBool() then return end

    if !IsValid(ply) or !ply:IsPlayer() then return end

    if !ply.ARC9_AttInv then
        ply.ARC9_AttInv = {}
    end

    local atttbl = ARC9.GetAttTable(att)
    if !atttbl or atttbl.Free then return end

    if atttbl.InvAtt then att = atttbl.InvAtt end

    ply.ARC9_AttInv[att] = ply.ARC9_AttInv[att] or 0

    if ply.ARC9_AttInv[att] < amt then
        return false
    end

    ply.ARC9_AttInv[att] = ply.ARC9_AttInv[att] - amt
    if ply.ARC9_AttInv[att] <= 0 then
        ply.ARC9_AttInv[att] = nil
    end
    return true
end

if CLIENT then

net.Receive("ARC9_sendattinv", function(len, ply)
    LocalPlayer().ARC9_AttInv = {}

    local count = net.ReadUInt(32)

    for i = 1, count do
        local attid = net.ReadUInt(ARC9.Attachments_Bits)
        local acount = net.ReadUInt(32)

        local att = ARC9.Attachments_Index[attid]

        LocalPlayer().ARC9_AttInv[att] = acount
    end
end)

elseif SERVER then

hook.Add("PlayerDeath", "ARC9_DeathAttInv", function(ply)
    -- if GetConVar("arc9_atts_loseondie"):GetBool() then
    --     ply.ARC9_AttInv = ply.ARC9_AttInv or {}
    -- end
    -- if table.Count(ply.ARC9_AttInv) > 0
    --         and GetConVar("arc9_atts_loseondie"):GetInt() >= 2
    --         and !GetConVar("arc9_free_atts"):GetBool() then
    --     local boxEnt = ents.Create("ARC9_att_dropped")
    --     boxEnt:SetPos(ply:GetPos() + Vector(0, 0, 4))
    --     boxEnt.GiveAttachments = ply.ARC9_AttInv
    --     boxEnt:Spawn()
    --     boxEnt:SetNWString("boxname", ply:GetName() .. "'s Death Box")
    --     local count = 0
    --     for i, v in pairs(boxEnt.GiveAttachments) do count = count + v end
    --     boxEnt:SetNWInt("boxcount", count)
    -- end
end)

hook.Add("PlayerSpawn", "ARC9_SpawnAttInv", function(ply, trans)
    if trans then return end

    if GetConVar("arc9_atts_loseondie"):GetInt() >= 1 then
        ply.ARC9_AttInv = {}

        ARC9:PlayerSendAttInv(ply)
    end
end)

function ARC9:PlayerSendAttInv(ply)
    if GetConVar("arc9_free_atts"):GetBool() then return end

    if !IsValid(ply) then return end

    if !ply.ARC9_AttInv then return end

    net.Start("ARC9_sendattinv")

    net.WriteUInt(table.Count(ply.ARC9_AttInv), 32)

    for att, count in pairs(ply.ARC9_AttInv) do
        local atttbl = ARC9.GetAttTable(att)
        local attid = atttbl.ID
        net.WriteUInt(attid, ARC9.Attachments_Bits)
        net.WriteUInt(count, 32)
    end

    net.Send(ply)
end

end
