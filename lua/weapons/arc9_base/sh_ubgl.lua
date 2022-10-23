function SWEP:ThinkUBGL()
    if !self:GetProcessedValue("UBGLInsteadOfSights") and self:GetValue("UBGL") then
        if self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyPressed(IN_RELOAD) and IsFirstTimePredicted() then
            if self.NextUBGLSwitch and self.NextUBGLSwitch > CurTime() then return end
            self.NextUBGLSwitch = CurTime() + 1

            if self:GetUBGL() then
                self:ToggleUBGL(false)
            else
                self:ToggleUBGL(true)
            end
        end
    end
end

function SWEP:ToggleUBGL(on)
    if on == nil then on = !self:GetUBGL() end
    if self:GetReloading() then on = false end
    if self:GetCustomize() then on = false end

    if on == self:GetUBGL() then return end

    self:CancelReload()
    self:SetUBGL(on)

    if on then
        self:EmitSound(self:GetProcessedValue("EnterUBGLSound"), 75, 100, 1, CHAN_AUTO)
        self:PlayAnimation("enter_ubgl", 1, true)
        self:ExitSights()
    else
        self:EmitSound(self:GetProcessedValue("ExitUBGLSound"), 75, 100, 1, CHAN_AUTO)
        self:PlayAnimation("exit_ubgl", 1, true)
    end
end