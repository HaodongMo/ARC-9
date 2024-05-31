ARC9.Flares = {}

local flaremat = Material("effects/arc9_lensflare", "mips smooth")

hook.Add("PostDrawHUD", "ARC9_SSE_PP", function()
    if !IsValid(LocalPlayer()) then return end
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:HoldBreathPP()
    
    for i, flare in ipairs(ARC9.Flares) do
        cam.Start3D(_, _ , flare.invm and wpn.ViewModelFOV + 16 or _) -- no idea why 16
        local toscreen = flare.pos:ToScreen()
        cam.End3D()

        if toscreen.visible then
            surface.SetMaterial(flaremat)
            surface.SetDrawColor(flare.color)
            local s = ScreenScale(flare.size)
            surface.DrawTexturedRect(toscreen.x - (s / 2), toscreen.y - (s / 2), s, s)
        end
    end

    ARC9.Flares = {}
    wpn.FlaresAlreadyDrawn = {}

    if wpn:GetSight().FlatScope and wpn:GetSight().FlatScopeCC and wpn:GetSightAmount() > 0.75 then
        DrawColorModify(wpn:GetSight().FlatScopeCC)
    end
end)