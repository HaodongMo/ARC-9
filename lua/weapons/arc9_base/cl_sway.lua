SWEP.ViewModelVelocityPos = Vector()
SWEP.ViewModelVelocityAng = Angle()
SWEP.ViewModelPos = Vector()
SWEP.ViewModelAng = Angle()
SWEP.SwayCT = 0


local lasteyeang = Angle()
local smootheyeang = Angle()
local posoffset = Vector()
local smoothswayroll = 0
local smoothswaypitch = 0

function SWEP:GetViewModelSway(pos, ang)
    local sightmult = Lerp(self:GetSightAmount(), 1, 0.5)
    smootheyeang = LerpAngle(math.Clamp(FrameTime() * 8, 0, 0.04), smootheyeang, EyeAngles() - lasteyeang)
    lasteyeang = EyeAngles()

    smoothswayroll = Lerp(math.Clamp(FrameTime() * 8, 0, 0.8), smoothswayroll, smootheyeang.y * -3.5)
    smoothswaypitch = Lerp(math.Clamp(FrameTime() * 8, 0, 0.8), smoothswaypitch, smootheyeang.p * 0.5)

    if self.SprintVerticalOffset then
        local sprintoffset = ang.p * 0.04 * Lerp(self:GetSprintAmount(), 0, 1) 
        pos:Add(ang:Up() * sprintoffset)
        pos:Add(ang:Forward() * sprintoffset)
    end

    posoffset.x = math.Clamp(smoothswayroll * 0.1,  -1.5, 1.5)
    posoffset.y = math.Clamp(smoothswaypitch * 0.5, -1.5, 1.5)
    posoffset.z = math.Clamp(smoothswayroll * 0.03, -1.5, 1.5)

    smootheyeang.p = math.Clamp(smootheyeang.p * 0.95, -7, 7)
    smootheyeang.y = math.Clamp(smootheyeang.y * 0.9, -7, 7)
    smootheyeang.r = math.Clamp(smoothswayroll + smoothswaypitch * -2, -15, 15)

    ang:Add(smootheyeang * sightmult)
    pos:Add(posoffset * sightmult)

    return pos, ang
end

SWEP.ViewModelLastEyeAng = Angle()
SWEP.ViewModelSwayInertia = Angle()

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

local function FesiugBob(self, pos, ang)
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
    local spe = self:GetIsSprinting()

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

    ang:RotateAroundAxis( ang:Forward(),          math.sin( ct * p * 1 ) * airtime*-5 * mulp * 2)
    ang:RotateAroundAxis( ang:Right(),          ( math.sin( ct * p * 1 ) * airtime*3 * mulp ) + ( (3/2) * airtime * mulp ) ) 
    ang:RotateAroundAxis( ang:Up(),          math.sin( ct * p * 2 ) * airtime*2 * mulp )

    return pos, ang
end

local function ArcticBob(self, pos, ang)
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

local smoothsidemove = 0
local smoothjumpmove = 0
local notonground = 0

local function DarsuBob(self, pos, ang)
    self.BobScale = 0 -- hl2 bob removal
    if self:GetCustomize() then return pos, ang end

    local owner = self:GetOwner()
    local velocityangle = owner:GetVelocity()
    local sightamount = self:GetSightAmount()

    local velocity = math.Clamp(velocityangle:Length(), 0, 350)

    self.ViewModelBobVelocity = math.Approach(self.ViewModelBobVelocity, velocity, FrameTime() * 10000)
    
    local d = math.Clamp(self.ViewModelBobVelocity / 350, 0, 1)

    notonground = math.Approach(notonground, (owner:OnGround() and owner:GetMoveType() != MOVETYPE_NOCLIP) and 0 or 1, FrameTime() / 0.1)
    local steprate = Lerp(d, 1, 2.5)
    steprate = Lerp(notonground, steprate, 0.5)


    local jumpmove = math.Clamp(math.ease.InExpo(math.Clamp(velocityangle.z, -350, 0)/-350)*25 + math.ease.InExpo(math.Clamp(velocityangle.z, 0, 350)/350)*-60, -5, 3.5) * (1.5-sightamount) -- crazy math for jump movement
    smoothjumpmove = Lerp(math.Clamp(FrameTime()*8, 0, 1), smoothjumpmove, jumpmove)


    if IsFirstTimePredicted() or game.SinglePlayer() then self.BobCT = self.BobCT + (FrameTime() * steprate) end
    
    d = d * Lerp(sightamount, 1, 0.65) -- If we in sights make less moves

    local d2 = math.ease.InQuart(d)
    local d3 = math.ease.InQuad(d)
    local speedmult = 1.3

    local sidemove = ((owner:KeyDown(IN_MOVERIGHT) and 1 or 0) - (owner:KeyDown(IN_MOVELEFT) and 1 or 0)) * 3 * (1.3-sightamount)
    smoothsidemove = Lerp(math.Clamp(FrameTime()*8, 0, 1), smoothsidemove, sidemove)

    local crouchmult = (owner:Crouching() and not owner:IsSprinting()) and 2.5*(1.3-sightamount)  or 1
    
    if owner.GetSliding then if owner:GetSliding() then speedmult = 0.01 d3 = 0 smoothsidemove = -10 end end

    pos:Sub(ang:Right() *          math.sin(speedmult * self.BobCT * 3.3)  * d2 * 1)                                   -- X 
    pos:Sub(ang:Up() *             math.cos(speedmult * self.BobCT * 6)    * d * 0.3 * crouchmult)                     -- Y
    pos:Sub(ang:Forward() *        math.sin(speedmult * self.BobCT * 4.5)  * d2 * 0.75 * crouchmult)                   -- Z

    ang:RotateAroundAxis(ang:Right(),   math.cos(speedmult * self.BobCT * 6)    * d3 * 2 + smoothjumpmove)                  -- P
    ang:RotateAroundAxis(ang:Up(),      math.cos(speedmult * self.BobCT * 3.3)  * d3 * 2)                                   -- Y
    ang:RotateAroundAxis(ang:Forward(), math.sin(speedmult * self.BobCT * 6)    * d3 * 3.5 * crouchmult + smoothsidemove)   -- R

    return pos, ang
end

function SWEP:GetViewModelBob(pos, ang)
    if GetConVar("arc9_vm_bobstyle"):GetBool() then
        return FesiugBob(self, pos, ang)
        -- return ArcticBob(self, pos, ang) -- arctic got cancelled
    else
        return DarsuBob(self, pos, ang)
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
    v, _ = WorldToLocal(v, Angle(), Vector(), self:GetOwner():EyeAngles())
    local vx = math.Clamp(v.x / 200, -1, 1)
    local vy = math.Clamp(v.y / 200, -1, 1)
    self.ViewModelInertiaX = math.Approach(self.ViewModelInertiaX, vx, math.abs(vx) * FrameTime() / 0.1)
    self.ViewModelInertiaY = math.Approach(self.ViewModelInertiaY, vy, math.abs(vy) * FrameTime() / 0.1)
    pos = pos + (ang:Right() * -self.ViewModelInertiaX * 0.65 * d)
    pos = pos + (ang:Forward() * self.ViewModelInertiaY * 0.5 * d)

    return pos, ang
end