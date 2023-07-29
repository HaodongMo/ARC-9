local ENTITY = FindMetaTable("Entity")
SWEP.StatCache = {}
SWEP.HookCache = {}
SWEP.AffectorsCache = nil
SWEP.HasNoAffectors = {}

SWEP.ExcludeFromRawStats = {
    ["PrintName"] = true,
}

SWEP.DynamicConditions = { -- Never cache these conditions because they will always change
    ["Recoil"] = true,
}

local quickmodifiers = {
    ["DamageMin"] = GetConVar("arc9_mod_damage"),
    ["DamageMax"] = GetConVar("arc9_mod_damage"),
    ["Spread"] = GetConVar("arc9_mod_spread"),
    ["Recoil"] = GetConVar("arc9_mod_recoil"),
    ["VisualRecoil"] = GetConVar("arc9_mod_visualrecoil"),
    ["AimDownSightsTime"] = GetConVar("arc9_mod_adstime"),
    ["SprintToFireTime"] = GetConVar("arc9_mod_sprinttime"),
    ["DamageRand"] = GetConVar("arc9_mod_damagerand"),
    ["PhysBulletMuzzleVelocity"] = GetConVar("arc9_mod_muzzlevelocity"),
    ["RPM"] = GetConVar("arc9_mod_rpm"),
    ["HeadshotDamage"] = GetConVar("arc9_mod_headshotdamage"),
    ["MalfunctionMeanShotsToFail"] = GetConVar("arc9_mod_malfunction")
}

local singleplayer = game.SinglePlayer()
local ARC9HeatCapacityGPVOverflow = false

function SWEP:InvalidateCache()
    if singleplayer then
        self:CallOnClient("InvalidateCache")
    end

    for _, v in pairs(self.PV_CacheLong) do v.time = 0 end
    -- self.PV_CacheLong = {}
    
    self.StatCache = {}
    self.HookCache = {}
    self.AffectorsCache = nil
    self.ElementsCache = nil
    self.RecoilPatternCache = {}
    self.ScrollLevels = {}
    self.HasNoAffectors = {}
    self:SetBaseSettings()
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

do
    local entityGetTable = ENTITY.GetTable
    local swepGetCurrentFiremodeTable = SWEP.GetCurrentFiremodeTable
    local swepGetElements = SWEP.GetElements
    local swepGetFinalAttTable = SWEP.GetFinalAttTable
    local cvarArcModifiers = GetConVar("arc9_modifiers")
    local cvarGetString = FindMetaTable("ConVar").GetString

    function SWEP:GetAllAffectors()
        if self.AffectorsCache then return self.AffectorsCache end

        local aff = {table.Copy(entityGetTable(self))}

        local affLength = 1

        if not ARC9.OverrunSights then
            ARC9.OverrunSights = true
            local originalSightTable = self:GetSight().OriginalSightTable

            if originalSightTable then
                affLength = affLength + 1
                aff[affLength] = originalSightTable
            end

            ARC9.OverrunSights = false
        end

        local subSlotList = self:GetSubSlotList()
        local subSlotListLength = #subSlotList

        for i = 1, subSlotListLength do
            local atttbl = swepGetFinalAttTable(self, subSlotList[i])

            if atttbl then
                affLength = affLength + 1
                aff[affLength] = atttbl
            end
        end

        local config = string.Split(cvarGetString(cvarArcModifiers), "\\n")
        local configLength = #config
        local c4 = {}

        for i = 1, configLength do
            local swig = string.Split(config[i], "\\t")
            local swig1, swig2 = swig[1], swig[2]
            -- local c2 = c4[swig[1]]
            local swig2Num = tonumber(swig2)

            if swig2Num then
                c4[swig1] = swig2Num
            elseif swig2 == "true" or swig2 == "false" then
                c4[swig1] = swig2 == "true"
            else
                c4[swig1] = swig2
            end
        end

        affLength = affLength + 1
        aff[affLength] = c4

        if not ARC9.OverrunFiremodes then
            ARC9.OverrunFiremodes = true
            affLength = affLength + 1
            aff[affLength] = swepGetCurrentFiremodeTable(self)
            ARC9.OverrunFiremodes = false
        end

        if not ARC9.OverrunAttElements then
            ARC9.OverrunAttElements = true

            for i, k in pairs(swepGetElements(self)) do
                if not k then continue end
                local ele = self.AttachmentElements[i]

                if ele then
                    affLength = affLength + 1
                    aff[affLength] = ele
                end
            end

            ARC9.OverrunAttElements = false
        end

        self.AffectorsCache = aff

        return aff
    end
end

do
    -- local CURRENT_AFFECTOR
    -- local CURRENT_DATA
    -- local CURRENT_SWEP
    local swepGetAllAffectors = SWEP.GetAllAffectors

    -- local function affectorCall()
    --     return CURRENT_AFFECTOR(CURRENT_SWEP, CURRENT_DATA)
    -- end

    function SWEP:RunHook(val, data)
        local any = false
        local hookCache = self.HookCache[val]

        if hookCache then
            for i = 1, #hookCache do
                local d = hookCache[i](self, data)

                if d ~= nil then
                    data = d
                end

                any = true
            end

            data = hook.Run("ARC9_" .. val, self, data) or data

            return data, any
        end

        -- CURRENT_SWEP = self

        local cacheLen = 0
        local newCache = {}
        local affectors = swepGetAllAffectors(self)
        local affectorsCount = #affectors

        for i = 1, affectorsCount do
            local tbl = affectors[i]
            local tblVal = tbl[val]
            if tblVal and isfunction(tblVal) then
                cacheLen = cacheLen + 1
                newCache[cacheLen] = tblVal

                -- CURRENT_AFFECTOR = tblVal
                -- CURRENT_DATA = data
                -- local succ, returnedData = CURRENT_AFFECTOR(CURRENT_SWEP, CURRENT_DATA) pcall(affectorCall)
                local d = tblVal(self, data)
                if d ~= nil then
                    data = d
                end
                -- if succ then
                --     data = returnedData ~= nil and returnedData or data
                --     any = true
                -- else
                --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO RUN INVALID HOOK ON " .. val .. "!")
                --     print(returnedData, '\n')
                -- end
            end
        end

        self.HookCache[val] = newCache
        data = hook.Run("ARC9_" .. val, self, data) or data

        return data, any
    end
end

local Lerp = function(a, v1, v2)
    local d = v2 - v1

    return v1 + (a * d)
end

-- local pvtick = 0
-- local pv_move = 0
-- local pv_shooting = 0
-- local pv_melee = 0
SWEP.PV_Tick = 0
SWEP.PV_Move = 0
SWEP.PV_Shooting = 0
SWEP.PV_Melee = 0
SWEP.PV_Cache = {}
SWEP.PV_CacheLong = {}

do
    local swepRunHook = SWEP.RunHook
    local swepGetAllAffectors = SWEP.GetAllAffectors

    -- Maybe we need to make a thug version of this function? with getmetatable fuckery
    local type = type

    function SWEP:GetValue(val, base, condition, amount)
        condition = condition or ""
        amount = amount or 1
        local stat = base

        if stat == nil then
            stat = self:GetTable()[val]
        end

        local valContCondition = val .. condition
        if self.HasNoAffectors[valContCondition] == true then
            return stat
        end
        local unaffected = true
        local baseStr = tostring(base)
        -- damn
        local baseContValContCondition = baseStr .. valContCondition

        if type(stat) == "table" then
            stat.BaseClass = nil
        end

        local statCache = self.StatCache
        local cacheAvailable = statCache[baseContValContCondition]

        if cacheAvailable ~= nil then
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
            
            if quickmodifiers[val] and isnumber(stat) then
                local convarvalue = quickmodifiers[val]:GetFloat()

                if val == "MalfunctionMeanShotsToFail" then -- dont kill me for this pls
                    stat = stat / math.max(0.00000001, convarvalue)
                else
                    stat = stat * convarvalue
                end
            end

            return stat
        end

        local priority = 0
        local allAffectors = swepGetAllAffectors(self)
        local affectorsCount = #allAffectors

        if not self.ExcludeFromRawStats[val] then
            for i = 1, affectorsCount do
                local tbl = allAffectors[i]
                if !tbl then continue end
                
                local att_priority = tbl[valContCondition .. "_Priority"] or 1

                if att_priority >= priority and tbl[valContCondition] ~= nil then
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

            if att_priority >= priority and tbl[keyName] ~= nil then
                stat = tbl[keyName]
                priority = att_priority
                unaffected = false
            end
        end

        if type(stat) == "number" then
            for i = 1, affectorsCount do
                local tbl = allAffectors[i]
                local keyName = val .. "Add" .. condition

                if tbl[keyName] ~= nil then
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

                if tbl[keyName] ~= nil then
                    -- if !pcall(function() stat = stat * math.pow(tbl[val .. "Mult" .. condition], amount) end) then
                    --     print("!!! ARC9 ERROR - \"" .. (tbl["PrintName"] or "Unknown") .. "\" TRIED TO MULTIPLY INVALID VALUE: (" .. tbl[val .. "Add" .. condition] .. ") TO " .. val .. "!")
                    -- end
                    if type(tbl[keyName]) == type(stat) then
                        if amount > 1 then
                            stat = stat * math.pow(tbl[keyName], amount)
                        else
                            stat = stat * tbl[keyName]
                        end
                    end

                    unaffected = false
                end
            end
        end

        if not self.DynamicConditions[condition] then
            statCache[baseContValContCondition] = stat
        end
        -- self.StatCache[tostring(base) .. valContCondition] = stat
        local newstat, any = swepRunHook(self, val .. "Hook" .. condition, stat)
        stat = newstat or stat

        if quickmodifiers[val] and isnumber(val) then
            local convarvalue = quickmodifiers[val]:GetFloat()
            
            if val == "MalfunctionMeanShotsToFail" then  -- dont kill me for this pls
                stat = stat / math.max(0.00000001, convarvalue)
            else
                stat = stat * convarvalue
            end

            unaffected = false
        end

        if any then
            unaffected = false
        end

        if not self.DynamicConditions[condition] then
            self.HasNoAffectors[valContCondition] = unaffected
        end

        -- if statType == 'table' then
        if type(stat) == 'table' then
            stat.BaseClass = nil
        end

        return stat
    end
end

do
    local PLAYER = FindMetaTable("Player")
    local playerCrouching = PLAYER.Crouching
    local playerGetWalkSpeed = PLAYER.GetWalkSpeed
    local entityOwner = ENTITY.GetOwner
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

    local getmetatable = getmetatable
    local numberMeta = getmetatable(1)

    -- This should NOT break anything
    -- There are a few addons (such as SAM) that do the same
    if not numberMeta then
        numberMeta = {MetaName = "number"}
        debug.setmetatable(1, numberMeta)
    end

    local function isnumber(val)
        return getmetatable(val) == numberMeta
    end

    function SWEP:GetProcessedValue(val, cachedelay, base, cmd)
        local swepDt = self.dt
        -- From now on, we will not call `self:GetJammed()`, `self:GetHeatLockout()`
        -- and similar functions, because all they do is just return `self.dt[thing]`
        -- We can (and should, if we want "PERFORMANCE :tm:") do this manually
        if swepDt.Jammed and val == "Malfunction" then return true end
        if swepDt.HeatLockout and val == "Overheat" then return true end
        local ct = CurTime()
        local upct = UnPredictedCurTime()
        local processedValueName = tostring(val) .. tostring(base)

        -- if CLIENT then -- why cache was client only???
            if self.PV_Cache[processedValueName] ~= nil and self.PV_Tick == upct then
                return self.PV_Cache[processedValueName]
            end
            if self.PV_Tick ~= upct then
                self.PV_Cache = {}
            end
        -- end


        -- mega cool thing to not calculate mostly static values

        if cachedelay then
            if self.PV_CacheLong[processedValueName] then
                local cachetime = self.PV_CacheLong[processedValueName].time

                if cachetime then
                    if upct > cachetime then
                        -- print("Renewing cache for - ", processedValueName)
                        

                        self.PV_CacheLong[processedValueName].time = upct + 0.66 -- idk whats number here should be
                        self.PV_CacheLong[processedValueName].value = self:GetProcessedValue(val, base, cmd, false)
                        
                -- if istable(self.PV_CacheLong[processedValueName].value) then
                    -- print("Renewed value is a table!")
                    -- PrintTable(self.PV_CacheLong[processedValueName].value)
                    -- else print("Renewed value - ", self.PV_CacheLong[processedValueName].value) end
                        -- print(processedValueName, "working", upct)
                    end
                end
            else

                        -- print("Didn't found cache for - ", processedValueName, ", generating!")
                self.PV_CacheLong[processedValueName] = {}
                self.PV_CacheLong[processedValueName].time = upct
                self.PV_CacheLong[processedValueName].value = self:GetProcessedValue(val, base, cmd, false)
                -- if istable(self.PV_CacheLong[processedValueName].value) then
                    -- print("That generated value is a table!")
                    -- PrintTable(self.PV_CacheLong[processedValueName].value)
                    -- else print("Generated value - ", self.PV_CacheLong[processedValueName].value) end
            end

            return self.PV_CacheLong[processedValueName].value
        end


        local stat = arcGetValue(self, val, base)
        local ubgl = swepDt.UBGL
        local owner = entityOwner(self)
        -- if true then return stat end
        local ownerIsNPC = owner:IsNPC()

        if ownerIsNPC then
            stat = arcGetValue(self, val, stat, "NPC")
        end

        if cvarGetBool(cvarArc9Truenames) then
            stat = arcGetValue(self, val, stat, "True")
        end

        if not ownerIsNPC and entityIsValid(owner) then
            local ownerOnGround = entityOnGround(owner)

            if not ownerOnGround or entityGetMoveType(owner) == MOVETYPE_NOCLIP then
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

        if swepDt.GrenadeTossing then
            stat = arcGetValue(self, val, stat, "Toss")
        end

        if weaponClip1(self) == 0 then
            stat = arcGetValue(self, val, stat, "Empty")
        end

        if not ubgl and arcGetValue(self, "Silencer") then
            stat = arcGetValue(self, val, stat, "Silenced")
        end

        if ubgl then
            stat = arcGetValue(self, val, stat, "UBGL")

            if weaponClip2(self) == 0 then
                stat = arcGetValue(self, val, stat, "EmptyUBGL")
            end
        end

        if swepDt.NthShot % 2 == 0 then
            stat = arcGetValue(self, val, stat, "EvenShot")
        else
            stat = arcGetValue(self, val, stat, "OddShot")
        end

        if swepDt.NthReload % 2 == 0 then
            stat = arcGetValue(self, val, stat, "EvenReload")
        else
            stat = arcGetValue(self, val, stat, "OddReload")
        end

        -- if self:GetBlindFire() then
        --     stat = arcGetValue(self, val, stat, "BlindFire")
        -- end
        if swepDt.Bipod then
            stat = arcGetValue(self, val, stat, "Bipod")
        end

        local hasNoAffectors = self.HasNoAffectors

        if not hasNoAffectors[val .. "Sights"] or not hasNoAffectors[val .. "HipFire"] or not hasNoAffectors[val .. "Sighted"] then
            local sightAmount = swepDt.SightAmount

            if isnumber(stat) then
                local hipfire = arcGetValue(self, val, stat, "HipFire")
                local sights = arcGetValue(self, val, stat, "Sights")
                local sighted = arcGetValue(self, val, stat, "Sighted")

                if sightAmount >= 1 and not hasNoAffectors[val .. "Sighted"] then
                    stat = sighted
                elseif isnumber(hipfire) and isnumber(sights) then
                    stat = Lerp(sightAmount, hipfire, sights)
                end
            else
                if sightAmount >= 1 then
                    if hasNoAffectors[val .. "Sighted"] then
                        stat = arcGetValue(self, val, stat, "Sights")
                    else
                        stat = arcGetValue(self, val, stat, "Sighted")
                    end
                else
                    stat = arcGetValue(self, val, stat, "HipFire")
                end
            end
        end

        if not ARC9HeatCapacityGPVOverflow then
            local heatAmount = swepDt.HeatAmount
            local hasHeat = heatAmount > 0

            if hasHeat and base ~= "HeatCapacity" and (not hasNoAffectors[val .. "Hot"] or not hasNoAffectors[val .. "Heated"]) then

                ARC9HeatCapacityGPVOverflow = true
                local cap = self:GetProcessedValue("HeatCapacity")
                ARC9HeatCapacityGPVOverflow = false

                if isnumber(stat) then
                    local hot = arcGetValue(self, val, stat, "Hot")

                    if not hasNoAffectors[val .. "Heated"] and heatAmount >= cap then
                        stat = arcGetValue(self, val, stat, "Heated")
                    elseif isnumber(hot) then
                        ARC9HeatCapacityGPVOverflow = true
                        stat = Lerp(heatAmount / cap, stat, hot)
                        ARC9HeatCapacityGPVOverflow = false
                    end
                else
                    if not hasNoAffectors[val .. "Heated"] and heatAmount >= cap then
                        stat = arcGetValue(self, val, stat, "Heated")
                    elseif hasHeat then
                        stat = arcGetValue(self, val, stat, "Hot")
                    end
                end
            end
        end

        local getlastmeleetime = swepDt.LastMeleeTime

        if not hasNoAffectors[val .. "Melee"] and getlastmeleetime < ct then
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

        if not hasNoAffectors[val .. "Shooting"] then
            local nextPrimaryFire = weaponGetNextPrimaryFire(self)

            if nextPrimaryFire + 0.1 > ct then
                local pft = (nextPrimaryFire + 0.1) - ct
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

        if val ~= "RecoilModifierCap" and not hasNoAffectors[val .. "Recoil"] then
            local recoilAmount = math.min(self:GetProcessedValue("RecoilModifierCap"), swepDt.RecoilAmount)

            if recoilAmount > 0 then
                stat = arcGetValue(self, val, stat, "Recoil", recoilAmount)
            end
        end

        if not hasNoAffectors[val .. "Move"] and IsValid(owner) then
            local spd = self.PV_Move
            local maxspd = entityIsPlayer(owner) and playerGetWalkSpeed(owner) or 250

            --if singleplayer or CLIENT or self.PV_Tick ~= upct then
                spd = math.min(vectorLength(entityGetAbsVelocity(owner)), maxspd) / maxspd
                self.PV_Move = spd
            --end

            if isnumber(stat) then
                stat = Lerp(spd, stat, arcGetValue(self, val, stat, "Move"))
            else
                if spd > 0 then
                    stat = arcGetValue(self, val, stat, "Move")
                end
            end
        end

        -- if CLIENT then
            self.PV_Tick = upct
            self.PV_Cache[processedValueName] = stat
        -- end

        return stat
    end
end
