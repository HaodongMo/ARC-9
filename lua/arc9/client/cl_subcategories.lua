-- This script adds support for weapon subcategories in Sandbox's
-- weapons tab.
-- Most of the code here is taken straight from Sandbox's source 
-- code. Specifically, it's taken from:
-- sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/weapons.lua
-- All I did was tweak the category table to also have support for
-- subcategories.
-- The way it works is that is checks each SWEP for the line
-- SWEP.SubCategory = ...
-- If it does not exist, it adds the weapon to the "Other" 
-- subcategory. However, if only one subcategory exists in each
-- category, then it doesn't print any subtitle as it's redundant.
-- Writted by Buu342, Still a work in progress.

local function getpresetname(preset, wpn, class)
    local filename = ARC9.PresetPath .. (wpn.SaveBase or class) .. "/" .. preset

    if !file.Exists(filename, "DATA") then return end

    local f = file.Open(filename, "r", "DATA")
    if !f then return end

    local str = f:Read()

    if string.sub(str, 1, 5) == "name=" then
        local strs = string.Split(str, "\n")
        f:Close()
        return string.sub(strs[1], 6)
    else
        f:Close()
        return preset
    end
end

local function getpresetsforweapon(wpn, class)
    local path = ARC9.PresetPath .. (wpn.SaveBase or class) .. "/*.txt"

    local files = file.Find(path, "DATA")
    local output = {}

    for i, k in pairs(files) do
        local shortname = string.sub(k, 1, string.len(k) - 4)
        if shortname == "default" or shortname == "autosave" then continue end
        output[shortname] = (getpresetname(k, wpn, class) or "Unknown")
    end
    
    return output
end


-- nice thing for extra options, stolen from SWCS
local function OpenMenuExtra(pan, menu)
	pan:_OpenMenuExtra(menu)
    menu:AddSpacer()
    menu:AddSpacer()

    local classname = pan:GetSpawnName()
	local swep = weapons.Get(classname)
	if !swep then return end -- ??
    if swep.NotAWeapon then return end

    if swep.Attachments and !table.IsEmpty(swep.Attachments) then
        menu:AddOption("Give default preset", function()
            RunConsoleCommand( "arc9_giveswep_preset", classname, "default" )
        end):SetIcon( "icon16/arrow_rotate_anticlockwise.png" )

        menu:AddOption("Give random preset", function()
            RunConsoleCommand( "arc9_giveswep_preset", classname, "random" )
        end):SetIcon( "icon16/arrow_switch.png" )

        local subMenu, parentMenuOption = menu:AddSubMenu("Give existing preset")
        parentMenuOption:SetIcon("icon16/application_cascade.png")

        local existingones = 0
        for k, v in pairs(getpresetsforweapon(swep, classname)) do
            subMenu:AddOption(v, function()
                RunConsoleCommand( "arc9_giveswep_preset", classname, k )
            end):SetIcon("icon16/bullet_green.png")

            existingones = existingones + 1
        end

        if existingones == 0 then
            subMenu:Remove()
            parentMenuOption:Remove()
        end
    end

    if game.SinglePlayer() then
        menu:AddOption("Give ammo", function()
            RunConsoleCommand( "givecurrentammo" )
        end):SetIcon( "icon16/emoticon_tongue.png" )
    end
end




-- I HATE GARRY NEWMAN

hook.Add("PopulateWeapons", "zzz_ARC9_SubCategories", function(pnlContent, tree, anode)

    timer.Simple(0, function()
        -- Loop through the weapons and add them to the menu
        local Weapons = list.Get("Weapon")
        local Categorised = {}
        local ARC9Cats = {}

        local truenames = ARC9:UseTrueNames()

        -- Build into categories + subcategories
        for k, weapon in pairs(Weapons) do
            if !weapon.Spawnable then continue end
            if !weapons.IsBasedOn(k, "arc9_base") then continue end

            -- Get the weapon category as a string
            local Category = weapon.Category or "Other2"
            local WepTable = weapons.Get(weapon.ClassName)
            if (!isstring(Category)) then
                Category = tostring(Category)
            end

            -- Get the weapon subcategory as a string
            local SubCategory = "Other"
            if (WepTable != nil and WepTable.SubCategory != nil) then
                SubCategory = WepTable.SubCategory
                if (!isstring(SubCategory)) then
                    SubCategory = tostring(SubCategory)
                end
            end

            if truenames and WepTable.TrueName then
                weapon.PrintName = WepTable.TrueName
            end

            -- Insert it into our categorised table
            Categorised[Category] = Categorised[Category] or {}
            Categorised[Category][SubCategory] = Categorised[Category][SubCategory] or {}
            table.insert(Categorised[Category][SubCategory], weapon)
            ARC9Cats[Category] = true
        end

        -- Iterate through each category in the weapons table
        for _, node in pairs(tree:Root():GetChildNodes()) do

            if !ARC9Cats[node:GetText()] then continue end

            -- Get the subcategories registered in this category
            local catSubcats = Categorised[node:GetText()]

            if !catSubcats then continue end

            -- Overwrite the icon populate function with a custom one
            node.DoPopulate = function(self)

                -- If we've already populated it - forget it.
                -- if (self.PropPanel) then return end

                -- Create the container panel
                self.PropPanel = vgui.Create("ContentContainer", pnlContent)
                self.PropPanel:SetVisible(false)
                self.PropPanel:SetTriggerSpawnlistChange(false)

                -- Iterate through the subcategories
                for subcatName, subcatWeps in SortedPairs(catSubcats) do

                    -- Create the subcategory header, if more than one exists for this category
                    if (table.Count(catSubcats) > 1) then
                        local label = vgui.Create("ContentHeader", container)
						
						if subcatName:sub(1, 1):match("%d") then
							subcatName = string.sub(subcatName, 2)
						end
						
                        label:SetText(subcatName)
                        self.PropPanel:Add(label)
                    end

                    -- Create the clickable icon
                    for _, ent in SortedPairsByMemberValue(subcatWeps, "PrintName") do
                        local newpanel = spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", self.PropPanel, {
                            nicename  = ent.PrintName or ent.ClassName,
                            spawnname = ent.ClassName,
                            material  = ent.IconOverride or "entities/" .. ent.ClassName .. ".png",
                            admin     = ent.AdminOnly
                        })
                        newpanel._OpenMenuExtra = newpanel._OpenMenuExtra or newpanel.OpenMenuExtra
                        newpanel.OpenMenuExtra = OpenMenuExtra
                    end
                end
            end

            -- If we click on the node populate it and switch to it.
            node.DoClick = function(self)
                self:DoPopulate()
                pnlContent:SwitchPanel(self.PropPanel)
            end
        end

        -- Select the first node
        local FirstNode = tree:Root():GetChildNode(0)
        if (IsValid(FirstNode)) then
            FirstNode:InternalDoClick()
        end
    end)
end)

list.Set("ContentCategoryIcons", "ARC9 - Ammo", "arc9/icon_16.png")
list.Set("ContentCategoryIcons", "ARC9 - Attachments", "arc9/icon_16.png")

-- Give all categories with ARC9 weapons our icon unless one is already set
timer.Simple(0, function()
    for i, wep in pairs(weapons.GetList()) do
        local weap = weapons.Get(wep.ClassName)
        if weap and weap.ARC9 then
            local cat = weap.Category
            if cat and !list.HasEntry("ContentCategoryIcons", cat) then
                list.Set("ContentCategoryIcons", cat, "arc9/icon_16.png")
            end
        end
    end
end)