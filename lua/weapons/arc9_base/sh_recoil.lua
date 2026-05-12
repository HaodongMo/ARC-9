SWEP.RecoilPatternCache = {}

local swepGetProcessedValue = SWEP.GetProcessedValue

local isSingleplayer = game.SinglePlayer()
local isDedi = game.IsDedicated()

function SWEP:GetRecoilPatternDirection(shot)
    local dir = 0

    local seed = swepGetProcessedValue(self, "RecoilSeed", true) or self:GetClass()

    if isstring(seed) then
        local numseed = 0

        for _, i in ipairs(string.ToTable(seed)) do
            numseed = numseed + string.byte(i)
        end

        numseed = numseed % 16777216

        seed = numseed
    end

    seed = seed + shot

    if swepGetProcessedValue(self, "RecoilLookupTable", true) then
        dir = self:PatternWithRunOff(swepGetProcessedValue(self, "RecoilLookupTable", true), swepGetProcessedValue(self, "RecoilLookupTableOverrun", true) or swepGetProcessedValue(self, "RecoilLookupTable", true), shot)
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

local recoilshake = GetConVar("arc9_recoilshake")

function SWEP:ApplyRecoil()
    local rec = self:GetRecoilAmount()

    local rps = swepGetProcessedValue(self, "RecoilPerShot")

    rec = math.Clamp(rec + rps, 0, swepGetProcessedValue(self, "RecoilMax", true) or math.huge)

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

    recoilup = recoilup * swepGetProcessedValue(self, "RecoilUp")
    recoilside = recoilside * swepGetProcessedValue(self, "RecoilSide")

    randomrecoilup = randomrecoilup * swepGetProcessedValue(self, "RecoilRandomUp")
    randomrecoilside = randomrecoilside * swepGetProcessedValue(self, "RecoilRandomSide")

    recoilup = recoilup + randomrecoilup
    recoilside = recoilside + randomrecoilside

    local pvrec = swepGetProcessedValue(self, "Recoil")

    recoilup = recoilup * (pvrec or 0)
    recoilside = recoilside * (pvrec or 0)

    self:SetRecoilUp(recoilup)
    self:SetRecoilSide(recoilside)

    -- self:SetRecoilDirection(-90)
    self:SetRecoilAmount(rec)

    self:SetLastRecoilTime(CurTime())

    local pbf = swepGetProcessedValue(self, "PushBackForce", true)

    local owner = self:GetOwner()

    if pbf != 0 then
        owner:SetVelocity(self:GetShootDir():Forward() * -pbf)
    end

    -- local vis_kick = swepGetProcessedValue(self, "RecoilKick")
    -- local vis_shake = 0

    -- vis_kick = vis_kick * rps
    -- vis_shake = vis_kick * rps

    -- local vis_kick_v = vis_kick * 0.5
    -- local vis_kick_h = vis_kick * util.SharedRandom("ARC9_vis_kick_h", -1, 1)
    -- vis_shake = vis_shake * util.SharedRandom("ARC9_vis_kick_shake", -1, 1)

    -- owner:SetViewPunchAngles(Angle(vis_kick_v, vis_kick_h, vis_shake))

    if recoilshake:GetBool() then
        owner:SetFOV(owner:GetFOV() * 0.99, 0)
        owner:SetFOV(0, 60 / (swepGetProcessedValue(self, "RPM")))
    end
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

    local function vectorTranspose(ang)
        return Vector(ang[1], ang[2], ang[3])
    end

    local function angleTranspose(vec)
        return Angle(vec[1], vec[2], vec[3])
    end

    local weirdfix = true

    function SWEP:ThinkVisualRecoil()
        --if SERVER and !self.PhysicalVisualRecoil then return end

        local MAGIC1 = 210
        local MAGIC2 = 210

        local ft = CLIENT and RealFrameTime() or FrameTime()
        if ft == 0 then return end -- game is paused

        if weirdfix then
            -- MAGIC1 = 210 / (engine.TickInterval() / 0.015)
            -- MAGIC2 = 210 / (engine.TickInterval() / 0.015)
            MAGIC1 = math.min(MAGIC1, 210 / (ft / 0.015))
            MAGIC2 = math.min(MAGIC2, 210 / (ft / 0.015))
        end
        
        if CLIENT and ft > 0.09 then -- super lag detected, clamping recoil
            MAGIC1 = 0.1
            MAGIC2 = 0.1
        end
        
        local springconstant = swepGetProcessedValue(self, "VisualRecoilDampingConst", true) or 120
        local springmagnitude = swepGetProcessedValue(self, "VisualRecoilSpringMagnitude", true) or 1
        local springdamping = swepGetProcessedValue(self, "VisualRecoilSpringPunchDamping", true) or 6

        if self.VisualRecoilThinkFunc then
            springconstant, springmagnitude, springdamping = self.VisualRecoilThinkFunc(springconstant, springmagnitude, springdamping, self:GetRecoilAmount())
        end

        local vpa = self:GetVisualRecoilPos()
        local vpv = self:GetVisualRecoilPosVel()
        local vpc = self:GetVisualRecoilPosAcc()

        vpa = vpa + (vpv * ft) + (vpc * ft * ft * 0.5)
        local vpdrag = -(vpv * vpv:Length() * 0.5)
        local vpreturn = (-vpa * vpa:Length() * springconstant) + (-vpa / vpa:Length() * springmagnitude) + (-vpv * springdamping)
        local new_vpc = vpdrag + vpreturn
        vpv = vpv + ((vpc + new_vpc) * (ft * 0.5))

        for i = 1, 3 do
            vpa[i] = math_Clamp(vpa[i], -MAGIC1, MAGIC1)
            vpv[i] = math_Clamp(vpv[i], -MAGIC1, MAGIC1)
            new_vpc[i] = math_Clamp(new_vpc[i], -MAGIC1, MAGIC1)
        end

        self:SetVisualRecoilPos(vpa)
        self:SetVisualRecoilPosAcc(new_vpc)
        self:SetVisualRecoilPosVel(vpv)

        -- New spring algorithm using the velocity Verlet integration

        local vaa = self:GetVisualRecoilAng()
        local vav = self:GetVisualRecoilVel()
        local vac = self:GetVisualRecoilAcc()

        vaa = vaa + (vav * ft) + (vac * ft * ft * 0.5)
        local vdrag = -(vav * vav:Length() * 0.5)
        local vreturn = (-vaa * vaa:Length() * springconstant) + (-vaa / vaa:Length() * springmagnitude) + (-vav * springdamping)
        local new_vac = vdrag + vreturn
        vav = vav + ((vac + new_vac) * (ft * 0.5))

        for i = 1, 3 do
            vaa[i] = math_Clamp(vaa[i], -MAGIC2, MAGIC2)
            vav[i] = math_Clamp(vav[i], -MAGIC2, MAGIC2)
            new_vac[i] = math_Clamp(new_vac[i], -MAGIC2, MAGIC2)
        end

        self:SetVisualRecoilAng(vaa)
        self:SetVisualRecoilAcc(new_vac)
        self:SetVisualRecoilVel(vav)




        -- SUBTLE RECOIL MOVEMENT
        if CLIENT and self.SubtleVisualRecoil and (self:GetLastRecoilTime() + 0.75 > CurTime()) then
            local springconstant2 = 150 * (self.SubtleVisualRecoilSpeed or 1)
            local springmagnitude2 = 0.3
            local springdamping2 = 2.8

            if !isSingleplayer then -- mmm
                local ping = LocalPlayer():Ping() -- retarded
                if isDedi then ping = ping + 5 end
                
                if ping > 9 then
                    springconstant2 = springconstant2 * 1
                    springdamping2 = springdamping2 * 3
                else
                    springconstant2 = springconstant2 * 15
                    springdamping2 = springdamping2 * 10
                end
            end
    
            -- if self.VisualRecoilThinkFunc then
            --     springconstant2, springmagnitude2, springdamping2 = self.VisualRecoilThinkFunc(springconstant2, springmagnitude2, springdamping2, self:GetRecoilAmount())
            -- end
    
            local vpa2 = self.SubtleVisualRecoilPos
            local vpv2 = self.SubtleVisualRecoilPosVel
            local vpc2 = self.SubtleVisualRecoilPosAcc
    
            vpa2 = vpa2 + (vpv2 * ft) + (vpc2 * ft * ft * 0.5)
            local vpdrag2 = -(vpv2 * vpv2:Length() * 0.5)
            local vpreturn2 = (-vpa2 * vpa2:Length() * springconstant2) + (-vpa2 / vpa2:Length() * springmagnitude2) + (-vpv2 * springdamping2)
            local new_vpc2 = vpdrag2 + vpreturn2
            vpv2 = vpv2 + ((vpc2 + new_vpc2) * (ft * 0.5))
    
            for i = 1, 3 do
                vpa2[i] = math_Clamp(vpa2[i], -MAGIC1, MAGIC1)
                vpv2[i] = math_Clamp(vpv2[i], -MAGIC1, MAGIC1)
                new_vpc2[i] = math_Clamp(new_vpc2[i], -MAGIC1, MAGIC1)
            end
    
            self.SubtleVisualRecoilPos = vpa2
            self.SubtleVisualRecoilPosAcc = new_vpc2
            self.SubtleVisualRecoilPosVel = vpv2
    
            -- New spring algorithm using the velocity Verlet integration
    
            local vaa2 = self.SubtleVisualRecoilAng
            local vav2 = self.SubtleVisualRecoilVel
            local vac2 = self.SubtleVisualRecoilAcc

            vaa2 = vaa2 + (vav2 * ft) + (vac2 * ft * ft * 0.5)
            local vdrag2 = -(vav2 * vav2:Length() * 0.5)
            local vreturn2 = (-vaa2 * vaa2:Length() * springconstant2) + (-vaa2 / vaa2:Length() * springmagnitude2) + (-vav2 * springdamping2)
            local new_vac2 = vdrag2 + vreturn2
            vav2 = vav2 + ((vac2 + new_vac2) * (ft * 0.5))
            
            vaa2.x = vaa2.x * 0.25

            for i = 1, 3 do
                vaa2[i] = math_Clamp(vaa2[i], -MAGIC2, MAGIC2)
                vav2[i] = math_Clamp(vav2[i], -MAGIC2, MAGIC2)
                new_vac2[i] = math_Clamp(new_vac2[i], -MAGIC2, MAGIC2)
            end
            
            self.SubtleVisualRecoilAng = vaa2
            self.SubtleVisualRecoilAcc = new_vac2
            self.SubtleVisualRecoilVel = vav2

            self:SetVisualRecoilPos(vpa + vpa2)
            self:SetVisualRecoilPosAcc(new_vpc + new_vpc2)
            self:SetVisualRecoilPosVel(vpv + vpv2)

            self:SetVisualRecoilAng(vaa + vaa2)
            self:SetVisualRecoilAcc(new_vac + new_vac2)
            self:SetVisualRecoilVel(vav + vav2)
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


		swepThinkVisualRecoil(self)

        if math.abs(ru) < smolnumber and math.abs(rs) < smolnumber and self.dt.RecoilAmount == 0 then return end

        local rdr = swepGetProcessedValue(self, "RecoilDissipationRate", true)
        local ct = CurTime()
        local ft = FrameTime()

        if (weaponGetNextPrimaryFire(self) + swepGetProcessedValue(self, "RecoilResetTime", true)) < ct then
            -- as soon as dissipation kicks in, recoil is clamped to the modifer cap; this is to not break visual recoil
            self:SetRecoilAmount(math.Clamp(self.dt.RecoilAmount - (ft * rdr), 0, swepGetProcessedValue(self, "UseVisualRecoil", true) and math.huge or swepGetProcessedValue(self, "RecoilModifierCap")))
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

SWEP.SubtleVisualRecoilPos = Vector(0, 0, 0)
SWEP.SubtleVisualRecoilPosAcc = Vector(0, 0, 0)
SWEP.SubtleVisualRecoilPosVel = Vector(0, 0, 0)
SWEP.SubtleVisualRecoilAng = Vector(0, 0, 0)
SWEP.SubtleVisualRecoilAcc = Vector(0, 0, 0)
SWEP.SubtleVisualRecoilVel = Vector(0, 0, 0)

local randdirectstable = { -1.35, -1.25, -1.125, -1, -0.75, -0.75, 0.75, 0.75, 1, 1.125, 1.25, 1.35 } -- regular random will provide near zero values most of the time
local randuptable = { 0.1, 0.125, 0.15, 0.175, 0.2 }

function SWEP:DoSubtleVisualRecoil(mult) -- cl only
    if SERVER or !self.SubtleVisualRecoil then return end
    
    mult = self.SubtleVisualRecoil * 0.75
    local upp = randuptable[math.random(#randuptable)]
    if !self:GetInSights() then mult = mult * (self.SubtleVisualRecoilHipFire or 2) end
    local funnynumber = 1.3 - math.min(self:GetRecoilAmount(), 4.5) / 4.5

    if !isSingleplayer then 
        local ping = LocalPlayer():Ping()
        if isDedi then ping = ping + 5 end
        if ping > 9 then
            mult = mult * math.Clamp(0.5 - ping * 0.004, 0.25, 0.5)
        end
        -- 0 = 1
        -- 1 = 0.5
        -- 40 = 0.3
        -- 80 = 0.25
    end

    self.SubtleVisualRecoilPos = self.SubtleVisualRecoilPos + Vector(math.Rand(-0.05, 0.03), -1.0, math.Rand(-0.06, 0.03)) * mult
    self.SubtleVisualRecoilAng = self.SubtleVisualRecoilAng + Vector(upp, 0, (self.SubtleVisualRecoilDirection or 0) * funnynumber + randdirectstable[math.random(#randdirectstable)]) * mult
end

function SWEP:DoVisualRecoil()
    if !swepGetProcessedValue(self, "UseVisualRecoil", true) then return end

    if isSingleplayer then self:CallOnClient("DoVisualRecoil") end

    if isSingleplayer or (!isSingleplayer and (SERVER or (CLIENT and IsFirstTimePredicted()))) then
        local mult = swepGetProcessedValue(self, "VisualRecoil")

        local up = swepGetProcessedValue(self, "VisualRecoilUp") * mult

        if swepGetProcessedValue(self, "RecoilLookupTable", true) then
            local dir = self:PatternWithRunOff(swepGetProcessedValue(self, "RecoilLookupTable", true), swepGetProcessedValue(self, "RecoilLookupTableOverrun", true) or swepGetProcessedValue(self, "RecoilLookupTable", true), math.floor(self:GetRecoilAmount()) + 1)
            up = up * self:GetRecoilUp() * -20 * (math.sin(math.rad(dir-90)) * -1)
        end

        local side = swepGetProcessedValue(self, "VisualRecoilSide") * mult * self:GetRecoilSide()
        local roll = swepGetProcessedValue(self, "VisualRecoilRoll") * util.SharedRandom("ARC9VisualRecoil", -1, 1) * 0.1 * mult
        local punch = swepGetProcessedValue(self, "VisualRecoilPunch") * mult

        if self.VisualRecoilDoingFunc then
            up, side, roll, punch = self.VisualRecoilDoingFunc(up, side, roll, punch, self:GetRecoilAmount(), self)
        end

        local fake = swepGetProcessedValue(self, "VisualRecoilPositionBump", true) or 1.5

        local bumpup = (self:IsUsingRTScope() and self.VisualRecoilPositionBumpUpRTScope or swepGetProcessedValue(self, "VisualRecoilPositionBumpUp")) or 0.08

        fake = Lerp(self:GetSightDelta(), fake, 1)

        fake = fake * 0.66

        if self.PhysicalVisualRecoilForce or realrecoilconvar:GetBool() then
            self:SetVisualRecoilAng(self:GetVisualRecoilAng() + Vector(up, side * 15, roll))
            self:SetVisualRecoilPos(self:GetVisualRecoilPos() - ((Vector(0, punch, up * bumpup) * fake) - Vector(side, 0, 0)))
        end

        self:DoSubtleVisualRecoil(mult)
    end
end

local magicmult = 2.5

function SWEP:GetViewModelRecoil(pos, ang, correct)
    correct = correct or 1
    if !isSingleplayer and SERVER then return end
    if !swepGetProcessedValue(self, "UseVisualRecoil", true) then return pos, ang end
    local vrc = swepGetProcessedValue(self, "VisualRecoilCenter", true)
    local vrc2 = Vector(vrc)

    local vra = self:GetVisualRecoilAng()
    if !isSingleplayer then vra = vra + self.SubtleVisualRecoilAng end

    vra = Angle(vra[1], vra[2], vra[3]) * (self.VisualRecoilEmergency or magicmult)

    vra.y = -vra.y
    
    local correct2 = math.max(1, correct)
    local altvra = vra * correct2
    altvra.z = vra.z * 0.3

    local visrecpos = self:GetVisualRecoilPos()
    if !isSingleplayer then visrecpos = visrecpos + self.SubtleVisualRecoilPos end
    
    vrc2.y = vrc.y / math.max(1, correct2)
    
    visrecpos.y = visrecpos.y / math.max(1, correct2)
    
    pos, ang = self:RotateAroundPoint(pos, ang, vrc2, visrecpos, altvra)

    -- if ARC9.Dev(2) then
    --     debugoverlay.Axis(self:GetVM():LocalToWorld(swepGetProcessedValue(self, "VisualRecoilCenter", true)), ang, 2, 0.1, true)
    -- end

    return pos, ang
end


function SWEP:GetRecoilOffset(pos, ang)
    if !self.PhysicalVisualRecoilForce and (!self.PhysicalVisualRecoil or !realrecoilconvar:GetBool()) then return pos, ang end
    if !swepGetProcessedValue(self, "UseVisualRecoil", true) then return pos, ang end

    local vrp = self:GetVisualRecoilPos()
    local vra = self:GetVisualRecoilAng()

    vra = Angle(vra[1], vra[2], vra[3]) * magicmult

    local vrc = swepGetProcessedValue(self, "VisualRecoilCenter", true)

    pos, ang = self:RotateAroundPoint2(pos, ang, vrc, vrp, vra)

    return pos, ang
end