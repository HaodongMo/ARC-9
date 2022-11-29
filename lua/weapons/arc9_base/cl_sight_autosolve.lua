function SWEP:GenerateAutoSight(sight, slottbl)
    local pos, ang = self:GetAttPos(slottbl, false, true)
    local scale = slottbl.Scale or 1

    pos = pos - (ang:Right() * sight.Pos.x * scale)
    pos = pos - (ang:Forward() * sight.Pos.y * scale)
    pos = pos - (ang:Up() * sight.Pos.z * scale)

    ang:RotateAroundAxis(ang:Right(), sight.Ang.p)
    ang:RotateAroundAxis(ang:Up(), sight.Ang.y)
    ang:RotateAroundAxis(ang:Forward(), sight.Ang.r)

    debugoverlay.Axis(pos, ang, 16, 1, true)

    local s_pos = Vector(0, self:GetProcessedValue("AdditionalSightDistance"), 0)
    local s_ang = Angle(0, 0, 0)

    local up, forward, right = s_ang:Up(), s_ang:Forward(), s_ang:Right()

    s_pos = s_pos + (right * pos.x)
    s_pos = s_pos + (forward * pos.y)
    s_pos = s_pos + (up * -pos.z)

    -- print(ang)

    return {
        Pos = s_pos,
        Ang = -ang + (slottbl.CorrectiveAng or angle_zero),
        -- ExtraPos = Vector(0, pos.y + self.IronSights.Pos.y, 0),
        Magnification = sight.Magnification or 1,
        ExtraSightDistance = slottbl.ExtraSightDistance,
        GeneratedSight = true,
        -- ExtraAng = ang
        ShadowPos = sight.ShadowPos,
        Reticle = sight.Reticle,
        RTScopeFOV = sight.RTScopeFOV
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
        local atttbl = sight.atttbl

        if sight.BaseSight then
            atttbl = self:GetTable()
        end

        if atttbl and atttbl.RTScope and !atttbl.RTCollimator then
            -- target = (self:GetOwner():GetFOV() / self:GetRTScopeFOV())

            local realfov = self:GetOwner():GetFOV()
            local screenamt = ((ScrW() - ScrH()) / ScrW()) * (atttbl.ScopeScreenRatio or 0.5) * 2
            target = (realfov / self:GetRTScopeFOV()) * screenamt

            target = math.max(target, 1)
        end
    end

    return target
end

function SWEP:AdjustMouseSensitivity()
    if !self:GetInSights() then return end
    if !GetConVar("arc9_compensate_sens"):GetBool() then return end

    if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) then
        return
    end

    local mag = self:GetMagnification()
    local fov = GetConVar("fov_desired"):GetFloat()

    local sight = self:GetSight()
    local atttbl = sight.atttbl

    if sight.BaseSight then
        atttbl = self:GetTable()
    end

    if atttbl and atttbl.RTScope and !sight.Disassociate and !atttbl.RTCollimator then
        mag = mag + (fov / (self:GetRTScopeFOV() or 90))
    end

    if mag > 0 then
        return 1 / (1 - (self:GetSightAmount() * (1 - mag)))
    end
end