function SWEP:ThinkInspect()
	if self.NoInspect then return end
    if self:StillWaiting() or self:GetInSights() or self:GetBipod() or self:GetReloading() then return end
    if self.NextUBGLSwitch and self.NextUBGLSwitch > CurTime() then return end
    if self:GetUBGL() and !self:HasAnimation("inspect_ubgl") then return end
    if self:GetGrenadePrimed() then return end

    local owner = self:GetOwner()
    local ininspectrn = string.find(self:GetIKAnimation() or "", "inspect")

    -- self:PlayAnimation("inspect", 1, true)
    if (owner:KeyDown(IN_USE) and owner:KeyDown(IN_RELOAD)) or owner:KeyDown(ARC9.IN_INSPECT) then
        if !self:HasAnimation("enter_inspect") and !ininspectrn then
            self:PlayAnimation("inspect", 1, true)
            return
        end

        if self:GetInspecting() then
            self:PlayAnimation("idle_inspect", 1, true)
        else
            self:SetInspecting(true)
            self:PlayAnimation("enter_inspect", 1, true)
        end
    elseif self:GetInspecting() then
        self:SetInspecting(false)
        self:PlayAnimation("exit_inspect", 1, true)
    end
end