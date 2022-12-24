SWEP.StatCache = {}
SWEP.HookCache = {}
SWEP.AffectorsCache = nil
SWEP.HasNoAffectors = {}

SWEP.ExcludeFromRawStats = {
    ["PrintName"] = true,
}

function SWEP:InvalidateCache()
    if game.SinglePlayer() then
        self:CallOnClient("InvalidateCache")
    end
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

        data = hook.Run("ARC9_" .. val, self, data) or data

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

    data = hook.Run("ARC9_" .. val, self, data) or data

    return data, any
end

function SWEP:GetFinalAttTableFromAddress(address)
    return self:GetFinalAttTable(self:LocateSlotFromAddress(address))
end

function SWEP:GetFinalAttTable(slot)
    if !slot then return {} end
    if !slot.Installed then return {} end

    local atttbl = table.Copy(ARC9.GetAttTable(slot.Installed) or {})

    if self.AttachmentTableOverrides and self.AttachmentTableOverrides[slot.Installed] then
        atttbl = table.Merge(atttbl, self.AttachmentTableOverrides[slot.Installed])
    end

    if atttbl.ToggleStats then
        local toggletbl = atttbl.ToggleStats[slot.ToggleNum or 1] or {}

        table.Merge(atttbl, toggletbl)
    end

    return atttbl
end

function SWEP:GetAllAffectors()
    if self.AffectorsCache then return self.AffectorsCache end

    local aff = {}

    table.insert(aff, table.Copy(self:GetTable()))

    if !ARC9.OverrunSights then
        ARC9.OverrunSights = true
        local sight = self:GetSight()

        if sight.OriginalSightTable then
            table.insert(aff, sight.OriginalSightTable)
        end

        ARC9.OverrunSights = false
    end

    for _, slot in ipairs(self:GetSubSlotList()) do
        local atttbl = self:GetFinalAttTable(slot)

        if atttbl then
            table.insert(aff, atttbl)
        end
    end

    local config = string.Split( GetConVar("arc9_modifiers"):GetString(), "\\n" )
    local c4 = {}
    for i, v in ipairs(config) do
        local swig = string.Split( v, "\\t" )
        -- local c2 = c4[swig[1]]
        if tonumber(swig[2]) then
            c4[swig[1]] = tonumber(swig[2])
        elseif swig[2] == "true" or swig[2] == "false" then
            c4[swig[1]] = swig[2] == "true"
        else
            c4[swig[1]] = swig[2]
        end
    end
    table.insert(aff, c4)

    if !ARC9.OverrunFiremodes then
        ARC9.OverrunFiremodes = true
        table.insert(aff, self:GetCurrentFiremodeTable())
        ARC9.OverrunFiremodes = false
    end

    if !ARC9.OverrunAttElements then
        ARC9.OverrunAttElements = true

        for i, k in pairs(self:GetElements()) do
            if !k then continue end
            local ele = self.AttachmentElements[i]

            if ele then
                table.insert(aff, ele)
            end
        end

        ARC9.OverrunAttElements = false
    end

    self.AffectorsCache = aff

    return aff
end

local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

-- local pvtick = 0
-- local pv_move = 0
-- local pv_shooting = 0
-- local pv_melee = 0

local singleplayer = game.SinglePlayer()

SWEP.PV_Tick = 0
SWEP.PV_Move = 0
SWEP.PV_Shooting = 0
SWEP.PV_Melee = 0

SWEP.PV_Cache = {}


function SWEP:GetProcessedValue(val, base, cmd)
    local ct = CurTime()
    local upct = UnPredictedCurTime()

    if CLIENT and self.PV_Cache[tostring(val) .. tostring(base)] != nil and self.PV_Tick == upct then
        return self.PV_Cache[tostring(val) .. tostring(base)]
    end

    if self.PV_Tick != upct then
        self.PV_Cache = {}
    end

    local stat = self:GetValue(val, base)

    local ubgl = self:GetUBGL()
    local owner = self:GetOwner()

    -- if true then return stat end

    if self:GetJammed() and val == "Malfunction" then
        return true
    end

    if self:GetHeatLockout() and val == "Overheat" then
        return true
    end

    if owner:IsNPC() then
        stat = self:GetValue(val, stat, "NPC")
    end

    if GetConVar("arc9_truenames"):GetBool() then
        stat = self:GetValue(val, stat, "True")
    end

    if owner:IsValid() and !owner:IsNPC() then
        if !owner:OnGround() or owner:GetMoveType() == MOVETYPE_NOCLIP then
            stat = self:GetValue(val, stat, "MidAir")
        end

        if owner:Crouching() and owner:OnGround() then
            stat = self:GetValue(val, stat, "Crouch")
        end
    end

    if self:GetReloading() then
        stat = self:GetValue(val, stat, "Reload")
    end

    if self:GetBurstCount() == 0 then
        stat = self:GetValue(val, stat, "FirstShot")
    end

    if self:Clip1() == 0 then
        stat = self:GetValue(val, stat, "Empty")
    end

    if !ubgl and self:GetValue("Silencer") then
        stat = self:GetValue(val, stat, "Silenced")
    end

    if ubgl then
        stat = self:GetValue(val, stat, "UBGL")

        if self:Clip2() == 0 then
            stat = self:GetValue(val, stat, "EmptyUBGL")
        end
    end

    if bit.band(self:GetNthShot(), 1) == 0 then
        stat = self:GetValue(val, stat, "EvenShot")
    else
        stat = self:GetValue(val, stat, "OddShot")
    end

    if bit.band(self:GetNthReload(), 1) == 0  then
        stat = self:GetValue(val, stat, "EvenReload")
    else
        stat = self:GetValue(val, stat, "OddReload")
    end

    // if self:GetBlindFire() then
    //     stat = self:GetValue(val, stat, "BlindFire")
    // end

    if self:GetBipod() then
        stat = self:GetValue(val, stat, "Bipod")
    end

    if !self.HasNoAffectors[val .. "Sights"] or !self.HasNoAffectors[val .. "HipFire"] then
        if isnumber(stat) then
            local hipfire = self:GetValue(val, stat, "HipFire")
            local sights = self:GetValue(val, stat, "Sights")

            if isnumber(hipfire) and isnumber(sights) then
                stat = Lerp(self:GetSightAmount(), hipfire, sights)
            end
        else
            if self:GetSightAmount() >= 1 then
                stat = self:GetValue(val, stat, "Sights")
            else
                stat = self:GetValue(val, stat, "HipFire")
            end
        end
    end

    if base != "HeatCapacity" and !self.HasNoAffectors[val .. "Hot"]  and self:GetHeatAmount() > 0 then
        if isnumber(stat) then
            local hot = self:GetValue(val, stat, "Hot")

            if isnumber(hot) then
                stat = Lerp(self:GetHeatAmount() / self:GetProcessedValue("HeatCapacity"), stat, hot)
            end
        else
            if self:GetHeatAmount() > 0 then
                stat = self:GetValue(val, stat, "Hot")
            end
        end
    end

    local getlastmeleetime = self:GetLastMeleeTime()

    if !self.HasNoAffectors[val .. "Melee"] and getlastmeleetime < ct then
        local pft = ct - getlastmeleetime
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


    if !self.HasNoAffectors[val .. "Shooting"] then
        local getnextprimaryfire = self:GetNextPrimaryFire()

        if getnextprimaryfire + 0.1 > ct then
            local d
            local pft = ct - getnextprimaryfire + 0.1
            d = pft / 0.1

            d = math.Clamp(d, 0, 1)

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
        local getrecoilamount = self:GetRecoilAmount()
        if getrecoilamount > 0 then
            stat = self:GetValue(val, stat, "Recoil", getrecoilamount)
        end
    end

    if !self.HasNoAffectors[val .. "Move"] and IsValid(owner) then
        local spd = self.PV_Move
        local maxspd = owner:IsPlayer() and owner:GetWalkSpeed() or 250
        if singleplayer or CLIENT or self.PV_Tick != upct then
            spd = math.min(owner:GetAbsVelocity():Length(), maxspd) / maxspd

            self.PV_Move = spd
        end

        if isnumber(stat) then
            stat = Lerp(spd, stat, self:GetValue(val, stat, "Move"))
        else
            if spd > 0 then
                stat = self:GetValue(val, stat, "Move")
            end
        end
    end

    self.PV_Tick = upct
    self.PV_Cache[tostring(val) .. tostring(base)] = stat

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
        -- stat = self.StatCache[tostring(base) .. val .. condition]
        stat = self.StatCache[tostring(base) .. val .. condition]

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

    local getallaffectors = self:GetAllAffectors()

    if !self.ExcludeFromRawStats[val] then
        for _, tbl in ipairs(getallaffectors) do
            local att_priority = tbl[val .. condition .. "_Priority"] or 1

            if tbl[val .. condition] != nil and att_priority >= priority then
                stat = tbl[val .. condition]
                priority = att_priority
                unaffected = false
            end
        end
    end

    for _, tbl in ipairs(getallaffectors) do
        local att_priority = tbl[val .. "Override" .. condition .. "_Priority"] or 1

        if tbl[val .. "Override" .. condition] != nil and att_priority >= priority then
            stat = tbl[val .. "Override" .. condition]
            priority = att_priority
            unaffected = false
        end
    end

    if isnumber(stat) then
        for _, tbl in ipairs(getallaffectors) do
            if tbl[val .. "Add" .. condition] != nil then
                -- if !pcall(function() stat = stat + (tbl[val .. "Add" .. condition] * amount) end) then
                --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO ADD INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                -- end
                if type(tbl[val .. "Add" .. condition]) == type(stat) then
                    stat = stat + (tbl[val .. "Add" .. condition] * amount)
                end
                unaffected = false
            end
        end

        for _, tbl in ipairs(getallaffectors) do
            if tbl[val .. "Mult" .. condition] != nil then
                -- if !pcall(function() stat = stat * math.pow(tbl[val .. "Mult" .. condition], amount) end) then
                --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO MULTIPLY INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                -- end
                if type(tbl[val .. "Mult" .. condition]) == type(stat) then
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

    self.StatCache[tostring(base) .. val .. condition] = stat
    -- self.StatCache[tostring(base) .. val .. condition] = stat

    local newstat, any = self:RunHook(val .. "Hook" .. condition, stat)

    stat = newstat or stat

    if any then unaffected = false end

    self.HasNoAffectors[val .. condition] = unaffected

    if istable(stat) then
        stat.BaseClass = nil
    end

    return stat
end