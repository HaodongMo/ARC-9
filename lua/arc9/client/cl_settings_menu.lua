--[[
    type,
        label - pure text
        bool
        button: 
            content - text in button
            func - function(self2) end
        slider:
            min
            max
            decimals
            convar2 - same as convar, but only for input, not follow always
            func - function(self2) end   after action
        color
        coloralpha - with transparency slider
        input - text input, NOT IMPLEMENTED
        combo - dropdown menu:
            content - {"1table of thingies", "2there", "3for some reason you need put number at start so it will be properly sorted", "4though it will be not drawn in ui"}
    title,
    convar to follow, (without arc9_; color selectors will automatically use _r/_g/_b)
    description to show on right
]]--

local settingstable = {
    {
        TabName = "Tab name 1",
        { type = "label", text = "Header" },
        { type = "bool", text = "Booling", convar = "cust_blur", desc = "TEST DESCRIPTION" },
        { type = "slider", text = "Booling 2", min = -2, max = 2, desc = "f DESCRIPTION" },
        { type = "slider", text = "Slide me", min = -45, max = 45, convar = "fov", desc = "balls" },
        { type = "combo", text = "Yayay", convar = "arccw_attinv_loseondie", content = {"1table of thingies", "2there", "3ooo"}, desc = "hhhhhhhhhhhhhhhhh" },
        { type = "button", text = "Uhhh", content = "Boop", func = function(self2) print("wa") end, desc = "TEST DESCRIPTION" },
        { type = "color", text = "Coloringa", convar = "reflex", desc = "This color is very important. \n\nClient-only.\nConvar: arc9_sdfjidojgoidfjgoidfg_r/g/b/a" },
        -- { type = "coloralpha", text = "Color alpha", desc = "g" },
        -- { type = "input", text = "Color alpha", desc = "g" },
    },
    {
        TabName = "Tab name 2",
        { type = "bool", text = "bool 2" },
        -- crazy hacks to make hud scale work "almost dynamicly"
        { type = "slider", text = "HUD SCAle", min = 0.5, max = 1.5, decimals = 2, desc = "Awesome", convar2 = "hud_scale", func = function(self2, self3, settingspanel) 
            if IsValid(LocalPlayer()) then -- uncust the gun
                local wep = LocalPlayer():GetActiveWeapon()
                if IsValid(wep) and wep.ARC9 then
                    if wep.CustomizeHUD then
                        wep:SetCustomize(false)
                        net.Start("ARC9_togglecustomize")
                        net.WriteBool(false)
                        net.SendToServer()
                    end
                end
            end
            RunConsoleCommand("arc9_hud_scale", self3:GetValue())

            settingspanel:Remove() -- rebuilding
            timer.Simple(0, function()
                ARC9.Regen() -- reload fonts with new scale
                ARC9_OpenSettings(2) -- open settings on current page (set number to tab number)
            end)
        end },
        -- { type = "slider", text = "Slide me" },
    },
    
}

local ARC9ScreenScale = ARC9.ScreenScale
local mat_icon = Material("arc9/arc9_logo_ui.png", "mips smooth")

local function DrawSettings(bg, page)
    local cornercut = ARC9ScreenScale(3.5)
    
    local buttontalling = 0
    local activedesc = ""

    local sheet = vgui.Create("ARC9ColumnSheet", bg)
    sheet:Dock(FILL)
    sheet:DockMargin(0, 0, ARC9ScreenScale(77), ARC9ScreenScale(1.7))
    sheet.Navigation:DockMargin(-120, 0, 0, ARC9ScreenScale(5)) -- idk why -120
    sheet.Navigation:SetWidth(ARC9ScreenScale(77))

    for k, v in pairs(settingstable) do
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
                
                -- desc!!!!!!!!

                if self2:IsHovered() then
                    if activedesc != (v2.desc or "") then
                        activedesc = (v2.desc or "")
                        if bg.desc then bg.desc:Remove() end

                        local desc = vgui.Create("ARC9ScrollPanel", bg)
                        desc:SetPos(bg:GetWide() - ARC9ScreenScale(74.5), ARC9ScreenScale(35))
                        desc:SetSize(ARC9ScreenScale(70), bg:GetTall() - ARC9ScreenScale(40))
                        desc.Paint = function(self2, w, h)
                            -- surface.SetDrawColor(144, 0, 0, 100)
                            -- surface.DrawRect(0, 0, w, h)
                        end
                        bg.desc = desc

                        local descmultiline = ARC9MultiLineText(activedesc, desc:GetWide() - ARC9ScreenScale(1), "ARC9_8")
                        for i, text in ipairs(descmultiline) do
                            local desc_line = vgui.Create("DPanel", desc)
                            desc_line:SetSize(desc:GetWide(), ARC9ScreenScale(8))
                            desc_line:Dock(TOP)
                            desc_line.Paint = function(self2, w, h)
                                surface.SetFont("ARC9_8")
                                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                                surface.SetTextPos(ARC9ScreenScale(2), 0)
                                surface.DrawText(text)
                            end
                        end
                    end
                end



                surface.SetFont("ARC9_12_Slim")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(4), ARC9ScreenScale(4))
                surface.DrawText(v2.text or "Owo")
            end

            local elpw, elph = ARC9ScreenScale(168), ARC9ScreenScale(21)

            if v2.type == "label" then
                -- woopsie
            elseif v2.type == "bool" then
                local newel = vgui.Create("ARC9Checkbox", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(4+13), ARC9ScreenScale(4))
                if v2.convar then newel:SetConVar("arc9_" .. v2.convar) end
                
            elseif v2.type == "slider" then
                local newel = vgui.Create("ARC9NumSlider", elpanel)
                newel:SetPos(0, ARC9ScreenScale(6))
                newel:SetSize(elpw, 30)
                newel:SetDecimals(v2.decimals or 0)
                newel:SetMin(v2.min or 0)
                newel:SetMax(v2.max or 255)
                if v2.convar then newel:SetConVar("arc9_" .. v2.convar) end
                if v2.convar2 then newel:SetValue(GetConVar("arc9_" .. v2.convar2):GetFloat()) end

                local oldmousereleased = newel.Slider.OnMouseReleased
                newel.Slider.OnMouseReleased = function(self2, kc)
                    oldmousereleased(self2, kc)
                    if v2.func then v2.func(self2, newel, bg) end
                end
            elseif v2.type == "color" then
                local newel = vgui.Create("ARC9ColorButton", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                newel:CustomSetConvar(cvar)

                if GetConVar(cvar .. "_r") then 
                    newel.rgbcolor = Color(GetConVar(cvar .. "_r"):GetInt() or 255, GetConVar(cvar .. "_g"):GetInt() or 0, GetConVar(cvar .. "_b"):GetInt() or 0) 
                else 
                    newel.rgbcolor = Color(255, 0, 0)
                    print("you are dumb, missing color convar")
                end

            elseif v2.type == "coloralpha" then
                local newel = vgui.Create("ARC9ColorButton", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel:EnableAlpha()

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                newel:CustomSetConvar(cvar)

                if GetConVar(cvar .. "_a") then 
                    newel.rgbcolor = Color(GetConVar(cvar .. "_r"):GetInt() or 255, GetConVar(cvar .. "_g"):GetInt() or 0, GetConVar(cvar .. "_b"):GetInt() or 0, GetConVar(cvar .. "_a"):GetInt() or 255) 
                else 
                    newel.rgbcolor = Color(255, 0, 0)
                    print("you are dumb, missing color convar (or its _alpha)")
                end

            elseif v2.type == "input" then
                local newel = vgui.Create("DTextEntry", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel:SetText(v2.text)
            elseif v2.type == "combo" then
                local newel = vgui.Create("ARC9ComboBox", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                for _, choice in pairs(v2.content) do
                    newel:AddChoice(choice)
                end

                local cvar = "arc9_" .. (v2.convar or "ya_dumbass")
                if GetConVar(cvar) then
                    newel:CustomSetConvar(cvar)
                    newel:ChooseOptionID(GetConVar(cvar):GetInt())
                else
                    print("invalid combobox convar")
                end

            elseif v2.type == "button" then
                local newel = vgui.Create("ARC9Button", elpanel)
                newel:SetPos(elpw-ARC9ScreenScale(88), ARC9ScreenScale(6))
                newel.text = v2.content

                local oldmousepressed = newel.OnMousePressed
                newel.OnMousePressed = function(self2, kc)
                    oldmousepressed(self2, kc)
                    if kc == MOUSE_LEFT and v2.func then v2.func(self2) end
                end
            end
        end

        local thatsheet = sheet:AddSheet(v.TabName, newpanel)
        thatsheet.PageID = k

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
        local talll = sheet.Navigation:GetTall() + ARC9ScreenScale(6.7)
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

        surface.SetFont("ARC9_8_Slim")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(w-ARC9ScreenScale(73), ARC9ScreenScale(26))
        surface.DrawText(activedesc != "" and "Description" or "") -- no title if no desc

        surface.SetFont("ARC9_16")
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(ARC9ScreenScale(30), ARC9ScreenScale(4))
        surface.DrawText("ARC9 Settings")
    end

    if page then 
        for k, v in pairs(sheet.Items) do
            if v.PageID == page then
                v.Button:DoClick()
            end
        end
    end
end

local hoversound = "arc9/newui/uimouse_hover.ogg"
local clicksound = "arc9/newui/uimouse_click_return.ogg"


function ARC9_OpenSettings(page)
    local bg = vgui.Create("DFrame")
    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg:SetTitle("")
    bg:SetDraggable(false)
    -- bg:ShowCloseButton(false)        -- set to false when done please!!
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
    DrawSettings(panel, page)

    panel.OnRemove = function() bg:Remove() end


    local discord = vgui.Create("ARC9TopButton", panel)
    discord:SetPos(panel:GetWide() - ARC9ScreenScale(21*3 + 12), ARC9ScreenScale(2))
    discord:SetIcon(Material("arc9/ui/discord.png", "mips smooth"))
    discord.DoClick = function(self2)
        surface.PlaySound(clicksound)
        gui.OpenURL("https://discord.gg/wkafWps44a")
    end    

    local steam = vgui.Create("ARC9TopButton", panel)
    steam:SetPos(panel:GetWide() - ARC9ScreenScale(21*2 + 7), ARC9ScreenScale(2))
    steam:SetIcon(Material("arc9/ui/steam.png", "mips smooth"))
    steam.DoClick = function(self2)
        surface.PlaySound(clicksound)
        gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2131057232") -- dont forget to change to arc9 page when it release
    end

    local close = vgui.Create("ARC9TopButton", panel)
    close:SetPos(panel:GetWide() - ARC9ScreenScale(21+2), ARC9ScreenScale(2))
    close:SetIcon(Material("arc9/ui/close.png", "mips smooth"))
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