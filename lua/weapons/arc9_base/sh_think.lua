function SWEP:Think()
    local owner = self:GetOwner()

    if !IsValid(owner) then return end
    if self:GetOwner():IsNPC() then return end

    if self:GetNextIdle() < CurTime() then
        self:Idle()
    end

    if !self.NotAWeapon then

        if owner:KeyReleased(IN_ATTACK) or (self:GetUBGL() and owner:KeyReleased(IN_ATTACK2)) then
            self:SetNeedTriggerPress(false)
            if !self:GetProcessedValue("RunawayBurst") then
                self:SetBurstCount(0)
            end
            if self:GetCurrentFiremode() < 0 and !self:GetProcessedValue("RunawayBurst") and self:GetBurstCount() > 0 then
                self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("PostBurstDelay"))
            end
        end

        if self:GetProcessedValue("RunawayBurst") then
            if self:GetBurstCount() >= self:GetCurrentFiremode() and self:GetCurrentFiremode() > 0 then
                self:SetBurstCount(0)
                self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("PostBurstDelay"))
            elseif self:GetBurstCount() > 0 and self:GetBurstCount() < self:GetCurrentFiremode() then
                self:DoPrimaryAttack()
            end
        end

        if !self:StillWaiting() and self:GetProcessedValue("TriggerDelay") then
            local check = (game.SinglePlayer() and SERVER or CLIENT and IsFirstTimePredicted())
            if owner:KeyDown(IN_ATTACK) and !self:SprintLock() then
                if check and self:GetTriggerDelay() <= 0 then
                    self:PlayAnimation("trigger", self:GetProcessedValue("TriggerDelayTime") / self.TriggerDelayTime)
                end
                self:SetTriggerDelay( math.Approach( self:GetTriggerDelay(), 1, FrameTime() * (1 / self:GetProcessedValue("TriggerDelayTime")) ) )
            else
                if check and self:GetTriggerDelay() != 1 and self:GetTriggerDelay() != 0 then
                    self:PlayAnimation("untrigger", self:GetProcessedValue("TriggerDelayTime") / self.TriggerDelayTime)
                end
                self:SetTriggerDelay(0)
            end
        end

        // If we have stopped shooting, play the aftershotparticle
        if self:GetAfterShot() and (IsFirstTimePredicted() or game.SinglePlayer()) then
            local delay = 60 / self:GetProcessedValue("RPM")

            if self:GetNextPrimaryFire() + (delay * 2) < CurTime() then
                self:SetAfterShot(false)
                if self:GetProcessedValue("AfterShotParticle") then
                    local att = self:GetProcessedValue("AfterShotQCA") or self:GetProcessedValue("MuzzleEffectQCA")

                    ParticleEffectAttach(self:GetProcessedValue("AfterShotParticle"), PATTACH_POINT_FOLLOW, self:GetVM(), att)
                end
            end
        end

        self:ThinkCycle()

        self:ThinkRecoil()

        self:ThinkHeat()

        self:ThinkReload()

        self:ThinkSights()

        self:ThinkBlindFire()

        self:ThinkBipod()

        self:ThinkMelee()

        self:ThinkHoldBreath()

        self:ThinkUBGL()

    end

    self:ThinkSprint()

    self:ThinkFiremodes()

    self:ThinkFreeAim()

    self:ThinkLoopingSound()

    self:ThinkInspect()

    self:ThinkAnimation()

    self:RunHook("Hook_Think")

    if CLIENT then
        self:ThinkThirdArm()
    end

    self:ProcessTimers()

    lastwalking = self:GetIsWalking()

    if CLIENT then
        if !self.LoadedPreset then
            self.LoadedPreset = true
            if GetConVar("arc9_autosave"):GetBool() then
                self:LoadPreset("autosave")
                self:DoDeployAnimation()
            else
                self:LoadPreset("default")
                self:DoDeployAnimation()
            end
        end
    end
end

SWEP.LastClipSize = 0
SWEP.LastAmmo = ""