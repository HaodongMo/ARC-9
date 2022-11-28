--[[

    label - label
    bool - bool
    button - button
    slider - slider
    color - color
    input - text input
    combo - dropdown menu
    
]]--

local settingstable = {
    {
        TabName = "Tab name 1",
        { type = "label", text = "Header" },
        { type = "bool", text = "Booling" },
        { type = "slider", text = "Booling 2" },
        { type = "slider", text = "Slide me" },
        { type = "combo", text = "Yayay" },
        { type = "button", text = "Uhhh" },
        { type = "color", text = "Coloringa" },
        -- { type = "c", text = "Color yeah" },
        -- { type = "t", text = "Yrint the " },
    },
    {
        TabName = "Tab name 2",
        { type = "bool", text = "bool 2" },
        -- { type = "l", text = "Header 2" },
        { type = "slider", text = "Slide me" },
    },
    
}

local ARC9ScreenScale = ARC9.ScreenScale
local mat_icon = Material("arc9/arc9_sus.png", "mips smooth")

local function DrawSettings(bg)
    local cornercut = ARC9ScreenScale(3.5)
    
    local buttontalling = 0

    local sheet = vgui.Create("ARC9ColumnSheet", bg)
    sheet:Dock(FILL)
    sheet:DockMargin(0, 0, ARC9ScreenScale(77), ARC9ScreenScale(1.7))
    sheet.Navigation:DockMargin(-120, 0, 0, ARC9ScreenScale(5)) -- idk why -120
    sheet.Navigation:SetWidth(ARC9ScreenScale(77))

    for _, v in pairs(settingstable) do
        local newpanel = vgui.Create("DPanel", sheet)
        newpanel:Dock(FILL)
        newpanel.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ARC9.GetHUDColor("bg")) end 
        local newpanelscroll = vgui.Create("ARC9ScrollPanel", newpanel)
        newpanelscroll:Dock(FILL)
        newpanelscroll:DockMargin(ARC9ScreenScale(4), ARC9ScreenScale(4), ARC9ScreenScale(4), 0)

        for k2, v2 in ipairs(v) do
            local elpanel = vgui.Create("DPanel", newpanelscroll)
            elpanel:SetTall(ARC9ScreenScale(21))
            elpanel:Dock(TOP)
            elpanel.Paint = function(self2, w, h) 
                -- surface.SetDrawColor(20,20,20,44*k2) 
                -- surface.DrawRect(0, 0, w, h) 
            
                surface.SetFont("ARC9_12_Slim")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(4))
                surface.DrawText(v2.text or "Owo")
            end
            local elpw, elph = ARC9ScreenScale(168), ARC9ScreenScale(21)

            if v2.type == "label" then
                
            elseif v2.type == "bool" then
                local newel = vgui.Create("ARC9Checkbox", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(4+13), ARC9ScreenScale(4))
            elseif v2.type == "slider" then
                local newel = vgui.Create("ARC9NumSlider", elpanel)
                -- local newslider = vgui.Create("DNumSlider", newpanelscroll)
                newel:SetPos(0, ARC9ScreenScale(6))
                newel:SetSize(elpw, 30)
                newel:SetDecimals(0)
                newel:SetMin(0)
                newel:SetMax(256)
                newel:SetValue(128)
                -- newel:SetText(v2.text)
            elseif v2.type == "color" then
                local newel = vgui.Create("ARC9ColorButton", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel.rgbcolor = Color(255,0,0)
            elseif v2.type == "input" then
                local newtext = vgui.Create("DTextEntry", newpanelscroll)
                newtext:SetPos(20, 10+k2*20)
                newtext:SetText(v2.text)
            elseif v2.type == "combo" then
                local newel = vgui.Create("ARC9ComboBox", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel:AddChoice("option A")
                newel:AddChoice("option AAA")
                newel:AddChoice("option AAAAAAA")
            elseif v2.type == "button" then
                local newel = vgui.Create("ARC9Button", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel.text = v2.text
            end
        end

        local thatsheet = sheet:AddSheet(v.TabName, newpanel)

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
        local talll = sheet.Navigation:GetTall()+ARC9ScreenScale(6.7)
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

        surface.SetFont("ARC9_16")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(ARC9ScreenScale(30), ARC9ScreenScale(4))
        surface.DrawText("ARC9 Settings")
    end
end

local hoversound = "arc9/newui/uimouse_hover.ogg"
local clicksound = "arc9/newui/uimouse_click_return.ogg"


local function OpenSettings()
    local bg = vgui.Create("DFrame")
    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg:SetTitle("")
    bg:SetDraggable(false)
    -- bg:ShowCloseButton(false)
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
    DrawSettings(panel)

    panel.OnRemove = function() bg:Remove() end

    local close = vgui.Create("ARC9TopButton", panel)
    close:SetPos(panel:GetWide()-ARC9ScreenScale(21+2), ARC9ScreenScale(2))
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

    timer.Simple(33, function()
        bg:Remove()
        panel:Remove()
    end)
end

function ARC9_OpenSettings()
    OpenSettings()
end
 