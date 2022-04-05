SWEP.LoopingSound = nil

function SWEP:StartLoop()
    if self.LoopingSound then return end
    local s = self:GetProcessedValue("ShootSoundLooping")

    if !s then return end

    self.LoopingSound = CreateSound(self, s)
    self.LoopingSound:Play()
    self.LoopingSound:SetSoundLevel(math.Clamp(self:GetProcessedValue("ShootVolume"), 51, 149))
    self.LoopingSound:ChangePitch(self:GetProcessedValue("ShootPitch"), 0)
    -- self.LoopingSound = self:StartLoopingSound(s)
end

function SWEP:EndLoop()
    if !self.LoopingSound then return end

    self.LoopingSound:Stop()
    -- self:StopLoopingSound(self.LoopingSound)
    self.LoopingSound = nil

    self:EmitSound(self:GetProcessedValue("ShootSoundTail") or self:GetProcessedValue("ShootSoundWindDown") or "")
end

function SWEP:ThinkLoopingSound()
    if self.LoopingSound then
        if self:GetNextPrimaryFire() + (60 / self:GetProcessedValue("RPM")) <= CurTime() then
            self:EndLoop()
        else
            self.LoopingSound:Play()
        end
    end
end