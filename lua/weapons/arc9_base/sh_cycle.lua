function SWEP:ThinkCycle()
    if self:StillWaiting() then return end

    if self:GetNeedsCycle() and (!self:GetOwner():KeyDown(IN_ATTACK) or self:GetProcessedValue("SlamFire")) then
        if IsFirstTimePredicted() then

            if self.MalfunctionCycle and self:RollJam() then return end

            local t = self:PlayAnimation("cycle", 1, false)

            t = t * ((self:GetAnimationEntry(self:TranslateAnimation("cycle")) or {}).MinProgress or 1)

            self:SetAnimLockTime(CurTime() + t)

            local ejectdelay = self:GetProcessedValue("EjectDelay")

            if ejectdelay == 0 then
                self:DoEject()
            else
                self:SetTimer(ejectdelay, function()
                    self:DoEject()
                end)
            end
        end
        self:SetNeedsCycle(false)
    end
end