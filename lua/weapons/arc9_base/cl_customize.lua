local mat_grad = Material("arc9/gradient.png")

function SWEP:MultiLineText(text, maxw, font)
    local content = {}
    local tline = ""
    local x = 0
    surface.SetFont(font)

    local newlined = string.Split(text, "\n")

    for _, line in pairs(newlined) do
        local words = string.Split(line, " ")

        for _, word in pairs(words) do
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

local lastlmbdown = false
local lastrmbdown = false

local lastmousex = 0
local lastmousey = 0

local dragging = false
local dragging_r = false

SWEP.CustomizePanX = 0
SWEP.CustomizePanY = 0

SWEP.CustomizePitch = 0
SWEP.CustomizeYaw = 0

SWEP.CustomizeZoom = 0

function SWEP:CreateCustomizeHUD()
    local bg = vgui.Create("DPanel")

    self.CustomizeHUD = bg

    gui.EnableScreenClicker(true)

    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg.OnRemove = function(self2)
        if !IsValid(self) then return end
        -- self:SavePreset()
    end
    bg.OnMouseWheeled = function(self2, sd)
        self.CustomizeZoom = self.CustomizeZoom - (sd * 2)

        self.CustomizeZoom = math.Clamp(self.CustomizeZoom, -32, 32)
    end
    bg:SetMouseInputEnabled(true)
    bg.Paint = function(self2, w, h)
        if !IsValid(self) then
            self2:Remove()
            gui.EnableScreenClicker(false)
        end

        surface.SetMaterial(mat_grad)
        surface.SetDrawColor(0, 0, 0, 250)
        surface.DrawTexturedRect(w - h, 0, h, h)

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

            cam.Start3D(nil, nil, self:GetViewModelFOV())

            for _, slot in pairs(self:GetSubSlotList()) do
                if self:GetSlotBlocked(slot) then continue end
                local attpos = self:GetAttPos(slot)

                local icon_offset = slot.Icon_Offset or Vector(0, 0, 0)

                attpos = attpos + EyeAngles():Right() * -icon_offset.x
                attpos = attpos + EyeAngles():Up() * icon_offset.y
                attpos = attpos + EyeAngles():Forward() * icon_offset.z

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
                    for _, bump in pairs(bumpy) do
                        if isinaabb(bump.x, bump.y) then
                            local d2 = math.Distance(bump.x, bump.y, mousex, mousey)

                            if d2 < dist then
                                hoveredslot = false
                                break
                            end
                        end
                    end
                end

                table.insert(bumpy, {x = x, y = y, slot = slot})

                -- if self2:IsHovered() then
                -- end

                local col = ARC9.GetHUDColor("fg")

                if hoveredslot then
                    col = ARC9.GetHUDColor("hi")
                end

                surface.SetMaterial(mat_circle)
                surface.SetDrawColor(col)
                surface.DrawTexturedRect(x, y, s, s)

                local atttxt = slot.PrintName or "SLOT"

                if slot.Installed then
                    local atttbl = self:GetFinalAttTable(slot)
                    atttxt = ARC9:GetPhraseForAtt(slot.Installed, "CompactName")
                    atttxt = atttxt or ARC9:GetPhraseForAtt(slot.Installed, "PrintName") or ""
                    surface.SetMaterial(atttbl.Icon)
                    surface.SetDrawColor(col)
                    surface.DrawTexturedRect(x + ScreenScale(1), y + ScreenScale(1), s - ScreenScale(2), s - ScreenScale(2))
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

                if hoveredslot then
                    anyhovered = true
                    if input.IsMouseDown(MOUSE_LEFT) and !lastlmbdown and (self.BottomBarAddress != slot.Address or self.BottomBarMode != 1) then
                        self.BottomBarMode = 1
                        self.BottomBarAddress = slot.Address
                        self:CreateHUD_Bottom()

                        self.CustomizePanX = 0
                        self.CustomizePanY = 0
                    elseif input.IsMouseDown(MOUSE_RIGHT) and !lastrmbdown then
                        self:Detach(slot.Address)
                    end
                end

                cam.End2D()
            end

            cam.End3D()

        end

        if !anyhovered then
            if input.IsMouseDown(MOUSE_LEFT) and !lastlmbdown then
                dragging = true
                lastmousex, lastmousey = input.GetCursorPos()
            elseif input.IsMouseDown(MOUSE_RIGHT) and !lastrmbdown then
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
                dragging = false
            else
                local mousex, mousey = input.GetCursorPos()

                local dx = mousex - lastmousex
                local dy = mousey - lastmousey

                self.CustomizePitch = self.CustomizePitch - (dx / ScreenScale(4))
                self.CustomizeYaw = math.Clamp(self.CustomizeYaw + (dy / ScreenScale(8)) * (math.floor(self.CustomizePitch / 90) % 2 == 0 and 1 or -1), -30, 30)

            end
        end

        lastmousex, lastmousey = input.GetCursorPos()

        lastlmbdown = input.IsMouseDown(MOUSE_LEFT)
        lastrmbdown = input.IsMouseDown(MOUSE_RIGHT)
    end

    self:CreateHUD_RHP()

    bg:MoveToFront()

    self:CreateHUD_Bottom()
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

    for i, btn in pairs(self.CustomizeButtons) do
        local newbtn = vgui.Create("DButton", bg)
        newbtn:SetPos(ScrW() - ScreenScale(6) - (ScreenScale(69) * i), ScreenScale(58))
        newbtn:SetSize(ScreenScale(64), ScreenScale(12))
        newbtn.title = btn.title
        newbtn.page = i - 1
        newbtn.func = btn.func
        newbtn:SetText("")
        newbtn.Paint = function(self2, w, h)
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
            self.CustomizeTab = self2.page
            self2.func(self)
        end
        newbtn.DoRightClick = function(self2)
            self.CustomizeTab = 0
            self:ClearTabPanel()
        end
    end

    self.CustomizeButtons[self.CustomizeTab + 1].func(self)
end