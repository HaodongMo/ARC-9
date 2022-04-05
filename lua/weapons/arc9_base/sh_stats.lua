SWEP.StatCache = {}
SWEP.HookCache = {}
SWEP.AffectorsCache = nil
SWEP.HasNoAffectors = {}
SWEP.ProcessedValueTickCache = {}
SWEP.ProcessedValueTick = 0

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


local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
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

    for _, tbl in ipairs(self:GetAllAffectors()) do
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

    for _, slot in ipairs(self:GetSubSlotList()) do
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

local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

local pvtick = 0
local pv_move = 0
local pv_shooting = 0
local pv_melee = 0

function SWEP:GetProcessedValue(val, base)
    local stat = self:GetValue(val, base)

    -- if true then return stat end

    if self:GetJammed() and val == "Malfunction" then
        return true
    end

    if self:GetHeatLockout() and val == "Overheat" then
        return true
    end

    if !self.HasNoAffectors[val .. "True"] and GetConVar("arc9_truenames"):GetBool() then
        stat = self:GetValue(val, stat, "True")
    end

    if self:GetOwner():IsValid() and !self:GetOwner():IsNPC() then
        if !self.HasNoAffectors[val .. "MidAir"] and !self:GetOwner():OnGround() or self:GetOwner():GetMoveType() == MOVETYPE_NOCLIP then
            stat = self:GetValue(val, stat, "MidAir")
        end

        if !self.HasNoAffectors[val .. "Crouch"] and self:GetOwner():Crouching() and self:GetOwner():OnGround() then
            stat = self:GetValue(val, stat, "Crouch")
        end
    end

    if self:GetBurstCount() == 0 and !self.HasNoAffectors[val .. "FirstShot"] then
        stat = self:GetValue(val, stat, "FirstShot")
    end

    if self:Clip1() == 0 and !self.HasNoAffectors[val .. "Empty"] then
        stat = self:GetValue(val, stat, "Empty")
    end

    if !self:GetUBGL() and self:GetValue("Silencer") and !self.HasNoAffectors[val .. "Silencer"] then
        stat = self:GetValue(val, stat, "Silenced")
    end

    if self:GetUBGL() and !self.HasNoAffectors[val .. "UBGL"] then
        stat = self:GetValue(val, stat, "UBGL")

        if self:Clip2() == 0 and !self.HasNoAffectors[val .. "EmptyUBGL"] then
            stat = self:GetValue(val, stat, "EmptyUBGL")
        end
    end

    if self:GetNthShot() % 2 == 0  and !self.HasNoAffectors[val .. "EvenShot"] then
        stat = self:GetValue(val, stat, "EvenShot")
    elseif !self.HasNoAffectors[val .. "OddShot"] then
        stat = self:GetValue(val, stat, "OddShot")
    end

    if self:GetNthReload() % 2 == 0 and !self.HasNoAffectors[val .. "EvenReload"] then
        stat = self:GetValue(val, stat, "EvenReload")
    elseif !self.HasNoAffectors[val .. "OddReload"] then
        stat = self:GetValue(val, stat, "OddReload")
    end

    if self:GetBlindFire() and !self.HasNoAffectors[val .. "BlindFire"] then
        stat = self:GetValue(val, stat, "BlindFire")
    end

    if self:GetBipod() then
        stat = self:GetValue(val, stat, "Bipod")
    end

    if !self.HasNoAffectors[val .. "Sights"] or !self.HasNoAffectors[val .. "HipFire"] then
        if isnumber(stat) then
            stat = Lerp(self:GetSightAmount(), self:GetValue(val, stat, "HipFire"), self:GetValue(val, stat, "Sights"))
        else
            if self:GetSightAmount() >= 1 then
                stat = self:GetValue(val, stat, "Sights")
            else
                stat = self:GetValue(val, stat, "HipFire")
            end
        end
    end

    if !self.HasNoAffectors[val .. "Melee"] then
        if self:GetLastMeleeTime() < CurTime() then
            local d = pv_melee

            if pvtick != CurTime() then
                local pft = CurTime() - self:GetLastMeleeTime()
                d = pft / (self:GetValue("PreBashTime") + self:GetValue("PostBashTime"))

                d = math.Clamp(d, 0, 1)

                d = 1 - d

                pv_melee = d
            end

            if isnumber(stat) then
                stat = Lerp(d, stat, self:GetValue(val, stat, "Melee"))
            else
                if d > 0 then
                    stat = self:GetValue(val, stat, "Melee")
                end
            end
        end
    end

    if !self.HasNoAffectors[val .. "Shooting"] then
        if self:GetNextPrimaryFire() + 0.1 > CurTime() then
            local d = pv_shooting

            if pvtick != CurTime() then
                local pft = CurTime() - self:GetNextPrimaryFire() + 0.1
                d = pft / 0.1

                d = math.Clamp(d, 0, 1)

                pv_shooting = d
            end

            if isnumber(stat) then
                stat = Lerp(d, stat, self:GetValue(val, stat, "Shooting"))
            else
                if d > 0 then
                    stat = self:GetValue(val, stat, "Shooting")
                end
            end
        end
    end

    if !self.HasNoAffectors[val .. "Recoil"] then
        if self:GetRecoilAmount() > 0 then
            stat = self:GetValue(val, stat, "Recoil", self:GetRecoilAmount())
        end
    end

    if !self.HasNoAffectors[val .. "Move"] then
        if self:GetOwner():IsValid() then
            local spd = pv_move
            if pvtick != CurTime() then
                spd = math.min(self:GetOwner():GetAbsVelocity():Length(), 250)

                spd = spd / 250

                pv_move = spd
            end

            if isnumber(stat) then
                stat = Lerp(spd, stat, self:GetValue(val, stat, "Move"))
            else
                if spd > 0 then
                    stat = self:GetValue(val, stat, "Move")
                end
            end
        end
    end

    pvtick = CurTime()

    return stat
end

function SWEP:GetValue(val, base, condition, amount)
    condition = condition or ""
    amount = amount or 1
    local stat = base

    if stat == nil then
        stat = self:GetTable()[val]
    end

    if self.HasNoAffectors[val .. condition] == true then
        return stat
    end

    local unaffected = true

    if istable(stat) then
        stat.BaseClass = nil
    end

    if self.StatCache[tostring(base) .. val .. condition] != nil then
        stat = self.StatCache[tostring(base) .. val .. condition]

        local oldstat = stat
        stat = self:RunHook(val .. "Hook" .. condition, stat)

        if stat == nil then
            stat = oldstat
        end

        if istable(stat) then
            stat.BaseClass = nil
        end

        return stat
    end

    local priority = 0

    if !self.ExcludeFromRawStats[val] then
        for _, tbl in ipairs(self:GetAllAffectors()) do
            local att_priority = tbl[val .. condition .. "_Priority"] or 1

            if tbl[val .. condition] != nil and att_priority >= priority then
                stat = tbl[val .. condition]
                priority = att_priority
                unaffected = false
            end
        end
    end

    for _, tbl in ipairs(self:GetAllAffectors()) do
        local att_priority = tbl[val .. "Override" .. condition .. "_Priority"] or 1

        if tbl[val .. "Override" .. condition] != nil and att_priority >= priority then
            stat = tbl[val .. "Override" .. condition]
            priority = att_priority
            unaffected = false
        end
    end

    if isnumber(stat) then

        for _, tbl in ipairs(self:GetAllAffectors()) do
            if tbl[val .. "Add" .. condition] != nil then
                if !pcall(function() stat = stat + (tbl[val .. "Add" .. condition] * amount) end) then
                    print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO ADD INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                end
                unaffected = false
            end
        end

        for _, tbl in ipairs(self:GetAllAffectors()) do
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