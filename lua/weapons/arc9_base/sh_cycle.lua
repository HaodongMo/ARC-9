function SWEP:ThinkCycle()
    if self:StillWaiting() then return end

    if self:GetNeedsCycle() and !self:GetOwner():KeyDown(IN_ATTACK) then
        if IsFirstTimePredicted() then
            self:PlayAnimation("cycle", 1, true, true)
        end
        self:SetNeedsCycle(false)
    end
end