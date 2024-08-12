function SWEP:ThinkInspect()
	if self.NoInspect then return end
    if self:StillWaiting() or self:GetInSights() then return end
    if self:GetReloading() or self:GetBipod() then self:SetInspecting(false) return end
    if self.NextUBGLSwitch and self.NextUBGLSwitch > CurTime() then return end
    if self:GetUBGL() and !self:HasAnimation("inspect_ubgl") then return end
    if self:GetGrenadePrimed() then return end

    local owner = self:GetOwner()
    local inspecting = self:GetInspecting()

    -- self:PlayAnimation("inspect", 1, true)
    if (owner:KeyDown(IN_USE) and owner:KeyDown(IN_RELOAD)) or owner:KeyDown(ARC9.IN_INSPECT) then
        if !self:HasAnimation("enter_inspect") and !inspecting then
            self:PlayAnimation("inspect", 1, true)
            self:SetInspecting(true)
            return
        end

        if inspecting then
            self:PlayAnimation("idle_inspect", 1, true)
        else
            self:SetInspecting(true)
            self:PlayAnimation("enter_inspect", 1, true)
        end
    elseif inspecting then
        self:SetInspecting(false)
        self:PlayAnimation("exit_inspect", 1, true)
    else
        self:SetInspecting(false)
    end
end

function SWEP:CancelInspect()
    if !self:GetInspecting() then return end
    self:SetInspecting(false)

    -- local vm = self:GetVM()
    -- vm:SetSequence(0)
    -- vm:SetCycle(0)
    self:SetAnimLockTime(0)
    self:PlayAnimation("idle")
    self:CancelSoundTable()
    self:SetIKTimeLineStart(0)
    self:SetIKTime(0)
end