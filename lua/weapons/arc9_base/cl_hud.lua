function SWEP:ShouldDrawCrosshair()
    -- return false
end

function SWEP:DoDrawCrosshair(x, y)

    if self:GetOwner():IsAdmin() and GetConVar("developer"):GetInt() >= 2 and self:GetInSights() then
        surface.SetDrawColor(255, 0, 0, 150)
        surface.DrawLine(ScrW() / 2, 0, ScrW() / 2, ScrH())
        surface.DrawLine(0, ScrH() / 2, ScrW(), ScrH() / 2)
    end

    return true
end

function SWEP:GetBinding(bind)
    local t_bind = input.LookupBinding(bind)

    if !t_bind then
        t_bind = "BIND " .. bind .. "!"
    end

    return string.upper(t_bind)
end

function SWEP:DrawHUD()
    self:DrawCustomizeHUD()
end

SWEP.Mat_Select = nil

function SWEP:DrawWeaponSelection(x, y, w, h, a)
    -- if !self.Mat_Select then
    --     self.Mat_Select = Material("entities/" .. self:GetClass() .. ".png")
    -- end

    -- surface.SetDrawColor(255, 255, 255, 255)
    -- surface.SetMaterial(self.Mat_Select)

    -- if w > h then
    --     y = y - ((w - h) / 2)
    -- end

    -- surface.DrawTexturedRect(x, y, w, w)
end

function SWEP:RangeUnitize(range)
    return tostring(math.Round(range * ARC9.HUToM)) .. "M"
end