function SWEP:Attach(addr, att, silent)
    if !self:CanAttach(addr, att) then return false end

    local slottbl = self:LocateSlotFromAddress(addr)

    self:DetachAllFromSubSlot(addr, true)

    if slottbl.Installed == att then return end

    slottbl.Installed = att
    slottbl.ToggleNum = 1

    if !silent then
        self:EmitSound(slottbl.InstallSound or "arc9/install.wav")
    end

    self:PruneAttachments()

    self:PostModify()

    return true
end

function SWEP:Detach(addr, silent)
    if !self:CanDetach(addr) then return false end

    local slottbl = self:LocateSlotFromAddress(addr)

    if !slottbl.Installed then return end

    slottbl.Installed = nil

    if !silent then
        self:EmitSound(slottbl.UninstallSound or "arc9/uninstall.wav")
    end

    self:PruneAttachments()

    self:PostModify()

    return true
end

function SWEP:DetachAllFromSubSlot(addr, silent)
    local slottbl = self:LocateSlotFromAddress(addr)

    self:Detach(addr, silent)

    if slottbl.MergeSlotAddresses then
        for _, addr2 in ipairs(slottbl.MergeSlotAddresses) do
            self:Detach(addr2, silent)
        end
    end
end

function SWEP:GetFilledMergeSlot(addr)
    local slottbl = self:LocateSlotFromAddress(addr)

    if !slottbl then return {} end

    if slottbl.Installed then
        return slottbl
    end

    if slottbl.MergeSlots then
        for _, merge_addr in ipairs(slottbl.MergeSlotAddresses) do
            local mergeslot = self:LocateSlotFromAddress(merge_addr)

            if mergeslot.Installed then
                return mergeslot
            end
        end
    end

    return slottbl
end

SWEP.LastClipSize = 0
SWEP.LastAmmo = ""

function SWEP:PostModify(toggleonly)
    self:InvalidateCache()

    if !toggleonly then
        self:CancelReload()
        -- self:PruneAttachments()
        self:SetNthReload(0)
    end

    local base = baseclass.Get(self:GetClass())

    if ARC9:UseTrueNames() then
        self.PrintName = base.TrueName
        self.PrintName = self:GetValue("TrueName")
    else
        self.PrintName = base.PrintName
        self.PrintName = self:GetValue("PrintName")
    end

    if !self.PrintName then
        self.PrintName = base.PrintName
        self.PrintName = self:GetValue("PrintName")
    end

    self.PrintName = self:RunHook("HookP_NameChange", self.PrintName)
    self.Description = self:RunHook("HookP_DescriptionChange", self.Description)

    if CLIENT then
        -- self:PruneAttachments()
        self:SendWeapon()
        self:SetupModel(true)
        self:SetupModel(false)
        if !toggleonly then
            self:SavePreset()
        end
        self:BuildMultiSight()
        self.InvalidateSelectIcon = true
    else
        if self:GetOwner():IsPlayer() then
            if self:GetValue("ToggleOnF") then
                if self:GetOwner():FlashlightIsOn() then
                    self:GetOwner():Flashlight(false)
                end
            end

            if self.LastAmmo != self:GetValue("Ammo") then
                self:GetOwner():GiveAmmo(self:Clip1(), self.LastAmmo)
                self:SetClip1(0)
                self:SetRequestReload(true)
            end

            if self.LastClipSize != self:GetValue("ClipSize") then
                self:GetOwner():GiveAmmo(self:Clip1(), self:GetValue("Ammo"))
                self:SetClip1(0)
                self:SetRequestReload(true)
            end

            self.LastAmmo = self:GetValue("Ammo")
            self.LastClipSize = self:GetValue("ClipSize")

            if self.LastUBGLAmmo and self.LastUBGLAmmo != self:GetValue("UBGLAmmo") then
                self:GetOwner():GiveAmmo(self:Clip2(), self.LastUBGLAmmo)
                self:SetClip2(0)
                self:SetRequestReload(true)
            end

            if self.LastUBGLAmmo and self.LastUBGLClipSize != self:GetValue("UBGLClipSize") then
                self:GetOwner():GiveAmmo(self:Clip2(), self.LastUBGLAmmo)
                self:SetClip2(0)
                self:SetRequestReload(true)
            end

            self.LastUBGLAmmo = self:GetValue("UBGLAmmo")
            self.LastUBGLClipSize = self:GetValue("UBGLClipSize")
        end

        if self:GetOwner():IsPlayer() then
            if self:GetCapacity(false) > 0 and self:Clip1() > self:GetCapacity(false) then
                self:GetOwner():GiveAmmo(self:Clip1() - self:GetCapacity(false), self:GetValue("Ammo"))
                self:SetClip1(self:GetCapacity(false))
            end
        end

        if self:GetValue("UBGL") then
            if !self.AlreadyGaveUBGLAmmo or self.SpawnTime + 0.25 > CurTime() then
                self:SetClip2(self:GetMaxClip2())
                self.AlreadyGaveUBGLAmmo = true
            end

            self.LastUBGLAmmo = self:GetProcessedValue("UBGLAmmo")

            if self:GetOwner():IsPlayer() and self:GetCapacity(true) > 0 and self:Clip2() > self:GetCapacity(true) then
                self:GetOwner():GiveAmmo(self:Clip2() - self:GetCapacity(true), self:GetValue("UBGLAmmo"))
                self:SetClip2(self:GetCapacity(true))
            end
        else
            if self.LastUBGLAmmo and SERVER then
                if !IsValid(self:GetOwner()) or !self:GetOwner():IsPlayer() then return end
                self:GetOwner():GiveAmmo(self:Clip2(), self.LastUBGLAmmo)
                self:SetClip2(0)
            end
        end

        if self:GetProcessedValue("BottomlessClip") then
            self:RestoreClip()
        end
    end

    self:SetupAnimProxy()

    self:SetBaseSettings()
end

function SWEP:ToggleCustomize(on)
    if on == self:GetCustomize() then return end

    self:SetCustomize(on)

    self:SetShouldHoldType()

    self:SetInSights(false)

    if !on then
        if self:HasAnimation("postcustomize") then
            self:CancelReload()
            self:PlayAnimation("postcustomize", 1, true)
        end
    end
end

function SWEP:GetAttBlocked(atttbl)
    local eles = self:GetElements()

    if atttbl.ExcludeElements then
        for _, group in ipairs(atttbl.ExcludeElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return true end
        end
    end

    if atttbl.RequireElements then
        for _, group in ipairs(atttbl.RequireElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return false end
        end

        return true
    end

    return false
end

function SWEP:SlotInvalid(slottbl)
    if GetConVar("arc9_atts_anarchy"):GetBool() then return false end

    local eles = self:GetElements()

    if slottbl.ExcludeElements then
        for _, group in ipairs(slottbl.ExcludeElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return true end
        end
    end

    local totalcount = self:CountAttachments()

    if totalcount > ARC9.GetMaxAtts() then return true end

    if slottbl.RequireElements then
        for _, group in ipairs(slottbl.RequireElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = true
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = false break end
            end

            if !ok then return true end
        end
    end

    local att = slottbl.Installed

    if !att then return false end

    if self:RunHook("Hook_BlockAttachment", {att = att, slottbl = slottbl}) == false then return true end

    if (slottbl.RejectAttachments or {})[att] then return true end

    local cat = slottbl.Category

    if !istable(cat) then
        cat = {cat}
    end

    local atttbl = ARC9.GetAttTable(att)

    if atttbl.Max then
        local count = self:CountAttachments(att)

        if slottbl.Installed then
            local installed_atttbl = ARC9.GetAttTable(slottbl.Installed)

            if slottbl.Installed == installed_atttbl.InvAtt then
                count = count - 1
            end
        end

        if count > atttbl.Max then return true end
    end

    if self:GetAttBlocked(atttbl) then return true end
    if atttbl.AdminOnly and (self:GetOwner():IsNPC() or !self:GetOwner():IsAdmin()) then return true end

    local attcat = atttbl.Category

    if !istable(attcat) then
        attcat = {attcat}
    end

    local cat_true = false

    for _, c in ipairs(attcat) do
        if (slottbl.RejectAttachments or {})[c] then return false end
        if table.HasValue(cat, c) then
            cat_true = true
        end
    end

    return !cat_true
end

function SWEP:GetSlotBlocked(slottbl)
    local eles = self:GetElements()

    if slottbl.ExcludeElements then
        for _, group in ipairs(slottbl.ExcludeElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = false
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = true break end
            end

            if !ok then return true end
        end
    end

    local totalcount = self:CountAttachments()

    if totalcount >= ARC9.GetMaxAtts() then return true end

    if slottbl.RequireElements then
        for _, group in ipairs(slottbl.RequireElements) do
            if !istable(group) then
                group = {group}
            end

            local ok = true
            for _, ele in ipairs(group) do
                if !eles[ele] then ok = false break end
            end

            if !ok then return true end
        end
    end

    return false
end

function SWEP:CanAttach(addr, att, slottbl)
    if ARC9.Blacklist[att] then return false end

    if GetConVar("arc9_atts_anarchy"):GetBool() then return true end
    if GetConVar("arc9_atts_nocustomize"):GetBool() then return false end

    slottbl = slottbl or self:LocateSlotFromAddress(addr)

    if self:RunHook("Hook_BlockAttachment", {att = att, slottbl = slottbl}) == false then return false end

    if self:GetSlotBlocked(slottbl) then return false end

    if (slottbl.RejectAttachments or {})[att] then return false end

    local cat = slottbl.Category

    if !istable(cat) then
        cat = {cat}
    end

    local atttbl = ARC9.GetAttTable(att)

    if atttbl.Max then
        local count = self:CountAttachments(att)

        if slottbl.Installed then
            local installed_atttbl = ARC9.GetAttTable(slottbl.Installed)

            if slottbl.Installed == installed_atttbl.InvAtt then
                count = count - 1
            end
        end

        if count >= atttbl.Max then return false end
    end

    if self:GetAttBlocked(atttbl) then return false end
    if atttbl.AdminOnly and !self:GetOwner():IsAdmin() then return false end

    local attcat = atttbl.Category

    if !istable(attcat) then
        attcat = {attcat}
    end

    local cat_true = false

    for _, c in ipairs(attcat) do
        if (slottbl.RejectAttachments or {})[c] then return false end
        if table.HasValue(cat, c) then
            cat_true = true
        end
    end

    return cat_true
end

function SWEP:CanDetach(addr)
    if GetConVar("arc9_atts_nocustomize"):GetBool() then return false end

    local slottbl = self:LocateSlotFromAddress(addr)

    if slottbl and slottbl.Integral then return false end

    return true
end

function SWEP:CountAttachments(countatt)
    local qty = 0

    for _, att in ipairs(self:GetAttachmentList()) do
        if !countatt then
            qty = qty + 1
        else
            if countatt == att then
                qty = qty + 1
            end
        end
    end

    return qty
end

function SWEP:ToggleAllStatsOnF()
    if self:GetReloading() then return true end

    local toggled = false

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = self:GetFinalAttTable(slottbl)

        if !atttbl.ToggleStats then continue end
        if !atttbl.ToggleOnF then continue end

        toggled = true

        self:ToggleStat(slottbl.Address)
    end

    if toggled then
        self:RunHook("Hook_ToggleAtts")
        self:PostModify()
        return true
    end
end

function SWEP:CanToggleAllStatsOnF()
    local toggled = false

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = self:GetFinalAttTable(slottbl)

        if !atttbl.ToggleStats then continue end
        if !atttbl.ToggleOnF then continue end

        toggled = true
    end

    return toggled
end

function SWEP:ToggleStat(addr, val)
    val = val or 1
    local slottbl = self:LocateSlotFromAddress(addr)

    if !slottbl.Installed then return end

    local atttbl = self:GetFinalAttTableFromAddress(addr)

    if !atttbl.ToggleStats then return end

    slottbl.ToggleNum = (slottbl.ToggleNum or 1) + val

    if slottbl.ToggleNum > #atttbl.ToggleStats then
        slottbl.ToggleNum = 1
    elseif slottbl.ToggleNum < 1 then
        slottbl.ToggleNum = #atttbl.ToggleStats
    end
end