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
    self:SetHolster_Time(0)

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

    if self:GetHolster_Time() > CurTime() then return false end

    if (self:GetHolster_Time() != 0 and self:GetHolster_Time() <= CurTime()) or !IsValid(wep) then
        -- Do the final holster request
        -- Picking up props try to switch to NULL, by the way
        self:SetHolster_Time(0)
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
            self:SetHolster_Time(CurTime() + animation)
            self:SetHolster_Entity(wep)
        else
            self:SetHolster_Time(CurTime() + (self:GetProcessedValue("DeployTime", 1)))
            self:SetHolster_Entity(wep)
        end

        self:ToggleBlindFire(false)
        self:SetInSights(false)
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

    self:SetLastMeleeTime(0)
    self:SetNthShot(0)

    self.SpawnTime = CurTime()

    -- self:BuildAttachmentAddresses()

    self:InitTimers()

    self:ClientInitialize()

    -- local base = baseclass.Get(self:GetClass())

    -- PrintTable(base.Attachments)

    self.DefaultAttachments = table.Copy(self.Attachments)

    self:BuildSubAttachments(self.DefaultAttachments)
end

function SWEP:ClientInitialize()
    if game.SinglePlayer() then self:CallOnClient("ClientInitialize") end
    if SERVER then return end

    -- local base = baseclass.Get(self:GetClass())

    -- self:BuildSubAttachments(base.Attachments)

    self.DefaultAttachments = table.Copy(self.Attachments)

    self:BuildSubAttachments(self.DefaultAttachments)

    self:SavePreset("default")

    self:InitTimers()

    self:LoadPreset("autosave")
end

function SWEP:SetBaseSettings()
    if game.SinglePlayer() and SERVER then
        self:CallOnClient("SetBaseSettings")
    end

    self.Primary.Automatic = true
    self.Secondary.Automatic = true

    self.Primary.ClipSize = self:GetValue("ClipSize")
    self.Primary.Ammo = self:GetValue("Ammo")

    self.Primary.DefaultClip = self.Primary.ClipSize

    if self:GetValue("UBGL") then
        self.Secondary.ClipSize = self:GetValue("UBGLClipSize")
        self.Secondary.Ammo = self:GetValue("UBGLAmmo")

        if SERVER then
            if self:Clip2() < 0 then
                self:SetClip2(0)
            end
        end
    else
        self.Secondary.ClipSize = -1
        self.Secondary.Ammo = nil

        self:SetUBGL(false)
    end
end

function SWEP:SetShouldHoldType()
    if self:GetOwner():IsNPC() then
        local htnpc = self:GetValue("HoldTypeNPC")

        if !htnpc then
            if self:GetProcessedValue("ManualAction") then
                self:SetHoldType("shotgun")
            else
                self:SetHoldType(self:GetValue("HoldTypeSights") or self:GetValue("HoldType"))
            end
        else
            self:SetHoldType(self:GetValue("HoldTypeNPC"))
        end

        return
    end

    if self:GetInSights() then
        if self:GetProcessedValue("HoldTypeSights") then
            self:SetHoldType(self:GetProcessedValue("HoldTypeSights"))

            return
        end
    end

    if self:GetSafe() then
        if self:GetProcessedValue("HoldTypeHolstered") then
            self:SetHoldType(self:GetProcessedValue("HoldTypeHolstered"))

            return
        end
    end

    if self:GetIsSprinting() or self:GetSafe() then
        if self:GetProcessedValue("HoldTypeSprint") then
            self:SetHoldType(self:GetProcessedValue("HoldTypeSprint"))

            return
        end
    end

    if self:GetCustomize() then
        if self:GetProcessedValue("HoldTypeCustomize") then
            self:SetHoldType(self:GetProcessedValue("HoldTypeCustomize"))

            return
        end
    end

    self:SetHoldType(self:GetProcessedValue("HoldType"))
end

function SWEP:OnDrop()
    self:EndLoop()
end

function SWEP:OnRemove()
    self:EndLoop()
end
