function SWEP:ThinkInspect()
    if self:StillWaiting() or self:GetInSights() then return end
    
    -- self:PlayAnimation("inspect", 1, true)
    if self:GetOwner():KeyDown(IN_RELOAD) and self:GetOwner():KeyDown(IN_USE) then
        if !self:HasAnimation("enter_inspect") then
            self:PlayAnimation("inspect", 1, true)
            return
        end

        if self:GetInspecting() then
            if IsFirstTimePredicted() then
                self:PlayAnimation("idle_inspect", 1, true)
            end
        else
            self:SetInspecting(true)
            if IsFirstTimePredicted() then
                self:PlayAnimation("enter_inspect", 1, true)
            end
        end
    elseif self:GetInspecting() then
        self:SetInspecting(false)
        if IsFirstTimePredicted() then
            self:PlayAnimation("exit_inspect", 1, true)
        end
    end
end