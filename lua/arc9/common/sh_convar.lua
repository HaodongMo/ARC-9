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
        default = "0",
        client = true
    },
    {
        name = "cust_light",
        default = "0",
        client = true
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
        label = "HUD Everywhere",
        command = "arc9_hud_always"
    })
end

local function menu_client_customization(panel)
    panel:AddControl("checkbox", {
        label = "Customization Blur",
        command = "arc9_cust_blur"
    })
    panel:AddControl("checkbox", {
        label = "Customization Light",
        command = "arc9_cust_light"
    })
end

local function menu_client_controller(panel)
    --local textbox = panel:TextEntry("Custom Controller Glyphset", "arc9_controller_glyphset")
    panel:AddControl( "header", { description = "Replace key names with controller glyphs." } )
    panel:CheckBox("Internal Command Names", "arc9_controller")
    panel:CheckBox("Controller Rumble w/ SInput", "arc9_controller_rumble")

    local listview = vgui.Create("DListView", panel)
    listview:SetSize( 99, 200 )
    panel:AddItem( listview )
    listview:SetMultiSelect( true )
    listview:AddColumn( "Input" )
    listview:AddColumn( "Output" )

    local tex_inp = vgui.Create( "DTextEntry", panel )
    local tex_out = vgui.Create( "DTextEntry", panel )
    panel:AddItem( tex_inp )
    panel:ControlHelp( "Glyph or keyboard icon to be replaced.\nInputs are case-sensitive!" )
    panel:AddItem( tex_out )
    panel:ControlHelp( "Glyph to show." )
    tex_inp:SetPlaceholderText("Input to replace")
    tex_out:SetPlaceholderText("Output to show")

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
    matselect_filter:AddChoice( "Common (includes mice)", "shared_" )
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
        matselect = vgui.Create( "MatSelect", panel )
        Derma_Hook( matselect.List, "Paint", "Paint", "Panel" )
            function matselect:AddMaterial( label, value )
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
        label = "Enable Penetration",
        command = "ARC9_penetration"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Deal Equal Damage",
        command = "ARC9_npc_equality"
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

local function menu_server_attachments(panel)
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
        label = "NPCs Get Random Attachments",
        command = "ARC9_npc_atts"
    })
end

local function menu_server_modifiers(panel)
end

local clientmenus_ti = {
    {
        text = "Client", func = menu_client_ti
    },
    {
        text = "Client - Customization", func = menu_client_customization
    },
    {
        text = "Client - Controller", func = menu_client_controller
    },
    {
        text = "Server", func = menu_server_ti
    },
    {
        text = "Server - Attachments", func = menu_server_attachments
    },
    {
        text = "Server - Modifiers", func = menu_server_modifiers
    },
}

hook.Add("PopulateToolMenu", "ARC9_MenuOptions", function()
    for smenu, data in pairs(clientmenus_ti) do
        spawnmenu.AddToolMenuOption("Options", "ARC-9", "ARC9_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

end