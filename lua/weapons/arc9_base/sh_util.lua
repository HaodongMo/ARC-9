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

function SWEP:RotateAroundPoint(pos, ang, point, offset, offset_ang)
    local v = Vector(0, 0, 0)
    v = v + (point.x * ang:Right())
    v = v + (point.y * ang:Forward())
    v = v + (point.z * ang:Up())

    local newang = Angle()
    newang:Set(ang)

    newang:RotateAroundAxis(ang:Right(), offset_ang.p)
    newang:RotateAroundAxis(ang:Forward(), offset_ang.r)
    newang:RotateAroundAxis(ang:Up(), offset_ang.y)

    v = v + newang:Right() * offset.x
    v = v + newang:Forward() * offset.y
    v = v + newang:Up() * offset.z

    -- v:Rotate(offset_ang)

    v = v - (point.x * newang:Right())
    v = v - (point.y * newang:Forward())
    v = v - (point.z * newang:Up())

    pos = v + pos

    return pos, newang
end



if CLIENT then

    function SWEP:ScaleFOVByWidthRatio( fovDegrees, ratio )
        local halfAngleRadians = fovDegrees * ( 0.5 * math.pi / 180 )
        local t = math.tan( halfAngleRadians )
        t = t * ratio
        local retDegrees = ( 180 / math.pi ) * math.atan( t )
        return retDegrees * 2
    end


    function SWEP:WidescreenFix(target)
        return self:ScaleFOVByWidthRatio(target, ((ScrW and ScrW() or 4) / (ScrH and ScrH() or 3)) / (4 / 3))
    end

end