SWEP.StatCache = {}
SWEP.HookCache = {}
SWEP.AffectorsCache = nil
SWEP.HasNoAffectors = {}

SWEP.ExcludeFromRawStats = {
    ["PrintName"] = true,
}

function SWEP:InvalidateCache()
    self.StatCache = {}
    self.HookCache = {}
    self.AffectorsCache = nil
    self.ElementsCache = nil
    self.RecoilPatternCache = {}
    self.ScrollLevels = {}
    self.HasNoAffectors = {}

    self:SetBaseSettings()
end

function SWEP:RunHook(val, data)
    local any = false

    if self.HookCache[val] then
        for _, chook in pairs(self.HookCache[val]) do
            local d = chook(self, data)

            if d != nil then
                data = d
            end

            any = true
        end

        return data, any
    end

    self.HookCache[val] = {}

    for _, tbl in pairs(self:GetAllAffectors()) do
        if tbl[val] then

            table.insert(self.HookCache[val], tbl[val])

            if !pcall(function()
                local d = tbl[val](self, data)

                if d != nil then
                    data = d
                end

                any = true
            end) then
                print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO RUN INVALID HOOK ON " .. val .. "!")
            end
        end
    end

    return data, any
end

function SWEP:GetFinalAttTableFromAddress(address)
    return self:GetFinalAttTable(self:LocateSlotFromAddress(address))
end

function SWEP:GetFinalAttTable(slot)
    if !slot then return {} end
    if !slot.Installed then return {} end

    local atttbl = ARC9.GetAttTable(slot.Installed)

    if atttbl.ToggleStats then
        local tbl = table.Copy(atttbl)
        local toggletbl = atttbl.ToggleStats[slot.ToggleNum or 1] or {}

        table.Merge(tbl, toggletbl)

        return tbl
    else
        return atttbl
    end
end

function SWEP:GetAllAffectors()
    if self.AffectorsCache then return self.AffectorsCache end

    local aff = {}

    table.insert(aff, self:GetTable())

    if !ARC9.Overrun then
        ARC9.Overrun = true
        local sight = self:GetSight()

        if sight.OriginalSightTable then
            table.insert(aff, sight.OriginalSightTable)
        end

        ARC9.Overrun = false
    end

    for _, slot in pairs(self:GetSubSlotList()) do
        local atttbl = self:GetFinalAttTable(slot)

        if atttbl then
            table.insert(aff, atttbl)
        end
    end

    if !ARC9.Overrun then
        ARC9.Overrun = true
        table.insert(aff, self:GetCurrentFiremodeTable())
        ARC9.Overrun = false
    end

    self.AffectorsCache = aff

    return aff
end

function SWEP:GetProcessedValue(val, base)
    local stat = self:GetValue(val, base)

    if val == "Malfunction" and self:GetJammed() then
        return true
    end

    if val == "Overheat" and self:GetHeatLockout() then
        return true
    end

    if GetConVar("arc9_truenames"):GetBool() then
        stat = self:GetValue(val, stat, "True")
    end

    if self:GetOwner():IsValid() and !self:GetOwner():IsNPC() then
        if !self:GetOwner():OnGround() or self:GetOwner():GetMoveType() == MOVETYPE_NOCLIP then
            stat = self:GetValue(val, stat, "MidAir")
        end

        if self:GetOwner():Crouching() and self:GetOwner():OnGround() then
            stat = self:GetValue(val, stat, "Crouch")
        end
    end

    if self:GetBurstCount() == 0 then
        stat = self:GetValue(val, stat, "FirstShot")
    end

    if self:Clip1() == 0 then
        stat = self:GetValue(val, stat, "Empty")
    end

    if self:GetValue("Silencer") then
        stat = self:GetValue(val, stat, "Silenced")
    end

    if self:GetNthShot() % 2 == 0 then
        stat = self:GetValue(val, stat, "EvenShot")
    else
        stat = self:GetValue(val, stat, "OddShot")
    end

    if self:GetNthReload() % 2 == 0 then
        stat = self:GetValue(val, stat, "EvenReload")
    else
        stat = self:GetValue(val, stat, "OddReload")
    end

    if self:GetBlindFire() then
        stat = self:GetValue(val, stat, "BlindFire")
    end

    if self:GetBipod() then
        stat = self:GetValue(val, stat, "Bipod")
    end

    if isnumber(stat) then
        stat = Lerp(self:GetSightAmount(), self:GetValue(val, stat, "HipFire"), self:GetValue(val, stat, "Sights"))
    else
        if self:GetSightAmount() >= 1 then
            stat = self:GetValue(val, stat, "Sights")
        else
            stat = self:GetValue(val, stat, "HipFire")
        end
    end

    if self:GetLastMeleeTime() < CurTime() then
        local pft = CurTime() - self:GetLastMeleeTime()
        local d = pft / (self:GetValue("PreBashTime") + self:GetValue("PostBashTime"))

        d = math.Clamp(d, 0, 1)

        d = 1 - d

        if isnumber(stat) then
            stat = Lerp(d, stat, self:GetValue(val, stat, "Melee"))
        else
            if d > 0 then
                stat = self:GetValue(val, stat, "Melee")
            end
        end
    end

    if self:GetNextPrimaryFire() + 0.1 > CurTime() then
        local pft = CurTime() - self:GetNextPrimaryFire() + 0.1
        local d = pft / 0.1

        d = math.Clamp(d, 0, 1)

        if isnumber(stat) then
            stat = Lerp(d, stat, self:GetValue(val, stat, "Shooting"))
        else
            if d > 0 then
                stat = self:GetValue(val, stat, "Shooting")
            end
        end
    end

    if self:GetRecoilAmount() > 0 then
        stat = self:GetValue(val, stat, "Recoil", self:GetRecoilAmount())
    end

    if self:GetOwner():IsValid() then
        local spd = math.min(self:GetOwner():GetAbsVelocity():Length(), 250)

        spd = spd / 250

        if isnumber(stat) then
            stat = Lerp(spd, stat, self:GetValue(val, stat, "Move"))
        else
            if spd > 0 then
                stat = self:GetValue(val, stat, "Move")
            end
        end
    end

    return stat
end

function SWEP:GetValue(val, base, condition, amount)
    condition = condition or ""
    amount = amount or 1
    local stat = base or self:GetTable()[val]

    if self.HasNoAffectors[val .. condition] == true then
        return stat
    end

    local unaffected = true

    if istable(stat) then
        stat.BaseClass = nil
    end

    if self.StatCache[tostring(base) .. val .. condition] then
        stat = self.StatCache[tostring(base) .. val .. condition]

        stat = self:RunHook(val .. "Hook" .. condition, stat) or stat

        if istable(stat) then
            stat.BaseClass = nil
        end

        return stat
    end

    local priority = 0

    if !self.ExcludeFromRawStats[val] then
        for _, tbl in pairs(self:GetAllAffectors()) do
            local att_priority = tbl[val .. condition .. "_Priority"] or 1

            if tbl[val .. condition] != nil and att_priority >= priority then
                stat = tbl[val .. condition]
                priority = att_priority
                unaffected = false
            end
        end
    end

    for _, tbl in pairs(self:GetAllAffectors()) do
        local att_priority = tbl[val .. "Override" .. condition .. "_Priority"] or 1

        if tbl[val .. "Override" .. condition] != nil and att_priority >= priority then
            stat = tbl[val .. "Override" .. condition]
            priority = att_priority
            unaffected = false
        end
    end

    if isnumber(stat) then

        for _, tbl in pairs(self:GetAllAffectors()) do
            if tbl[val .. "Add" .. condition] != nil then
                if !pcall(function() stat = stat + (tbl[val .. "Add" .. condition] * amount) end) then
                    print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO ADD INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                end
                unaffected = false
            end
        end

        for _, tbl in pairs(self:GetAllAffectors()) do
            if tbl[val .. "Mult" .. condition] != nil then
                if !pcall(function() stat = stat * math.pow(tbl[val .. "Mult" .. condition], amount) end) then
                    print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO MULTIPLY INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                end
                unaffected = false
            end
        end

    end

    self.StatCache[tostring(base) .. val .. condition] = stat

    local newstat, any = self:RunHook(val .. "Hook" .. condition, stat)

    stat = newstat or stat

    if any then unaffected = false end

    self.HasNoAffectors[val .. condition] = unaffected

    if istable(stat) then
        stat.BaseClass = nil
    end

    return stat
end