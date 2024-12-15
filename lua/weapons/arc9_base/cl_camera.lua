SWEP.SmoothedMagnification = 1
SWEP.FOV = 90


-- local arc9_cheapscopes = GetConVar("arc9_cheapscopes")
local arc9_vm_cambob = GetConVar("arc9_vm_cambob")
local arc9_vm_cambobwalk = GetConVar("arc9_vm_cambobwalk")
local arc9_vm_cambobintensity = GetConVar("arc9_vm_cambobintensity")
local arc9_vm_camrollstrength = GetConVar("arc9_vm_camrollstrength")
local arc9_vm_camstrength = GetConVar("arc9_vm_camstrength")

local SmoothRecoilAmount = 0

function SWEP:CalcView(ply, pos, ang, fov)
    if self:GetOwner():ShouldDrawLocalPlayer() then return end

    local rec = (self:GetLastRecoilTime() + 0.25) - CurTime()

    local reckick = self:GetProcessedValue("RecoilKick")
    rec = rec * 3 * reckick

    if rec > 0 then
        ang.r = ang.r + (math.sin(CurTime() * self:GetProcessedValue("RecoilKickDamping", true)) * rec)
    end

    if self.RecoilKickAffectPitch then
        if !self:IsUsingRTScope() then
            local recam = math.min(self:GetRecoilAmount(), 15)
            SmoothRecoilAmount = Lerp(FrameTime() * 3, SmoothRecoilAmount, recam)
            local thing = SmoothRecoilAmount * reckick * self:GetProcessedValue("Recoil")
            ang.p = ang.p - 0.6 * thing
            self.VMZOffsetForCamera = -0.25 * thing
        end
    end

    local sightamount = self:GetSightAmount()

    -- does anybody knows what this part of code for? seems to be useless and breaks lean mods 
    -- if self:IsScoping() and arc9_cheapscopes:GetBool() then
    --     local shootang = self:GetShootDir()

    --     ang = LerpAngle(sightamount, ang, shootang)
    -- end

    fov = fov / self:GetSmoothedFOVMag()

    self.FOV = fov

    ang = ang + (self.StoredVMAngles or angle_zero)

    if arc9_vm_cambob:GetBool() then
        local sprintmult = arc9_vm_cambobwalk:GetBool() and 1 or Lerp(self:GetSprintAmount(), 0, 1)
        local totalmult = math.ease.InQuad(math.Clamp(self.ViewModelBobVelocity / 350, 0, 1) * Lerp(sightamount, 1, 0.65)) * sprintmult * arc9_vm_cambobintensity:GetFloat()
        ang:RotateAroundAxis(ang:Right(),   math.cos(self.BobCT * 6)    * totalmult * -0.5)
        ang:RotateAroundAxis(ang:Up(),      math.cos(self.BobCT * 3.3)  * totalmult * -0.5)
        ang:RotateAroundAxis(ang:Forward(), math.sin(self.BobCT * 6)    * totalmult * -0.36)
    end

    pos, ang = self:DoCameraLean(pos, ang)

    return pos, ang, fov
end

local mathapproach = math.Approach

function SWEP:GetSmoothedFOVMag()
    local mag = 1
    local speed = 1

    if self:GetInSights() then
        local target = self:GetMagnification()
        local sightdelta = self:GetSightAmount()
		local curTime = UnPredictedCurTime()
		local fuckingreloadprocess = math.Clamp(1 - (self:GetReloadFinishTime() - curTime) / (self.ReloadTime * self:GetAnimationTime("reload")), 0, 1)
		local reloadanim = self:GetAnimationEntry(self:TranslateAnimation("reload"))
		local shotgun = self:GetShouldShotgunReload()

        if self:GetInSights() then
            sightdelta = math.ease.OutQuart(sightdelta)
        else
            sightdelta = math.ease.InQuart(sightdelta)
        end
        sightdelta = math.ease.InOutQuad(sightdelta)

        if self.Peeking then
            target = self.IronSights.Magnification * 0.95
        end

		if !shotgun and fuckingreloadprocess < (reloadanim.PeekProgress or reloadanim.MinProgress or 0.9) then target = target * 0.95 end
			
		if shotgun and self:GetReloading() then target = target * 0.95 end
		
        mag = Lerp(sightdelta, 1, target)

        -- mag = target
        speed = Lerp(self:GetSightAmount(), speed, 10)
	else
		speed = Lerp(self:GetSightAmount(), 15, 10)
    end

    local diff = math.abs(self.SmoothedMagnification - mag)

    self.SmoothedMagnification = mathapproach(self.SmoothedMagnification, mag, FrameTime() * diff * speed)

    return self.SmoothedMagnification
end

SWEP.LastMuzzleAngle = Angle(0, 0, 0)
SWEP.MuzzleAngleVelocity = Angle(0, 0, 0)
SWEP.ProceduralViewOffset = Angle(0, 0, 0)
SWEP.ProceduralSpeedLimit = 5

function SWEP:GetCameraControl()
    local seqprox = self:GetSequenceProxy()
	
	if self:GetCustomize() then return end

    local camstrength = arc9_vm_camstrength:GetFloat()

    if camstrength == 0 then return end

    local rollstrength = arc9_vm_camrollstrength:GetFloat()
    if seqprox != 0 then
        local slottbl = self:LocateSlotFromAddress(seqprox)
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
        ang.p = ang.p * camstrength
        ang.y = ang.y * camstrength
        ang.r = ang.r * camstrength * rollstrength
        ang:Sub(atttbl.IKCameraMotionOffsetAngle or angle_zero)
        ang:Mul(self:GetProcessedValue("CamQCA_Mult", true) or 1)

        return ang
    else
        local camqca = self:GetProcessedValue("CamQCA", true)

        if !camqca then return end

        local vm = self:GetVM()

        local ang = (vm:GetAttachment(camqca) or {}).Ang

        if !ang then return end

        ang = vm:WorldToLocalAngles(ang)
        ang:Sub(self.CamOffsetAng)

        if self:GetProcessedValue("CamCoolView", true) then
            local ft = FrameTime()

            self.ProceduralViewOffset:Normalize()
            
            ang:Normalize()
            local delta = self.LastMuzzleAngle - ang
            delta:Normalize()

            local targeting = self:GetNextPrimaryFire() - .1 > CurTime()
            local target = targeting and 1 or 0
            target = math.min(target, 1 - math.pow( vm:GetCycle(), 2 ) )
            local progress = Lerp(ft * 15, progress or 0, target)

            local mult = self:GetProcessedValue("CamQCA_Mult", true) or 1

            if self:GetAnimLockTime() < CurTime() and !self:GetInMeleeAttack() then
                mult = 0
            end

            self.MuzzleAngleVelocity = self.MuzzleAngleVelocity + delta * 2 * mult
            self.MuzzleAngleVelocity.p = mathapproach(self.MuzzleAngleVelocity.p, -self.ProceduralViewOffset.p * 2, ft * 20)
            self.MuzzleAngleVelocity.p = math.Clamp(self.MuzzleAngleVelocity.p, -self.ProceduralSpeedLimit, self.ProceduralSpeedLimit)
            self.ProceduralViewOffset.p = self.ProceduralViewOffset.p + self.MuzzleAngleVelocity.p * ft
            self.ProceduralViewOffset.p = math.Clamp(self.ProceduralViewOffset.p, -90, 90)
            self.MuzzleAngleVelocity.y = mathapproach(self.MuzzleAngleVelocity.y, -self.ProceduralViewOffset.y * 2, ft * 20)
            self.MuzzleAngleVelocity.y = math.Clamp(self.MuzzleAngleVelocity.y, -self.ProceduralSpeedLimit, self.ProceduralSpeedLimit)
            self.ProceduralViewOffset.y = self.ProceduralViewOffset.y + self.MuzzleAngleVelocity.y * ft
            self.ProceduralViewOffset.y = math.Clamp(self.ProceduralViewOffset.y, -90, 90)
            self.MuzzleAngleVelocity.r = mathapproach(self.MuzzleAngleVelocity.r, -self.ProceduralViewOffset.r * 2, ft * 20)
            self.MuzzleAngleVelocity.r = math.Clamp(self.MuzzleAngleVelocity.r, -self.ProceduralSpeedLimit, self.ProceduralSpeedLimit)
            self.ProceduralViewOffset.r = self.ProceduralViewOffset.r + self.MuzzleAngleVelocity.r * ft
            self.ProceduralViewOffset.r = math.Clamp(self.ProceduralViewOffset.r, -90, 90)

            self.ProceduralViewOffset.p = mathapproach(self.ProceduralViewOffset.p, 0, (1 - progress) * ft * -self.ProceduralViewOffset.p)
            self.ProceduralViewOffset.y = mathapproach(self.ProceduralViewOffset.y, 0, (1 - progress) * ft * -self.ProceduralViewOffset.y)
            self.ProceduralViewOffset.r = mathapproach(self.ProceduralViewOffset.r, 0, (1 - progress) * ft * -self.ProceduralViewOffset.r) * rollstrength

            self.LastMuzzleAngle = ang

            return self.ProceduralViewOffset
        else
            ang:Mul(self:GetProcessedValue("CamQCA_Mult", true) or 1)
            ang:Mul(1 - self:GetSightAmount() * (1 - (self:GetProcessedValue("CamQCA_Mult_ADS", true) or 0.5)))
			ang.p = ang.p * camstrength
			ang.y = ang.y * camstrength
            ang.r = ang.r * camstrength * rollstrength
        end

        return ang
    end
end

-- 100, 100 = 1
-- 100, 90 = 0.8
-- 100, 70 = 0.6
-- 100, 60 = 0.5
-- 100, 40 = 0.3

function SWEP:GetCorVal()
    local vmfov = self.ViewModelFOV
    local fov = self.FOV

    return vmfov / (fov * 1.333333)
end