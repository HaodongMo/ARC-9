function SWEP:DrawLightFlare(pos, norm, col, size, focus)
    col = col or Color(255, 255, 255)
    size = size or 1
    local eyevec = (pos - EyePos()):GetNormalized()

    local dot = norm:Dot(eyevec)

    if dot > 0 then return end

    local tr = util.TraceLine({
        start = pos,
        endpos = EyePos(),
        mask = MASK_OPAQUE_AND_NPCS,
        filter = LocalPlayer():GetViewEntity()
    })

    if tr.Hit then return end

    dot = -dot

    if dot < 0.75 then return end

    dot = math.Clamp(dot, 0, 1)

    dot = math.ease.InOutExpo(dot)

    size = size * dot

    if !focus then
        local dist = (pos - EyePos()):Length()

        size = size * 120 / (math.pow(dist, 1.25))      -- the math is wrong here pls fix
    end

    local toscreen = pos:ToScreen()

    table.insert(ARC9.Flares, {
        pos = pos,
        x = toscreen.x,
        y = toscreen.y,
        size = ScreenScale(size),
        col = col
    })
end