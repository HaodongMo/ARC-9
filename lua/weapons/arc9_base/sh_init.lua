
function SWEP:OnReloaded()
    self:InvalidateCache()
end

function SWEP:Initialize()
    local owner = self:GetOwner()

    self:SetShouldHoldType()

    if owner:IsNPC() then
        self:PostModify()
        self:NPC_Initialize()
        return
    end

    self:SetLastMeleeTime(0)
    self:SetNthShot(0)

    self.SpawnTime = CurTime()
    self:SetSpawnEffect(false) -- lol gmod suck
    -- self:BuildAttachmentAddresses()

    self:InitTimers()

    self:ClientInitialize()

    -- local base = baseclass.Get(self:GetClass())

    -- PrintTable(base.Attachments)

    self.DefaultAttachments = table.Copy(self.Attachments)

    self:BuildSubAttachments(self.DefaultAttachments)

    if !IsValid(owner) then -- player is nil here sometimes
        self:PostModify()
    end

    self.LastClipSize = self:GetProcessedValue("ClipSize")
    self.Primary.Ammo = self:GetProcessedValue("Ammo")
    self.LastAmmo = self.Primary.Ammo

    local bottomless = self:GetProcessedValue("BottomlessClip")
    local clip = bottomless and self:GetProcessedValue("AmmoPerShot") or self.LastClipSize
    self.Primary.DefaultClip = clip * math.max(1, self:GetProcessedValue("SupplyLimit") + (bottomless and 0 or 1))

    if self.Primary.DefaultClip == 1 then -- This specific value seems to be hard-coded to not give any ammo?
        self:SetClip1(1)
        self.Primary.DefaultClip = 0
    end

    ARC9.CacheAttsModels()

    if GetConVar("arc9_precache_sounds_onfirsttake"):GetBool() then
        ARC9.CacheWepSounds(self, self:GetClass())
    end
    
    if GetConVar("arc9_precache_wepmodels_onfirsttake"):GetBool() then
        ARC9.CacheWeaponsModels()
    end
end

function SWEP:ClientInitialize()
    if game.SinglePlayer() then self:CallOnClient("ClientInitialize") end
    if SERVER then return end

    -- local base = baseclass.Get(self:GetClass())

    -- self:BuildSubAttachments(base.Attachments)

    self.DefaultAttachments = table.Copy(self.Attachments)

    self:BuildSubAttachments(self.DefaultAttachments)

    self:InitTimers()

    if self:GetOwner() == LocalPlayer() then
        if !file.Exists(ARC9.PresetPath .. (self.SaveBase or self:GetClass()) .. "/default.txt", "DATA") then -- im sorry for that
            self:PostModify()
            self:SavePreset("default", true)
        end

        self:CreateStandardPresets()
    end

    if LocalPlayer().ARC9_IncompatibilityCheck != true and game.SinglePlayer() then
        LocalPlayer().ARC9_IncompatibilityCheck = true

        ARC9.DoCompatibilityCheck()
    end
end

do
    local _R = debug.getregistry()
    local ENTITY = _R.Entity
    local entityGetOwner = ENTITY.GetOwner

    local METATABLE = setmetatable(table.Copy(_R.Weapon), {__index = ENTITY})
    local EntTabMT = {__index = METATABLE}

    local copyKeys = {"MetaID","MetaName","__tostring","__eq","__concat"}
    local copyKeysLength = #copyKeys

    local function CopyMetatable(ent)
        local tab = ent:GetTable()
        setmetatable(tab, EntTabMT)

        local mt = {
            __index = function(self, key)
                -- we still have to take care of these idiots
                if key == "Owner" then
                    return entityGetOwner(self, key)
                end

                return tab[key]
            end,
            __newindex = tab,
            __metatable = ENTITY
        }

        for i = 1, copyKeysLength do
            local v = copyKeys[i]
            mt[v] = ENTITY[v]
        end

        debug.setmetatable(ent, mt)
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

        timer.Simple(0, function()
            if IsValid(self) then
                CopyMetatable(self)
            end
        end)
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
    self:KillShield()
    self:InvalidateCache()
    self:SetReady(false)
end

function SWEP:OnRemove()
    self:EndLoop()

    if SERVER then
        self:KillShield()
    end
end
