ARC9.Blacklist = {}

-- ["att"] = true

function ARC9:SaveBlacklist()
    local f = file.Open("arc9_blacklist.txt", "w", "DATA")

    for i, k in pairs(ARC9.Blacklist) do
        f:Write(i)
        f:Write("\n")
    end

    f:Close()
end

function ARC9:LoadBlacklist()
    local f = file.Open("arc9_blacklist.txt", "r", "DATA")

    ARC9.Blacklist = {}

    if !f then return end

    while !f:EndOfFile() do
        local line = f:ReadLine()

        line = string.Trim(line, "\n")

        ARC9.Blacklist[line] = true
    end

    f:Close()
end

function ARC9:SendBlacklist(ply)
    net.Start("arc9_sendblacklist")

    net.WriteUInt(table.Count(ARC9.Blacklist), 32)

    for attname, i in pairs(ARC9.Blacklist) do
        if !i then continue end
        local atttbl = ARC9.GetAttTable(attname) or {}

        local id = atttbl.ID or 0

        net.WriteUInt(id, ARC9.Attachments_Bits)
    end

    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

concommand.Add("arc9_blacklist_refresh_sv", function()
    ARC9:LoadBlacklist()
    ARC9:SendBlacklist()
end)

net.Receive("arc9_sendblacklist", function(len, ply)
    if !ply:IsAdmin() then return end

    ARC9.Blacklist = {}

    local count = net.ReadUInt(32)

    for i = 1, count do
        local attid = net.ReadUInt(ARC9.Attachments_Bits)

        local atttbl = ARC9.GetAttTable(attid)

        if !atttbl then continue end

        local shortname = atttbl.ShortName

        ARC9.Blacklist[shortname] = true
    end

    ARC9:SaveBlacklist()
    ARC9:SendBlacklist()
end)

hook.Add("PlayerInitialSpawn", "ARC9_PlayerInitialSpawn_SendBlacklist", function(ply)
    ARC9:SendBlacklist(ply)
end)

hook.Add("PreGamemodeLoaded", "ARC9_PreGamemodeLoaded_LoadBlacklist", function()
    ARC9:LoadBlacklist()
end)