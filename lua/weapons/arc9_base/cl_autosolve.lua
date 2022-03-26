function SWEP:GenerateAutoSight(sight, slottbl)
    local pos, ang = self:GetAttPos(slottbl, false, true)
    local scale = slottbl.Scale or 1

    pos:Sub(ang:Right() * sight.Pos.x * scale)
    pos:Sub(ang:Forward() * sight.Pos.y * scale)
    pos:Sub(ang:Up() * sight.Pos.z * scale)

    ang:RotateAroundAxis(ang:Right(), sight.Ang.p)
    ang:RotateAroundAxis(ang:Up(), sight.Ang.y)
    ang:RotateAroundAxis(ang:Forward(), sight.Ang.r)

    debugoverlay.Axis(pos, ang, 16, 1, true)

    -- local s_pos = Vector(0, 0, 0)
    -- local s_ang = Angle(0, 0, 0)

    -- s_ang is defined right above as angle 0, 0, 0 therefore these will always be Vector(1, 0, 0), Vector(0, -1, 0), Vector(0, 0, 1)
    -- I moved their definitions to sh_common.lua
    -- local up, forward, right = s_ang:Up(), s_ang:Forward(), s_ang:Right()

    -- Since the direction vectors are static constant variables this can be represented as simple Add(Vector()) operation, see blow.
    -- s_pos:Add(ARC9_VECTORRIGHT * pos.x)
    -- s_pos:Add(ARC9_VECTORFORWARD * pos.y)
    -- s_pos:Add(ARC9_VECTORUP * -pos.z)

    -- Tadaaaaa, also we don't need this because we know exactly what the vector is supposed to be so...
    -- s_pos:Add(Vector(pos.y, -pos.x, -pos.z))

    -- This could also be represented as local s_pos = pos:ShiftLeft()

    -- print(ang)

    return {
        Pos = Vector(pos.y, -pos.x, -pos.z), -- s_pos
        Ang = -ang + (slottbl.CorrectiveAng or Angle(0, 0, 0)),
        -- ExtraPos = Vector(0, pos.y + self.IronSights.Pos.y, 0),
        Magnification = sight.Magnification or 1,
        ExtraSightDistance = slottbl.ExtraSightDistance,
        GeneratedSight = true,
        -- ExtraAng = ang
    }
end

SWEP.MultiSightIndex = 1

function SWEP:GetSightPositions()
    local s = self:GetSight()
    return s.Pos, s.Ang
end

function SWEP:GetExtraSightPositions()
    local s = self:GetSight()
    local se = s.ExtraPos or Vector(0, 0, 0)
    se.y = se.y - (s.ExtraSightDistance or 0)
    -- return Vector(0, 0, 0), Angle(0, 0, 0)
    return se, s.ExtraAng or Angle(0, 0, 0)
end

function SWEP:GetMagnification()
    local sight = self:GetSight()
    local target = sight.Magnification or 1

    if GetConVar("arc9_cheapscopes"):GetBool() and !sight.Disassociate then
        local atttbl = self:GetSight().atttbl

        if atttbl and atttbl.RTScope then
            target = (self:GetOwner():GetFOV() / self:GetRTScopeFOV())
        end
    end

    return target
end

function SWEP:AdjustMouseSensitivity()
    if self:GetSightAmount() <= 0 then return end

    local mag = self:GetMagnification()
    local fov = GetConVar("fov_desired"):GetFloat()

    local sight = self:GetSight()

    if sight.atttbl and sight.atttbl.RTScope and !sight.Disassociate then
        mag = mag + (fov / self:GetRTScopeFOV())
    end

    if mag > 0 then
        return 1 / Lerp(self:GetSightAmount(), 1, mag)
    end
end