--[[
    type,
        label - pure text
        bool
        button: 
            content - text in button
            func - function(self2) end
        slider:
            min
            max
            decimals
            convar2 - same as convar, but only for input, not follow always
            func - function(self2) end   after action
        color
        coloralpha - with transparency slider
        input - text input, NOT IMPLEMENTED
        combo - dropdown menu:
            content - {{"1table of thingies", "stibb"}, {"2there", "yolo"}, {"3for some reason you need put number at start so it will be properly sorted", "foog"}, {"4though it will be not drawn in ui", "booglybop"}}
    title,
    convar to follow, (without arc9_; color selectors will automatically use _r/_g/_b)
    description to show on right
]]--

ARC9.LanguagesTable = {}

local settingstable = {
    -- {
    --     TabName = "Tab name 1",
    --     { type = "label", text = "Header" },
    --     { type = "bool", text = "Booling", convar = "cust_blur", desc = "TEST DESCRIPTION" },
    --     { type = "slider", text = "Booling 2", min = -2, max = 2, desc = "f DESCRIPTION" },
    --     { type = "slider", text = "Slide me", min = -45, max = 45, convar = "fov", desc = "balls" },
    --     { type = "combo", text = "Yayay", convar = "arccw_attinv_loseondie", content = {"1table of thingies", "2there", "3ooo"}, desc = "hhhhhhhhhhhhhhhhh" },
    --     { type = "button", text = "Uhhh", content = "Boop", func = function(self2) print("wa") end, desc = "TEST DESCRIPTION" },
    --     { type = "color", text = "Coloringa", convar = "reflex", desc = "This color is very important. \n\nClient-only.\nConvar: arc9_sdfjidojgoidfjgoidfg_r/g/b/a" },
    --     -- { type = "coloralpha", text = "Color alpha", desc = "g" },
    --     -- { type = "input", text = "Color alpha", desc = "g" },
    -- },
    {
        TabName = "settings.tabname.performance",
        { type = "label", text = "settings.performance.important" },
        { type = "bool", text = "settings.cheapscopes.title", convar = "cheapscopes", desc = "settings.cheapscopes.desc"},
        { type = "bool", text = "settings.allflash.title", convar = "allflash", desc = "settings.allflash.desc"},
        { type = "bool", text = "settings.tpik.title", convar = "tpik", desc = "settings.tpik.desc"},
        { type = "bool", text = "settings.attachments.free_atts.title", convar = "free_atts", desc = "settings.attachments.free_atts.desc"},

        { type = "label", text = "settings.performance.blur.title" },
        { type = "bool", text = "settings.cust_blur.title", convar = "cust_blur", desc = "settings.cust_blur.desc"},
        { type = "bool", text = "settings.fx_reloadblur.title", convar = "fx_reloadblur", desc = "settings.fx_reloadblur.desc"},
        { type = "bool", text = "settings.fx_animblur.title", convar = "fx_animblur", desc = "settings.fx_animblur.desc"},
        { type = "bool", text = "settings.fx_rtblur.title", convar = "fx_rtblur", desc = "settings.fx_rtblur.desc"},
        { type = "bool", text = "settings.fx_adsblur.title", convar = "fx_adsblur", desc = "settings.fx_adsblur.desc"},

        { type = "label", text = "settings.performance.shelleject.title" },
        { type = "bool", text = "settings.eject_fx.title", convar = "eject_fx", desc = "settings.eject_fx.desc"},
        { type = "slider", text = "settings.eject_time.title", convar = "eject_time", min = -1, max = 60, decimals = 0, desc = "settings.eject_time.desc"},
    },
    {
        TabName = "settings.tabname.optics",
        -- { type = "label", text = "Performance" }, -- fine here but they are already in first tab
        { type = "bool", text = "Cheap Scopes", convar = "cheapscopes", desc = "settings.optics.cheapscopes.desc"},
        -- { type = "bool", text = "Blur in Scopes", convar = "fx_rtblur", desc = "Blurs the world while using a magnified scope."},
        -- { type = "bool", text = "Blur in Sights", convar = "fx_adsblur", desc = "Blurs the weapon while aiming down sights."},

        { type = "label", text = "settings.optics.control" },
        { type = "bool", text = "settings.optics.compensate_sens.title", convar = "compensate_sens", desc = "settings.optics.compensate_sens.desc" },
        { type = "bool", text = "settings.optics.toggleads.title", convar = "toggleads", desc = "settings.optics.toggleads.desc" },

        { type = "label", text = "settings.optics.color" },
        { type = "color", text = "settings.optics.reflex.title", convar = "reflex", desc = "settings.optics.reflex.desc" },
        { type = "color", text = "settings.optics.scope.title", convar = "scope", desc = "settings.optics.scope.desc" },
    },
    {
        TabName = "settings.tabname.crosshair",
        { type = "label", text = "settings.crosshair.crosshair" },
        { type = "bool", text = "settings.crosshair.cross_enable.title", convar = "cross_enable", desc = "settings.crosshair.cross_enable.desc" },
        { type = "coloralpha", text = "settings.crosshair.cross.title", convar = "cross", desc = "settings.crosshair.cross.desc"},
        { type = "slider", text = "settings.crosshair.cross_size_mult.title", min = 0.01, max = 10, decimals = 2, convar = "cross_size_mult", desc = "settings.crosshair.cross_size_mult.desc" },
        { type = "slider", text = "settings.crosshair.cross_size_dot.title", min = 0.01, max = 10, decimals = 2, convar = "cross_size_dot", desc = "settings.crosshair.cross_size_dot.desc" },
        { type = "slider", text = "settings.crosshair.cross_size_prong.title", min = 0.01, max = 10, decimals = 2, convar = "cross_size_prong", desc = "settings.crosshair.cross_size_prong.desc" },
        { type = "bool", text = "settings.crosshair.crosshair_static.title", convar = "crosshair_static", desc = "settings.crosshair.crosshair_static.desc" },
        { type = "bool", text = "settings.crosshair.crosshair_force.title", convar = "crosshair_force", desc = "settings.crosshair.crosshair_force.desc" },
    },
    {
        TabName = "settings.tabname.hud_cust",
        { type = "label", text = "settings.hud_cust.hud" },
        -- crazy hacks to make hud scale work "almost dynamicly"
        { type = "slider", text = "settings.hud_cust.hud_scale.title", min = 0.5, max = 1.5, decimals = 2, desc = "settings.hud_cust.hud_scale.desc", convar2 = "hud_scale", func = function(self2, self3, settingspanel) 
            if IsValid(LocalPlayer()) then -- uncust the gun
                local wep = LocalPlayer():GetActiveWeapon()
                if IsValid(wep) and wep.ARC9 then
                    if wep.CustomizeHUD then
                        wep:SetCustomize(false)
                        net.Start("ARC9_togglecustomize")
                        net.WriteBool(false)
                        net.SendToServer()
                    end
                end
            end
            RunConsoleCommand("arc9_hud_scale", self3:GetValue())

            settingspanel:Remove() -- rebuilding
            timer.Simple(0, function()
                ARC9.Regen() -- reload fonts with new scale
                ARC9_OpenSettings(4) -- open settings on current page (set number to tab number)
            end)
        end },
        -- { type = "input", text = "Font", convar = "font", desc = "Font replacement for ARC9. Set empty to use default font." },
        -- { type = "slider", min = -16, max = 16, decimals = 0, text = "Font Add Size", convar = "font_addsize", desc = "Increase text size.", func = function(self2, self3, settingspanel) 
        --     timer.Simple(0, function()
        --         ARC9.Regen() -- reload fonts with new scale
        --     end)
        -- end },
        { type = "color", text = "settings.hud_cust.hud_color.title", convar = "hud_color", desc = "settings.hud_cust.hud_color.desc"},
        -- { type = "input", text = "Language", convar = "language", desc = "Language pack to use for ARC9. Leave blank for game default." },
        -- { type = "combo", text = "settings.hud_cust.language_id.title", convar = "language", content = ARC9.LanguagesTable, desc = "settings.hud_cust.language_id.desc" },
        { type = "bool", text = "settings.hud_cust.cust_light.title", convar = "cust_light", desc = "settings.hud_cust.cust_light.desc"},
        { type = "slider", min = -20, max = 30, decimals = 1, text = "settings.hud_cust.cust_light_brightness.title", convar = "cust_light_brightness", desc = "settings.hud_cust.cust_light_brightness.desc" },

        { type = "label", text = "settings.hud_cust.customization" },
        -- { type = "bool", text = "Background Blur", convar = "cust_blur", desc = "Blurs customization background.\n\nRequires DX9."},
        { type = "bool", text = "settings.hud_cust.cust_hints.title", convar = "cust_hints", desc = "settings.hud_cust.cust_hints.desc"},
        { type = "bool", text = "settings.hud_cust.cust_roll_unlock.title", convar = "cust_roll_unlock", desc = "settings.hud_cust.cust_roll_unlock.desc"},
        { type = "bool", text = "settings.hud_cust.cust_exit_reset_sel.title", convar = "cust_exit_reset_sel", desc = "settings.hud_cust.cust_exit_reset_sel.desc"}
    },
    {
        TabName = "settings.tabname.hud_game",
        { type = "label", text = "settings.hud_game.lcd" },
        { type = "bool", text = "settings.hud_game.hud_arc9.title", convar = "hud_arc9", desc = "settings.hud_game.hud_arc9.desc" },
        { type = "bool", text = "settings.hud_game.hud_always.title", convar = "hud_always", desc = "settings.hud_game.hud_always.desc" },
        { type = "bool", text = "settings.hud_game.hud_compact.title", convar = "hud_compact", desc = "settings.hud_game.hud_compact.desc" },
        { type = "bool", text = "settings.hud_game.hud_keephints.title", convar = "hud_keephints", desc = "settings.hud_game.hud_keephints.desc" },

        { type = "label", text = "settings.hud_game.killfeed" },
        { type = "bool", text = "settings.hud_game.killfeed_enable.title", convar = "killfeed_enable", desc = "settings.hud_game.killfeed_enable.desc" },
        { type = "bool", text = "settings.hud_game.killfeed_dynamic.title", convar = "killfeed_dynamic", desc = "settings.hud_game.killfeed_dynamic.desc" },

        { type = "label", text = "settings.hud_game.breath" },
        { type = "bool", text = "settings.hud_game.breath_hud.title", convar = "breath_hud", desc = "settings.hud_game.breath_hud.desc" },
        { type = "bool", text = "settings.hud_game.breath_pp.title", convar = "breath_pp", desc = "settings.hud_game.breath_pp.desc" },
        { type = "bool", text = "settings.hud_game.breath_sfx.title", convar = "breath_sfx", desc = "settings.hud_game.breath_sfx.desc" },
    },
    {
        TabName = "settings.tabname.npc",
        { type = "label", text = "settings.npc.weapons" },
        { type = "bool", text = "settings.npc.npc_equality.title", convar = "npc_equality", desc = "settings.npc.npc_equality.desc" },
        { type = "bool", text = "settings.npc.npc_atts.title", convar = "npc_atts", desc = "settings.npc.npc_atts.desc" },
        { type = "bool", text = "settings.npc.npc_autoreplace.title", convar = "npc_autoreplace", desc = "settings.npc.npc_autoreplace.desc" },
        { type = "bool", text = "settings.npc.replace_spawned.title", convar = "replace_spawned", desc = "settings.npc.replace_spawned.desc" },
        { type = "bool", text = "settings.npc.npc_give_weapons.title", convar = "npc_give_weapons", desc = "settings.npc.npc_give_weapons.desc" },
    },
    {
        TabName = "settings.tabname.gameplay",
        { type = "label", text = "settings.gameplay.controls" },
        { type = "bool", text = "settings.gameplay.toggleads.title", convar = "toggleads", desc = "settings.gameplay.toggleads.desc" },
        { type = "bool", text = "settings.gameplay.autolean.title", convar = "autolean", desc = "settings.gameplay.autolean.desc" },
        { type = "bool", text = "settings.gameplay.autoreload.title", convar = "autoreload", desc = "settings.gameplay.autoreload.desc" },
        { type = "bool", text = "settings.gameplay.togglelean.title", convar = "togglelean", desc = "settings.gameplay.togglelean.desc" },
        { type = "bool", text = "settings.gameplay.togglepeek.title", convar = "togglepeek", desc = "settings.gameplay.togglepeek.desc" },

        { type = "label", text = "settings.gameplay.mechanics" },
        -- { type = "combo", text = "Lean style", convar = "vm_bobstyle", content = {"1Disabled", "2Only manual", "3Manual + auto", "4Auto only"}, desc = "Select style of leaning.\n\nWhether players can lean with +alt1 and +alt2 or with automatic near-wall lean.\n\nThis is a server variable." },
        { type = "bool", text = "settings.gameplay.infinite_ammo.title", convar = "infinite_ammo", desc = "settings.gameplay.infinite_ammo.desc" },
        { type = "bool", text = "settings.gameplay.realrecoil.title", convar = "realrecoil", desc = "settings.gameplay.realrecoil.desc" },
        { type = "bool", text = "settings.gameplay.lean.title", convar = "lean", desc = "settings.gameplay.lean.desc" },
        { type = "bool", text = "settings.gameplay.mod_sway.title", convar = "mod_sway", desc = "settings.gameplay.mod_sway.desc" },
        { type = "bool", text = "settings.gameplay.mod_freeaim.title", convar = "mod_freeaim", desc = "settings.gameplay.mod_freeaim.desc" },
        { type = "bool", text = "settings.gameplay.mod_bodydamagecancel.title", convar = "mod_bodydamagecancel", desc = "settings.gameplay.mod_bodydamagecancel.desc" },
        { type = "bool", text = "settings.gameplay.breath_slowmo.title", convar = "breath_slowmo", desc = "settings.gameplay.breath_slowmo.desc" },
        { type = "bool", text = "settings.gameplay.manualbolt.title", convar = "manualbolt", desc = "settings.gameplay.manualbolt.desc" },
        -- { type = "bool", text = "", convar = "nearwall", desc = "" },
        -- random jams
        -- overheating
    },
    {
        TabName = "settings.tabname.visuals",
        { type = "label", text = "settings.visuals.viewmodel" },
        { type = "combo", text = "settings.visuals.vm_bobstyle.title", convar = "vm_bobstyle", content = {
            {"1Darsu", "0"},
            {"2Fesiug", "1"},
            {"3Arctic", "2"},
            {"4Half-Life 2", "-1"},
        },
        desc = "settings.visuals.vm_bobstyle.desc" },
        -- { type = "slider", text = "Bob Style", convar = "vm_bobstyle", min = 0, max = 2, decimals = 0, desc = "Select different bobbing styles, to the flavor of different members of the ARC9 team.\n\n0: Darsu\n 1: Fesiug\n2: Arctic" },
        { type = "slider", text = "settings.visuals.fov.title", convar = "fov", min = -40, max = 40, decimals = 0, desc = "settings.visuals.fov.desc"},
        { type = "slider", min = -16, max = 16, decimals = 1, text = "settings.visuals.vm_addx.title", convar = "vm_addx", desc = "settings.visuals.vm_addx.desc" },
        { type = "slider", min = -16, max = 16, decimals = 1, text = "settings.visuals.vm_addy.title", convar = "vm_addy", desc = "settings.visuals.vm_addy.desc" },
        { type = "slider", min = -16, max = 16, decimals = 1, text = "settings.visuals.vm_addz.title", convar = "vm_addz", desc = "settings.visuals.vm_addz.desc" },

        { type = "label", text = "settings.visuals.tpik" },
        { type = "bool", text = "settings.visuals.tpik.title", convar = "tpik", desc = "settings.visuals.tpik.desc" },
        { type = "bool", text = "settings.visuals.tpik_others.title", convar = "tpik_others", desc = "settings.visuals.tpik_others.desc" },
        { type = "slider", text = "settings.visuals.tpik_framerate.title", convar = "tpik_framerate", min = 0, max = 200, decimals = 0, desc = "settings.visuals.tpik_framerate.desc" },
    },
    {
        TabName = "settings.tabname.bullets",
        { type = "label", text = "settings.bullets.bullets"},
        { type = "bool", text = "settings.bullets.bullet_physics.title", convar = "bullet_physics", desc = "settings.bullets.bullet_physics.desc" },
        { type = "slider", text = "settings.bullets.bullet_gravity.title", convar = "bullet_gravity", min = 0, max = 10, decimals = 1, desc = "settings.bullets.bullet_gravity.desc" },
        { type = "slider", text = "settings.bullets.bullet_drag.title", convar = "bullet_drag", min = 0, max = 10, decimals = 1, desc = "settings.bullets.bullet_drag.desc" },
        { type = "bool", text = "settings.bullets.ricochet.title", convar = "ricochet", desc = "settings.bullets.ricochet.desc" },
        { type = "bool", text = "settings.bullets.mod_penetration.title", convar = "mod_penetration", desc = "settings.bullets.mod_penetration.desc" },
        { type = "slider", text = "settings.bullets.bullet_lifetime.title", convar = "bullet_lifetime", min = 0, max = 120, decimals = 0, desc = "settings.bullets.bullet_lifetime.desc" },
        { type = "bool", text = "settings.bullets.bullet_imaginary.title", convar = "bullet_imaginary", desc = "settings.bullets.bullet_imaginary.desc" },
    },
    {
        TabName = "settings.tabname.attachments",
        { type = "label", text = "settings.attachments.customization"},
        { type = "bool", text = "settings.attachments.atts_nocustomize.title", convar = "atts_nocustomize", desc = "settings.attachments.atts_nocustomize.desc"},
        { type = "slider", text = "settings.attachments.atts_max.title", convar = "atts_max", min = 0, max = 250, decimals = 0, desc = "settings.attachments.atts_max.desc"},
        { type = "bool", text = "settings.attachments.autosave.title", convar = "autosave", desc = "settings.attachments.autosave.desc"},
        -- { type = "bool", text = "Total Anarchy", convar = "atts_anarchy", desc = "Allows any attachment to be attached to any slot.\nVERY laggy.\nWill not work properly with 99% of weapons and attachments.\nPlease don't turn this on.\n\nThis is a server variable."},
        { type = "label", text = "settings.attachments.inventory"},
        { type = "bool", text = "settings.attachments.free_atts.title", convar = "free_atts", desc = "settings.attachments.free_atts.desc"},
        { type = "bool", text = "settings.attachments.atts_lock.title", convar = "atts_lock", desc = "settings.attachments.atts_lock.desc"},
        { type = "bool", text = "settings.attachments.atts_loseondie.title", convar = "atts_loseondie", desc = "settings.attachments.atts_loseondie.desc"},
        { type = "bool", text = "settings.attachments.atts_generateentities.title", convar = "atts_generateentities", desc = "settings.attachments.atts_generateentities.desc"},
    },
    {
        TabName = "settings.tabname.modifiers",
        { type = "label", text = "settings.modifiers.quick.title", desc = "settings.modifiers.quick.desc"},
        -- { type = "slider", text = "Damage", convar = "wawa", min = 0, max = 10, decimals = 0, desc = "The     Damage\n\nThis is a server variable."},

        -- { type = "button", text = "Advanced modifiers", content = "Open panel", func = function(self2)
        --     -- RunConsoleCommand("arc9_reloadatts")
        --     print("lol")
        --     -- put here default derma panel with stuff from fesiug's spawmenu modifier panel
        -- end},    
    },
    {
        TabName = "settings.tabname.controller",
        { type = "label", text = "settings.controller.misc", desc = "settings.controller.misc.desc"},
        { type = "bool", text = "settings.controller.controller.title", convar = "controller", desc = "settings.controller.controller.desc"},
        { type = "bool", text = "settings.controller.controller_rumble.title", convar = "controller_rumble", desc = "settings.controller.controller_rumble.desc"},
        -- { type = "button", text = "settings.controller.controller_config.title", desc = "settings.controller.controller_config.desc", content = "settings.controller.controller_config.content", func = function(self2)
        --     -- RunConsoleCommand("arc9_reloadatts")
        --     print("lol")
        --     -- put here default derma panel with stuff from fesiug's spawmenu controller panel
        -- end},
    },
    {
        TabName = "settings.tabname.developer",
        { type = "label", text = "settings.developer.developer"},
        { type = "bool", text = "settings.developer.dev_always_ready.title", convar = "dev_always_ready", desc = "settings.developer.dev_always_ready.desc"},
        { type = "bool", text = "settings.developer.dev_benchgun.title", convar = "dev_benchgun", desc = "settings.developer.dev_benchgun.desc"},
        { type = "bool", text = "settings.developer.dev_show_shield.title", convar = "dev_show_shield", desc = "settings.developer.dev_show_shield.desc"},
        { type = "button", text = "settings.developer.reloadatts.title", content = "settings.developer.reload", func = function(self2)
            RunConsoleCommand("arc9_reloadatts")
        end},
        { type = "button", text = "settings.developer.reloadlangs.title", content = "settings.developer.reload", func = function(self2)
            RunConsoleCommand("arc9_reloadlangs")
        end},
        { type = "button", text = "settings.developer.dev_listanims.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_listanims")
        end},
        { type = "button", text = "settings.developer.dev_listbones.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_listbones")
        end},
        { type = "button", text = "settings.developer.dev_listbgs.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_listbgs")
        end},
        { type = "button", text = "settings.developer.dev_listatts.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_listatts")
        end},
        { type = "button", text = "settings.developer.dev_export.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_export")
        end},
        { type = "button", text = "settings.developer.dev_getjson.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_getjson")
        end},
    },
}

local ARC9ScreenScale = ARC9.ScreenScale
-- local mat_icon = Material("arc9/arc9_logo_ui.png", "mips smooth")

local function DrawSettings(bg, page)
    local cornercut = ARC9ScreenScale(3.5)
    
    local buttontalling = 0
    local activedesc = ""

    local sheet = vgui.Create("ARC9ColumnSheet", bg)
    sheet:Dock(FILL)
    sheet:DockMargin(0, 0, ARC9ScreenScale(77), ARC9ScreenScale(1.7))
    sheet.Navigation:DockMargin(-120, 0, 0, ARC9ScreenScale(5)) -- idk why -120
    sheet.Navigation:SetWidth(ARC9ScreenScale(77))

    for k, v in pairs(settingstable) do
        local newpanel = vgui.Create("DPanel", sheet)
        newpanel:Dock(FILL)
        newpanel.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ARC9.GetHUDColor("bg")) end 
        local newpanelscroll = vgui.Create("ARC9ScrollPanel", newpanel)
        newpanelscroll:Dock(FILL)
        newpanelscroll:DockMargin(ARC9ScreenScale(4), ARC9ScreenScale(4), ARC9ScreenScale(4), 0)

        local tabname = v.tabname

        for k2, v2 in ipairs(v) do
            local elpanel = vgui.Create("DPanel", newpanelscroll)
            
            elpanel:SetTall(ARC9ScreenScale(v2.type == "label" and 14 or 21))
            elpanel:DockMargin(0, (k2 != 1 and v2.type == "label") and ARC9ScreenScale(4) or 0, 0, 0)
            elpanel:Dock(TOP)

            elpanel.Paint = function(self2, w, h)
                if v2.type == "label" then
                    surface.SetDrawColor(0, 0, 0, 75)
                    surface.DrawRect(0, 0, w, h)
                end
                -- desc!!!!!!!!

                if self2:IsHovered() then
                    if activedesc != (ARC9:GetPhrase(v2.desc) or v2.desc or "") then
                        activedesc = (ARC9:GetPhrase(v2.desc) or v2.desc or "")
                        if bg.desc then bg.desc:Remove() end

                        local desc = vgui.Create("ARC9ScrollPanel", bg)
                        desc:SetPos(bg:GetWide() - ARC9ScreenScale(74.5), ARC9ScreenScale(35))
                        desc:SetSize(ARC9ScreenScale(70), bg:GetTall() - ARC9ScreenScale(40))
                        desc.Paint = function(self2, w, h)
                            -- surface.SetDrawColor(144, 0, 0, 100)
                            -- surface.DrawRect(0, 0, w, h)
                        end
                        bg.desc = desc

                        local descmultiline = ARC9MultiLineText(activedesc, desc:GetWide() - ARC9ScreenScale(1), "ARC9_8")
                        for i, text in ipairs(descmultiline) do
                            local desc_line = vgui.Create("DPanel", desc)
                            desc_line:SetSize(desc:GetWide(), ARC9ScreenScale(8))
                            desc_line:Dock(TOP)
                            desc_line.Paint = function(self2, w, h)
                                surface.SetFont("ARC9_8")
                                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                                surface.SetTextPos(ARC9ScreenScale(2), 0)
                                surface.DrawText(text)
                            end
                        end
                    end
                end

                local txt = ARC9:GetPhrase(v2.text) or ARC9:GetPhrase("settings" .. "." .. (v2.convar or "") .. ".title") or v2.text or ""

                surface.SetFont("ARC9_12_Slim")
                local tw, th = surface.GetTextSize(txt)
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(4), h/2 - th/2)
                surface.DrawText(txt)
            end

            local elpw, elph = ARC9ScreenScale(168), ARC9ScreenScale(21)

            if v2.type == "label" then
                -- woopsie
            elseif v2.type == "bool" then
                local newel = vgui.Create("ARC9Checkbox", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(4+13), ARC9ScreenScale(4))
                if v2.convar then newel:SetConVar("arc9_" .. v2.convar) end
            elseif v2.type == "slider" then
                local newel = vgui.Create("ARC9NumSlider", elpanel)
                newel:SetPos(0, ARC9ScreenScale(6))
                newel:SetSize(elpw, 30)
                newel:SetDecimals(v2.decimals or 0)
                newel:SetMin(v2.min or 0)
                newel:SetMax(v2.max or 255)
                if v2.convar then newel:SetConVar("arc9_" .. v2.convar) end
                if v2.convar2 then newel:SetValue(GetConVar("arc9_" .. v2.convar2):GetFloat()) end

                local oldmousereleased = newel.Slider.OnMouseReleased
                newel.Slider.OnMouseReleased = function(self2, kc)
                    oldmousereleased(self2, kc)
                    if v2.func then v2.func(self2, newel, bg) end
                end
            elseif v2.type == "color" then
                local newel = vgui.Create("ARC9ColorButton", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                newel:CustomSetConvar(cvar)

                if GetConVar(cvar .. "_r") then 
                    newel.rgbcolor = Color(GetConVar(cvar .. "_r"):GetInt() or 255, GetConVar(cvar .. "_g"):GetInt() or 0, GetConVar(cvar .. "_b"):GetInt() or 0) 
                else 
                    newel.rgbcolor = Color(255, 0, 0)
                    print("you are dumb, missing color convar")
                end

            elseif v2.type == "coloralpha" then
                local newel = vgui.Create("ARC9ColorButton", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel:EnableAlpha()

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                newel:CustomSetConvar(cvar)

                if GetConVar(cvar .. "_a") then 
                    newel.rgbcolor = Color(GetConVar(cvar .. "_r"):GetInt() or 255, GetConVar(cvar .. "_g"):GetInt() or 0, GetConVar(cvar .. "_b"):GetInt() or 0, GetConVar(cvar .. "_a"):GetInt() or 255) 
                else
                    newel.rgbcolor = Color(255, 0, 0)
                    print("you are dumb, missing color convar (or its _alpha)")
                end

            elseif v2.type == "input" then
                local newel = vgui.Create("DTextEntry", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel:SetText(v2.text)
            elseif v2.type == "combo" then
                local newel = vgui.Create("ARC9ComboBox", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel:CustomSetConvar("arc9_" .. v2.convar)

                local cvdata = GetConVar("arc9_" .. v2.convar):GetString()

                for _, choice in pairs(v2.content) do
                    if tostring(choice[2]) == cvdata then
                        newel:AddChoice(choice[1], choice[2], true)
                    else
                        newel:AddChoice(choice[1], choice[2])
                    end
                end
            elseif v2.type == "button" then
                local newel = vgui.Create("ARC9Button", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel.text = ARC9:GetPhrase(v2.content)

                local oldmousepressed = newel.OnMousePressed
                newel.OnMousePressed = function(self2, kc)
                    oldmousepressed(self2, kc)
                    if kc == MOUSE_LEFT and v2.func then v2.func(self2) end
                end
            end
        end

        local thatsheet = sheet:AddSheet(v.TabName, newpanel)
        thatsheet.PageID = k

        thatsheet.Button:DockMargin(0, 0, ARC9ScreenScale(1.5), ARC9ScreenScale(1.7))
        thatsheet.Button:SetTall(ARC9ScreenScale(19))
        thatsheet.Button:SetText("")

        thatsheet.Button.Paint = function(self2, w, h)
            local mainbuttoncolor = ARC9.GetHUDColor("bg")
            local barbuttoncolor = ARC9.GetHUDColor("bg")
            local buttontextcolor = ARC9.GetHUDColor("fg")

            if sheet:GetActiveButton() == self2 then
                mainbuttoncolor = ARC9.GetHUDColor("hi")
                barbuttoncolor = ARC9.GetHUDColor("hi")
                buttontextcolor = ARC9.GetHUDColor("shadow")
            end

            if self2:IsHovered() then
                barbuttoncolor = ARC9.GetHUDColor("hi")
            end

            surface.SetDrawColor(barbuttoncolor)        
            surface.DrawRect(0, 0, ARC9ScreenScale(1.7), h)
            surface.SetDrawColor(mainbuttoncolor)        
            surface.DrawRect(ARC9ScreenScale(3.4), 0, w-ARC9ScreenScale(3.4), h)         
            
            surface.SetFont("ARC9_12")
            local tw = surface.GetTextSize(ARC9:GetPhrase(v.TabName))

            surface.SetTextColor(buttontextcolor)
            surface.SetTextPos((w - tw) / 2 + ARC9ScreenScale(1.7), ARC9ScreenScale(3))
            surface.DrawText(ARC9:GetPhrase(v.TabName))
        end
        buttontalling = buttontalling + ARC9ScreenScale(19+1.7)
    end





    bg.Paint = function(self2, w, h)
        draw.NoTexture()
        
        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        local talll = sheet.Navigation:GetTall() + ARC9ScreenScale(6.7)
        surface.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = 0, y = h-math.max(ARC9ScreenScale(5), talll-buttontalling)}, {x = ARC9ScreenScale(75.4), y = h-math.max(ARC9ScreenScale(5), talll-buttontalling)}, {x = ARC9ScreenScale(75.4), y = h}}) -- left bottom panel
        surface.DrawPoly({{x = w-ARC9ScreenScale(75.4), y = h}, {x = w-ARC9ScreenScale(75.4), y = ARC9ScreenScale(25.7)}, {x = w, y = ARC9ScreenScale(25.7)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}}) -- right panel
        surface.DrawPoly({{x = 0, y = ARC9ScreenScale(24)},{x = 0, y = cornercut},{x = cornercut, y = 0}, {x = w-cornercut, y = 0}, {x = w, y = cornercut}, {x = w, y = ARC9ScreenScale(24)}}) -- top panel

        surface.SetDrawColor(ARC9.GetHUDColor("hi"))
        surface.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = cornercut, y = h-cornercut*.5}})
        surface.DrawPoly({{x = w, y = h-cornercut}, {x = w-cornercut, y = h}, {x = w-cornercut, y = h-cornercut*.5}})
        surface.DrawPoly({{x = cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h}, {x = cornercut, y = h}, })
        
        
        -- surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        -- surface.SetMaterial(mat_icon)
        -- surface.DrawTexturedRect(ARC9ScreenScale(4), ARC9ScreenScale(2), ARC9ScreenScale(20), ARC9ScreenScale(20))

        ARC9.DrawColoredARC9Logo(ARC9ScreenScale(4), ARC9ScreenScale(2), ARC9ScreenScale(20), ARC9.GetHUDColor("hi"))

        surface.SetFont("ARC9_8_Slim")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(w-ARC9ScreenScale(73), ARC9ScreenScale(26))
        surface.DrawText(activedesc != "" and ARC9:GetPhrase("settings.desc") or "") -- no title if no desc

        surface.SetFont("ARC9_16")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(ARC9ScreenScale(30), ARC9ScreenScale(4))
        surface.DrawText(ARC9:GetPhrase("settings.title"))
    end

    if page then 
        for k, v in pairs(sheet.Items) do
            if v.PageID == page then
                v.Button:DoClick()
            end
        end
    end
end

local hoversound = "arc9/newui/uimouse_hover.ogg"
local clicksound = "arc9/newui/uimouse_click_return.ogg"


function ARC9_OpenSettings(page)
    local bg = vgui.Create("DFrame")
    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg:SetTitle("")
    bg:SetDraggable(false)
    bg:ShowCloseButton(false)        -- set to false when done please!!
    bg:SetAlpha(0)
    bg:AlphaTo(255, 0.2, 0, nil)
    bg:SetBackgroundBlur(true)
    -- bg:MakePopup()

    -- bg.Init = function(self2) self2.startTime = SysTime() end
    bg.Paint = function(self2, w, h)
        surface.SetDrawColor(20, 20, 20, 224)
        surface.DrawRect(0, 0, w, h)
        -- Derma_DrawBackgroundBlur(self2, self2.startTime) -- idk but cool
    end

    local panel = vgui.Create("DFrame", bg)
    panel:SetSize(ARC9ScreenScale(330), ARC9ScreenScale(242))
    panel:MakePopup()
    panel:SetAlpha(0)
    panel:AlphaTo(255, 0.2, 0, nil)
    panel:Center()
    panel:SetTitle("")
    panel:DockPadding(0, ARC9ScreenScale(25.7), 0, 0)
    panel:ShowCloseButton(false)
    DrawSettings(panel, page)

    panel.OnRemove = function() bg:Remove() end


    local discord = vgui.Create("ARC9TopButton", panel)
    discord:SetPos(panel:GetWide() - ARC9ScreenScale(21*3 + 12), ARC9ScreenScale(2))
    discord:SetIcon(Material("arc9/ui/discord.png", "mips smooth"))
    discord.DoClick = function(self2)
        surface.PlaySound(clicksound)
        gui.OpenURL("https:--discord.gg/wkafWps44a")
    end    

    local steam = vgui.Create("ARC9TopButton", panel)
    steam:SetPos(panel:GetWide() - ARC9ScreenScale(21*2 + 7), ARC9ScreenScale(2))
    steam:SetIcon(Material("arc9/ui/steam.png", "mips smooth"))
    steam.DoClick = function(self2)
        surface.PlaySound(clicksound)
        gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2910505837") -- dont forget to change to arc9 page when it release
    end

    local close = vgui.Create("ARC9TopButton", panel)
    close:SetPos(panel:GetWide() - ARC9ScreenScale(21+2), ARC9ScreenScale(2))
    close:SetIcon(Material("arc9/ui/close.png", "mips smooth"))
    close.DoClick = function(self2)
        surface.PlaySound(clicksound)
        panel:AlphaTo(0, 0.1, 0, nil)
        bg:AlphaTo(0, 0.1, 0, function()
            bg:Remove()
            panel:Remove()
        end)
    end    
    
    bg.OnMousePressed = function(self2, keycode)
        close.DoClick()
    end

    -- timer.Simple(33, function()
    --     bg:Remove()
    --     panel:Remove()
    -- end)
end