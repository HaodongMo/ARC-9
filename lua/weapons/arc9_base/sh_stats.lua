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

do
    local CURRENT_AFFECTOR
    local CURRENT_VAL
    local CURRENT_DATA
    local CURRENT_SWEP
    local CURRENT_IS_ANY

    local swepGetAllAffectors = SWEP.GetAllAffectors

    local function affectorCall()
        local d = CURRENT_AFFECTOR[CURRENT_VAL](CURRENT_SWEP, CURRENT_DATA)
    
        if d != nil then
            CURRENT_DATA = d
        end

        CURRENT_IS_ANY = true
    end

    function SWEP:RunHook(val, data)
        CURRENT_IS_ANY = false

        local hookCache = self.HookCache[val]
        if hookCache then
            local len = #hookCache

            for i = 1, len do
                local d = hookCache[i](self, data)
    
                if d != nil then
                    data = d
                end
    
                any = true
            end
    
            data = hook.Run("ARC9_" .. val, self, data) or data
            return data, any
        end
    
        CURRENT_SWEP = self
        CURRENT_DATA = data
        CURRENT_VAL = val

        local i = 0
        local newCache = {}
        local affectors = swepGetAllAffectors(self)
        local affectorsCount = #affectors
        for j = 1, affectorsCount do
            local tbl = affectors[j]
            if tbl[val] then
    
                i = i + 1
                newCache[i] = tbl[val]
    
                CURRENT_AFFECTOR = tbl
                if !pcall(affectorCall) then
                    print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO RUN INVALID HOOK ON " .. val .. "!")
                end
            end
        end
    
        self.HookCache[val] = newCache
        data = hook.Run("ARC9_" .. val, self, data) or data
    
        return data, any
    end
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

do
    local swepRunHook = SWEP.RunHook
    local swepGetAllAffectors = SWEP.GetAllAffectors

    function SWEP:GetValue(val, base, condition, amount)
        condition = condition or ""
        amount = amount or 1
        local stat = base
    
        if stat == nil then
            stat = self[val]
        end

        local valContCondition = val .. condition
    
        if self.HasNoAffectors[valContCondition] == true then
            return stat
        end
    
        local unaffected = true
        local statType = type(stat)
        local baseStr = tostring(base)

        -- damn
        local baseContValContCondition = baseStr .. valContCondition
    
        if statType == 'table' then
            stat.BaseClass = nil
        end

        local statCache = self.StatCache
    
        local cacheAvailable = statCache[baseContValContCondition]
        if cacheAvailable != nil then
            -- stat = self.StatCache[tostring(base) .. valContCondition]
            stat = cacheAvailable
    
            local oldstat = stat
            stat = swepRunHook(self, val .. "Hook" .. condition, stat)
    
            if stat == nil then
                stat = oldstat
            end
    
            -- if istable(stat) then
            --     stat.BaseClass = nil
            -- end
    
            return stat
        end
    
        local priority = 0
    
        local allAffectors = swepGetAllAffectors(self)
        local affectorsCount = #allAffectors
    
        if !self.ExcludeFromRawStats[val] then
            for i = 1, affectorsCount do
                local tbl = allAffectors[i]
                local att_priority = tbl[valContCondition .. "_Priority"] or 1
    
                if att_priority >= priority and tbl[valContCondition] != nil then
                    stat = tbl[valContCondition]
                    priority = att_priority
                    unaffected = false
                end
            end
        end
    
        for i = 1, affectorsCount do
            local tbl = allAffectors[i]
            local att_priority = tbl[val .. "Override" .. condition .. "_Priority"] or 1
    
            local keyName = val .. "Override" .. condition
            if att_priority >= priority and tbl[keyName] != nil then
                stat = tbl[keyName]
                priority = att_priority
                unaffected = false
            end
        end
    
        if statType == 'number' then
            for i = 1, affectorsCount do
                local tbl = allAffectors[i]
                local keyName = val .. "Add" .. condition 
                if tbl[keyName] != nil then
                    -- if !pcall(function() stat = stat + (tbl[val .. "Add" .. condition] * amount) end) then
                    --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO ADD INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                    -- end
                    if type(tbl[keyName]) == type(stat) then
                        stat = stat + (tbl[keyName] * amount)
                    end
                    unaffected = false
                end
            end
    
            for i = 1, affectorsCount do
                local tbl = allAffectors[i]
                local keyName = val .. "Mult" .. condition
                if tbl[keyName] != nil then
                    -- if !pcall(function() stat = stat * math.pow(tbl[val .. "Mult" .. condition], amount) end) then
                    --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO MULTIPLY INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                    -- end
                    if type(tbl[keyName]) == type(stat) then
                        if amount > 1 then
                            stat = stat * (math.pow(tbl[keyName], amount))
                        else
                            stat = stat * tbl[keyName]
                        end
                    end
                    unaffected = false
                end
            end
        end
    
        statCache[baseContValContCondition] = stat
        -- self.StatCache[tostring(base) .. valContCondition] = stat
    
        local newstat, any = swepRunHook(self, val .. "Hook" .. condition, stat)
    
        stat = newstat or stat
    
        if any then unaffected = false end
    
        self.HasNoAffectors[valContCondition] = unaffected
    
        if statType == 'table' then
            stat.BaseClass = nil
        end
    
        return stat
    end
end

do
    local PLAYER = FindMetaTable("Player")
    local playerCrouching = PLAYER.Crouching
    local playerGetWalkSpeed = PLAYER.GetWalkSpeed

    local ENTITY = FindMetaTable("Entity")
    local entityOwner = ENTITY.GetOwner
    local entityIsNPC = ENTITY.IsNPC
    local entityOnGround = ENTITY.OnGround
    local entityIsValid = ENTITY.IsValid
    local entityGetMoveType = ENTITY.GetMoveType
    local entityIsPlayer = ENTITY.IsPlayer
    local entityGetAbsVelocity = ENTITY.GetAbsVelocity

    local WEAPON = FindMetaTable("Weapon")
    local weaponClip1 = WEAPON.Clip1
    local weaponClip2 = WEAPON.Clip2
    local weaponGetNextPrimaryFire = WEAPON.GetNextPrimaryFire

    local arcGetValue = SWEP.GetValue

    local cvarArc9Truenames = GetConVar("arc9_truenames")
    local cvarGetBool = FindMetaTable("ConVar").GetBool

    local vectorLength = FindMetaTable("Vector").Length

    function SWEP:GetProcessedValue(val, base, cmd)
        local swepDt = self.dt

        -- From now on, we will not call `self:GetJammed()`, `self:GetHeatLockout()`
        -- and similar functions, because all they do is just return `self.dt[thing]`
        -- We can (and should, if we want "PERFORMANCE :tm:") do this manually

        if swepDt.Jammed and val == "Malfunction" then
            return true
        end
    
        if swepDt.HeatLockout and val == "Overheat" then
            return true
        end

        local ct = CurTime()
        local upct = UnPredictedCurTime()

        local processedValueName = tostring(val) .. tostring(base)
    
        if CLIENT and self.PV_Cache[processedValueName] != nil and self.PV_Tick == upct then
            return self.PV_Cache[processedValueName]
        end
    
        if self.PV_Tick != upct then
            self.PV_Cache = {}
        end
        
        local stat = arcGetValue(self, val, base)
    
        local ubgl = swepDt.UBGL
        local owner = entityOwner(self)
    
        -- if true then return stat end

        local ownerIsNPC = entityIsNPC(owner)
    
        if ownerIsNPC then
            stat = arcGetValue(self, val, stat, "NPC")
        end
    
        if cvarGetBool(cvarArc9Truenames) then
            stat = arcGetValue(self, val, stat, "True")
        end
    
        if !ownerIsNPC and entityIsValid(owner) then
            local ownerOnGround = entityOnGround(owner)

            if !ownerOnGround or entityGetMoveType(owner) == MOVETYPE_NOCLIP then
                stat = arcGetValue(self, val, stat, "MidAir")
            end
    
            if ownerOnGround and playerCrouching(owner) then
                stat = arcGetValue(self, val, stat, "Crouch")
            end
        end
    
        if swepDt.Reloading then
            stat = arcGetValue(self, val, stat, "Reload")
        end
    
        if swepDt.BurstCount == 0 then
            stat = arcGetValue(self, val, stat, "FirstShot")
        end
    
        if weaponClip1(self) == 0 then
            stat = arcGetValue(self, val, stat, "Empty")
        end
    
        -- !! changed the order
        if ubgl then
            stat = arcGetValue(self, val, stat, "UBGL")
    
            if weaponClip2(self) == 0 then
                stat = arcGetValue(self, val, stat, "EmptyUBGL")
            end
        elseif arcGetValue(self, "Silencer") then
            stat = arcGetValue(self, val, stat, "Silenced")
        end
    
        if bit.band(swepDt.NthShot, 1) == 0 then
            stat = arcGetValue(self, val, stat, "EvenShot")
        else
            stat = arcGetValue(self, val, stat, "OddShot")
        end
    
        if bit.band(swepDt.NthReload, 1) == 0  then
            stat = arcGetValue(self, val, stat, "EvenReload")
        else
            stat = arcGetValue(self, val, stat, "OddReload")
        end
    
        // if self:GetBlindFire() then
        //     stat = arcGetValue(self, val, stat, "BlindFire")
        // end
    
        if swepDt.Bipod then
            stat = arcGetValue(self, val, stat, "Bipod")
        end
    
        local hasNoAffectors = self.HasNoAffectors
        if !hasNoAffectors[val .. "Sights"] or !hasNoAffectors[val .. "HipFire"] then
            local sightAmount = swepDt.SightAmount

            if isnumber(stat) then
                local hipfire = arcGetValue(self, val, stat, "HipFire")
                local sights = arcGetValue(self, val, stat, "Sights")
    
                if isnumber(hipfire) and isnumber(sights) then
                    stat = Lerp(sightAmount, hipfire, sights)
                end
            else
                if sightAmount >= 1 then
                    stat = arcGetValue(self, val, stat, "Sights")
                else
                    stat = arcGetValue(self, val, stat, "HipFire")
                end
            end
        end
    
        local heatAmount = swepDt.HeatAmount
        local hasHeat = heatAmount > 0
        if hasHeat and base != "HeatCapacity" and !hasNoAffectors[val .. "Hot"] then
            if isnumber(stat) then
                local hot = arcGetValue(self, val, stat, "Hot")
    
                if isnumber(hot) then
                    stat = Lerp(heatAmount / self:GetProcessedValue("HeatCapacity"), stat, hot)
                end
            else
                if hasHeat then
                    stat = arcGetValue(self, val, stat, "Hot")
                end
            end
        end
    
        local getlastmeleetime = swepDt.LastMeleeTime
    
        if !hasNoAffectors[val .. "Melee"] and getlastmeleetime < ct then
            local pft = ct - getlastmeleetime
            local d = pft / (arcGetValue(self, "PreBashTime") + arcGetValue(self, "PostBashTime"))
    
            d = 1 - math.Clamp(d, 0, 1)
    
            if isnumber(stat) then
                stat = Lerp(d, stat, arcGetValue(self, val, stat, "Melee"))
            else
                if d > 0 then
                    stat = arcGetValue(self, val, stat, "Melee")
                end
            end
        end
    
    
        if !hasNoAffectors[val .. "Shooting"] then
            local nextPrimaryFire = weaponGetNextPrimaryFire(self)
    
            if nextPrimaryFire + 0.1 > ct then
                local pft = ct - nextPrimaryFire + 0.1
                local d = math.Clamp(pft / 0.1, 0, 1)
    
                if isnumber(stat) then
                    stat = Lerp(d, stat, arcGetValue(self, val, stat, "Shooting"))
                else
                    if d > 0 then
                        stat = arcGetValue(self, val, stat, "Shooting")
                    end
                end
            end
        end
    
        if !hasNoAffectors[val .. "Recoil"] then
            local recoilAmount = swepDt.RecoilAmount
            if recoilAmount > 0 then
                stat = arcGetValue(self, val, stat, "Recoil", recoilAmount)
            end
        end
    
        if !hasNoAffectors[val .. "Move"] and IsValid(owner) then
            local spd = self.PV_Move
            local maxspd = entityIsPlayer(owner) and playerGetWalkSpeed(owner) or 250
            if singleplayer or CLIENT or self.PV_Tick != upct then
                spd = math.min(vectorLength(entityGetAbsVelocity(owner)), maxspd) / maxspd
    
                self.PV_Move = spd
            end
    
            if isnumber(stat) then
                stat = Lerp(spd, stat, arcGetValue(self, val, stat, "Move"))
            else
                if spd > 0 then
                    stat = arcGetValue(self, val, stat, "Move")
                end
            end
        end
    
        self.PV_Tick = upct
        self.PV_Cache[processedValueName] = stat
    
        return stat
    end
end
