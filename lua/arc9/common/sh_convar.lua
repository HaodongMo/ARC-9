local conVars = {
    {
        name = "truenames",
        default = "0",
        client = true,
        min = 0,
        max = 2,
    },
    {
        name = "truenames_default",
        default = "0",
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "truenames_enforced",
        default = "0",
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "reflex_r",
        default = "255",
        client = true
    },
    {
        name = "reflex_g",
        default = "0",
        client = true
    },
    {
        name = "reflex_b",
        default = "0",
        client = true
    },
    {
        name = "scope_r",
        default = "255",
        client = true
    },
    {
        name = "scope_g",
        default = "0",
        client = true
    },
    {
        name = "scope_b",
        default = "0",
        client = true
    },
    {
        name = "language",
        default = "",
        client = true,
    },
    {
        name = "font",
        default = "",
        client = true,
    },
    {
        name = "maxatts",
        default = "100",
    },
    {
        name = "autosave",
        default = "1",
        client = true
    },
    {
        name = "fov",
        default = "0",
        client = true
    },
    {
        name = "controller",
        default = "0",
        client = true
    },
    {
        name = "controller_rumble",
        default = "1",
        client = true
    },
    {
        name = "controller_glyphset",
        default = "",
        client = true
    },
    {
        name = "bodydamagecancel",
        default = "1",
        replicated = true
    },
    {
        name = "free_atts",
        default = "0",
        replicated = true
    },
    {
        name = "lock_atts",
        default = "0",
        replicated = true
    },
    {
        name = "loseattsondie",
        default = "1",
    },
    {
        name = "generateattentities",
        default = "1",
        replicated = true
    },
    {
        name = "npc_equality",
        default = "0",
    },
    {
        name = "npc_atts",
        default = "1",
    },
    {
        name = "penetration",
        default = "1",
        replicated = true
    },
    {
        name = "freeaim",
        default = "1",
        replicated = true
    },
    {
        name = "sway",
        default = "1",
        replicated = true
    },
    {
        name = "benchgun",
        default = "0",
    },
    {
        name = "ricochet",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_physics",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_gravity",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_drag",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_imaginary",
        default = "1",
        replicated = true
    },
    {
        name = "bullet_lifetime",
        default = "10",
        replicated = true
    },
    {
        name = "cheapscopes",
        default = "0"
    },
    {
        name = "compensate_sens",
        default = "1"
    },
    {
        name = "freeaim",
        default = "1"
    },
    {
        name = "cust_blur",
        default = "1"
    },
    {
        name = "hud_always",
        default = "0"
    },
    {
        name = "hud_keephints",
        default = "0",
        client = true
    },
    {
        name = "infinite_ammo",
        default = "0",
        replicated = true
    },
    {
        name = "tpik",
        default = "1",
        client = true
    },
    {
        name = "crosshair_force",
        default = "0",
        replicated = true
    },
    {
        name = "thirdperson",
        default = "0",
        client = true
    },
    {
        name = "thirdperson_force",
        default = "0",
        replicated = true
    },
    {
        name = "cam_shoulder",
        default = "1",
        client = true
    },
    {
        name = "dev_irons_x",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_y",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_z",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_pitch",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_yaw",
        default = "0",
        client = true
    },
    {
        name = "dev_irons_roll",
        default = "0",
        client = true
    },
}

local prefix = "arc9_"

for _, var in pairs(conVars) do
    local convar_name = prefix .. var.name

    if var.client and CLIENT then
        CreateClientConVar(convar_name, var.default, true)
    else
        local flags = FCVAR_ARCHIVE
        if var.replicated then
            flags = flags + FCVAR_REPLICATED
        end
        CreateConVar(convar_name, var.default, flags, var.helptext, var.min, var.max)
    end
end

if CLIENT then

local function menu_client_ti(panel)
    panel:AddControl("checkbox", {
        label = "Reload Automatically",
        command = "arc9_autoreload"
    })
    panel:AddControl("checkbox", {
        label = "Auto-Save Weapon",
        command = "arc9_autosave"
    })
    panel:AddControl("checkbox", {
        label = "Compensate Sensitivity",
        command = "arc9_compensate_sens"
    })
    panel:AddControl("checkbox", {
        label = "Customization Blur",
        command = "arc9_cust_blur"
    })
    panel:AddControl("checkbox", {
        label = "Draw ARC-9 HUD Everywhere",
        command = "arc9_hud_always"
    })
end

local function menu_client_controller(panel)
    --local textbox = panel:TextEntry("Custom Controller Glyphset", "arc9_controller_glyphset")
    panel:AddControl( "label", { text = "Select a controller glyphset to use." } )
    panel:CheckBox("Controller Glyph Presets", "arc9_controller")
    panel:CheckBox("Rumble", "arc9_controller_rumble")
    local combobox = panel:ComboBox("Controller Glyphset", "arc9_controller_glyphset" )
    combobox:AddChoice( "PS4", "!PS4" )
    combobox:AddChoice( "PS5", "!PS5" )
    combobox:AddChoice( "Xbox", "!Xbox" )
    -- combobox:AddChoice( "Xbox 360", "!Xbox360" ) just changes Start and Select which are not used
    combobox:AddChoice( "Steam Controller", "!SC" )
    combobox:AddChoice( "Steam Deck", "!SD" )
    combobox:AddChoice( "Switch Pro", "!SwitchPro" )
    combobox:AddChoice( "Switch Pro (Xbox ABXY)", "!SwitchProXboxABXY" )

    panel:AddControl("label", { text = "\nOr, make your own." } )
    local listview = vgui.Create("DListView", panel)
    listview:SetSize( 99, 200 )
    panel:AddItem( listview )
    listview:SetMultiSelect( true )
    listview:AddColumn( "Input" )
    listview:AddColumn( "Output" )

    local tex_inp = vgui.Create( "DTextEntry", panel )
    local tex_out = vgui.Create( "DTextEntry", panel )
    panel:AddItem( tex_inp )
    panel:ControlHelp( "Glyph or keyboard icon to be replaced.\nAll keyboard and mouse inputs are in uppercase." )
    panel:AddItem( tex_out )
    panel:ControlHelp( "Glyph to show." )
    tex_inp:SetPlaceholderText("Input: Button to replace")
    tex_out:SetPlaceholderText("Output: Button to show")

    local but_add = vgui.Create( "DButton", panel )
    local but_rem = vgui.Create( "DButton", panel )
    local but_upd = vgui.Create( "DButton", panel )
    local but_app = vgui.Create( "DButton", panel )
    panel:AddItem( but_add )
    panel:AddItem( but_rem )
    panel:AddItem( but_upd )
    panel:AddItem( but_app )
    but_add:SetText("Add")
    but_rem:SetText("Remove selected")
    but_upd:SetText("Restore from memory")
    but_app:SetText("Save & apply")

    function but_add:DoClick()
        listview:AddLine( tex_inp:GetValue(), tex_out:GetValue() )
    end

    function but_rem:DoClick()
        for i, v in pairs(listview:GetSelected()) do
            listview:RemoveLine( v:GetID() )
        end
    end

    function but_upd:DoClick()
        listview:Clear()

        local config = GetConVar("arc9_controller_glyphset"):GetString()
        config = string.Split( config, "\\n" )
        for i, v in ipairs(config) do
            local swig = string.Split( v, "\\t" )
            if swig[1] == "" then continue end
            listview:AddLine( swig[1], swig[2] )
        end
    end

    function but_app:DoClick()
        local toapply = ""
        local order = 1
        for k, line in pairs( listview:GetLines() ) do
            if order != 1 then toapply = toapply .. "\\n" end
            toapply = toapply .. line:GetValue( 1 ) .. "\\t" .. line:GetValue( 2 )
            order = order + 1
        end
        RunConsoleCommand("arc9_controller_glyphset", toapply)
    end


    local matselect_filter = vgui.Create( "DComboBox", panel )
    panel:AddItem( matselect_filter )
    matselect_filter:AddChoice( "! No filter", "" )
    matselect_filter:AddChoice( "Common", "shared_" )
    matselect_filter:AddChoice( "PS4", "ps4_" )
    matselect_filter:AddChoice( "PS5", "ps5_" )
    matselect_filter:AddChoice( "PS Common", "ps_" )
    matselect_filter:AddChoice( "Switch Pro", "switchpro_" )
    matselect_filter:AddChoice( "Steam Controller", "sc_" )
    matselect_filter:AddChoice( "Steam Deck", "sd_" )
    matselect_filter:AddChoice( "Xbox", "xbox_" )
    matselect_filter:AddChoice( "Xbox 360", "xbox360_" )
    matselect_filter:SetValue( "Filter by controller type" )

    local matselect = ""
    local function GenerateMatSelect()
        matselect = vgui.Create( "ARC9_MatSelect", panel )
        Derma_Hook( matselect.List, "Paint", "Paint", "Panel" )
        panel:AddItem( matselect )

        for k, v in SortedPairs( ARC9.CTRL_Exists ) do
            local sel, seldata = matselect_filter:GetSelected()
            if string.find( k, seldata or "" ) then
                matselect:AddMaterial( k, "arc9/glyphs_light/" .. k .. "_lg.png" )
            end
        end

        matselect:SetAutoHeight( true )
        matselect:SetItemWidth( 0.1875 )
        matselect:SetItemHeight( 0.1875 )

        matselect.InputPanel = tex_inp
        matselect.OutputPanel = tex_out
    end
    GenerateMatSelect()
    but_upd:DoClick()

    function matselect_filter:OnSelect()
        matselect:Remove()
        GenerateMatSelect()
    end

end

local function menu_server_ti(panel)
    panel:AddControl("checkbox", {
        label = "Free Attachments",
        command = "ARC9_free_atts"
    })
    panel:AddControl("checkbox", {
        label = "Attachment Locking",
        command = "ARC9_lock_atts"
    })
    panel:AddControl("checkbox", {
        label = "Lose Attachments On Death",
        command = "ARC9_loseattsondie"
    })
    panel:AddControl("checkbox", {
        label = "Generate Attachment Entities",
        command = "arc9_generateattentities"
    })
    panel:AddControl("checkbox", {
        label = "Enable Penetration",
        command = "ARC9_penetration"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Deal Equal Damage",
        command = "ARC9_npc_equality"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Get Random Attachments",
        command = "ARC9_npc_atts"
    })
    panel:AddControl("label", {
        text = "Disable body damage cancel only if you have another addon that will override the hl2 limb damage multipliers."
    })
    panel:AddControl("checkbox", {
        label = "Default Body Damage Cancel",
        command = "ARC9_bodydamagecancel"
    })
    panel:AddControl("checkbox", {
        label = "Infinite Ammo",
        command = "arc9_infinite_ammo"
    })
end

local clientmenus_ti = {
    {
        text = "Client", func = menu_client_ti
    },
    {
        text = "Controller", func = menu_client_controller
    },
    {
        text = "Server", func = menu_server_ti
    },
}

hook.Add("PopulateToolMenu", "ARC9_MenuOptions", function()
    for smenu, data in pairs(clientmenus_ti) do
        spawnmenu.AddToolMenuOption("Options", "ARC-9", "ARC9_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

end


-- This is an edit of the MatSelect panel for the controller configurator. TODO: Move this to another file.

if CLIENT then


local PANEL = {}

AccessorFunc( PANEL, "ItemWidth", "ItemWidth", FORCE_NUMBER )
AccessorFunc( PANEL, "ItemHeight", "ItemHeight", FORCE_NUMBER )
AccessorFunc( PANEL, "Height", "NumRows", FORCE_NUMBER )
AccessorFunc( PANEL, "m_bSizeToContent", "AutoHeight", FORCE_BOOL )

local border = 0
local border_w = 8
local matHover = Material( "gui/ps_hover.png", "nocull" )
local boxHover = GWEN.CreateTextureBorder( border, border, 64 - border * 2, 64 - border * 2, border_w, border_w, border_w, border_w, matHover )

-- This function is used as the paint function for selected buttons.
local function HighlightedButtonPaint( self, w, h )

	boxHover( 0, 0, w, h, color_white )

end

function PANEL:Init()

	-- A panellist is a panel that you shove other panels
	-- into and it makes a nice organised frame.
	self.List = vgui.Create( "DPanelList", self )
	self.List:EnableHorizontal( true )
	self.List:EnableVerticalScrollbar()
	self.List:SetSpacing( 1 )
	self.List:SetPadding( 3 )

	self.Controls = {}
	self.Height = 2

    self.InputPanel = ""
    self.OutputPanel = ""

	self:SetItemWidth( 128 )
	self:SetItemHeight( 128 )

end

function PANEL:SetAutoHeight( bAutoHeight )

	self.m_bSizeToContent = bAutoHeight
	self.List:SetAutoSize( bAutoHeight )

	self:InvalidateLayout()

end

function PANEL:AddMaterial( label, value )

	-- Creeate a spawnicon and set the model
	local Mat = vgui.Create( "DImageButton", self )
	Mat:SetOnViewMaterial( value, "models/wireframe" )
	Mat.AutoSize = false
	Mat.Value = value
	Mat:SetSize( self.ItemWidth, self.ItemHeight )
	Mat:SetTooltip( label )

	-- Run a console command when the Icon is clicked
	Mat.DoClick = function( button )
		local menu = DermaMenu()
		menu:AddOption( "As input", function() self.InputPanel:SetValue( label ) end ):SetIcon( "icon16/page_copy.png" )
		menu:AddOption( "As output", function() self.OutputPanel:SetValue( label ) end ):SetIcon( "icon16/page_paste.png" )
		menu:Open()
	end

	Mat.DoRightClick = function( button )
	end

	-- Add the Icon us
	self.List:AddItem( Mat )
	table.insert( self.Controls, Mat )

	self:InvalidateLayout()

end

function PANEL:SetItemSize( pnl )

	local maxW = self:GetWide()
	if ( self.List.VBar && self.List.VBar.Enabled ) then maxW = maxW - self.List.VBar:GetWide() end

	local w = self.ItemWidth
	if ( w < 1 ) then
		local numIcons = math.floor( 1 / w )
		w = math.floor( ( maxW - self.List:GetPadding() * 2 - self.List:GetSpacing() * ( numIcons - 1 ) ) / numIcons )
	end

	local h = self.ItemHeight
	if ( h < 1 ) then
		local numIcons = math.floor( 1 / h )
		h = math.floor( ( maxW - self.List:GetPadding() * 2 - self.List:GetSpacing() * ( numIcons - 1 ) ) / numIcons )
	end

	pnl:SetSize( w, h )

end

function PANEL:AddMaterialEx( label, material, value, convars )

	-- Creeate a spawnicon and set the model
	local Mat = vgui.Create( "DImageButton", self )
	Mat:SetImage( material )
	Mat.AutoSize = false
	Mat.Value = value
	Mat.ConVars = convars
	self:SetItemSize( Mat )
	Mat:SetTooltip( label )

	-- Run a console command when the Icon is clicked
	Mat.DoClick = function ( button )

		for k, v in pairs( convars ) do RunConsoleCommand( k, v ) end

	end

	-- Add the Icon us
	self.List:AddItem( Mat )
	table.insert( self.Controls, Mat )

	self:InvalidateLayout()

end

function PANEL:ControlValues( kv )

	self.BaseClass.ControlValues( self, kv )

	self.Height = kv.height or 2

	-- Load the list of models from our keyvalues file
	if ( kv.options ) then

		for k, v in pairs( kv.options ) do
			self:AddMaterial( k, v )
		end

	end

	self.ItemWidth = kv.itemwidth or 32
	self.ItemHeight = kv.itemheight or 32

	for k, v in pairs( self.Controls ) do
		v:SetSize( self.ItemWidth, self.ItemHeight )
	end

	self:InvalidateLayout()

end

function PANEL:PerformLayout()

	self.List:SetPos( 0, 0 )

	for k, v in pairs( self.List:GetItems() ) do
		self:SetItemSize( v )
	end

	if ( self.m_bSizeToContent ) then
		self.List:SetWide( self:GetWide() )
		self.List:InvalidateLayout( true )
		self:SetTall( self.List:GetTall() + 5 )

		return
	end

	self.List:InvalidateLayout( true ) -- Rebuild

	local maxW = self:GetWide()
	if ( self.List.VBar && self.List.VBar.Enabled ) then maxW = maxW - self.List.VBar:GetWide() end

	local h = self.ItemHeight
	if ( h < 1 ) then
		local numIcons = math.floor( 1 / h )
		h = math.floor( ( maxW - self.List:GetPadding() * 2 - self.List:GetSpacing() * ( numIcons - 1 ) ) / numIcons )
	end

	local Height = ( h * self.Height ) + ( self.List:GetPadding() * 2 ) + self.List:GetSpacing() * ( self.Height - 1 )

	self.List:SetSize( self:GetWide(), Height )
	self:SetTall( Height + 5 )

end

function PANEL:FindAndSelectMaterial( Value )

	self.CurrentValue = Value

	for k, Mat in pairs( self.Controls ) do

		if ( Mat.Value == Value ) then

			-- Remove the old overlay
			if ( self.SelectedMaterial ) then
				self.SelectedMaterial.PaintOver = self.OldSelectedPaintOver
			end

			-- Add the overlay to this button
			self.OldSelectedPaintOver = Mat.PaintOver
			Mat.PaintOver = HighlightedButtonPaint
			self.SelectedMaterial = Mat

		end

	end

end

function PANEL:TestForChanges()

	local cvar = self:ConVar()
	if ( !cvar ) then return end

	local Value = GetConVarString( cvar )
	if ( Value == self.CurrentValue ) then return end

	self:FindAndSelectMaterial( Value )

end

vgui.Register( "ARC9_MatSelect", PANEL, "ContextBase" )

end