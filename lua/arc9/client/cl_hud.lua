local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudGMod"] = false,
}

hook.Add("HUDShouldDraw", "ARC9_HideHUD", function(name)
    if !IsValid(LocalPlayer()) then return end

    if ARC9.ShouldDrawHUD() then
        if hide[name] then return false end
    end
end)

local arc9_hud_scale = GetConVar("arc9_hud_scale")
ARC9.ScreenScale = function(size)
    return size * (ScrW() / 640) * arc9_hud_scale:GetFloat() * 0.9
end

local ARC9ScreenScale = ARC9.ScreenScale

ARC9.Colors = {
    bg      = Color(153, 153, 153, 97), --
    bgdark  = Color(37, 37, 37, 240), --
    bg_pro  = Color(53, 179, 53, 97), --
    bg_con  = Color(204, 61, 61, 97), --
    pro  = Color(54, 179, 54), --
    con  = Color(179, 54, 54), --
    fg      = Color(255, 255, 255), --
    hi      = Color(255, 123, 0), --
    hint    = Color(200, 200, 200, 120), --
    unowned = Color(180, 180, 180, 255),

    notoccupied      = Color(216, 216, 216, 70), --

    sel      = Color(255, 150, 100),
    occupied = Color(150, 255, 100),
    shadow   = Color(17, 17, 9),
    neg      = Color(255, 100, 100),
    pos      = Color(100, 255, 100),

    bg_3d = Color(255, 255, 240),
    fg_3d = Color(0, 0, 0),
    shadow_3d = Color(0, 0, 0),
    hi_3d = Color(255, 50, 50),
    pos_3d = Color(255, 255, 255),

    bg_menu = Color(26, 26, 23, 252),
    md = Color(107,107,92),
}

local cl_drawhud = GetConVar("cl_drawhud")
local arc9_hud_arc9 = GetConVar("arc9_hud_arc9")
local arc9_hud_always = GetConVar("arc9_hud_always")
local arc9_hud_force_disable = GetConVar("arc9_hud_force_disable")

function ARC9.ShouldDrawHUD()
    if !cl_drawhud:GetBool() then return end
    if arc9_hud_force_disable:GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()
    local a9 = wpn.ARC9
    local incust = a9 and wpn:GetCustomize()
    -- local hud = arc9_hud_arc9:GetBool()
    -- local hudalways = arc9_hud_always:GetBool()

    hide.CHudGMod = incust

    -- if (!hud and !incust) or (!a9 and !hudalways) then return end
    if (!arc9_hud_arc9:GetBool() and !incust) or (!a9 and !arc9_hud_always:GetBool()) then return end -- this line was hard

    return true
end

local alldays = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [19] = true,
    [20] = true,
    [21] = true,
    [22] = true,
    [23] = true,
    [24] = true,
    [25] = true,
    [26] = true,
    [27] = true,
    [28] = true,
    [29] = true,
    [30] = true,
    [31] = true,
    [32] = true, -- you can't fight nature, jack
}
local events = {
    ["New Year's"] = {
        months = { [1] = true },
        days = { [1] = true },
    },
    ["Leap Day"] = {
        months = { [2] = true },
        days = { [29] = true },
    },
    -- ["Opposite Day"] = {
    --     months = { 1 },
    --     days = { 25 },
    -- },
    -- ["Earth Day"] = {
    --     months = { 4 },
    --     days = { 22 },
    -- },
    ["Earth Day"] = {
        months = { [4] = true },
        days = { [22] = true },
    },
    ["Easter"] = {
        months = { [4] = true },
        days = alldays,
    },
    ["Halloween"] = {
        months = { [10] = true },
        days = { [31] = true },
    },
    ["Thanksgiving"] = {
        months = { [11] = true }, 
        days = { [23] = true },
    },
    ["Christmas"] = {
        months = { [12] = true },
        days = { [25] = true },
    },
    ["Birthday - Arctic"] = {
        months = { [7] = true },
        days = { [27] = true },
    },
    ["Summer Break"] = {
        months = { [6] = true, [7] = true, [8] = true,  },
        days = alldays,
    },
    ["Troll Day"] = {
        months = { [4] = true },
        days = { [1] = true }
    },
}

local holidayscolors = {
    ["Christmas"] = {
        hi     = Color(184, 210, 160),
        bg     = Color(153, 113, 110, 97),
        bgdark = Color(33, 11, 9, 240),
    },
    ["Halloween"] = {
        hi     = Color(255, 187, 132),
        bg     = Color(120, 110, 153, 97),
        bgdark = Color(14, 6, 37, 240),
    },
    ["Thanksgiving"] = {
        hi     = Color(240, 195, 172),
        bg     = Color(153, 137, 110, 97),
        bgdark = Color(38, 34, 27, 240),
    },
    ["New Year's"] = {
        hi     = Color(255, 255, 200),
        bg     = Color(114, 114, 153, 97),
        bgdark = Color(30, 30, 40, 240),
    },
    ["Birthday - Arctic"] = {
        hi     = Color(210, 235, 255),
        bg     = Color(153, 153, 114, 97),
        bgdark = Color(40, 40, 30, 240),
    },
    ["None"] = {
        hi     = ARC9.Colors.hi,
        bg     = ARC9.Colors.bg,
        bgdark = ARC9.Colors.bgdark,
    },
}

local arc9_holiday_month = GetConVar("arc9_holiday_month")
local arc9_holiday_day = GetConVar("arc9_holiday_day")

function ARC9.GetTime()
    if arc9_holiday_month:GetInt() > 0 and arc9_holiday_day:GetInt() > 0 then
        return os.time( { month = arc9_holiday_month:GetInt(), day = arc9_holiday_day:GetInt(), year = 2000 } )
    else
        return os.time( )--{ month = 12, day = 1, year = 2000 } )
    end
end

function ARC9.GetHolidayColor()
    local d = os.date( "*t", ARC9.GetTime() )
    for i,j in pairs(holidayscolors) do
        if i == "None" then continue end
        if events[i].days[d.day] and events[i].months[d.month] then
            return i
        end
    end
    return "None"
end

ARC9.ActiveHolidays = {}

local d = os.date( "*t", ARC9.GetTime() )
for i,j in pairs(events) do
	if j.days[d.day] and j.months[d.month] then
		ARC9.ActiveHolidays[i] = true
	end
end

local arc9_hud_color_r = GetConVar("arc9_hud_color_r")
local arc9_hud_color_g = GetConVar("arc9_hud_color_g")
local arc9_hud_color_b = GetConVar("arc9_hud_color_b")
local arc9_hud_darkmode = GetConVar("arc9_hud_darkmode")
local arc9_hud_holiday = GetConVar("arc9_hud_holiday")

function ARC9.GetHUDColor(part, alpha)
    alpha = alpha or 255
    local holidayenabled = arc9_hud_holiday:GetBool()
    local col = ARC9.Colors[part] or ARC9.Colors.hi
    local holidaycol = holidayscolors[ARC9.GetHolidayColor()]
    
    
    if part == "hi" then
        col = Color(
            arc9_hud_color_r:GetInt(),
            arc9_hud_color_g:GetInt(),
            arc9_hud_color_b:GetInt()
        )
        if holidayenabled then
            col = holidaycol.hi
        end
    end

    if part == "bg" then
        if holidayenabled then
            col = holidaycol.bg
        end
        if arc9_hud_darkmode:GetBool() then
            col = ARC9.Colors["bgdark"]
            if holidayenabled then
                col = holidaycol.bgdark
            end
        end
    end
    
    if alpha < 255 then
        col = Color(col.r, col.g, col.b)
        col.a = alpha or 255
    end
    return col
end


local rackrisetime = 0
local lastrow = 0
local lastweapon = NULL
local hint_alpha = 1
local lasthintcount = 0
local hidefadetime = 0
local first = true
local convar_keephints = GetConVar("arc9_hud_keephints")

local hud_bg = Material("arc9/hud_bg.png", "mips smooth")
local hud_t_full = Material("arc9/thermometer_full.png", "mips")
local hud_t_empty = Material("arc9/thermometer_empty.png", "mips")
local hud_bigblur = Material("arc9/bigblur.png", "mips")
local hud_sillyhints = Material("arc9/sillyhintsblur.png", "mips")
local hud_logo_lowvis = Material("arc9/logo/logo_lowvis.png", "mips smooth")

local firemode_pics = {
    [-1] = Material("arc9/fs_auto.png", "mips smooth"),
    [0] = Material("arc9/fs_safe.png", "mips smooth"),
    [1] = Material("arc9/fs_semi.png", "mips smooth"),
    [2] = Material("arc9/fs_2rb.png", "mips smooth"),
    [3] = Material("arc9/fs_3rb.png", "mips smooth"),
}

local automatics = {
    ["weapon_smg1"] = true,
    ["weapon_ar2"] = true,
    ["weapon_mp5_hl1"] = true,
    ["weapon_gauss"] = true,
    ["weapon_egon"] = true
}

local arc9_lean = GetConVar("arc9_lean")

local function GetWeaponCapabilities(wpn)
    cap = {
        UBGL = tobool(!wpn:GetInSights() and wpn:GetValue("UBGL")),
        Bash = tobool(!wpn:GetInSights() and wpn:GetValue("Bash")),
        SwitchSights = tobool(wpn:GetInSights() and #wpn.MultiSightTable > 1),
        Inspect = !wpn:GetInSights() and tobool(wpn:HasAnimation("enter_inspect") or wpn:HasAnimation("inspect")),
        -- Blindfire = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire")),
        -- BlindfireLeft = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire") and wpn:GetValue("BlindFireLeft")),
        -- BlindfireRight = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire") and wpn:GetValue("BlindFireRight")),
        Firemode = tobool(!wpn:GetUBGL() and #wpn:GetValue("Firemodes") > 1),
        HoldBreath = tobool(wpn:GetInSights() and wpn:GetValue("HoldBreathTime") > 0),
        VariableZoom = tobool(wpn:GetInSights() and (wpn:GetSight().atttbl or {}).RTScopeAdjustable),
        ManualCycle = tobool(wpn:GetNeedsCycle() and wpn:ShouldManualCycle()),
        Lean = tobool(wpn:GetProcessedValue("CanLean", true) and arc9_lean:GetBool()),
    }

    return cap
end

local function GetHintsTable(capabilities)
    local weapon = LocalPlayer():GetActiveWeapon()
    local hints = {}

    if capabilities.UBGL then
        if ARC9.GetKeyIsBound("+arc9_ubgl") then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+arc9_ubgl"),
                action = ARC9:GetPhrase("hud.hint.ubgl") .. " " .. tostring(weapon:GetProcessedValue("UBGLFiremodeName", true))
            })
        else
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+attack2"),
                action = ARC9:GetPhrase("hud.hint.ubgl") .. " " .. tostring(weapon:GetProcessedValue("UBGLFiremodeName", true))
            })
        end
    end

    if capabilities.SwitchSights then
        if ARC9.GetKeyIsBound("+arc9_switchsights") then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+arc9_switchsights"),
                action = ARC9:GetPhrase("hud.hint.switchsights")
            })
        else
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("invnext"),
                action = ARC9:GetPhrase("hud.hint.switchsights")
            }) -- TODO: hardcoded to mouse wheel, see sh_move.lua ARC9.StartCommand
        end
    end

    if capabilities.VariableZoom then
        table.insert(hints, {
            glyph = !input.LookupBinding("invnext") and !(input.LookupKeyBinding(113) != nil and input.LookupKeyBinding(113):len() > 0) and "shared_mouse_scroll_down" or ARC9.GetBindKey("invnext"),
            glyph2 = !input.LookupBinding("invprev") and !(input.LookupKeyBinding(112) != nil and input.LookupKeyBinding(112):len() > 0) and "shared_mouse_scroll_up" or ARC9.GetBindKey("invprev"),
            action = ARC9:GetPhrase("hud.hint.zoom")
        }) -- use mouse wheel if invnext or invprev not bound, possible convar to swap maybe? currently for semi parity with switchsights
    end

    if capabilities.HoldBreath then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+speed"),
            action = ARC9:GetPhrase("hud.hint.breath")
        })
    end

    if capabilities.Bash and !weapon.PrimaryBash then
		if weapon.SecondaryBash then -- If the weapon performs bashing as the primary attack function, only display the "+attack" function.
			table.insert(hints, {
				glyph = ARC9.GetBindKey("+attack2"),
				action = ARC9:GetPhrase("hud.hint.bash")
			})
		else
			if ARC9.GetKeyIsBound("+arc9_melee") then
				table.insert(hints, {
					glyph = ARC9.GetBindKey("+arc9_melee"),
					action = ARC9:GetPhrase("hud.hint.bash")
				})
			else
				table.insert(hints, {
					glyph = ARC9.GetBindKey("+use"),
					glyph2 = ARC9.GetBindKey("+attack"),
					action = ARC9:GetPhrase("hud.hint.bash")
				})
			end
		end
    end

    if capabilities.Inspect then
        if ARC9.GetKeyIsBound("+arc9_inspect") then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+arc9_inspect"),
                action = ARC9:GetPhrase("hud.hint.inspect")
            })
        else
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+reload"),
                action = ARC9:GetPhrase("hud.hint.inspect")
            })
        end
    end

    if capabilities.Firemode then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+zoom"),
            action = ARC9:GetPhrase("hud.hint.firemode")
        })
    end

    if capabilities.ManualCycle then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+reload"),
            action = ARC9:GetPhrase("hud.hint.cycle")
        })
    end

    if weapon:CanToggleAllStatsOnF() then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("impulse 100"),
            action = ARC9:GetPhrase("hud.hint.toggleatts")
        })
    end

    table.insert(hints, {
        glyph = ARC9.GetBindKey("+menu_context"),
        action = not weapon:GetProcessedValue("CantPeek",true) and weapon:GetInSights() and ARC9:GetPhrase("hud.hint.peek") or ARC9:GetPhrase("hud.hint.customize") })

    table.insert(hints, {
        glyph = ARC9.GetBindKey("+use"),
        glyph2 = ARC9.GetBindKey("+zoom"),
        action = ARC9:GetPhrase("hud.hint.safe")
    })

    if capabilities.Lean and input.LookupBinding("+alt1") and input.LookupBinding("+alt2") then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+alt1"),
            glyph2 = ARC9.GetBindKey("+alt2"),
            action = ARC9:GetPhrase("hud.hint.lean")
        })
    end

    for i, v in ipairs(hints) do
        if ARC9.CTRL_Lookup[v.glyph] then v.glyph = ARC9.CTRL_Lookup[v.glyph] end
        if ARC9.CTRL_ConvertTo[v.glyph] then v.glyph = ARC9.CTRL_ConvertTo[v.glyph] end
        if ARC9.CTRL_Exists[v.glyph] then v.glyph = Material( "arc9/glyphs/" .. v.glyph .. ".png", "smooth" ) end
        if v.glyph2 then
            if ARC9.CTRL_Lookup[v.glyph2] then v.glyph2 = ARC9.CTRL_Lookup[v.glyph2] end
            if ARC9.CTRL_ConvertTo[v.glyph2] then v.glyph2 = ARC9.CTRL_ConvertTo[v.glyph2] end
            if ARC9.CTRL_Exists[v.glyph2] then v.glyph2 = Material( "arc9/glyphs/" .. v.glyph2 .. ".png", "smooth" ) end
        end
    end

    return hints
end

local arc9_hud_nohints = GetConVar("arc9_hud_nohints")
local arc9_hud_compact = GetConVar("arc9_hud_compact")
local deadzonex = GetConVar("arc9_hud_deadzonex")

local function DrawSimpleHints()
    if arc9_hud_nohints:GetBool() then return end

    local weapon = LocalPlayer():GetActiveWeapon()
    if !weapon.ARC9 then return end

    if !cl_drawhud:GetBool() then return end
    if weapon:GetCustomize() then return end

    local ct = CurTime()

    local capabilities = GetWeaponCapabilities(weapon)

    local CTRL = false

    local hints = GetHintsTable(capabilities)

    if lasthintcount != #hints and hidefadetime + 1.5 < ct then
        hidefadetime = ct
    end

    if weapon:GetInSights() and hidefadetime + 1.5 < ct then
        hidefadetime = ct
    end

    if first then
        hidefadetime = ct + 7
        first = false
    end

    lasthintcount = #hints

    local hx = 0
    local hy = 0
    local SIZE = ARC9ScreenScale(8)

    if hidefadetime + 1.5 > ct then
        hint_alpha = math.Approach(hint_alpha, 1, FrameTime() / 0.1)
    else
        hint_alpha = math.Approach(hint_alpha, 0, FrameTime() / 1)
    end
    if convar_keephints:GetBool() then hint_alpha = 1 end

    local hints_w = ARC9ScreenScale(100)
    local hints_h = ARC9ScreenScale(12) * table.Count(hints)

    hx = ARC9ScreenScale(10) + deadzonex:GetInt()
    hy = (ScrH() - hints_h) / 2

    surface.SetDrawColor(ARC9.GetHUDColor("shadow", 160 * hint_alpha))
    surface.SetMaterial(hud_sillyhints)
    surface.DrawTexturedRect(-ARC9ScreenScale(5) + deadzonex:GetInt(), hy-ARC9ScreenScale(7.5), hints_w, hints_h+ARC9ScreenScale(15))

    local off_x = ARC9ScreenScale(0.5)
    local off_y = ARC9ScreenScale(0.5)

    local txt_off_y = -ARC9ScreenScale(0.8)

    for _, hint in ipairs(hints) do
        local strreturn = 0
        surface.SetFont("ARC9_10")
        surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
        surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
        surface.SetTextPos(hx + off_x, hy + off_y)
        strreturn = CreateControllerKeyLine( {x = hx + off_x, y = hy + off_y, size = ARC9ScreenScale(9), font_keyb = "ARC9_10", font = "ARC9_10" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
        CreateControllerKeyLine( {x = hx + off_x + math.max(strreturn, ARC9ScreenScale(25)), y = hy + txt_off_y + off_y, size = ARC9ScreenScale(10), font_keyb = "ARC9_10", font = "ARC9_10" }, " " .. hint.action )


        surface.SetFont("ARC9_10")
        surface.SetDrawColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
        surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
        surface.SetTextPos(hx, hy)
        strreturn = CreateControllerKeyLine( {x = hx, y = hy, size = ARC9ScreenScale(9), font_keyb = "ARC9_10", font = "ARC9_10" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
        CreateControllerKeyLine( {x = hx + math.max(strreturn, ARC9ScreenScale(25)), y = hy + txt_off_y, size = ARC9ScreenScale(10), font_keyb = "ARC9_10", font = "ARC9_10" }, " " .. hint.action )

        hy = hy + ARC9ScreenScale(12)
    end
end

local deadzonex = GetConVar("arc9_hud_deadzonex")

function ARC9.DrawHUD()
    EyeAngles() -- This, for some ungodly reason, allows sway to work when the HUD is off.
    EyePos()

    if !ARC9.ShouldDrawHUD() then
        DrawSimpleHints()
        return
    end

    local localplayer = LocalPlayer()
    local weapon = localplayer:GetActiveWeapon()

    if !IsValid(weapon) then return end

    local ct = CurTime()

    if lastweapon != weapon then
        rackrisetime = ct
        lastrow = 0
        hidefadetime = ct
    end

    -- local weapon_printname = weapon:GetPrintName()
    local weapon_clipsize = weapon:GetMaxClip1()
    local weapon_clip = weapon:Clip1()
    local weapon_reserve = localplayer:GetAmmoCount(weapon:GetPrimaryAmmoType())

    local flash_period = 3

    local firemode_text = "AUTO"
    local firemode_pic = firemode_pics[-1]

    local chambered = math.max(weapon_clip - weapon_clipsize, 0)
    local clip_to_show = math.min(weapon_clip, weapon_clipsize)

    local inf_clip = false
    local inf_reserve = false
    local melee = false
    local jammed = false
    local showheat = false
    local heat = 0
    local heatcap = 100
    local heatlocked = false
    local multiple_modes = false

    if weapon_clipsize <= 0 then
        inf_clip = true
        clip_to_show = weapon_reserve
    end

    if weapon.ARC9 then
        if weapon:GetCustomize() then return end

        local arc9_mode = weapon:GetCurrentFiremodeTable()

        firemode_text = weapon:GetFiremodeName()

        if #weapon:GetValue("Firemodes") > 1 then
            multiple_modes = true
        end

        if weapon:GetProcessedValue("NoFiremodeWhenEmpty", true) and weapon:Clip1() <= 0 then
            multiple_modes = false
        end

        if weapon:GetUBGL() then
            arc9_mode = {
                Mode = weapon:GetCurrentFiremode(),
                PrintName = weapon:GetProcessedValue("UBGLFiremodeName", true)
            }
            firemode_text = arc9_mode.PrintName
            weapon_clipsize = weapon:GetMaxClip2()
            weapon_clip = weapon:Clip2()
            clip_to_show = weapon_clip
            weapon_reserve = localplayer:GetAmmoCount(weapon:GetSecondaryAmmoType())
            multiple_modes = false
        end

        if arc9_mode.Icon then
            firemode_pic = arc9_mode.Icon
        else
            if firemode_pics[arc9_mode.Mode] then
                firemode_pic = firemode_pics[arc9_mode.Mode]
            elseif arc9_mode.Mode < 0 then
                firemode_pic = firemode_pics[-1]
            else
                firemode_pic = firemode_pics[3]
            end
        end

        if weapon:GetSafe() then
            firemode_pic = firemode_pics[0]
        end

        if weapon:GetInfiniteAmmo() then
            inf_reserve = true
            weapon_reserve = 2147483640
        end

        if weapon:GetProcessedValue("BottomlessClip", true) then
            inf_clip = true
            weapon_reserve = weapon_reserve + weapon_clip
            clip_to_show = weapon_reserve
            weapon_clip = weapon_reserve
            weapon_clipsize = 1
            chambered = 0

            if inf_reserve then
                clip_to_show = 2147483640 - weapon:GetNthShot() % 2147483640
            end
        end

        if weapon:GetJammed() then
            jammed = true
        end

        if weapon:GetProcessedValue("Overheat", true) then
            showheat = true
            heat = weapon:GetHeatAmount()
            heatcap = weapon:GetProcessedValue("HeatCapacity", true)
            heatlocked = weapon:GetHeatLockout()
        end
    elseif weapon.ArcCW then
        local arccw_mode = weapon:GetCurrentFiremode()

        firemode_text = weapon:GetFiremodeName()
        -- there was a reason I kept it to 4 letters you assholes

        firemode_text = string.Replace(firemode_text, "-", "")
        firemode_text = string.Replace(firemode_text, " ", "")
        firemode_text = string.sub(firemode_text, 1, 4)
        firemode_text = string.upper(firemode_text)

        if arccw_mode.Mode > 1 then
            firemode_pic = firemode_pics[-1]
        elseif arccw_mode.Mode == 1 then
            firemode_pic = firemode_pics[1]
        elseif firemode_pics[-arccw_mode.Mode] then
            firemode_pic = firemode_pics[-arccw_mode.Mode]
        else
            firemode_pic = firemode_pics[3]
        end
    elseif weapon:IsScripted() then
        if !weapon.Primary.Automatic then
            firemode_pic = firemode_pics[1]
            firemode_text = ARC9:GetPhrase("hud.firemode.single")
        end

        if weapon.ThreeRoundBurst then
            firemode_pic = firemode_pics[3]
            firemode_text = "3-" .. ARC9:GetPhrase("hud.firemode.burst")
        end

        if weapon.TwoRoundBurst then
            firemode_pic = firemode_pics[2]
            firemode_text = "2-" .. ARC9:GetPhrase("hud.firemode.burst")
        end

        if weapon.GetSafe then
            if weapon:GetSafe() then
                firemode_pic = firemode_pics[0]
                firemode_text = ARC9:GetPhrase("hud.firemode.safe")
            end
        end

        if isfunction(weapon.Safe) then
            if weapon:Safe() then
                firemode_pic = firemode_pics[0]
                firemode_text = ARC9:GetPhrase("hud.firemode.safe")
            end
        end

        if isfunction(weapon.Safety) then
            if weapon:Safety() then
                firemode_pic = firemode_pics[0]
                firemode_text = ARC9:GetPhrase("hud.firemode.safe")
            end
        end
    else
        if !automatics[weapon:GetClass()] then
            firemode_pic = firemode_pics[1]
            firemode_text = ARC9:GetPhrase("hud.firemode.single")
        end
    end

    local flashammowidgets = false

    if (weapon_clip / weapon_clipsize) < 0.34 then
        flashammowidgets = true
        if weapon_clip == 0 then
            flashammowidgets = false
        end
    end

    if weapon_clipsize <= 0 and weapon:GetPrimaryAmmoType() == -1 then
        melee = true
        flashammowidgets = false
    end

    if inf_clip then
        weapon_clipsize = 30
    end

    if jammed then
        flashammowidgets = true
    end

    local flashheatbar = false

    if heatlocked then flashheatbar = true end

    local heat_col = ARC9.GetHUDColor("fg_3d", 200)

    if (flashheatbar and math.floor(ct * flash_period) % 2 == 0) then
        heat_col = ARC9.GetHUDColor("hi_3d", 200)
    end

    local am_col = ARC9.GetHUDColor("fg_3d", 255)

    if (flashammowidgets and math.floor(ct * flash_period) % 2 == 0) or (weapon_clip == 0 and !melee) then
        am_col = ARC9.GetHUDColor("hi_3d", 255)
    end

    local s_right = 2
    local s_down = 1

    -- cam.Start3D(Vector pos=EyePos(), Angle angles=EyeAngles(), number fov=nil, number x=0, number y=0, number w=ScrW(), number h=ScrH(), number zNear=nil, number zFar=nil)
    local anchorwidth = math.min(ScrW() / 2, ScrH() / 2)

    cam.Start3D(nil, nil, 55, deadzonex:GetInt(), ScrH() - anchorwidth, anchorwidth, anchorwidth)
    -- cam.Start3D(nil, nil, 105)

    local ang = EyeAngles()

    local up, right, forward = ang:Up(), ang:Right(), ang:Forward()

    -- local ang = EyeAngles()

    -- ang = ang + Angle(0, 180, 0)

    -- ang = -ang

    -- ang:RotateAroundAxis(up, 175)
    -- ang:RotateAroundAxis(right, 80)
    -- ang:RotateAroundAxis(forward, -90)

    ang:RotateAroundAxis(up, 180)
    ang:RotateAroundAxis(right, 105)
    ang:RotateAroundAxis(forward, -95)

    -- cam.Start3D2D(EyePos() + (forward * 8) + (up * -3.25) + (right * -10), ang2, 0.0125 )
    -- cam.End3D2D()

    -- local ratio = ScrW() / ScrH()

    local pos = EyePos() + (forward * 4) + (up * -0.25) + (right * -1.5)

    pos, ang = ARC9.HUDBob(pos, ang)
    pos, ang = ARC9.HUDSway(pos, ang)

    local compatc = arc9_hud_compact:GetBool()

    cam.Start3D2D(pos, ang, 0.0125)
        -- surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 20))
        -- surface.DrawRect( 8, 4, 254, 110 )

        if compatc then
            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
            surface.DrawRect( 0, 0, 254, 80 )

            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 100))
            surface.SetMaterial(hud_bg)
            surface.DrawTexturedRect(0, 0, 254, 80)

            surface.DrawLine(0, 85, 254, 85)

            surface.SetDrawColor(Color(0, 0, 0, 50))
            surface.SetMaterial(hud_logo_lowvis)
            surface.DrawTexturedRect((254 - 80) / 2, 0, 80, 80)
        else
            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
            surface.DrawRect( 0, 0, 254, 110 )

            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 100))
            surface.SetMaterial(hud_bg)
            surface.DrawTexturedRect(0, 0, 254, 110)

            surface.DrawLine(0, 115, 254, 115)

            surface.SetDrawColor(Color(0, 0, 0, 50))
            surface.SetMaterial(hud_logo_lowvis)
            surface.DrawTexturedRect((254 - 110) / 2, 0, 110, 110)
        end

        -- surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
        -- surface.DrawRect( 0, 0, 140, 70 )

        local deco_x = 6
        local deco_y = 2
        local deco = ARC9:GetPhrase("hud.version") .. ARC9.Version

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_Deco_8_Unscaled")
        surface.SetTextPos(deco_x + s_right, deco_y + s_down)
        surface.DrawText(deco)

        surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetFont("ARC9_Deco_8_Unscaled")
        surface.SetTextPos(deco_x, deco_y)
        surface.DrawText(deco)

        local health_x = 8
        local health_y = 9
        local health = math.Clamp(localplayer:Health() / localplayer:GetMaxHealth(), 0, 99.99)
        local overheal = localplayer:Health() > localplayer:GetMaxHealth() or localplayer:Armor() > 100

        local flashhealthwidgets = false

        if localplayer:Health() <= 10 then
            flashhealthwidgets = true
        end

        local hb_col = ARC9.GetHUDColor("fg_3d", 225)
        local hw_col = ARC9.GetHUDColor("fg_3d", 255)

        if (flashhealthwidgets and math.floor(ct * flash_period) % 2 == 0) then
            hw_col = ARC9.GetHUDColor("hi_3d", 255)
            hb_col = ARC9.GetHUDColor("hi_3d", 170)
        end

        local hb_left = 30
        local hb_tall = 24
        local hb_wide = 209

        if compatc and showheat then
            hb_wide = 140
        end

        if !overheal then
            if localplayer:Armor() > 0 then
                hb_tall = 18

                local armor = math.min(localplayer:Armor() / 100, 1)

                surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
                surface.DrawRect(hb_left + s_right, 32 + s_down, hb_wide * armor, 3)

                surface.SetDrawColor(hb_col)
                surface.DrawRect(hb_left, 32, hb_wide * armor, 3)
            end

            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            if health < 1 then
                surface.DrawLine(hb_wide + hb_left + s_right, 12 + s_down, hb_wide + hb_left + s_right, 12 + hb_tall + s_down)
            end
            surface.DrawRect(hb_left + s_right, 12 + s_down, hb_wide * health, hb_tall)

            surface.SetDrawColor(hb_col)
            if health < 1 then
                surface.DrawLine(hb_wide + hb_left, 12, hb_wide + hb_left, 12 + hb_tall)
            end
            surface.DrawRect(hb_left, 12, hb_wide * health, hb_tall)
        end

        local healthtext = "♥"

        if overheal then
            healthtext = "♥:" .. tostring(math.ceil(health * 100)) .. "%"
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_LCD")
        surface.SetTextPos(health_x + s_right, health_y + s_down)
        surface.DrawText(healthtext)

        surface.SetTextColor(hw_col)
        surface.SetFont("ARC9_24_LCD")
        surface.SetTextPos(health_x, health_y)
        surface.DrawText(healthtext)

        if overheal then
            local armor_x = 250
            local armor_y = 9
            local armor = math.Round((localplayer:Armor() / 100) * 100)
            armor = "⌂:" .. tostring(math.ceil(armor)) .. "%"

            surface.SetFont("ARC9_24_LCD")
            armor_x = armor_x - surface.GetTextSize(armor)

            surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetFont("ARC9_24_LCD")
            surface.SetTextPos(armor_x + s_right, armor_y + s_down)
            surface.DrawText(armor)

            surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetFont("ARC9_24_LCD")
            surface.SetTextPos(armor_x, armor_y)
            surface.DrawText(armor)
        end

        -- local title_x = 8
        -- local title_y = 2

        -- surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        -- surface.SetFont("ARC9_24_Unscaled")
        -- surface.SetTextPos(title_x + s_right, title_y + s_down)
        -- surface.DrawText(weapon_printname)

        -- surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        -- surface.SetFont("ARC9_24_Unscaled")
        -- surface.SetTextPos(title_x, title_y)
        -- surface.DrawText(weapon_printname)

        if showheat then
            local therm_x = 174
            local therm_y = 66
            local therm_w = 70
            local therm_h = 35

            local therm_deco_x = 190
            local therm_deco_y = 97
            local therm_deco = ARC9:GetPhrase("hud.therm_deco")

            if compatc then
                therm_x = 174
                therm_y = 6
                therm_w = 70
                therm_h = 35

                therm_deco_x = 190
                therm_deco_y = 5
            end

            surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetFont("ARC9_Deco_8_Unscaled")
            surface.SetTextPos(therm_deco_x + s_right, therm_deco_y + s_down)
            surface.DrawText(therm_deco)

            surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetFont("ARC9_Deco_8_Unscaled")
            surface.SetTextPos(therm_deco_x, therm_deco_y)
            surface.DrawText(therm_deco)

            local fill = math.Clamp(0.05 + (0.9 * heat) / heatcap, 0, 1)

            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetMaterial(hud_t_full)
            surface.DrawTexturedRectUV(therm_x + s_right, therm_y + s_down, math.ceil(therm_w * fill), therm_h, 0, 0, fill, 1)
            -- surface.DrawTexturedRect(therm_x + s_right, therm_y + s_down, therm_s, therm_s)

            surface.SetDrawColor(heat_col)
            surface.SetMaterial(hud_t_full)
            surface.DrawTexturedRectUV(therm_x, therm_y, math.ceil(therm_w * fill), therm_h, 0, 0,  fill, 1)

            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetMaterial(hud_t_empty)
            surface.DrawTexturedRectUV(therm_x + math.ceil(therm_w * fill) + s_right, therm_y + s_down, therm_w * (1 - fill), therm_h, fill, 0, 1, 1)
            -- surface.DrawTexturedRect(therm_x + s_right, therm_y + s_down, therm_s, therm_s)

            surface.SetDrawColor(heat_col)
            surface.SetMaterial(hud_t_empty)
            surface.DrawTexturedRectUV(therm_x + math.ceil(therm_w * fill), therm_y, therm_w * (1 - fill), therm_h, fill, 0, 1, 1)
            -- surface.DrawTexturedRect(therm_x, therm_y, therm_s, therm_s)
        end

        local ammo_x = 8
        local ammo_y = 40
        local ammo_text = tostring(weapon_clip)

        if inf_reserve then
            ammo_text = ammo_text .. "/∞"
            if inf_clip then
                ammo_text = "∞"
            end
        else
            ammo_text = ammo_text .. "/" .. tostring(weapon_reserve)
            if inf_clip then
                ammo_text = tostring(weapon_reserve)
            end
        end

        if melee then
            ammo_text = "-"
        end

        if jammed then
            ammo_text = ARC9:GetPhrase("hud.jammed")
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_LCD")
        surface.SetTextPos(ammo_x + s_right, ammo_y + s_down)
        surface.DrawText(ammo_text)

        surface.SetTextColor(am_col)
        surface.SetFont("ARC9_24_LCD")
        surface.SetTextPos(ammo_x, ammo_y)
        surface.DrawText(ammo_text)

        local fmi_x = 215
        local fmi_y = 38
        local fmi_s = 30

        surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetMaterial(firemode_pic)
        surface.DrawTexturedRect(fmi_x + s_right, fmi_y + s_down, fmi_s, fmi_s)

        surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetMaterial(firemode_pic)
        surface.DrawTexturedRect(fmi_x, fmi_y, fmi_s, fmi_s)

        local fmm_text = firemode_text
        local fmm_x = 212
        local fmm_y = 39

        if !multiple_modes then
            fmm_y = 45
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_12_Unscaled")
        local fmm_w = surface.GetTextSize(fmm_text)
        surface.SetTextPos(fmm_x + s_right - fmm_w, fmm_y + s_down)
        surface.DrawText(fmm_text)

        surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetFont("ARC9_12_Unscaled")
        surface.SetTextPos(fmm_x - fmm_w, fmm_y)
        surface.DrawText(fmm_text)

        if multiple_modes then
            local fmh_text = ARC9.GetBindKey("+zoom")--"[" .. ARC9.GetBindKey("+zoom") .. "]"
            local fmh_x = 212
            local fmh_y = 53

            if ARC9.CTRL_Lookup[fmh_text] then fmh_text = ARC9.CTRL_Lookup[fmh_text] end
            if ARC9.CTRL_ConvertTo[fmh_text] then fmh_text = ARC9.CTRL_ConvertTo[fmh_text] end
            if ARC9.CTRL_Exists[fmh_text] then fmh_text = Material( "arc9/glyphs/" .. fmh_text .. ".png", "smooth" ) else fmh_text = "["..fmh_text.."]" end
            fmh_text = isstring(fmh_text) and fmh_text or { fmh_text, 16 }

            surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
            surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
            surface.SetFont("ARC9_12_LCD")
            local fmh_w = GetControllerKeyLineSize( { font = "ARC9_12_LCD" }, fmh_text )
            CreateControllerKeyLine( { x = fmh_x + s_right - fmh_w, y = fmh_y + s_down, size = 16, font = "ARC9_12_LCD" }, fmh_text )

            surface.SetDrawColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
            surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
            surface.SetFont("ARC9_12_LCD")
            CreateControllerKeyLine( { x = fmh_x - fmh_w, y = fmh_y, size = 16, font = "ARC9_12_LCD" }, fmh_text )
        end

        if !compatc then
            -- bullet fields

            local b_alpha = 225

            local b_m_left = -8
            local b_m_down = 72
            local b_m_margin = 2

            local row_size = 15

            if showheat then
                row_size = 10
            end

            local row1_bullets = 0
            local row2_bullets = 0
            local rackrise = 0

            local disparity = weapon_clipsize % row_size

            local corrected = clip_to_show - disparity

            local row = math.ceil(corrected / row_size)

            local sb = 14

            local crc = clip_to_show

            if disparity > 0 then
                crc = clip_to_show + row_size - disparity
            end

            if crc > row_size then
                row2_bullets = math.min(row_size, clip_to_show + disparity)
                row1_bullets = (corrected % row_size)

                if row1_bullets == 0 then
                    row1_bullets = row_size
                end

                if clip_to_show <= row_size + disparity then
                    row2_bullets = disparity
                end

                if row < lastrow then
                    rackrisetime = ct
                end

                lastrow = row
            else
                row2_bullets = clip_to_show
            end

            if rackrisetime + 0.2 > ct then
                local rackrisedelta = ((rackrisetime + 0.2) - ct) / 0.2
                rackrise = rackrisedelta * (sb + b_m_margin)
            end

            for i = 1, row1_bullets do
                surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
                surface.DrawRect(b_m_left + ((sb + b_m_margin) * i) + s_right, b_m_down + rackrise + s_down, sb, sb)

                if row1_bullets - i < chambered then
                    surface.SetDrawColor(ARC9.GetHUDColor("hi_3d", b_alpha))
                else
                    surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", b_alpha))
                end
                surface.DrawRect(b_m_left + ((sb + b_m_margin) * i), b_m_down + rackrise, sb, sb)
            end

            for i = 1, row2_bullets do
                surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
                surface.DrawRect(b_m_left + ((sb + b_m_margin) * i) + s_right, b_m_down + sb + b_m_margin + rackrise + s_down, sb, sb)

                if row2_bullets - i < chambered - row1_bullets then
                    surface.SetDrawColor(ARC9.GetHUDColor("hi_3d", b_alpha))
                else
                    surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", b_alpha))
                end
                surface.DrawRect(b_m_left + ((sb + b_m_margin) * i), b_m_down + sb + b_m_margin + rackrise, sb, sb)
            end
        end

    cam.End3D2D()

    if weapon.ARC9 and !arc9_hud_nohints:GetBool() then
        local capabilities = GetWeaponCapabilities(weapon)

        -- local hints = {
        --     {
        --         {"E", "R"},
        --         "Inspect"
        --     },
        --     {
        --         {"E", "M2"},
        --         "Toggle Alt-Weapon"
        --     },
        --     {
        --         {"E", "M1"},
        --         "Bash"
        --     },
        --     {
        --         {"B"},
        --         "Switch Firemode"
        --     },
        -- }

        local hints = GetHintsTable(capabilities)

        if lasthintcount != #hints and hidefadetime + 1.5 < ct then
            hidefadetime = ct
        end

        if weapon:GetInSights() and hidefadetime + 1.5 < ct then
            hidefadetime = ct
        end

        if first then
            hidefadetime = ct + 10
            first = false
        end

        lasthintcount = #hints

        local hx = 0
        local hy = 0
        local SIZE = 16

        if hidefadetime + 1.5 > ct then
            hint_alpha = math.Approach(hint_alpha, 1, FrameTime() / 0.1)
        else
            hint_alpha = math.Approach(hint_alpha, 0, FrameTime() / 1)
        end
        if convar_keephints:GetBool() then hint_alpha = 1 end

        cam.Start3D2D(pos - (ang:Right() * ((16 * #hints * 0.0125) + 0.25)), ang, 0.0125)
            surface.SetDrawColor(ARC9.GetHUDColor("shadow", 150 * hint_alpha))
            surface.SetMaterial(hud_bigblur)
            surface.DrawTexturedRect(-32, 0, 300, 20 * #hints)

            for _, hint in ipairs(hints) do
                local strreturn = 0
                surface.SetFont("ARC9_16_Unscaled")
                surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
                surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
                surface.SetTextPos(hx + 4, hy + 2)
                strreturn = CreateControllerKeyLine( {x = hx + 2, y = hy + 1, size = 16, font = "ARC9_16_Unscaled" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
                CreateControllerKeyLine( {x = hx + 4 + math.max(strreturn, 48), y = hy + 2, size = 16, font = "ARC9_16_Unscaled" }, " " .. hint.action )


                surface.SetFont("ARC9_16_Unscaled")
                surface.SetDrawColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
                surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
                surface.SetTextPos(hx, hy)
                strreturn = CreateControllerKeyLine( {x = hx, y = hy, size = 16, font = "ARC9_16_Unscaled" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
                CreateControllerKeyLine( {x = hx + math.max(strreturn, 48), y = hy, size = 16, font = "ARC9_16_Unscaled" }, " " .. hint.action )

                hy = hy + 19
            end
        cam.End3D2D()
    end

    cam.End3D()

    lastweapon = weapon
end

hook.Add("HUDPaint", "ARC9_DrawHud", ARC9.DrawHUD)



-- Controller / key additions by Fesiug. Blame Fesiug!

local convar_controllermode = GetConVar("arc9_controller")
function ARC9.ControllerMode()
    return convar_controllermode:GetBool()
end

ARC9.CTRL_Set_Xbox = {}
ARC9.CTRL_Set_UserCustom = {}

ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox -- {}

function ARC9.DarkButtons()
	local darkbuttons = "light"
	
	if GetConVar("arc9_hud_darkmode"):GetFloat() == 1 then
		darkbuttons = "dark"
	end
	
	return darkbuttons
end

ARC9.CTRL_Lookup = {
    MOUSE1 = "mouse_left_key_" .. ARC9.DarkButtons(),
    MOUSE2 = "mouse_right_key_" .. ARC9.DarkButtons(),
    MOUSE3 = "mouse_middle_key_" .. ARC9.DarkButtons(),
    MOUSE4 = "legacy/" .. ARC9.DarkButtons() .. "/shared_mouse_4_lg",
    MOUSE5 = "legacy/" .. ARC9.DarkButtons() .. "/shared_mouse_5_lg",

    MWHEELUP = "legacy/" .. ARC9.DarkButtons() .. "/shared_mouse_scroll_up_lg",
    MWHEELDOWN = "legacy/" .. ARC9.DarkButtons() .. "/shared_mouse_scroll_down_lg",

    KP_INS = "KP 0",
    KP_END = "KP 1",
    KP_DOWNARROW  = "KP 2",
    KP_PGDN       = "KP 3",
    KP_LEFTARROW  = "KP 4",
    KP_5   = "KP 5",
    KP_RIGHTARROW = "KP 6",
    KP_HOME       = "KP 7",
    KP_UPARROW    = "KP 8",
    KP_PGUP       = "KP 9",
    KP_SLASH      = "KP /",
    KP_MULTIPLY   = "KP *",
    KP_MINUS      = "KP -",
    KP_PLUS       = "KP +",
    KP_ENTER      = "KP ENTER",
    KP_DEL = "KP .",

	A = "a_key_" .. ARC9.DarkButtons(),
	B = "b_key_" .. ARC9.DarkButtons(),
	C = "c_key_" .. ARC9.DarkButtons(),
	D = "d_key_" .. ARC9.DarkButtons(),
	E = "e_key_" .. ARC9.DarkButtons(),
	F = "f_key_" .. ARC9.DarkButtons(),
	G = "g_key_" .. ARC9.DarkButtons(),
	H = "h_key_" .. ARC9.DarkButtons(),
	I = "i_key_" .. ARC9.DarkButtons(),
	J = "j_key_" .. ARC9.DarkButtons(),
	K = "k_key_" .. ARC9.DarkButtons(),
	L = "l_key_" .. ARC9.DarkButtons(),
	M = "m_key_" .. ARC9.DarkButtons(),
	N = "n_key_" .. ARC9.DarkButtons(),
	O = "o_key_" .. ARC9.DarkButtons(),
	P = "p_key_" .. ARC9.DarkButtons(),
	Q = "q_key_" .. ARC9.DarkButtons(),
	R = "r_key_" .. ARC9.DarkButtons(),
	S = "s_key_" .. ARC9.DarkButtons(),
	T = "t_key_" .. ARC9.DarkButtons(),
	U = "u_key_" .. ARC9.DarkButtons(),
	V = "v_key_" .. ARC9.DarkButtons(),
	W = "w_key_" .. ARC9.DarkButtons(),
	X = "x_key_" .. ARC9.DarkButtons(),
	Y = "y_key_" .. ARC9.DarkButtons(),
	Z = "z_key_" .. ARC9.DarkButtons(),
	
	["0"] = "0_key_" .. ARC9.DarkButtons(),
	["1"] = "1_key_" .. ARC9.DarkButtons(),
	["2"] = "2_key_" .. ARC9.DarkButtons(),
	["3"] = "3_key_" .. ARC9.DarkButtons(),
	["4"] = "4_key_" .. ARC9.DarkButtons(),
	["5"] = "5_key_" .. ARC9.DarkButtons(),
	["6"] = "6_key_" .. ARC9.DarkButtons(),
	["7"] = "7_key_" .. ARC9.DarkButtons(),
	["8"] = "8_key_" .. ARC9.DarkButtons(),
	["9"] = "9_key_" .. ARC9.DarkButtons(),
	
	SHIFT = "shift_key_" .. ARC9.DarkButtons(),
	TAB = "tab_key_" .. ARC9.DarkButtons(),
	SPACE = "space_key_" .. ARC9.DarkButtons(),
	ENTER = "enter_key_" .. ARC9.DarkButtons(),
	ALT = "alt_key_" .. ARC9.DarkButtons(),
	BACKSPACE = "backspace_key_" .. ARC9.DarkButtons(),
	CTRL = "ctrl_key_" .. ARC9.DarkButtons(),
}

ARC9.CTRL_Exists = {
    ["0_key_dark"] = true,
    ["0_key_light"] = true,
    ["10_key_dark"] = true,
    ["10_key_light"] = true,
    ["11_key_dark"] = true,
    ["11_key_light"] = true,
    ["12_key_dark"] = true,
    ["12_key_light"] = true,
    ["1_key_dark"] = true,
    ["1_key_light"] = true,
    ["2_key_dark"] = true,
    ["2_key_light"] = true,
    ["360_a"] = true,
    ["360_b"] = true,
    ["360_back"] = true,
    ["360_back_alt"] = true,
    ["360_dpad"] = true,
    ["360_dpad_down"] = true,
    ["360_dpad_left"] = true,
    ["360_dpad_right"] = true,
    ["360_dpad_up"] = true,
    ["360_lb"] = true,
    ["360_left_stick"] = true,
    ["360_left_stick_click"] = true,
    ["360_lt"] = true,
    ["360_rb"] = true,
    ["360_right_stick"] = true,
    ["360_right_stick_click"] = true,
    ["360_rt"] = true,
    ["360_start"] = true,
    ["360_start_alt"] = true,
    ["360_x"] = true,
    ["360_y"] = true,
    ["3_key_dark"] = true,
    ["3_key_light"] = true,
    ["4_key_dark"] = true,
    ["4_key_light"] = true,
    ["5_key_dark"] = true,
    ["5_key_light"] = true,
    ["6_key_dark"] = true,
    ["6_key_light"] = true,
    ["7_key_dark"] = true,
    ["7_key_light"] = true,
    ["8_key_dark"] = true,
    ["8_key_light"] = true,
    ["9_key_dark"] = true,
    ["9_key_light"] = true,
    alt_key_dark = true,
    alt_key_light = true,
    arrow_down_key_dark = true,
    arrow_down_key_light = true,
    arrow_left_key_dark = true,
    arrow_left_key_light = true,
    arrow_right_key_dark = true,
    arrow_right_key_light = true,
    arrow_up_key_dark = true,
    arrow_up_key_light = true,
    asterisk_key_dark = true,
    asterisk_key_light = true,
    a_key_dark = true,
    a_key_light = true,
    backspace_alt_key_dark = true,
    backspace_alt_key_light = true,
    backspace_key_dark = true,
    backspace_key_light = true,
    blank_black_enter = true,
    blank_black_mouse = true,
    blank_black_normal = true,
    blank_black_super_wide = true,
    blank_black_tall = true,
    blank_black_wide = true,
    blank_white_enter = true,
    blank_white_mouse = true,
    blank_white_normal = true,
    blank_white_super_wide = true,
    blank_white_tall = true,
    blank_white_wide = true,
    bracket_left_key_dark = true,
    bracket_left_key_light = true,
    bracket_right_key_dark = true,
    bracket_right_key_light = true,
    b_key_dark = true,
    b_key_light = true,
    caps_lock_key_dark = true,
    caps_lock_key_light = true,
    command_key_dark = true,
    command_key_light = true,
    controller_disconnected = true,
    ctrl_key_dark = true,
    ctrl_key_light = true,
    c_key_dark = true,
    c_key_light = true,
    del_key_dark = true,
    del_key_light = true,
    d_key_dark = true,
    d_key_light = true,
    end_key_dark = true,
    end_key_light = true,
    enter_alt_key_dark = true,
    enter_alt_key_light = true,
    enter_key_dark = true,
    enter_key_light = true,
    enter_tall_key_dark = true,
    enter_tall_key_light = true,
    esc_key_dark = true,
    esc_key_light = true,
    e_key_dark = true,
    e_key_dark2 = true,
    e_key_light = true,
    f10_key_dark = true,
    f10_key_light = true,
    f11_key_dark = true,
    f11_key_light = true,
    f12_key_dark = true,
    f12_key_light = true,
    f1_key_dark = true,
    f1_key_light = true,
    f2_key_dark = true,
    f2_key_light = true,
    f3_key_dark = true,
    f3_key_light = true,
    f4_key_dark = true,
    f4_key_light = true,
    f5_key_dark = true,
    f5_key_light = true,
    f6_key_dark = true,
    f6_key_light = true,
    f7_key_dark = true,
    f7_key_light = true,
    f8_key_dark = true,
    f8_key_light = true,
    f9_key_dark = true,
    f9_key_light = true,
    f_key_dark = true,
    f_key_light = true,
    g_key_dark = true,
    g_key_light = true,
    home_key_dark = true,
    home_key_light = true,
    h_key_dark = true,
    h_key_light = true,
    insert_key_dark = true,
    insert_key_light = true,
    i_key_dark = true,
    i_key_light = true,
    j_key_dark = true,
    j_key_light = true,
    k_key_dark = true,
    k_key_light = true,
    luna_a = true,
    luna_b = true,
    luna_circle = true,
    luna_dpad = true,
    luna_dpad_down = true,
    luna_dpad_left = true,
    luna_dpad_right = true,
    luna_dpad_up = true,
    luna_lb = true,
    luna_left_stick = true,
    luna_left_stick_click = true,
    luna_lt = true,
    luna_menu = true,
    luna_microphone = true,
    luna_rb = true,
    luna_right_stick = true,
    luna_right_stick_click = true,
    luna_rt = true,
    luna_x = true,
    luna_y = true,
    l_key_dark = true,
    l_key_light = true,
    mark_left_key_dark = true,
    mark_left_key_light = true,
    mark_right_key_dark = true,
    mark_right_key_light = true,
    minus_key_dark = true,
    minus_key_light = true,
    mouse_left_key_dark = true,
    mouse_left_key_light = true,
    mouse_middle_key_dark = true,
    mouse_middle_key_light = true,
    mouse_right_key_dark = true,
    mouse_right_key_light = true,
    mouse_simple_key_dark = true,
    mouse_simple_key_light = true,
    m_key_dark = true,
    m_key_light = true,
    num_lock_key_dark = true,
    num_lock_key_light = true,
    n_key_dark = true,
    n_key_light = true,
    oculus_a = true,
    oculus_b = true,
    oculus_grab_blank = true,
    oculus_left_grab = true,
    oculus_left_stick = true,
    oculus_lt = true,
    oculus_right_grab = true,
    oculus_right_stick = true,
    oculus_rt = true,
    oculus_touch_left = true,
    oculus_touch_right = true,
    oculus_trigger_blank = true,
    oculus_x = true,
    oculus_y = true,
    ouya_a = true,
    ouya_dpad = true,
    ouya_dpad_down = true,
    ouya_dpad_left = true,
    ouya_dpad_right = true,
    ouya_dpad_up = true,
    ouya_l1 = true,
    ouya_l2 = true,
    ouya_left_stick = true,
    ouya_menu = true,
    ouya_o = true,
    ouya_r1 = true,
    ouya_r2 = true,
    ouya_right_stick = true,
    ouya_touch = true,
    ouya_u = true,
    ouya_y = true,
    o_key_dark = true,
    o_key_light = true,
    page_down_key_dark = true,
    page_down_key_light = true,
    page_up_key_dark = true,
    page_up_key_light = true,
    plus_key_dark = true,
    plus_key_light = true,
    plus_tall_key_dark = true,
    plus_tall_key_light = true,
    positional_prompts_down = true,
    positional_prompts_left = true,
    positional_prompts_right = true,
    positional_prompts_up = true,
    print_screen_key_dark = true,
    print_screen_key_light = true,
    ps3_circle = true,
    ps3_cross = true,
    ps3_dpad = true,
    ps3_dpad_down = true,
    ps3_dpad_left = true,
    ps3_dpad_right = true,
    ps3_dpad_up = true,
    ps3_l1 = true,
    ps3_l2 = true,
    ps3_left_stick = true,
    ps3_left_stick_click = true,
    ps3_r1 = true,
    ps3_r2 = true,
    ps3_right_stick = true,
    ps3_right_stick_click = true,
    ps3_select = true,
    ps3_square = true,
    ps3_start = true,
    ps3_triangle = true,
    ps4_circle = true,
    ps4_cross = true,
    ps4_dpad = true,
    ps4_dpad_down = true,
    ps4_dpad_left = true,
    ps4_dpad_right = true,
    ps4_dpad_up = true,
    ps4_l1 = true,
    ps4_l2 = true,
    ps4_left_stick = true,
    ps4_left_stick_click = true,
    ps4_options = true,
    ps4_r1 = true,
    ps4_r2 = true,
    ps4_right_stick = true,
    ps4_right_stick_click = true,
    ps4_share = true,
    ps4_square = true,
    ps4_touch_pad = true,
    ps4_triangle = true,
    ps5_circle = true,
    ps5_cross = true,
    ps5_dpad = true,
    ps5_dpad_down = true,
    ps5_dpad_left = true,
    ps5_dpad_right = true,
    ps5_dpad_up = true,
    ps5_l1 = true,
    ps5_l2 = true,
    ps5_left_stick = true,
    ps5_left_stick_click = true,
    ps5_microphone = true,
    ps5_options = true,
    ps5_options_alt = true,
    ps5_r1 = true,
    ps5_r2 = true,
    ps5_right_stick = true,
    ps5_right_stick_click = true,
    ps5_share = true,
    ps5_share_alt = true,
    ps5_square = true,
    ps5_touch_pad = true,
    ps5_triangle = true,
    psmove_circle = true,
    psmove_controllers = true,
    psmove_controller_stick = true,
    psmove_controller_wand = true,
    psmove_cross = true,
    psmove_left_stick = true,
    psmove_lt = true,
    psmove_move = true,
    psmove_rt = true,
    psmove_select = true,
    psmove_square = true,
    psmove_start = true,
    psmove_t = true,
    psmove_triangle = true,
    psmove_trigger_blank = true,
    p_key_dark = true,
    p_key_light = true,
    question_key_dark = true,
    question_key_light = true,
    quote_key_dark = true,
    quote_key_light = true,
    q_key_dark = true,
    q_key_light = true,
    remote_back = true,
    remote_circle = true,
    remote_circle_down = true,
    remote_circle_inner = true,
    remote_circle_left = true,
    remote_circle_outter = true,
    remote_circle_right = true,
    remote_circle_scroll_left = true,
    remote_circle_scroll_right = true,
    remote_circle_up = true,
    remote_icon = true,
    remote_minus = true,
    remote_plus = true,
    remote_system = true,
    r_key_dark = true,
    r_key_light = true,
    semicolon_key_dark = true,
    semicolon_key_light = true,
    shift_alt_key_dark = true,
    shift_alt_key_light = true,
    shift_key_dark = true,
    shift_key_light = true,
    slash_key_dark = true,
    slash_key_light = true,
    space_key_dark = true,
    space_key_light = true,
    stadia_a = true,
    stadia_assistant = true,
    stadia_b = true,
    stadia_dots = true,
    stadia_dpad = true,
    stadia_dpad_down = true,
    stadia_dpad_left = true,
    stadia_dpad_right = true,
    stadia_dpad_up = true,
    stadia_l1 = true,
    stadia_l2 = true,
    stadia_left_stick = true,
    stadia_menu = true,
    stadia_r1 = true,
    stadia_r2 = true,
    stadia_right_stick = true,
    stadia_select = true,
    stadia_x = true,
    stadia_y = true,
    steamdeck_a = true,
    steamdeck_b = true,
    steamdeck_dots = true,
    steamdeck_dpad = true,
    steamdeck_dpad_down = true,
    steamdeck_dpad_left = true,
    steamdeck_dpad_right = true,
    steamdeck_dpad_up = true,
    steamdeck_gyro = true,
    steamdeck_l1 = true,
    steamdeck_l2 = true,
    steamdeck_l4 = true,
    steamdeck_l5 = true,
    steamdeck_left_stick = true,
    steamdeck_left_stick_click = true,
    steamdeck_left_track = true,
    steamdeck_menu = true,
    steamdeck_minus = true,
    steamdeck_plus = true,
    steamdeck_power = true,
    steamdeck_r1 = true,
    steamdeck_r2 = true,
    steamdeck_r4 = true,
    steamdeck_r5 = true,
    steamdeck_right_stick = true,
    steamdeck_right_stick_click = true,
    steamdeck_right_track = true,
    steamdeck_square = true,
    steamdeck_steam = true,
    steamdeck_x = true,
    steamdeck_y = true,
    steam_a = true,
    steam_b = true,
    steam_back = true,
    steam_gyro = true,
    steam_lb = true,
    steam_left_grip = true,
    steam_left_track = true,
    steam_left_track_center = true,
    steam_left_track_down = true,
    steam_left_track_left = true,
    steam_left_track_right = true,
    steam_left_track_up = true,
    steam_lt = true,
    steam_rb = true,
    steam_right_grip = true,
    steam_right_track = true,
    steam_right_track_center = true,
    steam_right_track_down = true,
    steam_right_track_left = true,
    steam_right_track_right = true,
    steam_right_track_up = true,
    steam_rt = true,
    steam_start = true,
    steam_stick = true,
    steam_system = true,
    steam_tilt_pitch = true,
    steam_tilt_roll = true,
    steam_tilt_yaw = true,
    steam_x = true,
    steam_y = true,
    switch_a = true,
    switch_b = true,
    switch_down = true,
    switch_dpad = true,
    switch_dpad_down = true,
    switch_dpad_left = true,
    switch_dpad_right = true,
    switch_dpad_up = true,
    switch_home = true,
    switch_lb = true,
    switch_left = true,
    switch_left_stick = true,
    switch_lt = true,
    switch_minus = true,
    switch_plus = true,
    switch_rb = true,
    switch_right = true,
    switch_right_stick = true,
    switch_rt = true,
    switch_square = true,
    switch_up = true,
    switch_x = true,
    switch_y = true,
    s_key_dark = true,
    s_key_light = true,
    tab_key_dark = true,
    tab_key_light = true,
    tilda_key_dark = true,
    tilda_key_light = true,
    t_key_dark = true,
    t_key_light = true,
    u_key_dark = true,
    u_key_light = true,
    vita_bumper_right = true,
    vita_bumpter_left = true,
    vita_circle = true,
    vita_cross = true,
    vita_dpad = true,
    vita_dpad_down = true,
    vita_dpad_left = true,
    vita_dpad_right = true,
    vita_dpad_up = true,
    vita_left_stick = true,
    vita_minus = true,
    vita_plus = true,
    vita_power = true,
    vita_right_stick = true,
    vita_select = true,
    vita_square = true,
    vita_start = true,
    vita_touch_pad = true,
    vita_triangle = true,
    vive_controllers = true,
    vive_controller_left = true,
    vive_controller_right = true,
    vive_girp_left = true,
    vive_grip_right = true,
    vive_hand_left = true,
    vive_hand_right = true,
    vive_hold_left = true,
    vive_hold_right = true,
    vive_lt = true,
    vive_menu = true,
    vive_rt = true,
    vive_system = true,
    vive_touch = true,
    vive_touch_center = true,
    vive_touch_down = true,
    vive_touch_left = true,
    vive_touch_right = true,
    vive_touch_scroll_left = true,
    vive_touch_scroll_right = true,
    vive_touch_up = true,
    vive_triggerblank = true,
    v_key_dark = true,
    v_key_light = true,
    wiiu_1 = true,
    wiiu_2 = true,
    wiiu_a = true,
    wiiu_b = true,
    wiiu_dpad = true,
    wiiu_dpad_down = true,
    wiiu_dpad_left = true,
    wiiu_dpad_right = true,
    wiiu_dpad_up = true,
    wiiu_home = true,
    wiiu_l = true,
    wiiu_left_stick = true,
    wiiu_look_down = true,
    wiiu_look_up = true,
    wiiu_minus = true,
    wiiu_plus = true,
    wiiu_power = true,
    wiiu_r = true,
    wiiu_right_stick = true,
    wiiu_tv = true,
    wiiu_x = true,
    wiiu_y = true,
    wiiu_zl = true,
    wiiu_zr = true,
    wii_1 = true,
    wii_2 = true,
    wii_a = true,
    wii_b = true,
    wii_c = true,
    wii_dpad = true,
    wii_dpad_down = true,
    wii_dpad_left = true,
    wii_dpad_right = true,
    wii_dpad_up = true,
    wii_home = true,
    wii_minus = true,
    wii_plus = true,
    wii_power = true,
    wii_stick = true,
    wii_z = true,
    win_key_dark = true,
    win_key_light = true,
    w_key_dark = true,
    w_key_light = true,
    xboxone_a = true,
    xboxone_b = true,
    xboxone_dpad = true,
    xboxone_dpad_down = true,
    xboxone_dpad_left = true,
    xboxone_dpad_right = true,
    xboxone_dpad_up = true,
    xboxone_lb = true,
    xboxone_left_stick = true,
    xboxone_left_stick_click = true,
    xboxone_lt = true,
    xboxone_menu = true,
    xboxone_rb = true,
    xboxone_right_stick = true,
    xboxone_right_stick_click = true,
    xboxone_rt = true,
    xboxone_windows = true,
    xboxone_x = true,
    xboxone_y = true,
    xboxseriesx_a = true,
    xboxseriesx_b = true,
    xboxseriesx_dpad = true,
    xboxseriesx_dpad_down = true,
    xboxseriesx_dpad_left = true,
    xboxseriesx_dpad_right = true,
    xboxseriesx_dpad_up = true,
    xboxseriesx_lb = true,
    xboxseriesx_left_stick = true,
    xboxseriesx_left_stick_click = true,
    xboxseriesx_lt = true,
    xboxseriesx_menu = true,
    xboxseriesx_rb = true,
    xboxseriesx_right_stick = true,
    xboxseriesx_right_stick_click = true,
    xboxseriesx_rt = true,
    xboxseriesx_share = true,
    xboxseriesx_view = true,
    xboxseriesx_x = true,
    xboxseriesx_y = true,
    x_key_dark = true,
    x_key_light = true,
    y_key_dark = true,
    y_key_light = true,
    z_key_dark = true,
    z_key_light = true,
	
 -- Legacy, Dark
	["legacy/dark/shared_mouse_4_lg"] = true,
	["legacy/dark/shared_mouse_5_lg"] = true,
	["legacy/dark/shared_mouse_l_click_lg"] = true,
	["legacy/dark/shared_mouse_mid_click_lg"] = true,
	["legacy/dark/shared_mouse_r_click_lg"] = true,
	["legacy/dark/shared_mouse_scroll_down_lg"] = true,
	["legacy/dark/shared_mouse_scroll_up_lg"] = true,
	
 -- Legacy, Knockout
	["legacy/knockout/shared_mouse_4_lg"] = true,
	["legacy/knockout/shared_mouse_5_lg"] = true,
	["legacy/knockout/shared_mouse_l_click_lg"] = true,
	["legacy/knockout/shared_mouse_mid_click_lg"] = true,
	["legacy/knockout/shared_mouse_r_click_lg"] = true,
	["legacy/knockout/shared_mouse_scroll_down_lg"] = true,
	["legacy/knockout/shared_mouse_scroll_up_lg"] = true,

 -- Legacy, Light
	["legacy/light/shared_mouse_4_lg"] = true,
	["legacy/light/shared_mouse_5_lg"] = true,
	["legacy/light/shared_mouse_l_click_lg"] = true,
	["legacy/light/shared_mouse_mid_click_lg"] = true,
	["legacy/light/shared_mouse_r_click_lg"] = true,
	["legacy/light/shared_mouse_scroll_down_lg"] = true,
	["legacy/light/shared_mouse_scroll_up_lg"] = true,
}

surface.CreateFont( "ARC9_KeybindPreview", {
    font = "Arial",
    size = 16,
    weight = 600,
    antialias = false,
} )

--[[
    Creates a controller key line.
Info:
     x: X position
     y: Y position
     size: Height of font
     font: Font to use

Vararg:
    String: Out goes a string.
    Table:
        If it has a proper glyph name, it is used.
        If it doesn't, it is made into a key.
]]

local lastupdate = 0
local arc9_controller_glyphset = GetConVar("arc9_controller_glyphset")
local function UpdateGlyphs()
    if lastupdate == FrameNumber() then
        return false
    end
    lastupdate = FrameNumber()

    local glyphset = arc9_controller_glyphset:GetString()
    if glyphset != "" then
        table.Empty(ARC9.CTRL_Set_UserCustom)
        local config = glyphset
        config = string.Split( config, "\\n" )
        for i, v in ipairs(config) do
            local swig = string.Split( v, "\\t" )
            ARC9.CTRL_Set_UserCustom[swig[1]] = swig[2]
        end
        ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_UserCustom
    else
        ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox
    end

    return true
end

function CreateControllerKeyLine( info, ... )
    UpdateGlyphs()
    local args = { ... }
    local strlength = 0

    for i, v in ipairs( args ) do
        if IsColor(v) then
            surface.SetDrawColor(v)
            surface.SetTextColor(v)
        elseif isstring(v) then
            -- Draw text.
            surface.SetTextPos(info.x + strlength, info.y)
            surface.DrawText(v)
            strlength = strlength + surface.GetTextSize(v)
        elseif istable(v) then
            local size = v[2]
            if isstring(v[1]) and !ARC9.CTRL_Exists[v[1]] then
                -- Draw a key.
                surface.SetFont(info.font_keyb or "ARC9_KeybindPreview")
                local sx, sy = surface.GetTextSize(v[1])
                local keylength = math.max(sx + (info.size/2), info.size)
                surface.DrawOutlinedRect(info.x + strlength, info.y, keylength, info.size )
                surface.SetTextPos(info.x + strlength - (sx/2) + (keylength/2), info.y - (sy/2) + (info.size/2) )
                surface.DrawText( v[1] )
                surface.SetFont(info.font)
                strlength = strlength + keylength
            else
                -- Draw a controller input.
                surface.SetMaterial(v[1])
                surface.DrawTexturedRect( info.x + strlength, info.y - ((size - info.size)*0), size * 1.25, size * 1.25 )
                strlength = strlength + size
            end
        end
    end
    return strlength
end

-- Gets the size of the controller key line.
function GetControllerKeyLineSize( info, ... )
    UpdateGlyphs()
    local args = { ... }
    local strlength = 0

    for i, v in ipairs( args ) do
        if isstring(v) then
            strlength = strlength + surface.GetTextSize(v)
        elseif istable(v) then
            local size = v[2]
            if isstring(v[1]) and !ARC9.CTRL_Exists[v[1]] then
                surface.SetFont(info.font_keyb or "ARC9_KeybindPreview")
                local sx = surface.GetTextSize(v[1])
                local keylength = math.max(sx + (info.size/2), info.size)
                surface.SetFont(info.font)
                strlength = strlength + keylength
            else
                strlength = strlength + size
            end
        end
    end
    return strlength
end




function ARC9MultiLineText(text, maxw, font)
    local content = {}
    local tline = ""
    local x = 0
    surface.SetFont(font)

    local ts = surface.GetTextSize(" ")

    local newlined = string.Split(text, "\n")

    for _, line in ipairs(newlined) do
        local words = string.Split(line, " ")

        -- Keep track of the current color tag across lines
        local active_color_tag = nil

        for _, word in ipairs(words) do
            local tx = surface.GetTextSize(word)

            -- Don't count color tags for length purposes
            local match = {string.match(word, "<color=%d+,%d+,%d+>")}
            local matchend = {string.match(word, "</color>")}
            
            local matchfont = {string.match(word, "<font=^.*$>")}
            local matchfontend = {string.match(word, "</font>")}
            
            for _, v in ipairs(match) do
                tx = tx - surface.GetTextSize(v)
            end
            for _, v in ipairs(matchend) do
                tx = tx - surface.GetTextSize(v)
            end

            for _, v in ipairs(matchfont) do
                tx = tx - surface.GetTextSize(v)
            end
            for _, v in ipairs(matchfontend) do
                tx = tx - surface.GetTextSize(v)
            end

            -- if #match + #matchend > 0 then
            --     print(word, table.ToString(match), table.ToString(matchend))
            -- end

            if x + tx > maxw then
                local dashi = string.find(word, "-")
                if dashi and surface.GetTextSize(utf8.sub(word, 0, dashi)) <= maxw - x then
                    -- cut the word at the dash sign if possible
                    table.insert(content, tline .. utf8.sub(word, 0, dashi))
                    tline = ""
                    x = 0
                    word = utf8.sub(word, dashi + 1)
                    tx = surface.GetTextSize(word)
                else
                    -- move whole word to new line

                    -- close color tag
                    if active_color_tag != nil then
                        tline = tline .. "</color>"
                    end

                    table.insert(content, tline)
                    tline = ""
                    x = 0

                    -- reopen color tag
                    if active_color_tag != nil then
                        tline = tline .. active_color_tag
                    end
                end
            end

            -- Check the status of the color tag at the end of current word
            if math.abs(#match - #matchend) > 1 then
                ErrorNoHalt("<color> tag miscount!\n")
            elseif #match > #matchend then
                if active_color_tag != nil then
                    ErrorNoHalt("<color> tag miscount (too many opening tags)!\n")
                else
                    active_color_tag = match[#match]
                end
            elseif #matchend > #match then
                if active_color_tag == nil then
                    ErrorNoHalt("<color> tag miscount (too many closing tags)!\n")
                else
                    active_color_tag = nil
                end
            end

            tline = tline .. word .. " "

            x = x + tx + ts
        end

        -- close color tag
        if active_color_tag != nil then
            tline = tline .. "</color>"
        end

        table.insert(content, tline)
        tline = ""
        x = 0
    end

    return content
end


-- span: panel that hosts the rotating text
-- txt: the text to draw
-- x: where to start the crop
-- y: where to start the crp
-- tx, ty: where to draw the text
-- maxw: maximum width
-- only: don't advance text
function ARC9.DrawTextRot(span, txt, x, y, tx, ty, maxw, only)
    local tw, th = surface.GetTextSize(txt or "")

    span.TextRot = span.TextRot or {}

    if tw > maxw then
        local realx, realy = span:LocalToScreen(x, y)
        render.SetScissorRect(realx, realy, realx + maxw, realy + (th * 2), true)

        span.TextRot[txt] = span.TextRot[txt] or 0

        if !only then
            span.StartTextRot = span.StartTextRot or CurTime()
            span.TextRotState = span.TextRotState or 0 -- 0: start, 1: moving, 2: end
            if span.TextRotState == 0 then
                span.TextRot[txt] = 0
                if span.StartTextRot < CurTime() - 2 then
                    span.TextRotState = 1
                end
            elseif span.TextRotState == 1 then
                span.TextRot[txt] = span.TextRot[txt] + (FrameTime() * ARC9ScreenScale(16))
                if span.TextRot[txt] >= (tw - maxw) + ARC9ScreenScale(8) then
                    span.StartTextRot = CurTime()
                    span.TextRotState = 2
                end
            elseif span.TextRotState == 2 then
                if span.StartTextRot < CurTime() - 2 then
                    span.TextRotState = 3
                    span.StartTextRot = CurTime()
                end
            elseif span.TextRotState == 3 then
                span.TextRot[txt] = span.TextRot[txt] - (FrameTime() * ARC9ScreenScale(16))
                if span.TextRot[txt] <= 0 then
                    span.StartTextRot = CurTime()
                    span.TextRotState = 0
                end
            end
        end
        surface.SetTextPos(tx - span.TextRot[txt], ty)
        surface.DrawText(txt)
        render.SetScissorRect(0, 0, 0, 0, false)
    else
        surface.SetTextPos(tx, ty)
        surface.DrawText(txt)
    end
end
