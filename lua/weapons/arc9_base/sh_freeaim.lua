function SWEP:ThinkFreeAim()
    local eyeAngles = self:GetOwner():EyeAngles()
    local lastAimPitch = self:GetLastAimPitch()
    local lastAimYaw = self:GetLastAimYaw()

    -- local diff = self:GetOwner():EyeAngles() - self:GetLastAimAngle()
    -- diff:Normalize()

    local freeAimPitch = self:GetFreeAimPitch()
    local freeAimYaw = self:GetFreeAimYaw()
    local max = self:GetProcessedValue("FreeAimRadius")

    local pitchDelta = math.NormalizeAngle(eyeAngles.p - lastAimPitch) * 0.25
    local yawDelta = math.NormalizeAngle(eyeAngles.y - lastAimYaw) * 0.25

    freeAimPitch = math.Clamp(math.NormalizeAngle(freeAimPitch + pitchDelta), -max, max)
    freeAimYaw = math.Clamp(math.NormalizeAngle(freeAimYaw + yawDelta), -max, max)

    local ang2d = math.atan2(freeAimPitch, freeAimYaw)
    local mag2d = math.sqrt(math.pow(freeAimPitch, 2) + math.pow(freeAimYaw, 2))

    mag2d = math.min(mag2d, max)

    freeAimPitch = mag2d * math.sin(ang2d)
    freeAimYaw = mag2d * math.cos(ang2d)

    -- Thank Garry's Mod's m_GMOD_QAngle compression for this mess.
    self:SetFreeAimPitch(freeAimPitch)
    self:SetFreeAimYaw(freeAimYaw)
    self:SetLastAimPitch(eyeAngles.p)
    self:SetLastAimYaw(eyeAngles.y)
end

function SWEP:GetFreeAimOffset()
    if !GetConVar("arc9_freeaim"):GetBool() then return Angle(0, 0, 0) end

    return Angle(self:GetFreeAimPitch(), self:GetFreeAimYaw(), 0)
end

function SWEP:GetFreeSwayAngles()
    local freeSwayAngles = Angle(0, 0, 0)
    if !GetConVar("arc9_freeaim"):GetBool() then
        return freeSwayAngles
    end

    local swayamt = self:GetFreeSwayAmount() * (1 - self:GetSightAmount())
    local swayspeed = 1

    freeSwayAngles.p = (math.sin(CurTime() * 0.6 * swayspeed) + (math.cos(CurTime() * 2) * 0.5)) * swayamt
    freeSwayAngles.y = (math.sin(CurTime() * 0.4 * swayspeed) + (math.cos(CurTime() * 1.6) * 0.5)) * swayamt
    -- No need to normalize here unless swayamt becomes absurdly high number for whatever reason.
    -- freeSwayAngles:Normalize()

    return freeSwayAngles
end
