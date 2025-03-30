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
        menu:AddOption( ARC9:GetPhrase( "spawnmenu.spawnpreset.default" ), function()
            RunConsoleCommand( "arc9_giveswep_preset", classname, "default" )
        end):SetIcon( "icon16/arrow_rotate_anticlockwise.png" )

        menu:AddOption( ARC9:GetPhrase( "spawnmenu.spawnpreset.random" ), function()
            RunConsoleCommand( "arc9_giveswep_preset", classname, "random" )
        end):SetIcon( "icon16/arrow_switch.png" )

        local subMenu, parentMenuOption = menu:AddSubMenu( ARC9:GetPhrase( "spawnmenu.spawnpreset" ) )
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
        menu:AddOption( ARC9:GetPhrase( "spawnmenu.giveammo" ), function()
            RunConsoleCommand( "givecurrentammo" )
        end):SetIcon( "icon16/emoticon_tongue.png" )
    end
end


-- default gmod spawnicon paint code but edited
local matOverlay_Normal = Material( "arc9/ui/spawnicon_normal.png", "" )
local matOverlay_Hovered = Material( "arc9/ui/spawnicon_hold.png", "" )
local matOverlay_Shadow = Material( "arc9/bigblur.png", "mips smooth" )

local matOverlay_AdminOnly = Material( "icon16/shield.png" )
local matOverlay_NPCWeapon = Material( "icon16/monkey.png" )
local matOverlay_NPCWeaponSelected = Material( "icon16/monkey_tick.png" )
local shadowColor = Color( 0, 0, 0, 200 )
local hoversound = "arc9/newui/uimouse_hover.ogg"

surface.CreateFont( "ARC9_Spawnmenu_Name", { font = ARC9:GetFont(), size = 20, weight = 600, antialias = true, extended = true } )
surface.CreateFont( "ARC9_Spawnmenu_Header", { font = ARC9:GetFont(), size = 56, weight = 650, antialias = true, extended = true } )

local function DrawTextShadow( text, x, y )
	draw.SimpleText( text, "ARC9_Spawnmenu_Name", x + 1, y + 1, shadowColor )
	draw.SimpleText( text, "ARC9_Spawnmenu_Name", x, y, color_white )
end

local function DrawTextShadow2( text, x, y )
	draw.SimpleText( text, "ARC9_Spawnmenu_Header", x + 2, y + 2, shadowColor )
	draw.SimpleText( text, "ARC9_Spawnmenu_Header", x, y, color_white )
end

local function paintcoolicon(self, w, h)
    if ( self.Depressed && !self.Dragging ) then
        if ( self.Border != 8 ) then
            -- self.Border = 8
            self:OnDepressionChanged( true )
        end
    else
        if ( self.Border != 0 ) then
            -- self.Border = 0
            self:OnDepressionChanged( false )
        end
    end


    render.PushFilterMag( TEXFILTER.ANISOTROPIC )
    render.PushFilterMin( TEXFILTER.ANISOTROPIC )


    render.PopFilterMin()
    render.PopFilterMag()

    if self:GetAdminOnly() then
        surface.SetDrawColor( 255, 208, 0, 200)
    else
        surface.SetDrawColor( 255, 255, 255, 200)
    end
    
    local fakepressed = self.Depressed
    if self.SubMenu and self.SubMenu:IsVisible() then fakepressed = true else fakepressed = self.Depressed end

    local drawText = false
    if ( !dragndrop.IsDragging() && ( self:IsHovered() || fakepressed || self:IsChildHovered() ) ) then
        surface.SetDrawColor( 255, 255, 255, 100)
        surface.SetMaterial( matOverlay_Hovered )
        local localborder = self.Border * -0.2
        surface.DrawTexturedRect( localborder, localborder, w - localborder * 2, h - localborder * 2 )
        self.Border = fakepressed and math.Approach( self.Border, 3, FrameTime() * 600 ) or math.Approach( self.Border, -30, FrameTime() * 300 )
    else
        surface.SetMaterial( matOverlay_Normal )
        local localborder = self.Border + 2
        surface.DrawTexturedRect( localborder, localborder, w - localborder * 2, h - localborder * 2 )
        drawText = true
        self.Border = math.Approach( self.Border, 0, FrameTime() * 500 )
    end
    
    
    self:SetDrawOnTop(self.Border < 0)

	local old = DisableClipping( self.Border < 0 )
    -- self:NoClipping(self.Border < 0)

    local progress = self.Border / -30
    surface.SetDrawColor( 10, 10, 10, 160 *progress)
    surface.SetMaterial( matOverlay_Shadow )
    local localborder = self.Border * 1.3
    surface.DrawTexturedRect( localborder, localborder, w - localborder * 2, h - localborder * 2 )

    local mxx, myy = self:ScreenToLocal( input.GetCursorPos() )
    mxx, myy = math.Clamp((mxx - 64)/64, -1, 1) * 8 * progress, math.Clamp((myy - 64)/64, -1, 1) * 8 * progress
    
    surface.SetDrawColor( 255, 255, 255, 255 )
    self.Image:PaintAt( 3 + self.Border + mxx, 3 + self.Border + myy, 128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2 )
    
    if progress > 0.1 then
        local _, mousechecky = self:LocalToScreen( 64, 64)
        local anticlipoffset = 0
        if mousechecky > ScrH() - 200 then anticlipoffset = -256 end
        mxx, myy = mxx * 0.75, myy * 0.75

        surface.SetFont( "ARC9_Spawnmenu_Header" )
        local tW, tH = surface.GetTextSize( self.m_NiceName )

        surface.SetDrawColor( 10, 10, 10, 200 *progress)
        surface.SetMaterial( matOverlay_Shadow )
        surface.DrawTexturedRect( 64 + mxx - tW/2 - 64, 3 + self.Border + myy + 128 - 8 - self.Border * 2-16 + anticlipoffset, tW + 128, tH+32 )

        surface.SetDrawColor( 34, 34, 34, 220 *progress)
        surface.DrawRect( 64 + mxx - tW/2 - 16, 3 + self.Border + myy + 128 - 8 - self.Border * 2 -4 + anticlipoffset, tW + 32, tH+8 )

        DrawTextShadow2( self.m_NiceName, 64 + mxx - tW/2, 3 + self.Border + myy + 128 - 8 - self.Border * 2 + anticlipoffset )
    end


    if drawText then
        -- Admin only icon
        if self:GetAdminOnly() then
            surface.SetMaterial( matOverlay_AdminOnly )
            surface.DrawTexturedRect( self.Border + 8, self.Border + 8, 16, 16 )
        end
    
        -- Draw NPC weapon support icon
        -- This whole thing could be more dynamic
        -- if ( self:GetIsNPCWeapon() ) then
        --     surface.SetMaterial( matOverlay_NPCWeapon )
    
        --     if ( self:GetSpawnName() == GetConVarString( "gmod_npcweapon" ) ) then
        --         surface.SetMaterial( matOverlay_NPCWeaponSelected )
        --     end
    
        --     surface.DrawTexturedRect( w - self.Border - 24, self.Border + 8, 16, 16 )
        -- end
    
        -- self:ScanForNPCWeapons()


        local buffere = self.Border + 10

        -- Set up smaller clipping so cut text looks nicer
        local px, py = self:LocalToScreen( buffere, 0 )
        local pw, ph = self:LocalToScreen( w - buffere, h )
        render.SetScissorRect( px, py, pw, ph, true )

        -- Calculate X pos
        surface.SetFont( "ARC9_Spawnmenu_Name" )
        local tW, tH = surface.GetTextSize( self.m_NiceName )

        local x = w / 2 - tW / 2
        if ( tW > ( w - buffere * 2 ) ) then
            local mx, my = self:ScreenToLocal( input.GetCursorPos() )
            local diff = tW - w + buffere * 2

            x = buffere + math.Remap( math.Clamp( mx, 0, w ), 0, w, 0, -diff )
        end

        -- Draw
        DrawTextShadow( self.m_NiceName, x, h - tH - 5 )

        render.SetScissorRect( 0, 0, 0, 0, false )
    end
	DisableClipping( old )
end


local function OpenGenericSpawnmenuRightClickMenu(self) -- fuck why default func doesn't save this panel anywhere
	local menu = DermaMenu()
		if ( self:GetSpawnName() and self:GetSpawnName() != "" ) then
			menu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText( self:GetSpawnName() ) end ):SetIcon( "icon16/page_copy.png" )
		end
		if ( isfunction( self.OpenMenuExtra ) ) then
			self:OpenMenuExtra( menu )
		end
		hook.Run( "SpawnmenuIconMenuOpen", menu, self, self:GetContentType() )
		if ( !IsValid( self:GetParent() ) || !self:GetParent().GetReadOnly || !self:GetParent():GetReadOnly() ) then
			menu:AddSpacer()
			menu:AddOption( "#spawnmenu.menu.delete", function()
				self:Remove()
				hook.Run( "SpawnlistContentChanged" )
			end ):SetIcon( "icon16/bin_closed.png" )
		end
	menu:Open()

    self.SubMenu = menu
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
						
                        label:SetText(" " .. subcatName)
                        if GetConVar("arc9_fancy_spawnmenu"):GetBool() then
                            label:SetFont( "ARC9_Spawnmenu_Header" )
                            label:SetAutoStretch( false )
                            label.SizeToContents = function() end
                            label:SetWidth(label:GetParent():GetWide())
                            -- label:SetWidth(64, 777)
                            label.Paint = function(self, w, h) 
                                surface.SetDrawColor( 0, 0, 0, 98)
                                surface.DrawRect( self:GetContentSize() + 32, h/2-4/2, w/2, 4 )
                                surface.SetMaterial( matOverlay_Shadow )
                                surface.DrawTexturedRect( 0, 0, self:GetContentSize(), h )
                            end
                        end
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
                        if GetConVar("arc9_fancy_spawnmenu"):GetBool() then 
                            newpanel.Paint = paintcoolicon
                            newpanel.OnCursorEntered = function(self) surface.PlaySound(hoversound) end
                            newpanel:SetTooltipDelay(1337)
                        end
                        newpanel._OpenMenuExtra = newpanel._OpenMenuExtra or newpanel.OpenMenuExtra
                        newpanel.OpenMenuExtra = OpenMenuExtra
	                    newpanel.OpenMenu = OpenGenericSpawnmenuRightClickMenu
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