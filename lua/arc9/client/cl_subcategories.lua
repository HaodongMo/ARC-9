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

hook.Add("PopulateWeapons", "ARC9_SubCategories", function(pnlContent, tree, node)

    -- Loop through the weapons and add them to the menu
    local Weapons = list.Get("Weapon")
    local Categorised = {}

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
        if (WepTable != nil && WepTable.SubCategory != nil) then
            SubCategory = WepTable.SubCategory
            if (!isstring(SubCategory)) then
                SubCategory = tostring(SubCategory)
            end
        end

        -- Insert it into our categorised table
        Categorised[Category] = Categorised[Category] or {}
        Categorised[Category][SubCategory] = Categorised[Category][SubCategory] or {}
        table.insert(Categorised[Category][SubCategory], weapon)
    end

    -- Iterate through each category in the weapons table
    for _, node in pairs(tree:Root():GetChildNodes()) do

        -- Get the subcategories registered in this category
        local catSubcats = Categorised[node:GetText()]

        -- Overwrite the icon populate function with a custom one
        node.DoPopulate = function(self)

            -- If we've already populated it - forget it.
            if (self.PropPanel) then return end

            -- Create the container panel
            self.PropPanel = vgui.Create("ContentContainer", pnlContent)
            self.PropPanel:SetVisible(false)
            self.PropPanel:SetTriggerSpawnlistChange(false)

            -- Iterate through the subcategories
            for subcatName, subcatWeps in SortedPairs(catSubcats) do

                -- Create the subcategory header, if more than one exists for this category
                if (table.Count(catSubcats) > 1) then
                    local label = vgui.Create("ContentHeader", container)
                    label:SetText(subcatName)
                    self.PropPanel:Add(label)
                end

                -- Create the clickable icon
                for _, ent in SortedPairsByMemberValue(subcatWeps, "PrintName") do
                    spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", self.PropPanel, {
                        nicename  = ent.PrintName or ent.ClassName,
                        spawnname = ent.ClassName,
                        material  = ent.IconOverride or "entities/" .. ent.ClassName .. ".png",
                        admin     = ent.AdminOnly
                    })
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