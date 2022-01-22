function SWEP:GetSprintToFireTime()
    return self:GetProcessedValue("SprintToFireTime")
end

function SWEP:GetIsSprinting()
    local owner = self:GetOwner()

    if !self:GetOwner():IsValid() or self:GetOwner():IsNPC() then
        return false
    end

    local curspeed = owner:GetVelocity():Length()

    if !owner:KeyDown(IN_FORWARD) and !owner:KeyDown(IN_BACK) and !owner:KeyDown(IN_MOVELEFT) and !owner:KeyDown(IN_MOVERIGHT) then return false end
    if !owner:KeyDown(IN_SPEED) then return false end
    if curspeed <= 0 then return false end
    if !owner:OnGround() or owner:GetMoveType() == MOVETYPE_NOCLIP then return false end

    return true
end

function SWEP:GetSprintDelta()
    return self:GetSprintAmount()
end

function SWEP:EnterSprint()
    self:SetShouldHoldType()

    if !self:StillWaiting() then
        self:PlayAnimation("enter_sprint", self:GetProcessedValue("SprintToFireTime"))
    end
end

function SWEP:ExitSprint()
    self:SetShouldHoldType()

    if !self:StillWaiting() then
        self:PlayAnimation("exit_sprint", self:GetProcessedValue("SprintToFireTime"))
    end
end

SWEP.LastWasSprinting = false

function SWEP:ThinkSprint()
    local sprinting = self:GetIsSprinting() or self:GetSafe()

    if self:GetSightAmount() >= 1 then
        sprinting = false
    end

    local amt = self:GetSprintAmount()

    if self.LastWasSprinting and !sprinting then
        self:ExitSprint()
    elseif !self.LastWasSprinting and sprinting then
        self:EnterSprint()
    end

    self.LastWasSprinting = sprinting

    if sprinting then
        amt = math.Approach(amt, 1, FrameTime() / self:GetSprintToFireTime())
    else
        amt = math.Approach(amt, 0, FrameTime() / self:GetSprintToFireTime())
    end

    self:SetSprintAmount(amt)
end