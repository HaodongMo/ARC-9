ARC9.Attachments = {}
ARC9.Attachments_Index = {}

ARC9.Attachments_Count = 0

ARC9.Attachments_Bits = 16

ARC9.ModelToPrecacheList = {}

local fullreload

local defaulticon = Material("arc9/logo/logo_lowvis.png", "mips smooth")

local function FixVertexLitMaterial(mat) -- from DImage code
	if string.find(mat:GetShader(), "VertexLitGeneric") then
		local t = mat:GetString( "$basetexture" )
		if t then
			local params = {}
			params[ "$basetexture" ] = t
			params[ "$vertexcolor" ] = 1
			params[ "$vertexalpha" ] = 1

			mat = CreateMaterial( mat:GetName() .. "_Icon", "UnlitGeneric", params )
		end
	end

	return mat
end

function ARC9.LoadAttachment(atttbl, shortname, id)
    if hook.Run("ARC9_LoadAttachment", atttbl, shortname, id) then return end
    if atttbl.Ignore then return end
    shortname = shortname or "default"

    if !id then
        ARC9.Attachments_Count = ARC9.Attachments_Count + 1
    end

    atttbl.ShortName = shortname
    atttbl.ID = id or ARC9.Attachments_Count
    atttbl.Icon = atttbl.Icon or defaulticon

    -- only checking stickers and camos cuz rest of icons are usually normal and use png
    -- parsing all thousands of icons of atts might technically take more time otherwise
    if CLIENT and (atttbl.StickerMaterial or atttbl.CustomCamoTexture) then atttbl.Icon = FixVertexLitMaterial(atttbl.Icon) end

    -- for stat, val in ipairs(atttbl) do
    --     local stat2 = string.Replace(stat, "Override", "")
    --     atttbl[stat2] = val
    -- end

    if atttbl.Model then
        table.insert(ARC9.ModelToPrecacheList, atttbl.Model)
    end

    if atttbl.AdvancedCamoSupport then
        local camotoggles = {}
        
        for i = 1, 3 do
            table.insert(camotoggles, {
				PrintName = string.format( ARC9:GetPhrase("customize.camoslot"), i),
				[shortname .. "_camoslot"] = i
            })
        end

        atttbl.ToggleStats = camotoggles
    end

    ARC9.Attachments[shortname] = atttbl
    ARC9.Attachments_Index[atttbl.ID] = shortname

    if GetConVar("arc9_atts_generate_entities"):GetBool() and !atttbl.DoNotRegister and !atttbl.InvAtt and !atttbl.Free then
        local attent = {}
        attent.Base = "arc9_att_base"
        attent.Icon = atttbl.Icon or defaulticon
        if CLIENT and attent.Icon then
            attent.IconOverride = string.Replace( attent.Icon:GetTexture( "$basetexture" ):GetName() .. ".png", "0001010", "" )
        end
        attent.PrintName = atttbl.PrintName or shortname
        attent.Spawnable = true
        attent.AdminOnly = atttbl.AdminOnly or false
        attent.Model = atttbl.BoxModel or "models/items/arc9/att_plastic_box.mdl"
        attent.AttToGive = shortname
        attent.GiveAttachments = {
            [shortname] = 1
        }
        attent.Category =  atttbl.MenuCategory or "ARC9 - Attachments"

        if atttbl.MenuCategory and !list.HasEntry("ContentCategoryIcons", atttbl.MenuCategory) then
            list.Set("ContentCategoryIcons", atttbl.MenuCategory, "arc9/icon_16.png")
        end

        scripted_ents.Register(attent, "arc9_att_" .. shortname)
    end

    if !fullreload then -- not full loading means individual att file was updated. thats a dev! recaching gun for him so he dont have to reattach attahment!
        if game.SinglePlayer() then
            if IsValid(Entity(1)) then
                local wep = Entity(1):GetActiveWeapon()

                if IsValid(wep) and wep.ARC9 then
                    timer.Simple(0, function() wep:PostModify(true) end)
                end
            end
        end
    end
end

function ARC9.LoadAtts()
    fullreload = true
    ARC9.Attachments_Count = 0
    local Attachments_BulkCount = 0
    local Attachments_RegularCount = 0
    local Attachments_LuaCount = 0
    ARC9.Attachments = {}
    ARC9.Attachments_Index = {}

    local searchdir = "arc9/common/attachments/"
    local searchdir_bulk = "arc9/common/attachments_bulk/"

    local files = file.Find(searchdir .. "*.lua", "LUA")

    for _, filename in pairs(files) do
        if filename == "default.lua" then continue end
        
        AddCSLuaFile(searchdir .. filename)

        local shortname = string.lower(string.sub(filename, 1, -5))
        if string.match(shortname, "[^%w_]") then
            ErrorNoHalt("ARC9: Refusing to load attachment with invalid name \"" .. tostring(shortname) .. "\"!\n")
            continue
        end

        Attachments_LuaCount = Attachments_LuaCount + 1
        ARC9.Attachments_Count = ARC9.Attachments_Count + 1
        local attid = ARC9.Attachments_Count

        ATT = {}

        include(searchdir .. filename)

        ARC9.LoadAttachment(ATT, shortname, attid)
    end

    Attachments_RegularCount = Attachments_LuaCount

    local bulkfiles = file.Find(searchdir_bulk .. "/*.lua", "LUA")

    for _, filename in pairs(bulkfiles) do
        if filename == "default.lua" then continue end

        AddCSLuaFile(searchdir_bulk .. filename)

        Attachments_LuaCount = Attachments_LuaCount + 1
        Attachments_BulkCount = Attachments_BulkCount + 1
        
        include(searchdir_bulk .. filename)
    end

    print("ARC9 Registered " .. tostring(ARC9.Attachments_Count) .. " attachments. (" .. Attachments_LuaCount .. " lua files total, " .. Attachments_BulkCount .. " bulk/" .. Attachments_RegularCount .. " regular)")

    ARC9.Attachments_Bits = math.min(math.ceil(math.log(ARC9.Attachments_Count + 1, 2)), 32)

    if game.SinglePlayer() then
        if IsValid(Entity(1)) then
            local wep = Entity(1):GetActiveWeapon()

            if IsValid(wep) and wep.ARC9 then
                timer.Simple(0, function() wep:PostModify(true) end)
            end
        end
    end

    fullreload = nil
    
    if SERVER then
        net.Start("arc9_svattcount")
        net.WriteUInt(#ARC9.Attachments_Index, 16)
        net.Broadcast()
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

local arc9_atts_anarchy = GetConVar("arc9_atts_anarchy")

function ARC9.GetAttsForCats(cats)
    if !istable(cats) then
        cats = {cats}
    end

    local atts = {}

    for i, k in pairs(ARC9.Attachments) do
        if ARC9.Blacklist[k] then continue end
        local attcats = k.Category

        if attcats == "*" then
            table.insert(atts, k.ShortName)
            continue
        end

        if !istable(attcats) then
            attcats = {attcats}
        end

        for _, cat in pairs(cats) do
            if arc9_atts_anarchy:GetBool() then
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

local arc9_atts_max = GetConVar("arc9_atts_max")

function ARC9.GetMaxAtts()
    return arc9_atts_max:GetInt()
end

if CLIENT then

concommand.Add("arc9_reloadatts", function()
    if !LocalPlayer():IsSuperAdmin() then return end

	ARC9.ATTsHaveBeenReloaded = true
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