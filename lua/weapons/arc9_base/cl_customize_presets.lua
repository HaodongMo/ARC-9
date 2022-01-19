
function SWEP:CreateHUD_Presets(scroll)
    local presettable = {}

    for _, preset in pairs(presettable) do
        local btn = vgui.Create("DButton", scroll)
        btn:SetSize(ScreenScale(48), ScreenScale(48))
        btn:DockMargin(ScreenScale(2), 0, 0, 0)
        btn:Dock(LEFT)
        btn:SetText("")
        scroll:AddPanel(btn)
        btn.OnMousePressed = function(self2, kc)
        end
        btn.Paint = function(self2, w, h)
            if !IsValid(self) then return end
        end
    end
end