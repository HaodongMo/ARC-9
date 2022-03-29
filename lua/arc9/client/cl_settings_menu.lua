--[[

    l - label
    b - bool
    s - slider
    c - color
    t - text input
    
]]--

local cltable = {
    {
        TabName = "Tab name 1",
        { type = "l", text = "header" },
        { type = "b", text = "bool" },
        { type = "s", text = "slide me" },
        { type = "c", text = "color yeah" },
        { type = "t", text = "print the " },
    },
    {
        TabName = "Tab name 2",
        { type = "b", text = "bool 2" },
        { type = "l", text = "Header 2" },
    },
}

local function DrawSettings(bg, clsv)
    bg.Paint = function(self2, w, h)
        surface.SetDrawColor(ARC9.GetHUDColor("bg_menu"))
        surface.DrawRect(0, 0, w, h)
    end

    local sheet = vgui.Create( "DColumnSheet", bg )
    sheet:Dock( FILL )

    for k, v in pairs(cltable) do
        local newpanel = vgui.Create( "DPanel", sheet )
        newpanel:Dock( FILL )
        newpanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 44, 44, 44) ) end 

        for k2, v2 in ipairs(v) do
            if v2.type == "l" then
                local newheader = vgui.Create( "DLabel", newpanel )
                newheader:SetPos(20, k2*20)
                newheader:SetText(v2.text)
            elseif v2.type == "b" then
                local newbool = vgui.Create( "DCheckBoxLabel", newpanel )
                newbool:SetPos(20, k2*20)
                newbool:SetText(v2.text)
            elseif v2.type == "s" then
                local newslider = vgui.Create( "DNumSlider", newpanel )
                newslider:SetPos(20, k2*20)
                newslider:SetSize(400, 30)
                newslider:SetDecimals(0)
                newslider:SetMin(0)
                newslider:SetMax(256)
                newslider:SetText(v2.text)
            elseif v2.type == "c" then
                local newcolor = vgui.Create( "DColorPalette", newpanel )
                newcolor:SetPos(20, 10+k2*20)
                newcolor:SetSize(400, 30)
                newcolor:SetColorButtons({
                    Color(255,255,255),
                    Color(0,0,0),
                    Color(80,80,80),
                    Color(255,0,0),
                    Color(255,136,0),
                    Color(255,238,0),
                    Color(72,255,0),
                    Color(0,255,242),
                    Color(0,4,255),
                    Color(98,0,255),
                    Color(174,0,255),
                    Color(255,0,149),
                })
            elseif v2.type == "t" then
                local newtext = vgui.Create( "DTextEntry", newpanel )
                newtext:SetPos(20, 10+k2*20)
                newtext:SetText(v2.text)
            end
        end

        sheet:AddSheet(v.TabName, newpanel)
    end

    -- if clsv then
    --     cltable
    -- else
    --     svtable
    -- end
end

local function OpenSettings(type)
    ARC9.NoFocus = true 

    local wpn = LocalPlayer():GetActiveWeapon()
    if !wpn or !IsValid(wpn) or !wpn.ARC9 then wpn = nil end

    if wpn:GetCustomize() and wpn then
        wpn.CustomizeHUD:SetMouseInputEnabled(false)
    end

    local bg = vgui.Create("DFrame")
    bg:SetSize(ScrW()/2, ScrH()/2)
    bg:MakePopup()
    bg:Center()
    bg:SetTitle("")

    DrawSettings(bg, clsv) -- false = client, true = server

    bg.OnRemove = function()
        ARC9.NoFocus = false

        if wpn:GetCustomize() and wpn then
            wpn.CustomizeHUD:SetMouseInputEnabled(true)
        end
    end

    timer.Simple(15, function()
        bg:Remove()
    end)
end

function ARC9_ClientSettings()
    OpenSettings(false)
end
 