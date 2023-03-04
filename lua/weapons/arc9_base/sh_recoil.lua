SWEP.RecoilPatternCache = {}

-- Unfortunately, this file is loaded before sh_stats,
-- so we do not know about this function at this time
local swepGetProcessedValue

local isSingleplayer = game.SinglePlayer()

function SWEP:GetRecoilPatternDirection(shot)
    local dir = 0

    local seed = self:GetProcessedValue("RecoilSeed") or self:GetClass()

    if isstring(seed) then
        local numseed = 0

        for _, i in ipairs(string.ToTable(seed)) do
            numseed = numseed + string.byte(i)
        end

        numseed = numseed % 16777216

        seed = numseed
    end

    seed = seed + shot

    if self:GetProcessedValue("RecoilLookupTable") then
        dir = self:PatternWithRunOff(self:GetProcessedValue("RecoilLookupTable"), self:GetProcessedValue("RecoilLookupTableOverrun") or self:GetProcessedValue("RecoilLookupTable"), shot)
    else
        if self.RecoilPatternCache[shot] then
            dir = self.RecoilPatternCache[shot]
        else
            self.RecoilPatternCache[1] = 0
            if self.RecoilPatternCache[shot - 1] then
                dir = self.RecoilPatternCache[shot - 1]
                math.randomseed(seed)
                local drift = self:GetValue("RecoilPatternDrift")
                dir = dir + math.Rand(-drift, drift)
                math.randomseed(CurTime() + self:EntIndex())
                self.RecoilPatternCache[shot] = dir
            else
                dir = 0
            end
        end
    end

    dir = self:RunHook("Hook_ModifyRecoilDir", dir) or dir

    return dir
end

function SWEP:ApplyRecoil()
    local rec = self:GetRecoilAmount()

    local rps = 1

    rec = rec + rps
    -- local delay = 60 / self:GetProcessedValue("RPM")

    local recoilup = 0
    local recoilside = 0

    local shot = math.floor(self:GetRecoilAmount()) + 1

    local dir = self:GetRecoilPatternDirection(shot)

    dir = dir - 90

    dir = math.rad(dir)

    recoilup = math.sin(dir)
    recoilside = math.cos(dir)

    local randomrecoilup = util.SharedRandom("arc9_recoil_up_r", -1, 0)
    local randomrecoilside = util.SharedRandom("arc9_recoil_side_r", -1, 1)

    recoilup = recoilup * self:GetProcessedValue("RecoilUp")
    recoilside = recoilside * self:GetProcessedValue("RecoilSide")

    randomrecoilup = randomrecoilup * self:GetProcessedValue("RecoilRandomUp")
    randomrecoilside = randomrecoilside * self:GetProcessedValue("RecoilRandomSide")

    recoilup = recoilup + randomrecoilup
    recoilside = recoilside + randomrecoilside

    recoilup = recoilup * (self:GetProcessedValue("Recoil") or 0)
    recoilside = recoilside * (self:GetProcessedValue("Recoil") or 0)

    self:SetRecoilUp(recoilup)
    self:SetRecoilSide(recoilside)

    -- self:SetRecoilDirection(-90)
    self:SetRecoilAmount(rec)

    self:SetLastRecoilTime(CurTime())

    local pbf = self:GetProcessedValue("PushBackForce")

    if pbf != 0 then
        self:GetOwner():SetVelocity(self:GetShootDir():Forward() * -pbf)
    end

    local vis_kick = self:GetProcessedValue("RecoilKick")
    local vis_shake = 0

    vis_kick = vis_kick * rps
    vis_shake = vis_kick * rps

    local vis_kick_v = vis_kick * 0.5
    local vis_kick_h = vis_kick * util.SharedRandom("ARC9_vis_kick_h", -1, 1)
    vis_shake = vis_shake * util.SharedRandom("ARC9_vis_kick_shake", -1, 1)

    -- self:GetOwner():SetViewPunchAngles(Angle(vis_kick_v, vis_kick_h, vis_shake))

    self:GetOwner():SetFOV(self:GetOwner():GetFOV() * 0.99, 0)
    self:GetOwner():SetFOV(0, 60 / (self:GetProcessedValue("RPM")))
end

-- local function lensqr(ang)
--     return (ang[1] ^ 2) + (ang[2] ^ 2) + (ang[3] ^ 2)
-- end
-- :troll:
local function twoLenSqr(ang1, ang2)
    return (ang1[1] ^ 2) + (ang1[2] ^ 2) + (ang1[3] ^ 2) + (ang2[1] ^ 2) + (ang2[2] ^ 2) + (ang2[3] ^ 2)
end

-- scraped from source SDK 2013, just like this viewpunch damping code
-- local PUNCH_DAMPING = 6
local PUNCH_SPRING_CONSTANT = 120
local POS_PUNCH_DAMPING = 20
local POS_PUNCH_CONSTANT = 90

local ang0 = Angle(0, 0, 0)
local vec0 = Vector(0, 0, 0)

if CLIENT then

SWEP.VisualRecoilPos = Vector(0, 0, 0)
SWEP.VisualRecoilPosVel = Vector(0, 0, 0)
SWEP.VisualRecoilAng = Angle(0, 0, 0)
SWEP.VisualRecoilVel = Angle(0, 0, 0)

end

do
    local min, max = math.min, math.max

    -- Our math.Clamp is faster because:
    -- 1. it is local (welcome to lua)
    -- 2. min and max inside are local (WELCOME to lua + fake for the original function)
    local function math_Clamp(val, low, high)
        return min(max(val, low), high)
    end

    local VECTOR = FindMetaTable("Vector")
    local vectorSub = VECTOR.Sub
    local vectorAdd = VECTOR.Add
    local vectorMul = VECTOR.Mul

    local ANGLE = FindMetaTable("Angle")
    local angleSub = ANGLE.Sub
    local angleAdd = ANGLE.Add
    local angleMul = ANGLE.Mul

    function SWEP:ThinkVisualRecoil()
        -- Don't need to update swepGetProcessedValue because we doing it inside ThinkRecoil
        local ft = FrameTime()
        local swepDt = self.dt
        local firstTimePredicted = IsFirstTimePredicted()

        -- self.VisualRecoilPos = LerpVector(2 * FrameTime(), self.VisualRecoilPos, Vector(0, 0, 0))
        -- self.VisualRecoilAng = LerpAngle(2.5 * FrameTime(), self.VisualRecoilAng, Angle(0, 0, 0))

        -- local ds = 0.2 / (self.VisualRecoilPos:Length() / 1.5)
        -- local dr = 0.1 / (self.VisualRecoilAng.p + self.VisualRecoilAng.y + self.VisualRecoilAng.r)

        -- self.VisualRecoilPos.x = math.Approach(self.VisualRecoilPos.x, 0, FrameTime() / ds)
        -- self.VisualRecoilPos.y = math.Approach(self.VisualRecoilPos.y, 0, FrameTime() / ds)
        -- self.VisualRecoilPos.z = math.Approach(self.VisualRecoilPos.z, 0, FrameTime() / ds)

        -- self.VisualRecoilAng.p = math.Approach(self.VisualRecoilAng.p, 0, FrameTime() / dr)
        -- self.VisualRecoilAng.y = math.Approach(self.VisualRecoilAng.y, 0, FrameTime() / dr)
        -- self.VisualRecoilAng.r = math.Approach(self.VisualRecoilAng.r, 0, FrameTime() / dr)

        local springconstant = swepGetProcessedValue(self, "VisualRecoilDampingConst") or 120
        local VisualRecoilSpringMagnitude = swepGetProcessedValue(self, "VisualRecoilSpringMagnitude") or 1
        local PUNCH_DAMPING = swepGetProcessedValue(self, "VisualRecoilSpringPunchDamping") or 6
        
        if CLIENT and isSingleplayer then  -- idk why
            ft = ft * 0.6666
            PUNCH_DAMPING = PUNCH_DAMPING * 2.6666
            VisualRecoilSpringMagnitude = VisualRecoilSpringMagnitude * 1.6666
        end

        if self.VisualRecoilThinkFunc then
            springconstant, VisualRecoilSpringMagnitude, PUNCH_DAMPING = self.VisualRecoilThinkFunc(springconstant, VisualRecoilSpringMagnitude, PUNCH_DAMPING, self:GetRecoilAmount())
        end

        -- Sometimes we get things depending on the realm:
        --      local vpa = self:GetVisualRecoilPos()
        --      local vpv = self:GetVisualRecoilPosVel()
        --      if CLIENT then
        --          vpa = self.VisualRecoilPos
        --          vpv = self.VisualRecoilPosVel
        --      end
        -- Since we can avoid calling `self:Get[...]()` by directly accessing `self.dt`,
        -- our choice looks like:
        --      local vpa = swepDt.VisualRecoilPos
        --      local vpv = swepDt.VisualRecoilPosVel
        --      if CLIENT then
        --          vpa = self.VisualRecoilPos
        --          vpv = self.VisualRecoilPosVel
        --      end
        -- Only one thing changes here = `self` or `swepDt`. So we can select it once
        -- and use it later:
        local realmDataHolder = CLIENT and self or swepDt

        local vpa = realmDataHolder.VisualRecoilPos
        local vpv = realmDataHolder.VisualRecoilPosVel

        if twoLenSqr(vpa, vpv) > 0 then
            -- {
            --     player->m_Local.m_vecPunchAngle += player->m_Local.m_vecPunchAngleVel * gpGlobals->frametime;
            --     float damping = 1 - (PUNCH_DAMPING * gpGlobals->frametime);

            -- vpa = vpa + (vpv * ft)
            vectorAdd(vpa, vpv * ft)
            local damping = 1 - (POS_PUNCH_DAMPING * ft)

            --     if ( damping < 0 )
            --     {
            --         damping = 0;
            --     }

            if damping < 0 then damping = 0 end

            --     player->m_Local.m_vecPunchAngleVel *= damping;

            -- vpv = vpv * damping
            vectorMul(vpv, damping)

            --     -- torsional spring
            --     -- UNDONE: Per-axis spring constant?
            --     float springForceMagnitude = PUNCH_SPRING_CONSTANT * gpGlobals->frametime;
            local springforcemagnitude = POS_PUNCH_CONSTANT * ft * VisualRecoilSpringMagnitude
            --     springForceMagnitude = clamp(springForceMagnitude, 0.f, 2.f );
            springforcemagnitude = math_Clamp(springforcemagnitude, 0, 2)
            --     player->m_Local.m_vecPunchAngleVel -= player->m_Local.m_vecPunchAngle * springForceMagnitude;
            -- vpv = vpv - (vpa * springforcemagnitude)
            vectorSub(vpv, vpa * springforcemagnitude)

            --     -- don't wrap around
            --     player->m_Local.m_vecPunchAngle.Init(
            --         clamp(player->m_Local.m_vecPunchAngle->x, -89.f, 89.f ),
            --         clamp(player->m_Local.m_vecPunchAngle->y, -179.f, 179.f ),
            --         clamp(player->m_Local.m_vecPunchAngle->z, -89.f, 89.f ) );
            -- }

            vpa[1] = math_Clamp(vpa[1], -89.9, 89.9)
            vpa[2] = math_Clamp(vpa[2], -179.9, 179.9)
            vpa[3] = math_Clamp(vpa[3], -89.9, 89.9)

            self:SetVisualRecoilPos(vpa)
            self:SetVisualRecoilPosVel(vpv)

            if CLIENT and (isSingleplayer or firstTimePredicted) then
                self.VisualRecoilPos = vpa
                self.VisualRecoilPosVel = vpv
            end
        else
            local stubVec = Vector()
            self:SetVisualRecoilPos(stubVec)
            self:SetVisualRecoilPosVel(swepDt.VisualRecoilPos)

            if CLIENT and (isSingleplayer or firstTimePredicted) then
                self.VisualRecoilPos = stubVec
                self.VisualRecoilPosVel = self.VisualRecoilPos
            end
        end

        local vaa = realmDataHolder.VisualRecoilAng
        local vav = realmDataHolder.VisualRecoilVel

        if twoLenSqr(vaa, vav) > 0.000001 then
            -- {
            --     player->m_Local.m_vecPunchAngle += player->m_Local.m_vecPunchAngleVel * gpGlobals->frametime;
            --     float damping = 1 - (PUNCH_DAMPING * gpGlobals->frametime);


            -- vaa = vaa + (vav * ft)
            angleAdd(vaa, vav * ft)
            local damping = 1 - (PUNCH_DAMPING * ft)

            --     if ( damping < 0 )
            --     {
            --         damping = 0;
            --     }

            if damping < 0 then damping = 0 end

            --     player->m_Local.m_vecPunchAngleVel *= damping;

            -- vav = vav * damping
            angleMul(vav, damping)

            --     -- torsional spring
            --     -- UNDONE: Per-axis spring constant?
            --     float springForceMagnitude = PUNCH_SPRING_CONSTANT * gpGlobals->frametime;
            local springforcemagnitude = springconstant * ft
            --     springForceMagnitude = clamp(springForceMagnitude, 0.f, 2.f );
            springforcemagnitude = math_Clamp(springforcemagnitude, 0, 2)
            --     player->m_Local.m_vecPunchAngleVel -= player->m_Local.m_vecPunchAngle * springForceMagnitude;
            -- vav = vav - (vaa * springforcemagnitude)
            angleSub(vav, vaa * springforcemagnitude)

            --     -- don't wrap around
            --     player->m_Local.m_vecPunchAngle.Init(
            --         clamp(player->m_Local.m_vecPunchAngle->x, -89.f, 89.f ),
            --         clamp(player->m_Local.m_vecPunchAngle->y, -179.f, 179.f ),
            --         clamp(player->m_Local.m_vecPunchAngle->z, -89.f, 89.f ) );
            -- }
            vaa[1] = math_Clamp(vaa[1], -89.9, 89.9)
            vaa[2] = math_Clamp(vaa[2], -179.9, 179.9)
            vaa[3] = math_Clamp(vaa[3], -89.9, 89.9)

            self:SetVisualRecoilAng(vaa)
            self:SetVisualRecoilVel(vav)

            if CLIENT and (isSingleplayer or firstTimePredicted)  then
                self.VisualRecoilAng = vaa
                self.VisualRecoilVel = vav
            end
        else
            local recoilZeroAng = Angle(0, 0, 0)
            local velocityZeroAng = Angle(0, 0, 0)
            self:SetVisualRecoilAng(recoilZeroAng)
            self:SetVisualRecoilVel(velocityZeroAng)

            if CLIENT and (isSingleplayer or firstTimePredicted) then
                self.VisualRecoilAng = recoilZeroAng
                self.VisualRecoilVel = velocityZeroAng
            end
        end
    end
end

do
    local weaponGetNextPrimaryFire = FindMetaTable("Weapon").GetNextPrimaryFire
    local swepThinkVisualRecoil = SWEP.ThinkVisualRecoil

    function SWEP:ThinkRecoil()
        swepGetProcessedValue = swepGetProcessedValue or self.GetProcessedValue

        local rdr = swepGetProcessedValue(self, "RecoilDissipationRate")

        if (weaponGetNextPrimaryFire(self) + swepGetProcessedValue(self, "RecoilResetTime")) < CurTime() then
            -- as soon as dissipation kicks in, recoil is clamped to the modifer cap; this is to not break visual recoil
            self:SetRecoilAmount(math.Clamp(self.dt.RecoilAmount - (FrameTime() * rdr), 0, swepGetProcessedValue(self, "UseVisualRecoil") and math.huge or swepGetProcessedValue(self, "RecoilModifierCap")))
            if weaponGetNextPrimaryFire(self) + swepGetProcessedValue(self, "RecoilFullResetTime") < CurTime() then
                self:SetRecoilAmount(0)
            end
            -- print(math.Round(rec))
        end

        local ru = self.dt.RecoilUp
        local rs = self.dt.RecoilSide

        local m = 10

        if math.abs(ru) > 1e-5 or math.abs(rs) > 1e-5 then
            local new_ru = ru - (FrameTime() * ru * m)
            local new_rs = rs - (FrameTime() * rs * m)

            self:SetRecoilUp(new_ru)
            self:SetRecoilSide(new_rs)
        end

        if game.SinglePlayer() or IsFirstTimePredicted() then
            swepThinkVisualRecoil(self)
        end
    end
end

function SWEP:DoVisualRecoil()
    if !self:GetProcessedValue("UseVisualRecoil") then return end

    if isSingleplayer then self:CallOnClient("DoVisualRecoil") end

    -- if IsFirstTimePredicted() or isSingleplayer then
        local mult = self:GetProcessedValue("VisualRecoil")

        local up = self:GetProcessedValue("VisualRecoilUp") * mult

        if self:GetProcessedValue("RecoilLookupTable") then
            local dir = self:PatternWithRunOff(self:GetProcessedValue("RecoilLookupTable"), self:GetProcessedValue("RecoilLookupTableOverrun") or self:GetProcessedValue("RecoilLookupTable"), math.floor(self:GetRecoilAmount()) + 1)
            up = self:GetProcessedValue("VisualRecoilUp") * mult * self:GetRecoilUp() * -20 * (math.sin(math.rad(dir-90)) * -1)
        end

        local side = self:GetProcessedValue("VisualRecoilSide") * mult * self:GetRecoilSide()
        local roll = self:GetProcessedValue("VisualRecoilRoll") * math.Rand(-1, 1) * 0.1 * mult
        local punch = self:GetProcessedValue("VisualRecoilPunch") * mult * (self.ViewRecoil and math.Min(0.3, self:GetBurstCount() * 0.1) or 1)

        if self.VisualRecoilDoingFunc then
            up, side, roll, punch = self.VisualRecoilDoingFunc(up, side, roll, punch, self:GetRecoilAmount())
        end

        local fake = 0

        fake = self:GetProcessedValue("VisualRecoilPositionBump") or 1.5
        local bumpup = self:GetProcessedValue("VisualRecoilPositionBumpUp") or 0.08

        fake = Lerp(self:GetSightDelta(), fake, 1)

        if GetConVar("arc9_realrecoil"):GetBool() then
            self:SetVisualRecoilAng(self:GetVisualRecoilAng() + Angle(up, side * 15, roll))
            self:SetVisualRecoilPos(self:GetVisualRecoilPos() - ((Vector(0, punch, up * bumpup) * fake) - Vector(side, 0, 0)))
        end

        if IsFirstTimePredicted() or isSingleplayer then
            if CLIENT then
                self.VisualRecoilAng = self.VisualRecoilAng + Angle(up, side * 15, roll)
                self.VisualRecoilPos = self.VisualRecoilPos - ((Vector(0, punch, up * bumpup) * fake) - Vector(side, 0, 0))
            end
        end
    -- end
end

function SWEP:GetViewModelRecoil(pos, ang, correct)
    correct = correct or 1
    if !isSingleplayer and SERVER then return end
    if !self:GetProcessedValue("UseVisualRecoil") then return pos, ang end
    local vrc = self:GetProcessedValue("VisualRecoilCenter")

    local vra = Angle(self.VisualRecoilAng)

    vra.y = -vra.y

    pos, ang = self:RotateAroundPoint(pos, ang, vrc, self.VisualRecoilPos, vra * correct)

    if ARC9.Dev(2) then
        debugoverlay.Axis(self:GetVM():LocalToWorld(self:GetProcessedValue("VisualRecoilCenter")), ang, 2, 0.1, true)
    end

    return pos, ang
end

function SWEP:GetRecoilOffset(pos, ang)
    if !GetConVar("arc9_realrecoil"):GetBool() then return pos, ang end
    if !self:GetProcessedValue("UseVisualRecoil") then return pos, ang end

    local vrp = self:GetVisualRecoilPos()
    local vra = self:GetVisualRecoilAng()

    local vrc = self:GetProcessedValue("VisualRecoilCenter")

    pos, ang = self:RotateAroundPoint2(pos, ang, vrc, vrp, vra)

    return pos, ang
end