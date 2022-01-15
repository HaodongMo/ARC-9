local function multlinetext(text, maxw, font)
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

local function PaintScrollBar(panel, w, h)
    local ss = ScreenScale(2)
    local s = ss * 2
    draw.RoundedBox(ss * 1, (w - s) / 2, 0, s, h, col_fg)
end

// span: panel that hosts the rotating text
// txt: the text to draw
// x: where to start the crop
// y: where to start the crp
// tx, ty: where to draw the text
// maxw: maximum width
// only: don't advance text
local function DrawTextRot(span, txt, x, y, tx, ty, maxw, only)
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

local mat_circle = Material("ARC9/circle.png", "mips smooth")

local col_hi = Color(255, 237, 193)
local col_lo = Color(255, 255, 255)

function SWEP:RefreshCustomizeMenu()
    if !self.CustomizeHUD then return end

    self:CreateCustomizeBoxes(self.CustomizeHUD)
    if self.CustomizeSelectAddr then
        self:CreateCustomizeSelectMenu(self.CustomizeHUD, self:LocateSlotFromAddress(self.CustomizeSelectAddr))
    end
end

function SWEP:CreateCustomizeBoxes(panel)
    for _, i in pairs(self.CustomizeBoxes or {}) do
        i:Remove()
    end

    self.CustomizeBoxes = {}

    for _, i in pairs(self:GetSubSlotList()) do
        local cbox = vgui.Create("DPanel", panel)
        cbox.slottbl = i

        cbox:SetSize(ScreenScale(32), ScreenScale(40))
        cbox:SetPos(0, 0)
        cbox.Paint = function(self2, w, h)
            local apos, aang = self:GetAttPos(self2.slottbl, false)
            apos = apos + (aang:Up() * 3.5)
            local col1 = col_hi

            if self:GetSlotBlocked(self2.slottbl) and !self2.slottbl.Installed then
                col1 = Color(255, 100, 100)
            end

            cam.Start3D(nil, nil, self.ViewModelFOV)
            local screenpos = apos:ToScreen()
            cam.End3D()

            local sx = screenpos.x
            local sy = screenpos.y

            sx = sx - (cbox:GetWide() * 0.5)
            sy = sy - (cbox:GetTall() * 0.9)

            sx = math.Clamp(sx, 0, ScrW() - ScreenScale(32))
            sy = math.Clamp(sy, 0, ScrH() - ScreenScale(40))

            self2:SetPos(sx, sy)

            surface.SetDrawColor(col1)
            surface.SetMaterial(mat_circle)
            local s = ScreenScale(8)
            surface.DrawTexturedRect((w - s) / 2, h - s, s, s)
        end

        cbox:Paint(0, 0)

        csquare = vgui.Create("DPanel", cbox)
        csquare.slottbl = i
        csquare:SetSize(ScreenScale(32), ScreenScale(32))
        csquare:SetPos(0, 0)
        csquare.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                if !self:GetSlotBlocked(self2.slottbl) or self2.slottbl.Installed then
                    if self:CreateCustomizeSelectMenu(panel, self2.slottbl) then
                        self.CustomizeSelectAddr = self2.slottbl.Address
                        self:CreateCustomizeBoxes(panel)
                    end
                end
            elseif kc == MOUSE_RIGHT then
                if self:Detach(self2.slottbl.Address) then
                    self.CustomizeSelectAddr = self2.slottbl.Address
                    self:CreateCustomizeBoxes(panel)
                    self:CreateCustomizeSelectMenu(panel)
                end
            end
        end
        csquare.Paint = function(self2, w, h)
            local col1 = Color(0, 0, 0, 150)
            local col2 = col_hi
            local col3 = Color(255, 255, 255)

            if self2:IsHovered() then
                col1 = Color(100, 100, 100, 150)
                col2 = Color(0, 0, 0, 255)
                col3 = Color(50, 50, 50)
            end

            if self:GetSlotBlocked(self2.slottbl) and !self2.slottbl.Installed then
                col1 = Color(50, 0, 0, 150)
                col2 = Color(255, 100, 100)
                col3 = Color(200, 0, 0)
            end

            surface.SetDrawColor(col1)
            surface.DrawRect(0, 0, w, h)

            if self2.slottbl.Installed then
                local atttbl = ARC9.GetAttTable(self2.slottbl.Installed)

                surface.SetDrawColor(col3)
                surface.SetMaterial(atttbl.Icon)
                surface.DrawTexturedRect(0, 0, w, h)
            end

            local txt = self2.slottbl.PrintName or ""

            if self2.slottbl.Installed then
                local atttbl = ARC9.GetAttTable(self2.slottbl.Installed)

                txt = atttbl.CompactName or atttbl.PrintName or atttbl.ShortName
            end

            surface.SetTextColor(col2)
            surface.SetFont("ARC9_6")
            -- local tw = surface.GetTextSize(txt)
            -- surface.SetTextPos(0, 0)
            -- surface.DrawText(txt)
            DrawTextRot(self2, txt, 0, ScreenScale(32 - 6 - 1), ScreenScale(2), ScreenScale(32 - 6 - 1), ScreenScale(32))

            surface.SetDrawColor(col2)

            local outlines = ScreenScale(0.25)

            for j = 0, math.ceil(outlines) do
                surface.DrawOutlinedRect(j, j, w - (2 * j), h - (2 * j))
            end
        end

        table.insert(self.CustomizeBoxes, cbox)
    end
end

SWEP.CustomizeSelectAddr = nil
SWEP.CustomizeSelectMenu = nil

function SWEP:CreateCustomizeSelectMenu(panel, slottbl)
    if self.CustomizeSelectMenu then
        self.CustomizeSelectMenu:Remove()
        self.CustomizeSelectMenu = nil
    end

    if !slottbl then return end

    local bg = vgui.Create("DPanel", panel)

    bg:SetSize(ScreenScale(96), ScrH() - ScreenScale(32))
    bg:SetPos(ScreenScale(16), ScreenScale(16))
    bg.Paint = function(self2, w, h)
        local col1 = Color(0, 0, 0, 150)
        local col2 = col_hi

        surface.SetDrawColor(col1)
        surface.DrawRect(0, ScreenScale(18), w, h)

        surface.SetDrawColor(col2)
        surface.DrawLine(0, ScreenScale(18), w, ScreenScale(18))

        surface.SetTextColor(col_hi)
        surface.SetTextPos(ScreenScale(4), 0)
        surface.SetFont("ARC9_16")
        DrawTextRot(self2, slottbl.PrintName or "Attachment", 0, 0, ScreenScale(4), 0, ScreenScale(96), false)
    end

    -- Menu for attachments
    attmenu = vgui.Create("DScrollPanel", bg)
    attmenu:SetPos(0, ScreenScale(18))
    attmenu:SetSize(ScreenScale(96), ScrH() - ScreenScale(32 + 18))

    -- attmenu.Paint = function(self2, w, h)
    --     draw.RoundedBox(2, 0, 0, w, h, col_fg)
    -- end

    local scroll_2 = attmenu:GetVBar()
    -- scroll_2.AlreadySet = false
    -- scroll_2.Paint = function(self2, w, h)
    --     if !self2.AlreadySet then
    --         self2:SetScroll(self.Inv_Scroll[self.Inv_SelectedSlot or 0] or 0)
    --         self2.AlreadySet = true
    --     end

    --     local scroll = self2:GetScroll()

    --     self.Inv_Scroll[self.Inv_SelectedSlot or 0] = scroll
    -- end

    scroll_2.btnUp.Paint = function(span, w, h)
    end
    scroll_2.btnDown.Paint = function(span, w, h)
    end
    scroll_2.btnGrip.Paint = PaintScrollBar

    local slot = slottbl

    if !slot then return end

    local atts = ARC9.GetAttsForCats(slottbl.Category or "")

    table.sort(atts, function(a, b)
        a = a or ""
        b = b or ""

        if a == "" or b == "" then return true end

        local atttbl_a = ARC9.GetAttTable(a)
        local atttbl_b = ARC9.GetAttTable(b)

        local order_a = 0
        local order_b = 0

        order_a = atttbl_a.SortOrder or order_a
        order_b = atttbl_b.SortOrder or order_b

        if order_a == order_b then
            return (atttbl_a.PrintName or "") < (atttbl_b.PrintName or "")
        end

        return order_a < order_b
    end)

    for i, att in pairs(atts) do
        local atttbl = ARC9.GetAttTable(att)

        local attbtn = vgui.Create("DScrollPanel", attmenu)
        attbtn:SetSize(ScreenScale(96), ScreenScale(12))
        attbtn:Dock(TOP)
        attbtn.att = att
        attbtn.slottbl = slottbl
        attbtn.address = slottbl.Address
        attbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                self:Attach(self2.slottbl.Address, self2.att)
                self.CustomizeSelectAddr = self2.slottbl.Address
                self:RefreshCustomizeMenu()
            elseif kc == MOUSE_RIGHT then
                self:Detach(self2.slottbl.Address)
                self.CustomizeSelectAddr = self2.slottbl.Address
                self:RefreshCustomizeMenu()
            end
        end
        attbtn.Paint = function(self2, w, h)
            surface.SetDrawColor(col_hi)
            surface.DrawLine(0, h-1, w, h-1)

            local attached = self2.slottbl.Installed == self2.att

            local col1 = Color(0, 0, 0, 150)
            local col2 = col_hi

            if self2:IsHovered() or attached then
                col1 = col_hi
                col2 = Color(0, 0, 0, 255)
            end

            if self2:IsHovered() and attached then
                col1 = col_lo
                col2 = Color(0, 0, 0, 255)
            end

            local canattach = self:CanAttach(self2.slottbl.Address, self2.att, self2.slottbl.slottbl)

            if !canattach then
                col1 = Color(50, 0, 0, 150)
                col2 = Color(255, 100, 100)
                col3 = Color(200, 0, 0)
            end

            surface.SetDrawColor(col1)
            surface.DrawRect(0, 0, w, h)

            local icon = atttbl.Icon

            surface.SetDrawColor(col2)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(0, 0, ScreenScale(12), ScreenScale(12))

            surface.SetTextColor(col2)
            surface.SetTextPos(ScreenScale(13), 0)
            surface.SetFont("ARC9_12")
            DrawTextRot(self2, atttbl.CompactName or atttbl.PrintName or atttbl.ShortName, ScreenScale(12), 0, ScreenScale(13), 0, ScreenScale(96 - 12), false)
        end
    end

    self.CustomizeSelectMenu = bg
end

SWEP.MenuRotation = Angle(0, 0, 0)
SWEP.MenuPan = Vector(0, 0, 0)
SWEP.MenuRotating = false
SWEP.MenuZooming = false
SWEP.LastMouseX = 0
SWEP.LastMouseY = 0

function SWEP:CreateCustomizeHUD()
    self:RemoveCustomizeHUD()

    self.MenuRotation = Angle(0, 0, 0)
    self.MenuPan = Vector(0, 0, 0)
    self.MenuRotating = false
    self.MenuZooming = false

    gui.EnableScreenClicker(true)

    local bg = vgui.Create("DPanel")

    self.CustomizeHUD = bg

    local scrw = ScrW()
    local scrh = ScrH()

    local airgap = ScreenScale(8)
    local smallgap = ScreenScale(4)

    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg.OnRemove = function(self2)
        if !IsValid(self) then return end
        -- self:SavePreset()
    end
    bg.OnMousePressed = function(self2, kc)
        if kc == MOUSE_LEFT then
            self.MenuRotating = true
            self.LastMousePos = Vec

            self.LastMouseX, self.LastMouseY = input.GetCursorPos()
        elseif kc == MOUSE_RIGHT then
            self.MenuZooming = true
            self.LastMousePos = Vec

            self.LastMouseX, self.LastMouseY = input.GetCursorPos()
        end
    end
    bg.OnMouseWheeled = function(self2, sd)
        self.MenuPan = self.MenuPan + Vector(0, 0, sd)
    end

    bg.Paint = function(self2, w, h)
        if !IsValid(self) then
            self:Remove()
            gui.EnableScreenClicker(false)
        end

        local name_txt = self:GetValue("PrintName")

        surface.SetFont("ARC9_16")
        local name_w = surface.GetTextSize(name_txt)
        surface.SetTextPos(w - name_w - ScreenScale(14), airgap)
        surface.SetTextColor(0, 0, 0)
        surface.DrawText(name_txt)

        if self.MenuRotating or self.MenuZooming then
            if !input.IsMouseDown(MOUSE_LEFT) then
                self.MenuRotating = false
            end
            if !input.IsMouseDown(MOUSE_RIGHT) then
                self.MenuZooming = false
            end

            local mousex, mousey = input.GetCursorPos()

            local dx = mousex - self.LastMouseX
            local dy = mousey - self.LastMouseY

            dx = dx * 200 / ScrW()
            dy = dy * 200 / ScrW()

            if self.MenuRotating then
                self.MenuRotation = self.MenuRotation + Angle(dx, dy, 0)
            end

            if self.MenuZooming then
                self.MenuPan = self.MenuPan + Vector(dx, dy, 0)
            end
            self.MenuRotation:Normalize()

            self.LastMouseX, self.LastMouseY = input.GetCursorPos()
        end
    end

    timer.Simple(0, function()
        self:RefreshCustomizeMenu()
    end)
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