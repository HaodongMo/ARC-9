SWEP.RecoilPatternCache = {}

-- Unfortunately, this file is loaded before sh_stats,
-- so we do not know about this function at this time
local swepGetProcessedValue

local isSingleplayer = game.SinglePlayer()

function SWEP:GetRecoilPatternDirection(shot)
    local dir = 0

    local seed = self:GetProcessedValue("RecoilSeed", true) or self:GetClass()

    if isstring(seed) then
        local numseed = 0

        for _, i in ipairs(string.ToTable(seed)) do
            numseed = numseed + string.byte(i)
        end

        numseed = numseed % 16777216

        seed = numseed
    end

    seed = seed + shot

    if self:GetProcessedValue("RecoilLookupTable", true) then
        dir = self:PatternWithRunOff(self:GetProcessedValue("RecoilLookupTable", true), self:GetProcessedValue("RecoilLookupTableOverrun", true) or self:GetProcessedValue("RecoilLookupTable", true), shot)
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

    local pvrec = self:GetProcessedValue("Recoil")

    recoilup = recoilup * (pvrec or 0)
    recoilside = recoilside * (pvrec or 0)

    self:SetRecoilUp(recoilup)
    self:SetRecoilSide(recoilside)

    -- self:SetRecoilDirection(-90)
    self:SetRecoilAmount(rec)

    self:SetLastRecoilTime(CurTime())

    local pbf = self:GetProcessedValue("PushBackForce", true)

    local owner = self:GetOwner()

    if pbf != 0 then
        owner:SetVelocity(self:GetShootDir():Forward() * -pbf)
    end

    local vis_kick = self:GetProcessedValue("RecoilKick")
    local vis_shake = 0

    vis_kick = vis_kick * rps
    vis_shake = vis_kick * rps

    local vis_kick_v = vis_kick * 0.5
    local vis_kick_h = vis_kick * util.SharedRandom("ARC9_vis_kick_h", -1, 1)
    vis_shake = vis_shake * util.SharedRandom("ARC9_vis_kick_shake", -1, 1)

    -- owner:SetViewPunchAngles(Angle(vis_kick_v, vis_kick_h, vis_shake))

    owner:SetFOV(owner:GetFOV() * 0.99, 0)
    owner:SetFOV(0, 60 / (self:GetProcessedValue("RPM")))
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
        local ft = FrameTime()
        local swepDt = self.dt
        local firstTimePredicted = IsFirstTimePredicted()
        local baseFramerate = 30

        ft = math_Clamp(ft, 0, 1 / baseFramerate)

        local springconstant = swepGetProcessedValue(self, "VisualRecoilDampingConst", true) or 120
        local VisualRecoilSpringMagnitude = swepGetProcessedValue(self, "VisualRecoilSpringMagnitude", true) or 1
        local PUNCH_DAMPING = swepGetProcessedValue(self, "VisualRecoilSpringPunchDamping", true) or 6

        if self.VisualRecoilThinkFunc then
            springconstant, VisualRecoilSpringMagnitude, PUNCH_DAMPING = self.VisualRecoilThinkFunc(springconstant, VisualRecoilSpringMagnitude, PUNCH_DAMPING, self:GetRecoilAmount())
        end

        local realmDataHolder = CLIENT and self or swepDt

        local vpa = realmDataHolder.VisualRecoilPos
        local vpv = realmDataHolder.VisualRecoilPosVel

        if twoLenSqr(vpa, vpv) > 0 then
            local damping = 1 - (math.pow(POS_PUNCH_DAMPING, ft / baseFramerate))

            if damping < 0 then damping = 0 end

            local springforcemagnitude = math.pow(POS_PUNCH_CONSTANT * VisualRecoilSpringMagnitude, ft  / baseFramerate)

            vectorSub(vpv, vpa * springforcemagnitude)
            vectorAdd(vpa, vpv * ft)
            vectorMul(vpv, damping)

            for i = 1, 3 do
                vpa[i] = math_Clamp(vpa[i], -8, 8)
                vpv[i] = math_Clamp(vpv[i], -100, 100)
            end
            
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
            
        if twoLenSqr(vaa, vav) > 0 then

            local damping = 1 - (math.pow(PUNCH_DAMPING, ft / baseFramerate))

            if damping < 0 then damping = 0 end
            
            local springforcemagnitude = math.pow(springconstant, ft  / baseFramerate)

            angleSub(vav, vaa * springforcemagnitude)
            angleAdd(vaa, vav * ft)
            angleMul(vav, damping)

            for i = 1, 3 do
                vaa[i] = math_Clamp(vaa[i], -90, 90)
                vav[i] = math_Clamp(vav[i], -90, 90)
            end

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

            -- if CLIENT and (isSingleplayer or firstTimePredicted) then
            if CLIENT then
                self.VisualRecoilAng = recoilZeroAng
                self.VisualRecoilVel = velocityZeroAng
            end
        end
    end
end

do
    local weaponGetNextPrimaryFire = FindMetaTable("Weapon").GetNextPrimaryFire
    local swepThinkVisualRecoil = SWEP.ThinkVisualRecoil

    local smolnumber = 1e-5

    function SWEP:ThinkRecoil()
        local ru = self.dt.RecoilUp
        local rs = self.dt.RecoilSide

        swepGetProcessedValue = swepGetProcessedValue or self.GetProcessedValue

        if isSingleplayer or IsFirstTimePredicted() then
            swepThinkVisualRecoil(self)
        end

        if math.abs(ru) < smolnumber and math.abs(rs) < smolnumber and self.dt.RecoilAmount == 0 then return end

        local rdr = swepGetProcessedValue(self, "RecoilDissipationRate")
        local ct = CurTime()
        local ft = FrameTime()

        if (weaponGetNextPrimaryFire(self) + swepGetProcessedValue(self, "RecoilResetTime", true)) < ct then
            -- as soon as dissipation kicks in, recoil is clamped to the modifer cap; this is to not break visual recoil
            self:SetRecoilAmount(math.Clamp(self.dt.RecoilAmount - (ft * rdr), 0, swepGetProcessedValue(self, "UseVisualRecoil", true) and math.huge or swepGetProcessedValue(self, "RecoilModifierCap", true)))
            if weaponGetNextPrimaryFire(self) + swepGetProcessedValue(self, "RecoilFullResetTime", true) < ct then
                self:SetRecoilAmount(0)
            end
            -- print(math.Round(rec))
        end

        if math.abs(ru) > smolnumber or math.abs(rs) > smolnumber then
            local new_ru = ru - (ft * ru * 10)
            local new_rs = rs - (ft * rs * 10)

            self:SetRecoilUp(new_ru)
            self:SetRecoilSide(new_rs)
        end

    end
end

local lastrft = 0
local realrecoilconvar = GetConVar("arc9_realrecoil")

function SWEP:DoVisualRecoil()
    if !self:GetProcessedValue("UseVisualRecoil", true) then return end

    if isSingleplayer then self:CallOnClient("DoVisualRecoil") end

    -- if IsFirstTimePredicted() or isSingleplayer then
        local mult = self:GetProcessedValue("VisualRecoil")

        local up = self:GetProcessedValue("VisualRecoilUp") * mult

        if self:GetProcessedValue("RecoilLookupTable", true) then
            local dir = self:PatternWithRunOff(self:GetProcessedValue("RecoilLookupTable", true), self:GetProcessedValue("RecoilLookupTableOverrun", true) or self:GetProcessedValue("RecoilLookupTable", true), math.floor(self:GetRecoilAmount()) + 1)
            up = up * self:GetRecoilUp() * -20 * (math.sin(math.rad(dir-90)) * -1)
        end

        local side = self:GetProcessedValue("VisualRecoilSide") * mult * self:GetRecoilSide()
        local roll = self:GetProcessedValue("VisualRecoilRoll") * math.Rand(-1, 1) * 0.1 * mult
        local punch = self:GetProcessedValue("VisualRecoilPunch") * mult * (self.ViewRecoil and math.Min(0.3, self:GetBurstCount() * 0.1) or 1)

        if self.VisualRecoilDoingFunc then
            up, side, roll, punch = self.VisualRecoilDoingFunc(up, side, roll, punch, self:GetRecoilAmount())
        end

        local fake = 0

        fake = self:GetProcessedValue("VisualRecoilPositionBump", true) or 1.5

        local isRTscoped = CLIENT and self:GetSight() and self:GetSight().atttbl and self:GetSight().atttbl.RTScope -- horible

        local bumpup = (isRTscoped and self:GetProcessedValue("VisualRecoilPositionBumpUpRTScope", true) or self:GetProcessedValue("VisualRecoilPositionBumpUp", true)) or 0.08

        fake = Lerp(self:GetSightDelta(), fake, 1)

        if CLIENT then
            -- if !isSingleplayer then awfulnumber = 1.2 end
            fake = fake * 0.66
        end

        if realrecoilconvar:GetBool() then
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
    if !self:GetProcessedValue("UseVisualRecoil", true) then return pos, ang end
    local vrc = self:GetProcessedValue("VisualRecoilCenter", true)

    local vra = Angle(self.VisualRecoilAng)

    vra.y = -vra.y

    pos, ang = self:RotateAroundPoint(pos, ang, vrc, self.VisualRecoilPos, vra * correct)

    if ARC9.Dev(2) then
        debugoverlay.Axis(self:GetVM():LocalToWorld(self:GetProcessedValue("VisualRecoilCenter", true)), ang, 2, 0.1, true)
    end

    return pos, ang
end


function SWEP:GetRecoilOffset(pos, ang)
    if !realrecoilconvar:GetBool() then return pos, ang end
    if !self:GetProcessedValue("UseVisualRecoil", true) then return pos, ang end

    local vrp = self:GetVisualRecoilPos()
    local vra = self:GetVisualRecoilAng()

    local vrc = self:GetProcessedValue("VisualRecoilCenter", true)

    pos, ang = self:RotateAroundPoint2(pos, ang, vrc, vrp, vra)

    return pos, ang
end