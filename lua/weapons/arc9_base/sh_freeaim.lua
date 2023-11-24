SWEP.ClientFreeAimAng = Angle(0, 0, 0)

local faconvar = GetConVar("arc9_mod_freeaim")

function SWEP:ThinkFreeAim()
    if !faconvar:GetBool() then return true end

    local diff = self:GetOwner():EyeAngles() - self:GetLastAimAngle()

    local freeaimang = Angle(self:GetFreeAimAngle())

    local max = self:GetProcessedValue("FreeAimRadius")

    diff.p = math.NormalizeAngle(diff.p)
    diff.y = math.NormalizeAngle(diff.y)

    diff = diff * 0.25

    freeaimang.p = math.Clamp(math.NormalizeAngle(freeaimang.p) + math.NormalizeAngle(diff.p), -max, max)
    freeaimang.y = math.Clamp(math.NormalizeAngle(freeaimang.y) + math.NormalizeAngle(diff.y), -max, max)

    local ang2d = math.atan2(freeaimang.p, freeaimang.y)
    local mag2d = math.sqrt(math.pow(freeaimang.p, 2) + math.pow(freeaimang.y, 2))

    mag2d = math.min(mag2d, max)

    freeaimang.p = mag2d * math.sin(ang2d)
    freeaimang.y = mag2d * math.cos(ang2d)

    self:SetFreeAimAngle(freeaimang)

    if CLIENT then
        self.ClientFreeAimAng = freeaimang
    end

    self:SetLastAimAngle(self:GetOwner():EyeAngles())
end

function SWEP:GetFreeAimOffset()
    if !faconvar:GetBool() then return angle_zero end
    if CLIENT then
        return self.ClientFreeAimAng
    else
        return self:GetFreeAimAngle()
    end
end

local arc9_mod_sway = GetConVar("arc9_mod_sway")

local smoothswayamt = 0

function SWEP:GetFreeSwayAngles()
    if !arc9_mod_sway:GetBool() then return end
    local swayamt = self:GetFreeSwayAmount()
    if swayamt == 0 then return end

    local swayspeed = 2
    local isScope = self:IsUsingRTScope()

    swayamt = isScope and 0 or swayamt * (1-self:GetSightAmount() * 0.2)
    smoothswayamt = CLIENT and Lerp(RealFrameTime(), smoothswayamt, swayamt) or swayamt

    local ang = Angle(math.sin(CurTime() * 0.6 * swayspeed) + (math.cos(CurTime() * 2) * 0.5), math.sin(CurTime() * 0.4 * swayspeed) + (math.cos(CurTime() * 1.6) * 0.5), 0)

    ang = ang * smoothswayamt

    return ang
end