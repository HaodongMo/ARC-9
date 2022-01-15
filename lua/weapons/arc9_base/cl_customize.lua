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

function SWEP:RefreshCustomizeMenu()
end

function SWEP:CreateCustomizeHUD()
    local bg = vgui.Create("DPanel")

    self.CustomizeHUD = bg

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

    self:CreateHUD_Stats()
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