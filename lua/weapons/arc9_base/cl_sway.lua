SWEP.ViewModelVelocityPos = Vector(0, 0, 0)
SWEP.ViewModelVelocityAng = Angle(0, 0, 0)

SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)

SWEP.SwayCT = 0

function SWEP:GetViewModelSway(pos, ang)
    -- local d = Lerp(self:GetSightAmount(), 1, 0.02)
    -- local v = 1
    -- local steprate = 1

    -- d = d * 0.25

    -- pos = pos + (ang:Up() * (math.sin(self.SwayCT * 0.311 * v) + math.cos(self.SwayCT * 0.44 * v)) * math.sin(CurTime() * 0.8) * d)
    -- pos = pos + (ang:Right() * (math.sin(self.SwayCT * 0.324 * v) + math.cos(self.SwayCT * 0.214 * v)) * math.sin(CurTime() * 0.76) * d)

    -- if IsFirstTimePredicted() then
    --     self.SwayCT = self.SwayCT + (FrameTime() * steprate)
    -- end

    return pos, ang
end

SWEP.ViewModelLastEyeAng = Angle(0, 0, 0)
SWEP.ViewModelSwayInertia = Angle(0, 0, 0)

function SWEP:GetViewModelInertia(pos, ang)
    local d = 1 - self:GetSightAmount()

    local diff = self:GetOwner():EyeAngles() - self.ViewModelLastEyeAng

    diff = diff / 4

    diff.p = math.Clamp(diff.p, -1, 1)
    diff.y = math.Clamp(diff.y, -1, 1)

    local vsi = self.ViewModelSwayInertia

    vsi.p = math.ApproachAngle(vsi.p, diff.p, vsi.p / 10 * FrameTime() / 0.5)
    vsi.y = math.ApproachAngle(vsi.y, diff.y, vsi.y / 10 * FrameTime() / 0.5)

    self.ViewModelLastEyeAng = self:GetOwner():EyeAngles()

    ang:RotateAroundAxis(ang:Up(), vsi.y * 12 * d)
    ang:RotateAroundAxis(ang:Right(), -vsi.p * 12 * d)

    -- pos = pos - (ang:Up() * vsi.p * 0.5 * d)
    -- pos = pos - (ang:Right() * vsi.y * 0.5 * d)

    return pos, ang
end

function SWEP:GetViewModelSmooth(pos, ang)
    return pos, ang
end

SWEP.ViewModelBobVelocity = 0
SWEP.ViewModelNotOnGround = 0

SWEP.BobCT = 0

function SWEP:GetViewModelBob(pos, ang)
    local step = 10
    local mag = 1

    local v = self:GetOwner():GetVelocity():Length()
    v = math.Clamp(v, 0, 350)
    self.ViewModelBobVelocity = math.Approach(self.ViewModelBobVelocity, v, FrameTime() * 10000)
    local d = math.Clamp(self.ViewModelBobVelocity / 350, 0, 1)

    if self:GetOwner():OnGround() then
        self.ViewModelNotOnGround = math.Approach(self.ViewModelNotOnGround, 0, FrameTime() / 1)
    else
        self.ViewModelNotOnGround = math.Approach(self.ViewModelNotOnGround, 1, FrameTime() / 1)
    end

    d = d * Lerp(self:GetSightAmount(), 1, 0.5)
    mag = d * 2
    step = 10

    ang:RotateAroundAxis(ang:Forward(), math.sin(self.BobCT * step * 0.5) * ((math.sin(CurTime() * 6.151) * 0.2) + 1) * 4.5 * d)
    ang:RotateAroundAxis(ang:Right(), math.sin(self.BobCT * step * 0.12) * ((math.sin(CurTime() * 1.521) * 0.2) + 1) * 2.11 * d)
    pos = pos - (ang:Up() * math.sin(self.BobCT * step) * 0.07 * ((math.sin(CurTime() * 3.515) * 0.2) + 1) * mag)
    pos = pos + (ang:Forward() * math.sin(self.BobCT * step * 0.3) * 0.11 * ((math.sin(CurTime() * 1.615) * 0.2) + 1) * mag)
    pos = pos + (ang:Right() * (math.sin(self.BobCT * step * 0.15) + (math.cos(self.BobCT * step * 0.3332))) * 0.16 * mag)

    local steprate = Lerp(d, 1, 2.5)

    steprate = Lerp(self.ViewModelNotOnGround, steprate, 0.25)

    if IsFirstTimePredicted() or game.SinglePlayer() then
        self.BobCT = self.BobCT + (FrameTime() * steprate)
    end

    return pos, ang
end

SWEP.LastViewModelVerticalVelocity = 0
-- SWEP.ViewModelLanded = 0
-- SWEP.ViewModelLanding = 0

function SWEP:GetMidAirBob(pos, ang)
    local v = -self:GetOwner():GetVelocity().z / 200

    v = math.Clamp(v, -1, 1)

    -- if v == 0 and self.LastViewModelVerticalVelocity != 0 then
    --     self.ViewModelLanding = self.LastViewModelVerticalVelocity
    --     self.ViewModelLanded = 1
    -- end

    -- if self.ViewModelLanded > 0 then
    --     self.ViewModelLanded = math.Approach(self.ViewModelLanded, 0, FrameTime() / 0.25)

    v = Lerp(5 * FrameTime(), self.LastViewModelVerticalVelocity, v)
    -- end

    self.LastViewModelVerticalVelocity = v

    local d = self.ViewModelNotOnGround

    d = d * Lerp(self:GetSightAmount(), 1, 0.1)

    ang:RotateAroundAxis(ang:Right(), -v * d * 8 * math.sin(CurTime() * 0.15))

    return pos, ang
end

SWEP.ViewModelInertiaX = 0
SWEP.ViewModelInertiaY = 0

function SWEP:GetViewModelLeftRight(pos, ang)
    local v = self:GetOwner():GetVelocity()
    local d = Lerp(self:GetSightDelta(), 1, 0)

    v, _ = WorldToLocal(v, Angle(0, 0, 0), Vector(0, 0, 0), self:GetOwner():EyeAngles())

    local vx = math.Clamp(v.x / 200, -1, 1)
    local vy = math.Clamp(v.y / 200, -1, 1)

    self.ViewModelInertiaX = math.Approach(self.ViewModelInertiaX, vx, math.abs(vx) * FrameTime() / 0.1)
    self.ViewModelInertiaY = math.Approach(self.ViewModelInertiaY, vy, math.abs(vy) * FrameTime() / 0.1)

    pos = pos + (ang:Right() * -self.ViewModelInertiaX * 0.65 * d)
    pos = pos + (ang:Forward() * self.ViewModelInertiaY * 0.5 * d)

    return pos, ang
end