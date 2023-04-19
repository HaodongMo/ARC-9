ARC9.Flares = {}

local flaremat = Material("effects/arc9_lensflare", "mips smooth")

hook.Add("DrawOverlay", "ARC9_SSE_PP", function()
    if !IsValid(LocalPlayer()) then return end
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:HoldBreathPP()

    -- local r = math.Rand(0.97, 1.02)

    for _, flare in ipairs(ARC9.Flares) do
        -- render.SetMaterial(flaremat)
        -- render.DrawSprite(flare.pos, flare.size, flare.size, flare.col)
        surface.SetMaterial(flaremat)
        -- surface.SetDrawColor(Color(255, 255, 255))
        surface.SetDrawColor(flare.color)
        local s = flare.size
        surface.DrawTexturedRect(flare.x - (s / 2), flare.y - (s / 2), s, s)
    end
    
    -- for _, flare in ipairs(ARC9.Flares) do
        -- render.SetMaterial(flaremat)
        -- render.DrawSprite(flare.pos, flare.size, flare.size, flare.col)
        -- surface.SetMaterial(flaremat)
        -- surface.SetDrawColor(255, 255, 255)
        -- local s = 100
        -- surface.DrawTexturedRect(flare.x - (s / 2), flare.y - (s / 2), s, s)
        -- surface.DrawTexturedRect(500, 500, s, s)
    -- end

    ARC9.Flares = {}

    if wpn:GetSight().FlatScope and wpn:GetSight().FlatScopeCC and wpn:GetSightAmount() > 0.75 then
        DrawColorModify(wpn:GetSight().FlatScopeCC)
    end
end)