function SWEP:NPC_PrimaryAttack()
    if !IsValid(self:GetOwner()) then return end
    if self:Clip1() <= 0 then self:GetOwner():SetSchedule(SCHED_HIDE_AND_RELOAD) return end

    local owner = self:GetOwner()

    self:SetBaseSettings()
    self:SetShouldHoldType()
    self:DoShootSounds()
    self:DoEffects()
    self:DoEject()

    local delay = 60 / self:GetProcessedValue("RPM")

    self:SetNextPrimaryFire(CurTime() + delay)

    local spread = self:GetNPCBulletSpread(owner:GetCurrentWeaponProficiency()) / 36
    spread = spread + self:GetProcessedValue("Spread")

    self:DoProjectileAttack(owner:GetShootPos(), owner:GetAimVector():Angle(), spread)

    if !self:GetProcessedValue("BottomlessClip") then
        self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
    end
end

function SWEP:GetNPCBulletSpread(prof)
    prof = prof or 0
    local mode = self:GetCurrentFiremode()
    local mult = GetConVar("arc9_npc_spread"):GetFloat()

    mult = mult * 0.5

    if mode < 0 then
        return mult * 10 / (prof + 1)
    elseif mode == 0 then
        return mult * 20 / (prof + 1)
    elseif mode == 1 then
        if math.Rand(0, 100) < (prof + 1) * 5 then
            return mult * 1 / (prof + 1)
        else
            return mult * 25 / (prof + 1)
        end
    elseif mode >= 2 then
        return mult * 20 / (prof + 1)
    end

    return mult * 15
end

function SWEP:GetNPCSpread()
    local spread = self:GetValue("Spread")

    spread = math.max(spread, 0)

    return spread
end

function SWEP:GetNPCBurstSettings()
    local mode = self:GetCurrentFiremode()

    local delay = 60 / self:GetValue("RPM")

    self:SetNextPrimaryFire(CurTime() + delay)

    if !mode then return 1, 1, delay end

    if mode < 0 then
        return 2, math.floor(0.5 * (self:GetOwner():GetCurrentWeaponProficiency()) / delay), delay
    elseif mode == 0 then
        return 0, 0, delay
    elseif mode == 1 then
        return 1, 1, delay + math.Rand(0.3, 0.6)
    elseif mode >= 2 then
        return mode, mode, delay
    end
end

function SWEP:GetNPCRestTimes()
    return 0.33, 1
end

function SWEP:CanBePickedUpByNPCs()
    return !self.NotForNPCs
end

function SWEP:NPC_Reload()
    self:DropMagazine()
    self:SetNthShot(0)
end

function SWEP:NPC_Initialize()
    self.DefaultAttachments = table.Copy(self.Attachments)

    self:BuildSubAttachments(self.DefaultAttachments)
    self:SetBaseSettings()

    if CLIENT then return end

    if IsValid(self) then
        if !self.WeaponWasGiven then
            -- self:RollRandomAtts(self.Attachments)
            self:QueueForRandomize()
        end
        self:SetClip1(self:GetValue("ClipSize"))
        -- self:PostModify()

        -- self:PruneAttachments()
        -- self:SendWeapon()
    end
end

function SWEP:QueueForRandomize()
    table.insert(ARC9.RandomizeQueue, self)
end

function SWEP:RollRandomAtts(tree)
    local attchance = 66

    for i, slottbl in pairs(tree) do
        if slottbl.MergeSlots then
            if math.Rand(0, 100) > (100 / table.Count(slottbl.MergeSlots)) then continue end
        end

        if math.Rand(0, 100) > attchance then continue end

        local atts = ARC9.GetAttsForCats(slottbl.Category or "")

        -- if math.Rand(0, 100) > 100 / (table.Count(atts) + 1) then slottbl.Installed = nil continue end

        local att = table.Random(atts)

        if !att then slottbl.Installed = nil continue end

        local atttbl = ARC9.GetAttTable(att)

        if !atttbl then continue end

        slottbl.Installed = att

        if atttbl.Attachments then
            slottbl.SubAttachments = table.Copy(atttbl.Attachments)
            self:RollRandomAtts(slottbl.SubAttachments)
        end
    end
end