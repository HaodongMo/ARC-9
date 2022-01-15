local mat_grad = Material("arc9/gradient.png")

function SWEP:CreateHUD_Stats()
    local bg = self.CustomizeHUD

    local gr_h = ScrH()
    local gr_w = gr_h

    local gradient = vgui.Create("DPanel", bg)
    gradient:SetPos(ScrW() - gr_w, 0)
    gradient:SetSize(gr_w, gr_h)
    gradient.Paint = function(self2, w, h)
        surface.SetMaterial(mat_grad)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local nameplate = vgui.Create("DPanel", bg)
    nameplate:SetPos(0, ScreenScale(4))
    nameplate:SetSize(ScrW(), ScreenScale(32))
    nameplate.Paint = function(self2, w, h)
        surface.SetFont("ARC9_32")
        local tw = surface.GetTextSize(self.PrintName)
        surface.SetTextPos(w - tw - ScreenScale(4), 0)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(self.PrintName)
    end
end