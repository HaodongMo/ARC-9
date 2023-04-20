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
SWEP.IsIndoors = false

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


local traceResultTable = {}

local traceTable = {
    start = 0,
    endpos = 0,
    mask = 16513,
    output = traceResultTable
}

function SWEP:GetIndoor()
    if !self.ShootSoundIndoor and !self.DistantShootSoundIndoor and !self.ShootSoundSilencedIndoor and !self.DistantShootSoundSilencedIndoor then return false end -- non realism guns!!!

    if self.IndoorTick == UnPredictedCurTime() then return self.IsIndoors end

    self.IndoorTick = UnPredictedCurTime()

    local isindoors = false

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

        if ARC9.Dev(2) then
            debugoverlay.Line(traceTable.start, traceTable.endpos, 3, (tr.Hit and !tr.HitSky) and Color(255,0,0) or color_white, true)
            if i == 8 then
                print(hits.."/8 indoor trace hits, fraction "..endmult)
                -- print(1-tr.Fraction, math.exp(1-tr.Fraction))
            end
        end
    end

    if hits > 0 then
    -- if hits >= #dirs * 0.5 then
        isindoors = true
    end

    self.IsIndoors = isindoors

    return isindoors and endmult or false
end