SWEP.CustomizeDelta = 0

SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)

local lht = 0
local sht = 0

local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local LerpVector = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local LerpAngle = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

-- local ApproachVector = function(a1, a2, d)
--     a1[1] = math.Approach(a1[1], a2[1], d)
--     a1[2] = math.Approach(a1[2], a2[2], d)
--     a1[3] = math.Approach(a1[3], a2[3], d)

--     return a1
-- end

-- local Damp = function(a, v1, v2)
--     return Lerp(1 - math.pow(a, FrameTime()), v2, v1)
-- end

local DampVector = function(a, v1, v2)
    a = 1 - math.pow(a, FrameTime())

    return LerpVector(a, v2, v1)
end

local DampAngle = function(a, v1, v2)
    a = 1 - math.pow(a, FrameTime())

    return LerpAngle(a, v2, v1)
end

function SWEP:GetViewModelPosition(pos, ang)
    local oldpos = Vector(0, 0, 0)
    local oldang = Angle(0, 0, 0)

    oldpos:Set(pos)
    oldang:Set(ang)

    if GetConVar("arc9_dev_benchgun"):GetBool() then
        if GetConVar("arc9_dev_benchgun_custom"):GetString() then
            local bgc = GetConVar("arc9_dev_benchgun_custom"):GetString()
            if string.Left(bgc, 6) != "setpos" then return vector_origin, angle_zero end

            bgc = string.TrimLeft(bgc, "setpos ")
            bgc = string.Replace(bgc, ";setang", "")
            bgc = string.Explode(" ", bgc)

            pos, ang = Vector(bgc[1], bgc[2], bgc[3]), Angle(bgc[4], bgc[5], bgc[6])
    else
        return Vector(), Angle()
    end
    elseif ARC9.Dev(3) then
        pos = self:GetOwner():EyePos()
        ang = self:GetOwner():EyeAngles()
    end

    -- pos = Vector(0, 0, 0)
    -- ang = Angle(0, 0, 0)

    local cor_val = 0.25

    local offsetpos = Vector(0, 0, 0)
    local offsetang = Angle(0, 0, 0)

    local extra_offsetpos = Vector(0, 0, 0)
    local extra_offsetang = Angle(0, 0, 0)

    -- print(extra_offsetang)

    offsetpos:Set(self:GetProcessedValue("ActivePos"))
    offsetang:Set(self:GetProcessedValue("ActiveAng"))

    local movingpv = self.PV_Move
    local mvpos = self:GetProcessedValue("MovingPos")

    if mvpos and movingpv > 0.125 then
        local mvang = self:GetProcessedValue("MovingAng")
        
        local ts_movingpv = 0 -- self:GetTraversalSprintAmount()
        movingpv = math.ease.InOutQuad(movingpv)
        ts_movingpv = math.ease.InOutSine(ts_movingpv)

        movingpv = math.max(movingpv, ts_movingpv)


        offsetpos = LerpVector(movingpv, offsetpos, mvpos)
        offsetang = LerpAngle(movingpv, offsetang, mvang)

        extra_offsetang = LerpAngle(movingpv, extra_offsetang, Angle(0, 0, 0))

        local wim = self:GetProcessedValue("MovingMidPoint")

        local mv_midpoint = movingpv * math.cos(movingpv * (math.pi / 2))
        local mv_joffset = (wim and wim.Pos or Vector(0, 0, 0)) * mv_midpoint
        local mv_jaffset = (wim and wim.Ang or Angle(0, 0, 0)) * mv_midpoint

        extra_offsetpos = extra_offsetpos + mv_joffset
        extra_offsetang = extra_offsetang + mv_jaffset
    end

    -- if self.PV_Move > 0.2 and self:GetSprintDelta() == 0 then
    --     offsetpos:Set(self:GetProcessedValue("MovingPos"))
    --     offsetang:Set(self:GetProcessedValue("MovingAng"))
    -- end

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
        local bipodpos, bipodang = self:GetProcessedValue("BipodPos"), self:GetProcessedValue("BipodAng")

        if bipodpos and bipodang then
            -- LerpVector(bipodamount, sightpos, bipodpos)
            -- LerpAngle(bipodamount, sightpos, bipodang)

            -- offsetpos = offsetpos + (bipodpos * bipodamount)
            -- offsetang = offsetang + (bipodpos * bipodamount)
            offsetpos = LerpVector(bipodamount, offsetpos, bipodpos)
            offsetang = LerpAngle(bipodamount, offsetang, bipodang)
        else
            offsetpos = offsetpos + (sightpos * bipodamount)
            offsetang = offsetang + (sightang * bipodamount)
        end
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
        if self:GetInSights() then
            sightdelta = math.ease.OutQuart(sightdelta)
        else
            sightdelta = math.ease.InQuart(sightdelta)
        end
        -- sightdelta = math.ease.InOutQuad(sightdelta)
        local sightpos, sightang = self:GetSightPositions()
        local sight = self:GetSight()
        local eepos, eeang = self:GetExtraSightPositions()

        if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) then
            eepos = eepos + Vector(-1, 0, 1)
        end

        if sight.GeneratedSight then
            local t_sightpos = LerpVector(sightdelta, Vector(0, 0 ,0), sightpos)
            local t_sightang = LerpAngle(sightdelta, Angle(0, 0, 0), sightang)

            ang:RotateAroundAxis(oldang:Up(), t_sightang.p)
            ang:RotateAroundAxis(oldang:Right(), t_sightang.y)
            ang:RotateAroundAxis(oldang:Forward(), t_sightang.r)

            pos = pos + (ang:Right() * t_sightpos.x)
            pos = pos + (ang:Forward() * t_sightpos.y)
            pos = pos + (ang:Up() * t_sightpos.z)

            offsetpos = LerpVector(sightdelta, offsetpos, Vector(0, 0, 0))
            offsetang = LerpAngle(sightdelta, offsetang, Angle(0, 0, 0))
        else
            offsetpos = LerpVector(sightdelta, offsetpos or Vector(0, 0 ,0), sightpos or Vector(0, 0 ,0))
            offsetang = LerpAngle(sightdelta, offsetang or Angle(0, 0 ,0), sightang or Angle(0, 0, 0))
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

    extra_offsetang.y = extra_offsetang.y - (self:GetFreeSwayAngles().p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (self:GetFreeSwayAngles().y * cor_val)

    -- extra_offsetpos.x = extra_offsetpos.x + (self:GetFreeSwayAngles().y * cor_val) - 0.01
    -- extra_offsetpos.z = extra_offsetpos.z + (self:GetFreeSwayAngles().p * cor_val) - 0.05 -- idkkkkkkkk

    extra_offsetang.y = extra_offsetang.y - (self:GetFreeAimOffset().p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (self:GetFreeAimOffset().y * cor_val)

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
        local ts_sprintdelta = 0 -- self:GetTraversalSprintAmount()
        sprintdelta = math.ease.InOutQuad(sprintdelta) - curvedcustomizedelta
        ts_sprintdelta = math.ease.InOutSine(ts_sprintdelta)

        sprintdelta = math.max(sprintdelta, ts_sprintdelta)

        local sprpos = self:GetProcessedValue("SprintPos") or self:GetProcessedValue("RestPos")
        local sprang = self:GetProcessedValue("SprintAng") or self:GetProcessedValue("RestAng")

        sprpos = LerpVector(ts_sprintdelta, sprpos, self:GetProcessedValue("TraversalSprintPos"))
        sprang = LerpAngle(ts_sprintdelta, sprang, self:GetProcessedValue("TraversalSprintAng"))

        offsetpos = LerpVector(sprintdelta, offsetpos, sprpos)
        offsetang = LerpAngle(sprintdelta, offsetang, sprang)

        extra_offsetang = LerpAngle(sprintdelta, extra_offsetang, Angle(0, 0, 0))

        local sim = self:GetProcessedValue("SprintMidPoint")

        local spr_midpoint = sprintdelta * math.cos(sprintdelta * (math.pi / 2))
        local spr_joffset = (sim and sim.Pos or Vector(0, 0, 0)) * spr_midpoint
        local spr_jaffset = (sim and sim.Ang or Angle(0, 0, 0)) * spr_midpoint

        extra_offsetpos = extra_offsetpos + spr_joffset
        extra_offsetang = extra_offsetang + spr_jaffset
    end

    if curvedcustomizedelta > 0 then
        local cpos = self:GetProcessedValue("CustomizePos")
        local cang = self:GetProcessedValue("CustomizeAng")

        extra_offsetpos = LerpVector(curvedcustomizedelta, extra_offsetpos, Vector(0, 0, 0))
        extra_offsetang = LerpAngle(curvedcustomizedelta, extra_offsetang, Angle(0, 0, 0))

        -- if self.BottomBarAddress then
        --     local slot = self:LocateSlotFromAddress(self.BottomBarAddress)

        --     if slot then
        --         local apos = self:GetAttPos(slot, false, true, true)

        --         local opos = (slot.Icon_Offset or Vector(0, 0, 0))
        --         local atttbl = self:GetFinalAttTable(slot)
        --         opos = opos + (atttbl.IconOffset or Vector(0, 0, 0))

        --         apos.x = apos.x + opos.x
        --         apos.z = apos.z - opos.z

        --         cpos = cpos + cang:Up() * (apos.x - cpos.x)
        --         -- cpos = cpos + cang:Right() * (apos.y - cpos.y)
        --         cpos = cpos + cang:Forward() * (apos.z + cpos.z)
        --     end

        if self.BottomBarMode == 1 then
            cpos = cpos - cang:Forward() * 5 -- extended cust offset
        else
            cpos = cpos - cang:Forward() * 1.5 -- idle offset

        end

        cpos = cpos + cang:Up() * self.CustomizePanX
        cpos = cpos + cang:Forward() * (self.CustomizePanY - 0.7)
        cpos = cpos + Vector(0, 1, 0) * (self.CustomizeZoom + 10)

        offsetpos = LerpVector(curvedcustomizedelta, offsetpos, cpos)
        offsetang = LerpAngle(curvedcustomizedelta, offsetang, cang)
    end

    local ht = self:GetHolsterTime()

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

    if curvedcustomizedelta > 0 then
        if !self.CustomizeNoRotate then
            self.CustomizePitch = math.NormalizeAngle(self.CustomizePitch)
            self.CustomizeYaw = math.NormalizeAngle(self.CustomizeYaw)
            -- this needs to be better
            -- its more like proof of concept
            -- probably this can be better if it based on selected slot offset not random numbers

            -- local px, py = rotatearound2dpoint(pos.x - 4, pos.y - 15, self.CustomizePitch, pos.x, pos.y)
            -- i have no fucking ideaaaaa im bad at trigonometry

            pos = pos + (ang:Right() * math.sin(math.rad(self.CustomizePitch)) * 18) * curvedcustomizedelta ^ 2
            pos = pos + (ang:Forward() * math.cos(math.rad(self.CustomizePitch)) * -18) * curvedcustomizedelta ^ 2
        end

        pos = pos + (ang:Right() * -18) * curvedcustomizedelta ^ 2
        pos = pos + (ang:Forward() * 18) * curvedcustomizedelta ^ 2

        if !self.CustomizeNoRotate then
            ang:RotateAroundAxis(EyeAngles():Up(), self.CustomizePitch * curvedcustomizedelta ^ 2)

            if GetConVar("arc9_cust_roll_unlock"):GetBool() then
                ang:RotateAroundAxis(EyeAngles():Right(), self.CustomizeYaw * curvedcustomizedelta ^ 2)
            end
        end
    else
        pos:Add( ang:Up() * math.sin(CurTime() * math.pi) * 0.02 * Lerp(self:GetSightDelta(), 1, 0.05) )
        pos:Add( ang:Right() * math.sin(CurTime() * math.pi * 0.5) * 0.04 * Lerp(self:GetSightDelta(), 1, 0.05) )
        ang.x = ang.x + math.pow( math.sin(CurTime() * math.pi * 0.5) * 0.3 * Lerp(self:GetSightDelta(), 1, 0.05), 2 )
        ang.y = ang.y + ( math.sin(CurTime() * math.pi * 1) * 0.1 * Lerp(self:GetSightDelta(), 1, 0.05) )
        ang.z = ang.z + ( math.sin(CurTime() * math.pi * 0.25) * 0.1 * Lerp(self:GetSightDelta(), 1, 0.05) )
    end
    pos, ang = self:GetViewModelRecoil(pos, ang)

    if !self:GetProcessedValue("NoViewBob") then
        pos, ang = self:GetViewModelBob(pos, ang)
        pos, ang = self:GetMidAirBob(pos, ang)
    end
    -- pos, ang = self:GetViewModelLeftRight(pos, ang)
    pos, ang = self:GetViewModelInertia(pos, ang)
    pos, ang = self:GetViewModelSway(pos, ang)
    pos, ang = self:GetViewModelSmooth(pos, ang)

    -- if game.SinglePlayer() or IsFirstTimePredicted() then
    pos, ang = WorldToLocal(pos, ang, oldpos, oldang)

    if game.SinglePlayer() or IsFirstTimePredicted() then
        pos = DampVector(1 / 10000000000, pos, self.ViewModelPos)
        ang = DampAngle(1 / 10000000000, ang, self.ViewModelAng)

        -- pos = DampVector(0, pos, self.ViewModelPos)
        -- ang = DampAngle(0, ang, self.ViewModelAng)

        -- ang:Normalize()

        self.ViewModelPos = pos
        self.ViewModelAng = ang
    else
        pos, ang = self.ViewModelPos, self.ViewModelAng
    end

    pos, ang = LocalToWorld(pos, ang, oldpos, oldang)

    -- LocalToWorld(Vector localPos, Angle localAng, Vector originPos, Angle originAngle)
    -- self.ViewModelAng:Normalize()

    pos, ang = self:GunControllerRHIK(pos, ang)
    pos, ang = self:GunControllerThirdArm(pos, ang)

    self.LastViewModelPos = pos
    self.LastViewModelAng = ang

    local wm = self:GetWM()

    if IsValid(wm) and curvedcustomizedelta == 0 then
        if !self:ShouldTPIK() then
            wm.slottbl.Pos = self.WorldModelOffset.Pos
            wm.slottbl.Ang = self.WorldModelOffset.Ang
        else
            if LocalPlayer() == self:GetOwner() then
                wm.slottbl.Pos = (self.WorldModelOffset.TPIKPos or self.WorldModelOffset.Pos) - self.ViewModelPos * Vector(-1, -1, 1)
                wm.slottbl.Ang = (self.WorldModelOffset.TPIKAng or self.WorldModelOffset.Ang) + Angle(self.ViewModelAng.p, -self.ViewModelAng.y, self.ViewModelAng.r)
            end
        end
    end

    return pos, ang
end

function SWEP:ScaleFOVByWidthRatio( fovDegrees, ratio )
    local halfAngleRadians = fovDegrees * ( 0.5 * math.pi / 180 )
    local t = math.tan( halfAngleRadians )
    t = t * ratio
    local retDegrees = ( 180 / math.pi ) * math.atan( t )
    return retDegrees * 2
end

SWEP.SmoothedViewModelFOV = nil

function SWEP:WidescreenFix(target)
    return self:ScaleFOVByWidthRatio(target, ((ScrW and ScrW() or 4) / (ScrH and ScrH() or 3)) / (4 / 3))
end

function SWEP:GetViewModelFOV()
    -- local target = self:GetOwner():GetFOV() + GetConVar("arc9_fov"):GetInt()
    local owner = self:GetOwner()
    local target = (self:GetProcessedValue("ViewModelFOVBase") or owner:GetFOV()) + (self:GetCustomize() and 0 or GetConVar("arc9_fov"):GetInt())

    if self:GetInSights() then
        -- target = Lerp(self:GetSightAmount(), target, sightedtarget)
        target = self:GetSight().ViewModelFOV or (75 + GetConVar("arc9_fov"):GetInt())
    end

    for _, mod in pairs(self.FOV_RecoilMods) do
        local per_pre = math.TimeFraction( mod.realstart, mod.time_start, CurTime() )
        local per_act = math.TimeFraction( mod.time_start, mod.time_end, CurTime() )
        if per_act < 0 then
            per_act = per_pre
            if mod.func_pre then per_act = mod.func_pre(per_act) end
        else
            per_act = 1-per_act
            if mod.func_act then per_act = mod.func_act(per_act) end
        end
        per_act = math.Clamp(per_act, 0, 1)
        local satarget = 0
        satarget = satarget + (mod.amount * per_act)
        target = target + satarget * ( target / (owner:GetFOV() + GetConVar("arc9_fov"):GetInt() ) )
        if mod.time_end < CurTime() then self.FOV_RecoilMods[_] = nil end
    end

    self.SmoothedViewModelFOV = self.SmoothedViewModelFOV or target

    self.SmoothedViewModelFOV = Lerp(0.1, self.SmoothedViewModelFOV, target)

    return self.SmoothedViewModelFOV
    -- return 60 * self:GetSmoothedFOVMag()
    -- return 150
    -- return self:GetOwner():GetFOV() * (self:GetProcessedValue("DesiredViewModelFOV") / 90) * math.pow(self:GetSmoothedFOVMag(), 1/4)
end