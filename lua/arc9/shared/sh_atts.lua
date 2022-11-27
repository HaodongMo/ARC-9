ARC9.Attachments = {}
ARC9.Attachments_Index = {}

ARC9.Attachments_Count = 0

ARC9.Attachments_Bits = 16

local defaulticon = Material("arc9/arccw_bird.png", "mips smooth")

function ARC9.LoadAttachment(atttbl, shortname, id)
    if atttbl.Ignore then return end
    shortname = shortname or "default"

    if !id then
        ARC9.Attachments_Count = ARC9.Attachments_Count + 1
    end

    atttbl.ShortName = shortname
    atttbl.ID = id or ARC9.Attachments_Count
    atttbl.Icon = atttbl.Icon or defaulticon

    -- for stat, val in ipairs(atttbl) do
    --     local stat2 = string.Replace(stat, "Override", "")
    --     atttbl[stat2] = val
    -- end

    ARC9.Attachments[shortname] = atttbl
    ARC9.Attachments_Index[atttbl.ID] = shortname

    if GetConVar("arc9_atts_generateentities"):GetBool() and !atttbl.DoNotRegister and !atttbl.InvAtt and !atttbl.Free then
        local attent = {}
        attent.Base = "arc9_att_base"
        attent.Icon = atttbl.Icon or defaulticon
        -- attent.IconOverride = atttbl.Icon or defaulticon  -- nah this needs a path (a true string), imaterial "path" does not work
        attent.PrintName = atttbl.PrintName or shortname
        attent.Spawnable = true
        attent.AdminOnly = atttbl.AdminOnly or false
        attent.Model = atttbl.BoxModel or "models/items/arc9/att_plastic_box.mdl"
        attent.AttToGive = shortname
        attent.GiveAttachments = {
            [shortname] = 1
        }
        attent.Category =  atttbl.MenuCategory or "ARC-9 - Attachments"

        scripted_ents.Register(attent, "arc9_att_" .. shortname)
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

        ARC9.Attachments_Count = ARC9.Attachments_Count + 1

        local shortname = string.sub(filename, 1, -5)
        local attid = ARC9.Attachments_Count

        // include(searchdir .. filename)

        if game.SinglePlayer() then
            file.AsyncRead(searchdir .. filename, "LUA", function(fileName, gamePath, status, data)
                ATT = {}

                local thrownerror = RunString(data, "ARC9AsyncLoad", true)

                if thrownerror then
                    print("ARC9: Error loading attachment " .. shortname .. "!")
                    print(thrownerror)
                else
                    ARC9.LoadAttachment(ATT, shortname, attid)
                end
            end)
        else
            ATT = {}

            include(searchdir .. filename)

            ARC9.LoadAttachment(ATT, shortname, attid)
        end
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

    if game.SinglePlayer() then
        if IsValid(Entity(1)) then
            local wep = Entity(1):GetActiveWeapon()

            if IsValid(wep) and wep.ARC9 then
                timer.Simple(0, function() wep:PostModify(true) end)
            end
        end
    end
end

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
        if ARC9.Blacklist[k] then continue end
        local attcats = k.Category
        if !istable(attcats) then
            attcats = {attcats}
        end

        for _, cat in pairs(cats) do
            if GetConVar("arc9_atts_anarchy"):GetBool() then
                table.insert(atts, k.ShortName)
                break
            else
                if table.HasValue(attcats, cat) then
                    table.insert(atts, k.ShortName)
                    break
                end
            end
        end
    end

    return atts
end

ARC9.AttMaterialIndex = true

if file.Exists("wmsm/playerdata.txt", "DATA") then
    ARC9.AttMaterialIndex = false
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
    return GetConVar("arc9_atts_max"):GetInt()
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

    ARC9.InvalidateAll()
    net.Start("ARC9_InvalidateAll_ToClients")
    net.Broadcast()
end)

end

-- local CT = 0

-- hook.Add("OnReloaded", "ARC9_OnReloaded", function()
--     if CT == CurTime() then return end

--     ARC9.LoadAtts()

--     CT = CurTime()
-- end)

ARC9.LoadAtts()