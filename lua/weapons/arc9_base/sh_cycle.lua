function SWEP:ThinkCycle()
    if self:StillWaiting() then return end

    if self:GetNeedsCycle() and !self:GetOwner():KeyDown(IN_ATTACK) then
        if IsFirstTimePredicted() then
            self:PlayAnimation("cycle", 1, true)

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