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


local ARC9ColumnSheet = {}

function ARC9ColumnSheet:Init()
	self.Navigation = vgui.Create( "ARC9ScrollPanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( 100 )
	self.Navigation:DockMargin( 10, 10, 10, 0 )

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}
end

vgui.Register("ARC9ColumnSheet", ARC9ColumnSheet, "DColumnSheet")


local ARC9Checkbox = {}
ARC9Checkbox.Color = ARC9.GetHUDColor("fg")
ARC9Checkbox.ColorClicked = ARC9.GetHUDColor("hi")

ARC9Checkbox.MatIdle = Material("arc9/ui/checkbox.png", "mips")
ARC9Checkbox.MatSel = Material("arc9/ui/checkbox_sel.png", "mips")
ARC9Checkbox.MatToggled = Material("arc9/ui/checkbox_toggled.png", "mips")

function ARC9Checkbox:Init()
    self:SetSize(ARC9ScreenScale(13), ARC9ScreenScale(13))
end

function ARC9Checkbox:Paint(w, h)
	local color = self.Color
	local color2 = self.ColorClicked

    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, w)

    if self:GetChecked() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self.MatToggled)
        surface.DrawTexturedRect(0, 0, w, w)
    end

    if self:IsHovered() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self.MatSel)
        surface.DrawTexturedRect(0, 0, w, w)
    end
end

vgui.Register("ARC9Checkbox", ARC9Checkbox, "DCheckBox")


local ARC9NumSlider = {}
ARC9NumSlider.Color = ARC9.GetHUDColor("fg")
ARC9NumSlider.ColorClicked = ARC9.GetHUDColor("hi")
ARC9NumSlider.ColorNo = ARC9.GetHUDColor("bg")

function ARC9NumSlider:Init()
    local color = self.Color
    local color2 = self.ColorClicked
    local color3 = self.ColorNo
    
    self.Slider.Knob:SetSize(ARC9ScreenScale(1.7), ARC9ScreenScale(7))
    self.Slider.Knob.Paint = function( panel, w, h ) 
        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, w, h) 
    end    
    
    self.Slider.Paint = function( panel, w, h ) 
        surface.SetDrawColor(color3)
        surface.DrawRect(0, h/3, w, h/4) 
        surface.SetDrawColor(color)
        surface.DrawRect(0, h/3, w*self.Scratch:GetFraction(), h/4) 
    end
	self.TextArea:SetWide(ARC9ScreenScale(20))
	self.TextArea:DockMargin(ARC9ScreenScale(3), 0, 0, 0)
	self.TextArea:SetHighlightColor(color2)
	self.TextArea:SetCursorColor(color2)
	self.TextArea:SetTextColor(color)
    self.TextArea:SetFont("ARC9_10_Slim")
    -- self.TextArea.Paint = function( panel, w, h ) 
    --     surface.SetFont("ARC9_10_Slim")
    --     local text = panel:GetValue() or "Owo"
    --     local tw = surface.GetTextSize(text)
    --     surface.SetTextColor(color)
    --     surface.SetTextPos(w-tw, ARC9ScreenScale(0))
    --     surface.DrawText(text)
    -- end
end

vgui.Register("ARC9NumSlider", ARC9NumSlider, "DNumSlider")


local ARC9ComboBox = {}
ARC9ComboBox.Color = ARC9.GetHUDColor("fg")
ARC9ComboBox.ColorClicked = ARC9.GetHUDColor("hi")

ARC9ComboBox.MatIdle = Material("arc9/ui/dd.png", "mips")
ARC9ComboBox.MatSel = Material("arc9/ui/dd_sel.png", "mips")
ARC9ComboBox.MatOpened = Material("arc9/ui/dd_opened.png", "mips")
ARC9ComboBox.MatOpenedSel = Material("arc9/ui/dd_opened_sel.png", "mips")
ARC9ComboBox.MatSingle = Material("arc9/ui/dd_option.png", "mips")
ARC9ComboBox.MatSingleSel = Material("arc9/ui/dd_option_sel.png", "mips")
ARC9ComboBox.MatLast = Material("arc9/ui/dd_option_last.png", "mips")
ARC9ComboBox.MatLastSel = Material("arc9/ui/dd_option_last_sel.png", "mips")

function ARC9ComboBox:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))
    self.DropButton:Remove()
end

function ARC9ComboBox:PerformLayout() -- to fix button we removed
	DButton.PerformLayout( self, w, h )
end

function ARC9ComboBox:OnSelect(index, value, data)
    self.text = self:GetText()
    self:SetText("")
end

function ARC9ComboBox:OnMenuOpened(menu)
    menu.Paint = function(panel, w, h) end
    
    menu:SetAlpha(0)
    menu:AlphaTo(255, 0.1, 0, nil)
	-- local mat = self.MatIdle

    for i=1, menu:ChildCount() do
        local child = menu:GetChild(i)

        child.PerformLayout = function(self22, w22, h22) DButton.PerformLayout(self22, w22, h22) end

        child:SetSize(ARC9ScreenScale(84),ARC9ScreenScale(13))
        child.id = i
        child.last = i==menu:ChildCount()
        child.text = child:GetText()
        child:SetText("")
        
        child.Paint = function(self2, w, h)
            local mat = self.MatSingle
            local mat2 = self.MatSingleSel
            local mat3 = self.MatLast
            local mat4 = self.MatLastSel
            local color = self.Color
            local color2 = self.ColorClicked
                    
            if self2:IsDown() then
                color = color2
            end

            surface.SetDrawColor(color)
            surface.SetMaterial(self2.last and mat3 or mat)
            surface.DrawTexturedRect(0, 0, w, h)
            
            local active = self:GetSelectedID() == self2.id

            if active or self2:IsHovered() then
                surface.SetDrawColor(color2)
                surface.SetMaterial(self2.last and mat4 or mat2)
                surface.DrawTexturedRect(0, 0, w, h)
            end
             
            surface.SetFont("ARC9_10")
            surface.SetTextColor(active and color2 or color)
            surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(1))
            surface.DrawText(child.text or "Owo")
        end
    end
end

function ARC9ComboBox:Paint(w, h)
	local color = self.Color
	local color2 = self.ColorClicked
	local mat = self.MatIdle
	local mat2 = self.MatSel
	local mat3 = self.MatOpened
	local mat4 = self.MatOpenedSel

    surface.SetDrawColor(color)
    surface.SetMaterial(self:IsMenuOpen() and mat3 or mat)
    surface.DrawTexturedRect(0, 0, w, h)

    if self:IsHovered() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self:IsMenuOpen() and mat4 or mat2)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    surface.SetFont("ARC9_10")
    surface.SetTextColor(color)
    surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(1))
    surface.DrawText(self.text or "unselected")
end

vgui.Register("ARC9ComboBox", ARC9ComboBox, "DComboBox")


local ARC9Button = {}
ARC9Button.Color = ARC9.GetHUDColor("fg")
ARC9Button.ColorClicked = ARC9.GetHUDColor("hi")

ARC9Button.MatIdle = Material("arc9/ui/button.png", "mips")
ARC9Button.MatSel = Material("arc9/ui/button_sel.png", "mips")

function ARC9Button:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))
    self.text = self:GetText()
    self:SetText("")
end

function ARC9Button:Paint(w, h)
	local color = self.Color
	local color2 = self.ColorClicked

    if self:IsDown() then
        color = color2
    end

    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, h)

    if self:IsHovered() then
        surface.SetDrawColor(color2)
        surface.SetMaterial(self.MatSel)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    local text = self.text or "owo"
    surface.SetFont("ARC9_10")
    local tw = surface.GetTextSize(text)
    surface.SetTextColor(color)
    surface.SetTextPos(w/2-tw/2, ARC9ScreenScale(1.5))
    surface.DrawText(text)
end

vgui.Register("ARC9Button", ARC9Button, "DButton")


local ARC9ColorPanel = {}
ARC9ColorPanel.Color = ARC9.GetHUDColor("fg")
ARC9ColorPanel.ColorClicked = ARC9.GetHUDColor("hi")

ARC9ColorPanel.MatIdle = Material("arc9/ui/colorpanel2.png", "mips")

function ARC9ColorPanel:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(108)) --96

    self:MakePopup()
    self:Center()
    self:Center()
    self:SetDraggable(true)
    self:ShowCloseButton(true)

    local huepanel = vgui.Create("DPanel", self)
    huepanel:SetPos(ARC9ScreenScale(2.5), ARC9ScreenScale(82+12))
    huepanel:SetSize(ARC9ScreenScale(79), ARC9ScreenScale(12))
    huepanel.LastX = 0
    -- local hueslider = vgui.Create("DPanel", huepanel)
    -- hueslider:SetPos(0, 0)
    -- hueslider:SetSize(ARC9ScreenScale(1), ARC9ScreenScale(11))

    huepanel.OnCursorMoved =  function( self2, x, y )
        if !input.IsMouseDown(MOUSE_LEFT) then return end
    
        -- local col = self:GetPosColor(x, y)
    
        -- if col then
        --     self.m_RGB = col
        --     self.m_RGB.a = 255
        --     self:OnChange( self.m_RGB )
        -- end
        x = math.Clamp(x, 0, self2:GetWide()) -- -ARC9ScreenScale(1))
        self2.LastX = x
        
    end

    huepanel.OnMousePressed =  function(self2, mcode)
        self2:MouseCapture(true)
        self2:OnCursorMoved( self2:CursorPos() )
    end
    huepanel.OnMouseReleased =  function(self2, mcode)
        self2:MouseCapture(false)
        self2:OnCursorMoved(self2:CursorPos())
    end
    
    huepanel.Paint =  function(self2, w, h)
        -- surface.SetDrawColor( 255, 255, 255, 255 )
        -- surface.SetMaterial( self.Material )
        -- surface.DrawTexturedRect( 0, 0, w, h )
    
        -- surface.SetDrawColor( 0, 0, 0, 250 )
        -- self:DrawOutlinedRect()
    
        -- surface.DrawRect( 0, self.LastY - 2, w, 3 )
    
        surface.SetDrawColor( 255, 255, 255, 250 )
        surface.DrawRect( self2.LastX-ARC9ScreenScale(0.5),  0, ARC9ScreenScale(1), h )
    
    end

    local cube = vgui.Create( "DColorCube", self)
    cube:SetPos( 50, 50 )
    cube:SetSize( 200, 200 )
    cube:SetBaseRGB( Color( 0, 255, 0 ) )
end

function ARC9ColorPanel:Paint(w, h)
	local color = self.Color


    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, h)
    
    -- surface.SetDrawColor(color)
    -- surface.SetMaterial(self.MatIcon)
    -- surface.DrawTexturedRect(w/2-h*0.35, h/2-h*0.35, h*0.7, h*0.7)

    -- if self:IsHovered() then
    --     surface.SetDrawColor(color2)
    -- end

    -- surface.SetMaterial(self.MatSel)
    -- surface.DrawTexturedRect(0, 0, w, h)
    
end

vgui.Register("ARC9ColorPanel", ARC9ColorPanel, "DFrame")


local ARC9ColorButton = {}
ARC9ColorButton.Color = ARC9.GetHUDColor("fg")
ARC9ColorButton.ColorClicked = ARC9.GetHUDColor("hi")

ARC9ColorButton.MatIdle = Material("arc9/ui/button_color.png", "mips")
ARC9ColorButton.MatSel = Material("arc9/ui/button_sel.png", "mips")
ARC9ColorButton.MatIcon = Material("arc9/ui/paint.png", "mips smooth")

function ARC9ColorButton:Init()
    self:SetSize(ARC9ScreenScale(84), ARC9ScreenScale(13))
    self:SetText("")
end

function ARC9ColorButton:DoClick()
    local newel = vgui.Create("ARC9ColorPanel")
end

function ARC9ColorButton:Paint(w, h)
	local color = self.Color
	local color2 = self.ColorClicked
	local color3 = self.rgbcolor or self.Color


    if self:IsDown() then
        color = color2
    end

    surface.SetDrawColor(color3)
    surface.SetMaterial(self.MatIdle)
    surface.DrawTexturedRect(0, 0, w, h)
    
    surface.SetDrawColor(color)
    surface.SetMaterial(self.MatIcon)
    surface.DrawTexturedRect(w/2-h*0.35, h/2-h*0.35, h*0.7, h*0.7)

    if self:IsHovered() then
        surface.SetDrawColor(color2)
    end

    surface.SetMaterial(self.MatSel)
    surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("ARC9ColorButton", ARC9ColorButton, "DButton")