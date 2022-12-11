function SWEP:ThinkTriggerSounds()
    if self:PredictionFilter() then return end

    if self:GetAnimLockTime() > CurTime() then return end
    if self:StillWaiting() then return end
    if self:GetSafe() then return end

    if self:GetOwner():KeyReleased(IN_ATTACK) then
        local soundtab = {
            name = "triggerup",
            sound = self:RandomChoice(self:GetProcessedValue("TriggerUpSound")),
            channel = CHAN_VOICE_BASE
        }

        self:PlayTranslatedSound(soundtab)
    elseif self:GetOwner():KeyPressed(IN_ATTACK) then
        local soundtab = {
            name = "triggerdown",
            sound = self:RandomChoice(self:GetProcessedValue("TriggerDownSound")),
            channel = CHAN_VOICE_BASE
        }

        self:PlayTranslatedSound(soundtab)
    end
end