ARC9.Flares = {}

local flaremat = Material("effects/arc9_lensflare", "mips smooth")

hook.Add("PostDrawHUD", "ARC9_SSE_PP", function()
    if !IsValid(LocalPlayer()) then return end
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:HoldBreathPP()
    
    for i, flare in ipairs(ARC9.Flares) do
        cam.Start3D()
        local toscreen = flare.pos:ToScreen()
        cam.End3D()

        surface.SetMaterial(flaremat)
        surface.SetDrawColor(flare.color)
        local s = flare.size
        -- print(i, s)
        surface.DrawTexturedRect(toscreen.x - (s / 2), toscreen.y - (s / 2), s, s)
    end

    ARC9.Flares = {}

    if wpn:GetSight().FlatScope and wpn:GetSight().FlatScopeCC and wpn:GetSightAmount() > 0.75 then
        DrawColorModify(wpn:GetSight().FlatScopeCC)
    end
end)