local lastwalking = false

function SWEP:Think()
    local owner = self:GetOwner()

    if !IsValid(owner) then return end
    if self:GetOwner():IsNPC() then return end

    if self:GetNextIdle() < CurTime() then
        self:Idle()
    end

    if !self:StillWaiting() and (lastwalking != self:GetIsWalking()) then
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
                if !self:GetProcessedValue("AutoBurst") then
                    self:SetNeedTriggerPress(true)
                end
            elseif self:GetBurstCount() > 0 and self:GetBurstCount() < self:GetCurrentFiremode() then
                self:PrimaryAttack()
            end
        end

        if !self:StillWaiting() and self:GetProcessedValue("TriggerDelay") then
            local check = (game.SinglePlayer() and SERVER or CLIENT and IsFirstTimePredicted())
            if owner:KeyDown(IN_ATTACK) then
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
                self:LoadPreset()
                self:DoDeployAnimation()
            end
        end
    end
end

SWEP.LastClipSize = 0
SWEP.LastAmmo = ""