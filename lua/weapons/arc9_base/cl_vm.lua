SWEP.CustomizeDelta = 0

SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)

local LerpVector = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local LerpAngle = function(a, a1, a2)
    local d = a2 - a1

    return a1 + (a * d)
end

local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

function SWEP:GetViewModelPosition(pos, ang)
    local oldang = Angle(0, 0, 0)

    oldang:Set(ang)

    if GetConVar("ARC9_benchgun"):GetBool() then
        return Vector(0, 0, 0), Angle(0, 0, 0)
    end

    -- pos = Vector(0, 0, 0)
    -- ang = Angle(0, 0, 0)

    local cor_val = 0.75

    local offsetpos = Vector(0, 0, 0)
    local offsetang = Angle(0, 0, 0)

    local extra_offsetpos = Vector(0, 0, 0)
    local extra_offsetang = Angle(0, 0, 0)

    -- print(extra_offsetang)

    offsetpos:Set(self:GetProcessedValue("ActivePos"))
    offsetang:Set(self:GetProcessedValue("ActiveAng"))

    local sightdelta = math.ease.InOutCirc(self:GetSightDelta())

    -- cor_val = Lerp(sightdelta, cor_val, 1)

    if sightdelta > 0 then
        local sightpos, sightang = self:GetSightPositions()

        -- local sightpos = self.SightPos
        -- local sightang = self.SightAng

        offsetpos = LerpVector(sightdelta, offsetpos, sightpos)
        offsetang = LerpAngle(sightdelta, offsetang, sightang)
    end

    local eepos, eeang = self:GetExtraSightPositions()
    -- local eepos, eeang = Vector(0, 0, 0), Angle(0, 0, 0)

    local im = self:GetProcessedValue("SightMidPoint")

    local midpoint = sightdelta * math.cos(sightdelta * (math.pi / 2))
    local joffset = (im and im.Pos or Vector(0, 0, 0)) * midpoint
    local jaffset = (im and im.Ang or Angle(0, 0, 0)) * midpoint

    extra_offsetpos = LerpVector(sightdelta, extra_offsetpos, -eepos + joffset)
    extra_offsetang = LerpAngle(sightdelta, extra_offsetang, -eeang + jaffset)

    extra_offsetang.y = extra_offsetang.y - (self:GetFreeSwayAngles().p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (self:GetFreeSwayAngles().y * cor_val)

    extra_offsetang.y = extra_offsetang.y - (self:GetFreeAimOffset().p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (self:GetFreeAimOffset().y * cor_val)

    if game.SinglePlayer() or IsFirstTimePredicted() then
        if self:GetCustomize() then
            self.CustomizeDelta = math.Approach(self.CustomizeDelta, 1, FrameTime() * 1 / 0.15)
        else
            self.CustomizeDelta = math.Approach(self.CustomizeDelta, 0, FrameTime() * 1 / 0.15)
        end
    end

    local curvedcustomizedelta = self:Curve(self.CustomizeDelta)

    -- local sprintdelta = self:Curve(self:GetSprintDelta())
    local sprintdelta = math.ease.InOutQuad(self:GetSprintDelta()) - curvedcustomizedelta

    if sprintdelta > 0 then
        offsetpos = LerpVector(sprintdelta, offsetpos, self:GetProcessedValue("SprintPos") or self:GetProcessedValue("HolsterPos"))
        offsetang = LerpAngle(sprintdelta, offsetang, self:GetProcessedValue("SprintAng") or self:GetProcessedValue("HolsterAng"))

        extra_offsetang = LerpAngle(sprintdelta, extra_offsetang, Angle(0, 0, 0))
    end

    local sim = self:GetProcessedValue("SprintMidPoint")

    local spr_midpoint = sprintdelta * math.cos(sprintdelta * (math.pi / 2))
    local spr_joffset = (sim and sim.Pos or Vector(0, 0, 0)) * spr_midpoint
    local spr_jaffset = (sim and sim.Ang or Angle(0, 0, 0)) * spr_midpoint

    extra_offsetpos = extra_offsetpos + spr_joffset
    extra_offsetang = extra_offsetang + spr_jaffset

    self.BobScale = 0
    self.SwayScale = Lerp(sightdelta, 1, 0.1)

    if curvedcustomizedelta > 0 then
        local cpos = self:GetProcessedValue("CustomizePos")
        local cang = self:GetProcessedValue("CustomizeAng")

        extra_offsetpos = LerpVector(curvedcustomizedelta, extra_offsetpos, Vector(0, 0, 0))
        extra_offsetang = LerpAngle(curvedcustomizedelta, extra_offsetang, Angle(0, 0, 0))

        if self.BottomBarAddress then
            local slot = self:LocateSlotFromAddress(self.BottomBarAddress)

            if slot then
                local apos = self:GetAttPos(slot, false, true)

                cpos = cpos + cang:Up() * (apos.x - cpos.x)
                -- cpos = cpos + cang:Right() * (apos.y - cpos.y)
                cpos = cpos + cang:Forward() * (apos.z + cpos.z)
            end
        end

        cpos = cpos + cang:Up() * self.CustomizePanX
        cpos = cpos + cang:Forward() * self.CustomizePanY
        cpos = cpos + Vector(0, 1, 0) * (self.CustomizeZoom+24)

        offsetpos = LerpVector(curvedcustomizedelta, offsetpos, cpos)
        offsetang = LerpAngle(curvedcustomizedelta, offsetang, cang)
    end

    if game.SinglePlayer() or IsFirstTimePredicted() then
        self.ViewModelPos = LerpVector(0.8, offsetpos, self.ViewModelPos)
        self.ViewModelAng = LerpAngle(0.8, offsetang, self.ViewModelAng)
    end

    offsetpos = self.ViewModelPos
    offsetang = self.ViewModelAng
    self.ViewModelAng:Normalize()

    pos = pos + (ang:Right() * offsetpos.x)
    pos = pos + (ang:Forward() * offsetpos.y)
    pos = pos + (ang:Up() * offsetpos.z)

    ang:RotateAroundAxis(oldang:Up(), offsetang.p)
    ang:RotateAroundAxis(oldang:Right(), offsetang.y)
    ang:RotateAroundAxis(oldang:Forward(), offsetang.r)

    pos = pos + (oldang:Right() * extra_offsetpos[1])
    pos = pos + (oldang:Forward() * extra_offsetpos[2])
    pos = pos + (oldang:Up() * extra_offsetpos[3])

    ang:RotateAroundAxis(oldang:Up(), extra_offsetang[1])
    ang:RotateAroundAxis(oldang:Right(), extra_offsetang[2])
    ang:RotateAroundAxis(oldang:Forward(), extra_offsetang[3])

    self.CustomizePitch = math.NormalizeAngle(self.CustomizePitch)
    -- this needs to be better
    -- its more like proof of concept
    -- probably this can be better if it based on selected slot offset not random numbers
    pos = pos + (ang:Right() *math.sin(math.rad(self.CustomizePitch)) * 18) * curvedcustomizedelta ^ 2
    pos = pos + (ang:Forward() *math.cos(math.rad(self.CustomizePitch)) * -15) * curvedcustomizedelta ^ 2

    pos = pos + (ang:Right() * -18) * curvedcustomizedelta ^ 2
    pos = pos + (ang:Forward() * 15) * curvedcustomizedelta ^ 2

    ang:RotateAroundAxis(EyeAngles():Up(), self.CustomizePitch * curvedcustomizedelta ^ 2)

    -- ang:RotateAroundAxis(EyeAngles():Forward(), self.CustomizeYaw * curvedcustomizedelta ^ 2)

    pos, ang = self:GetViewModelBob(pos, ang)
    pos, ang = self:GetMidAirBob(pos, ang)
    -- pos, ang = self:GetViewModelLeftRight(pos, ang)
    pos, ang = self:GetViewModelInertia(pos, ang)
    pos, ang = self:GetViewModelSway(pos, ang)
    pos, ang = self:GetViewModelSmooth(pos, ang)

    self.LastViewModelPos = pos
    self.LastViewModelAng = ang

    return pos, ang
end

function SWEP:GetViewModelFOV()
    local target = self:GetOwner():GetFOV() + GetConVar("arc9_fov"):GetInt()

    if self:GetSightAmount() > 0 then
        return Lerp(self:GetSightAmount(), target, 75 + GetConVar("arc9_fov"):GetInt())
    end

    return target
    -- return 60 * self:GetSmoothedFOVMag()
    -- return 150
    -- return self:GetOwner():GetFOV() * (self:GetProcessedValue("DesiredViewModelFOV") / 90) * math.pow(self:GetSmoothedFOVMag(), 1/4)
end