
function SWEP:OnReloaded()
    self:InvalidateCache()
end

local arc9_precache_sounds_onfirsttake = GetConVar("arc9_precache_sounds_onfirsttake")
local arc9_precache_wepmodels_onfirsttake = GetConVar("arc9_precache_wepmodels_onfirsttake")
local arc9_precache_attsmodels_onfirsttake = GetConVar("arc9_precache_attsmodels_onfirsttake")

function SWEP:Initialize()
    local owner = self:GetOwner()

    self.HoldTypeDefault = self.HoldType

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

    local bottomless = self:GetProcessedValue("BottomlessClip", true)
    local clip = bottomless and self:GetProcessedValue("AmmoPerShot") or self.LastClipSize
    self.Primary.DefaultClip = clip + (bottomless and 0 or (self:GetProcessedValue("ChamberSize") or 0))
    -- self.Primary.DefaultClip = clip * math.max(1, self:GetProcessedValue("SupplyLimit") + (bottomless and 0 or 1))

    if self.Primary.DefaultClip == 1 then -- This specific value seems to be hard-coded to not give any ammo?
        self:SetClip1(1)
        self.Primary.DefaultClip = 0
    end

    if self:GetValue("UBGL") then
        self.Secondary.Ammo = self:GetValue("UBGLAmmo")
        self.Secondary.DefaultClip = self:GetValue("UBGLClipSize") * math.max(1, self:GetValue("SecondarySupplyLimit") + 1)
    end

    self:SetClip1(self.ClipSize > 0 and math.max(1, self.Primary.DefaultClip) or self.Primary.DefaultClip)
    self:SetClip2(self.Secondary.DefaultClip)

    self:SetLastLoadedRounds(self.LastClipSize)
    
    timer.Simple(0.4, function()
        if IsValid(self) then
            if self:LookupPoseParameter("sights") != -1 then self.HasSightsPoseparam = true end
            if self:LookupPoseParameter("firemode") != -1 then self.HasFiremodePoseparam = true end
            if SERVER then self:InitialDefaultClip() end
        end
    end)

    if arc9_precache_sounds_onfirsttake:GetBool() then
        ARC9.CacheWepSounds(self, self:GetClass())
    end

    if arc9_precache_wepmodels_onfirsttake:GetBool() then
        ARC9.CacheWeaponsModels()
    end
    
    if arc9_precache_attsmodels_onfirsttake:GetBool() then
        ARC9.CacheAttsModels()
    end
end

function SWEP:ClientInitialize()
    if game.SinglePlayer() and self:GetOwner():IsPlayer() then self:CallOnClient("ClientInitialize") end
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
        if game.SinglePlayer() and self:GetOwner():IsPlayer() and SERVER then
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
        local htnpc = self:GetValue("HoldTypeNPC", true)

        if !htnpc then
            if self:GetProcessedValue("ManualAction", true) then
                self:SetHoldType("shotgun")
            else
                self:SetHoldType(self:GetValue("HoldTypeSights", true) or self:GetValue("HoldType", true))
            end
        else
            self:SetHoldType(self:GetValue("HoldTypeNPC", true))
        end

        return
    end

    if self:GetInSights() and !self:GetSafe() then
        if self:GetProcessedValue("HoldTypeSights", true) then
            self:SetHoldType(self:GetProcessedValue("HoldTypeSights", true))

            return
        end
    end

    if self:GetCustomize() then
        if self:GetProcessedValue("HoldTypeCustomize", true) then
            self:SetHoldType(self:GetProcessedValue("HoldTypeCustomize", true))

            return
        end
    end

    if self:GetSafe() then
        if self:GetProcessedValue("HoldTypeHolstered", true) then
            self:SetHoldType(self:GetProcessedValue("HoldTypeHolstered", true))

            return
        end
    end

    if self:GetIsSprinting() or self:GetSafe() then
        if self:GetProcessedValue("HoldTypeSprint", true) then
            self:SetHoldType(self:GetProcessedValue("HoldTypeSprint", true))

            return
        end
    end

    self:SetHoldType(self:GetProcessedValue("HoldTypeDefault", true) or self:GetValue("HoldType", true))
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
