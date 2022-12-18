SWEP.SmoothedMagnification = 1
SWEP.FOV = 90

local SmoothRecoilUp = 0
local SmoothRecoilSide = 0

function SWEP:CalcView(ply, pos, ang, fov)
    if self:GetOwner():ShouldDrawLocalPlayer() then return end

    local rec = (self:GetLastRecoilTime() + 0.25) - CurTime()

    rec = rec * 3

    rec = rec * self:GetProcessedValue("RecoilKick")

    if rec > 0 then
        ang.r = ang.r + (math.sin(CurTime() * self:GetProcessedValue("RecoilKickDamping")) * rec)
    end

    -- EFT like recoil
    if self.ViewRecoil then
        local ftmult = self:GetProcessedValue("RecoilDissipationRate") / 3
        local srupmult = self:GetProcessedValue("RecoilUp") * (self:GetProcessedValue("ViewRecoilUpMult") or 50)
        local srsidemult = self:GetProcessedValue("RecoilSide") * (self:GetProcessedValue("ViewRecoilSideMult") or 2)

        srupmult = srupmult - 10
        ftmult = self:GetProcessedValue("RecoilDissipationRate") / 3

        SmoothRecoilUp = Lerp(FrameTime() * ftmult, SmoothRecoilUp, self:GetRecoilUp() * srupmult)
        SmoothRecoilSide = Lerp(FrameTime() * (ftmult + 2), SmoothRecoilSide, self:GetRecoilSide() * srsidemult)


        ang.p = ang.p + SmoothRecoilUp
        ang.y = ang.y + SmoothRecoilSide
    end

    if self:IsScoping() and GetConVar("arc9_cheapscopes"):GetBool() then
        local _, shootang = self:GetShootPos()

        ang = LerpAngle(self:GetSightAmount(), ang, shootang)
    end

    fov = fov / self:GetSmoothedFOVMag()

    self.FOV = fov

    ang = ang + (self:GetCameraControl() or angle_zero)

    return pos, ang, fov
end

function SWEP:GetSmoothedFOVMag()
    local mag = 1
    local speed = 20

    if self:GetInSights() then
        local target = self:GetMagnification()
        local sightdelta = self:GetSightAmount()

        if self:GetInSights() then
            sightdelta = math.ease.OutQuart(sightdelta)
        else
            sightdelta = math.ease.InQuart(sightdelta)
        end
        sightdelta = math.ease.InOutQuad(sightdelta)

        if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) then
            target = 1
        end

        mag = Lerp(sightdelta, 1, target)

        -- mag = target
        speed = Lerp(self:GetSightAmount(), speed, 10)
    end

    local diff = math.abs(self.SmoothedMagnification - mag)

    self.SmoothedMagnification = math.Approach(self.SmoothedMagnification, mag, FrameTime() * diff * speed)

    return self.SmoothedMagnification
end

function SWEP:GetCameraControl()
    if self:GetSequenceProxy() != 0 then
        local slottbl = self:LocateSlotFromAddress(self:GetSequenceProxy())
        local atttbl = self:GetFinalAttTable(slottbl)
        local camqca = atttbl.IKCameraMotionQCA

        if !camqca then return end

        local mdl = slottbl.GunDriverModel

        mdl:SetPos(vector_origin)
        mdl:SetAngles(angle_zero)

        mdl:SetSequence(self:GetSequenceIndex())
        mdl:SetCycle(self:GetSequenceCycle())

        local ang = (mdl:GetAttachment(camqca) or {}).Ang

        if !ang then return end

        ang = mdl:WorldToLocalAngles(ang)
        ang:Sub(atttbl.IKCameraMotionOffsetAngle or angle_zero)
        ang:Mul(self:GetProcessedValue("CamQCA_Mult") or 1)
        ang:Mul(1 - self:GetSightAmount() * (1 - (self:GetProcessedValue("CamQCA_Mult_ADS") or 0.5)))

        return ang
    else
        local camqca = self:GetProcessedValue("CamQCA")

        if !camqca then return end

        local vm = self:GetVM()

        local ang = (vm:GetAttachment(camqca) or {}).Ang

        if !ang then return end

        ang = vm:WorldToLocalAngles(ang)
        ang:Sub(self.CamOffsetAng)
        ang:Mul(self:GetProcessedValue("CamQCA_Mult") or 1)
        ang:Mul(1 - self:GetSightAmount() * (1 - (self:GetProcessedValue("CamQCA_Mult_ADS") or 0.5)))

        return ang
    end
end

// 100, 100 = 1
// 100, 90 = 0.8
// 100, 70 = 0.6
// 100, 60 = 0.5
// 100, 40 = 0.3

function SWEP:GetCorVal()
    local vmfov = self.ViewModelFOV
    local fov = self.FOV

    return vmfov / (fov * 1.33333)
end