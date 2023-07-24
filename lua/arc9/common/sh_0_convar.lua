local conVars = {
    {
        name = "cruelty_reload",
        default = "0",
        client = true
    },
    {
        name = "cruelty_reload_april_fools",
        default = "0",
        client = true
    },
    {
        name = "allflash",
        default = "0",
        client = true
    },
    {
        name = "truenames",
        default = "2",
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
        name = "cross_enable",
        default = "1",
        client = true
    },
    {
        name = "cross_r",
        default = "255",
        client = true
    },
    {
        name = "cross_g",
        default = "255",
        client = true
    },
    {
        name = "cross_b",
        default = "255",
        client = true
    },
    {
        name = "cross_a",
        default = "150",
        client = true
    },
    {
        name = "cross_size_mult",
        default = "1",
        client = true
    },
    {
        name = "cross_size_dot",
        default = "1",
        client = true
    },
    {
        name = "cross_size_prong",
        default = "1",
        client = true
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
        name = "hud_color_r",
        default = "255",
        client = true
    },
    {
        name = "hud_color_g",
        default = "123",
        client = true
    },
    {
        name = "hud_color_b",
        default = "0",
        client = true
    },
    {
        name = "hud_darkmode",
        default = "0",
        client = true
    },
    {
        name = "hud_showunowned",
        default = "1",
        client = true
    },
    {
        name = "language",
        default = "",
        client = true,
    },
    {
        name = "language_id",
        default = -1,
        client = true,
    },
    {
        name = "font",
        default = "",
        client = true,
    },
    {
        name = "font_addsize",
        default = "0",
        client = true,
    },
    {
        name = "hud_scale",
        default = "1",
        client = true,
    },
    {
        name = "hud_deadzonex",
        default = "0",
        client = true,
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
        name = "modifiers",
        default = "",
    },
    {
        name = "mod_bodydamagecancel",
        default = "1",
        replicated = true
    },
    {
        name = "atts_nocustomize",
        default = "0",
        replicated = true
    },
    {
        name = "atts_anarchy",
        default = "0",
        replicated = true
    },
    {
        name = "free_atts",
        default = "1",
        replicated = true
    },
    {
        name = "atts_max",
        default = "100",
    },
    {
        name = "atts_lock",
        default = "0",
        replicated = true
    },
    {
        name = "atts_loseondie",
        default = "1",
    },
    {
        name = "atts_generateentities",
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
        name = "npc_autoreplace",
        default = "0"
    },
    {
        name = "npc_blacklist",
        default = ""
    },
    {
        name = "npc_whitelist",
        default = ""
    },
    {
        name = "npc_give_weapons",
        default = "0"
    },
    {
        name = "npc_spread",
        default = "1"
    },
    {
        name = "replace_spawned",
        default = "0"
    },
    {
        name = "mod_penetration",
        default = "1",
        replicated = true
    },
    {
        name = "mod_freeaim",
        default = "0",
        replicated = true
    },
    {
        name = "mod_sway",
        default = "1",
        replicated = true
    },
    {
        name = "never_ready",
        default = "0",
    },
    {
        name = "dev_always_ready",
        default = "0",
    },
    {
        name = "dev_benchgun",
        default = "0",
    },
    {
        name = "dev_greenscreen",
        default = "0",
    },
    {
        name = "dev_benchgun_custom",
        default = "",
    },
    {
        name = "dev_crosshair",
        default = "0",
    },
    {
        name = "breath_hud",
        default = "1",
        client = true,
    },
    {
        name = "breath_pp",
        default = "1",
        client = true,
    },
    {
        name = "breath_sfx",
        default = "1",
        client = true,
    },
    {
        name = "breath_slowmo",
        default = "1",
        replicated = true
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
        name = "vm_bobstyle",
        default = "0",
        client = true,
    },
    {
        name = "vm_cambob",
        default = "1",
        client = true,
    },
    {
        name = "vm_cambobwalk",
        default = "0",
        client = true,
    },
    {
        name = "vm_cambobintensity",
        default = "0.75",
        client = true,
    },
    {
        name = "vm_addx",
        default = "0",
        client = true,
    },
    {
        name = "vm_addy",
        default = "0",
        client = true,
    },
    {
        name = "vm_addz",
        default = "0",
        client = true,
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
        name = "cust_light_brightness",
        default = "1",
        client = true
    },
    {
        name = "cust_hints",
        default = "1",
        client = true
    },
    {
        name = "cust_exit_reset_sel",
        default = "0",
        client = true
    },
    {
        name = "cust_roll_unlock",
        default = "0",
        client = true
    },
    {
        name = "killfeed_enable",
        default = "1",
        client = true
    },
    {
        name = "killfeed_dynamic",
        default = "1",
        client = true
    },
    {
        name = "killfeed_color",
        default = "0",
        client = true
    },
    {
        name = "hud_always",
        default = "0"
    },
    {
        name = "hud_compact",
        default = "0"
    },
    {
        name = "hud_arc9",
        default = "1"
    },
    {
        name = "hud_keephints",
        default = "0",
        client = true
    },
    {
        name = "hud_nohints",
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
        name = "tpik_others",
        default = "1",
        client = true
    },
    {
        name = "tpik_framerate",
        default = "60",
        client = true
    },
    {
        name = "autoreload",
        default = "0",
        client = true
    },
    {
        name = "toggleads",
        default = "0",
        client = true,
        userinfo = true
    },
    {
        name = "crosshair_force",
        default = "0",
        replicated = true
    },
    {
        name = "crosshair_static",
        default = "0",
        replicated = false,
        client = true
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
    {
        name = "dev_show_shield",
        default = "0",
        client = true
    },
    {
        name = "fx_rtblur",
        default = "0",
        client = true
    },
    {
        name = "fx_adsblur",
        default = "1",
        client = true
    },
    {
        name = "fx_reloadblur",
        default = "0",
        client = true
    },
    {
        name = "fx_animblur",
        default = "0",
        client = true
    },
    {
        name = "realrecoil",
        default = "1",
    },
    {
        name = "manualbolt",
        default = "0",
        client = true,
        userinfo = true
    },
    {
        name = "autolean",
        default = "1",
        client = true,
    },
    {
        name = "lean",
        default = "1",
    },
    {
        name = "togglelean",
        default = "0",
        client = true,
        userinfo = true
    },
    {
        name = "togglepeek",
        default = "0",
        client = true,
    },
    {
        name = "togglebreath",
        default = "0",
        client = true,
    },
    {
        name = "eject_fx",
        default = "1",
        client = true
    },
    {
        name = "eject_time",
        default = "0",
        client = true
    },
    {
        name = "never_ready",
        default = "0",
        replicated = true
    },
    {
        name = "muzzle_light",
        default = "1",
        client = true
    },
    {
        name = "muzzle_others",
        default = "1",
        client = true
    },
    {
        name = "mod_damage",
        default = "1",
        replicated = true
    },
    {
        name = "mod_spread",
        default = "1",
        replicated = true
    },
    {
        name = "mod_recoil",
        default = "1",
        replicated = true
    },
    {
        name = "mod_visualrecoil",
        default = "1",
        replicated = true
    },
    {
        name = "mod_adstime",
        default = "1",
        replicated = true
    },
    {
        name = "mod_sprinttime",
        default = "1",
        replicated = true
    },
    {
        name = "mod_damagerand",
        default = "1",
        replicated = true
    },
    {
        name = "mod_muzzlevelocity",
        default = "1",
        replicated = true
    },
    {
        name = "mod_rpm",
        default = "1",
        replicated = true
    },
    {
        name = "mod_headshotdamage",
        default = "1",
        replicated = true
    },
    {
        name = "mod_malfunction",
        default = "1",
        replicated = true
    },
    {
        name = "cust_tips",
        default = "1",
        client = true
    },
    {
        name = "precache_sounds_onfirsttake",
        default = "1",
        replicated = true
    },
    {
        name = "precache_allsounds_onstartup",
        default = "0",
        replicated = true
    },
    {
        name = "precache_attsmodels_onfirsttake",
        default = "0",
        replicated = true
    },
    {
        name = "precache_attsmodels_onstartup",
        default = "0",
        replicated = true
    },
    {
        name = "precache_wepmodels_onfirsttake",
        default = "0",
        replicated = true
    },
    {
        name = "precache_wepmodels_onstartup",
        default = "0",
        replicated = true
    },
    {
        name = "togglepeek_reset",
        default = "0",
        client = true,
    },
    {
        name = "recoilshake",
        default = "1",
    },
    {
        name = "equipment_generate_ammo",
        default = "1",
        replicated = true
    },
    {
        name = "mult_defaultammo",
        default = "2",
        replicated = true
    },
}

local prefix = "arc9_"

local torevertlist_cl = {}
local torevertlist_sv = {}

for _, var in pairs(conVars) do
    local convar_name = prefix .. var.name

    if var.client and CLIENT then
        table.insert(torevertlist_cl, convar_name)
        CreateClientConVar(convar_name, var.default, true, var.userinfo)
    else
        local flags = FCVAR_ARCHIVE
        if var.replicated then
            flags = flags + FCVAR_REPLICATED
        end
        if var.userinfo then
            flags = flags + FCVAR_USERINFO
        end
        table.insert(torevertlist_sv, convar_name)
        CreateConVar(convar_name, var.default, flags, var.helptext, var.min, var.max)
    end
end

if CLIENT then
    concommand.Add("arc9_settings_reset_client", function()
        for _, var in pairs(torevertlist_cl) do
            RunConsoleCommand(var, GetConVar(var):GetDefault()) -- :Revert() wont work!!!!!!!!! ghhh
        end
    end, nil, "Reset all client ARC9 settings.")
end

concommand.Add("arc9_settings_reset_server", function()
    for _, var in pairs(torevertlist_sv) do
        GetConVar(var):Revert()
    end
end, nil, "Reset all server ARC9 settings.")

if SERVER then
    util.AddNetworkString("ARC9_InvalidateAll")
    util.AddNetworkString("ARC9_InvalidateAll_ToClients")

    net.Receive("ARC9_InvalidateAll", function(len, ply)
        if ply:IsAdmin() then
            ARC9.InvalidateAll()
            net.Start("ARC9_InvalidateAll_ToClients")
            net.Broadcast()
        end
    end)
else
    net.Receive("ARC9_InvalidateAll_ToClients", function(len, ply)
        ARC9.InvalidateAll()
    end)
end

function ARC9.InvalidateAll()
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:IsWeapon() and ent.ARC9 then
            ent:InvalidateCache()
        end
    end
end

if CLIENT then

local function menu_client_ti(panel)
    panel:AddControl("checkbox", {
        label = "Auto-Save Weapon",
        command = "arc9_autosave"
    })
    panel:ControlHelp( "Reattach your last used attachments." )
    panel:AddControl("checkbox", {
        label = "Draw HUD",
        command = "arc9_hud_arc9"
    })
    panel:AddControl("checkbox", {
        label = "Draw HUD Everywhere",
        command = "arc9_hud_always"
    })
    panel:ControlHelp( "HUD on all weapons." )
    panel:AddControl("checkbox", {
        label = "ADS Blur",
        command = "arc9_fx_adsblur"
    })
    panel:AddControl("checkbox", {
        label = "ADS Blur on RT Scopes",
        command = "arc9_fx_rtblur"
    })
    panel:AddControl("checkbox", {
        label = "Keep HUD Hints",
        command = "arc9_hud_keephints"
    })
    panel:ControlHelp( "Never fade HUD hints." )
    panel:AddControl("checkbox", {
        label = "Enable TPIK",
        command = "arc9_tpik"
    })
    panel:ControlHelp( "Use high quality first person animations in third person, where available." )
    panel:AddControl("checkbox", {
        label = "Enable TPIK For Others",
        command = "arc9_tpik_others"
    })
    panel:ControlHelp( "Enable TPIK on other players." )
    panel:AddControl("checkbox", {
        label = "Viewmodel Bob Style",
        command = "arc9_vm_bobstyle"
    })
    panel:ControlHelp( "Toggle between old and new viewmodel bobbing." )
    panel:AddControl("checkbox", {
        label = "Toggle ADS",
        command = "arc9_toggleads"
    })
    panel:AddControl("checkbox", {
        label = "Automatic Reload",
        command = "arc9_autoreload"
    })
    panel:AddControl("checkbox", {
        label = "Other Player Flashlights",
        command = "arc9_allflash"
    })
    panel:ControlHelp( "Other players have proper, visible flashlights in third person. Extremely expensive." )

    -- Add a slider for FOV
    panel:AddControl("slider", {
        label = "Viewmodel FOV",
        command = "arc9_fov",
        min = -45,
        max = 45,
    })

    -- Add help text for imaginary bullets
    panel:ControlHelp( "Imaginary bullets appear to travel outside the skybox. There is no gameplay difference to disabling this option." )
    -- Add a toggle for imaginary bullets
    panel:AddControl("checkbox", {
        label = "Enable Imaginary Bullets",
        command = "arc9_bullet_imaginary"
    })
    panel:AddControl("checkbox", {
        label = "ADS Sensitivity Compensation",
        command = "arc9_compensate_sens"
    })
end

local function menu_arc9_settings(panel)
    local butt = vgui.Create( "DButton", panel )

    butt:SetText("Open settings panel!")
    butt:SetPos(20, 50)
    butt:SetSize(300, 50)
    function butt:DoClick()
        ARC9_OpenSettings()
    end
end

local function menu_client_customization(panel)
    panel:AddControl("checkbox", {
        label = "Customization Blur",
        command = "arc9_cust_blur"
    })
    panel:ControlHelp( "Blur the background of the customization screen.\nMay reduce performance." )
    panel:AddControl("checkbox", {
        label = "Customization Light",
        command = "arc9_cust_light"
    })
    panel:ControlHelp( "Add a light to the customization screen." )
    panel:AddControl("checkbox", {
        label = "Customization Hints",
        command = "arc9_cust_hints"
    })
    panel:ControlHelp( "Show hints in bottom of hud of actions you can do there   please write better string for this" )
    panel:AddControl("checkbox", {
        label = "Reset attachment selection on exit",
        command = "arc9_cust_exit_reset_sel"
    })
    panel:ControlHelp( "Reset last selected attachment and its folder on exit from customisation menu  (maybe write about it making you go back to slots selection?) please write better string for this" )
    panel:AddControl("checkbox", {
        label = "Disable Holiday Theming",
        command = "arc9_holiday_grinch"
    })
    panel:ControlHelp( "Disable all holiday and events related theming.\nYou're a mean one, Mr. Grinch." )
    panel:AddControl("slider", {
        label = "DEBUG: Holiday Month",
        command = "arc9_holiday_month",
        min = 0,
        max = 12,
    })
    panel:ControlHelp( "Fake month to debug and test as, set over 0!!" )
    panel:AddControl("slider", {
        label = "DEBUG: Holiday Day",
        command = "arc9_holiday_day",
        min = 0,
        max = 31,
    })
    panel:ControlHelp( "Fake day to debug and test as, set over 0!!" )
end


local function menu_client_crosshair(panel)
    panel:AddControl("label", {
        text = "Crosshairs are only enabled on certain weapons."
    })
    panel:AddControl("checkbox", {
        label = "Enable Crosshair",
        command = "arc9_cross_enable"
    })
    panel:AddControl("color", {
        label = "Crosshair Color",
        red = "arc9_cross_r",
        green = "arc9_cross_g",
        blue = "arc9_cross_b"
    })
end

local function menu_client_optics(panel)
    panel:AddControl("checkbox", {
        label = "Cheap Scopes",
        command = "arc9_cheapscopes"
    })
    panel:ControlHelp( "Cheap Scopes are practically as good as normal scopes, but substantially improve performance." )
    panel:AddControl("color", {
        label = "Reflex Sight Color",
        red = "arc9_reflex_r",
        green = "arc9_reflex_g",
        blue = "arc9_reflex_b"
    })
    panel:AddControl("color", {
        label = "Scope Color",
        red = "arc9_scope_r",
        green = "arc9_scope_g",
        blue = "arc9_scope_b"
    })
end

local function menu_server_ballistics(panel)
    panel:AddControl("checkbox", {
        label = "Physical Bullets",
        command = "arc9_bullet_physics"
    })
    panel:ControlHelp( "Most weapons are designed for this to be on. Some weapons force physical bullets on. Disabling this will improve server performance." )

    -- Add a slider to control bullet gravity
    panel:AddControl("slider", {
        label = "Gravity Multiplier",
        command = "arc9_bullet_gravity",
        min = 0,
        max = 100,
    })

    -- Add a slider for bullet drag
    panel:AddControl("slider", {
        label = "Drag Multiplier",
        command = "arc9_bullet_drag",
        min = 0,
        max = 100,
    })

    -- Add a toggle for ricochet
    panel:AddControl("checkbox", {
        label = "Enable Ricochet",
        command = "arc9_ricochet"
    })

    -- Add a slider for bullet lifetime
    panel:AddControl("slider", {
        label = "Bullet Lifetime",
        command = "arc9_bullet_lifetime",
        min = 1,
        max = 100,
    })
end

local function menu_client_controller(panel)
    panel:AddControl( "header", { description = "Replace key names with controller glyphs." } )
    panel:CheckBox("Engage Super Controller Mode", "arc9_controller")
    panel:ControlHelp( "Activate controller-focused features in ARC9.\n- Keys are replaced with their bindnames.\n- Jump and reload are used as Select and Deselect, respectively." )
    panel:CheckBox("Controller Rumble w/ SInput", "arc9_controller_rumble")
    panel:ControlHelp( "Use Fesiug's SInput to interact with ARC9.\nFound at github.com/Fesiug/gmod-sinput" )
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
        listview:AddLine( string.Trim(tex_inp:GetValue()), string.Trim(tex_out:GetValue()) )
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
                    local menu = DermaMenu()
                    menu:AddOption( "As input", function() self.InputPanel:SetValue( label ) end ):SetIcon( "icon16/page_copy.png" )
                    menu:AddOption( "As output", function() self.OutputPanel:SetValue( label ) end ):SetIcon( "icon16/page_paste.png" )
                    menu:Open()
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
        command = "arc9_penetration"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Deal Equal Damage",
        command = "arc9_npc_equality"
    })
    panel:AddControl("checkbox", {
        label = "Default Body Damage Cancel",
        command = "arc9_mod_bodydamagecancel"
    })
    panel:ControlHelp( "Disable body damage cancel only if you have another addon that will override the HL2 limb damage multipliers." )
    panel:AddControl("checkbox", {
        label = "Infinite Ammo",
        command = "arc9_infinite_ammo"
    })
    -- Add a slider for giving NPCs weapons.
    panel:AddControl("checkbox", {
        label = "Allow Giving NPCs Weapons With +USE.",
        command = "arc9_npc_give_weapons",
    })
end

local function menu_server_attachments(panel)
    panel:AddControl("checkbox", {
        label = "Free Attachments",
        command = "arc9_free_atts"
    })
    panel:ControlHelp( "Enable this to be able to use all attachments without spawning entities." )
    panel:AddControl("checkbox", {
        label = "Attachment Locking",
        command = "arc9_atts_lock"
    })
    panel:ControlHelp( "You only need one attachment to be able to use it on all guns." )
    panel:AddControl("checkbox", {
        label = "Lose Attachments On Death",
        command = "arc9_atts_loseondie"
    })
    panel:AddControl("checkbox", {
        label = "Generate Attachment Entities",
        command = "arc9_atts_generateentities"
    })
    panel:ControlHelp( "Disabling this can save a lot of time on startup." )
    panel:AddControl("checkbox", {
        label = "NPCs Get Random Attachments",
        command = "arc9_atts_npc"
    })
    --Removed Anarchy Mode from menu to prevent inexperienced users from activating it
    -- panel:AddControl("checkbox", {
    --     label = "Total Anarchy Mode",
    --     command = "arc9_atts_anarchy"
    -- })
    -- panel:ControlHelp( "For the love of God, don't enable this." )
end

c1 = {
    ["DamageMax"] = true,
    ["DamageMin"] = true,
    ["DamageRand"] = true,
    ["RangeMin"] = true,
    ["RangeMax"] = true,
    ["Distance"] = true,
    ["Num"] = true,
    ["Penetration"] = true,
    ["RicochetAngleMax"] = true,
    ["RicochetChance"] = true,
    ["ArmorPiercing"] = true,
    ["EntityMuzzleVelocity"] = true,
    ["PhysBulletMuzzleVelocity"] = true,
    ["PhysBulletDrag"] = true,
    ["PhysBulletGravity"] = true,
    ["ChamberSize"] = true,
    ["ClipSize"] = true,
    ["SupplyLimit"] = true,
    ["SecondarySupplyLimit"] = true,
    ["AmmoPerShot"] = true,
    ["ManualActionChamber"] = true,
    ["TriggerDelay"] = true,
    ["RPM"] = true,
    ["PushBackForce"] = true,
    ["PostBurstDelay"] = true,
    ["Recoil"] = true,
    ["RecoilPatternDrift"] = true,
    ["RecoilUp"] = true,
    ["RecoilSide"] = true,
    ["RecoilRandomUp"] = true,
    ["RecoilRandomSide"] = true,
    ["RecoilDissipationRate"] = true,
    ["RecoilResetTime"] = true,
    ["RecoilAutoControl"] = true,
    ["RecoilKick"] = true,
    ["Spread"] = true,
    ["PelletSpread"] = true,
    ["FreeAimRadius"] = true,
    ["Sway"] = true,
    ["AimDownSightsTime"] = true,
    ["SprintToFireTime"] = true,
    ["ReloadTime"] = true,
    ["DeployTime"] = true,
    ["CycleTime"] = true,
    ["FixTime"] = true,
    ["OverheatTime"] = true,
    ["Speed"] = true,
    ["BashDamage"] = true,
    ["BashRange"] = true,
    ["BashLungeRange"] = true,
    ["HeatPerShot"] = true,
    ["HeatCapacity"] = true,
    ["HeatDissipation"] = true,
    ["ShootVolume"] = true,
    ["AlwaysPhysBullet"] = true,
    ["NeverPhysBullet"] = true,
    ["InfiniteAmmo"] = true,
    ["BottomlessClip"] = true,
    ["ShotgunReload"] = true,
    ["HybridReload"] = true,
    ["ManualAction"] = true,
    ["CanFireUnderwater"] = true,
    ["AutoReload"] = true,
    ["AutoBurst"] = true,
    ["RunawayBurst"] = true,
    ["ShootWhileSprint"] = true,
    ["Bash"] = true,
    ["Overheat"] = true,
    ["Malfunction"] = true,
    ["MalfunctionMeanShotsToFail"] = true,
    ["MalfunctionWait"] = true,
    ["Bipod"] = true,
    ["NoFlash"] = true,
    ["BulletGuidance"] = true,
    ["BulletGuidanceAmount"] = true,
    ["ExplosionDamage"] = true,
    ["ExplosionRadius"] = true,
    ["CanLean"] = true,
    ["HoldBreathTime"] = true,
    ["RestoreBreathTime"] = true,
    ["SlamFire"] = true,
    ["TriggerDelay"] = true,
    ["TriggerDelayTime"] = true,
    ["TriggerDelayRepeat"] = true,
    ["HeadshotDamage"] = true,
    ["ChestDamage"] = true,
    ["StomachDamage"] = true,
    ["ArmDamage"] = true,
    ["LegDamage"] = true,
    ["VisualRecoil"] = true,
    ["VisualRecoilUp"] = true,
    ["VisualRecoilSide"] = true,
    ["VisualRecoilRoll"] = true,
    ["VisualRecoilPunch"] = true,
    ["BreathHoldTime"] = true,
}

c2 = {
    [""] = true,
    ["Mult"] = true,
    ["Add"] = true,
    ["Override"] = true,
}

c3 = {
    [""] = true,
    ["True"] = true,
    ["Silenced"] = true,
    ["UBGL"] = true,
    ["MidAir"] = true,
    ["Crouch"] = true,
    ["FirstShot"] = true,
    ["Empty"] = true,
    ["EvenShot"] = true,
    ["OddShot"] = true,
    ["EvenReload"] = true,
    ["OddReload"] = true,
    ["Sights"] = true,
    ["HipFire"] = true,
    ["Shooting"] = true,
    ["Recoil"] = true,
    ["Move"] = true,
}

local function menu_server_modifiers(panel)
    local listview = vgui.Create("DListView", panel)
    listview:SetSize( 99, 200 )
    panel:AddItem( listview )
    listview:SetMultiSelect( true )
    listview:AddColumn( "Stat" )
    listview:AddColumn( "Modifier" )

    local tex_inp = vgui.Create( "DTextEntry", panel )
    local tex_out = vgui.Create( "DTextEntry", panel )
    panel:AddItem( tex_inp )
    panel:AddItem( tex_out )
    tex_inp:SetPlaceholderText("Use the first list to select a stat to modify")
    tex_out:SetPlaceholderText("Enter a number value, 'true', or 'false'.")

    local com_1 = vgui.Create( "DComboBox", panel )
    local com_2 = vgui.Create( "DComboBox", panel )
    local com_3 = vgui.Create( "DComboBox", panel )
    panel:AddItem( com_1 )
    panel:ControlHelp( "Stat to change." )
    panel:AddItem( com_2 )
    panel:ControlHelp( "Modification type. Some stats don't have these." )
    panel:AddItem( com_3 )
    panel:ControlHelp( "Special condition, like if you're crouching." )

    for i, v in pairs(c1) do
        com_1:AddChoice( i )
    end
    for i, v in pairs(c2) do
        com_2:AddChoice( i )
    end
    for i, v in pairs(c3) do
        com_3:AddChoice( i )
    end

    com_1.OnSelect = function( self, index, value )
        tex_inp:SetValue( ( com_1:GetValue() or "" ) .. ( com_2:GetValue() or "" ) .. ( com_3:GetValue() or "" ) )
    end

    com_2.OnSelect = function( self, index, value )
        tex_inp:SetValue( ( com_1:GetValue() or "" ) .. ( com_2:GetValue() or "" ) .. ( com_3:GetValue() or "" ) )
    end

    com_3.OnSelect = function( self, index, value )
        tex_inp:SetValue( ( com_1:GetValue() or "" ) .. ( com_2:GetValue() or "" ) .. ( com_3:GetValue() or "" ) )
    end

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

    panel:ControlHelp( "Examples:" )
    panel:ControlHelp( " - \"Overheat\" \"true\" to disable overheating." )
    panel:ControlHelp( " - \"BottomlessClip\" \"true\" to enable Bottomless Clip." )
    panel:ControlHelp( " - \"RecoilMultCrouch\" \"0.1\" to reduce recoil to 10% when crouching." )
    panel:ControlHelp( " - \"RPMMultOddShot\" \"0.5\" to make every other shot 600RPM." )

    function but_add:DoClick()
        listview:AddLine( string.Trim(tex_inp:GetValue()), string.Trim(tex_out:GetValue()) )
    end

    function but_rem:DoClick()
        for i, v in pairs(listview:GetSelected()) do
            listview:RemoveLine( v:GetID() )
        end
    end

    function but_upd:DoClick()
        listview:Clear()

        local config = GetConVar("arc9_modifiers"):GetString()
        config = string.Split( config, "\\n" )
        for i, v in ipairs(config) do
            local swig = string.Split( v, "\\t" )
            if swig[1] == "" then continue end
            listview:AddLine( swig[1], swig[2] )
        end
    end
    but_upd:DoClick()

    function but_app:DoClick()
        local toapply = ""
        local order = 1
        for k, line in pairs( listview:GetLines() ) do
            if order != 1 then toapply = toapply .. "\\n" end
            toapply = toapply .. line:GetValue( 1 ) .. "\\t" .. line:GetValue( 2 )
            order = order + 1
        end
        RunConsoleCommand("arc9_modifiers", toapply)
        RunConsoleCommand("arc9_modifiers_invalidateall")
    end
end

concommand.Add( "arc9_modifiers_invalidateall", function( ply, cmd, args )
    if IsValid(ply) and ply:IsAdmin() then
        net.Start("ARC9_InvalidateAll") net.SendToServer()
    end
end )

local clientmenus_ti = {
    {
        text = "REAL SETTINGS here", func = menu_arc9_settings
    },
    -- {
    --     text = "Client", func = menu_client_ti
    -- },
    -- {
    --     text = "Client - Customization", func = menu_client_customization
    -- },
    {
        text = "Controller", func = menu_client_controller
    },
    -- {
    --     text = "Client - Crosshair", func = menu_client_crosshair
    -- },
    -- {
    --     text = "Client - Optics", func = menu_client_optics
    -- },
    -- {
    --     text = "Server", func = menu_server_ti
    -- },
    -- {
    --     text = "Server - Attachments", func = menu_server_attachments
    -- },
    -- {
    --     text = "Server - Ballistics", func = menu_server_ballistics
    -- },
    {
        text = "Modifiers", func = menu_server_modifiers
    },
}

hook.Add("PopulateToolMenu", "ARC9_MenuOptions", function()
    for smenu, data in pairs(clientmenus_ti) do
        spawnmenu.AddToolMenuOption("Options", "ARC9", "ARC9_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

end