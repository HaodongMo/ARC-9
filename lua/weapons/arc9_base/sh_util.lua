function SWEP:SanityCheck()
    if !IsValid(self) then return false end
    if !IsValid(self:GetOwner()) then return false end
    if !IsValid(self:GetVM()) then return false end
end

function SWEP:DoPlayerAnimationEvent(event)
    -- if CLIENT and self:ShouldTPIK() then return end
    if event then self:GetOwner():DoAnimationEvent(event) end
end

function SWEP:GetWM()
    if self.WModel then
        return self.WModel[1]
    else
        return NULL
    end
end

function SWEP:GetVM()
    if !IsValid(self:GetOwner()) then return nil end
    if !self:GetOwner():IsPlayer() then return nil end
    return self:GetOwner():GetViewModel()
end

function SWEP:Curve(x)
    return 0.5 * math.cos((x + 1) * math.pi) + 0.5
end

function SWEP:IsAnimLocked()
    return self:GetAnimLockTime() > CurTime()
end

function SWEP:RandomChoice(choice)
    if istable(choice) then
        choice = table.Random(choice)
    end

    return choice
end

function SWEP:PatternWithRunOff(pattern, runoff, num)
    if num < #pattern then
        return pattern[num]
    else
        num = num - #pattern
        num = num % #runoff

        return runoff[num + 1]
    end
end

-- Written by and used with permission from AWholeCream
-- start_p: Shoulder
-- end_p: Hand
-- length0: Shoulder to elbow
-- length1: Elbow to hand
-- rotation: rotates??? prevents chicken winging
function SWEP:Solve2PartIK(start_p, end_p, length0, length1, rotation)
    -- local circle = math.sqrt((end_p.x-start_p.x) ^ 2 + (end_p.y-start_p.y) ^ 2 )
    -- local length2 = math.sqrt(circle ^ 2 + (end_p.z-start_p.z) ^ 2 )
    local length2 = (start_p - end_p):Length()
    local cosAngle0 = math.Clamp(((length2 * length2) + (length0 * length0) - (length1 * length1)) / (2 * length2 * length0), -1, 1)
    local angle0 = -math.deg(math.acos(cosAngle0))
    local cosAngle1 = math.Clamp(((length1 * length1) + (length0 * length0) - (length2 * length2)) / (2 * length1 * length0), -1, 1)
    local angle1 = -math.deg(math.acos(cosAngle1))
    local diff = end_p - start_p
    local angle2 = math.deg(math.atan2(-math.sqrt(diff.x ^ 2 + diff.y ^ 2), diff.z)) - 90
    local angle3 = -math.deg(math.atan2(diff.x, diff.y)) - 90
    local axis = diff * 1
    axis:Normalize()
    local Joint0 = Angle(angle0 + angle2, angle3, 0)
    Joint0:RotateAroundAxis(axis, rotation)
    Joint0 = (Joint0:Forward() * length0)
    local Joint1 = Angle(angle0 + angle2 + 180 + angle1, angle3, 0)
    Joint1:RotateAroundAxis(axis, rotation)
    Joint1 = (Joint1:Forward() * length1)
    local Joint0_F = start_p + Joint0
    local Joint1_F = Joint0_F + Joint1

    return Joint0_F, Joint1_F
end
-- returns two vectors
-- upper arm and forearm


-- https://github.com/Fraktality/Spring/blob/master/Spring.lua
local spring = {}
_G.spring = spring

do
    local meta = {}
    spring.meta = {__index = meta}

    local pi = math.pi
	local exp = math.exp
	local sin = math.sin
	local cos = math.cos
	local sqrt = math.sqrt
	local EPS = 1e-4

	function meta:SetGoal(newGoal)
		self.g = newGoal
	end

	function meta:GetPosition()
		return self.p
	end

	function meta:GetVelocity()
		return self.v
	end

    function meta:Update(dt)
		local d = self.d
		local f = self.f*2*pi
		local g = self.g
		local p0 = self.p
		local v0 = self.v

		local offset = p0 - g
		local decay = exp(-d*f*dt)

		local p1, v1

		if d == 1 then -- Critically damped
			p1 = (offset*(1 + f*dt) + v0*dt)*decay + g
			v1 = (v0*(1 - f*dt) - offset*(f*f*dt))*decay

		elseif d < 1 then -- Underdamped
			local c = sqrt(1 - d*d)

			local i = cos(f*c*dt)
			local j = sin(f*c*dt)

			-- Damping ratios approaching 1 can cause division by small numbers.
			-- To fix that, group terms around z=j/c and find an approximation for z.
			-- Start with the definition of z:
			--    z = sin(dt*f*c)/c
			-- Substitute a=dt*f:
			--    z = sin(a*c)/c
			-- Take the Maclaurin expansion of z with respect to c:
			--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
			--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
			-- Rewrite in Horner form:
			--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

			local z
			if c > EPS then
				z = j/c
			else
				local a = dt*f
				z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
			end

			-- Frequencies approaching 0 present a similar problem.
			-- We want an approximation for y as f approaches 0, where:
			--    y = sin(dt*f*c)/(f*c)
			-- Substitute b=dt*c:
			--    y = sin(b*c)/b
			-- Now reapply the process from z.

			local y
			if f*c > EPS then
				y = j/(f*c)
			else
				local b = f*c
				y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6
			end

			p1 = (offset*(i + d*z) + v0*y)*decay + g
			v1 = (v0*(i - z*d) - offset*(z*f))*decay

		else -- Overdamped
			local c = sqrt(d*d - 1)

			local r1 = -f*(d - c)
			local r2 = -f*(d + c)

			local co2 = (v0 - offset*r1)/(2*f*c)
			local co1 = offset - co2

			local e1 = co1*exp(r1*dt)
			local e2 = co2*exp(r2*dt)

			p1 = e1 + e2 + g
			v1 = e1*r1 + e2*r2
		end

		self.p = p1
		self.v = v1

		return p1
	end
end

--[[
    d - dampening
    f - frequency
    g - goal
    p - position
    v - velocity

	goal should always be vector/angle 0
	frequency is basically like the speed of it

	position and velocity are what changes
	use position as the end recoil point
	and velocity as the applying point of recoil

	use position and velocity as prediction fall-back points
]]

function spring:new(position, frequency, dampening)
    assert(type(dampening) == "number")
    assert(type(frequency) == "number")
    assert(dampening*frequency >= 0, "Spring does not converge")

    return setmetatable({
        d = dampening,
        f = frequency,
        g = position,
        p = position,
        v = position*0, -- Match the original vector type
    }, self.meta)
end