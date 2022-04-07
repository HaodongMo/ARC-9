local StatCache = {}
local HookCache = {}
local AffectorsCache = nil
local HasNoAffectors = {}

SWEP.ExcludeFromRawStats = {
    ["PrintName"] = true,
}

function SWEP:InvalidateCache()
    StatCache = {}
    HookCache = {}
    AffectorsCache = nil
    ElementsCache = nil
    self.RecoilPatternCache = {}
    self.ScrollLevels = {}
    HasNoAffectors = {}

    self:SetBaseSettings()
end

function SWEP:RunHook(val, data)
    local any = false

    if HookCache[val] then
        for _, chook in pairs(HookCache[val]) do
            local d = chook(self, data)

            if d != nil then
                data = d
            end

            any = true
        end

        return data, any
    end

    HookCache[val] = {}

    for _, tbl in ipairs(self:GetAllAffectors()) do
        if tbl[val] then

            table.insert(HookCache[val], tbl[val])

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
    if AffectorsCache then return AffectorsCache end

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

    AffectorsCache = aff

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

local pvcache = {}

function SWEP:GetProcessedValue(val, base)
    if CLIENT and pvcache[tostring(val) .. tostring(base)] != nil and pvtick == UnPredictedCurTime() then
        return pvcache[tostring(val) .. tostring(base)]
    end

    if pvtick != UnPredictedCurTime() then
        pvcache = {}
    end

    local stat = self:GetValue(val, base)

    -- if true then return stat end

    if self:GetJammed() and val == "Malfunction" then
        return true
    end

    if self:GetHeatLockout() and val == "Overheat" then
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

    if !self:GetUBGL() and self:GetValue("Silencer") then
        stat = self:GetValue(val, stat, "Silenced")
    end

    if self:GetUBGL() then
        stat = self:GetValue(val, stat, "UBGL")

        if self:Clip2() == 0 then
            stat = self:GetValue(val, stat, "EmptyUBGL")
        end
    end

    if self:GetNthShot() % 2 == 0 then
        stat = self:GetValue(val, stat, "EvenShot")
    else
        stat = self:GetValue(val, stat, "OddShot")
    end

    if self:GetNthReload() % 2 == 0  then
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

    if !HasNoAffectors[val .. "Sights"] or !HasNoAffectors[val .. "HipFire"] then
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

    if !HasNoAffectors[val .. "Melee"] then
        if self:GetLastMeleeTime() < CurTime() then
            local d = pv_melee

            if pvtick != UnPredictedCurTime() then
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

    if !HasNoAffectors[val .. "Shooting"] then
        if self:GetNextPrimaryFire() + 0.1 > CurTime() then
            local d = pv_shooting

            if pvtick != UnPredictedCurTime() then
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

    if !HasNoAffectors[val .. "Recoil"] then
        if self:GetRecoilAmount() > 0 then
            stat = self:GetValue(val, stat, "Recoil", self:GetRecoilAmount())
        end
    end

    if !HasNoAffectors[val .. "Move"] then
        if self:GetOwner():IsValid() then
            local spd = pv_move
            if pvtick != UnPredictedCurTime() then
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

    pvtick = UnPredictedCurTime()
    pvcache[tostring(val) .. tostring(base)] = stat

    return stat
end

function SWEP:GetValue(val, base, condition, amount)
    condition = condition or ""
    amount = amount or 1
    local stat = base

    if stat == nil then
        stat = self:GetTable()[val]
    end

    if HasNoAffectors[val .. condition] == true then
        return stat
    end

    local unaffected = true

    if istable(stat) then
        stat.BaseClass = nil
    end

    if StatCache[tostring(base) .. val .. condition] != nil then
        stat = StatCache[tostring(base) .. val .. condition]

        local oldstat = stat
        stat = self:RunHook(val .. "Hook" .. condition, stat)

        if stat == nil then
            stat = oldstat
        end

        -- if istable(stat) then
        --     stat.BaseClass = nil
        -- end

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
                -- if !pcall(function() stat = stat + (tbl[val .. "Add" .. condition] * amount) end) then
                --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO ADD INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                -- end
                if isnumber(tbl[val .. "Add" .. condition]) then
                    stat = stat + (tbl[val .. "Add" .. condition] * amount)
                end
                unaffected = false
            end
        end

        for _, tbl in ipairs(self:GetAllAffectors()) do
            if tbl[val .. "Mult" .. condition] != nil then
                -- if !pcall(function() stat = stat * math.pow(tbl[val .. "Mult" .. condition], amount) end) then
                --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO MULTIPLY INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                -- end
                if isnumber(tbl[val .. "Mult" .. condition]) then
                    if amount > 1 then
                        stat = stat * (math.pow(tbl[val .. "Mult" .. condition], amount))
                    else
                        stat = stat * tbl[val .. "Mult" .. condition]
                    end
                end
                unaffected = false
            end
        end

    end

    StatCache[tostring(base) .. val .. condition] = stat

    local newstat, any = self:RunHook(val .. "Hook" .. condition, stat)

    stat = newstat or stat

    if any then unaffected = false end

    HasNoAffectors[val .. condition] = unaffected

    if istable(stat) then
        stat.BaseClass = nil
    end

    return stat
end