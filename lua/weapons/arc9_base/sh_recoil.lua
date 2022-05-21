function SWEP:ThinkRecoil()
    local rdr = self:GetProcessedValue("RecoilDissipationRate")

    if (self:GetLastRecoilTime() + self:GetProcessedValue("RecoilResetTime")) < CurTime() then
        local rec = self:GetRecoilAmount()

        rec = rec - (FrameTime() * rdr)

        self:SetRecoilAmount(math.max(rec, 0))
    end

    local ru = self:GetRecoilUp()
    local rs = self:GetRecoilSide()

    if math.abs(ru) > 0 or math.abs(rs) > 0 then
        local new_ru = ru - (FrameTime() * self:GetRecoilUp() * rdr)
        local new_rs = rs - (FrameTime() * self:GetRecoilSide() * rdr)

        self:SetRecoilUp(new_ru)
        self:SetRecoilSide(new_rs)
    end

    self:ThinkVisualRecoil()
end

SWEP.RecoilPatternCache = {}

function SWEP:ApplyRecoil()
    local rec = self:GetRecoilAmount()

    local rps = 1

    rec = rec + rps
    -- local delay = 60 / self:GetProcessedValue("RPM")

    local recoilup = 1
    local recoilside = 0

    local seed = self:GetProcessedValue("RecoilSeed") or self:GetClass()
    local shot = math.floor(self:GetRecoilAmount()) + 1

    if isstring(seed) then
        local numseed = 0

        for _, i in ipairs(string.ToTable(seed)) do
            numseed = numseed + string.byte(i)
        end

        numseed = numseed % 16777216

        seed = numseed
    end

    seed = seed + shot

    local dir = 0

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

    recoilup = recoilup * self:GetProcessedValue("Recoil")
    recoilside = recoilside * self:GetProcessedValue("Recoil")

    self:SetRecoilUp(recoilup)
    self:SetRecoilSide(recoilside)

    -- self:SetRecoilDirection(-90)
    self:SetRecoilAmount(rec)

    self:SetLastRecoilTime(CurTime())

    local pbf = self:GetProcessedValue("PushBackForce")

    if pbf != 0 then
        self:GetOwner():SetVelocity(self:GetShootDir():Forward() * -pbf)
    end

    -- local vis_kick = self:GetProcessedValue("RecoilKick")
    -- local vis_shake = 0

    -- vis_kick = vis_kick * rps
    -- vis_shake = vis_kick * rps

    -- local vis_kick_v = vis_kick * 0.5
    -- local vis_kick_h = vis_kick * util.SharedRandom("ARC9_vis_kick_h", -1, 1)
    -- vis_shake = vis_shake * util.SharedRandom("ARC9_vis_kick_shake", -1, 1)

    -- self:GetOwner():SetViewPunchAngles(Angle(vis_kick_v, vis_kick_h, vis_shake))

    -- self:GetOwner():SetFOV(self:GetOwner():GetFOV() * 0.99, 0)
    -- self:GetOwner():SetFOV(0, 60 / (self:GetProcessedValue("RPM")))
end

local function lensqr(ang)
    return (ang[1] ^ 2) + (ang[2] ^ 2) + (ang[3] ^ 2)
end

-- scraped from source SDK 2013, just like this viewpunch damping code
local PUNCH_DAMPING = 5
local PUNCH_SPRING_CONSTANT = 120
local POS_PUNCH_DAMPING = 6
local POS_PUNCH_CONSTANT = 90

local ang0 = Angle(0, 0, 0)
local vec0 = Vector(0, 0, 0)

SWEP.VisualRecoilPos = Vector(0, 0, 0)
SWEP.VisualRecoilPosVel = Vector(0, 0, 0)
SWEP.VisualRecoilAng = Angle(0, 0, 0)
SWEP.VisualRecoilVel = Angle(0, 0, 0)

function SWEP:ThinkVisualRecoil()
    if game.SinglePlayer() and SERVER then self:CallOnClient("ThinkVisualRecoil") end

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

    local vpa = self.VisualRecoilPos
    local vpv = self.VisualRecoilPosVel
    PUNCH_SPRING_CONSTANT = self.VisualRecoilDampingConst or 120
    VisualRecoilSpringMagnitude = self.VisualRecoilSpringMagnitude or 1

    if lensqr(vpa) + lensqr(vpv) > 0.000001 then
        -- {
        --     player->m_Local.m_vecPunchAngle += player->m_Local.m_vecPunchAngleVel * gpGlobals->frametime;
        --     float damping = 1 - (PUNCH_DAMPING * gpGlobals->frametime);

        local ft = FrameTime()

        vpa = vpa + (vpv * ft)
        local damping = 1 - (POS_PUNCH_DAMPING * ft)

        --     if ( damping < 0 )
        --     {
        --         damping = 0;
        --     }

        if damping < 0 then damping = 0 end

        --     player->m_Local.m_vecPunchAngleVel *= damping;

        vpv = vpv * damping

        --     // torsional spring
        --     // UNDONE: Per-axis spring constant?
        --     float springForceMagnitude = PUNCH_SPRING_CONSTANT * gpGlobals->frametime;
        local springforcemagnitude = POS_PUNCH_CONSTANT * ft * VisualRecoilSpringMagnitude
        --     springForceMagnitude = clamp(springForceMagnitude, 0.f, 2.f );
        springforcemagnitude = math.Clamp(springforcemagnitude, 0, 2)
        --     player->m_Local.m_vecPunchAngleVel -= player->m_Local.m_vecPunchAngle * springForceMagnitude;
        vpv = vpv - (vpa * springforcemagnitude)

        --     // don't wrap around
        --     player->m_Local.m_vecPunchAngle.Init( 
        --         clamp(player->m_Local.m_vecPunchAngle->x, -89.f, 89.f ), 
        --         clamp(player->m_Local.m_vecPunchAngle->y, -179.f, 179.f ),
        --         clamp(player->m_Local.m_vecPunchAngle->z, -89.f, 89.f ) );
        -- }

        vpa[1] = math.Clamp(vpa[1], -89.9, 89.9)
        vpa[2] = math.Clamp(vpa[2], -179.9, 179.9)
        vpa[3] = math.Clamp(vpa[3], -89.9, 89.9)

        self.VisualRecoilPos = vpa
        self.VisualRecoilPosVel = vpv
    else
        self.VisualRecoilPos = vec0
        self.VisualRecoilPosVel = vec0
    end

    local vaa = self.VisualRecoilAng
    local vav = self.VisualRecoilVel

    if lensqr(vaa) + lensqr(vav) > 0.000001 then
        -- {
        --     player->m_Local.m_vecPunchAngle += player->m_Local.m_vecPunchAngleVel * gpGlobals->frametime;
        --     float damping = 1 - (PUNCH_DAMPING * gpGlobals->frametime);

        local ft = FrameTime()

        vaa = vaa + (vav * ft)
        local damping = 1 - (PUNCH_DAMPING * ft)

        --     if ( damping < 0 )
        --     {
        --         damping = 0;
        --     }

        if damping < 0 then damping = 0 end

        --     player->m_Local.m_vecPunchAngleVel *= damping;

        vav = vav * damping

        --     // torsional spring
        --     // UNDONE: Per-axis spring constant?
        --     float springForceMagnitude = PUNCH_SPRING_CONSTANT * gpGlobals->frametime;
        local springforcemagnitude = PUNCH_SPRING_CONSTANT * ft
        --     springForceMagnitude = clamp(springForceMagnitude, 0.f, 2.f );
        springforcemagnitude = math.Clamp(springforcemagnitude, 0, 2)
        --     player->m_Local.m_vecPunchAngleVel -= player->m_Local.m_vecPunchAngle * springForceMagnitude;
        vav = vav - (vaa * springforcemagnitude)

        --     // don't wrap around
        --     player->m_Local.m_vecPunchAngle.Init( 
        --         clamp(player->m_Local.m_vecPunchAngle->x, -89.f, 89.f ), 
        --         clamp(player->m_Local.m_vecPunchAngle->y, -179.f, 179.f ),
        --         clamp(player->m_Local.m_vecPunchAngle->z, -89.f, 89.f ) );
        -- }

        vaa[1] = math.Clamp(vaa[1], -89.9, 89.9)
        vaa[2] = math.Clamp(vaa[2], -179.9, 179.9)
        vaa[3] = math.Clamp(vaa[3], -89.9, 89.9)

        self.VisualRecoilAng = vaa
        self.VisualRecoilVel = vav
    else
        self.VisualRecoilAng = Angle(ang0)
        self.VisualRecoilVel = Angle(ang0)
    end
end

SWEP.FOV_Recoil = 0
SWEP.FOV_RecoilMods = {}

function SWEP:CreateFOVEvent( fov, start, endt, fpre, fact )
    table.insert(self.FOV_RecoilMods, {
        amount = fov,
        time_start = CurTime() + start,
        time_end = CurTime() + endt,
        func_pre = fpre,
        func_act = fact,
        realstart = CurTime(),
    })
end

function SWEP:DoVisualRecoil()
    if !self:GetProcessedValue("UseVisualRecoil") then return end

    if game.SinglePlayer() then self:CallOnClient("DoVisualRecoil") end
    if self.FOV_RecoilAdd and self.FOV_RecoilAdd != 0 then
        self:CreateFOVEvent(
            self.FOV_RecoilAdd,
            self.FOV_Recoil_TimeStart,
            self.FOV_Recoil_TimeEnd,
            self.FOV_Recoil_FuncStart,
            self.FOV_Recoil_FuncEnd
        )
    end

    if IsFirstTimePredicted() or game.SinglePlayer() then
        -- Completely unnecessary; use VisualRecoilMultSights
        -- local adsmult = (1 - (self:GetSightAmount() * (1 - (self:GetProcessedValue("VisualRecoilADSMult") or 1))))
        -- local punchadsmult = (1 - (self:GetSightAmount() * (1 - (self:GetProcessedValue("VisualRecoilPunchADSMult") or 1))))

        -- Should literally just be VisualRecoil for VisualRecoilAdd, VisualRecoilHook, etc
        local mult = self:GetProcessedValue("VisualRecoilMult")

        local up = self:GetProcessedValue("VisualRecoilUp") * mult
        local side = self:GetProcessedValue("VisualRecoilSide") * math.Rand(-1, 1) * mult
        local roll = self:GetProcessedValue("VisualRecoilRoll") * math.Rand(-1, 1) * mult
        local punch = self:GetProcessedValue("VisualRecoilPunch") * mult * (self.EFTRecoil and math.Min(0.3, self:GetBurstCount() * 0.05) or 1)
        -- self.VisualRecoilPos = self.VisualRecoilPos + Vector(side, -punch, up)
        -- self.VisualRecoilAng = self.VisualRecoilAng + Angle(0, 0, roll)

        -- if self:GetSightAmount() > 0 then
        --     self.VisualRecoilPos.x = math.Clamp(self.VisualRecoilPos.x, -0.1, 0.1)
        --     self.VisualRecoilPos.y = math.Clamp(self.VisualRecoilPos.y, -0.5, 0)
        --     self.VisualRecoilPos.z = math.Clamp(self.VisualRecoilPos.z, 0, 0.25)
        -- end

        local fake = 0

        if self:GetProcessedValue("VisualRecoilHipFire") then
            fake = 1.5
        end

        fake = Lerp(self:GetSightDelta(), fake, 1)

        self.VisualRecoilAng = self.VisualRecoilAng + Angle(up * fake, side * 15, roll)
        self.VisualRecoilPos = self.VisualRecoilPos - (Vector(0, punch, up / 12.5) * fake) - Vector(side, 0, 0)
    end
end

function SWEP:GetViewModelRecoil(pos, ang)
    if !self:GetProcessedValue("UseVisualRecoil") then return pos, ang end
    local vrc = self:GetProcessedValue("VisualRecoilCenter")

    -- v = v + (vrc.x * ang:Right())
    -- v = v + (vrc.y * ang:Forward())
    -- v = v + (vrc.z * ang:Up())

    -- ang:RotateAroundAxis(ang:Right(), self.VisualRecoilAng.p)
    -- ang:RotateAroundAxis(ang:Forward(), self.VisualRecoilAng.r)

    -- v = v + ang:Right() * self.VisualRecoilPos.x
    -- v = v + ang:Forward() * self.VisualRecoilPos.y
    -- v = v + ang:Up() * self.VisualRecoilPos.z

    -- v:Rotate(self.VisualRecoilAng)

    -- v = v - (vrc.x * ang:Right())
    -- v = v - (vrc.y * ang:Forward())
    -- v = v - (vrc.z * ang:Up())

    -- pos = pos + v

    pos, ang = self:RotateAroundPoint(pos, ang, vrc, self.VisualRecoilPos, self.VisualRecoilAng)

    return pos, ang
end