SWEP.CustomizeDelta = 0

SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)

local lht = 0
local sht = 0

local LerpVector = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local LerpAngle = function(a, a1, a2)
    local d = a2 - a1

    return a1 + (a * d)
end

-- local ApproachVector = function(a1, a2, d)
--     a1[1] = math.Approach(a1[1], a2[1], d)
--     a1[2] = math.Approach(a1[2], a2[2], d)
--     a1[3] = math.Approach(a1[3], a2[3], d)

--     return a1
-- end

local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local Damp = function(a, v1, v2)
    return Lerp(1 - math.pow(a, FrameTime()), v2, v1)
end

local DampVector = function(a, v1, v2)
    a = 1 - math.pow(a, FrameTime())

    return LerpVector(a, v2, v1)
end

local DampAngle = function(a, v1, v2)
    a = 1 - math.pow(a, FrameTime())

    return LerpAngle(a, v2, v1)
end

function SWEP:GetViewModelPosition(pos, ang)
    if GetConVar("ARC9_benchgun"):GetBool() then
        return ARC9_VECTORZERO, ARC9_ANGLEZERO
    end

    local oldpos = Vector(pos)
    local oldang = Angle(ang)


    -- pos = Vector(0, 0, 0)
    -- ang = Angle(0, 0, 0)

    local cor_val = 0.75

    local extra_offsetpos = Vector(0, 0, 0)
    local extra_offsetang = Angle(0, 0, 0)

    local oldforward, oldright, oldup = oldang:Forward(), oldang:Right(), oldang:Up()

    -- print(extra_offsetang)

    local offsetpos = Vector(self:GetProcessedValue("ActivePos"))
    local offsetang = Angle(self:GetProcessedValue("ActiveAng"))

    if !self:GetReloading() and !self:GetBipod() and self:GetOwner():Crouching() then
        local crouchpos = self:GetProcessedValue("CrouchPos")
        local crouchang = self:GetProcessedValue("CrouchAng")
        if crouchpos then
            offsetpos:Set(crouchpos)
        end
        if crouchang then
            offsetang:Set(crouchang)
        end
    end

    if self:GetBipod() then
        local bipodamount = self:GetBipodAmount()

        bipodamount = math.ease.InOutQuad(bipodamount)

        local sightpos, sightang = self:GetSightPositions()

        LerpVector(bipodamount, offsetpos, self:GetProcessedValue("BipodPos"))
        LerpAngle(bipodamount, offsetang, self:GetProcessedValue("BipodAng"))

        offsetpos:Add(sightpos * bipodamount)
        offsetang:Add(sightang * bipodamount)
    end

    local blindfiredelta = self:GetBlindFireAmount()
    local blindfirecornerdelta = self:GetBlindFireCornerAmount()

    local curvedblindfiredelta = self:Curve(blindfiredelta)
    local curvedblindfirecornerdelta = self:Curve(math.abs(blindfirecornerdelta))

    if blindfiredelta > 0 then
        offsetpos = LerpVector(curvedblindfiredelta, offsetpos, self:GetValue("BlindFirePos"))
        offsetang = LerpAngle(curvedblindfiredelta, offsetang, self:GetValue("BlindFireAng"))

        if blindfirecornerdelta > 0 then
            offsetpos = LerpVector(curvedblindfirecornerdelta, offsetpos, self:GetValue("BlindFireRightPos"))
            offsetang = LerpAngle(curvedblindfirecornerdelta, offsetang, self:GetValue("BlindFireRightAng"))
        elseif blindfirecornerdelta < 0 then
            offsetpos = LerpVector(curvedblindfirecornerdelta, offsetpos, self:GetValue("BlindFireLeftPos"))
            offsetang = LerpAngle(curvedblindfirecornerdelta, offsetang, self:GetValue("BlindFireLeftAng"))
        end
    end

    local sightdelta = self:GetSightDelta()

    -- cor_val = Lerp(sightdelta, cor_val, 1)

    self.SwayScale = 0

    if sightdelta > 0 then
        sightdelta = math.ease.InOutQuad(sightdelta)
        local sightpos, sightang = self:GetSightPositions()
        local sight = self:GetSight()
        local eepos, eeang = self:GetExtraSightPositions()

        if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) then
            eepos:Add(Vector(-1, 0, 1))
        end

        if sight.GeneratedSight then
            --[[
                NONSENSE:
                LerpVector(sightdelta, Vector(0, 0 ,0), sightpos) in this case expands into

                local ret = Vector(0, 0, 0)
                for i = 1, 3 do
                    ret[i] = Vector(0, 0, 0)[i] + (sightpos[i] - Vector(0, 0, 0)[i]) * sightdelta
                end

                which is literally the same as t_sightpos = sightpos * sightdelta
                ~BlacK 26/03/2022
            ]]--
            -- local t_sightpos = LerpVector(sightdelta, Vector(0, 0 ,0), sightpos)
            -- local t_sightang = LerpAngle(sightdelta, Angle(0, 0, 0), sightang)

            local t_sightpos = sightpos * sightdelta
            local t_sightang = sightang * sightdelta

            ang:RotateAroundAxis(oldang:Up(), t_sightang.p)
            ang:RotateAroundAxis(oldang:Right(), t_sightang.y)
            ang:RotateAroundAxis(oldang:Forward(), t_sightang.r)

            pos:Add(ang:Right() * t_sightpos.x)
            pos:Add(ang:Forward() * t_sightpos.y)
            pos:Add(ang:Up() * t_sightpos.z)

            offsetpos:Mul(1 - sightdelta) -- LerpVector(sightdelta, offsetpos, Vector(0, 0, 0))
            offsetang:Mul(1 - sightdelta) -- LerpAngle(sightdelta, offsetang, Angle(0, 0, 0))
        else
            offsetpos = LerpVector(sightdelta, offsetpos, sightpos)
            offsetang = LerpAngle(sightdelta, offsetang, sightang)
        end

        -- local eepos, eeang = Vector(0, 0, 0), Angle(0, 0, 0)

        local im = self:GetProcessedValue("SightMidPoint")

        local midpoint = sightdelta * math.cos(sightdelta * (math.pi / 2))
        local joffset = (im and im.Pos or Vector(0, 0, 0)) * midpoint
        local jaffset = (im and im.Ang or Angle(0, 0, 0)) * midpoint

        extra_offsetpos = LerpVector(sightdelta, extra_offsetpos, -eepos + joffset)
        extra_offsetang = LerpAngle(sightdelta, extra_offsetang, -eeang + jaffset)

        self.BobScale = 0
        self.SwayScale = Lerp(sightdelta, 1, 0.1)
    end

    local freeSwayAngles = self:GetFreeSwayAngles()
    extra_offsetang.y = extra_offsetang.y - (freeSwayAngles.p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (freeSwayAngles.y * cor_val)
    extra_offsetang:Normalize()

    local freeAimOffset = self:GetFreeAimOffset()
    extra_offsetang.y = extra_offsetang.y - (freeAimOffset.p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (freeAimOffset.y * cor_val)
    extra_offsetang:Normalize()

    if game.SinglePlayer() or IsFirstTimePredicted() then
        if self:GetCustomize() then
            if self.CustomizeDelta < 1 then
                self.CustomizeDelta = math.Approach(self.CustomizeDelta, 1, FrameTime() * 1 / 0.15)
            end
        else
            if self.CustomizeDelta > 0 then
                self.CustomizeDelta = math.Approach(self.CustomizeDelta, 0, FrameTime() * 1 / 0.15)
            end
        end
    end

    local curvedcustomizedelta = self:Curve(self.CustomizeDelta)

    -- local sprintdelta = self:Curve(self:GetSprintDelta())
    local sprintdelta = self:GetSprintDelta()

    if sprintdelta > 0 then
        local ts_sprintdelta = 0 // self:GetTraversalSprintAmount()
        sprintdelta = math.ease.InOutQuad(sprintdelta) - curvedcustomizedelta
        ts_sprintdelta = math.ease.InOutSine(ts_sprintdelta)

        sprintdelta = math.max(sprintdelta, ts_sprintdelta)

        local sprpos = self:GetProcessedValue("SprintPos") or self:GetProcessedValue("RestPos")
        local sprang = self:GetProcessedValue("SprintAng") or self:GetProcessedValue("RestAng")

        sprpos = LerpVector(ts_sprintdelta, sprpos, self:GetProcessedValue("TraversalSprintPos"))
        sprang = LerpAngle(ts_sprintdelta, sprang, self:GetProcessedValue("TraversalSprintAng"))

        offsetpos = LerpVector(sprintdelta, offsetpos, sprpos)
        offsetang = LerpAngle(sprintdelta, offsetang, sprang)

        extra_offsetang = extra_offsetang * sprintdelta -- LerpAngle(sprintdelta, extra_offsetang, Angle(0, 0, 0))

        local sim = self:GetProcessedValue("SprintMidPoint")

        local spr_midpoint = sprintdelta * math.cos(sprintdelta * (math.pi / 2))
        local spr_joffset = (sim and sim.Pos or Vector(0, 0, 0)) * spr_midpoint
        local spr_jaffset = (sim and sim.Ang or Angle(0, 0, 0)) * spr_midpoint

        extra_offsetpos:Add(spr_joffset)
        extra_offsetang:Add(spr_jaffset)
    end

    if curvedcustomizedelta > 0 then
        local cpos = Vector(self:GetProcessedValue("CustomizePos"))
        local cang = Angle(self:GetProcessedValue("CustomizeAng"))

        extra_offsetpos:Mul(curvedcustomizedelta) -- LerpVector(curvedcustomizedelta, extra_offsetpos, Vector(0, 0, 0))
        extra_offsetang:Mul(curvedcustomizedelta) -- LerpAngle(curvedcustomizedelta, extra_offsetang, Angle(0, 0, 0))

        if self.BottomBarAddress then
            local slot = self:LocateSlotFromAddress(self.BottomBarAddress)

            if slot then
                local apos = self:GetAttPos(slot, false, true, true)

                local opos = (slot.Icon_Offset or Vector(0, 0, 0))
                local atttbl = self:GetFinalAttTable(slot)
                opos = opos + (atttbl.IconOffset or Vector(0, 0, 0))

                apos.x = apos.x + opos.x
                apos.z = apos.z - opos.z

                cpos:Add(cang:Up() * (apos.x - cpos.x))
                -- cpos:Add(cang:Right() * (apos.y - cpos.y))
                cpos:Add(cang:Forward() * (apos.z + cpos.z))
            end
        end

        cpos:Add(cang:Up() * self.CustomizePanX)
        cpos:Add(cang:Forward() * self.CustomizePanY)
        cpos:Add(Vector(0, 1, 0) * (self.CustomizeZoom + 24))

        offsetpos = LerpVector(curvedcustomizedelta, offsetpos, cpos)
        offsetang = LerpAngle(curvedcustomizedelta, offsetang, cang)
    end

    local ht = self:GetHolster_Time()

    if (ht + 0.1) > CurTime() then
        if ht > lht then
            sht = CurTime()
        end

        local hdelta = 1 - ((ht - CurTime()) / (ht - sht))

        if hdelta > 0 then
            hdelta = math.ease.InOutQuad(hdelta)
            offsetpos = LerpVector(hdelta, offsetpos, self:GetValue("HolsterPos"))
            offsetang = LerpAngle(hdelta, offsetang, self:GetValue("HolsterAng"))
        end
    end

    lht = ht

    pos:Add(ang:Right() * offsetpos.x)
    pos:Add(ang:Forward() * offsetpos.y)
    pos:Add(ang:Up() * offsetpos.z)

    ang:RotateAroundAxis(oldup, offsetang.p)
    ang:RotateAroundAxis(oldright, offsetang.y)
    ang:RotateAroundAxis(oldforward, offsetang.r)

    pos:Add(oldright * extra_offsetpos[1])
    pos:Add(oldforward * extra_offsetpos[2])
    pos:Add(oldup * extra_offsetpos[3])

    ang:RotateAroundAxis(oldup, extra_offsetang[1])
    ang:RotateAroundAxis(oldright, extra_offsetang[2])
    ang:RotateAroundAxis(oldforward, extra_offsetang[3])

    if curvedcustomizedelta > 0 then
        self.CustomizePitch = math.NormalizeAngle(self.CustomizePitch)
        -- this needs to be better
        -- its more like proof of concept
        -- probably this can be better if it based on selected slot offset not random numbers
        pos:Add((ang:Right() * math.sin(math.rad(self.CustomizePitch)) * 18) * curvedcustomizedelta ^ 2)
        pos:Add((ang:Forward() * math.cos(math.rad(self.CustomizePitch)) * -15) * curvedcustomizedelta ^ 2)

        pos:Add((ang:Right() * -18) * curvedcustomizedelta ^ 2)
        pos:Add((ang:Forward() * 15) * curvedcustomizedelta ^ 2)

        ang:RotateAroundAxis(EyeAngles():Up(), self.CustomizePitch * curvedcustomizedelta ^ 2)
    end

    -- ang:RotateAroundAxis(EyeAngles():Forward(), self.CustomizeYaw * curvedcustomizedelta ^ 2)
    --[[
        All of these could be Apply* instead of Get* functions and they could just internaly set their arguments values using :Set() function
        Think back to ArcCW and how munch trouble GetViewModelPosition() function causes, this function is a SWEP maker's worst night nightmare. ~BlacK 26/03/2022
    ]]--
    pos, ang = self:GetViewModelRecoil(pos, ang)
    pos, ang = self:GetViewModelBob(pos, ang)
    pos, ang = self:GetMidAirBob(pos, ang)
    -- pos, ang = self:GetViewModelLeftRight(pos, ang)
    pos, ang = self:GetViewModelInertia(pos, ang)
    pos, ang = self:GetViewModelSway(pos, ang)
    pos, ang = self:GetViewModelSmooth(pos, ang)

    -- if game.SinglePlayer() or IsFirstTimePredicted() then
    if game.SinglePlayer() or CLIENT then
        pos, ang = WorldToLocal(pos, ang, oldpos, oldang)

        pos = DampVector(1 / 10000000000, pos, self.ViewModelPos)
        ang = DampAngle(1 / 10000000000, ang, self.ViewModelAng)

        ang:Normalize()

        self.ViewModelPos = pos
        self.ViewModelAng = ang

        pos, ang = LocalToWorld(pos, ang, oldpos, oldang)

        -- LocalToWorld(Vector localPos, Angle localAng, Vector originPos, Angle originAngle)
        self.ViewModelAng:Normalize()
    end

    pos, ang = self:GunControllerThirdArm(pos, ang)

    self.LastViewModelPos = pos
    self.LastViewModelAng = ang

    return pos, ang
end

function SWEP:GetViewModelFOV()
    local target = self:GetOwner():GetFOV() + GetConVar("arc9_fov"):GetInt()
    local sightedtarget = self:GetSight().ViewModelFOV or (75 + GetConVar("arc9_fov"):GetInt())

    if self:GetSightAmount() > 0 then
        return Lerp(self:GetSightAmount(), target, sightedtarget)
    end

    return target
    -- return 60 * self:GetSmoothedFOVMag()
    -- return 150
    -- return self:GetOwner():GetFOV() * (self:GetProcessedValue("DesiredViewModelFOV") / 90) * math.pow(self:GetSmoothedFOVMag(), 1/4)
end