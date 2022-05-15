
function SWEP:Deploy()
    if self:GetOwner():IsNPC() then
        return
    end

    self:InvalidateCache()

    self:SetBaseSettings()

    self:SetNextPrimaryFire(0)
    self:SetNextSecondaryFire(0)
    self:SetAnimLockTime(0)
    self:SetLastMeleeTime(0)
    self:SetRecoilAmount(0)
    self:SetRecoilUp(0)
    self:SetRecoilSide(0)
    self:SetPrimedAttack(false)
    self:SetReloading(false)
    self:SetHolsterTime(0)
    self:SetRequestReload(false)
    self:SetEmptyReload(false)

    self:GetOwner():SetCanZoom(false)

    self.LastAmmo = self:GetValue("Ammo")
    self.LastClipSize = self:GetValue("ClipSize")
    -- self:SetTraversalSprint(false)
    -- self:SetLastPressedWTime(0)

    self:SetBlindFire(false)
    self:SetBlindFireDirection(0)

    self:SetHolster_Entity(NULL)
    self:SetHolsterTime(0)

    self:SetFreeAimAngle(Angle(0, 0, 0))
    self:SetLastAimAngle(Angle(0, 0, 0))

    self:DoDeployAnimation()

    self:SetBurstCount(0)
    self:SetSightAmount(0)
    self:SetCustomize(false)
    self:SetBreath(100)
    self:SetInspecting(false)
    self:SetLoadedRounds(self:Clip1())

    self:SetBipod(false)

    self:SetTriggerDown(self:GetOwner():KeyDown(IN_ATTACK))

    if self:GetValue("AnimDraw") then
        self:DoPlayerAnimationEvent(self:GetValue("AnimDraw"))
    end

    if self:GetProcessedValue("AutoReload") then
        self:RestoreClip(math.huge)
    end

    if SERVER then
        if !self.GaveDefaultAmmo then
            self:GiveDefaultAmmo()
            self.GaveDefaultAmmo = true
            self:SetLoadedRounds(self:Clip1())
        end

        -- self:NetworkWeapon()
        self:SetTimer(0.25, function()
            self:SendWeapon()
        end)
    end

    self:SetShouldHoldType()

    self:RunHook("Hook_Deploy")

    return true
end

function SWEP:GiveDefaultAmmo()
    self:SetClip1(self:GetValue("ClipSize"))
    self:GetOwner():GiveAmmo(self:GetValue("ClipSize") * 2, self:GetValue("Ammo"))
end

function SWEP:Holster(wep)
    -- May cause issues? But will fix HL2 weapons playing a wrong animation on ARC9 holster
    if game.SinglePlayer() and CLIENT then return end

    if self:GetOwner():IsNPC() then
        return
    end

    if self:GetReloading() then
        self:CancelReload()
    end

    if self:GetHolsterTime() > CurTime() then return false end

    if (self:GetHolsterTime() != 0 and self:GetHolsterTime() <= CurTime()) or !IsValid(wep) then
        -- Do the final holster request
        -- Picking up props try to switch to NULL, by the way
        self:SetHolsterTime(0)
        self:SetHolster_Entity(NULL)

        self:KillTimers()
        self:GetOwner():SetFOV(0, 0)
        self:GetOwner():SetCanZoom(true)
        self:EndLoop()

        if game.SinglePlayer() then
            game.SetTimeScale(1)
        end

        if self.SetBreathDSP then
            self:GetOwner():SetDSP(0)
            self.SetBreathDSP = false
        end

        self:RunHook("Hook_Holster")

        self:GetVM():SetSubMaterial()
        self:GetVM():SetMaterial()

        if self:GetProcessedValue("Disposable") and self:Clip1() == 0 and self:Ammo1() == 0 then
            self:Remove()
        end

        return true
    else
        -- Prepare the holster and set up the timer
        if self:HasAnimation("holster") then
            local animation = self:PlayAnimation("holster", self:GetProcessedValue("DeployTime", 1), true, false) or 0
            self:SetHolsterTime(CurTime() + animation)
            self:SetHolster_Entity(wep)
        else
            self:SetHolsterTime(CurTime() + (self:GetProcessedValue("DeployTime", 1)))
            self:SetHolster_Entity(wep)
        end

        self:ToggleBlindFire(false)
        self:SetInSights(false)
    end
end

hook.Add("StartCommand", "ARC9_Holster", function(ply, ucmd)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.ARC9 then
        if wep:GetHolsterTime() != 0 and wep:GetHolsterTime() <= CurTime() then
            if IsValid(wep:GetHolster_Entity()) then
                wep:SetHolsterTime(-math.huge) -- Pretty much force it to work
                ucmd:SelectWeapon(wep:GetHolster_Entity()) -- Call the final holster request
            end
        end
    end
end)

function SWEP:DoDeployAnimation()
    if !self:GetReady() and self:HasAnimation("ready") then
        local t = self:PlayAnimation("ready", self:GetProcessedValue("DeployTime", 1), true) or 0.25

        self:SetTimer(t, function()
            self:SetReady(true)
        end)
    else
        self:PlayAnimation("draw", self:GetProcessedValue("DeployTime", 1), true)
    end
end
