SWEP.LoopingSound = nil
SWEP.LoopingSoundIndoor = nil

function SWEP:StartLoop()
    if self.LoopingSound then return end
    local s = self:GetProcessedValue("ShootSoundLooping", true)

    if !s then return end

    self.LoopingSound = CreateSound(self, s)
    self.LoopingSound:Play()
    self.LoopingSound:SetSoundLevel(math.Clamp(self:GetProcessedValue("ShootVolume", true), 51, 149))
    self.LoopingSound:ChangePitch(self:GetProcessedValue("ShootPitch", true), 0)
    self.LoopingSound:ChangeVolume(self:GetProcessedValue("ShootVolumeActual", true))
    -- self.LoopingSound = self:StartLoopingSound(s)

    local si = self:GetProcessedValue("ShootSoundLoopingIndoor")

    if !si then return end

    self.LoopingSoundIndoor = CreateSound(self, si)
    self.LoopingSoundIndoor:Play()
    self.LoopingSoundIndoor:SetSoundLevel(math.Clamp(self:GetProcessedValue("ShootVolume", true), 51, 149))
    self.LoopingSoundIndoor:ChangePitch(self:GetProcessedValue("ShootPitch", true), 0)
    self.LoopingSoundIndoor:ChangeVolume(0)
end

function SWEP:EndLoop()
    if !self.LoopingSound then return end

    self.LoopingSound:Stop()
    -- self:StopLoopingSound(self.LoopingSound)
    self.LoopingSound = nil

    if self.LoopingSoundIndoor then
        self.LoopingSoundIndoor:Stop()
    -- self:StopLoopingSound(self.LoopingSound)
        self.LoopingSoundIndoor = nil

        if self:GetIndoor() then
            local soundtab1 = {
                name = "shootlooptailindoor",
                sound = self:GetProcessedValue("ShootSoundTailIndoor", true) or self:GetProcessedValue("ShootSoundWindDownIndoor", true) or "",
            }
            self:PlayTranslatedSound(soundtab1)
        else
            local soundtab1 = {
                name = "shootlooptail",
                sound = self:GetProcessedValue("ShootSoundTail", true) or self:GetProcessedValue("ShootSoundWindDown", true) or "",
            }
            self:PlayTranslatedSound(soundtab1)
        end
    else
        local soundtab1 = {
            name = "shootlooptail",
            sound = self:GetProcessedValue("ShootSoundTail", true) or self:GetProcessedValue("ShootSoundWindDown", true) or "",
        }
        self:PlayTranslatedSound(soundtab1)
    end
end

function SWEP:ThinkLoopingSound()

    if self.LoopingSound then
        if self:GetNextPrimaryFire() + (60 / self:GetProcessedValue("RPM")) <= CurTime() then
            self:EndLoop()
        else
            self.LoopingSound:Play()

            if self.LoopingSoundIndoor then
                self.LoopingSoundIndoor:Play()

                if self:GetIndoor() then
                    self.LoopingSoundIndoor:ChangeVolume(1, 0.1)
                    self.LoopingSound:ChangeVolume(0, 0.1)
                else
                    self.LoopingSoundIndoor:ChangeVolume(0, 0.1)
                    self.LoopingSound:ChangeVolume(1, 0.1)
                end
            end
        end
    end
end

SWEP.IndoorTick = 0
SWEP.IsIndoors = 0

--[[]
local dirs = {
    Angle(-90, 90, 0), -- Up            angled by 15 degrees + diagonal direction
    Angle(-75, 135, 0), -- Up right
    Angle(-105, 135, 0), -- Up left
    Angle(-105, 45, 0), -- Up front
    Angle(-105, 225, 0), -- Up back

    Angle(-15, 0, 0), -- side
    Angle(-15, 120, 0), -- side
    Angle(-15, 240, 0), -- side
}
]]

local traces = {
    {
        Distance = Vector(0, 0, 1024),
        Influence = 0,
    }, -- Up
    {
        Distance = Vector(0, 768, 768),
        Influence = 1,
    }, -- Up Forward
    {
        Distance = Vector(0, -768, 768),
        Influence = 1,
    }, -- Up Back
    {
        Distance = Vector(0, 768, 0),
        Influence = 0.5,
    }, -- Forward
    {
        Distance = Vector(768, 768, 0),
        Influence = 0.5,
    }, -- Right
    {
        Distance = Vector(-768, 768, 0),
        Influence = 0.5,
    }, -- Left

}


local traceResultTable = {}

local traceTable = {
    start = 0,
    endpos = 0,
    mask = 16513,
    output = traceResultTable
}

function SWEP:GetIndoor()
    if !self.ShootSoundIndoor and !self.DistantShootSoundIndoor and !self.ShootSoundSilencedIndoor and !self.DistantShootSoundSilencedIndoor then return 0 end -- non realism guns!!!

    if self.IndoorTick == UnPredictedCurTime() then return self.IsIndoors end
    self.IndoorTick = UnPredictedCurTime()

    ------------------------- the one Fesiug wrote for UC (smooth)
    local vol = 0
    local wo = self:GetOwner()
    if !IsValid(wo) then return end
    local wop = wo:EyePos()
    local woa = Angle(0, wo:EyeAngles().y, 0)
    local t_influ = 0

    for _, tin in ipairs(traces) do
        traceTable.start = wop
        offset = Vector()
        offset = offset + (tin.Distance.x * woa:Right())
        offset = offset + (tin.Distance.y * woa:Forward())
        offset = offset + (tin.Distance.z * woa:Up())
        traceTable.endpos = wop + offset
        traceTable.filter = wo
        t_influ = t_influ + (tin.Influence or 1)
        local result = util.TraceLine(traceTable)
        if GetConVar("developer"):GetInt() > 2 then
            debugoverlay.Line(wop - (vector_up * 4), result.HitPos - (vector_up * 4), 1, Color((_ / 4) * 255, 0, (1 - (_ / 4)) * 255))
            debugoverlay.Text(result.HitPos - (vector_up * 4), math.Round((result.HitSky and 1 or result.Fraction) * 100) .. "%", 1)
        end
        vol = vol + (result.HitSky and 1 or result.Fraction) * tin.Influence
    end

    self.IsIndoors = 1 - vol / t_influ

    return self.IsIndoors

    ------------------------- old one (bad) (not good)
    --[[]
    local isindoors = 0

    local hits = 0
    local endmult = 0

    local owner = self:GetOwner()
    local eyePos = owner:EyePos() -- vector which will be used for adding dir:Forward()
    local eyePos2 = Vector(eyePos)

    traceTable.start = eyePos -- copy
    traceTable.endpos = eyePos2

    for i, dir in ipairs(dirs) do

        local dirForward = dir:Forward()
        dirForward:Mul(500 * (i == 1 and 2 or 1))
        eyePos2:Set(eyePos)
        eyePos2:Add(dirForward)

        util.TraceLine(traceTable)

        local tr = traceResultTable

        if tr.Hit and !tr.HitSky then
            hits = hits + 1

            endmult = endmult + math.exp(math.min(math.ease.InExpo(1-tr.Fraction), 0.4)) / 10
        end

        -- if ARC9.Dev(2) then
        --     debugoverlay.Line(traceTable.start, traceTable.endpos, 3, (tr.Hit and !tr.HitSky) and Color(255,0,0) or color_white, true)
        --     if i == 8 then
        --         print(hits.."/8 indoor trace hits, fraction "..endmult)
        --     end
        -- end
    end

    if hits > 0 then
        isindoors = endmult
    end

    isindoors = math.min(isindoors, 1)
    self.IsIndoors = isindoors
    ]]
end