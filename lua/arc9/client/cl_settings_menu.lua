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
            content - {"1table of thingies", "2there", "3for some reason you need put number at start so it will be properly sorted", "4though it will be not drawn in ui"}
    title,
    convar to follow, (without arc9_; color selectors will automatically use _r/_g/_b)
    description to show on right
]]--

local settingstable = {
    // {
    //     TabName = "Tab name 1",
    //     { type = "label", text = "Header" },
    //     { type = "bool", text = "Booling", convar = "cust_blur", desc = "TEST DESCRIPTION" },
    //     { type = "slider", text = "Booling 2", min = -2, max = 2, desc = "f DESCRIPTION" },
    //     { type = "slider", text = "Slide me", min = -45, max = 45, convar = "fov", desc = "balls" },
    //     { type = "combo", text = "Yayay", convar = "arccw_attinv_loseondie", content = {"1table of thingies", "2there", "3ooo"}, desc = "hhhhhhhhhhhhhhhhh" },
    //     { type = "button", text = "Uhhh", content = "Boop", func = function(self2) print("wa") end, desc = "TEST DESCRIPTION" },
    //     { type = "color", text = "Coloringa", convar = "reflex", desc = "This color is very important. \n\nClient-only.\nConvar: arc9_sdfjidojgoidfjgoidfg_r/g/b/a" },
    //     -- { type = "coloralpha", text = "Color alpha", desc = "g" },
    //     -- { type = "input", text = "Color alpha", desc = "g" },
    // },
    {
        TabName = "Performance",
        { type = "label", text = "Blur" },
        { type = "bool", text = "In Scopes", convar = "fx_rtblur", desc = "Blurs the world while using a magnified scope."},
        { type = "bool", text = "In Sights", convar = "fx_adsblur", desc = "Blurs the weapon while aiming down sights."},
        { type = "bool", text = "While Reloading", convar = "fx_reloadblur", desc = "Blurs the world while reloading."},
        { type = "bool", text = "While Readying", convar = "fx_animblur", desc = "Blurs the world while deploying a weapon for the first time."},
        { type = "label", text = "Shell Eject" },
        { type = "bool", text = "Smoke Effects", convar = "eject_fx", desc = "Produce smoke effects from ejected shell casings, where the weapon supports this feature."},
        { type = "slider", text = "Add Life Time", convar = "eject_time", min = -1, max = 60, decimals = 0, desc = "Allow shell casings to stay in the world for longer. Can be expensive."},
        { type = "label", text = "Misc" },
        { type = "bool", text = "All Flashlights", convar = "allflash", desc = "Fully render all flashlights from other players.\n\nVery expensive."},
    },
    {
        TabName = "Optics",
        { type = "label", text = "Color" },
        { type = "color", text = "Reflex Sights", convar = "reflex", desc = "Color to use for reflex/holographic sights. Not all optics support this feature." },
        { type = "color", text = "Scopes", convar = "scope", desc = "Color to use for magnified scopes. Not all optics support this feature." },
        { type = "label", text = "Performance" },
        { type = "bool", text = "Cheap Scopes", convar = "cheapscopes", desc = "A cheap RT scope implementation. Significantly reduces lag while using RT scopes while losing very little."},
        { type = "label", text = "Control" },
        { type = "bool", text = "Compensate Sensitivity", convar = "compensate_sens", desc = "Compensate sensitivity for magnification." },
        { type = "bool", text = "Toggle ADS", convar = "toggleads", desc = "Aiming will toggle sights." },
    },
    {
        TabName = "Crosshair",
        { type = "label", text = "Crosshair" },
        { type = "bool", text = "Enable Crosshair", convar = "cross_enable", desc = "Enable crosshair. Does not work on all guns, which may not allow the crosshair to be used." },
        { type = "coloralpha", text = "Crosshair Color", convar = "cross", desc = "The crosshair's color. Some guns do not allow you to use the crosshair."},
        { type = "bool", text = "Force Crosshair", convar = "crosshair_force", desc = "Force crosshair enabled, even on guns that do not support it\nServer setting." },
        { type = "bool", text = "Static Crosshair", convar = "crosshair_static", desc = "Enable static crosshair, which does not move when shooting." }
    },
    {
        TabName = "Customize HUD",
        { type = "label", text = "HUD" },
        -- crazy hacks to make hud scale work "almost dynamicly"
        { type = "slider", text = "HUD Scale", min = 0.5, max = 1.5, decimals = 2, desc = "Scale multiplier for ARC9's HUD.", convar2 = "hud_scale", func = function(self2, self3, settingspanel) 
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
                ARC9_OpenSettings(3) -- open settings on current page (set number to tab number)
            end)
        end },
        { type = "input", text = "Font", convar = "font", desc = "Font replacement for ARC9. Set empty to use default font." },
        { type = "slider", min = -16, max = 16, decimals = 0, text = "Font Add Size", convar = "font_addsize", desc = "Increase text size.", func = function(self2, self3, settingspanel) 
            timer.Simple(0, function()
                ARC9.Regen() -- reload fonts with new scale
            end)
        end },
        { type = "color", text = "HUD Color", convar = "hud_color", desc = "Highlight color for the HUD."},
        { type = "input", text = "Language", convar = "language", desc = "Language pack to use for ARC9. Leave blank for game default." },
        { type = "slider", min = 0, max = 10, decimals = 1, text = "Light Brightness", convar = "cust_light_brightness", desc = "How bright the light in the customization panel is." },
        { type = "label", text = "Customization" },
        { type = "bool", text = "Background Blur", convar = "cust_blur", desc = "Blurs customization background.\n\nRequires DX9."},
        { type = "bool", text = "Hints", convar = "cust_hints", desc = "Enable hints for the customization menu."},
        { type = "bool", text = "Unlock Roll", convar = "cust_roll_unlock", desc = "Allow weapon roll in the customization menu."},
        { type = "bool", text = "Exit Resets Selection", convar = "cust_exit_reset_sel", desc = "Exiting customization menu resets customization selection."}
    },
    {
        TabName = "Game HUD",
        { type = "label", text = "LCD Panel" },
        { type = "bool", text = "Enable HUD", convar = "hud_arc9", desc = "Enable HUD for ARC9 weapons." },
        { type = "bool", text = "Always HUD", convar = "hud_always", desc = "Enable HUD on all weapons." },
        { type = "bool", text = "Compact Mode", convar = "hud_compact", desc = "Compact appearance for the HUD panel." },
        { type = "bool", text = "Keep Hints", convar = "hud_keephints", desc = "Always show ARC9 control hints." },
        { type = "label", text = "Killfeed" },
        { type = "bool", text = "Killfeed Icons", convar = "killfeed_enable", desc = "Enable ARC9-generated killfeed icons." },
        { type = "bool", text = "Dynamic Killfeed Icons", convar = "killfeed_dynamic", desc = "Killfeed icons are dynamically generated for each weapon." },
        { type = "label", text = "Breath" },
        { type = "bool", text = "Breath HUD", convar = "breath_hud", desc = "Show a bar that displays your remaining breath while stabilizing your gun in sights." },
        { type = "bool", text = "Breath Post-Process", convar = "breath_pp", desc = "Holding breath will also add post-processing effects to your screen." },
        { type = "bool", text = "Breath SFX", convar = "breath_sfx", desc = "Holding breath will play associated sound effects." },
    },
    {
        TabName = "NPCs",
        { type = "label", text = "NPC Weapons" },
        { type = "bool", text = "Damage Equality", convar = "npc_equality", desc = "NPCs do just as much damage as players do.\n\nThis is a server variable." },
        { type = "bool", text = "Give Attachments", convar = "npc_atts", desc = "Spawned or given ARC9 weapons receive a random set of attachments.\n\nThis is a server variable." },
        { type = "bool", text = "Replace NPC Weapons", convar = "npc_autoreplace", desc = "Replace NPC weapons with randomly chosen ARC9 weapons.\n\nThis is a server variable." },
        { type = "bool", text = "Replace Ground Weapons", convar = "replace_spawned", desc = "Replace map/spawned weapons with randomly chosen ARC9 weapons.\n\nThis is a server variable." },
        { type = "bool", text = "Players Can Give Weapons", convar = "npc_give_weapons", desc = "Players are able to press E on NPCs to give them their weapon.\n\nThis is a server variable." },
    },
    {
        TabName = "Gameplay",
        { type = "label", text = "Controls" },
        { type = "bool", text = "Toggle ADS", convar = "toggleads", desc = "Aiming will toggle sights." },
        { type = "bool", text = "Automatic Lean", convar = "autolean", desc = "Aiming will try to automatically lean if this is possible." },
        { type = "bool", text = "Automatic Reload", convar = "autoreload", desc = "Empty ARC9 weapons will reload automatically." },
        { type = "label", text = "Game Mechanics" },
        { type = "bool", text = "Infinite Ammo", convar = "infinite_ammo", desc = "Weapons have infinite ammunition.\n\nThis is a server variable." },
        { type = "bool", text = "Physical Visual Recoil", convar = "realrecoil", desc = "Select weapons set up for this feature experience physical muzzle rise, meaning they will fire where their viewmodel shows it rather than at the center of the screen. Very important for some weapon packs' balancing schemes.\n\nThis is a server variable." },
        { type = "bool", text = "Leaning", convar = "lean", desc = "Whether players can lean with +alt1 and +alt2, including automatic lean.\n\nThis is a server variable." },
        { type = "bool", text = "Sway", convar = "mod_sway", desc = "Weapons will have sway, if they are set up to use it.\n\nThis is a server variable." },
        { type = "bool", text = "Free Aim", convar = "mod_freeaim", desc = "Weapons will have free aim, and will not always shoot in the middle of the screen.\n\nThis is a server variable." },
        { type = "bool", text = "Body Damage Cancel", convar = "mod_bodydamagecancel", desc = "Cancel out default body damage multiplier. Only disable if using another mod that provides this type of functionality.\ne.g. Mods which change the default limb multipliers.\n\nThis is a server variable." },
        { type = "bool", text = "Slow-Mo Breath", convar = "breath_slowmo", desc = "Holding breath slows time.\n\nSingleplayer only." },
        { type = "bool", text = "Manual Cycling", convar = "manualbolt", desc = "Bolt-action weapons configured for this feature will only bolt when R is pressed, and not when the attack key is released." },
    },
    {
        TabName = "Visuals",
        { type = "label", text = "Viewmodel" },
        { type = "slider", text = "Bob Style", convar = "vm_bobstyle", min = 0, max = 2, decimals = 0, desc = "Select different bobbing styles, to the flavor of different members of the ARC9 team.\n\n0: Darsu\n 1: Fesiug\n2: Arctic" },
        { type = "slider", text = "FOV", convar = "fov", min = -50, max = 50, decimals = 0, desc = "Add viewmodel FOV. Makes the viewmodel bigger or smaller. Use responsibly."},
        { type = "label", text = "TPIK" },
        { type = "bool", text = "Enable TPIK", convar = "tpik", desc = "TPIK (Third Person Inverse Kinematics) is a system that allows select weapons that support the feature to display detailed reload and firing animations in third person." },
        { type = "bool", text = "Other Players TPIK", convar = "tpik_others", desc = "Show TPIK for players other than yourself. Negatively impacts performance." },
        { type = "slider", text = "TPIK Framerate", convar = "tpik_framerate", min = 0, max = 200, decimals = 0, desc = "Maximum framerate at which TPIK can run. Set to 0 for unlimited." },
    },
    {
        TabName = "Bullet Physics",
        { type = "label", text = "Bullet Physics"},
        { type = "bool", text = "Physical Bullets", convar = "bullet_physics", desc = "Weapons that support this feature will fire physical bullets, which have drop, travel time, and drag.\n\nThis is a server variable." },
        { type = "slider", text = "Gravity", convar = "bullet_gravity", min = 0, max = 10, decimals = 1, desc = "Multiplier for bullet gravity.\n\nThis is a server variable." },
        { type = "slider", text = "Drag", convar = "bullet_drag", min = 0, max = 10, decimals = 1, desc = "Multiplier for bullet drag.\n\nThis is a server variable." },
        { type = "bool", text = "Ricochet", convar = "ricochet", desc = "Bullets fired from select weapons can sometimes bounce off of surfaces and continue to travel and do damage.\n\nThis is a server variable." },
        { type = "bool", text = "Penetration", convar = "mod_penetration", desc = "Bullets fired from select weapons can penetrate surfaces and deal damage to whatever is on the other side.\n\nThis is a server variable." },
        { type = "slider", text = "Life Time", convar = "bullet_lifetime", min = 0, max = 120, decimals = 0, desc = "Time in seconds after which a bullet will be deleted.\n\nThis is a server variable." },
        { type = "bool", text = "Imaginary Bullets", convar = "bullet_imaginary", desc = "Bullets will appear to travel into the skybox, beyond the map's bounds." },
    },
    {
        TabName = "Attachments",
        { type = "label", text = "Customization"},
        { type = "bool", text = "Disable Customization", convar = "atts_nocustomize", desc = "Disallow all customization via the customization menu."},
        { type = "slider", text = "Max Attachments", convar = "atts_max", min = 0, max = 1000, decimals = 0, desc = "The maximum number of attachments that can be put on a weapon, including cosmetic attachments.\n\nThis is a server variable."},
        { type = "bool", text = "Autosave", convar = "autosave", desc = "Your last weapon customization options will be saved and automatically applied the next time you spawn that weapon."},
        { type = "bool", text = "Total Anarchy", convar = "atts_anarchy", desc = "Allows any attachment to be attached to any slot.\nVERY laggy.\nWill not work properly with 99% of weapons and attachments.\nPlease don't turn this on.\n\nThis is a server variable."},
        { type = "label", text = "Inventory"},
        { type = "bool", text = "One For All", convar = "atts_lock", desc = "Picking up one instance of an attachments allows you to use it infinite times on all your guns.\n\nThis is a server variable."},
        { type = "bool", text = "Lose On Death", convar = "atts_loseondie", desc = "Your attachment inventory will be lost when you die.\n\nThis is a server variable."},
        { type = "bool", text = "Generate Entities", convar = "atts_generateentities", desc = "Generate entities that can be spawned, allowing you to pick up attachments when free attachments is off.\n\nThis is a server variable."},
    },
    {
        TabName = "Controller",
        { type = "label", text = "Controller"},
        { type = "bool", text = "Controller Glyphs", convar = "controller", desc = "Enable custom controller-compatible glyphs, showing controller buttons instead of the default keys."},
        { type = "bool", text = "Rumble", convar = "controller_rumble", desc = "Enable controller rumble as long as Fesiug's DLL mod is loaded."},
    },
    {
        TabName = "Developer",
        { type = "label", text = "Developer Options"},
        { type = "bool", text = "Always Ready", convar = "dev_always_ready", desc = "Always play \"ready\" animation when deploying a weapon.\n\nThis is a server variable."},
        { type = "bool", text = "Benchgun", convar = "dev_benchgun", desc = "Set weapon to world origin.\nOnly really useful on gm_construct."},
        { type = "bool", text = "Show Shield", convar = "dev_show_shield", desc = "Show the model for the player's shield."},
        { type = "button", text = "List Anims", content = "Print to Console", func = function(self2)
            RunConsoleCommand("arc9_dev_listanims")
        end},
        { type = "button", text = "List Bones", content = "Print to Console", func = function(self2)
            RunConsoleCommand("arc9_dev_listbones")
        end},
        { type = "button", text = "List Bodygroups", content = "Print to Console", func = function(self2)
            RunConsoleCommand("arc9_dev_listbgs")
        end},
        { type = "button", text = "List QCAttachments", content = "Print to Console", func = function(self2)
            RunConsoleCommand("arc9_dev_listatts")
        end},
        { type = "button", text = "Get Export Code", content = "Print to Console", func = function(self2)
            RunConsoleCommand("arc9_dev_export")
        end},
        { type = "button", text = "Get Weapon JSON", content = "Print to Console", func = function(self2)
            RunConsoleCommand("arc9_dev_getjson")
        end},
        { type = "button", text = "List Anims", content = "Print to Console", func = function(self2)
            RunConsoleCommand("arc9_dev_listanims")
        end},
    },
}

local ARC9ScreenScale = ARC9.ScreenScale
local mat_icon = Material("arc9/arc9_logo_ui.png", "mips smooth")

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
                    if activedesc != (v2.desc or "") then
                        activedesc = (v2.desc or "")
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



                surface.SetFont("ARC9_12_Slim")
                local tw, th = surface.GetTextSize(v2.text or "Owo")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(4), h/2 - th/2)
                surface.DrawText(v2.text or "Owo")
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
                for _, choice in pairs(v2.content) do
                    newel:AddChoice(choice)
                end

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                if GetConVar(cvar) then
                    newel:CustomSetConvar(cvar)
                    newel:ChooseOptionID(GetConVar(cvar):GetInt())
                else
                    print("invalid combobox convar")
                end

            elseif v2.type == "button" then
                local newel = vgui.Create("ARC9Button", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel.text = v2.content

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
            local tw = surface.GetTextSize(v.TabName)

            surface.SetTextColor(buttontextcolor)
            surface.SetTextPos((w - tw) / 2 + ARC9ScreenScale(1.7), ARC9ScreenScale(3))
            surface.DrawText(v.TabName)
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
        
        
        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.SetMaterial(mat_icon)
        surface.DrawTexturedRect(ARC9ScreenScale(4), ARC9ScreenScale(2), ARC9ScreenScale(20), ARC9ScreenScale(20))

        surface.SetFont("ARC9_8_Slim")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(w-ARC9ScreenScale(73), ARC9ScreenScale(26))
        surface.DrawText(activedesc != "" and "Description" or "") -- no title if no desc

        surface.SetFont("ARC9_16")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(ARC9ScreenScale(30), ARC9ScreenScale(4))
        surface.DrawText("ARC9 Settings")
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
    -- bg:ShowCloseButton(false)        -- set to false when done please!!
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
        gui.OpenURL("https://discord.gg/wkafWps44a")
    end    

    local steam = vgui.Create("ARC9TopButton", panel)
    steam:SetPos(panel:GetWide() - ARC9ScreenScale(21*2 + 7), ARC9ScreenScale(2))
    steam:SetIcon(Material("arc9/ui/steam.png", "mips smooth"))
    steam.DoClick = function(self2)
        surface.PlaySound(clicksound)
        gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2131057232") -- dont forget to change to arc9 page when it release
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