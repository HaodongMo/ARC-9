ARC9.Flares = {}

local flaremat = Material("effects/arc9_lensflare", "mips smooth")
-- flaremat:SetInt("$additive", 1)

hook.Add("RenderScreenspaceEffects", "ARC9_SSE", function()
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
        surface.SetDrawColor(Color(255, 255, 255))
        local s = flare.size * 0.25 * r
        surface.DrawTexturedRect(flare.x - (s / 2), flare.y - (s / 2), s, s)
    end

    ARC9.Flares = {}
end)