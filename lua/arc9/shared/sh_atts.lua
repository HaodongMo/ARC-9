ARC9.Attachments = {}
ARC9.Attachments_Index = {}

ARC9.Attachments_Count = 0

ARC9.Attachments_Bits = 16

local defaulticon = Material("arc9/arccw_bird.png", "mips smooth")

function ARC9.LoadAttachment(atttbl, shortname)
    if atttbl.Ignore then return end
    shortname = shortname or "default"

    ARC9.Attachments_Count = ARC9.Attachments_Count + 1

    atttbl.ShortName = shortname
    atttbl.ID = ARC9.Attachments_Count
    atttbl.Icon = atttbl.Icon or defaulticon

    ARC9.Attachments[shortname] = atttbl
    ARC9.Attachments_Index[ARC9.Attachments_Count] = shortname

    if GetConVar("arc9_generateattentities"):GetBool() and !atttbl.DoNotRegister and !atttbl.InvAtt and !atttbl.Free then
        local attent = {}
        attent.Base = "ARC9_att"
        attent.Icon = atttbl.Icon or defaulticon
        attent.PrintName = atttbl.PrintName or shortname
        attent.Spawnable = true
        attent.AdminOnly = atttbl.AdminOnly or false
        attent.AttToGive = shortname
        attent.Category =  atttbl.MenuCategory or "ARC-9 - Attachments"

        scripted_ents.Register(attent, "ARC9_att_" .. shortname)
    end
end

function ARC9.LoadAtts()
    ARC9.Attachments_Count = 0
    ARC9.Attachments = {}
    ARC9.Attachments_Index = {}

    local searchdir = "ARC9/common/attachments/"
    local searchdir_bulk = "ARC9/common/attachments_bulk/"

    local files = file.Find(searchdir .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        AddCSLuaFile(searchdir .. filename)
    end

    files = file.Find(searchdir .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        if filename == "default.lua" then continue end

        ATT = {}

        local shortname = string.sub(filename, 1, -5)

        include(searchdir .. filename)

        ARC9.LoadAttachment(ATT, shortname)
    end

    local bulkfiles = file.Find(searchdir_bulk .. "/*.lua", "LUA")

    for _, filename in pairs(bulkfiles) do
        AddCSLuaFile(searchdir_bulk .. filename)
    end

    bulkfiles = file.Find(searchdir_bulk .. "/*.lua", "LUA")

    for _, filename in pairs(bulkfiles) do
        if filename == "default.lua" then continue end

        include(searchdir_bulk .. filename)
    end

    print("ARC9 Registered " .. tostring(ARC9.Attachments_Count) .. " Attachments.")

    ARC9.Attachments_Bits = math.min(math.ceil(math.log(ARC9.Attachments_Count + 1, 2)), 32)
end

ARC9.LoadAtts()

function ARC9.GetAttTable(name)
    local shortname = name
    if isnumber(shortname) then
        shortname = ARC9.Attachments_Index[name]
    end

    if ARC9.Attachments[shortname] then
        return ARC9.Attachments[shortname]
    else
        return nil
    end
end

function ARC9.GetAttsForCats(cats)
    if !istable(cats) then
        cats = {cats}
    end

    local atts = {}

    for i, k in pairs(ARC9.Attachments) do
        local attcats = k.Category
        if !istable(attcats) then
            attcats = {attcats}
        end

        for _, cat in pairs(cats) do
            if table.HasValue(attcats, cat) then
                table.insert(atts, k.ShortName)
                break
            end
        end
    end

    return atts
end

function ARC9.GetFoldersForAtts(atts)

    local folders = {}
    for i, k in pairs(atts) do
        local atttbl = ARC9.Attachments[k]
        if !atttbl then continue end
        if !atttbl.Folder then
            folders[atttbl.ShortName] = true
        else
            local names = string.Explode("/", atttbl.Folder)
            local cur = folders
            for _, v in ipairs(names) do
                cur[v] = cur[v] or {}
                cur = cur[v]
            end
            cur[atttbl.ShortName] = true
        end
    end

    return folders
end

hook.Add("OnReloaded", "ARC9_ReloadAtts", ARC9.LoadAtts)

function ARC9.GetMaxAtts()
    return GetConVar("arc9_maxatts"):GetInt()
end

if CLIENT then

concommand.Add("arc9_reloadatts", function()
    if !LocalPlayer():IsSuperAdmin() then return end

    net.Start("arc9_reloadatts")
    net.SendToServer()
end)

net.Receive("arc9_reloadatts", function(len, ply)
    ARC9.LoadAtts()
end)

elseif SERVER then

net.Receive("arc9_reloadatts", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    ARC9.LoadAtts()

    net.Start("arc9_reloadatts")
    net.Broadcast()
end)

end