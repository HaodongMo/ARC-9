local badcolor = Color(255, 255, 255)

function SWEP:DrawLightFlare(pos, ang, col, size)
    -- ARC9.NEXTFLARE = true 
    col = col or badcolor
    size = size or 1
    local campos = LocalPlayer():GetViewEntity():GetPos()

	local diff = campos - pos
    if -ang:Right():Dot(diff) < 0 then return end
    local dotter = math.max(0, -ang:Right():Dot(diff) / diff:Length())


    if dotter < 0.4 then return end
    -- dotter = math.ease.InCirc(math.ease.InExpo(dotter))
    dotter = math.ease.InExpo(dotter)
    if dotter!=dotter then return end
    
    local distancer = math.ease.InExpo(math.max(1 - campos:DistToSqr(pos) * 0.0000005, 0))
    size = size * dotter * 1 * distancer
    
    -- cam.Start3D()
    -- local toscreen = pos:ToScreen()
    -- cam.End3D()
    -- print(dotter, distancer)
    ARC9.Flares[#ARC9.Flares+1] = {
        pos = pos,
        size = ScreenScale(math.Clamp(size, 0, 200)),
        color = col
    }
end