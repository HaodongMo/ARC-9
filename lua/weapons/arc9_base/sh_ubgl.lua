local arc9_infinite_ammo = GetConVar("arc9_infinite_ammo")
local cvarGetBool = FindMetaTable("ConVar").GetBool

function SWEP:ThinkUBGL()
    if self:GetValue("UBGL") and !self:GetProcessedValue("UBGLInsteadOfSights", true)  then
        local owner = self:GetOwner()
		local mag = self:Clip2()
		local magr = self.Owner:GetAmmoCount(self.Secondary.Ammo)
		local infmag = cvarGetBool(arc9_infinite_ammo)

		if mag == 0 and (!infmag and magr == 0) then
			if self:GetUBGL() then self:ToggleUBGL(false) end
			return
		end

        if (owner:KeyDown(IN_USE) and owner:KeyPressed(IN_ATTACK2)) or owner:KeyPressed(ARC9.IN_UBGL) then
            if self.NextUBGLSwitch and self.NextUBGLSwitch > CurTime() then return end
            self.NextUBGLSwitch = CurTime() + (self.UBGLToggleTime or 1)

            if self:GetUBGL() then
                self:ToggleUBGL(false)
            else
                self:ToggleUBGL(true)
            end
        end

    end
end

local singleplayer = game.SinglePlayer()

function SWEP:ToggleUBGL(on)
    if on == nil then on = !self:GetUBGL() end
    if self:GetReloading() then on = false end
    if self:GetCustomize() then on = false end

    if on == self:GetUBGL() then return end

    if self:StillWaiting() then return end

	if self.UBGLCancelAnim then self:PlayAnimation("enter_sights" or "idle", 1, true) end
	
    self:CancelReload()
    self:SetUBGL(on)

    if singleplayer and self:GetOwner():IsPlayer() then
        self:CallOnClient("ClearLongCache")
    end
    self:ClearLongCache()
    
    if on then
        local soundtab = {
            name = "enterubgl",
            sound = self:RandomChoice(self:GetProcessedValue("EnterUBGLSound", true)),
            channel = ARC9.CHAN_FIDDLE
        }

        self:PlayTranslatedSound(soundtab)

        self:PlayAnimation("enter_ubgl", 1, true)
        self:ExitSights()

        if singleplayer then
            self:CallOnClient("RecalculateIKGunMotionOffset")
        end
    else
        local soundtab = {
            name = "exitubgl",
            sound = self:RandomChoice(self:GetProcessedValue("ExitUBGLSound", true)),
            channel = ARC9.CHAN_FIDDLE
        }

        self:PlayTranslatedSound(soundtab)

        self:PlayAnimation("exit_ubgl", 1, true)
    end
end