SWEP.LoopingSound = nil
SWEP.LoopingSoundIndoor = nil

function SWEP:StartLoop()
    if self.LoopingSound then return end
    local s = self:GetProcessedValue("ShootSoundLooping")

    if !s then return end

    self.LoopingSound = CreateSound(self, s)
    self.LoopingSound:Play()
    self.LoopingSound:SetSoundLevel(math.Clamp(self:GetProcessedValue("ShootVolume"), 51, 149))
    self.LoopingSound:ChangePitch(self:GetProcessedValue("ShootPitch"), 0)
    self.LoopingSound:ChangeVolume(self:GetProcessedValue("ShootVolumeActual"))
    -- self.LoopingSound = self:StartLoopingSound(s)

    local si = self:GetProcessedValue("ShootSoundLoopingIndoor")

    if !si then return end

    self.LoopingSoundIndoor = CreateSound(self, si)
    self.LoopingSoundIndoor:Play()
    self.LoopingSoundIndoor:SetSoundLevel(math.Clamp(self:GetProcessedValue("ShootVolume"), 51, 149))
    self.LoopingSoundIndoor:ChangePitch(self:GetProcessedValue("ShootPitch"), 0)
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
            self:EmitSound(self:GetProcessedValue("ShootSoundTailIndoor") or self:GetProcessedValue("ShootSoundWindDownIndoor") or "")
        else
            self:EmitSound(self:GetProcessedValue("ShootSoundTail") or self:GetProcessedValue("ShootSoundWindDown") or "")
        end
    else
        self:EmitSound(self:GetProcessedValue("ShootSoundTail") or self:GetProcessedValue("ShootSoundWindDown") or "")
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
    -- Angle(-90, 90, 0), -- Up         angled by 45 degrees
    -- Angle(-45, 90, 0), -- Up right
    -- Angle(-135, 90, 0), -- Up left
    -- Angle(-135, 0, 0), -- Up front
    -- Angle(-135, 180, 0), -- Up back

    Angle(-90, 90, 0), -- Up            angled by 15 degrees + diagonal direction
    Angle(-75, 135, 0), -- Up right
    Angle(-105, 135, 0), -- Up left
    Angle(-105, 45, 0), -- Up front
    Angle(-105, 225, 0), -- Up back
}

function SWEP:GetIndoor()
    if !self.ShootSoundIndoor then return false end -- non realism guns!!!

    if self.IndoorTick == UnPredictedCurTime() then return self.IsIndoors end

    self.IndoorTick = UnPredictedCurTime()

    local isindoors = false

    local hits = 0
    
    local multlength = 1

    for i, dir in ipairs(dirs) do
        local tracetable = {
            start = self:GetOwner():EyePos(),
            endpos = self:GetOwner():EyePos() + dir:Forward() * 500 * (i == 1 and 1.5 or 1), -- if first trace (up) then multiplicate length by 1.5
            -- mask = MASK_NPCSOLID_BRUSHONLY
        }

        local tr = util.TraceLine(tracetable)

        if ARC9.Dev(2) then debugoverlay.Line(tracetable.start, tracetable.endpos, 3, color_white, true) end
        
        if tr.Hit and !tr.HitSky then
            hits = hits + 1
        end
    end

    if hits >= #dirs * 0.5 then
        isindoors = true
    end

    self.IsIndoors = isindoors

    return isindoors
end