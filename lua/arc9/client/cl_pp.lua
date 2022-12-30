ARC9.Flares = {}

local flaremat = Material("effects/arc9_lensflare", "mips smooth")

hook.Add("RenderScreenspaceEffects", "ARC9_SSE_PP", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:HoldBreathPP()

    local r = math.Rand(0.95, 1.05)

    for _, flare in ipairs(ARC9.Flares) do
        -- render.SetMaterial(flaremat)
        -- render.DrawSprite(flare.pos, flare.size, flare.size, flare.col)
        surface.SetMaterial(flaremat)
        surface.SetDrawColor(flare.col)
        local s = flare.size * r
        surface.DrawTexturedRect(flare.x - (s / 2), flare.y - (s / 2), s, s)
    end

    for _, flare in ipairs(ARC9.Flares) do
        -- render.SetMaterial(flaremat)
        -- render.DrawSprite(flare.pos, flare.size, flare.size, flare.col)
        surface.SetMaterial(flaremat)
        surface.SetDrawColor(255, 255, 255)
        local s = flare.size * 0.25 * r
        surface.DrawTexturedRect(flare.x - (s / 2), flare.y - (s / 2), s, s)
    end

    ARC9.Flares = {}

    if wpn:GetSight().FlatScope and wpn:GetSight().FlatScopeCC and wpn:GetSightAmount() > 0.75 then
        DrawColorModify(wpn:GetSight().FlatScopeCC)
    end
end)