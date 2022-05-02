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
    if self.EFTRecoil then
        local ftmult = self:GetProcessedValue("RecoilDissipationRate") / 3
        local srupmult = self:GetProcessedValue("RecoilUp") * 10
        local srsidemult = self:GetProcessedValue("RecoilSide") * 5

        SmoothRecoilUp = Lerp(FrameTime()*ftmult, SmoothRecoilUp, self:GetRecoilUp()*srupmult)
        SmoothRecoilSide = Lerp(FrameTime()*(ftmult + 2), SmoothRecoilSide, self:GetRecoilSide()*srsidemult)
        ang.p = ang.p + SmoothRecoilUp
        ang.y = ang.y + SmoothRecoilSide
    end

    fov = fov / self:GetSmoothedFOVMag()

    self.FOV = fov

    for _, mod in pairs(self.FOV_RecoilMods) do
        local per_pre = math.TimeFraction( mod.realstart, mod.time_start, CurTime() )
        local per_act = math.TimeFraction( mod.time_start, mod.time_end, CurTime() )
        if per_act < 0 then
            per_act = per_pre
            if mod.func_pre then per_act = mod.func_pre(per_act) end
        else
            per_act = 1-per_act
            if mod.func_act then per_act = mod.func_act(per_act) end
        end
        per_act = math.Clamp(per_act, 0, 1)
        fov = fov + (mod.amount * per_act)
        if mod.time_end < CurTime() then self.FOV_RecoilMods[_] = nil end
    end

    ang = ang + (self:GetCameraControl() or Angle(0, 0, 0))

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

        mag = Lerp(sightdelta, 1, target)
        -- mag = target
        speed = Lerp(self:GetSightAmount(), speed, 10)
    end

    local diff = math.abs(self.SmoothedMagnification - mag)

    self.SmoothedMagnification = math.Approach(self.SmoothedMagnification, mag, FrameTime() * diff * speed)

    return self.SmoothedMagnification
end

function SWEP:GetCameraControl()
    local camqca = self:GetProcessedValue("CamQCA")

    if !camqca then return end

    local vm = self:GetVM()

    local ang = (vm:GetAttachment(camqca) or {}).Ang

    if !ang then return end

    ang = vm:WorldToLocalAngles(ang)
    ang:Sub(self.CamOffsetAng)
    ang:Mul(self:GetProcessedValue("CamQCA_Mult") or 1)
    ang:Mul(1-(self:GetSightAmount() * 1-(self:GetProcessedValue("CamQCA_Mult_ADS") or 0.5)))

    return ang
end