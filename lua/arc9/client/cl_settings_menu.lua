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

ARC9.LanguagesTable = {
{"0GMod Language", ""},
{"1English", "en"},
{"2Deutsch", "de"},
{"2Español", "es-es"},
{"2Русский", "ru"},
{"2Svenska", "sv-se"},
{"2中國人", "zh-cn"},

{"9UwU :3", "uwu"},
}

ARC9.BadPerfromanceSettings = function() return BRANCH != "x86-64" end
ARC9.BadPerfromanceSettingsAlt = function() return BRANCH != "x86-64" or GetConVar("mat_queue_mode"):GetInt() == 0 or GetConVar("cl_threaded_bone_setup"):GetInt() < 1 end

ARC9.SettingsTable = {
    -- {
    --     TabName = "Tab name 1",
    --     { type = "label", text = "Header" },
    --     { type = "bool", text = "Booling", convar = "cust_blur", desc = "TEST DESCRIPTION" },
    --     { type = "slider", text = "Booling 2", min = -2, max = 2, desc = "f DESCRIPTION", parentconvar = "cust_blur" }, -- show that slider only if cust_blur is enabled
    --     { type = "slider", text = "Slide me", min = -45, max = 45, convar = "fov", desc = "balls" },
    --     { type = "combo", text = "Yayay", convar = "arccw_attinv_loseondie", content = {"1table of thingies", "2there", "3ooo"}, desc = "hhhhhhhhhhhhhhhhh" },
    --     { type = "button", text = "Uhhh", content = "Boop", func = function(self2) print("wa") end, desc = "TEST DESCRIPTION" },
    --     { type = "color", text = "Coloringa", convar = "reflex", desc = "This color is very important. \n\nClient-only.\nConvar: arc9_sdfjidojgoidfjgoidfg_r/g/b/a" },
    --     -- { type = "coloralpha", text = "Color alpha", desc = "g" },
    --     -- { type = "input", text = "Color alpha", desc = "g" },
    -- },
    {
        TabName = "settings.tabname.general",

        { type = "label", text = "settings.general.client" },
        { type = "bool", text = "settings.hud_game.hud_arc9.title", convar = "hud_arc9", desc = "settings.hud_game.hud_arc9.desc" },
        { type = "bool", text = "settings.crosshair.cross_enable.title", convar = "cross_enable", desc = "settings.crosshair.cross_enable.desc", parentconvar = "hud_arc9" },
        { type = "bool", text = "settings.tpik.title", convar = "tpik", desc = "settings.tpik.desc"},
        -- { type = "combo", text = "settings.truenames.title", convar = "truenames", content = {
        --     {"1Use Default", "2"},
        --     {"2Disabled", "0"},
        --     {"3Enabled", "1"},
        -- }, desc = "settings.truenames.desc"},
        -- { type = "bool", text = "settings.aimassist.enable.title", convar = "aimassist_cl", desc = "settings.aimassist.enable_client.desc"},
		{ type = "combo", text = "settings.language_id.title", convar = "language", desc = "settings.language_id.desc", content = ARC9.LanguagesTable, func = function(self2)
            RunConsoleCommand("arc9_reloadlangs")
        end},
        { type = "button", text = "settings.resetsettings.cl.title", content = "settings.reset", func = function(self2)
            RunConsoleCommand("arc9_settings_reset_client")
        end},

        { sv = true, type = "label", text = "settings.general.server" },
        { type = "bool", text = "settings.hud_game.hud_force_disable.title", convar = "hud_force_disable", desc = "settings.hud_game.hud_force_disable.desc" },

        { sv = true, type = "bool", text = "settings.attachments.free_atts.title", convar = "free_atts", desc = "settings.attachments.free_atts.desc"},
        { sv = true, type = "bool", text = "settings.gameplay.infinite_ammo.title", convar = "infinite_ammo", desc = "settings.gameplay.infinite_ammo.desc" },
        { sv = true, type = "slider", text = "settings.gameplay.mult_defaultammo.title", convar = "mult_defaultammo", min = 0, max = 16, decimals = 0, desc = "settings.gameplay.mult_defaultammo.desc" },
        { sv = true, type = "bool", text = "settings.truenames.title", convar = "truenames_default", desc = "settings.truenames.desc" },
        -- { sv = true, type = "combo", text = "settings.truenames_default.title", convar = "truenames_default", content = {
        --     {"1Disabled", "0"},
        --     {"2Enabled", "1"},
        -- }, desc = "settings.truenames_default.desc"},
        -- { sv = true, type = "bool", text = "settings.truenames_enforced.title", convar = "truenames_enforced", desc = "settings.truenames_enforced.desc"},
        { type = "bool", text = "settings.aimassist.enable.title", convar = "aimassist", desc = "settings.aimassist.enable_general.desc"},
        { sv = true, type = "button", text = "settings.resetsettings.sv.title", content = "settings.reset", func = function(self2)
            RunConsoleCommand("arc9_settings_reset_server")
        end},

    },
    {
        TabName = "settings.tabname.performance",
        Warning = ARC9.BadPerfromanceSettingsAlt,
        { type = "label", text = "badconf.warning", desc = "badconf.warning.desc", important = true, showfunc = ARC9.BadPerfromanceSettingsAlt },
        { type = "label", text = "badconf.x64.title", desc = "badconf.x64.desc", showfunc = function() return BRANCH != "x86-64" end },
        { type = "label", text = "badconf.multicore.title", desc = "badconf.multicore.desc", showfunc = function() return GetConVar("mat_queue_mode"):GetInt() == 0 or GetConVar("cl_threaded_bone_setup"):GetInt() < 1 end },
        { type = "label", text = "", showfunc = ARC9.BadPerfromanceSettingsAlt },
        { type = "label", text = "", showfunc = ARC9.BadPerfromanceSettingsAlt },

        { type = "label", text = "settings.performance.important" },
        { type = "bool", text = "settings.cheapscopes.title", convar = "cheapscopes", desc = "settings.cheapscopes.desc"},
        { type = "bool", text = "settings.tpik.title", convar = "tpik", desc = "settings.tpik.desc"},
        { type = "bool", text = "settings.allflash.title", convar = "allflash", desc = "settings.allflash.desc"},
        { type = "bool", text = "settings.fx_rtvm.title", convar = "fx_rtvm", desc = "settings.fx_rtvm.desc"},


        { type = "label", text = "settings.performance.blur.title" },
        { type = "bool", text = "settings.cust_blur.title", convar = "cust_blur", desc = "settings.cust_blur.desc"},
        { type = "bool", text = "settings.fx_reloadblur.title", convar = "fx_reloadblur", desc = "settings.fx_reloadblur.desc"},
        { type = "bool", text = "settings.fx_animblur.title", convar = "fx_animblur", desc = "settings.fx_animblur.desc"},
        { type = "bool", text = "settings.fx_rtblur.title", convar = "fx_rtblur", desc = "settings.fx_rtblur.desc"},
        { type = "bool", text = "settings.fx_adsblur.title", convar = "fx_adsblur", desc = "settings.fx_adsblur.desc"},

        { type = "label", text = "settings.performance.shelleject.title" },
        { type = "bool", text = "settings.eject_fx.title", convar = "eject_fx", desc = "settings.eject_fx.desc"},
        { type = "slider", text = "settings.eject_time.title", convar = "eject_time", min = -1, max = 60, decimals = 0, desc = "settings.eject_time.desc"},

        { type = "label", text = "settings.performance.fx.title" },
        { type = "bool", text = "settings.muzzle_light.title", convar = "muzzle_light", desc = "settings.muzzle_light.desc"},
        { type = "bool", text = "settings.muzzle_others.title", convar = "muzzle_others", desc = "settings.muzzle_others.desc"},
    },
    {
        TabName = "settings.tabname.optics",
        -- { type = "bool", text = "settings.cheapscopes.title", convar = "cheapscopes", desc = "settings.cheapscopes.desc"},

        { type = "label", text = "settings.optics.control" },
        { type = "slider", text = "settings.optics.sensmult.title", min = 0.1, max = 1, decimals = 1, convar = "mult_sens", desc = "settings.optics.sensmult.desc" },
        { type = "bool", text = "settings.optics.compensate_sens.title", convar = "compensate_sens", desc = "settings.optics.compensate_sens.desc" },
        { type = "bool", text = "settings.optics.toggleads.title", convar = "toggleads", desc = "settings.optics.toggleads.desc" },
        { type = "bool", text = "settings.optics.dtap_sights.title", convar = "dtap_sights", desc = "settings.optics.dtap_sights.desc" },

        { type = "label", text = "settings.optics.color" },
        { type = "color", text = "settings.optics.reflex.title", convar = "reflex", desc = "settings.optics.reflex.desc" },
        { type = "color", text = "settings.optics.scope.title", convar = "scope", desc = "settings.optics.scope.desc" },

        { type = "label", text = "settings.tabname.performance" },
        { type = "bool", text = "settings.cheapscopes.title", convar = "cheapscopes", desc = "settings.cheapscopes.desc"},
        { type = "bool", text = "settings.fx_rtvm.title", convar = "fx_rtvm", desc = "settings.fx_rtvm.desc"},
        { type = "bool", text = "settings.fx_rtblur.title2", convar = "fx_rtblur", desc = "settings.fx_rtblur.desc"},
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
        { type = "bool", text = "settings.crosshair.crosshair_target.title", convar = "crosshair_target", desc = "settings.crosshair.crosshair_target.desc" },
        { type = "bool", text = "settings.crosshair.crosshair_peeking.title", convar = "crosshair_peek", desc = "settings.crosshair.crosshair_peeking.desc" },
        { type = "combo", text = "settings.crosshair.crosshair_sgstyle.title", convar = "cross_sgstyle", desc = "settings.crosshair.crosshair_sgstyle.desc", content = {
            {"1" .. ARC9:GetPhrase("settings.crosshair.crosshair_sgstyle_fullcircle"), "1"},
            {"2" .. ARC9:GetPhrase("settings.crosshair.crosshair_sgstyle_four"), "2"},
            {"3" .. ARC9:GetPhrase("settings.crosshair.crosshair_sgstyle_two"), "3"},
            {"4" .. ARC9:GetPhrase("settings.crosshair.crosshair_sgstyle_dots"), "4"},
            {"5" .. ARC9:GetPhrase("settings.crosshair.crosshair_sgstyle_dots_accurate"), "5"}, 
			},
        },
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
                ARC9_OpenSettings()
            end)
        end },
        -- { type = "input", text = "Font", convar = "font", desc = "Font replacement for ARC9. Set empty to use default font." },
        -- { type = "slider", min = -16, max = 16, decimals = 0, text = "Font Add Size", convar = "font_addsize", desc = "Increase text size.", func = function(self2, self3, settingspanel)
        --     timer.Simple(0, function()
        --         ARC9.Regen() -- reload fonts with new scale
        --     end)
        -- end },

        { type = "slider", min = 0, max = 1000, decimals = 0, text = "settings.hud_cust.hud_deadzonex.title", convar = "hud_deadzonex", desc = "settings.hud_cust.hud_deadzonex.desc" },

        { type = "color", text = "settings.hud_cust.hud_color.title", convar = "hud_color", desc = "settings.hud_cust.hud_color.desc"},
        { type = "bool", text = "settings.hud_cust.hud_darkmode.title", convar = "hud_darkmode", desc = "settings.hud_cust.hud_darkmode.desc"},
        { type = "bool", text = "settings.hud_cust.hud_holiday.title", convar = "hud_holiday", desc = "settings.hud_cust.hud_holiday.desc"},
        -- { type = "input", text = "Language", convar = "language", desc = "Language pack to use for ARC9. Leave blank for game default." },
        { type = "bool", text = "settings.hud_cust.cust_light.title", convar = "cust_light", desc = "settings.hud_cust.cust_light.desc"},
        { type = "slider", min = -20, max = 30, decimals = 1, text = "settings.hud_cust.cust_light_brightness.title", convar = "cust_light_brightness", desc = "settings.hud_cust.cust_light_brightness.desc" },

        { type = "label", text = "settings.hud_cust.customization" },
        -- { type = "bool", text = "Background Blur", convar = "cust_blur", desc = "Blurs customization background.\n\nRequires DX9."},
        { type = "bool", text = "settings.hud_cust.cust_hints.title", convar = "cust_hints", desc = "settings.hud_cust.cust_hints.desc"},
        { type = "bool", text = "settings.hud_cust.cust_tips.title", convar = "cust_tips", desc = "settings.hud_cust.cust_tips.desc"},
        -- { type = "bool", text = "settings.hud_cust.cust_roll_unlock.title", convar = "cust_roll_unlock", desc = "settings.hud_cust.cust_roll_unlock.desc"},
        { type = "bool", text = "settings.hud_cust.cust_exit_reset_sel.title", convar = "cust_exit_reset_sel", desc = "settings.hud_cust.cust_exit_reset_sel.desc"},
        { type = "bool", text = "settings.hud_cust.imperial.title", convar = "imperial", desc = "settings.hud_cust.imperial.desc"},
    },
    {
        TabName = "settings.tabname.hud_game",
        { type = "label", text = "settings.hud_game.lcd" },
        { type = "bool", text = "settings.hud_game.hud_force_disable.title", convar = "hud_force_disable", desc = "settings.hud_game.hud_force_disable.desc" },
        { type = "bool", text = "settings.hud_game.hud_arc9.title", convar = "hud_arc9", desc = "settings.hud_game.hud_arc9.desc" },
        { type = "bool", text = "settings.hud_game.hud_always.title", convar = "hud_always", desc = "settings.hud_game.hud_always.desc" },
        { type = "bool", text = "settings.hud_game.hud_compact.title", convar = "hud_compact", desc = "settings.hud_game.hud_compact.desc" },
        { type = "bool", text = "settings.hud_game.hud_nohints.title", convar = "hud_nohints", desc = "settings.hud_game.hud_nohints.desc" },
        { type = "bool", text = "settings.hud_game.hud_keephints.title", convar = "hud_keephints", desc = "settings.hud_game.hud_keephints.desc" },

        { type = "label", text = "settings.hud_game.killfeed" },
        { type = "bool", text = "settings.hud_game.killfeed_enable.title", convar = "killfeed_enable", desc = "settings.hud_game.killfeed_enable.desc" },
        { type = "bool", text = "settings.hud_game.killfeed_dynamic.title", convar = "killfeed_dynamic", desc = "settings.hud_game.killfeed_dynamic.desc" },
        { type = "bool", text = "settings.hud_game.killfeed_colour.title", convar = "killfeed_colour", desc = "settings.hud_game.killfeed_colour.desc" },

        { type = "label", text = "settings.hud_game.breath" },
        { type = "bool", text = "settings.hud_game.breath_hud.title", convar = "breath_hud", desc = "settings.hud_game.breath_hud.desc" },
        { type = "bool", text = "settings.hud_game.breath_pp.title", convar = "breath_pp", desc = "settings.hud_game.breath_pp.desc" },

        { type = "label", text = "settings.hud_game.centerhint" },
        { type = "bool", text = "settings.hud_game.centerhint_reload.title", convar = "center_reload_enable", desc = "settings.hud_game.centerhint_reload.desc" },
        { type = "slider", min = 0, max = 1, decimals = 2, text = "settings.hud_game.centerhint_reload_percent.title", convar = "center_reload", desc = "settings.hud_game.centerhint_reload_percent.desc" },
        { type = "bool", text = "settings.hud_game.centerhint_bipod.title", convar = "center_bipod", desc = "settings.hud_game.centerhint_bipod.desc" },
        { type = "bool", text = "settings.hud_game.centerhint_jammed.title", convar = "center_jam", desc = "settings.hud_game.centerhint_jammed.desc" },
        { type = "bool", text = "settings.hud_game.centerhint_firemode.title", convar = "center_firemode", desc = "settings.hud_game.centerhint_firemode.desc" },
        { type = "slider", min = 0, max = 2, decimals = 2, text = "settings.hud_game.centerhint_firemode_time.title", convar = "center_firemode_time", desc = "settings.hud_game.centerhint_firemode_time.desc" },
        { type = "bool", text = "settings.hud_game.centerhint_overheat.title", convar = "center_overheat", desc = "settings.hud_game.centerhint_overheat.desc" },

        { type = "label", text = "settings.hud_game.hud_glyph" },
        -- { type = "bool", text = "settings.hud_game.hud_glyph_dark.title", convar = "glyph_dark", desc = "settings.hud_game.hud_glyph_dark.desc" },
        -- { type = "slider", min = 0.5, max = 2, decimals = 2, text = "settings.hud_game.hud_glyph_size.title", convar = "glyph_size", desc = "settings.hud_game.hud_glyph_size.desc" },
		
        { type = "combo", text = "settings.hud_game.hud_glyph_type_hud.title", convar = "glyph_family_hud", desc = "settings.hud_game.hud_glyph_type_hud.desc", content = {
            {"1" .. ARC9:GetPhrase("settings.hud_game.hud_glyph_light"), "light"},
            {"2" .. ARC9:GetPhrase("settings.hud_game.hud_glyph_dark"), "dark"},
            {"3" .. ARC9:GetPhrase("settings.hud_game.hud_glyph_knockout"), "knockout"},
			},
        },
		
        { type = "combo", text = "settings.hud_game.hud_glyph_type_cust.title", convar = "glyph_family_cust", desc = "settings.hud_game.hud_glyph_type_cust.desc", content = {
            {"1" .. ARC9:GetPhrase("settings.hud_game.hud_glyph_light"), "light"},
            {"2" .. ARC9:GetPhrase("settings.hud_game.hud_glyph_dark"), "dark"},
            {"3" .. ARC9:GetPhrase("settings.hud_game.hud_glyph_knockout"), "knockout"},
			},
        },
    },
    {
        TabName = "settings.tabname.npc",
        sv = true,
        { type = "label", text = "settings.npc.weapons" },
        { type = "bool", text = "settings.npc.npc_equality.title", convar = "npc_equality", desc = "settings.npc.npc_equality.desc" },
        { type = "slider", text = "settings.npc.npc_spread.title", min = 0, max = 10, decimals = 1, convar = "npc_spread", desc = "settings.npc.npc_spread.desc"},
        { type = "bool", text = "settings.npc.npc_atts.title", convar = "npc_atts", desc = "settings.npc.npc_atts.desc" },
        { type = "bool", text = "settings.npc.ground_atts.title", convar = "ground_atts", desc = "settings.npc.ground_atts.desc" },
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
        { type = "bool", text = "settings.gameplay.togglepeek_reset.title", convar = "togglepeek_reset", desc = "settings.gameplay.togglepeek_reset.desc" },
        { type = "bool", text = "settings.gameplay.togglebreath.title", convar = "togglebreath", desc = "settings.gameplay.togglebreath.desc" },

        { sv = true, type = "label", text = "settings.gameplay.mechanics" },
        { sv = true, type = "bool", text = "settings.gameplay.infinite_ammo.title", convar = "infinite_ammo", desc = "settings.gameplay.infinite_ammo.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.realrecoil.title", convar = "realrecoil", desc = "settings.gameplay.realrecoil.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.lean.title", convar = "lean", desc = "settings.gameplay.lean.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.mod_sway.title", convar = "mod_sway", desc = "settings.gameplay.mod_sway.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.mod_freeaim.title", convar = "mod_freeaim", desc = "settings.gameplay.mod_freeaim.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.mod_bodydamagecancel.title", convar = "mod_bodydamagecancel", desc = "settings.gameplay.mod_bodydamagecancel.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.breath_slowmo.title", convar = "breath_slowmo", desc = "settings.gameplay.breath_slowmo.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.manualbolt.title", convar = "manualbolt", desc = "settings.gameplay.manualbolt.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.never_ready.title", convar = "never_ready", desc = "settings.gameplay.never_ready.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.recoilshake.title", convar = "recoilshake", desc = "settings.gameplay.recoilshake.desc" },
        { sv = true, type = "bool", text = "settings.gameplay.equipment_generate_ammo.title", convar = "equipment_generate_ammo", desc = "settings.gameplay.equipment_generate_ammo.desc" },
        -- { type = "bool", text = "", convar = "nearwall", desc = "" },
        -- random jams
        -- overheating
    },
    {
        TabName = "settings.tabname.visuals",
        { type = "label", text = "settings.visuals.viewmodel" },
        { type = "combo", text = "settings.visuals.vm_bobstyle.title", convar = "vm_bobstyle", content = {
            {"1Bread & Darsu", "0"},
            {"2Fesiug", "1"},
            {"3Arctic", "2"},
            {"4Darsu", "3"},
            {"5Bread (exaggerated)", "4"},
            {"6Half-Life 2", "-1"},
        },
        desc = "settings.visuals.vm_bobstyle.desc" },
        -- { type = "slider", text = "Bob Style", convar = "vm_bobstyle", min = 0, max = 2, decimals = 0, desc = "Select different bobbing styles, to the flavor of different members of the ARC9 team.\n\n0: Darsu\n 1: Fesiug\n2: Arctic" },
        { type = "slider", text = "settings.visuals.fov.title", convar = "fov", min = -40, max = 40, decimals = 0, desc = "settings.visuals.fov.desc"},
        { type = "slider", min = -16, max = 16, decimals = 1, text = "settings.visuals.vm_addx.title", convar = "vm_addx", desc = "settings.visuals.vm_addx.desc" },
        { type = "slider", min = -16, max = 16, decimals = 1, text = "settings.visuals.vm_addy.title", convar = "vm_addy", desc = "settings.visuals.vm_addy.desc" },
        { type = "slider", min = -16, max = 16, decimals = 1, text = "settings.visuals.vm_addz.title", convar = "vm_addz", desc = "settings.visuals.vm_addz.desc" },

        { type = "label", text = "settings.visuals.cambob" },
        { type = "bool", text = "settings.visuals.vm_cambob.title", convar = "vm_cambob", desc = "settings.visuals.vm_cambob.desc" },
        { type = "bool", text = "settings.visuals.vm_cambobwalk.title", convar = "vm_cambobwalk", desc = "settings.visuals.vm_cambobwalk.desc" },
        { type = "slider", text = "settings.visuals.vm_cambobintensity.title", convar = "vm_cambobintensity", min = 0, max = 3, decimals = 2, desc = "settings.visuals.vm_cambobintensity.desc"},

        { type = "label", text = "settings.visuals.tpik" },
        { type = "bool", text = "settings.visuals.tpik.title", convar = "tpik", desc = "settings.visuals.tpik.desc" },
        { type = "bool", text = "settings.visuals.tpik_others.title", convar = "tpik_others", desc = "settings.visuals.tpik_others.desc" },
        { type = "slider", text = "settings.visuals.tpik_framerate.title", convar = "tpik_framerate", min = 0, max = 200, decimals = 0, desc = "settings.visuals.tpik_framerate.desc" },
    },
    {
        TabName = "settings.tabname.bullets",
        sv = true,
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
        { sv = true, type = "label", text = "settings.attachments.customization"},
        { sv = true, type = "bool", text = "settings.attachments.atts_nocustomize.title", convar = "atts_nocustomize", desc = "settings.attachments.atts_nocustomize.desc"},
        { type = "slider", text = "settings.attachments.atts_max.title", convar = "atts_max", min = 0, max = 250, decimals = 0, desc = "settings.attachments.atts_max.desc"},
        { type = "bool", text = "settings.attachments.autosave.title", convar = "autosave", desc = "settings.attachments.autosave.desc"},
        -- { type = "bool", text = "Total Anarchy", convar = "atts_anarchy", desc = "Allows any attachment to be attached to any slot.\nVERY laggy.\nWill not work properly with 99% of weapons and attachments.\nPlease don't turn this on.\n\nThis is a server variable."},
        { sv = true, type = "button", text = "settings.attachments.blacklist.title", content = "settings.attachments.blacklist.open", func = function(self2)
            RunConsoleCommand("arc9_blacklist")
        end},
        { sv = true, type = "label", text = "settings.attachments.inventory"},
        { sv = true, type = "bool", text = "settings.attachments.free_atts.title", convar = "free_atts", desc = "settings.attachments.free_atts.desc"},
        { sv = true, type = "bool", text = "settings.attachments.atts_lock.title", convar = "atts_lock", desc = "settings.attachments.atts_lock.desc"},
        { sv = true, type = "bool", text = "settings.attachments.atts_loseondie.title", convar = "atts_loseondie", desc = "settings.attachments.atts_loseondie.desc"},
        { sv = true, type = "bool", text = "settings.attachments.atts_generateentities.title", convar = "atts_generateentities", desc = "settings.attachments.atts_generateentities.desc"},
    },
    {
        TabName = "settings.tabname.modifiers",
        sv = true,
        { type = "label", text = "settings.modifiers.quick.title", desc = "settings.modifiers.quick.desc"},
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_damage.title", convar = "mod_damage" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_spread.title", convar = "mod_spread" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_recoil.title", convar = "mod_recoil" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_visualrecoil.title", convar = "mod_visualrecoil" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_adstime.title", convar = "mod_adstime" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_sprinttime.title", convar = "mod_sprinttime" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_damagerand.title", convar = "mod_damagerand" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_muzzlevelocity.title", convar = "mod_muzzlevelocity" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_rpm.title", convar = "mod_rpm" },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "settings.mod_headshotdamage.title", convar = "mod_headshotdamage" },
        { type = "slider", min = 0, max = 100, decimals = 1, text = "settings.mod_malfunction.title", convar = "mod_malfunction" },
        -- { type = "slider", text = "Damage", convar = "wawa", min = 0, max = 10, decimals = 0, desc = "The     Damage\n\nThis is a server variable."},

        -- { type = "button", text = "Advanced modifiers", content = "Open panel", func = function(self2)
        --     -- RunConsoleCommand("arc9_reloadatts")
        --     print("lol")
        --     -- put here default derma panel with stuff from fesiug's spawmenu modifier panel
        -- end},
    },
    {
        TabName = "settings.tabname.controller",
        { type = "label", text = "settings.tabname.controller", desc = "settings.controller.misc.desc"},
        { type = "bool", text = "settings.controller.controller.title", convar = "controller", desc = "settings.controller.controller.desc"},
		{ type = "bool", text = "settings.aimassist.enable.title", convar = "aimassist_cl", desc = "settings.aimassist.enable_client.desc"},
		{ type = "slider", text = "settings.optics.sensmult.title", min = 0.1, max = 1, decimals = 1, convar = "mult_sens", desc = "settings.optics.sensmult.desc" },
        -- { type = "combo", text = "settings.controller.glyphs.title", convar = "glyph_type", desc = "settings.controller.glyphs.desc", content = {
            -- {"1Xbox", "xbox"},
            -- {"2PlayStation", "ps"},
            -- {"3Nintendo Switch", "switch"},
			-- },
        -- },
        -- { type = "bool", text = "settings.controller.controller_rumble.title", convar = "controller_rumble", desc = "settings.controller.controller_rumble.desc"},
        -- { type = "button", text = "settings.controller.controller_config.title", desc = "settings.controller.controller_config.desc", content = "settings.controller.controller_config.content", func = function(self2)
        --     -- RunConsoleCommand("arc9_reloadatts")
        --     print("lol")
        --     -- put here default derma panel with stuff from fesiug's spawmenu controller panel
        -- end},
    },
    {
        TabName = "settings.tabname.aimassist",
        { type = "label", text = "settings.general.client", desc = "settings.tabname.aimassist.desc" },
        { type = "bool", text = "settings.aimassist.enable.title", convar = "aimassist_cl", desc = "settings.aimassist.enable_client.desc"},
        -- { type = "bool", text = "settings.aimassist.lockon.title", convar = "aimassist_lockon_cl", desc = "settings.aimassist.lockon.desc"},
        { type = "slider", text = "settings.optics.sensmult.title", min = 0.1, max = 1, decimals = 2, convar = "aimassist_multsens", desc = "settings.aimassist.sensmult.desc" },

        { type = "label", text = "settings.general.server" },
        { type = "bool", text = "settings.aimassist.enable.title", convar = "aimassist", desc = "settings.aimassist.enable.desc"},
        -- { type = "bool", text = "settings.aimassist.lockon_allow.title", convar = "aimassist_lockon", desc = "settings.aimassist.lockon_allow.desc"},
        { type = "slider", min = 0.1, max = 2, decimals = 1, text = "settings.aimassist.intensity.title", convar = "aimassist_intensity", desc = "settings.aimassist.intensity.desc" },
        { type = "slider", min = 0.1, max = 10, decimals = 1, text = "settings.aimassist.cone.title", convar = "aimassist_cone", desc = "settings.aimassist.cone.desc" },
        { type = "bool", text = "settings.aimassist.head.title", convar = "aimassist_head", desc = "settings.aimassist.head.desc"},
        -- { type = "bool", text = "settings.aimassist.moving.title", convar = "aimassist_moving", desc = "settings.aimassist.moving.desc"},
        -- { type = "bool", text = "settings.aimassist.grounded.title", convar = "aimassist_grounded", desc = "settings.aimassist.grounded.desc"},

    },
    {
        TabName = "settings.tabname.caching",
        { type = "label", text = "settings.caching.title", desc = "settings.caching.desc" },
        { type = "bool", text = "settings.caching.precache_sounds_onfirsttake.title", convar = "precache_sounds_onfirsttake", desc = "settings.caching.precache_sounds_onfirsttake.desc"},
        { type = "bool", text = "settings.caching.precache_attsmodels_onfirsttake.title", convar = "precache_attsmodels_onfirsttake", desc = "settings.caching.precache_attsmodels_onfirsttake.desc"},
        { type = "bool", text = "settings.caching.precache_wepmodels_onfirsttake.title", convar = "precache_wepmodels_onfirsttake", desc = "settings.caching.precache_wepmodels_onfirsttake.desc"},
        { type = "bool", text = "settings.caching.precache_allsounds_onstartup.title", convar = "precache_allsounds_onstartup", desc = "settings.caching.precache_allsounds_onstartup.desc"},
        { type = "bool", text = "settings.caching.precache_attsmodels_onstartup.title", convar = "precache_attsmodels_onstartup", desc = "settings.caching.precache_attsmodels_onstartup.desc"},
        { type = "bool", text = "settings.caching.precache_wepmodels_onstartup.title", convar = "precache_wepmodels_onstartup", desc = "settings.caching.precache_wepmodels_onstartup.desc"},

        { type = "button", text = "settings.caching.precache_allsounds.title", content = "settings.developer.cache", func = function(self2)
            RunConsoleCommand("arc9_precache_allsounds")
        end},
        { type = "button", text = "settings.caching.precache_attsmodels.title", content = "settings.developer.cache", func = function(self2)
            RunConsoleCommand("arc9_precache_attsmodels")
        end},
        { type = "button", text = "settings.caching.precache_wepmodels.title", content = "settings.developer.cache", func = function(self2)
            RunConsoleCommand("arc9_precache_wepmodels")
        end},
    },
    {
        TabName = "settings.tabname.developer",
        sv = true,
        { type = "label", text = "settings.developer.developer"},
        { type = "bool", text = "settings.developer.dev_always_ready.title", convar = "dev_always_ready", desc = "settings.developer.dev_always_ready.desc"},
        { type = "bool", text = "settings.developer.dev_benchgun.title", convar = "dev_benchgun", desc = "settings.developer.dev_benchgun.desc"},
        { type = "bool", text = "settings.developer.dev_crosshair.title", convar = "dev_crosshair", desc = "settings.developer.dev_crosshair.desc"},
        { type = "bool", text = "settings.developer.dev_show_shield.title", convar = "dev_show_shield", desc = "settings.developer.dev_show_shield.desc"},
        { type = "bool", text = "settings.developer.dev_greenscreen.title", convar = "dev_greenscreen", desc = "settings.developer.dev_greenscreen.desc"},
        { type = "bool", text = "settings.developer.dev_show_affectors.title", convar = "dev_show_affectors", desc = "settings.developer.dev_show_affectors.desc"},
        { type = "button", text = "settings.developer.reloadatts.title", content = "settings.developer.reload", func = function(self2)
            RunConsoleCommand("arc9_reloadatts")
        end},
        { type = "button", text = "settings.developer.reloadlangs.title", content = "settings.developer.reload", func = function(self2)
            RunConsoleCommand("arc9_reloadlangs")
        end},
        { type = "button", text = "settings.developer.dev_listmyatts.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_listmyatts")
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
        { type = "button", text = "settings.developer.dev_listmats.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_listsubmats")
        end},
        { type = "button", text = "settings.developer.dev_export.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_export")
        end},
        { type = "button", text = "settings.developer.dev_getjson.title", content = "settings.developer.print", func = function(self2)
            RunConsoleCommand("arc9_dev_getjson")
        end},
        { type = "button", text = "settings.developer.presets_clear.title", content = "settings.developer.clear", desc = "settings.developer.presets_clear.desc", func = function(self2)
            RunConsoleCommand("arc9_presets_clear")
        end},
    },
}

local ARC9ScreenScale = ARC9.ScreenScale
-- local mat_icon = Material("arc9/arc9_logo_ui.png", "mips smooth")
local arc9logo_layer1 = Material("arc9/logo/logo_bottom.png", "mips smooth")
local arc9logo_layer2 = Material("arc9/logo/logo_middle.png", "mips smooth")
local mat_Notif = Material("arc9/ui/info.png", "mips")
local color_Notif = Color(255, 50, 50)

local function DrawSettings(bg, page)
    local cornercut = ARC9ScreenScale(3.5)

    local buttontalling = 0
    local activedesc = ""
    local activecvar = ""

    local sheet = vgui.Create("ARC9ColumnSheet", bg)
    sheet:Dock(FILL)
    sheet:DockMargin(0, 0, ARC9ScreenScale(100), ARC9ScreenScale(1.7))
    sheet.Navigation:DockMargin(-120, 0, 0, ARC9ScreenScale(5)) -- idk why -120
    sheet.Navigation:SetWidth(ARC9ScreenScale(100))

    for k, v in pairs(ARC9.SettingsTable) do
        local newpanel = vgui.Create("DPanel", sheet)
        newpanel:Dock(FILL)
        newpanel.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ARC9.GetHUDColor("bg")) end
        local newpanelscroll = vgui.Create("ARC9ScrollPanel", newpanel)
        newpanelscroll:Dock(FILL)
        newpanelscroll:DockMargin(ARC9ScreenScale(4), ARC9ScreenScale(4), ARC9ScreenScale(4), 0)

        for k2, v2 in ipairs(v) do
            if v2.showfunc and !v2.showfunc() then continue end
            
            local elpanel = vgui.Create("DPanel", newpanelscroll)
            elpanel.realtall = ARC9ScreenScale(v2.type == "label" and 14 or 21) * ((v2.type == "label" or v2.type == "bool" ) and 0.85 or 1)
            elpanel:SetTall(elpanel.realtall)
            elpanel:DockMargin(0, (k2 != 1 and v2.type == "label") and ARC9ScreenScale(4) or 0, 0, 0)
            elpanel:Dock(TOP)

            local noperms = !game.SinglePlayer() and !LocalPlayer():IsListenServerHost() and !LocalPlayer():IsAdmin()
                    and v2.convar and ARC9.ConVarData["arc9_" .. v2.convar] and !ARC9.ConVarData["arc9_" .. v2.convar].client

            elpanel.Paint = function(self2, w, h)
                if v2.type == "label" and v2.text != "" then
                    surface.SetDrawColor(0, 0, 0, 75)
                    if v2.important then surface.SetDrawColor(233, 21, 21, 171) end
                    surface.DrawRect(0, 0, w, h)
                end

                local txt = ""

                if v2.parentconvar then
                    if !GetConVar("arc9_" .. v2.parentconvar):GetBool() then
                        self2:SetTall(1)
                        return
                    else
                        self2:SetTall(elpanel.realtall)
                    end

                    txt = "   › "
                end
                -- desc!!!!!!!!

                if self2:IsHovered() and activedesc != (ARC9:GetPhrase(v2.desc) or v2.desc or "") then
                    activedesc = (ARC9:GetPhrase(v2.desc) or v2.desc or "")
                    activecvar = v2.convar and ("arc9_" .. v2.convar) or ""
                    if bg.desc then bg.desc:Remove() end

                    local desc = vgui.Create("ARC9ScrollPanel", bg)
                    desc:SetPos(bg:GetWide() - ARC9ScreenScale(97.5), ARC9ScreenScale(35))
                    desc:SetSize(ARC9ScreenScale(93), bg:GetTall() - ARC9ScreenScale(40))
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

                txt = txt .. ARC9:GetPhrase(v2.text) or ARC9:GetPhrase("settings" .. "." .. (v2.convar or "") .. ".title") or v2.text or ""

                surface.SetFont("ARC9_12_Slim")
                local tw, th = surface.GetTextSize(txt)
                if noperms then
                    surface.SetTextColor(ARC9.GetHUDColor("unowned"))
                else
                    surface.SetTextColor(ARC9.GetHUDColor("fg"))
                end

                surface.SetTextPos(ARC9ScreenScale(4), h/2 - th/2)
                surface.DrawText(txt)
            end

            local elpw, elph = bg:GetWide() - ARC9ScreenScale(232), ARC9ScreenScale(21)

            if v2.type == "label" then
                -- woopsie
            elseif v2.type == "bool" then
                local newel = vgui.Create("ARC9Checkbox", elpanel)
                newel:SetPos(elpw+ARC9ScreenScale(5), ARC9ScreenScale(4))
                if v2.convar then newel:SetConVar("arc9_" .. v2.convar) end
                if noperms then newel:SetEnabled(false) end
            elseif v2.type == "slider" then
                local newel = vgui.Create("ARC9NumSlider", elpanel)
                newel:SetPos(ARC9ScreenScale(23), ARC9ScreenScale(6))
                newel:SetSize(elpw, 30)
                newel:SetDecimals(v2.decimals or 0)
                newel:SetMin(v2.min or 0)
                newel:SetMax(v2.max or 255)
                if v2.convar then newel:SetConVar("arc9_" .. v2.convar) end
                if v2.convar2 then newel:SetValue(GetConVar("arc9_" .. v2.convar2):GetFloat()) end
                if noperms then newel:SetEnabled(false) end

                local oldmousereleased = newel.Slider.OnMouseReleased
                newel.Slider.OnMouseReleased = function(self2, kc)
                    oldmousereleased(self2, kc)
                    if v2.func then v2.func(self2, newel, bg) end
                end
            elseif v2.type == "color" then
                local newel = vgui.Create("ARC9ColorButton", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(65), ARC9ScreenScale(6))

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                newel:CustomSetConvar(cvar)

                if GetConVar(cvar .. "_r") then
                    newel.rgbcolor = Color(GetConVar(cvar .. "_r"):GetInt() or 255, GetConVar(cvar .. "_g"):GetInt() or 0, GetConVar(cvar .. "_b"):GetInt() or 0)
                else
                    newel.rgbcolor = Color(255, 0, 0)
                    print("you are dumb, missing color convar")
                end

                if noperms then newel:SetEnabled(false) end
            elseif v2.type == "coloralpha" then
                local newel = vgui.Create("ARC9ColorButton", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(65), ARC9ScreenScale(6))
                newel:EnableAlpha()

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                newel:CustomSetConvar(cvar)

                if GetConVar(cvar .. "_a") then
                    newel.rgbcolor = Color(GetConVar(cvar .. "_r"):GetInt() or 255, GetConVar(cvar .. "_g"):GetInt() or 0, GetConVar(cvar .. "_b"):GetInt() or 0, GetConVar(cvar .. "_a"):GetInt() or 255)
                else
                    newel.rgbcolor = Color(255, 0, 0)
                    print("you are dumb, missing color convar (or its _alpha)")
                end

                if noperms then newel:SetEnabled(false) end
            elseif v2.type == "input" then
                local newel = vgui.Create("DTextEntry", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(65), ARC9ScreenScale(6))
                newel:SetText(v2.text)
            elseif v2.type == "combo" then
                local newel = vgui.Create("ARC9ComboBox", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(65), ARC9ScreenScale(6))
                newel:CustomSetConvar("arc9_" .. v2.convar)

                local cvdata = GetConVar("arc9_" .. v2.convar):GetString()

                for _, choice in pairs(v2.content) do
                    if tostring(choice[2]) == cvdata then
                        newel:AddChoice(choice[1], choice[2], true)
                    else
                        newel:AddChoice(choice[1], choice[2])
                    end
                end

                local oldCloseMenu = newel.CloseMenu
                newel.CloseMenu = function(self2)
                    oldCloseMenu(self2, kc)
                    if true and v2.func then v2.func(self2) end
                end

                if noperms then newel:SetEnabled(false) end
            elseif v2.type == "button" then
                local newel = vgui.Create("ARC9Button", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(65), ARC9ScreenScale(6))
                newel.text = ARC9:GetPhrase(v2.content)

                local oldmousepressed = newel.OnMousePressed
                newel.OnMousePressed = function(self2, kc)
                    oldmousepressed(self2, kc)
                    if kc == MOUSE_LEFT and v2.func then v2.func(self2) end
                end

                if noperms then newel:SetEnabled(false) end
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

            if v.Warning and v.Warning() then
                barbuttoncolor = color_Notif
            end

            if self2:IsHovered() then
                barbuttoncolor = ARC9.GetHUDColor("hi")
            end

            surface.SetDrawColor(barbuttoncolor)
            surface.DrawRect(0, 0, ARC9ScreenScale(1.7), h)
            surface.SetDrawColor(mainbuttoncolor)
            surface.DrawRect(ARC9ScreenScale(3.4), 0, w-ARC9ScreenScale(3.4), h)

            surface.SetFont("ARC9_12")
            local tw = surface.GetTextSize(ARC9:GetPhrase(v.TabName) or v.TabName)

            surface.SetTextColor(buttontextcolor)
            surface.SetTextPos((w - tw) / 2 + ARC9ScreenScale(1.7), ARC9ScreenScale(3))
            surface.DrawText(ARC9:GetPhrase(v.TabName) or v.TabName)


            if v.Warning and v.Warning() then
                surface.SetDrawColor(color_Notif)
                surface.SetMaterial(mat_Notif)
                surface.DrawTexturedRect(ARC9ScreenScale(8), h / 2 - h / 6, h / 3, h / 3)
            end
        end

        thatsheet.Button.DoClickOld = thatsheet.Button.DoClick
        thatsheet.Button.DoClick = function(self2)
            self2:DoClickOld()
            ARC9.SettingsActiveTab = k
        end

        buttontalling = buttontalling + ARC9ScreenScale(19+1.7)
    end

    bg.Paint = function(self2, w, h)
        draw.NoTexture()

        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        local talll = sheet.Navigation:GetTall() + ARC9ScreenScale(6.7)
        surface.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = 0, y = h-math.max(ARC9ScreenScale(5), talll-buttontalling)}, {x = ARC9ScreenScale(98,4), y = h-math.max(ARC9ScreenScale(5), talll-buttontalling)}, {x = ARC9ScreenScale(98,4), y = h}}) -- left bottom panel
        surface.DrawPoly({{x = w-ARC9ScreenScale(98,4), y = h}, {x = w-ARC9ScreenScale(98,4), y = ARC9ScreenScale(25.7)}, {x = w, y = ARC9ScreenScale(25.7)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}}) -- right panel
        surface.DrawPoly({{x = 0, y = ARC9ScreenScale(24)},{x = 0, y = cornercut},{x = cornercut, y = 0}, {x = w-cornercut, y = 0}, {x = w, y = cornercut}, {x = w, y = ARC9ScreenScale(24)}}) -- top panel

        surface.SetDrawColor(ARC9.GetHUDColor("hi"))
        surface.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = cornercut, y = h-cornercut*.5}})
        surface.DrawPoly({{x = w, y = h-cornercut}, {x = w-cornercut, y = h}, {x = w-cornercut, y = h-cornercut*.5}})
        surface.DrawPoly({{x = cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h}, {x = cornercut, y = h}, })


        -- surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        -- surface.SetMaterial(mat_icon)
        -- surface.DrawTexturedRect(ARC9ScreenScale(4), ARC9ScreenScale(2), ARC9ScreenScale(20), ARC9ScreenScale(20))

        -- ARC9.DrawColoredARC9Logo(ARC9ScreenScale(4), ARC9ScreenScale(2), ARC9ScreenScale(20), ARC9.GetHUDColor("hi"))

        -- function ARC9.DrawColoredARC9Logo(x, y, s, col)
        do
            local x, y, s = ARC9ScreenScale(4), ARC9ScreenScale(2), ARC9ScreenScale(20)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(arc9logo_layer1)
            surface.DrawTexturedRect(x, y, s, s)

            surface.SetDrawColor(ARC9.GetHUDColor("hi"))
            surface.SetMaterial(arc9logo_layer2)
            surface.DrawTexturedRect(x, y, s, s)
        end

        surface.SetFont("ARC9_8_Slim")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(w-ARC9ScreenScale(96), ARC9ScreenScale(26))
        surface.DrawText(activedesc != "" and ARC9:GetPhrase("settings.desc") or "") -- no title if no desc

        if activecvar != "" then -- display the cvar at the bottom of the description page
            local freshcvar = ""
            local cvarrealm = nil

            if !GetConVar(activecvar) and GetConVar(activecvar .. "_r") then
                freshcvar = activecvar .. "_r/_g/_b" .. (GetConVar(activecvar .. "_a") and "/_a" or "")
            else
                freshcvar = activecvar .. " " .. (GetConVar(activecvar):GetString() or "")
            end

            if !GetConVar(activecvar) and GetConVar(activecvar .. "_r") then -- also display the default value of said cvar

                if GetConVar(activecvar .. "_a") then ifalpha = "," .. GetConVar(activecvar .. "_a"):GetDefault() else ifalpha = "" end -- check if an alpha convar also exists

                if string.len(ARC9:GetPhrase("settings.default_convar")) > 17 then -- if the string is over 17 characters long, then make it two value displays
                    defaultvalue = GetConVar(activecvar .. "_r"):GetDefault() .. "," .. GetConVar(activecvar .. "_g"):GetDefault() .. ","
                    defaultvalue2 = GetConVar(activecvar .. "_b"):GetDefault() .. ifalpha
                else -- otherwise, only use one
                    defaultvalue = GetConVar(activecvar .. "_r"):GetDefault() .. "," .. GetConVar(activecvar .. "_g"):GetDefault() .. "," .. GetConVar(activecvar .. "_b"):GetDefault() .. ifalpha
                    defaultvalue2 = ""
                end

                if !game.SinglePlayer() and !LocalPlayer():IsListenServerHost() then
                    if ARC9.ConVarData[activecvar .. "_r"].client then
                        cvarrealm = "settings.convar_client"
                    else
                        cvarrealm = "settings.convar_server"
                    end
                end
            else
                defaultvalue = GetConVar(activecvar):GetDefault()
                defaultvalue2 = ""

                if !game.SinglePlayer() and !LocalPlayer():IsListenServerHost() then
                    if ARC9.ConVarData[activecvar].client then
                        cvarrealm = "settings.convar_client"
                    else
                        cvarrealm = "settings.convar_server"
                    end
                end
            end

            local bump = cvarrealm and ARC9ScreenScale(37.5) or ARC9ScreenScale(30)
            surface.SetTextColor(ARC9.GetHUDColor("hint"))

            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(w-ARC9ScreenScale(90), h-bump)
            surface.DrawText(freshcvar)
            bump = bump - ARC9ScreenScale(7.5)

            surface.SetTextColor(ARC9.GetHUDColor("hint"))
            if cvarrealm then
                surface.SetTextPos(w-ARC9ScreenScale(90), h-bump)
                surface.DrawText(ARC9:GetPhrase(cvarrealm))
                bump = bump - ARC9ScreenScale(7.5)
            end

            surface.SetTextPos(w-ARC9ScreenScale(90), h-bump)
            surface.DrawText(ARC9:GetPhrase("settings.default_convar") .. ": " .. defaultvalue)
            bump = bump - ARC9ScreenScale(7.5)

            surface.SetTextPos(w-ARC9ScreenScale(90), h-bump)
            surface.DrawText(defaultvalue2)
        end

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

local arc9_hud_darkmode = GetConVar("arc9_hud_darkmode")

function ARC9_OpenSettings(page)
    page = page or ARC9.SettingsActiveTab
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

    bg.Paint = function(self2, w, h)
        if arc9_hud_darkmode:GetBool() then
            surface.SetDrawColor(58, 58, 58, 206)
        else
            surface.SetDrawColor(20, 20, 20, 224)
        end
        surface.DrawRect(0, 0, w, h)
    end

    local panel = vgui.Create("DFrame", bg)
    -- panel:SetSize(ARC9ScreenScale(330), ARC9ScreenScale(242))
    panel:SetSize(ScrH()*1.25, ScrH()*0.75)
    panel:MakePopup()
    panel:SetAlpha(0)
    panel:AlphaTo(255, 0.2, 0, nil)
    panel:Center()
    panel:SetTitle("")
    panel:DockPadding(0, ARC9ScreenScale(25.7), 0, 0)
    panel:ShowCloseButton(false)
    DrawSettings(panel, page)

    panel.OnRemove = function() bg:Remove() end


    -- do only if april fools
    local day = tonumber(os.date("%d"))
    local month = tonumber(os.date("%m"))

    if month == 4 and day == 1 then
        local m9k = vgui.Create("ARC9TopButton", panel)
        m9k:SetPos(panel:GetWide() - ARC9ScreenScale(21*4 + 11), ARC9ScreenScale(2))
        m9k:SetIcon(Material("arc9/ui/w9k.png", "mips smooth"))
        m9k.DoClick = function(self2)
            surface.PlaySound(clicksound)
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=128089118")
        end
    end

    local discord = vgui.Create("ARC9TopButton", panel)
    discord:SetPos(panel:GetWide() - ARC9ScreenScale(21*3 + 8), ARC9ScreenScale(2))
    discord:SetIcon(Material("arc9/ui/discord.png", "mips smooth"))
    discord.DoClick = function(self2)
        surface.PlaySound(clicksound)
        gui.OpenURL("https://discord.gg/wkafWps44a")
    end

    local steam = vgui.Create("ARC9TopButton", panel)
    steam:SetPos(panel:GetWide() - ARC9ScreenScale(21*2 + 5), ARC9ScreenScale(2))
    steam:SetIcon(Material("arc9/ui/steam.png", "mips smooth"))
    steam.DoClick = function(self2)
        surface.PlaySound(clicksound)
        gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2910505837")
    end

    local close = vgui.Create("ARC9TopButton", panel)
    close:SetPos(panel:GetWide() - ARC9ScreenScale(21+2), ARC9ScreenScale(2))
    close:SetIcon(Material("arc9/ui/close.png", "mips smooth"))
    close.DoClick = function(self2)
        surface.PlaySound(clicksound)
        -- print(ARC9.SettingsActiveTab)
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

concommand.Add("arc9_settings_open", ARC9_OpenSettings)