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
    sightedmult = Lerp(self:Curve(self.CustomizeDelta), sightedmult, 0)
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

    -- v:Rotate(offset_ang)

    v = v - (point.x * ang:Right())
    v = v - (point.y * ang:Forward())
    v = v - (point.z * ang:Up())

    pos = v + pos

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

local v = 0

local offset = Vector()
local affset = Angle()

local airtime = 0

local stammer = 0
local stammer_moving = false

local function goodassbob(self, pos, ang)
    if self:GetCustomize() then return pos, ang end
    local cv = self:GetOwner():GetVelocity():Length()
    v = math.Approach(v, cv, FrameTime()*400/0.4)
    v = math.Clamp(v, 0, 400)
    local tv = v / 400
    tv = tv * 1.1
    local mulp = Lerp(self:GetSightDelta(), 1, 0.15)
    local mulk = Lerp(self:GetSightDelta(), 1, 0.3)
    local tk = tv * mulk
    tv = tv * mulp
    self.BobScale = 0
    local p = math.pi
    local spe = self:GetOwner():KeyDown(IN_SPEED)

    local grounded = (self:GetOwner():IsOnGround() or self:GetOwner():GetMoveType() == MOVETYPE_NOCLIP)
    airtime = math.Approach(airtime, (grounded and 0 or 1), FrameTime()*5*(grounded and 10 or 1))

    offset:Set(vector_origin)
    affset:Set(angle_zero)

    local ct = ( (CurTime() * 1.1) % (0.975 * ((1/1.1)+0.1)) )

    offset.x = offset.x + math.sin( ct * p * 2 ) * 0.2 * ( spe and -2 or 1 )
    offset.y = offset.y + math.pow(math.sin( ct * p * 2 ), 2) * -0.5 * ( spe and -2 or 1 )
    offset.z = offset.z + math.abs(math.sin( ct * p * -1 )) * -0.15

    offset.z = offset.z + math.pow(math.abs( math.sin(ct * p * 2) ), 6) * -0.395 * ( spe and -4 or 0 )

    offset.z = offset.z + ( (-0.395/2)*3 * tv )

    offset.z = offset.z + ( math.pow(math.sin((ct+0)*p*2.5), 2) * -0.3 )
    offset.z = offset.z + ( math.pow(math.sin((ct+0.3)*p*2.5), 2) * -0.3 )

    affset.x = affset.x - ( math.pow( math.sin( ct * p ) * 2.2, 2 ) - ( (2.2/2) * tv ) ) * ( spe and 2 or 1 )
    affset.y = affset.y + math.sin( ct * p * -(3) ) * 0.5 * 1.5
    affset.z = affset.z + ( ( ((ct/2) % 1) < 0.5 and -1 or 2 ) * math.sin( ct * p * 2 ) * 2 * 1.5 ) * ( spe and 2 or 1 )
    affset.z = affset.z + ( ( ((ct/2) % 1) > 0.5 and -1 or 2 ) * math.sin( ct * p * 2 ) * 2 * 1.5 ) * ( spe and 2 or 1 )

    affset.x = affset.x + ( (-2) * tv )

    pos:Add( ang:Right()     *   offset.x * tv )
    pos:Add( ang:Forward()   *   offset.y * tv )
    pos:Add( ang:Up()        *   offset.z * tv )

    local stammertime_pos = Vector()
    local stammertime_ang = Angle()

    local pe = self:GetOwner()
    local pep = pe:KeyDown(IN_FORWARD) or pe:KeyDown(IN_BACK) or pe:KeyDown(IN_MOVELEFT) or pe:KeyDown(IN_MOVERIGHT)
    if tk > 0.1 then
        stammer = 1
        stammer_moving = true
    else
        stammer_moving = false
        stammer = math.Approach(stammer, 0, FrameTime()*3)
    end
    local elistam = (!pep and stammer or 0)*Lerp(self:GetSightDelta(), 1, 0.3)

    stammertime_pos.x = stammertime_pos.x + math.sin( ct * p * 5*1.334 ) * -0.05
    stammertime_pos.y = stammertime_pos.y + elistam*-0.5
    stammertime_pos.z = stammertime_pos.z + elistam*-0.25
    stammertime_ang.y = stammertime_ang.y + math.sin( ct * p * 2*1.334 ) * 0.8
    stammertime_ang.z = stammertime_ang.z + math.sin( ct * p * 5*1.334 ) * 0.5

    pos:Add( ang:Right()     *   stammertime_pos.x * elistam )
    pos:Add( ang:Forward()   *   stammertime_pos.y * elistam )
    pos:Add( ang:Up()        *   stammertime_pos.z * elistam )

    ang:RotateAroundAxis( ang:Forward(),        affset.x * tv )
    ang:RotateAroundAxis( ang:Right(),          affset.y * tv )
    ang:RotateAroundAxis( ang:Up(),             affset.z * tv )

    ang:RotateAroundAxis( ang:Forward(),        stammertime_ang.x * elistam )
    ang:RotateAroundAxis( ang:Right(),          stammertime_ang.y * elistam )
    ang:RotateAroundAxis( ang:Up(),             stammertime_ang.z * elistam )
    ang:RotateAroundAxis( ang:Up(),             (pe:KeyDown(IN_MOVELEFT) and 2 or pe:KeyDown(IN_MOVERIGHT) and -2 or 0) * tv )

    ang:RotateAroundAxis( ang:Forward(),          math.sin( ct * p * 1 ) * airtime*-5 * mulp )
    ang:RotateAroundAxis( ang:Right(),          ( math.sin( ct * p * 1 ) * airtime*3 * mulp ) + ( (3/2) * airtime * mulp ) ) 
    ang:RotateAroundAxis( ang:Up(),          math.sin( ct * p * 2 ) * airtime*2 * mulp )

    return pos, ang
end

local function goofyassbob(self, pos, ang)
    local step = 10
    local mag = 1
    local ts = 0 -- self:GetTraversalSprintAmount()
    -- ts = 1
    if self:GetCustomize() then return pos, ang end
    local v = self:GetOwner():GetVelocity():Length()
    v = math.Clamp(v, 0, 350)
    self.ViewModelBobVelocity = math.Approach(self.ViewModelBobVelocity, v, FrameTime() * 10000)
    local d = math.Clamp(self.ViewModelBobVelocity / 350, 0, 1)
    if self:GetOwner():OnGround() and self:GetOwner():GetMoveType() != MOVETYPE_NOCLIP then
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
    pos = pos - (ang:Up() * math.sin(self.BobCT * step) * 0.1 * ((math.sin(self.BobCT * 3.515) * 0.2) + 1) * mag)
    pos = pos + (ang:Forward() * math.sin(self.BobCT * step * 0.3) * 0.11 * ((math.sin(self.BobCT * 2) * ts * 1.25) + 1) * ((math.sin(self.BobCT * 1.615) * 0.2) + 1) * mag)
    pos = pos + (ang:Right() * (math.sin(self.BobCT * step * 0.15) + (math.cos(self.BobCT * step * 0.3332))) * 0.16 * mag)
    
    local steprate = Lerp(d, 1, 2.5)
    steprate = Lerp(self.ViewModelNotOnGround, steprate, 0.25)

    if IsFirstTimePredicted() or game.SinglePlayer() then
        self.BobCT = self.BobCT + (FrameTime() * steprate)
    end

    return pos, ang
end

function SWEP:GetViewModelBob(pos, ang)
    if GetConVar("arc9_vm_bobstyle"):GetBool() then
        return goofyassbob(self, pos, ang)
    else
        return goodassbob(self, pos, ang)
    end
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