local badcolor = Color(255, 255, 255)

SWEP.FlaresAlreadyDrawn = {}

function SWEP:DrawLightFlare(pos, ang, col, size, flareid, vm, nodotter)
    col = col or badcolor
    size = size or 1
    local lp = LocalPlayer()
    local campos = vm and EyePos() or lp:GetViewEntity():GetPos()

    if !vm then -- walls!!!!!
        local tr = util.TraceLine({
            start = campos,
            endpos = pos,
            mask = MASK_OPAQUE,
            filter = lp,
        })

        if tr.Fraction != 1 then return end
    end

    local dotter = 1
    if !nodotter then
        local diff = campos - pos
        if -ang:Right():Dot(diff) < 0 then return end
        dotter = math.max(0, -ang:Right():Dot(diff) / diff:Length())

        if dotter < 0.4 then return end
        dotter = math.ease.InExpo(dotter)
    end

    local distancer = math.ease.InExpo(math.max(1 - campos:DistToSqr(pos) * 0.0000005, 0))

    size = size * dotter * 3 * distancer

    if self.FlaresAlreadyDrawn[flareid] then return end
    self.FlaresAlreadyDrawn[flareid] = true

    table.insert(ARC9.Flares, {
        pos = pos,
        size = math.Clamp(size, 0, 1000),
        color = col,
        invm = vm
    })
end