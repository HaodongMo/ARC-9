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
        name = "atts_free",
        default = "0",
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
        name = "mod_penetration",
        default = "1",
        replicated = true
    },
    {
        name = "mod_freeaim",
        default = "1",
        replicated = true
    },
    {
        name = "mod_sway",
        default = "1",
        replicated = true
    },
    {
        name = "dev_benchgun",
        default = "0",
    },
    {
        name = "dev_benchgun_custom",
        default = "",
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
        name = "hud_always",
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
        CreateClientConVar(convar_name, var.default, true, var.userinfo)
    else
        local flags = FCVAR_ARCHIVE
        if var.replicated then
            flags = flags + FCVAR_REPLICATED
        end
        if var.userinfo then
            flags = flags + FCVAR_USERINFO
        end
        CreateConVar(convar_name, var.default, flags, var.helptext, var.min, var.max)
    end
end

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
        label = "Draw HUD",
        command = "arc9_hud_arc9"
    })
    panel:AddControl("checkbox", {
        label = "Draw HUD Everywhere",
        command = "arc9_hud_always"
    })
    panel:AddControl("checkbox", {
        label = "Keep HUD Hints",
        command = "arc9_hud_keephints"
    })
    panel:AddControl("checkbox", {
        label = "Viewmodel Bob Style",
        command = "arc9_vm_bobstyle"
    })
    panel:AddControl("checkbox", {
        label = "Toggle ADS",
        command = "arc9_toggleads"
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
    panel:AddControl( "header", { description = "Replace key names with controller glyphs." } )
    panel:CheckBox("Engage Super Controller Mode", "arc9_controller")
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
    panel:AddControl("label", {
        text = "Disable body damage cancel only if you have another addon that will override the HL2 limb damage multipliers."
    })
    panel:AddControl("checkbox", {
        label = "Default Body Damage Cancel",
        command = "arc9_mod_bodydamagecancel"
    })
    panel:AddControl("checkbox", {
        label = "Infinite Ammo",
        command = "arc9_infinite_ammo"
    })
end

local function menu_server_attachments(panel)
    panel:AddControl("checkbox", {
        label = "Free Attachments",
        command = "arc9_atts_free"
    })
    panel:AddControl("checkbox", {
        label = "Attachment Locking",
        command = "arc9_atts_lock"
    })
    panel:AddControl("checkbox", {
        label = "Lose Attachments On Death",
        command = "arc9_atts_loseondie"
    })
    panel:AddControl("checkbox", {
        label = "Generate Attachment Entities",
        command = "arc9_atts_generateentities"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Get Random Attachments",
        command = "arc9_atts_npc"
    })
end

c1 = {
    ["DamageMax"] = true,
    ["DamageMin"] = true,
    ["DamageRand"] = true,
    ["RangeMin"] = true,
    ["RangeMax"] = true,
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
    ["MalfunctionMeanShotsToFail"] = true,
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
    ["RunAwayBurst"] = true,
    ["ShootWhileSprint"] = true,
    ["Bash"] = true,
    ["Overheat"] = true,
    ["Malfunction"] = true,
    ["Bipod"] = true,
    ["NoFlash"] = true,
    ["BulletGuidance"] = true,
    ["BulletGuidanceAmount"] = true,
    ["ExplosionDamage"] = true,
    ["ExplosionRadius"] = true,

    ["CanBlindFire"] = true,
    ["BlindFireLeft"] = true,
    ["BlindFireRight"] = true,
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
    ["BlindFire"] = true,
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
    tex_inp:SetPlaceholderText("Stat to edit, along with type and conditions")
    tex_out:SetPlaceholderText("Additive, multiplicative, or overidiative.")

    local com_1 = vgui.Create( "DComboBox", panel )
    local com_2 = vgui.Create( "DComboBox", panel )
    local com_3 = vgui.Create( "DComboBox", panel )
    panel:AddItem( com_1 )
    panel:ControlHelp( "Stat to edit." )
    panel:AddItem( com_2 )
    panel:ControlHelp( "Type. Some don't have these, like 'Overheat'." )
    panel:AddItem( com_3 )
    panel:ControlHelp( "Special conditions." )

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