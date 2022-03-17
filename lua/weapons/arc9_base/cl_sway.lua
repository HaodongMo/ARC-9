SWEP.ViewModelVelocityPos = Vector(0, 0, 0)
SWEP.ViewModelVelocityAng = Angle(0, 0, 0)
SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)
SWEP.SwayCT = 0
local lasteyeang = Angle(0, 0, 0)
local smootheyeang = Angle(0, 0, 0)
local pos_offset = Vector(0, 0, 0)
local ang_offset = Angle(0, 0, 0)

-- local look_lerp = Angle(0, 0, 0)

local lookxmult = 1
local lookymult = 1

function SWEP:GetViewModelSway(pos, ang)
    local sightedmult = Lerp(self:GetSightAmount(), 1, 0.25)
    smootheyeang = LerpAngle(0.05, smootheyeang, EyeAngles() - lasteyeang)
    pos_offset.x = -smootheyeang.x * -0.5 * sightedmult * lookxmult
    pos_offset.y = smootheyeang.y * 0.5 * sightedmult * lookymult
    ang_offset.x = pos_offset.x * 2.5
    ang_offset.y = pos_offset.y * 2.5
    ang_offset.r = (pos_offset.x * 2) + (pos_offset.y * -2)
    -- local a1 = look_lerp.y
    -- local a2 = ang_offset.y * -3 + smootheyeang.y
    -- look_lerp.y = math.ApproachAngle(a1, a2, FrameTime() * math.abs(math.AngleDifference(a1, a2)) * 50)
    -- look_lerp.y = 0
    -- ang.y = ang.y - look_lerp.y
    -- ang = ang - look_lerp
    pos:Add(ang:Up() * pos_offset.x)
    pos:Add(ang:Right() * pos_offset.y)
    ang:Add(ang_offset)
    lasteyeang = EyeAngles()

    return pos, ang
end

function SWEP:RotateAroundPoint(pos, ang, point, offset, offset_ang)
    local v = Vector(0, 0, 0)
    v = v + (point.x * ang:Right())
    v = v + (point.y * ang:Forward())
    v = v + (point.z * ang:Up())

    ang:RotateAroundAxis(ang:Right(), offset_ang.p)
    ang:RotateAroundAxis(ang:Forward(), offset_ang.r)
    ang:RotateAroundAxis(ang:Up(), offset_ang.y)

    v = v + ang:Right() * offset.x
    v = v + ang:Forward() * offset.y
    v = v + ang:Up() * offset.z

    v:Rotate(offset_ang)

    v = v - (point.x * ang:Right())
    v = v - (point.y * ang:Forward())
    v = v - (point.z * ang:Up())

    pos = pos + v

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
    local ts = 0 -- self:GetTraversalSprintAmount()
    -- ts = 1
    if self:GetCustomize() then return pos, ang end
    local v = self:GetOwner():GetVelocity():Length()
    v = math.Clamp(v, 0, 350)
    self.ViewModelBobVelocity = math.Approach(self.ViewModelBobVelocity, v, FrameTime() * 10000)
    local d = math.Clamp(self.ViewModelBobVelocity / 350, 0, 1)

    if self:GetOwner():OnGround() and self:GetOwner():GetMoveType() ~= MOVETYPE_NOCLIP then
        self.ViewModelNotOnGround = math.Approach(self.ViewModelNotOnGround, 0, FrameTime() / 0.1)
    else
        self.ViewModelNotOnGround = math.Approach(self.ViewModelNotOnGround, 1, FrameTime() / 0.1)
    end

    d = d * Lerp(self:GetSightAmount(), 1, 0.5) * Lerp(ts, 1, 1.5)
    mag = d * 2
    mag = mag * Lerp(ts, 1, 1.5)
    step = 10
    ang:RotateAroundAxis(ang:Forward(), math.sin(self.BobCT * step * 0.5) * ((math.sin(self.BobCT * 6.151) * 0.2) + 1) * 4.5 * d)
    ang:RotateAroundAxis(ang:Right(), math.sin(self.BobCT * step * 0.12) * ((math.sin(self.BobCT * 1.521) * 0.2) + 1) * 2.11 * d)
    pos = pos - (ang:Up() * math.sin(self.BobCT * step) * 0.07 * ((math.sin(self.BobCT * 3.515) * 0.2) + 1) * mag)
    pos = pos + (ang:Forward() * math.sin(self.BobCT * step * 0.3) * 0.11 * ((math.sin(self.BobCT * 2) * ts * 1.25) + 1) * ((math.sin(self.BobCT * 1.615) * 0.2) + 1) * mag)
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
    if self:GetCustomize() then return pos, ang end
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
    -- ang:RotateAroundAxis(ang:Right(), -v * d * 8 * math.sin(CurTime() * 0.15))
    pos = pos + ang:Up() * -v * d * 2 * math.sin(CurTime() * 0.15)

    return pos, ang
end

SWEP.ViewModelInertiaX = 0
SWEP.ViewModelInertiaY = 0

function SWEP:GetViewModelLeftRight(pos, ang)
    if self:GetCustomize() then return pos, ang end
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