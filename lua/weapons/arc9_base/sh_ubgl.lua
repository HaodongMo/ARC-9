function SWEP:ThinkUBGL()
    if (!game.SinglePlayer() or CLIENT) then return end

    if !self:GetProcessedValue("UBGLInsteadOfSights") and self:GetValue("UBGL") then
        if self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyPressed(IN_RELOAD) then
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
    if (!game.SinglePlayer() or CLIENT) then return end
    if on == nil then on = !self:GetUBGL() end
    if self:GetReloading() then on = false end
    if self:GetCustomize() then on = false end

    if on == self:GetUBGL() then return end

    self:CancelReload()
    self:SetUBGL(on)

    if on then
        local soundtab = {
            name = "enterubgl",
            sound = self:RandomChoice(self:GetProcessedValue("EnterUBGLSound")),
            channel = CHAN_AUTO
        }

        self:PlayTranslatedSound(soundtab)

        self:PlayAnimation("enter_ubgl", 1, true)
        self:ExitSights()
    else
        local soundtab = {
            name = "exitubgl",
            sound = self:RandomChoice(self:GetProcessedValue("ExitUBGLSound")),
            channel = CHAN_AUTO
        }

        self:PlayTranslatedSound(soundtab)

        self:PlayAnimation("exit_ubgl", 1, true)
    end
end