function SWEP:DoDeployAnimation()
    if !self:GetReady() and self:HasAnimation("ready") then
        self:PlayAnimation("ready", self:GetProcessedValue("DeployTime", 1), true, true)
        self:SetReady(true)
    else
        self:PlayAnimation("draw", self:GetProcessedValue("DeployTime", 1), true, true)
    end
end

function SWEP:OnReloaded()
    self:InvalidateCache()
end

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
    self:SetHolster_Time(0)
    -- self:SetTraversalSprint(false)
    -- self:SetLastPressedWTime(0)

    self:SetBlindFire(false)
    self:SetBlindFireCorner(false)

    self:SetHolster_Entity(NULL)
    self:SetHolster_Time(0)

    self:SetFreeAimAngle(Angle(0, 0, 0))
    self:SetLastAimAngle(Angle(0, 0, 0))

    self:DoDeployAnimation()

    self:SetBurstCount(0)
    self:SetSightAmount(0)
    self:SetLoadedRounds(self:Clip1())
    self:SetCustomize(false)

    self:SetTriggerDown(self:GetOwner():KeyDown(IN_ATTACK))

    self:GetOwner():DoAnimationEvent(self:GetValue("AnimDraw"))

    if self:GetProcessedValue("AutoReload") then
        self:RestoreClip(math.huge)
    end

    if SERVER then
        if !self.GaveDefaultAmmo then
            self:GiveDefaultAmmo()
            self.GaveDefaultAmmo = true
        end

        -- self:NetworkWeapon()
        self:SetTimer(0.25, function()
            self:SendWeapon()
        end)
    end

    self:SetShouldHoldType()

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
        self:SetReady(false)
    end

    if self:GetHolster_Time() > CurTime() then return false end

    if (self:GetHolster_Time() != 0 and self:GetHolster_Time() <= CurTime()) or !IsValid(wep) then
        -- Do the final holster request
        -- Picking up props try to switch to NULL, by the way
        self:SetHolster_Time(0)
        self:SetHolster_Entity(NULL)

        self:KillTimers()
        self:GetOwner():SetFOV(0, 0)

        if self:GetProcessedValue("Disposable") and self:Clip1() == 0 and self:Ammo1() == 0 then
            self:Remove()
        end

        return true
    else
        -- Prepare the holster and set up the timer
        if self:HasAnimation("holster") then
            local animation = self:PlayAnimation("holster", self:GetProcessedValue("DeployTime", 1), true, false)
            self:SetHolster_Time(CurTime() + animation)
            self:SetHolster_Entity(wep)
        else
            self:SetHolster_Time(CurTime() + (self:GetProcessedValue("DeployTime", 1)))
            self:SetHolster_Entity(wep)
        end

        self:ToggleBlindFire(false)

    end
end

hook.Add("StartCommand", "ARC9_Holster", function(ply, ucmd)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.ARC9 then
        if wep:GetHolster_Time() != 0 and wep:GetHolster_Time() <= CurTime() then
            if IsValid(wep:GetHolster_Entity()) then
                wep:SetHolster_Time(-math.huge) -- Pretty much force it to work
                ucmd:SelectWeapon(wep:GetHolster_Entity()) -- Call the final holster request
            end
        end
    end
end)

function SWEP:Initialize()
    self:SetShouldHoldType()

    if self:GetOwner():IsNPC() then
        self:NPC_Initialize()
        return
    end

    self:SetBaseSettings()

    self:SetLastMeleeTime(0)
    self:SetNthShot(0)

    self:BuildAttachmentAddresses()

    self:InitTimers()

    self:ClientInitialize()
end

function SWEP:ClientInitialize()
    if game.SinglePlayer() then self:CallOnClient("ClientInitialize") end
    if SERVER then return end

    self:BuildAttachmentAddresses()
    self:SetBaseSettings()
    self:LoadPreset("autosave")

    self:InitTimers()
end

function SWEP:SetBaseSettings()
    if game.SinglePlayer() and SERVER then
        self:CallOnClient("SetBaseSettings")
    end

    self.Primary.Automatic = true

    self.Primary.ClipSize = self:GetValue("ClipSize")
    self.Primary.Ammo = self:GetValue("Ammo")

    self.Primary.DefaultClip = self.Primary.ClipSize

    if SERVER then
        if self:GetCapacity() > 0 and self:Clip1() > self:GetCapacity() then
            self:GetOwner():GiveAmmo(self:Clip1() - self:GetCapacity(), self:GetValue("Ammo"))
            self:SetClip1(self:GetCapacity())
        end
    end
end

function SWEP:SetShouldHoldType()
    if self:GetOwner():IsNPC() then
        self:SetHoldType(self:GetValue("HoldTypeNPC") or self:GetValue("HoldType"))

        return
    end

    if self:GetInSights() then
        if self:GetValue("HoldTypeSights") then
            self:SetHoldType(self:GetValue("HoldTypeSights"))

            return
        end
    end

    if self:GetSafe() then
        if self:GetValue("HoldTypeHolstered") then
            self:SetHoldType(self:GetValue("HoldTypeHolstered"))

            return
        end
    end

    if self:GetIsSprinting() or self:GetSafe() then
        if self:GetValue("HoldTypeSprint") then
            self:SetHoldType(self:GetValue("HoldTypeSprint"))

            return
        end
    end

    if self:GetCustomize() then
        if self:GetValue("HoldTypeCustomize") then
            self:SetHoldType(self:GetValue("HoldTypeCustomize"))

            return
        end
    end

    self:SetHoldType(self:GetValue("HoldType"))
end