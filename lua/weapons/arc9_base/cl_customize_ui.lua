local mat_grad = Material("arc9/gradient.png")

local DevMode = false

local ARC9ScreenScale = ARC9.ScreenScale

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

-- span: panel that hosts the rotating text
-- txt: the text to draw
-- x: where to start the crop
-- y: where to start the crp
-- tx, ty: where to draw the text
-- maxw: maximum width
-- only: don't advance text
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

-- Cycle the selected attachment
function SWEP:CycleSelectedAtt(amt, cyc)
    if self.CustomizeTab != 0 then return end

    cyc = cyc or 0
    if #self.AttachmentAddresses <= 0 then return end
    if cyc > #self.AttachmentAddresses then return end

    local addr = self.BottomBarAddress or 1

    local newaddr = addr + amt

    if newaddr < 1 then
        newaddr = #self.AttachmentAddresses
    elseif newaddr > #self.AttachmentAddresses then
        newaddr = 1
    end

    self.BottomBarAddress = newaddr

    self.BottomBarPath = {}

    self.BottomBarMode = 1
    self.BottomBarFolders = {}
    self.BottomBarAtts = {}
    self:CreateHUD_Bottom()

    self.CustomizePanX = 0
    self.CustomizePanY = 0
    self.CustomizePitch = 0

    local slot = self:LocateSlotFromAddress(self.BottomBarAddress)

    if slot.Hidden or self:GetSlotBlocked(slot) then
        self:CycleSelectedAtt(1, cyc + 1)
    end
end

SWEP.CustomizeHUD = nil
SWEP.CustomizeBoxes = nil

SWEP.CustomizeTab = 0

local function swtichtoslotmenu(self)
    if GetConVar("arc9_cust_exit_reset_sel"):GetBool() and self.CustomizeHUD.lowerpanel.Extended then
        self.CustomizeHUD.lowerpanel.Extended = nil
        self.BottomBarMode = 0
        self.BottomBarAddress = nil
        self.BottomBarMode = 0
        self:CreateHUD_Bottom()
    end
end

SWEP.CustomizeButtons = {
    {
        title = "CUSTOMIZE",
        func = function(self2)
            self2:ClearTabPanel()
            self2:CreateHUD_Bottom()

            swtichtoslotmenu(self2)

            if self2.CustomizeHUD.lowerpanel then
                if self2.CustomizeHUD.lowerpanel.Extended then
                    self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(93+73.5), 0.2, 0, 0.5, nil)
                    self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74+73.5), 0.2, 0, 0.5, nil)
                else
                    self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(93), 0.2, 0, 0.5, nil)
                    self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74), 0.2, 0, 0.5, nil)
                end

                self2:ClosePresetMenu()
                self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
            end
        end,
        customize = true,
        cutcorner = 1
    },
    -- {
    --     title = "STATS",
    --     func = function(self2)
    --         self2:CreateHUD_Stats()

    --         if self2.CustomizeHUD.lowerpanel then
    --             self2.CustomizeHUD.lowerpanel.Extended = nil

    --             self2:ClosePresetMenu()

    --             self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH()-ARC9ScreenScale(93+50), 0.2, 0, 0.5, nil)
    --             self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74+50), 0.2, 0, 0.5, nil)

    --             self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
    --             self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
    --             self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
    --         end
    --     end
    -- },
    {
        title = "STATS & BALLISTICS",
        func = function(self2)
            self2:CreateHUD_Bench()

            if self2.CustomizeHUD.lowerpanel then
                self2.CustomizeHUD.lowerpanel.Extended = nil

                self2:ClosePresetMenu()

                -- self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(93-55-22.75), 0.2, 0, 0.5, nil)
                -- self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74-55), 0.2, 0, 0.5, nil)

                self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH()-ARC9ScreenScale(93+50), 0.2, 0, 0.5, nil)
                self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74+50), 0.2, 0, 0.5, nil)

                self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
            end
        end
    },
    {
        title = "TRIVIA",
        func = function(self2)
            self2:CreateHUD_Trivia()

            if self2.CustomizeHUD.lowerpanel then
                self2.CustomizeHUD.lowerpanel.Extended = nil

                self2:ClosePresetMenu()

                self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH()-ARC9ScreenScale(93+50), 0.2, 0, 0.5, nil)
                self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74+50), 0.2, 0, 0.5, nil)

                self2.CustomizeHUD.lowerpanel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topright_panel:AlphaTo(255, 0.2, 0, nil)
                self2.CustomizeHUD.topleft_panel:AlphaTo(255, 0.2, 0, nil)
            end
        end,
        cutcorner = 2
    },
    {
        title = "INSPECT",
        func = function(self2, page)
            self2:ClearTabPanel()

            if self2.LastCustomizeTab == page then
                self2.CustomizeTab = 0
                self2.CustomizeButtons[1].func(self2)
            elseif self2.CustomizeHUD.lowerpanel then
                self2.CustomizeHUD.lowerpanel.Extended = nil

                self2:ClosePresetMenu()

                self2.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(93-55-22.75), 0.2, 0, 0.5, nil)
                self2.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74-55), 0.2, 0, 0.5, nil)

                self2.CustomizeAlphaBuffer = math.max(self2.CustomizeAlphaBuffer or 0, CurTime() + 0.5)
            end
        end,
        inspect = true,
        cutcorner = 3
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

local mat_3dslot = Material("arc9/ui/3d_slot.png", "mips smooth")
local mat_3dslot_empty = Material("arc9/ui/3d_slot_empty.png", "mips smooth")
local mat_gear = Material("arc9/gear.png", "mips smooth")
local mat_plus = Material("arc9/ui/plus.png")

local lmbdown = false
local rmbdown = false

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
hook.Add("StartCommand", "ARC9_GamepadHUD", function(ply, cmd)
    if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().ARC9 and LocalPlayer():GetActiveWeapon():GetCustomize() then
        local wpn = LocalPlayer():GetActiveWeapon()

        local pox = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_U))-0.5, 1)*2
        local poy = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_R))-0.5, 1)*2

        local p1x = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_X))-0.5, 1)*2
        local p1y = math.Round(math.TimeFraction(-32768, 32767, input.GetAnalogValue(ANALOG_JOY_Y))-0.5, 1)*2

        if ARC9.ControllerMode() then
            if cmd:KeyDown(IN_JUMP) then
                cmd:RemoveKey(IN_JUMP)
                if !Press1 then
                    gui.InternalMousePressed(MOUSE_LEFT)
                    Press1 = true
                end
                Release1 = true
            else
                if Release1 then
                    gui.InternalMouseReleased(MOUSE_LEFT)
                    Release1 = false
                    Press1 = false
                end
            end
            if cmd:KeyDown(IN_RELOAD) then
                cmd:RemoveKey(IN_RELOAD)
                if !Press2 then
                    gui.InternalMousePressed(MOUSE_RIGHT)
                    Press2 = true
                end
                Release2 = true
            else
                if Release2 then
                    gui.InternalMouseReleased(MOUSE_RIGHT)
                    Release2 = false
                    Press2 = false
                end
            end
        end

        if true then
            local cx, cy = input.GetCursorPos()

            gpX = ((pox * 160 * (ScrH() / 480)) * RealFrameTime())
            gpY = ((poy * 160 * (ScrH() / 480)) * RealFrameTime())
            input.SetCursorPos(cx+gpX, cy+gpY)
            gpX = 0
            gpY = 0
        end

        if cmd:KeyDown(IN_USE) then
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
local bday = {
    Material("arc9/seasonal/birthday1.png", "mips smooth"),
    Material("arc9/seasonal/birthday2.png", "mips smooth"),
    Material("arc9/seasonal/birthday3.png", "mips smooth"),
}
local troll = {
    Material("arc9/seasonal/troll.png", "mips smooth"),
    Material("arc9/seasonal/fuuu.png", "mips smooth")
}
local SeasonalHalloween = {}
local SeasonalHolidays = {}

local hoversound = "arc9/newui/uimouse_hover.ogg"
local clicksound = "arc9/newui/uimouse_click.ogg"
local opensound = "arc9/newui/uimouse_click_forward.ogg"
local backsound = "arc9/newui/uimouse_click_return.ogg"
local popupsound = "arc9/newui/uimouse_click_popup.ogg"
local closesound = "arc9/newui/ui_close.ogg"
local lightonsound = "arc9/newui/ui_light_on.ogg"
local lightoffsound = "arc9/newui/ui_light_off.ogg"
local tabsound = "arc9/newui/uimouse_click_tab.ogg"


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
        if !self2:IsHovered() then return false end -- to prevent wheeling outside area

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

        --[[
        if DevMode then
            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(5))
            surface.DrawText("Developer mode")

            surface.SetFont("ARC9_8")

            surface.SetTextColor(255, 174, 0)
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(16))
            surface.DrawText("bone pos")
            surface.SetTextColor(230, 166, 255)
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(23))
            surface.DrawText("icon pos")
            surface.SetTextColor(206, 90, 90)
            surface.SetTextPos((w/2) - 10, ARC9ScreenScale(30))
            surface.DrawText("att pos")

        elseif ARC9.ActiveHolidays["Troll Day"] then
            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "problem?"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255 / 64)

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial(v.mat)
                local si = ARC9ScreenScale(32)


                v.x = v.x + (v.px * 2 * FrameTime())
                v.y = v.y + (v.py2 * 2 * FrameTime())
                v.py = math.sin((CurTime() + (i / i)) * math.pi * 0.5) * ARC9ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin((CurTime() + (i / i)) * math.pi) * 15)

                if v.x >= w then
                    v.x = 0
                elseif v.x <= 0 then
                    v.x = w
                end

                if v.y >= h then
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
                            mat = table.Random(troll),
                        }
                   )
                end
            end

        elseif ARC9.ActiveHolidays["Birthday - Arctic"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Birthday to Arctic!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255/64)

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial(v.mat)
                local si = ARC9ScreenScale(32)


                v.x = v.x + (v.px * 2 * FrameTime())
                v.y = v.y + (v.py2 * 2 * FrameTime())
                v.py = math.sin((CurTime() + (i / i)) * math.pi * 0.5) * ARC9ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin((CurTime() + (i / i)) * math.pi) * 15)

                if v.y >= h then
                    v.y = 0
                    v.x = w*math.Rand(0, 1)
                elseif v.y <= 0 then
                    v.y = h
                    v.x = w*math.Rand(0, 1)
                end
            end

            if table.IsEmpty(SeasonalHalloween) then
                for i=1, 10 do
                    table.insert(SeasonalHalloween,
                        {
                            x = w*math.Rand(0, 1),
                            y = h*math.Rand(0, 1),
                            px = 0,
                            py = 0,
                            py2 = math.Rand(60, 120),
                            mat = table.Random(bday),
                        }
                   )
                end
            end
        elseif ARC9.ActiveHolidays["Summer Break"] then
            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Summer break!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 127, 255*0.04)
            surface.SetMaterial(Material("arc9/seasonal/sun.png", "mips smooth"))
            local si = ARC9ScreenScale(256)
            surface.DrawTexturedRectRotated(w-ARC9ScreenScale(32), ARC9ScreenScale(32), si, si, CurTime()*3)
        elseif ARC9.ActiveHolidays["Halloween"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Halloween!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255/64)

            for i, v in ipairs(SeasonalHalloween) do
                if isnumber(v.mat) then continue end -- fuck off
                surface.SetMaterial(v.mat)
                local si = ARC9ScreenScale(32)


                v.x = v.x + (v.px * 2 * FrameTime())
                v.y = v.y + (v.py2 * 2 * FrameTime())
                v.py = math.sin((CurTime() + (i / i)) * math.pi * 0.5) * ARC9ScreenScale(8)

                surface.DrawTexturedRectRotated(v.x + v.px, v.y + v.py, si, si, math.sin((CurTime() + (i / i)) * math.pi) * 15)

                if v.x >= w then
                    v.x = 0
                elseif v.x <= 0 then
                    v.x = w
                end

                if v.y >= h then
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
                            mat = table.Random(ghs),
                        }
                   )
                end
            end
        elseif ARC9.ActiveHolidays["Christmas"] then

            do  -- nice text
                surface.SetFont("ARC9_10")
                local tx = "Happy Holidays!"
                local tz = surface.GetTextSize(tx)
                surface.SetTextPos((w/2) - (tz/2)+ARC9ScreenScale(1), ARC9ScreenScale(16+1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(tx)
                surface.SetTextPos((w/2) - (tz/2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(tx)
            end

            surface.SetDrawColor(255, 255, 255, 255/32)
            surface.SetMaterial(Material("arc9/seasonal/hills.png", "smooth"))
            bg.Posh = math.Approach(bg.Posh or 0, 2, FrameTime() * (1/20))
            if bg.Posh > 1 then
                bg.Posh = 0
            end
            surface.DrawTexturedRect(
                math.Round(0-(ARC9ScreenScale(1024)*bg.Posh), 0),
                h-ARC9ScreenScale(1024/8*0.75) + ((math.sin(CurTime() * math.pi / 10)) * ARC9ScreenScale(16)),
                ARC9ScreenScale(1024),
                ARC9ScreenScale(1024/8)
           )
            surface.DrawTexturedRect(
                math.Round(0+ARC9ScreenScale(1024)-(ARC9ScreenScale(1024)*bg.Posh), 0),
                h-ARC9ScreenScale(1024/8*0.75) + ((math.sin(CurTime() * math.pi / 10)) * ARC9ScreenScale(16)),
                ARC9ScreenScale(1024),
                ARC9ScreenScale(1024/8)
           )

            for i, v in ipairs(SeasonalHolidays) do
                surface.SetMaterial(Material("arc9/seasonal/snowflake.png", "mips smooth"))
                local si = ARC9ScreenScale(16)

                surface.DrawTexturedRectRotated(v[1], v[2], si, si, v[5] or 0)
                v[1] = math.Approach(v[1], v[1] + v[3], FrameTime() * ARC9ScreenScale(1) * 20 * v[3])
                v[2] = math.Approach(v[2], h, FrameTime() * ARC9ScreenScale(1) * 20 * v[4])
                v[5] = math.Approach(v[5] or 0, 370, FrameTime() * ARC9ScreenScale(1) * 20 * v[4])
                if v[2] >= h then
                    v[2] = ARC9ScreenScale(-16)
                end
                if math.abs(v[1]) >= w then
                    v[2] = ARC9ScreenScale(-16)
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
        ]]

        if ARC9.ControllerMode() then
            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(4))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetFont("ARC9_8")
            surface.DrawText("Controller mode is on.")

            --[[surface.SetMaterial(Material("arc9/gamepad/corner.png", ""))
            surface.SetDrawColor(255, 255, 255, 255)

            local si = ARC9ScreenScale(6)
            local of = si/2
            local bo = si*2
            surface.DrawTexturedRectRotated(of, of, si, si, 0)
            surface.DrawTexturedRectRotated(of+bo, of, si, si, 270)
            surface.DrawTexturedRectRotated(of+bo, of+bo, si, si, 180)
            surface.DrawTexturedRectRotated(of, of+bo, si, si, 90)

            surface.SetMaterial(Material("arc9/gamepad/pointer.png", ""))
            surface.DrawTexturedRect(si, si, si, si)

            surface.SetMaterial(mat_grad)
            surface.SetDrawColor(0, 0, 0, 250)
            surface.DrawTexturedRect(w - h, 0, h, h)]]--
        end

        local bumpy = {}

        local anyhovered = false

        local function isinaabb(x, y)
            if !self2:IsHovered() then return false end -- to prevent clicking outside area
            if anyhovered then return false end

            local mousex, mousey = input.GetCursorPos()

            local s = ARC9ScreenScale(10) - self.CustomizeZoom*1.5


            if mousex >= x - s and mousex <= x + s and mousey >= y - (s / 2) and mousey <= y + (s / 2) then
                anyhovered = true
                return true
            else
                return false
            end
        end

        if self.CustomizeTab == 0 then

            cam.Start3D(nil, nil, self:WidescreenFix(self:GetViewModelFOV()))

            for _, slot in ipairs(self:GetSubSlotList()) do
                if slot.Hidden then continue end
                local ms_slot = self:GetFilledMergeSlot(slot.Address)

                if !ms_slot.Installed and self:GetSlotBlocked(slot) then continue end

                local atttbl = self:GetFinalAttTable(ms_slot)

                local attpos, attang = self:GetAttPos(slot, false, false, true)
                local attposOffset = attpos

                local icon_offset = slot.Icon_Offset or Vector(0, 0, 0)

                icon_offset = icon_offset + (atttbl.IconOffset or vector_origin)

                attposOffset = attposOffset + attang:Right() * icon_offset.y
                attposOffset = attposOffset + attang:Up() * icon_offset.z
                attposOffset = attposOffset + attang:Forward() * icon_offset.x

                local toscreen = attpos:ToScreen()
                local toscreenOffset = attposOffset:ToScreen()

                cam.Start2D()

                local x, y = toscreenOffset.x, toscreenOffset.y
                local xUOS, yUOS = toscreen.x, toscreen.y -- unoffsetted

                local s = ARC9ScreenScale(16) - self.CustomizeZoom*1.5

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

                if mousey > (ScrH() - ARC9ScreenScale(64)) then hoveredslot = false end

                table.insert(bumpy, {x = x, y = y, slot = slot})

                local col = ARC9.GetHUDColor("notoccupied")

                local showname = false

                if hoveredslot or ms_slot.hovered then
                    col = ARC9.GetHUDColor("hi")
                    showname = true
                elseif self.BottomBarAddress == ms_slot.Address then
                    col = ARC9.GetHUDColor("hi")
                elseif slot.Installed then
                    col = ARC9.GetHUDColor("fg")
                end

                if hoveredslot then
                    self.CustomizeHints["Select"] = "Expand"
                    if slot.Installed then
                        self.CustomizeHints["Deselect"] = "Unattach"
                    end
                end

                if DevMode then
                    -- local bonepos = self:GetVM():GetBonePosition(self:GetVM():LookupBone(slot.Bone))
                    local bonepos =  self:GetVM():GetBoneMatrix(self:GetVM():LookupBone(slot.Bone)):GetTranslation()
                    local bonepostoscreen = bonepos:ToScreen()
                    local boneposX, boneposY = bonepostoscreen.x, bonepostoscreen.y

                    surface.SetFont("ARC9_4")

                    -- att

                    surface.SetDrawColor(206, 90, 90)
                    surface.DrawRect(xUOS-5, yUOS-5, 10, 10)

                    surface.SetDrawColor(230, 166, 255)
                    surface.DrawLine(x, y, xUOS, yUOS)
                    surface.DrawRect(x-2.5, y-2.5, 5, 5)

                    surface.SetTextColor(230, 166, 255)
                    surface.SetTextPos(x, y-20)
                    surface.DrawText(slot.PrintName)

                    -- bone
                    surface.SetDrawColor(255, 174, 0)
                    surface.DrawLine(xUOS, yUOS, boneposX, boneposY)
                    surface.DrawRect(boneposX-2.5, boneposY-2.5, 5, 5)

                    surface.SetTextColor(255, 174, 0)
                    surface.SetTextPos(boneposX, boneposY)
                    surface.DrawText(slot.Bone)
                else
                    x, y = x-s/2, y-s/2

                    surface.SetMaterial(mat_3dslot)
                    surface.SetDrawColor(col)
                    surface.DrawTexturedRect(x, y, s, s)

                    local atttxt = ms_slot.PrintName or "SLOT"

                    if ms_slot.Installed then
                        atttxt = ARC9:GetPhraseForAtt(ms_slot.Installed, "CompactName")
                        atttxt = atttxt or ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName") or ""

                        surface.SetMaterial(atttbl.Icon or mat_3dslot)
                        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                        if !atttbl.FullColorIcon then
                            surface.DrawTexturedRect(x + ARC9ScreenScale(1), y + ARC9ScreenScale(1), s - ARC9ScreenScale(2), s - ARC9ScreenScale(2))
                        else
                            surface.DrawTexturedRect(x + ARC9ScreenScale(3), y + ARC9ScreenScale(3), s - ARC9ScreenScale(6), s - ARC9ScreenScale(6))
                        end
                    else
                        if ms_slot.DefaultCompactName then
                            atttxt = ARC9:UseTrueNames() and ms_slot.DefaultCompactName_TrueName or ms_slot.DefaultCompactName
                            atttxt = atttxt or ms_slot.DefaultName_TrueName or ms_slot.DefaultName or ""
                        end

                        if ms_slot.DefaultIcon then
                            surface.SetMaterial(ms_slot.DefaultIcon)
                        else
                            surface.SetMaterial(mat_plus)
                        end

                        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                        surface.DrawTexturedRect(x + ARC9ScreenScale(1), y + ARC9ScreenScale(1), s - ARC9ScreenScale(2), s - ARC9ScreenScale(2))
                    end

                    if showname then
                        surface.SetFont("ARC9_8")
                        local tw = surface.GetTextSize(atttxt)
                        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                        surface.SetTextPos(x + (s / 2) - (tw / 2) + 1, y + s + ARC9ScreenScale(1.3)) -- x + s + ARC9ScreenScale(2), y + (s / 2)
                        surface.DrawText(atttxt)
                        surface.SetTextColor(ARC9.GetHUDColor("fg"))
                        surface.SetTextPos(x + (s / 2) - (tw / 2), y + s + ARC9ScreenScale(1)) -- x + s + ARC9ScreenScale(2), y + (s / 2)
                        surface.DrawText(atttxt)
                    end
                end

                if hoveredslot then
                    if IsValid(ms_slot.lowerbutton) then ms_slot.lowerbutton:SetOverrideHovered(true) end

                    if input.IsMouseDown(MOUSE_LEFT) and !lmbdown and (self.BottomBarAddress != slot.Address or self.BottomBarMode != 1) then
                        self.BottomBarMode = 1
                        self.BottomBarAddress = slot.Address
                        self.BottomBarPath = {}
                        self.BottomBarFolders = {}
                        self.BottomBarAtts = {}
                        self:CreateHUD_Bottom()

                        -- self.CustomizePanX = 0
                        -- self.CustomizePanY = 0
                        -- self.CustomizePitch = 0
                        surface.PlaySound(clicksound)

                    elseif input.IsMouseDown(MOUSE_RIGHT) and !rmbdown then
                        self:DetachAllFromSubSlot(slot.Address)
                        self.BottomBarPath = {}
                        self.BottomBarFolders = {}
                        self.BottomBarAtts = {}
                        timer.Simple(0, function()
                            if !IsValid(self) then return end
                            self:CreateHUD_Bottom()
                        end)
                    end
                else
                    if IsValid(ms_slot.lowerbutton) then ms_slot.lowerbutton:SetOverrideHovered(false) end
                end

                cam.End2D()
            end

            cam.End3D()

        end

        if dragging then
            self2:SetCursor("sizeall")

            if !input.IsMouseDown(MOUSE_LEFT) then
                dragging = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizePanX = self.CustomizePanX + (dx / ARC9ScreenScale(32))
                self.CustomizePanY = self.CustomizePanY + (dy / ARC9ScreenScale(32))

                self.CustomizePanX = math.Clamp(self.CustomizePanX, -16, 16)
                self.CustomizePanY = math.Clamp(self.CustomizePanY, -8, 8)
            end
        elseif dragging_r then
            self2:SetCursor("sizewe")

            if !input.IsMouseDown(MOUSE_RIGHT) then
                dragging_r = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizePitch = self.CustomizePitch - (dx / ARC9ScreenScale(4))*3
                -- self.CustomizeYaw = math.Clamp(self.CustomizeYaw + (dy / ARC9ScreenScale(8)) * (math.floor(self.CustomizePitch / 90) % 2 == 0 and 1 or -1), -30, 30)
                self.CustomizeYaw = self.CustomizeYaw + (dy / ARC9ScreenScale(8))

            end
        elseif self:GetOwner():KeyDown(IN_RELOAD) then
            self.CustomizePanX = Lerp(0.25, self.CustomizePanX, 0)
            self.CustomizePanY = Lerp(0.25, self.CustomizePanY, 0)
            self.CustomizePitch = Lerp(0.25, self.CustomizePitch, 0)
            self.CustomizeYaw = Lerp(0.25, self.CustomizeYaw, 0)
            self.CustomizeZoom = Lerp(0.25, self.CustomizeZoom, 0)
        elseif !anyhovered then
            self2:SetCursor("arrow")

            if input.IsMouseDown(MOUSE_LEFT) and !lmbdown and self2:IsHovered() then
                dragging = true
                lastmousex, lastmousey = input.GetCursorPos()
            end
            if input.IsMouseDown(MOUSE_RIGHT) and !rmbdown and self2:IsHovered() then
                dragging_r = true
                lastmousex, lastmousey = input.GetCursorPos()
            end
        elseif anyhovered then
            self2:SetCursor("hand")
        end

        lastmousex, lastmousey = input.GetCursorPos()

        lmbdown = input.IsMouseDown(MOUSE_LEFT)
        rmbdown = input.IsMouseDown(MOUSE_RIGHT)
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
                row3 = true,
            },
            {
                action = "Cycle Slot",
                glyph = ARC9.GetBindKey("+showscores"),
                row3 = true,
            },
            {
                action = "Last Slot",
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+showscores"),
                row3 = true,
            },
        }
    end

    if GetConVar("arc9_cust_hints"):GetBool() then
        local hintspanel = vgui.Create("DPanel", bg)
        -- hintspanel:SetSize(ARC9ScreenScale(225), ARC9ScreenScale(100))
        -- hintspanel:SetPos(-ARC9ScreenScale(170), -ARC9ScreenScale(40)) -- w = scrw-ARC9Scr
        -- hintspanel:MoveTo(0, ARC9ScreenScale(4), 0.4, 0, 0.1, nil)

        self.CustomizeHUD.hintspanel = hintspanel
        hintspanel:SetPos(ARC9ScreenScale(19), ScrH())
        hintspanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(16.5), 0.6, 0, 0.1, nil)
        hintspanel:SetSize(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(18))
        hintspanel:MoveToBack()

        hintspanel.Paint = function(self2, w, h)
            if !IsValid(self) then
                self2:Remove()
                gui.EnableScreenClicker(false)
                return
            end

            if !self.CustomizeButtons[self.CustomizeTab + 1].customize then return end

            surface.SetFont("ARC9_10")
            surface.SetDrawColor(ARC9.GetHUDColor("fg"))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))

            local ToAdd = {}
            local ToAdd2 = {}
            local ToAdd3 = {}
            for _, v in ipairs(trolling) do
                local act, hid = v.action, v.hidden
                if self.CustomizeHints[v.action] == "" then continue end
                if self.CustomizeHints[v.action] then hid = false end
                if hid then continue end
                if ARC9.CTRL_Lookup[v.glyph] then v.glyph = ARC9.CTRL_Lookup[v.glyph] end
                if ARC9.CTRL_ConvertTo[v.glyph] then v.glyph = ARC9.CTRL_ConvertTo[v.glyph] end
                if ARC9.CTRL_Exists[v.glyph] then v.glyph = Material("arc9/glyphs_light/" .. v.glyph .. "_lg" .. ".png", "smooth") end
                if v.glyph2 then
                    if ARC9.CTRL_Lookup[v.glyph2] then v.glyph2 = ARC9.CTRL_Lookup[v.glyph2] end
                    if ARC9.CTRL_ConvertTo[v.glyph2] then v.glyph2 = ARC9.CTRL_ConvertTo[v.glyph2] end
                    if ARC9.CTRL_Exists[v.glyph2] then v.glyph2 = Material("arc9/glyphs_light/" .. v.glyph2 .. "_lg" .. ".png", "smooth") end
                end

                if v.row3 then
                    table.insert(ToAdd3, { v.glyph, ARC9ScreenScale(12) })
                    if v.glyph2 then
                        table.insert(ToAdd3, " ")
                        table.insert(ToAdd3, { v.glyph2, ARC9ScreenScale(12) })
                    end
                    table.insert(ToAdd3, " " .. (self.CustomizeHints[v.action] or v.action) .. "    ")
                elseif v.row2 then
                    -- table.insert(ToAdd2, { v.glyph, ARC9ScreenScale(12) })
                    -- if v.glyph2 then
                    --     table.insert(ToAdd2, " ")
                    --     table.insert(ToAdd2, { v.glyph2, ARC9ScreenScale(12) })
                    -- end
                    -- table.insert(ToAdd2, " " .. (self.CustomizeHints[v.action] or v.action) .. "    ")
                else
                    table.insert(ToAdd, { v.glyph, ARC9ScreenScale(12) })
                    if v.glyph2 then
                        table.insert(ToAdd, " ")
                        table.insert(ToAdd, { v.glyph2, ARC9ScreenScale(12) })
                    end
                    table.insert(ToAdd, " " .. (self.CustomizeHints[v.action] or v.action) .. "    ")
                end
            end


            CreateControllerKeyLine({x = ARC9ScreenScale(8), y = ARC9ScreenScale(2), size = ARC9ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("hint"), unpack(ToAdd))

            local strreturn = CreateControllerKeyLine({x = self2:GetWide(), y = ARC9ScreenScale(2), size = ARC9ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("hint"), unpack(ToAdd3)) -- ghost     text only to get width
            CreateControllerKeyLine({x = self2:GetWide() - ARC9ScreenScale(8)-strreturn , y = ARC9ScreenScale(2), size = ARC9ScreenScale(10), font = "ARC9_10", font_keyb = "ARC9_KeybindPreview_Cust" }, ARC9.GetHUDColor("hint"), unpack(ToAdd3))

            table.Empty(self.CustomizeHints)
        end
    end
    -- self:CreateHUD_Bottom()
end

function SWEP:RemoveCustomizeHUD()
    if self.RemovingCustHud then return end

    local bg = self.CustomizeHUD

    local scrh = ScrH()
    local scrw = ScrW()

    if self.CustomizeHUD then
        self.RemovingCustHud = true
        if bg.nameplate then bg.nameplate:MoveTo(scrw/3, -ARC9ScreenScale(64), 0.7, 0, 0.05, nil) bg.nameplate:AlphaTo(0, 0.2, 0) end
        if bg.topleft_panel then bg.topleft_panel:MoveTo(-ARC9ScreenScale(70), -ARC9ScreenScale(40), 0.7, 0, 0.05, nil) bg.topleft_panel:AlphaTo(0, 0.2, 0) end
        if bg.topright_panel then bg.topright_panel:MoveTo(scrw, -ARC9ScreenScale(40), 0.7, 0, 0.05, nil) bg.topright_panel:AlphaTo(0, 0.2, 0) end
        if bg.lowerpanel then bg.lowerpanel:MoveTo(ARC9ScreenScale(19), scrh, 0.7, 0, 0.05, nil) bg.lowerpanel:AlphaTo(0, 0.2, 0) end
        if bg.hintspanel then bg.hintspanel:MoveTo(ARC9ScreenScale(19), scrh, 0.7, 0, 0.05, nil) bg.hintspanel:AlphaTo(0, 0.1, 0) end
        -- if self.TabPanel then self.TabPanel:AlphaTo(0, 0.1, 0) end

        self:ClosePresetMenu()

        gui.EnableScreenClicker(false)

        timer.Simple(0.1, function()
            if !IsValid(self) then return end
            self.CustomizeHUD:Remove()
            self.CustomizeHUD = nil
            self.RemovingCustHud = nil
        end)
    end
end

function SWEP:DrawCustomizeHUD()
    local customize = self:GetCustomize()

    if self.CustomizeHUD and !IsValid(self.CustomizeHUD) then
        self:RemoveCustomizeHUD()
    end

    if customize and !self.CustomizeHUD and !self.RemovingCustHud then
        self:CreateCustomizeHUD()
    elseif !customize and self.CustomizeHUD then
        self:RemoveCustomizeHUD()
    end

    lastcustomize = self:GetCustomize()
end

function SWEP:CreateHUD_RHP()
    local bg = self.CustomizeHUD
    if !IsValid(self) then return end

    local scrh = ScrH()
    local scrw = ScrW()

    local gr_h = scrh
    local gr_w = gr_h

    local nameplate = vgui.Create("DPanel", bg)
    self.CustomizeHUD.nameplate = nameplate
    nameplate:SetPos(scrw/3, -ARC9ScreenScale(64)) -- h = ARC9ScreenScale(8)
    nameplate:MoveTo(scrw/3, ARC9ScreenScale(8), 1, 0, 0.05, nil)
    nameplate:SetSize(scrw/3, ARC9ScreenScale(38))
    nameplate:MoveToBack()
    nameplate.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        -- if (self.CustomizeButtons[self.CustomizeTab + 1] or {}).inspect then return end

        surface.SetFont("ARC9_24")
        local tw = surface.GetTextSize(self.PrintName)

        surface.SetFont("ARC9_24")
        surface.SetTextPos(w/2 - tw/2, 0)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(self.PrintName)

        -- class
        surface.SetFont("ARC9_12")
        local tw2 = surface.GetTextSize(self.Class)

        surface.SetFont("ARC9_12")
        surface.SetTextPos(w/2 - tw2/2, ARC9ScreenScale(25))
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(self.Class)

        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        surface.DrawRect(w/2 - tw2/2, ARC9ScreenScale(23), tw2, ARC9ScreenScale(1.5))
    end

    self.CustomizeAlphaBuffer = CurTime() + 1

    local inspectalpha = function(self2, panel, minusnum)
        if self.CustomizeButtons[self.CustomizeTab + 1].inspect then -- probably horrible
            if self2:IsHovered() or (self.CustomizeAlphaBuffer or 0) > CurTime() then
                panel:SetAlpha(math.min(panel:GetAlpha() + 25, 255))
            else
                panel:SetAlpha(math.max(panel:GetAlpha() - minusnum, 0)) -- * number of cust buttons
            end
        end
    end

    local topleft_panel = vgui.Create("DPanel", bg)
    self.CustomizeHUD.topleft_panel = topleft_panel
    topleft_panel:SetPos(-ARC9ScreenScale(70), -ARC9ScreenScale(40)) -- w = 0, h = 0
    topleft_panel:MoveTo(0, 0, 0.4, 0, 0.1, nil)
    topleft_panel:SetSize(ARC9ScreenScale(70), ARC9ScreenScale(40))
    topleft_panel:MoveToBack()
    topleft_panel.Paint = function(self2, w, h) end

    local topleft_settings = vgui.Create("ARC9TopButton", topleft_panel)
    topleft_settings:SetPos(ARC9ScreenScale(19), ARC9ScreenScale(19))
    topleft_settings.DoClick = function(self2)
        surface.PlaySound(popupsound)
        ARC9_OpenSettings()

        -- self:ToggleCustomize(false)
        -- bg:SetMouseInputEnabled(false)
    end

    local topleft_light = vgui.Create("ARC9TopButton", topleft_panel)
    topleft_light:SetPos(ARC9ScreenScale(47.5), ARC9ScreenScale(19))
    topleft_light:SetIcon(Material("arc9/ui/light.png", "mips smooth"))
    topleft_light:SetIsCheckbox(true)
    topleft_light:SetConVar("arc9_cust_light")
    topleft_light:SetValue(GetConVar("arc9_cust_light"):GetBool())
    local oldlightdoclick = topleft_light.DoClick
    topleft_light.DoClick = function(self2)
        oldlightdoclick(self2)
        surface.PlaySound(self2:GetChecked() and lightoffsound or lightonsound)
    end

    topleft_settings.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topleft_panel, 8) end
    topleft_light.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topleft_panel, 8) end

    local topright_panel = vgui.Create("DPanel", bg)
    self.CustomizeHUD.topright_panel = topright_panel
    topright_panel:SetPos(scrw, -ARC9ScreenScale(40)) -- w = scrw-ARC9ScreenScale(170), h = 0
    topright_panel:MoveTo(scrw-ARC9ScreenScale(170), 0, 0.4, 0, 0.1, nil)
    topright_panel:SetSize(ARC9ScreenScale(170), ARC9ScreenScale(40))
    topright_panel:MoveToBack()
    topright_panel.Paint = function(self2, w, h) end

    if self.Attachments[1] then -- no presets if no atts
        local topright_presets = vgui.Create("ARC9TopButton", topright_panel)
        self.CustomizeHUD.topright_panel.topright_presets = topright_presets
        surface.SetFont("ARC9_16")
        local tw = surface.GetTextSize("Presets")
        topright_presets:SetPos(ARC9ScreenScale(123)-(ARC9ScreenScale(28)+tw), ARC9ScreenScale(19))
        topright_presets:SetSize(ARC9ScreenScale(28)+tw, ARC9ScreenScale(21))
        topright_presets:SetIcon(Material("arc9/ui/presets.png", "mips"))
        topright_presets:SetButtonText("Presets")
        topright_presets:SetIsCheckbox(true)
        local oldpresetsdoclick = topright_presets.DoClick
        topright_presets.DoClick = function(self2)
            surface.PlaySound(self2:GetChecked() and backsound or opensound)

            oldpresetsdoclick(self2)

            self.CustomizeHUD.lowerpanel.Extended = nil
            self.BottomBarMode = 0

            self:CreatePresetMenu()
        end

        topright_presets.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topright_panel, 8) end
    end

    local topright_close = vgui.Create("ARC9TopButton", topright_panel)
    topright_close:SetPos(ARC9ScreenScale(130), ARC9ScreenScale(19))
    topright_close:SetIcon(Material("arc9/ui/close.png", "mips smooth"))
    topright_close.DoClick = function(self2)
        surface.PlaySound(clicksound)
        surface.PlaySound(closesound)
        self:SetCustomize(false)
        net.Start("ARC9_togglecustomize")
        net.WriteBool(false)
        net.SendToServer()
    end

    topright_close.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.topright_panel, 8) end


    local lowerpanel = vgui.Create("DPanel", bg)
    self.CustomizeHUD.lowerpanel = lowerpanel
    lowerpanel:SetPos(ARC9ScreenScale(19), scrh) -- h = scrh-ARC9ScreenScale(93)
    -- lowerpanel:MoveTo(ARC9ScreenScale(19), scrh-ARC9ScreenScale(93), 0.6, 0, 0.1, nil) -- CustomizeTab does this for us
    lowerpanel:SetSize(scrw - ARC9ScreenScale(38), ARC9ScreenScale(74))
    lowerpanel:MoveToBack()


    if !self.Attachments[1] and self.CustomizeButtons[1].customize then  -- NO ATTS CUST PANEL REMOVAL
        table.remove(self.CustomizeButtons, 1)
        self.CustomizeButtons[1].cutcorner = 1
        self.CustomizeTab = 0
    end


    local barlength = -ARC9ScreenScale(1.5)
    local cornercut = ARC9ScreenScale(3.5)
    local inspecttextwidth = 0

    for i, btn in pairs(self.CustomizeButtons) do
        local custtabbtn = vgui.Create("DButton", lowerpanel)
        --
        surface.SetFont("ARC9_12")
        local titlewidth = surface.GetTextSize(btn.title) + ARC9ScreenScale(12.5)
        --

        if btn.inspect then
            custtabbtn:SetPos(scrw - ARC9ScreenScale(38) - titlewidth, 0)
            inspecttextwidth = titlewidth
        else
            barlength = barlength + titlewidth + ARC9ScreenScale(1.5)
            custtabbtn:SetPos(barlength - titlewidth, 0)
        end

        custtabbtn:SetSize(titlewidth, ARC9ScreenScale(14.5))
        custtabbtn.title = btn.title
        custtabbtn.page = i - 1
        custtabbtn.func = btn.func
        custtabbtn:SetText("")


        custtabbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            local mainbuttoncolor = ARC9.GetHUDColor("bg")
            local barbuttoncolor = ARC9.GetHUDColor("bg")
            local buttontextcolor = ARC9.GetHUDColor("fg")

            if self.CustomizeTab == self2.page then
                mainbuttoncolor = ARC9.GetHUDColor("hi")
                barbuttoncolor = ARC9.GetHUDColor("hi")
                buttontextcolor = ARC9.GetHUDColor("shadow")
            end

            if self2:IsHovered() then
                barbuttoncolor = ARC9.GetHUDColor("hi")
                if self.CustomizeTab != self2.page then self.CustomizeHints["Select"] = "Open" end
            end

            surface.SetDrawColor(mainbuttoncolor)
            draw.NoTexture()

            local hcutted = ARC9ScreenScale(11.5)

            if btn.cutcorner == 1 then
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = cornercut}, {x = cornercut, y = 0}, {x = w, y = 0}, {x = w, y = hcutted}})
            elseif btn.cutcorner == 2 then
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = 0}, {x = w-cornercut, y = 0}, {x = w, y = cornercut}, {x = w, y = hcutted}})
            elseif btn.cutcorner == 3 then
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = cornercut}, {x = cornercut, y = 0}, {x = w-cornercut, y = 0}, {x = w, y = cornercut}, {x = w, y = hcutted}})
            else
                surface.DrawPoly({{x = 0, y = hcutted}, {x = 0, y = 0}, {x = w, y = 0}, {x = w, y = hcutted}})
            end

            surface.SetDrawColor(barbuttoncolor)
            surface.DrawRect(0, h - ARC9ScreenScale(1.5), w, h)

            surface.SetFont("ARC9_12")
            local tw = surface.GetTextSize(self2.title)

            surface.SetTextColor(buttontextcolor)
            -- surface.SetTextPos((w - tw) / 2, -ARC9ScreenScale(0.75))
            surface.SetTextPos((w - tw) / 2, 0)
            surface.DrawText(self2.title)
        end
        custtabbtn.Think = function(self2) if !IsValid(self) then return end inspectalpha(self2, self.CustomizeHUD.lowerpanel, 3) end
        custtabbtn.DoClick = function(self2)
            self.LastCustomizeTab = self.CustomizeTab
            self.CustomizeTab = self2.page
            self2.func(self, self2.page)
            surface.PlaySound(tabsound)
        end
        custtabbtn.OnCursorEntered = function(self2)
            surface.PlaySound(hoversound)
        end
        -- custtabbtn.DoRightClick = function(self2)
        --     self.CustomizeTab = 0
        --     self:ClearTabPanel()
        -- end


        lowerpanel.Paint = function(self2, w, h)
            surface.SetDrawColor(ARC9.GetHUDColor("bg"))

            surface.DrawRect(barlength + ARC9ScreenScale(1.5), ARC9ScreenScale(12.75), w - barlength - inspecttextwidth - ARC9ScreenScale(3.2), ARC9ScreenScale(1.75)) -- bar spacer

            draw.NoTexture()

            if self2.Extended then
                surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = ARC9ScreenScale(15.5+60)}, {x = w*0.5-ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w*0.5-ARC9ScreenScale(0.75), y = h}})

                surface.DrawRect(0, ARC9ScreenScale(15.5+60-2.5), w*0.5-ARC9ScreenScale(0.5), ARC9ScreenScale(1.5))

                surface.DrawRect(0, ARC9ScreenScale(15.5), w, ARC9ScreenScale(60-3.5))

                surface.SetDrawColor(self2.HasPros and ARC9.GetHUDColor("bg_pro") or ARC9.GetHUDColor("bg"))
                surface.DrawPoly({{x = w*0.5+ARC9ScreenScale(0.75), y = h}, {x = w*0.5+ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w*0.75-ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w*0.75-ARC9ScreenScale(0.75), y = h}})

                surface.SetDrawColor(self2.HasPros and ARC9.GetHUDColor("pro") or ARC9.GetHUDColor("bg"))
                surface.DrawRect(w*0.5+ARC9ScreenScale(0.75), ARC9ScreenScale(15.5+60-2.5), w*0.25-ARC9ScreenScale(1), ARC9ScreenScale(1.5))

                surface.SetDrawColor(self2.HasCons and ARC9.GetHUDColor("bg_con") or ARC9.GetHUDColor("bg"))
                surface.DrawPoly({{x = w*0.75+ARC9ScreenScale(0.75), y = h}, {x = w*0.75+ARC9ScreenScale(0.75), y = ARC9ScreenScale(15.5+60)}, {x = w, y = ARC9ScreenScale(15.5+60)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})

                surface.SetDrawColor(self2.HasCons and ARC9.GetHUDColor("con") or ARC9.GetHUDColor("bg"))
                surface.DrawRect(w*0.75+ARC9ScreenScale(1), ARC9ScreenScale(15.5+60-2.5), w*0.25, ARC9ScreenScale(1.5))
            else
                surface.DrawPoly({{x = cornercut, y = h},{x = 0, y = h-cornercut}, {x = 0, y = ARC9ScreenScale(15.5)}, {x = w, y = ARC9ScreenScale(15.5)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}})
            end

            -- thingy at bottom
            surface.SetDrawColor(ARC9.GetHUDColor("hi"))
            surface.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = cornercut, y = h-cornercut*.5}})
            surface.DrawPoly({{x = w, y = h-cornercut}, {x = w-cornercut, y = h}, {x = w-cornercut, y = h-cornercut*.5}})
            surface.DrawPoly({{x = cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h}, {x = cornercut, y = h}, })
        end
    end

    self.CustomizeButtons[self.CustomizeTab + 1].func(self)

    if DevMode then
        self:DevStuffMenu()
    end
end