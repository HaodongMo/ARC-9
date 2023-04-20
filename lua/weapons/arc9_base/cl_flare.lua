function SWEP:DrawLightFlare(pos, ang, col, size)
    col = col or Color(255, 255, 255)
    size = size or 1

	local diff = EyePos() - pos
    if -ang:Right():Dot(diff)<0 then return end
    local dotter = math.max(0, -ang:Right():Dot(diff)/diff:Length())


    if dotter < 0.5 then return end
    -- dotter = math.ease.InCirc(math.ease.InExpo(dotter))
    dotter = math.ease.InExpo(dotter)
    if dotter!=dotter then return end
    
    local distancer = math.ease.InExpo(math.max(1 - EyePos():DistToSqr(pos) * 0.000001, 0))
    size = size * dotter * 4 * distancer

    local toscreen = pos:ToScreen()
    table.insert(ARC9.Flares, {
        pos = pos,
        x = toscreen.x,
        y = toscreen.y,
        size = ScreenScale(math.Clamp(size, 0, 1000)),
        color = col
    })
end