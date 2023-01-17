SWEP.CustomizeDelta = 0
SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)
SWEP.BenchGunViewModelPos = Vector(0, 0, 0)
SWEP.BenchGunViewModelAng = Angle(0, 0, 0)
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

local LerpVectorEdit = function(a, v1, v2)
    local v11, v12, v13 = v1[1], v1[2], v1[3]
    local v21, v22, v23 = v2[1], v2[2], v2[3]
    v1[1] = Lerp(a, v11, v21)
    v1[2] = Lerp(a, v12, v22)
    v1[3] = Lerp(a, v13, v23)
end

local LerpAngle = function(a, v1, v2)
    -- angle aware lerp with Angles()
    local v11 = v1[1]
    local v12 = v1[2]
    local v13 = v1[3]
    local v21 = v2[1]
    local v22 = v2[2]
    local v23 = v2[3]
    local d1 = math.AngleDifference(v21, v11)
    local d2 = math.AngleDifference(v22, v12)
    local d3 = math.AngleDifference(v23, v13)
    local v3 = Angle(v11 + (a * d1), v12 + (a * d2), v13 + (a * d3))

    return v3
end

local LerpAngleEdit = function(a, v1, v2)
    local v11 = v1[1]
    local v12 = v1[2]
    local v13 = v1[3]
    local v21 = v2[1]
    local v22 = v2[2]
    local v23 = v2[3]
    local d1 = math.AngleDifference(v21, v11)
    local d2 = math.AngleDifference(v22, v12)
    local d3 = math.AngleDifference(v23, v13)
    v1[1] = v11 + (a * d1)
    v1[2] = v12 + (a * d2)
    v1[3] = v13 + (a * d3)
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

local DampVectorEdit = function(a, v1, v2)
    a = math.pow(a, FrameTime())
    LerpVectorEdit(a, v1, v2)
end

local DampAngle = function(a, v1, v2)
    a = 1 - math.pow(a, FrameTime())

    return LerpAngle(a, v2, v1)
end

local DampAngleEdit = function(a, v1, v2)
    a = math.pow(a, FrameTime())
    LerpAngleEdit(a, v1, v2)
end

local singleplayer = game.SinglePlayer()
local somevector = Vector(-1, 0, 1)
local somevector2 = Vector(0, 1, 0)
local somevector3 = Vector(-1, -1, 1)
local cangup = Vector(1, 0, 0)
local cangforward = Vector(0, 0, -1)
local oldpos = Vector(0, 0, 0)
local oldang = Angle(0, 0, 0)
local offsetpos = Vector(0, 0, 0)
local offsetang = Angle(0, 0, 0)
local extra_offsetpos = Vector(0, 0, 0)
local extra_offsetang = Angle(0, 0, 0)
local rotateAroundAngle = Angle(0, 0, 0)
local halfPi = math.pi / 2
local vmAddX = GetConVar("arc9_vm_addx")
local vmAddY = GetConVar("arc9_vm_addy")
local vmAddZ = GetConVar("arc9_vm_addz")
local arc9DevBenchGun = GetConVar("arc9_dev_benchgun")

function SWEP:GetViewModelPosition(pos, ang)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    -- if owner != LocalPlayer() then return end
    if CLIENT and owner ~= LocalPlayer() then return end
    pos, ang = self:DoCameraLean(pos, ang)
    oldpos:Set(pos)
    oldang:Set(ang)
    -- pos = Vector(0, 0, 0)
    -- ang = Angle(0, 0, 0)
    local cor_val = self:GetCorVal()
    extra_offsetpos:Zero()
    extra_offsetang:Zero()
    -- print(extra_offsetang)
    offsetpos:Set(self:GetProcessedValue("ActivePos"))
    offsetang:Set(self:GetProcessedValue("ActiveAng"))
    local movingpv = self.PV_Move
    local mvpos = self:GetProcessedValue("MovingPos")

    if mvpos and movingpv > 0.125 then
        local mvang = self:GetProcessedValue("MovingAng")
        -- local ts_movingpv = 0 -- self:GetTraversalSprintAmount()
        movingpv = math.ease.InOutQuad(movingpv)
        -- ts_movingpv = math.ease.InOutSine(ts_movingpv)
        -- movingpv = math.max(movingpv, ts_movingpv)
        LerpVectorEdit(movingpv, offsetpos, mvpos)
        LerpAngleEdit(movingpv, offsetang, mvang)
        LerpAngleEdit(movingpv, extra_offsetang, angle_zero)
        local wim = self:GetProcessedValue("MovingMidPoint")
        local mv_midpoint = movingpv * math.cos(movingpv * halfPi)
        local mv_joffset = (wim and wim.Pos or vector_origin) * mv_midpoint
        local mv_jaffset = (wim and wim.Ang or angle_zero) * mv_midpoint
        extra_offsetpos:Add(mv_joffset)
        extra_offsetang:Add(mv_jaffset)
    end

    -- if self.PV_Move > 0.2 and self:GetSprintDelta() == 0 then
    --     offsetpos:Set(self:GetProcessedValue("MovingPos"))
    --     offsetang:Set(self:GetProcessedValue("MovingAng"))
    -- end
    local getbipod = self:GetBipod()
    local reloading = self:GetReloading()

    if not reloading and not getbipod then
        local crouchpos = self:GetProcessedValue("CrouchPos")
        local crouchang = self:GetProcessedValue("CrouchAng")
        local viewOffsetZ = owner:GetViewOffset().z
        local crouchdelta = math.Clamp(math.ease.InOutSine((viewOffsetZ - owner:GetCurrentViewOffset().z) / (viewOffsetZ - owner:GetViewOffsetDucked().z)), 0, 1)

        if crouchpos then
            LerpVectorEdit(crouchdelta, offsetpos, crouchpos)
        end

        if crouchang then
            LerpAngleEdit(crouchdelta, offsetang, crouchang)
        end
    end

    if getbipod then
        local bipodamount = self:GetBipodAmount()
        bipodamount = math.ease.InOutQuad(bipodamount)
        local sightpos, sightang = self:GetSightPositions()
        local bipodpos, bipodang = self:GetProcessedValue("BipodPos"), self:GetProcessedValue("BipodAng")

        if bipodpos and bipodang then
            LerpVectorEdit(math.Clamp(bipodamount - self:GetSightAmount(), 0, 1), pos, self:GetBipodPos())
            LerpVectorEdit(bipodamount, offsetpos, bipodpos)
            LerpAngleEdit(bipodamount, offsetang, bipodang)
        else
            offsetpos:Add(sightpos * bipodamount)
            offsetang:Add(sightang * bipodamount)
        end
    end

    -- local blindfiredelta = self:GetBlindFireAmount()
    -- local blindfirecornerdelta = self:GetBlindFireCornerAmount()
    -- local curvedblindfiredelta = self:Curve(blindfiredelta)
    -- local curvedblindfirecornerdelta = self:Curve(math.abs(blindfirecornerdelta))
    -- if blindfiredelta > 0 then
    --     offsetpos = LerpVector(curvedblindfiredelta, offsetpos, self:GetValue("BlindFirePos"))
    --     offsetang = LerpAngle(curvedblindfiredelta, offsetang, self:GetValue("BlindFireAng"))
    --     if blindfirecornerdelta > 0 then
    --         offsetpos = LerpVector(curvedblindfirecornerdelta, offsetpos, self:GetValue("BlindFireRightPos"))
    --         offsetang = LerpAngle(curvedblindfirecornerdelta, offsetang, self:GetValue("BlindFireRightAng"))
    --     elseif blindfirecornerdelta < 0 then
    --         offsetpos = LerpVector(curvedblindfirecornerdelta, offsetpos, self:GetValue("BlindFireLeftPos"))
    --         offsetang = LerpAngle(curvedblindfirecornerdelta, offsetang, self:GetValue("BlindFireLeftAng"))
    --     end
    -- end
    if reloading then
        local reloadpos = self:GetProcessedValue("ReloadPos")
        local reloadang = self:GetProcessedValue("ReloadAng")

        if reloadpos then
            offsetpos:Set(reloadpos)
        end

        if reloadang then
            offsetang:Set(reloadang)
        end
    end

    do
        local offsetangRight = offsetang:Right()
        local offsetangForward = offsetang:Forward()
        local offsetangUp = offsetang:Up()
        offsetangRight:Mul(vmAddY:GetFloat())
        offsetangForward:Mul(vmAddX:GetFloat())
        offsetangUp:Mul(vmAddZ:GetFloat())
        offsetpos:Add(offsetangRight)
        offsetpos:Add(offsetangForward)
        offsetpos:Add(offsetangUp)
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

        -- if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) then
        if self.Peeking then
            eepos = eepos + self:GetProcessedValue("PeekPos")
            eeang = eeang + self:GetProcessedValue("PeekAng")
        end

        if sight.GeneratedSight then
            local t_sightpos = LerpVector(sightdelta, vector_origin, sightpos)
            local t_sightang = LerpAngle(sightdelta, angle_zero, sightang)
            ang:RotateAroundAxis(oldang:Up(), t_sightang[1])
            ang:RotateAroundAxis(oldang:Right(), t_sightang[2])
            ang:RotateAroundAxis(oldang:Forward(), t_sightang[3])
            local angRight = ang:Right()
            local angForward = ang:Forward()
            local angUp = ang:Up()
            angRight:Mul(t_sightpos[1])
            angForward:Mul(t_sightpos[2])
            angUp:Mul(t_sightpos[3])
            pos:Add(angRight)
            pos:Add(angForward)
            pos:Add(angUp)
            LerpVectorEdit(sightdelta, offsetpos, vector_origin)
            LerpAngleEdit(sightdelta, offsetang, angle_zero)
        else
            offsetpos = LerpVector(sightdelta, offsetpos or vector_origin, sightpos or vector_origin)
            offsetang = LerpAngle(sightdelta, offsetang or angle_zero, sightang or angle_zero)
        end

        -- local eepos, eeang = Vector(0, 0, 0), Angle(0, 0, 0)
        local im = self:GetProcessedValue("SightMidPoint")
        local midpoint = sightdelta * math.cos(sightdelta * halfPi)
        local joffset = (im and im.Pos or vector_origin) * midpoint
        local jaffset = (im and im.Ang or angle_zero) * midpoint
        LerpVectorEdit(sightdelta, extra_offsetpos, eepos + joffset)
        LerpAngleEdit(sightdelta, extra_offsetang, eeang + jaffset)
        -- self.BobScale = 0
        -- self.SwayScale = Lerp(sightdelta, 1, 0.1)
    end

    local getfreeswayang, getfreeswayoffset = self:GetFreeSwayAngles(), self:GetFreeAimOffset()
    extra_offsetang[2] = extra_offsetang[2] - (getfreeswayang[1] * cor_val)
    extra_offsetang[1] = extra_offsetang[1] + (getfreeswayang[2] * cor_val)
    -- extra_offsetpos.x = extra_offsetpos.x + (self:GetFreeSwayAngles().y * cor_val) - 0.01
    -- extra_offsetpos.z = extra_offsetpos.z + (self:GetFreeSwayAngles().p * cor_val) - 0.05 -- idkkkkkkkk
    extra_offsetang[2] = extra_offsetang[2] - (getfreeswayoffset[1] * cor_val)
    extra_offsetang[1] = extra_offsetang[1] + (getfreeswayoffset[2] * cor_val)

    if singleplayer or IsFirstTimePredicted() then
        if self:GetCustomize() then
            if self.CustomizeDelta < 1 then
                self.CustomizeDelta = math.Approach(self.CustomizeDelta, 1, FrameTime() * 6.666666666666667)
            end
        else
            if self.CustomizeDelta > 0 then
                self.CustomizeDelta = math.Approach(self.CustomizeDelta, 0, FrameTime() * 6.666666666666667)
            end
        end
    end

    local curvedcustomizedelta = self:Curve(self.CustomizeDelta)
    -- local sprintdelta = self:Curve(self:GetSprintDelta())
    local sprintdelta = self:GetSprintDelta()

    if sprintdelta > 0 then
        -- local ts_sprintdelta = 0 -- self:GetTraversalSprintAmount()
        sprintdelta = math.ease.InOutQuad(sprintdelta) - curvedcustomizedelta
        -- ts_sprintdelta = math.ease.InOutSine(ts_sprintdelta)
        -- sprintdelta = math.max(sprintdelta, ts_sprintdelta)
        local sprpos = self:GetProcessedValue("SprintPos") or self:GetProcessedValue("RestPos")
        local sprang = self:GetProcessedValue("SprintAng") or self:GetProcessedValue("RestAng")
        -- sprpos = LerpVector(ts_sprintdelta, sprpos, self:GetProcessedValue("TraversalSprintPos"))
        -- sprang = LerpAngle(ts_sprintdelta, sprang, self:GetProcessedValue("TraversalSprintAng"))
        LerpVectorEdit(sprintdelta, offsetpos, sprpos)
        LerpAngleEdit(sprintdelta, offsetang, sprang)
        LerpAngleEdit(sprintdelta, extra_offsetang, angle_zero)
        local sim = self:GetProcessedValue("SprintMidPoint")
        local spr_midpoint = sprintdelta * math.cos(sprintdelta * halfPi)
        local spr_joffset = (sim and sim.Pos or vector_origin) * spr_midpoint
        local spr_jaffset = (sim and sim.Ang or angle_zero) * spr_midpoint
        extra_offsetpos:Add(spr_joffset)
        extra_offsetang:Add(spr_jaffset)
    end

    local nearwalldelta = self:GetNearWallAmount()

    if nearwalldelta > 0 then
        nearwalldelta = math.ease.InOutQuad(nearwalldelta) - curvedcustomizedelta
        -- sprintdelta = math.max(sprintdelta, ts_sprintdelta)
        local sprpos = self:GetProcessedValue("NearWallPos") or self:GetProcessedValue("SprintPos") or self:GetProcessedValue("RestPos")
        local sprang = self:GetProcessedValue("NearWallAng") or self:GetProcessedValue("SprintAng") or self:GetProcessedValue("RestAng")
        -- sprpos = LerpVector(ts_sprintdelta, sprpos, self:GetProcessedValue("TraversalSprintPos"))
        -- sprang = LerpAngle(ts_sprintdelta, sprang, self:GetProcessedValue("TraversalSprintAng"))
        LerpVectorEdit(nearwalldelta, offsetpos, sprpos)
        LerpAngleEdit(nearwalldelta, offsetang, sprang)
        LerpAngleEdit(nearwalldelta, extra_offsetang, angle_zero)
    end

    if curvedcustomizedelta > 0 then
        local cpos = Vector(self:GetProcessedValue("CustomizePos"))
        local cang = self:GetProcessedValue("CustomizeAng")
        LerpVectorEdit(curvedcustomizedelta, extra_offsetpos, vector_origin)
        LerpAngleEdit(curvedcustomizedelta, extra_offsetang, angle_zero)

        if self.BottomBarMode == 1 then
            cpos[3] = cpos[3] + 5
        else
            cpos[3] = cpos[3] + 1.5
        end

        cpos[1] = cpos[1] + self.CustomizePanX
        cpos[3] = cpos[3] - self.CustomizePanY
        cpos[2] = cpos[2] + self.CustomizeZoom - 15
        LerpVectorEdit(curvedcustomizedelta, offsetpos, cpos)
        LerpAngleEdit(curvedcustomizedelta, offsetang, cang)
    end

    local ht = self:GetHolsterTime()
    local curTime = CurTime()

    if (ht + 0.1) > curTime then
        if ht > lht then
            sht = curTime
        end

        local hdelta = 1 - ((ht - curTime) / (ht - sht))

        if hdelta > 0 then
            hdelta = math.ease.InOutQuad(hdelta)
            LerpVectorEdit(hdelta, offsetpos, self:GetValue("HolsterPos"))
            LerpAngleEdit(hdelta, offsetang, self:GetValue("HolsterAng"))
        end
    end

    lht = ht
    local angup, angright, angforward = ang:Up(), ang:Right(), ang:Forward()
    local oldangup, oldangright, oldangforward = oldang:Up(), oldang:Right(), oldang:Forward()
    angright:Mul(offsetpos[1])
    angforward:Mul(offsetpos[2])
    angup:Mul(offsetpos[3])
    pos:Add(angright)
    pos:Add(angforward)
    pos:Add(angup)
    ang:RotateAroundAxis(oldangup, offsetang.p)
    ang:RotateAroundAxis(oldangright, offsetang.y)
    ang:RotateAroundAxis(oldangforward, offsetang.r)
    angup, angright, angforward = ang:Up(), ang:Right(), ang:Forward()
    ang:RotateAroundAxis(oldangup, extra_offsetang[1])
    ang:RotateAroundAxis(oldangright, extra_offsetang[2])
    ang:RotateAroundAxis(oldangforward, extra_offsetang[3])
    oldangright:Mul(extra_offsetpos[1])
    oldangforward:Mul(extra_offsetpos[2])
    oldangup:Mul(extra_offsetpos[3])
    pos:Add(oldangright)
    pos:Add(oldangforward)
    pos:Add(oldangup)

    -- idle breath
    if curvedcustomizedelta <= 0 then
        local sighted = Lerp(sightdelta, 1, 0.1)
        local ct = curTime * math.pi * Lerp(sightdelta, 1, 0.5)
        -- making parenthesis on (sightes * math.sin) cuz it creates number first and then multiplies vector to it
        -- if we won't do it, then vector would be multiplied by sighted,
        -- new vector will be created and there would be 3 additional vectors, which won't be used
        pos:Sub(angright * (sighted * math.sin(ct * 0.8) * 0.01)) -- X 
        pos:Sub(angup * (sighted * math.cos(ct * 0.84) * 0.02)) -- Y
        pos:Sub(angforward * (sighted * math.cos(ct * 0.84) * 0.02)) -- Z
        ang:RotateAroundAxis(angright, sighted * math.sin(ct * 0.84) * -0.07) -- P
        ang:RotateAroundAxis(angup, sighted * math.cos(ct * -0.65) * -0.07) -- Y
        ang:RotateAroundAxis(angforward, sighted * math.sin(ct * 0.5) * 0.25) -- R
    end

    pos, ang = self:GetViewModelRecoil(pos, ang, cor_val)

    if not self:GetProcessedValue("NoViewBob") then
        pos, ang = self:GetViewModelBob(pos, ang)
        pos, ang = self:GetMidAirBob(pos, ang)
    end

    -- pos, ang = self:GetViewModelLeftRight(pos, ang)
    pos, ang = self:GetViewModelInertia(pos, ang)
    pos, ang = self:GetViewModelSway(pos, ang)
    pos, ang = self:GetViewModelSmooth(pos, ang)
    -- if singleplayer or IsFirstTimePredicted() then
    pos, ang = WorldToLocal(pos, ang, oldpos, oldang)

    if singleplayer or IsFirstTimePredicted() then
        DampVectorEdit(0.0000005, pos, self.ViewModelPos)
        DampAngleEdit(0.00001, ang, self.ViewModelAng)
        self.ViewModelPos = pos
        self.ViewModelAng = ang
    else
        pos, ang = self.ViewModelPos, self.ViewModelAng
    end

    pos, ang = LocalToWorld(pos, ang, oldpos, oldang)

    -- CUSTOMISATION ROTATION AFTER DAMPING
    if curvedcustomizedelta > 0 then
        if not self.CustomizeNoRotate then
            self.CustomizePitch = math.NormalizeAngle(self.CustomizePitch) * curvedcustomizedelta
            self.CustomizeYaw = math.NormalizeAngle(self.CustomizeYaw) * curvedcustomizedelta
            -- local CustomizeRotateAnchor = Vector(21.5, -4.27, -5.23)
            rotateAroundAngle[2] = self.CustomizePitch
            rotateAroundAngle[3] = self.CustomizeYaw
            local rap_pos, rap_ang = self:RotateAroundPoint2(pos, ang, self.CustomizeRotateAnchor, vector_origin, rotateAroundAngle)
            pos:Set(rap_pos)
            ang:Set(rap_ang)
        end
    end

    pos, ang = self:GunControllerRHIK(pos, ang)
    pos, ang = self:GunControllerThirdArm(pos, ang)
    self.LastViewModelPos = pos
    self.LastViewModelAng = ang
    local wm = self:GetWM()

    if IsValid(wm) and curvedcustomizedelta == 0 then
        if not self:ShouldTPIK() then
            wm.slottbl.Pos = self.WorldModelOffset.Pos
            wm.slottbl.Ang = self.WorldModelOffset.Ang
        else
            if self.NoTPIKVMPos then
                wm.slottbl.Pos = self.WorldModelOffset.TPIKPos or self.WorldModelOffset.Pos
                wm.slottbl.Ang = self.WorldModelOffset.TPIKAng or self.WorldModelOffset.Ang
            elseif LocalPlayer() == owner then
                wm.slottbl.Pos = (self.WorldModelOffset.TPIKPos or self.WorldModelOffset.Pos) - self.ViewModelPos * somevector3
                wm.slottbl.Ang = (self.WorldModelOffset.TPIKAng or self.WorldModelOffset.Ang) + Angle(self.ViewModelAng.p, -self.ViewModelAng.y, self.ViewModelAng.r)
            end
        end
    end

    if arc9DevBenchGun:GetBool() then return self.BenchGunViewModelPos, self.BenchGunViewModelAng end
    self.BenchGunViewModelPos = pos
    self.BenchGunViewModelAng = ang

    return pos, ang
end

local Damp = function(a, v1, v2) return Lerp(1 - math.pow(a, FrameTime()), v2, v1) end
SWEP.SmoothedViewModelFOV = nil
local arc9Fov = GetConVar("arc9_fov")

function SWEP:GetViewModelFOV()
    local owner = self:GetOwner()
    local ownerfov = owner:GetFOV()
    local convarfov = arc9Fov:GetInt()
    local curtime = CurTime()
    -- local target = owner:GetFOV() + convarfov
    local target = (self:GetProcessedValue("ViewModelFOVBase") or ownerfov) + (self:GetCustomize() and 0 or convarfov)

    if self:GetInSights() then
        -- target = Lerp(self:GetSightAmount(), target, sightedtarget)
        target = self:GetSight().ViewModelFOV or (75 + convarfov)
    end

    if self:GetCustomize() then
        target = self.CustomizeSnapshotFOV or 90
    end

    if arc9DevBenchGun:GetBool() then
        target = owner:GetFOV()
    end

    self.SmoothedViewModelFOV = self.SmoothedViewModelFOV or target
    local diff = math.abs(target - self.SmoothedViewModelFOV)
    self.SmoothedViewModelFOV = math.Approach(self.SmoothedViewModelFOV, target, diff * FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
    -- return 60 * self:GetSmoothedFOVMag()
    -- return 150
    -- return owner:GetFOV() * (self:GetProcessedValue("DesiredViewModelFOV") / 90) * math.pow(self:GetSmoothedFOVMag(), 1/4)

    return self.SmoothedViewModelFOV
end