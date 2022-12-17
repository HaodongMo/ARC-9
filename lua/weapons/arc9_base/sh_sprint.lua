function SWEP:GetSprintToFireTime()
    return self:GetProcessedValue("SprintToFireTime")
end

function SWEP:GetTraverseSprintToFireTime()
    return self:GetProcessedValue("SprintToFireTime") * 1.5
end

-- local cachedissprinting = false
-- local cachedsprinttime = 0

function SWEP:GetIsSprinting()
    -- if cachedsprinttime == CurTime() then
    --     return cachedissprinting
    -- end

    -- cachedsprinttime = CurTime()
    -- cachedissprinting = self:GetIsSprintingCheck()

    return self:GetIsSprintingCheck()
end

function SWEP:GetIsWalking()
    local owner = self:GetOwner()

    if !self:GetOwner():IsValid() or self:GetOwner():IsNPC() then
        return false
    end

    if owner:KeyDown(IN_SPEED) then return false end
    if !owner:KeyDown(IN_FORWARD) and !owner:KeyDown(IN_BACK) and !owner:KeyDown(IN_MOVELEFT) and !owner:KeyDown(IN_MOVERIGHT) then return false end

    local curspeed = owner:GetVelocity():LengthSqr()
    if curspeed <= 0 then return false end

    return true
end

function SWEP:GetIsSprintingCheck()
    local owner = self:GetOwner()

    if !self:GetOwner():IsValid() or self:GetOwner():IsNPC() then
        return false
    end
    if self:GetSightAmount() > 0.5 then return false end
    if !owner:KeyDown(IN_SPEED) then return false end
    if !owner:OnGround() or owner:GetMoveType() == MOVETYPE_NOCLIP then return false end
    if !owner:KeyDown(IN_FORWARD) and !owner:KeyDown(IN_BACK) and !owner:KeyDown(IN_MOVELEFT) and !owner:KeyDown(IN_MOVERIGHT) then return false end

    if (self:GetAnimLockTime() > CurTime()) and self:GetProcessedValue("NoSprintWhenLocked") then
        return false
    end

    if self:GetProcessedValue("ShootWhileSprint") then
        if owner:KeyDown(IN_ATTACK) then
            return false
        end
    end

    if owner:Crouching() then return false end
    -- if owner:KeyDown(IN_WALK) then return false end
    local curspeed = owner:GetVelocity():LengthSqr()
    if curspeed <= 0 then return false end

    return true
end

function SWEP:GetSprintDelta()
    return self:GetSprintAmount()
end

function SWEP:EnterSprint()
    self:SetShouldHoldType()

    self:ToggleBlindFire(false)

    if !self:GetProcessedValue("ReloadWhileSprint") then
        self:CancelReload()
    end

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

function SWEP:ThinkSprint()

    local sprinting = self:GetSafe() or self:GetIsSprinting()

    if self:GetSightAmount() >= 1 or (self:GetProcessedValue("ReloadNoSprintPos") and self:GetReloading()) then
        sprinting = false
    end

    local amt = self:GetSprintAmount()
    -- local ts_amt = self:GetTraversalSprintAmount()
    local lastwassprinting = self:GetLastWasSprinting()

    if lastwassprinting and !sprinting then
        self:ExitSprint()
    elseif !lastwassprinting and sprinting then
        self:EnterSprint()
    end

    self:SetLastWasSprinting(sprinting)

    if sprinting then
        if amt < 1 then
            amt = math.Approach(amt, 1, FrameTime() / self:GetSprintToFireTime())
        end
        -- if self:GetTraversalSprint() then
        --     ts_amt = math.Approach(ts_amt, 1, FrameTime() / (self:GetTraverseSprintToFireTime()))
        -- end
    else
        if amt > 0 then
            amt = math.Approach(amt, 0, FrameTime() / self:GetSprintToFireTime())
        end
    end

    -- if !self:GetTraversalSprint() then
    --     ts_amt = math.Approach(ts_amt, 0, FrameTime() / (self:GetTraverseSprintToFireTime()))
    -- end

    -- self:SetTraversalSprintAmount(ts_amt)
    self:SetSprintAmount(amt)

    -- if self:GetOwner():KeyDown(IN_FORWARD) and self:GetOwner():KeyPressed(IN_SPEED) then
    --     if self:GetLastPressedWTime() >= (CurTime() - 0.33) then
    --         self:SetTraversalSprint(true)
    --     else
    --         self:SetLastPressedWTime(CurTime())
    --     end
    -- end

    -- if self:GetTraversalSprint() then
    --     if !sprinting then
    --         self:SetTraversalSprint(false)
    --     end

    --     if !self:GetOwner():KeyDown(IN_FORWARD) then
    --         self:SetTraversalSprint(false)
    --     end

    --     if self:GetSprintAmount() <= 0 then
    --         self:SetTraversalSprint(false)
    --     end
    -- end
end