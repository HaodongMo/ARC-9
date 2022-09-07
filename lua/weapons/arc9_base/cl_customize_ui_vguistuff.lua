local ARC9ScreenScale = ARC9.ScreenScale

local hoversound = "ui/panorama/itemtile_rollover_09.wav"
local clicksound = "ui/panorama/itemtile_click_02.wav"

local ARC9TopButton = {}
ARC9TopButton.Color = ARC9.GetHUDColor("fg")
ARC9TopButton.ColorClicked = ARC9.GetHUDColor("hi")
ARC9TopButton.Icon = Material("arc9/ui/settings.png", "mips")

ARC9TopButton.MatIdle = Material("arc9/ui/topbutton.png", "mips")
ARC9TopButton.MatHovered = Material("arc9/ui/topbutton_hover.png", "mips")

ARC9TopButton.MatIdleL = Material("arc9/ui/topbutton_l.png", "mips")
ARC9TopButton.MatHoveredL = Material("arc9/ui/topbutton_hover_l.png", "mips")
ARC9TopButton.MatIdleM = Material("arc9/ui/topbutton_m.png", "mips")
ARC9TopButton.MatHoveredM = Material("arc9/ui/topbutton_hover_m.png", "mips")
ARC9TopButton.MatIdleR = Material("arc9/ui/topbutton_r.png", "mips")
ARC9TopButton.MatHoveredR = Material("arc9/ui/topbutton_hover_r.png", "mips")

function ARC9TopButton:Init()
	self:SetText("")
    self:SetSize(ARC9ScreenScale(21), ARC9ScreenScale(21))
end

function ARC9TopButton:Paint(w, h)
	local color = self.Color
	local iconcolor = self.Color
	local icon = self.Icon
	local text = self.ButtonText

	local mat = self.MatIdle
	local matl = self.MatIdleL
	local matm = self.MatIdleM
	local matr = self.MatIdleR

	if self:IsHovered() then
		color = self.ColorClicked
		mat = self.MatHovered
		matl = self.MatHoveredL
		matm = self.MatHoveredM
		matr = self.MatHoveredR
	end
    
	if self:IsDown() or (self.Checkbox and self:GetChecked()) then
		iconcolor = self.ColorClicked
	end

    surface.SetDrawColor(color)

    if text then -- wide button
        surface.SetMaterial(matl)
        surface.DrawTexturedRect(0, 0, h/2, h)
        surface.SetMaterial(matm)
        surface.DrawTexturedRect(h/2, 0, w-h, h)
        surface.SetMaterial(matr)
        surface.DrawTexturedRect(w-h/2, 0, h/2, h)

        surface.SetFont(self.Font or "ARC9_16")
        local tw = surface.GetTextSize(text)
        surface.SetTextColor(iconcolor)
        surface.SetTextPos(h, h/8)
        surface.DrawText(text)
    else
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
    end

	surface.SetDrawColor(iconcolor)
    surface.SetMaterial(icon)
    surface.DrawTexturedRect(h/5, h/5, h-h/2.5, h-h/2.5)
end

function ARC9TopButton:OnCursorEntered() 
    surface.PlaySound(hoversound)
end

function ARC9TopButton:SetIcon(mat)
    self.Icon = mat
end

function ARC9TopButton:SetButtonText(text, font)
    self.ButtonText = text
    self.Font = font 
end

function ARC9TopButton:SetIsCheckbox(bool)
    self.Checkbox = bool
end

vgui.Register("ARC9TopButton", ARC9TopButton, "DCheckBox") -- DButton

local ARC9AttButton = {}

ARC9AttButton.Color = ARC9.GetHUDColor("fg")
ARC9AttButton.ColorClicked = ARC9.GetHUDColor("hi")
ARC9AttButton.ColorBlock = ARC9.GetHUDColor("con")
ARC9AttButton.Icon = Material("arc9/ui/settings.png", "mips")

ARC9AttButton.MatIdle = Material("arc9/ui/att.png", "mips")
ARC9AttButton.MatEmpty = Material("arc9/ui/att_empty.png", "mips")
ARC9AttButton.MatHover = Material("arc9/ui/att_hover.png", "mips")
ARC9AttButton.MatBlock = Material("arc9/ui/att_block.png", "mips")

ARC9AttButton.MatMarkerInstalled = Material("arc9/ui/mark_installed.png", "mips smooth")
ARC9AttButton.MatMarkerLock = Material("arc9/ui/mark_lock.png", "mips smooth")
ARC9AttButton.MatMarkerModes = Material("arc9/ui/mark_modes.png", "mips smooth")
ARC9AttButton.MatMarkerSlots = Material("arc9/ui/mark_slots.png", "mips smooth")

function ARC9AttButton:Init()
	self:SetText("")
    self:SetSize(ARC9ScreenScale(42.7), ARC9ScreenScale(42.7+14.6))
end

function ARC9AttButton:Paint(w, h)
	local color = self.Color
	local iconcolor = self.Color
	local textcolor = self.Color
	local markercolor = self.Color
	local icon = self.Icon or ARC9TopButton.MatIdle
	local text = self.ButtonText

	local mat = self.MatIdle
	local matmarker = nil

	if self:IsHovered() or self.OverrideHovered then
        textcolor = self.ColorClicked
	end

    if self.HasModes then
        matmarker = self.MatMarkerModes
    elseif self.HasSlots then
        matmarker = self.MatMarkerSlots
    end

    if self.Empty then
		mat = self.MatEmpty
    elseif !self.CanAttach then
		mat = self.MatBlock
        matmarker = self.MatMarkerLock
        textcolor = self.ColorBlock
        iconcolor = self.ColorBlock
        markercolor = self.ColorBlock
    elseif self:IsDown() or self.Installed then
		-- mat = self.MatHover
        color = self.ColorClicked
        matmarker = self.MatMarkerInstalled
        markercolor = self.ColorClicked
	end

    surface.SetDrawColor(color)
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, w, w)

    -- icon
	surface.SetDrawColor(iconcolor)
    surface.SetMaterial(icon)
    if !self.FullColorIcon then
        surface.DrawTexturedRect(ARC9ScreenScale(2), ARC9ScreenScale(2), w-ARC9ScreenScale(4), w-ARC9ScreenScale(4))
    else
        surface.DrawTexturedRect(ARC9ScreenScale(4), ARC9ScreenScale(4), w-ARC9ScreenScale(8), w-ARC9ScreenScale(8))
    end

    if matmarker then
        surface.SetDrawColor(markercolor)
        surface.SetMaterial(matmarker)
        surface.DrawTexturedRect(ARC9ScreenScale(3), w - ARC9ScreenScale(11), ARC9ScreenScale(8), ARC9ScreenScale(8))
        -- surface.DrawTexturedRect(0, 0, w, w)
    end

    if self.FolderContain then
        surface.SetFont("ARC9_12")
        local tww = surface.GetTextSize(self.FolderContain)
        surface.SetTextColor(iconcolor)
        surface.SetTextPos((w-tww)/2, h-ARC9ScreenScale(28))
        surface.DrawText(self.FolderContain)
    end

    -- text
    surface.SetFont("ARC9_9")
    local tw = surface.GetTextSize(text)
    surface.SetTextColor(textcolor)
    surface.SetTextPos((w-tw)/2, h-ARC9ScreenScale(13.5))
    surface.DrawText(text)

    -- self:DrawTextRot(self, text, 0, 0, ARC9ScreenScale(2), 0, ARC9ScreenScale(42.7), false) ??
end

function ARC9AttButton:OnCursorEntered() 
    surface.PlaySound(hoversound)
end

function ARC9AttButton:SetIcon(mat)
    self.Icon = mat
end
function ARC9AttButton:SetButtonText(text)
    self.ButtonText = text
end
function ARC9AttButton:SetEmpty(bool)
    self.Empty = bool
end
function ARC9AttButton:SetOverrideHovered(bool)
    self.OverrideHovered = bool
end
function ARC9AttButton:SetInstalled(bool)
    self.Installed = bool
end
function ARC9AttButton:SetCanAttach(bool)
    self.CanAttach = bool
end
function ARC9AttButton:SetFolderContain(num)
    self.FolderContain = num
end
function ARC9AttButton:SetHasModes(bool)
    self.HasModes = bool
end
function ARC9AttButton:SetHasSlots(bool)
    self.HasSlots = bool
end
function ARC9AttButton:SetFullColorIcon(bool)
    self.FullColorIcon = bool
end

vgui.Register("ARC9AttButton", ARC9AttButton, "DCheckBox") -- DButton

local ARC9ScrollPanel = {}

function ARC9ScrollPanel:Init()
    self.VBar:SetHideButtons(true)
    self.VBar:SetWide(ARC9ScreenScale(2))
    self.VBar:SetAlpha(0) -- to prevent blinking
    self.VBar:AlphaTo(255, 0.2, 0, nil)
    self.VBar.Paint = function(panel, w, h)
        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        surface.DrawRect(0, 0, w, h)
    end
    self.VBar.btnGrip.Paint = function(panel, w, h)
        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(0, 0, w, h)
    end

    local smoothdlta = 0

    self.VBar.AddScroll = function(self2, dlta)
        local OldScroll = self2:GetScroll()
        dlta = dlta * 35
        smoothdlta = Lerp(0.08, smoothdlta, dlta)
        self2:SetScroll(self2:GetScroll() + smoothdlta)
        return OldScroll != self2:GetScroll()
    end
end
function ARC9ScrollPanel:Paint(w, h) end

vgui.Register("ARC9ScrollPanel", ARC9ScrollPanel, "DScrollPanel")

local ARC9HorizontalScroller = {}

function ARC9HorizontalScroller:Init()
    local smoothdlta = 0

    self.OnMouseWheeled = function(self2, dlta)
        dlta = dlta * -55
        smoothdlta = Lerp(0.08, smoothdlta, dlta)
        
        self2.OffsetX = self2.OffsetX + smoothdlta
        self2:InvalidateLayout(true)

        return true
    end
end

vgui.Register("ARC9HorizontalScroller", ARC9HorizontalScroller, "DHorizontalScroller")