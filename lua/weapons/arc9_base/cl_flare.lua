function SWEP:DrawLightFlare(pos, ang, col, size)
    col = col or Color(255, 255, 255)
    size = size or 1

	local diff = EyePos() - pos
    if diff:Length() < 0.01 then return end
    local dotter = math.max(0, -ang:Right():Dot(diff)/diff:Length())
    -- print(dotter, col)
    -- print(ang:Forward():Dot(diff)/diff:Length())


    if dotter < 0.3 then return end
    dotter = math.ease.InCirc(math.ease.InExpo(dotter))
    -- if dotter!=dotter then return end
    -- dotter = math.ease.InExpo(dotter)
    
    local distancer = math.ease.InExpo(math.max(1 - EyePos():DistToSqr(pos) * 0.000001, 0))

    size = size * dotter * 4 * distancer
    -- print(dotter)
    -- local eyevec = (pos - EyePos()):GetNormalized()
    
    -- norm:Dot((tr.StartPos - tr.HitPos):GetNormalized())

    -- local dot = norm:Dot(eyevec)

    -- if dot > 0 then return end

    -- local tr = util.TraceLine({
    --     start = pos,
    --     endpos = EyePos(),
    --     mask = MASK_OPAQUE_AND_NPCS,
    --     filter = LocalPlayer():GetViewEntity()
    -- })

    -- if tr.Hit then return end

    -- dot = -dot

    -- print("hhi?")
    -- if dot < 0.75 then return end
    -- print(dot)

    -- dot = math.Clamp(dot, 0, 1)
    -- dot = math.ease.InOutExpo(dot)

    -- size = size
    -- if !focus then
    --     local dist = (pos - EyePos()):Length()

    --     size = size * 120 / (math.pow(dist, 1.25))      -- the math is wrong here pls fix
    -- end

    local toscreen = pos:ToScreen()
    table.insert(ARC9.Flares, {
        pos = pos,
        x = toscreen.x,
        y = toscreen.y,
        size = ScreenScale(math.Clamp(size, 0, 1000)),
        color = col
    })
end