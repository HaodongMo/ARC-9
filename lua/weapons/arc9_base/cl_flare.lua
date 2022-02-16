local flaremat = Material("particle/particle_glow_04", "mips smooth")
flaremat:SetInt("$additive", 1)

function SWEP:DrawLightFlare(pos, norm, col, size)
    col = col or Color(255, 255, 255)
    size = size or 1
    local eyevec = pos - EyePos()

    local dot = norm:Dot(eyevec)


end