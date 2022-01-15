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

SWEP.CustomizeTab = 0

SWEP.CustomizeButtons = {
    {
        title = "Hide",
        func = function(self2)
            self2:ClearTabPanel()
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
end

function SWEP:RefreshCustomizeMenu()
end

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
    bg.Paint = function(self2, w, h)
        if !IsValid(self) then
            self:Remove()
            gui.EnableScreenClicker(false)
        end
    end

    self:CreateHUD_RHP()
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

    local gradient = vgui.Create("DPanel", bg)
    gradient:SetPos(ScrW() - gr_w, 0)
    gradient:SetSize(gr_w, gr_h)
    gradient.Paint = function(self2, w, h)
        surface.SetMaterial(mat_grad)
        surface.SetDrawColor(0, 0, 0, 250)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local nameplate = vgui.Create("DPanel", bg)
    nameplate:SetPos(0, ScreenScale(8))
    nameplate:SetSize(ScrW(), ScreenScale(64))
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
        surface.DrawRect(w - ScreenScale(356 - 1), ScreenScale(42 + 1), ScreenScale(343), ScreenScale(1))

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(w - ScreenScale(356), ScreenScale(42), ScreenScale(343), ScreenScale(1))
    end

    for i, btn in pairs(self.CustomizeButtons) do
        local newbtn = vgui.Create("DButton", bg)
        newbtn:SetPos(ScrW() - ScreenScale(6) - (ScreenScale(70) * i), ScreenScale(58))
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
    end

    self.CustomizeButtons[self.CustomizeTab + 1].func(self)
end