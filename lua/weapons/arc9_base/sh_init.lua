
function SWEP:OnReloaded()
    self:InvalidateCache()
end

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
