SWEP.SmoothedMagnification = 1
SWEP.FOV = 90

function SWEP:CalcView(ply, pos, ang, fov)
    if self:GetOwner():ShouldDrawLocalPlayer() then return end

    local rec = (self:GetLastRecoilTime() + 0.25) - CurTime()

    -- rec = rec * 0.5

    rec = rec * self:GetProcessedValue("RecoilKick")

    if rec > 0 then
        ang.r = ang.r + (math.sin(CurTime() * 70.151) * rec)
    end

    fov = fov / self:GetSmoothedFOVMag()

    self.FOV = fov

    local cameracntrl = self:GetCameraControl()
    if cameracntrl then
        ang:Add(cameracntrl)
    end

    return pos, ang, fov
end

function SWEP:GetSmoothedFOVMag()
    local mag = 1

    if self:GetSightAmount() > 0 then
        local target = self:GetMagnification()

        mag = Lerp(math.ease.InQuint(self:GetSightAmount()), 1, target)
    end

    local diff = math.abs(self.SmoothedMagnification - mag)

    self.SmoothedMagnification = math.Approach(self.SmoothedMagnification, mag, FrameTime() * diff * 150)

    return self.SmoothedMagnification
end

function SWEP:GetCameraControl()
    local camqca = self:GetProcessedValue("CamQCA")

    if !camqca then return end

    local vm = self:GetVM()

    local ang = vm:GetAttachment(camqca).Ang
    ang = vm:WorldToLocalAngles(ang)
    ang:Sub(self.CamOffsetAng)

    return ang
end