function SWEP:ThinkCycle()
    if self:GetNeedsCycle() and self:GetCycleFinishTime() != 0 and self:GetCycleFinishTime() <= CurTime() then
        self:SetNeedsCycle(false)
        self:SetCycleFinishTime(0)
    end
    if self:StillWaiting() then return end
    local owner = self:GetOwner()

    local manual = self:ShouldManualCycle()

    local cycling = !owner:KeyDown(IN_ATTACK)

    if manual then
        cycling = owner:KeyDown(IN_RELOAD)
    end

    if self:GetNeedsCycle() and (cycling or self:GetProcessedValue("SlamFire", true)) then

        if self.MalfunctionCycle and (IsFirstTimePredicted() and self:RollJam()) then return end

        local ejectdelay = self:GetProcessedValue("EjectDelay", true)

        local t = self:PlayAnimation("cycle", self:GetProcessedValue("CycleTime", true), false)

        t = t * ((self:GetAnimationEntry(self:TranslateAnimation("cycle")) or {}).MinProgress or 1)

        self:SetCycleFinishTime(CurTime() + t)

        if IsFirstTimePredicted() and !self:GetProcessedValue("NoShellEjectManualAction", true) then
            if ejectdelay == 0 then
                self:DoEject()
            else
                self:SetTimer(ejectdelay, function()
                    self:DoEject()
                end)
            end
        end
    end
end

function SWEP:ShouldManualCycle()
    return self:GetOwner():GetInfoNum("arc9_manualbolt", 0) >= 1
end