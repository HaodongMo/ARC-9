hook.Add("InitPostEntity", "ARC9_NPCRegister", function()
    for _, wpn in pairs(weapons.GetList()) do
        local tbl = weapons.Get(wpn.ClassName)

        if !tbl.ARC9 then continue end
        if tbl.NotForNPCs then continue end
        if !tbl.Spawnable then continue end

        list.Add("NPCUsableWeapons",
            {
                class = wpn.ClassName,
                title = wpn.PrintName
            }
        )
    end
end)

if SERVER then

net.Receive("arc9_givenpcweapon", function(len, ply)
    local ent = net.ReadEntity()

    if !ent:IsValid() then return end
    if !ent:IsNPC() then return end

    ARC9.GiveNPCPlayerWeapon(ent, ply)
end)

end

function ARC9.GiveNPCPlayerWeapon(npc, ply)
    if bit.band(npc:CapabilitiesGet(), CAP_USE_WEAPONS) != CAP_USE_WEAPONS then return end

    if ply:GetPos():DistToSqr(npc:GetPos()) > 40000 then return end

    local weapon = ply:GetActiveWeapon()

    if !weapon.ARC9 then return end

    npc:DropWeapon(nil, ply:GetPos())
    npc:Give(weapon:GetClass())

    local wpn = npc:GetActiveWeapon()
    wpn.Attachments = weapon.Attachments
    wpn:Activate()
    wpn:NPC_Initialize()
    wpn:SetClip1(weapon:Clip1())

    ply:StripWeapon(weapon:GetClass())
end