SWEP.SmoothedMagnification = 1

function SWEP:CalcView(ply, pos, ang, fov)
    local rec = (self:GetLastRecoilTime() + self:GetProcessedValue("RecoilResetTime")) - CurTime()

    rec = rec * 10

    rec = math.Clamp(rec, 0, 1)

    rec = rec * self:GetProcessedValue("RecoilKick")

    if rec > 0 then
        ang.r = ang.r + (math.sin(CurTime() * 70.151) * rec * 0.25)
    end

    fov = fov / self:GetSmoothedFOVMag()

    return pos, ang, fov
end

function SWEP:GetSmoothedFOVMag()
    local mag = 1

    if self:GetSightAmount() > 0 then
        local target = self:GetMagnification()

        mag = Lerp(self:GetSightAmount(), 1, target)
    end

    local diff = math.abs(self.SmoothedMagnification - mag)

    self.SmoothedMagnification = math.Approach(self.SmoothedMagnification, mag, FrameTime() * diff * diff * 60)

    return self.SmoothedMagnification
end