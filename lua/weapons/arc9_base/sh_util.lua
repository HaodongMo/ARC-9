function SWEP:SanityCheck()
    if !IsValid(self) then return false end
    if !IsValid(self:GetOwner()) then return false end
    if !IsValid(self:GetVM()) then return false end
end

function SWEP:DoPlayerAnimationEvent(event)
    -- if CLIENT and self:ShouldTPIK() then return end
    if event and IsValid(self:GetOwner()) then self:GetOwner():AnimRestartGesture(1, event, true) end
    if SERVER then self:CallOnClient("DoPlayerAnimationEvent", event) end
end

local ENTITY = FindMetaTable("Entity")
local entityEmitSound = ENTITY.EmitSound

function SWEP:PlayTranslatedSound(soundtab)
    soundtab = self:RunHook("HookP_TranslateSound", soundtab) or soundtab

    if soundtab and soundtab.sound then
        local pitch = soundtab.pitch

        if istable(pitch) then
            pitch = math.random(pitch[1], pitch[2])
        end

        entityEmitSound(self,
            soundtab.sound,
            soundtab.level,
            pitch,
            soundtab.volume,
            soundtab.channel,
            soundtab.flags,
            soundtab.dsp
        )
    end
end

if SERVER then
    function SWEP:PredictionFilter()
        return false
    end
else
    local isSingleplayer = game.SinglePlayer()
    
    function SWEP:PredictionFilter()
        return isSingleplayer
    end
end

function SWEP:GetWM()
    if self.WModel then
        return self.WModel[1]
    else
        return NULL
    end
end

function SWEP:GetVM()
    local owner = self:GetOwner()
    if !IsValid(owner) then return nil end
    if !owner:IsPlayer() then return nil end
    return owner:GetViewModel()
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
function SWEP:Solve2PartIK(start_p, end_p, length0, length1, sign, angs)
    local length2 = (start_p - end_p):Length()

    if length0 + length1 < length2 then
        local add = length2 - length1 - length0
        --length0 = length0 + add * length0 / (length2 - add)
        --length1 = length1 + add * length1 / (length2 - add)
    end

    //local prev_ang0 = Quaternion():SetMatrix(mat0)
    //local prev_ang1 = Quaternion():SetMatrix(mat1)

    local cosAngle0 = math.Clamp(((length2 * length2) + (length0 * length0) - (length1 * length1)) / (2 * length2 * length0), -1, 1)
    local angle0 = -math.deg(math.acos(cosAngle0))
    local cosAngle1 = math.Clamp(((length1 * length1) + (length0 * length0) - (length2 * length2)) / (2 * length1 * length0), -1, 1)
    local angle1 = -math.deg(math.acos(cosAngle1))
    local diff = end_p - start_p-- + LocalPlayer():EyeAngles():Forward() * 555
    diff:Normalize()
    local angle2 = math.deg(math.atan2(-math.sqrt(diff.x * diff.x + diff.y * diff.y), diff.z)) - 90
    local angle3 = -math.deg(math.atan2(diff.x, diff.y)) - 90
    angle3 = math.NormalizeAngle(angle3)

    local diff2 = -vector_up:Angle()//-torsomat:GetAngles():Forward()
    --debugoverlay.Line(start_p,start_p + diff2 * 10,0.1,color_white,true)
    --debugoverlay.Line(start_p,start_p + diff * 10,0.1,color_red,true)
    local axis = diff * 1
    axis:Normalize()
    
    local torsoang = vector_up:Angle()//torsomat:GetAngles()

    local Joint0 = Angle(angle0 + angle2, angle3, 0)

    local asdot = -vector_up:Dot(torsoang:Up())
    local diffa = math.deg(math.acos(asdot)) + (sign < 0 and -0 or 0)
    local diffa2 = 90 + (sign > 0 and -30 or 30)--math.deg(math.acos(asdot))
    
    local tors = torsoang:Up()
    local torsoright = -math.deg(math.atan2(tors.x, tors.y)) - 120 - 60 * sign
    torsoright = angs.y + 120 * sign
    
    Joint0:RotateAroundAxis(Joint0:Forward(), diffa2)
    Joint0:RotateAroundAxis(axis, angle3 - torsoright)
    //prev_ang0:SetAngle(Joint0)
    local ang1 = -(-Joint0)

    --debugoverlay.Line(start_p,start_p + -diff:Angle():Up() * 10,0.1,color_black,true)
    --debugoverlay.Line(start_p,start_p + torsoang:Up() * sign * 10,0.1,color_red,true)
    
    --render.DrawLine(start_p,start_p + -diff:Angle():Up() * 10,color_black, true)
    --render.DrawLine(start_p,start_p + torsoang:Up() * sign * 10,color_red, true)

    local Joint0 = Joint0:Forward() * length0
    //local diffa2 = ang[3] + 90

    local Joint1 = Angle(angle0 + angle2 + 180 + angle1, angle3, 0)
    Joint1:RotateAroundAxis(Joint1:Forward(), diffa2)//+ ang[3] / 4 + 60)
    Joint1:RotateAroundAxis(axis, angle3 - torsoright)
    //prev_ang1:SetAngle(Joint1)
    --prev_ang1:SetDirection(Joint1:Forward(), torsomat:GetAngles():Up() * 1)
    local ang2 = -(-Joint1)
    local Joint1 = Joint1:Forward() * length1

    local Joint0_F = start_p + Joint0
    local Joint1_F = Joint0_F + Joint1

    return Joint0_F, Joint1_F, ang1, ang2
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

function SWEP:RotateAroundPoint2(pos, ang, point, offset, offset_ang)

    local mat = Matrix()
    mat:SetTranslation(pos)
    mat:SetAngles(ang)
    mat:Translate(point)

    local rot_mat = Matrix()
    rot_mat:SetAngles(offset_ang)
    rot_mat:Invert()

    mat:Mul(rot_mat)

    mat:Translate(-point)

    mat:Translate(offset)

    return mat:GetTranslation(), mat:GetAngles()
end

function SWEP:IsUsingRTScope()
    return self:GetSightAmount() > 0.5 and self:GetSight() and self:GetSight().atttbl and self:GetSight().atttbl.RTScope and !self:GetSight().Disassociate
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

    function SWEP:CallNonTPIKAnim(source)
        self:DoPlayerAnimationEvent(self:GetProcessedValue(!self:ShouldTPIK() and "NonTPIK" .. source or source, true))
    end
end