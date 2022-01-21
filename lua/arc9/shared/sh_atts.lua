ARC9.Attachments = {}
ARC9.Attachments_Index = {}

ARC9.Attachments_Count = 0

ARC9.Attachments_Bits = 16

local defaulticon = Material("arc9/arccw_bird.png", "mips smooth")

local attachments_path = "ARC9/common/attachments/"

local function ARC9_LoadAtt(attachment)

    local s = string.Explode("/", attachment)
    local shortname = string.sub(s[#s], 1, -5)

    ARC9.Attachments_Count = ARC9.Attachments_Count + 1

    ATT.ShortName = shortname
    ATT.ID = ARC9.Attachments_Count

    ARC9.Attachments[shortname] = ATT
    ARC9.Attachments_Index[ARC9.Attachments_Count] = shortname

    if GetConVar("arc9_generateattentities"):GetBool() and !ATT.DoNotRegister and !ATT.InvAtt and !ATT.Free then
        local attent = {}
        attent.Base = "ARC9_att"
        attent.Icon = ATT.Icon or defaulticon
        attent.PrintName = ATT.PrintName or shortname
        attent.Spawnable = true
        attent.AdminOnly = ATT.AdminOnly or false
        attent.AttToGive = shortname
        attent.Category =  ATT.MenuCategory or "ARC-9 - Attachments"

        scripted_ents.Register(attent, "ARC9_att_" .. shortname)
    end
end

local function ARC9_LoadFile(filename)
    ATT = {}
    include(filename)

    if SERVER then
        AddCSLuaFile(filename)
    end
    if ATT.Ignore then return end

    ARC9_LoadAtt(filename)

end


local function ARC9_LoadFolder(folder)
    folder = folder and (attachments_path .. folder .. "/") or attachments_path
    for k, v in pairs(file.Find(folder .. "*", "LUA")) do

        if !pcall(function() ARC9_LoadFile(folder .. v) end) then
            print("!!!! Attachment " .. v .. " has errors!")

            local s = string.Explode("/", folder .. v)
            local shortname = string.sub(s[#s], 1, -5)
            ARC9.Attachments[shortname] = {
                PrintName = shortname or "ERROR",
                Description = "This attachment failed to load!\nIts file path is: " .. v
            }
        end

    end
end

function ARC9.LoadAtts()
    ARC9.Attachments_Count = 0
    ARC9.Attachments = {}
    ARC9.Attachments_Index = {}


    ARC9_LoadFolder()
    local _, folders = file.Find(attachments_path .. "/*", "LUA")
    if folders then
        for _, folder in pairs(folders) do
            ARC9_LoadFolder(folder)
        end
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
        assert(false, "!!!! ARC9 tried to access invalid attachment " .. (shortname or "NIL") .. "!!!")
        return {}
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