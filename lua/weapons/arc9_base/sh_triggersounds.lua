function SWEP:ThinkTriggerSounds()
    if self:GetAnimLockTime() > CurTime() then return end
    if self:StillWaiting() then return end
    if self:SprintLock() then return end
    if self:GetSafe() then return end
    local owner = self:GetOwner()
    local processedValue = self.GetProcessedValue

    if processedValue(self,"Throwable", true) then return end
    if processedValue(self,"PrimaryBash", true) then return end

    if owner:KeyReleased(IN_ATTACK) then
        local soundtab = {
            name = "triggerup",
            sound = self:RandomChoice(self:GetProcessedValue("TriggerUpSound", true)),
            channel = ARC9.CHAN_TRIGGER
        }

        self:PlayTranslatedSound(soundtab)
    elseif owner:KeyPressed(IN_ATTACK) then
        if processedValue(self,"Bash", true) and owner:KeyDown(IN_USE) and !self:GetInSights() then return end

        local soundtab = {
            name = "triggerdown",
            sound = self:RandomChoice(self:GetProcessedValue("TriggerDownSound", true)),
            channel = ARC9.CHAN_TRIGGER
        }

        self:PlayTranslatedSound(soundtab)
    end
end