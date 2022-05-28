local mat_grad = Material("arc9/gradient.png")

function SWEP:MultiLineText(text, maxw, font)
    local content = {}
    local tline = ""
    local x = 0
    surface.SetFont(font)

    local newlined = string.Split(text, "\n")

    for _, line in ipairs(newlined) do
        local words = string.Split(line, " ")

        for _, word in ipairs(words) do
            local tx = surface.GetTextSize(word)

            if x + tx >= maxw then
                table.insert(content, tline)
                tline = ""
                x = surface.GetTextSize(word)
            end

            tline = tline .. word .. " "

            x = x + surface.GetTextSize(word .. " ")
        end

        table.insert(content, tline)
        tline = ""
        x = 0
    end

    return content
end

// span: panel that hosts the rotating text
// txt: the text to draw
// x: where to start the crop
// y: where to start the crp
// tx, ty: where to draw the text
// maxw: maximum width
// only: don't advance text
function SWEP:DrawTextRot(span, txt, x, y, tx, ty, maxw, only)
    local tw, th = surface.GetTextSize(txt)

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
                span.TextRot[txt] = span.TextRot[txt] + (FrameTime() * ScreenScale(16))
                if span.TextRot[txt] >= (tw - maxw) + ScreenScale(8) then
                    span.StartTextRot = CurTime()
                    span.TextRotState = 2
                end
            elseif span.TextRotState == 2 then
                if span.StartTextRot < CurTime() - 2 then
                    span.TextRotState = 3
                    span.StartTextRot = CurTime()
                end
            elseif span.TextRotState == 3 then
                span.TextRot[txt] = span.TextRot[txt] - (FrameTime() * ScreenScale(16))
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

SWEP.CustomizeHUD = nil
SWEP.CustomizeBoxes = nil

SWEP.CustomizeTab = 1

SWEP.CustomizeButtons = {
    {
        title = "Inspect",
        func = function(self2)
            self2:ClearTabPanel()
        end
    },
    {
        title = "Customize",
        func = function(self2)
            self2:ClearTabPanel()
            self2:CreateHUD_Bottom()
        end
    },
    {
        title = "Stats",
        func = function(self2)
            self2:CreateHUD_Stats()
        end
    },
    {
        title = "Trivia",
        func = function(self2)
            self2:CreateHUD_Trivia()
        end
    },
    {
        title = "Bench",
        func = function(self2)
            self2:CreateHUD_Bench()
        end
    },
    {
        title = "Credits",
        func = function(self2)
            self2:CreateHUD_Credits()
        end
    },
}

SWEP.TabPanel = nil

function SWEP:ClearTabPanel()
    if self.TabPanel then
        self.TabPanel:Remove()
        self.TabPanel = nil
    end

    self:ClearBottomBar()
end

function SWEP:RefreshCustomizeMenu()
end

local mat_circle = Material("arc9/circle.png", "mips smooth")
local mat_gear = Material("arc9/gear.png", "mips smooth")

local lmbdown = false
local lmbdowntime = 0
local rmbdown = false
local rmbdowntime = 0
local lmbhold = false
local lmbclick = false
local rmbhold = false
local rmbclick = false

local lastmousex = 0
local lastmousey = 0

local dragging = false
local dragging_r = false

SWEP.CustomizePanX = 0
SWEP.CustomizePanY = 0

SWEP.CustomizePitch = 0
SWEP.CustomizeYaw = 0

SWEP.CustomizeZoom = 0

SWEP.CustomizeHints = {}

local gpX = 0
local gpY = 0

local Press1 = false
local Press2 = false

local Release1 = false
local Release2 = false
local setscroll = 0
hook.Add("StartCommand", "ARC9_GamepadHUD", function( ply, cmd )
    if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().ARC9 and LocalPlayer():GetActiveWeapon():GetCustomize() then
        local wpn = LocalPlayer():GetActiveWeapon()
    
        local pox = math.Round( math.TimeFraction( -32768, 32767, input.GetAnalogValue( ANALOG_JOY_U ))-0.5, 1 )*2
        local poy = math.Round( math.TimeFraction( -32768, 32767, input.GetAnalogValue( ANALOG_JOY_R ))-0.5, 1 )*2

        local p1x = math.Round( math.TimeFraction( -32768, 32767, input.GetAnalogValue( ANALOG_JOY_X ))-0.5, 1 )*2
        local p1y = math.Round( math.TimeFraction( -32768, 32767, input.GetAnalogValue( ANALOG_JOY_Y ))-0.5, 1 )*2

        if ARC9.ControllerMode() then
            if cmd:KeyDown( IN_JUMP ) then
                cmd:RemoveKey( IN_JUMP )
                if !Press1 then
                    gui.InternalMousePressed( MOUSE_LEFT )
                    Press1 = true
                end
                Release1 = true
            else
                if Release1 then
                    gui.InternalMouseReleased( MOUSE_LEFT )
                    Release1 = false
                    Press1 = false
                end
            end
            if cmd:KeyDown( IN_RELOAD ) then
                cmd:RemoveKey( IN_RELOAD )
                if !Press2 then
                    gui.InternalMousePressed( MOUSE_RIGHT )
                    Press2 = true
                end
                Release2 = true
            else
                if Release2 then
                    gui.InternalMouseReleased( MOUSE_RIGHT )
                    Release2 = false
                    Press2 = false
                end
            end
        end

        if true then
            local cx, cy = input.GetCursorPos()

            gpX = ( ( pox * 160 * ( ScrH() / 480 ) ) * RealFrameTime() )
            gpY = ( ( poy * 160 * ( ScrH() / 480 ) ) * RealFrameTime() )
            input.SetCursorPos( cx+gpX, cy+gpY )
            gpX = 0
            gpY = 0
        end

        if cmd:KeyDown( IN_USE ) then
            wpn.CustomizePanX = wpn.CustomizePanX + (p1x * 5 * RealFrameTime())
            wpn.CustomizePanY = wpn.CustomizePanY + (p1y * 5 * RealFrameTime())
        else
            wpn.CustomizePitch = wpn.CustomizePitch - (p1x * 45 * RealFrameTime())
            wpn.CustomizeYaw   = wpn.CustomizeYaw   + (p1y * 1 * RealFrameTime())
        end

        gui.InternalMouseWheeled(setscroll)
        setscroll = 0
    end
end)

local doop = 0
hook.Add("PlayerBindPress", "ARC9_GamepadHUDBinds", function(ply, bind, pressed, code)
    if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().ARC9 and LocalPlayer():GetActiveWeapon():GetCustomize() and ARC9.ControllerMode() then
        local wpn = LocalPlayer():GetActiveWeapon()
        if bind == "invprev" then
            if doop % 2 == 0 then setscroll = 1 end
            doop = doop + 1
            return true
        elseif bind == "invnext" then
            if doop % 2 == 0 then setscroll = -1 end
            doop = doop + 1
            return true
        end
    end
end)

local ghs = {
    Material("arc9/seasonal/g1.png", "mips smooth"),
    Material("arc9/seasonal/g2.png", "mips smooth"),
    Material("arc9/seasonal/g3.png", "mips smooth"),
    Material("arc9/seasonal/g4.png", "mips smooth"),
    Material("arc9/seasonal/g5.png", "mips smooth"),
    Material("arc9/seasonal/g6.png", "mips smooth"),
}

local troll = {
    Material("arc9/seasonal/troll.png", "mips smooth"),
    Material("arc9/seasonal/fuuu.png", "mips smooth")
}

local SeasonalHalloween = {}
local SeasonalHolidays = {}

function SWEP:CreateCustomizeHUD()
    if !IsValid(self) then return end

    local bg = vgui.Create("DPanel")

    self.CustomizeHUD = bg

    gui.EnableScreenClicker(true)

    gpX = ScrW()/2
    gpY = ScrH()/2

    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg.OnRemove = function(self2)
        if !IsValid(self) then return end
        -- self:SavePreset()
    end
    bg.OnMouseWheeled = function(self2, sd)
        if !IsValid(self) then return end
        self.CustomizeZoom = self.CustomizeZoom - (sd * 2)

        self.CustomizeZoom = math.Clamp(self.CustomizeZoom, -16, 16)
    end
    bg:SetMouseInputEnabled(true)
    table.Empty(SeasonalHalloween)
    table.Empty(SeasonalHolidays)
    if ARC9.ActiveHolidays["Christmas"] then
        bg.Posh = 0
    end
    bg.Paint = function(self2, w, h)
        if !IsValid(self) or LocalPlayer():GetActiveWeapon() != self then
            self2:Remove()
            gui.EnableScreenClicker(false)
            return
        end

        if ARC9.ActiveHolidays["Troll Day"] then
            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "problem?"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos( (w/2) - (tz/2)+ScreenScale(1), ScreenScale(8+1) )
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos( (w/2) - (tz/2), ScreenScale(8) )
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor( 255, 255, 255, 255 / 64 )

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial( v.mat )
                local si = ScreenScale(32)


                v.x = v.x + (v.px * 2)
                v.y = v.y + (v.py2 * 2)
                v.py = math.sin( (CurTime() + (i / i)) * math.pi * 0.5 ) * ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin( (CurTime() + (i / i)) * math.pi ) * 15 )

                if v.x >= w then
                    v.x = 0
                elseif v.x <= 0 then
                    v.x = w
                end

                if v.y >= w then
                    v.y = 0
                elseif v.y <= 0 then
                    v.y = h
                end
            end

            if table.IsEmpty(SeasonalHalloween) then
                for i=1, 13 do
                    table.insert(SeasonalHalloween,
                        {
                            x = w*math.Rand(0, 1),
                            y = h*math.Rand(0, 1),
                            px = math.Rand(-1, 1),
                            py = 0,
                            py2 = math.Rand(-1, 1),
                            mat = table.Random( troll ),
                        }
                    )
                end
            end
        elseif ARC9.ActiveHolidays["Summer Break"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Summer break!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos( (w/2) - (tz/2)+ScreenScale(1), ScreenScale(8+1) )
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos( (w/2) - (tz/2), ScreenScale(8) )
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor( 255, 255, 127, 255*0.04 )
            surface.SetMaterial( Material( "arc9/seasonal/sun.png", "mips smooth" ) )
            local si = ScreenScale(256)
            surface.DrawTexturedRectRotated(w-ScreenScale(32), ScreenScale(32), si, si, CurTime()*3 )

        elseif ARC9.ActiveHolidays["Halloween"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Halloween!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos( (w/2) - (tz/2)+ScreenScale(1), ScreenScale(8+1) )
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos( (w/2) - (tz/2), ScreenScale(8) )
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor( 255, 255, 255, 255/64 )

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial( v.mat )
                local si = ScreenScale(32)


                v.x = v.x + (v.px * 2)
                v.y = v.y + (v.py2 * 2)
                v.py = math.sin( (CurTime() + (i / i)) * math.pi * 0.5 ) * ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin( (CurTime() + (i / i)) * math.pi ) * 15 )

                if v.x >= w then
                    v.x = 0
                elseif v.x <= 0 then
                    v.x = w
                end

                if v.y >= w then
                    v.y = 0
                elseif v.y <= 0 then
                    v.y = h
                end
            end

            if table.IsEmpty(SeasonalHalloween) then
                for i=1, 13 do
                    table.insert(SeasonalHalloween,
                        {
                            x = w*math.Rand(0, 1),
                            y = h*math.Rand(0, 1),
                            px = math.Rand(-1, 1),
                            py = 0,
                            py2 = math.Rand(-1, 1),
                            mat = table.Random( ghs ),
                        }
                    )
                end
            end
        elseif ARC9.ActiveHolidays["Christmas"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Holidays!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos( (w/2) - (tz/2)+ScreenScale(1), ScreenScale(8+1) )
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos( (w/2) - (tz/2), ScreenScale(8) )
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor( 255, 255, 255, 255/32 )
            surface.SetMaterial( Material( "arc9/seasonal/hills.png", "smooth" ) )
            bg.Posh = math.Approach(bg.Posh or 0, 2, FrameTime() * (1/20) )
            if bg.Posh > 1 then
                bg.Posh = 0
            end
            surface.DrawTexturedRect(
                math.Round( 0-(ScreenScale(1024)*bg.Posh), 0 ),
                h-ScreenScale(1024/8*0.75) + ( ( math.sin( CurTime() * math.pi / 10 ) ) * ScreenScale(16) ),
                ScreenScale(1024),
                ScreenScale(1024/8)
            )
            surface.DrawTexturedRect(
                math.Round( 0+ScreenScale(1024)-(ScreenScale(1024)*bg.Posh), 0 ),
                h-ScreenScale(1024/8*0.75) + ( ( math.sin( CurTime() * math.pi / 10 ) ) * ScreenScale(16) ),
                ScreenScale(1024),
                ScreenScale(1024/8)
            )

            for i, v in ipairs(SeasonalHolidays) do
                surface.SetMaterial( Material( "arc9/seasonal/snowflake.png", "mips smooth" ) )
                local si = ScreenScale(16)

                surface.DrawTexturedRectRotated(v[1], v[2], si, si, v[5] or 0 )
                v[1] = math.Approach( v[1], v[1] + v[3], FrameTime() * ScreenScale(1) * 20 * v[3] )
                v[2] = math.Approach( v[2], h, FrameTime() * ScreenScale(1) * 20 * v[4] )
                v[5] = math.Approach( v[5] or 0, 370, FrameTime() * ScreenScale(1) * 20 * v[4] )
                if v[2] >= h then
                    v[2] = ScreenScale(-16)
                end
                if math.abs(v[1]) >= w then
                    v[2] = ScreenScale(-16)
                    v[1] = w*math.Rand(0, 1)
                end
                if math.abs(v[5]) >= 360 then
                    v[5] = 0
                end
            end

            if table.IsEmpty(SeasonalHolidays) then
                for i=1, 32 do
                    table.insert(SeasonalHolidays,
                        {
                            [1] = w*math.Rand(0, 1),
                            [2] = -h*math.Rand(0, 0.5),
                            [3] = math.Rand(-4, 4),
                            [4] = math.Rand(0.5, 4),
                            [5] = 0,
                        }
                    )
                end
            end
        end

        if ARC9.ControllerMode() then
            surface.SetTextPos(ScreenScale(4), ScreenScale(4))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetFont("ARC9_8")
            surface.DrawText("Controller mode is on.")

            --[[surface.SetMaterial( Material( "arc9/gamepad/corner.png", "" ) )
            surface.SetDrawColor(255, 255, 255, 255)

            local si = ScreenScale(6)
            local of = si/2
            local bo = si*2
            surface.DrawTexturedRectRotated(of, of, si, si, 0)
            surface.DrawTexturedRectRotated(of+bo, of, si, si, 270)
            surface.DrawTexturedRectRotated(of+bo, of+bo, si, si, 180)
            surface.DrawTexturedRectRotated(of, of+bo, si, si, 90)

            surface.SetMaterial( Material( "arc9/gamepad/pointer.png", "" ) )
            surface.DrawTexturedRect(si, si, si, si)

            surface.SetMaterial(mat_grad)
            surface.SetDrawColor(0, 0, 0, 250)
            surface.DrawTexturedRect(w - h, 0, h, h)]]
        end

        local bumpy = {}

        local anyhovered = false

        local function isinaabb(x, y)
            local mousex, mousey = input.GetCursorPos()

            local s = ScreenScale(16)
            local sw = ScreenScale(32)

            if mousex >= x - sw and mousex <= x + sw and mousey >= y - (s / 2) and mousey <= y + (s / 2) then
                return true
            else
                return false
            end
        end

        if self.CustomizeTab == 1 then

            cam.Start3D(nil, nil, self:WidescreenFix(self:GetViewModelFOV()))

            for _, slot in ipairs(self:GetSubSlotList()) do
                if slot.Hidden then continue end
                local ms_slot = self:GetFilledMergeSlot(slot.Address)

                if !ms_slot.Installed and self:GetSlotBlocked(slot) then continue end

                local atttbl = self:GetFinalAttTable(ms_slot)

                local attpos, attang = self:GetAttPos(slot, false, false, true)

                local icon_offset = slot.Icon_Offset or Vector(0, 0, 0)

                icon_offset = icon_offset + (atttbl.IconOffset or Vector(0, 0, 0))

                attpos = attpos + attang:Right() * icon_offset.y
                attpos = attpos + attang:Up() * icon_offset.z
                attpos = attpos + attang:Forward() * icon_offset.x

                local toscreen = attpos:ToScreen()

                cam.Start2D()

                local x, y = toscreen.x, toscreen.y

                local s = ScreenScale(8)

                -- local push = s

                -- for _, bump in pairs(bumpy) do
                --     if x == bump.x and y == bump.y then
                --         x = x + push
                --     elseif math.Distance(x, y, bump.x, bump.y) < push then
                --         local dx = bump.x - x
                --         local dy = bump.y - y

                --         local mag = math.sqrt(math.pow(dx, 2), math.pow(dy, 2))

                --         dx = dx / mag
                --         dy = dy / mag

                --         dx = dx * push
                --         dy = dy * push

                --         x = x + dx
                --         y = y + dy
                --     end
                -- end

                local hoveredslot = false

                local dist = 0

                local mousex, mousey = input.GetCursorPos()

                if isinaabb(x, y) then
                    hoveredslot = true
                    dist = math.Distance(x, y, mousex, mousey)
                    for _, bump in ipairs(bumpy) do
                        if isinaabb(bump.x, bump.y) then
                            local d2 = math.Distance(bump.x, bump.y, mousex, mousey)

                            if d2 < dist then
                                hoveredslot = false
                                break
                            end
                        end
                    end
                end

                if mousey > (ScrH() - ScreenScale(64)) then hoveredslot = false end

                table.insert(bumpy, {x = x, y = y, slot = slot})

                -- if self2:IsHovered() then
                -- end

                local col = ARC9.GetHUDColor("fg")

                if hoveredslot then
                    col = ARC9.GetHUDColor("hi")
                elseif self.BottomBarAddress == ms_slot.Address then
                    col = ARC9.GetHUDColor("sel")
                elseif slot.Installed then
                    col = ARC9.GetHUDColor("occupied")
                end

                if hoveredslot then
                    self.CustomizeHints["Select"] = "Expand"
                    if slot.Installed then
                        self.CustomizeHints["Deselect"] = "Unattach"
                    end
                end

                surface.SetMaterial(mat_circle)
                surface.SetDrawColor(col)
                surface.DrawTexturedRect(x, y, s, s)

                local atttxt = ms_slot.PrintName or "SLOT"

                if ms_slot.Installed then
                    atttxt = ARC9:GetPhraseForAtt(ms_slot.Installed, "CompactName")
                    atttxt = atttxt or ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName") or ""
                    surface.SetMaterial(atttbl.Icon)
                    surface.SetDrawColor(col)
                    surface.DrawTexturedRect(x + ScreenScale(1), y + ScreenScale(1), s - ScreenScale(2), s - ScreenScale(2))
                else
                    if ms_slot.DefaultCompactName then
                        atttxt = ARC9:UseTrueNames() and ms_slot.DefaultCompactName_TrueName or ms_slot.DefaultCompactName
                        atttxt = atttxt or ms_slot.DefaultName_TrueName or ms_slot.DefaultName or ""
                    end
                    if ms_slot.DefaultIcon then
                        surface.SetMaterial(ms_slot.DefaultIcon)
                        surface.SetDrawColor(col)
                        surface.DrawTexturedRect(x + ScreenScale(1), y + ScreenScale(1), s - ScreenScale(2), s - ScreenScale(2))
                    end
                end

                surface.SetFont("ARC9_6")
                local tw = surface.GetTextSize(atttxt)

                surface.SetFont("ARC9_6")
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.SetTextPos(x + (s / 2) - (tw / 2), y + s + ScreenScale(1))
                surface.DrawText(atttxt)

                surface.SetFont("ARC9_6")
                surface.SetTextColor(col)
                surface.SetTextPos(x + (s / 2) - (tw / 2), y + s)
                surface.DrawText(atttxt)

                -- surface.SetFont("ARC9_6")
                -- surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                -- surface.SetTextPos(x + s + ScreenScale(3), y + (s / 2) + ScreenScale(1))
                -- surface.DrawText(atttxt)

                -- surface.SetFont("ARC9_6")
                -- surface.SetTextColor(col)
                -- surface.SetTextPos(x + s + ScreenScale(2), y + (s / 2))
                -- surface.DrawText(atttxt)

                if hoveredslot and !ARC9.NoFocus then
                    anyhovered = true
                    -- print(lmbdown)
                    if input.IsMouseDown(MOUSE_LEFT) and !lmbdown and (self.BottomBarAddress != slot.Address or self.BottomBarMode != 1) then
                        self.BottomBarMode = 1
                        self.BottomBarAddress = slot.Address
                        self.BottomBarPath = {}
                        self.BottomBarFolders = {}
                        self.BottomBarAtts = {}
                        self:CreateHUD_Bottom()

                        self.CustomizePanX = 0
                        self.CustomizePanY = 0
                        self.CustomizePitch = 0
                        -- print("hi")
                    elseif input.IsMouseDown(MOUSE_RIGHT) and !rmbdown then
                        self:DetachAllFromSubSlot(slot.Address)
                    end
                end

                cam.End2D()
            end

            cam.End3D()

        end

        if !anyhovered and !ARC9.NoFocus then
            if input.IsMouseDown(MOUSE_LEFT) and !lmbdown then
                dragging = true
                lastmousex, lastmousey = input.GetCursorPos()
            end
            if input.IsMouseDown(MOUSE_RIGHT) and !rmbdown then
                dragging_r = true
                lastmousex, lastmousey = input.GetCursorPos()
            end
        end

        if dragging then
            if !input.IsMouseDown(MOUSE_LEFT) then
                dragging = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizePanX = self.CustomizePanX + (dx / ScreenScale(32))
                self.CustomizePanY = self.CustomizePanY + (dy / ScreenScale(32))

                self.CustomizePanX = math.Clamp(self.CustomizePanX, -32, 32)
                self.CustomizePanY = math.Clamp(self.CustomizePanY, -32, 32)
            end
        elseif dragging_r then
            if !input.IsMouseDown(MOUSE_RIGHT) then
                dragging_r = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizePitch = self.CustomizePitch - (dx / ScreenScale(4))*3
                -- self.CustomizeYaw = math.Clamp(self.CustomizeYaw + (dy / ScreenScale(8)) * (math.floor(self.CustomizePitch / 90) % 2 == 0 and 1 or -1), -30, 30)
                self.CustomizeYaw = self.CustomizeYaw + (dy / ScreenScale(8)) 

            end
        elseif self:GetOwner():KeyDown(IN_RELOAD) then
            self.CustomizePanX = Lerp(0.25, self.CustomizePanX, 0)
            self.CustomizePanY = Lerp(0.25, self.CustomizePanY, 0)
            self.CustomizePitch = Lerp(0.25, self.CustomizePitch, 0)
            self.CustomizeYaw = Lerp(0.25, self.CustomizeYaw, 0)
            self.CustomizeZoom = Lerp(0.25, self.CustomizeZoom, 0)
        end

        lastmousex, lastmousey = input.GetCursorPos()

        lmbdown = input.IsMouseDown(MOUSE_LEFT)
        rmbdown = input.IsMouseDown(MOUSE_RIGHT)
        
        if lmbdown then lmbdowntime = lmbdowntime + FrameTime() else lmbdowntime = 0 end
        if rmbdown then rmbdowntime = rmbdowntime + FrameTime() else rmbdowntime = 0 end

        lmbhold, rmbhold = lmbdowntime > 0.1, rmbdowntime > 0.1
        lmbclick, rmbclick = (!lmbdown and !lmbhold), (rmbdown and !rmbhold)

        -- print(lmbclick) - gross
    end

    self:CreateHUD_RHP()

    bg:MoveToFront()

    local trolling = ""
    if ARC9.ControllerMode() then
        trolling = {
            {
                action = "Select",
                glyph = ARC9.GetBindKey("+jump"),
                hidden = true,
            },
            {
                action = "Deselect",
                glyph = ARC9.GetBindKey("+reload"),
                hidden = true,
            },
            {
                action = "Zoom",
                glyph = ARC9.GetBindKey("invprev"),
                glyph2 = ARC9.GetBindKey("invnext"),
                row2 = true,
            },
            {
                action = "Pan",
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = "shared_lstick",
                row2 = true,
            },
            {
                action = "Rotate",
                glyph = "shared_lstick",
                row2 = true,
            },
            {
                action = "Cursor",
                glyph = "shared_rstick",
                row2 = true,
            },
        }
    else
        trolling = {
            {
                action = "Select",
                glyph = ARC9.GetBindKey("+attack"),
                hidden = true,
            },
            {
                action = "Deselect",
                glyph = ARC9.GetBindKey("+attack2"),
                hidden = true,
            },
            {
                action = "Zoom",
                glyph = ARC9.GetBindKey("invprev"),
                glyph2 = ARC9.GetBindKey("invnext"),
                row2 = true,
            },
            {
                action = "Pan",
                glyph = ARC9.GetBindKey("+attack"),
                glyph2 = "shared_touch",
                row2 = true,
            },
            {
                action = "Rotate",
                glyph = ARC9.GetBindKey("+attack2"),
                glyph2 = "shared_touch",
                row2 = true,
            },
            {
                action = "Recenter",
                glyph = ARC9.GetBindKey("+reload"),
                row2 = true,
            },
        }
    end

    local help = vgui.Create("DPanel", bg)
    help:SetSize(ScrW(), ScreenScale(16+16))
    help:SetPos(0, ScreenScale(4) )--ScrH() - ScreenScale(16+2) )
    help.Paint = function(self2, w, h)
        if !IsValid(self) then
            self2:Remove()
            gui.EnableScreenClicker(false)
            return
        end

        surface.SetFont("ARC9_10")
        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.SetTextColor(ARC9.GetHUDColor("fg"))

        local ToAdd = {}
        local ToAdd2 = {}
        for _, v in ipairs(trolling) do
            local act, hid = v.action, v.hidden
            if self.CustomizeHints[v.action] == "" then continue end
            if self.CustomizeHints[v.action] then hid = false end
            if hid then continue end
            if ARC9.CTRL_Lookup[v.glyph] then v.glyph = ARC9.CTRL_Lookup[v.glyph] end
            if ARC9.CTRL_ConvertTo[v.glyph] then v.glyph = ARC9.CTRL_ConvertTo[v.glyph] end
            if ARC9.CTRL_Exists[v.glyph] then v.glyph = Material( "arc9/glyphs_light/" .. v.glyph .. "_lg" .. ".png", "smooth" ) end
            if v.glyph2 then 
                if ARC9.CTRL_Lookup[v.glyph2] then v.glyph2 = ARC9.CTRL_Lookup[v.glyph2] end
                if ARC9.CTRL_ConvertTo[v.glyph2] then v.glyph2 = ARC9.CTRL_ConvertTo[v.glyph2] end
                if ARC9.CTRL_Exists[v.glyph2] then v.glyph2 = Material( "arc9/glyphs_light/" .. v.glyph2 .. "_lg" .. ".png", "smooth" ) end
            end

            if v.row2 then
            table.insert( ToAdd2, { v.glyph, ScreenScale(12) } )
            if v.glyph2 then
                table.insert( ToAdd2, " " )
                table.insert( ToAdd2, { v.glyph2, ScreenScale(12) } )
            end
            table.insert(ToAdd2, " " .. (self.CustomizeHints[v.action] or v.action) .. "    ")
            else
            table.insert( ToAdd, { v.glyph, ScreenScale(12) } )
            if v.glyph2 then
                table.insert( ToAdd, " " )
                table.insert( ToAdd, { v.glyph2, ScreenScale(12) } )
            end
            table.insert(ToAdd, " " .. (self.CustomizeHints[v.action] or v.action) .. "    ")
            end
        end
        CreateControllerKeyLine( {x = ScreenScale(8+1), y = ScreenScale(2+16+1), size = ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("shadow"), unpack( ToAdd ) )
        CreateControllerKeyLine( {x = ScreenScale(8), y = ScreenScale(2+16), size = ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("fg"), unpack( ToAdd ) )
        CreateControllerKeyLine( {x = ScreenScale(8+1), y = ScreenScale(2+1), size = ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("shadow"), unpack( ToAdd2 ) )
        CreateControllerKeyLine( {x = ScreenScale(8), y = ScreenScale(2), size = ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("fg"), unpack( ToAdd2 ) )
        table.Empty( self.CustomizeHints )
    end


    -- self:CreateHUD_Bottom()


    --[[local settings = vgui.Create("DButton", bg) -- I dont know where to put it
    settings:SetPos(ScreenScale(8), ScreenScale(8))
    settings:SetSize(ScreenScale(24), ScreenScale(24))
    settings:SetText("")

    settings.Paint = function(self2, w, h)
        surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        surface.SetMaterial(mat_gear)
        surface.DrawTexturedRect(2, 2, w, h)

        if self2:IsHovered() then
            surface.SetDrawColor(ARC9.GetHUDColor("hi"))
        else
            surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        end
        surface.SetMaterial(mat_gear)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    settings.DoClick = function(self2)
        surface.PlaySound("arc9/ubgl_select.wav")
        ARC9_ClientSettings()
        
        -- self:ToggleCustomize(false)
        bg:SetMouseInputEnabled(false)
    end

    settings.DoRightClick = function(self2)
        surface.PlaySound("arc9/ubgl_exit.wav")
    end]]
end

function SWEP:RemoveCustomizeHUD()
    if self.CustomizeHUD then
        self.CustomizeHUD:Remove()

        gui.EnableScreenClicker(false)

        self.CustomizeHUD = nil
    end
end

function SWEP:DrawCustomizeHUD()

    local customize = self:GetCustomize()

    if self.CustomizeHUD and !IsValid(self.CustomizeHUD) then
        self:RemoveCustomizeHUD()
    end

    if customize and !self.CustomizeHUD then
        self:CreateCustomizeHUD()
    elseif !customize and self.CustomizeHUD then
        self:RemoveCustomizeHUD()
    end

    lastcustomize = self:GetCustomize()
end

function SWEP:CreateHUD_RHP()
    local bg = self.CustomizeHUD

    local gr_h = ScrH()
    local gr_w = gr_h

    local nameplate = vgui.Create("DPanel", bg)
    nameplate:SetPos(0, ScreenScale(8))
    nameplate:SetSize(ScrW(), ScreenScale(64))
    nameplate:MoveToBack()
    nameplate.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        surface.SetFont("ARC9_24")
        local tw = surface.GetTextSize(self.PrintName)

        surface.SetFont("ARC9_24")
        surface.SetTextPos(w - tw - ScreenScale(8) + ScreenScale(1), ScreenScale(1))
        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        surface.DrawText(self.PrintName)

        surface.SetFont("ARC9_24")
        surface.SetTextPos(w - tw - ScreenScale(8), 0)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(self.PrintName)

        -- class
        surface.SetFont("ARC9_12")
        local tw2 = surface.GetTextSize(self.Class)

        surface.SetFont("ARC9_12")
        surface.SetTextPos(w - tw2 - ScreenScale(10) + ScreenScale(1), ScreenScale(26 + 1))
        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        surface.DrawText(self.Class)

        surface.SetFont("ARC9_12")
        surface.SetTextPos(w - tw2 - ScreenScale(10), ScreenScale(26))
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(self.Class)

        surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        surface.DrawRect(w - ScreenScale(420 - 1), ScreenScale(42 + 1), ScreenScale(407), ScreenScale(1))

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(w - ScreenScale(420), ScreenScale(42), ScreenScale(407), ScreenScale(1))
    end

    if !self.Attachments[1] and self.CustomizeButtons[2].title == "Customize" then 
        table.remove(self.CustomizeButtons, 2)
        self.CustomizeTab = 0
    end

    for i, btn in ipairs(self.CustomizeButtons) do
        local newbtn = vgui.Create("DButton", bg)
        newbtn:SetPos(ScrW() - ScreenScale(6) - (ScreenScale(69) * i), ScreenScale(58))
        newbtn:SetSize(ScreenScale(64), ScreenScale(12))
        newbtn.title = btn.title
        newbtn.page = i - 1
        newbtn.func = btn.func
        newbtn:SetText("")
        newbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end
            local col1 = Color(0, 0, 0, 0)
            local col2 = ARC9.GetHUDColor("fg")

            local noshade = false

            if self.CustomizeTab == self2.page then
                col1 = ARC9.GetHUDColor("fg")
                col2 = ARC9.GetHUDColor("shadow")

                noshade = true
            end

            if self2:IsHovered() then
                col1 = ARC9.GetHUDColor("hi")
                col2 = ARC9.GetHUDColor("shadow")
                if self.CustomizeTab != self2.page then self.CustomizeHints["Select"] = "Open" end

                noshade = true
            end

            if noshade then
                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.DrawRect(ScreenScale(1), ScreenScale(1), w, h)
            end

            surface.SetDrawColor(col1)
            surface.DrawRect(0, 0, w - ScreenScale(1), h - ScreenScale(1))

            surface.SetFont("ARC9_8")
            local tw = surface.GetTextSize(self2.title)

            if !noshade then
                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.SetTextPos((w - tw) / 2 + ScreenScale(1), ScreenScale(1 + 1))
                surface.DrawText(self2.title)
            end

            surface.SetFont("ARC9_8")
            surface.SetTextColor(col2)
            surface.SetTextPos((w - tw) / 2, ScreenScale(1))
            surface.DrawText(self2.title)
        end
        newbtn.DoClick = function(self2)
            if !ARC9.NoFocus then
                self.CustomizeTab = self2.page
                self2.func(self)
            end
        end
        newbtn.DoRightClick = function(self2)
            self.CustomizeTab = 0
            self:ClearTabPanel()
        end
    end

    self.CustomizeButtons[self.CustomizeTab + 1].func(self)
end