function SWEP:GetSightDelta()
    return self:GetSightAmount()
end

function SWEP:EnterSights()
    if self:GetSprintAmount() > 0 then return end
    if !self:GetProcessedValue("HasSights") then return end

    self:SetInSights(true)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("EnterSightsSound")), 100, 75)

    self:PlayAnimation("enter_sights", self:GetProcessedValue("AimDownSightsTime"))

    if CLIENT then
        self:BuildMultiSight()
    elseif game.SinglePlayer() then
        self:CallOnClient("BuildMultiSight")
    end
end

function SWEP:ExitSights()
    self:SetInSights(false)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("ExitSightsSound")), 100, 75)

    self:PlayAnimation("exit_sights", self:GetProcessedValue("AimDownSightsTime"))
end

SWEP.LastPressedETime = 0

function SWEP:ThinkSights()
    if self:GetSafe() then return end

    local sighted = self:GetInSights()

    local amt = self:GetSightAmount()

    if sighted then
        amt = math.Approach(amt, 1, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
    else
        amt = math.Approach(amt, 0, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
    end

    self:GetVM():SetPoseParameter("sights", amt)

    self:SetSightAmount(amt)

    if sighted and !self:GetOwner():KeyDown(IN_ATTACK2) then
        self:ExitSights()
    elseif !sighted and self:GetOwner():KeyDown(IN_ATTACK2) then
        if self:GetOwner():KeyDown(IN_USE) then
            return
        end

        self:EnterSights()
    end

    if self:GetOwner():KeyPressed(IN_USE) then
        if CurTime() - self.LastPressedETime < 0.33 then
            if game.SinglePlayer() then
                self:CallOnClient("SwitchMultiSight")
            elseif CLIENT then
                self:SwitchMultiSight()
            end
        else
            self.LastPressedETime = CurTime()
        end
    end
end