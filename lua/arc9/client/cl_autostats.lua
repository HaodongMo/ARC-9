local imperial = GetConVar("arc9_imperial"):GetBool()

local hutom = function(i)
	if imperial then 
		impv = 1.0936
		impn = "unit.yard"
	else 
		impv = 1
		impn = "unit.meter"
	end
	return math.Round(i * ARC9.HUToM * impv) .. (ARC9:GetPhrase(impn) or "m") 
end

local hutoms = function(i) 
	if imperial then 
		impv = 3.2808399
		impn = "unit.footpersecond"
	else 
		impv = 1
		impn = "unit.meterpersecond"
	end
	return math.Round(i * ARC9.HUToM * impv) .. (ARC9:GetPhrase(impn) or "m/s")
end

local hutoms_1 = function(i) 
	if imperial then 
		impv = 3.2808399
		impn = "unit.footpersecond"
	else 
		impv = 1
		impn = "unit.meterpersecond"
	end
	return math.Round(i * ARC9.HUToM * impv, 1) .. (ARC9:GetPhrase(impn) or "m/s")
end

local degtomoa = function(i) return math.Round(i / ARC9.TrueMOAToAcc, 1) .. (ARC9:GetPhrase("unit.moa") or "MOA") end

-- [AutoStatName] = {unit, lower_is_better}
-- unit can be:
--   false - as is (e.g. 30 round capacity)
--   string - suffix (e.g. +1 chamber size)
--   true - true percentage (e.g. 80% move speed)
--   function - return a string to use as the value
ARC9.AutoStatsMains = {
    ["DamageMax"] = {false, false},
    ["DamageMin"] = {false, false},
    ["DamageRand"] = {false, true},
    ["RangeMin"] = {hutom, false},
    ["RangeMax"] = {hutom, false},
    ["Distance"] = {hutom, false},
    ["Num"] = {false, false},
    ["Penetration"] = {"HU", false},
    ["PenetrationDelta"] = {true, false},
    ["RicochetAngleMax"] = {"°", false},
    ["RicochetChance"] = {false, false},
    ["ArmorPiercing"] = {false, false},
    ["EntityMuzzleVelocity"] = {hutoms, false},
    ["PhysBulletMuzzleVelocity"] = {hutoms, false},
    ["PhysBulletDrag"] = {false, true},
    ["PhysBulletGravity"] = {false, true},
    ["ChamberSize"] = {false, false},
    ["ClipSize"] = {false, false},
    ["SupplyLimit"] = {false, false},
    ["SecondarySupplyLimit"] = {false, false},
    ["AmmoPerShot"] = {false, true},
    ["ManualActionChamber"] = {false, false},
    ["TriggerDelay"] = {false, true},
    ["TriggerDelayTime"] = {"s", true},
    ["RPM"] = {"RPM", false},
    ["PushBackForce"] = {hutoms_1, false},
    ["PostBurstDelay"] = {"s", true},
    ["Recoil"] = {false, true},
    ["RecoilPatternDrift"] = {false, true},
    ["RecoilUp"] = {false, true},
    ["RecoilSide"] = {false, true},
    ["RecoilRandomUp"] = {false, true},
    ["RecoilRandomSide"] = {false, true},
    ["RecoilDissipationRate"] = {false, false},
    ["RecoilResetTime"] = {"s", true},
    ["RecoilAutoControl"] = {false, false},
    ["RecoilKick"] = {false, true},
    ["Spread"] = {degtomoa, true},
    ["PelletSpread"] = {degtomoa, true},
    ["FreeAimRadius"] = {"°", true},
    ["Sway"] = {false, true},
    ["AimDownSightsTime"] = {"s", true},
    ["SprintToFireTime"] = {"s", true},
    ["ReloadTime"] = {false, true},
    ["DeployTime"] = {false, true},
    ["CycleTime"] = {false, true},
    ["FixTime"] = {false, true},
    ["OverheatTime"] = {false, true},
    ["Speed"] = {true, false},
    ["BashDamage"] = {false, false},
    ["BashRange"] = {"HU", false},
    ["BashLungeRange"] = {"HU", false},
    ["Bash2Damage"] = {false, false},
    ["Bash2Range"] = {"HU", false},
    ["Bash2LungeRange"] = {"HU", false},
    ["HeatPerShot"] = {false, true},
    ["HeatCapacity"] = {false, false},
    ["HeatDissipation"] = {false, false},
    ["MalfunctionMeanShotsToFail"] = {false, false},
    ["ShootVolume"] = {"dB", true},
    ["AlwaysPhysBullet"] = {false, false},
    ["NeverPhysBullet"] = {false, true},
    ["InfiniteAmmo"] = {false, true},
    ["BottomlessClip"] = {false, true},
    ["ShotgunReload"] = {false, false},
    ["HybridReload"] = {false, true},
    ["ManualAction"] = {false, false},
    ["CanFireUnderwater"] = {false, true},
    ["AutoReload"] = {false, true},
    ["AutoBurst"] = {false, true},
    ["RunawayBurst"] = {false, false},
    ["ShootWhileSprint"] = {false, true},
    ["Bash"] = {false, true},
    ["Bash2"] = {false, true},
    ["Overheat"] = {false, false},
    ["Malfunction"] = {false, false},
    ["MalfunctionWait"] = {"s", true},
    ["Bipod"] = {false, true},
    ["NoFlash"] = {false, true},
    ["BulletGuidance"] = {false, true},
    ["BulletGuidanceAmount"] = {false, false},
    ["ExplosionDamage"] = {false, false},
    ["ExplosionRadius"] = {false, false},
    ["HeadshotDamage"] = {true, false},
    ["ChestDamage"] = {true, false},
    ["StomachDamage"] = {true, false},
    ["ArmDamage"] = {true, false},
    ["LegDamage"] = {true, false},
    ["VisualRecoil"] = {false, true},
    ["VisualRecoilUp"] = {false, true},
    ["VisualRecoilSide"] = {false, true},
    ["VisualRecoilRoll"] = {false, true},
    ["VisualRecoilPunch"] = {false, true},
    ["BreathHoldTime"] = {false, false},
    ["RecoilModifierCap"] = {false, true},
    ["BashSpeed"] = {false, false},
    ["Bash2Speed"] = {false, false},
    ["RecoilPerShot"] = {false, true},
}

ARC9.AutoStatsOperations = {
    ["Mult"] = function(a, weapon, stat, unit)
        if unit == true then
            return "×" .. math.Round(a * 100, 2) .. "%", "", a < 1
        end

        local neg = false
        if a > 1 then
            a = (a - 1) * 100
        else
            a = (a - 1) * -100
            neg = true
        end
        a = math.Round(a, 2)

        if neg then
            return "-" .. tostring(a) .. "%", "", true
        else
            return "+" .. tostring(a) .. "%", "", false
        end
    end,
    ["Add"] = function(a, weapon, stat, unit)
        local neg = false
        if a < 0 then
            neg = true
            a = a * -1
        end

        local str
        if unit == true then
            str = math.Round(a * 100, 2) .. "%"
        elseif isstring(unit) then
            str = tostring(math.Round(a, 2)) .. unit
        elseif isfunction(unit) then
            str = unit(a)
        else
            str = tostring(math.Round(a, 2))
        end

        if neg then
            return "-" .. str, "", true
        else
            return "+" .. str, "", false
        end
    end,
    ["Override"] = function(a, weapon, stat, unit)
        if isbool(a) then
            if a then
                return ARC9:GetPhrase("autostat.enable.pre") or "", ARC9:GetPhrase("autostat.enable.post") or "", a
            else
                return ARC9:GetPhrase("autostat.disable.pre") or "", ARC9:GetPhrase("autostat.disable.post") or "", a
            end
        end

        local str
        if unit == true then
            str = math.Round(a * 100, 2) .. "%"
        elseif isstring(unit) then
            str = tostring(math.Round(a, 2)) .. unit
        elseif isfunction(unit) then
            str = unit(a)
        else
            str = tostring(math.Round(a, 2))
        end

        return str, "", a <= (weapon[stat] or 0)
    end,
    ["Hook"] = function(a, weapon, stat)
        return "", "", false
    end
}

ARC9.AutoStatsConditions = {
    ["True"] = "When TrueNames Is On",
    ["Silenced"] = "When Silenced",
    ["MidAir"] = "In Mid-Air",
    ["Crouch"] = "While Crouching",
    ["First"] = "On First Shot",
    ["FirstShot"] = "On First Shot",
    ["Last"] = "On Last Shot In Mag",
    ["LastShot"] = "On Last Shot In Mag",
    ["Empty"] = "On Last Shot In Mag",
    ["EvenShot"] = "Every Other Shot",
    ["OddShot"] = "Every Odd Shot",
    ["EvenReload"] = "Every Other Reload",
    ["OddReload"] = "Every Odd Reload",
    ["Sights"] = "In Sights",
    ["Sighted"] = "While Sighted",
    ["Hot"] = "From Heat",
    ["Heated"] = "While Heated",
    ["HipFire"] = "In Hipfire",
    ["Shooting"] = "While Shooting",
    ["Recoil"] = "With Each Shot",
    ["Move"] = "While Moving",
    ["BlindFire"] = "While Blind Firing",
    ["UBGL"] = "In UBGL",
    ["Bipod"] = "On Bipod",
	["Sprint"] = "when Sprinting",
}

function ARC9.GetProsAndCons(atttbl, weapon)
    local prosname = {}
    local prosnum = {}
    local consname = {}
    local consnum = {}

    for stat, value in pairs(atttbl) do
        if !isnumber(value) and !isbool(value) then continue end
        --if isnumber(value) and (!string.StartWith(stat, "Spread")) then value = math.Round(value, 2) end
        local autostat = ""
        local autostatnum = ""
        local canautostat = false
        local neg = false
        local unit = false
        local negisgood = false
        local asmain = ""

        local maxlen = 0

        for main, tbl in pairs(ARC9.AutoStatsMains) do
            if string.len(main) > maxlen and string.StartWith(stat, main) then
                autostat = ARC9:GetPhrase("autostat." .. main) or main
                unit = tbl[1]
                negisgood = tbl[2]
                asmain = main
                canautostat = true
                maxlen = string.len(main)
            end
        end

        if !canautostat then
            continue
        end

        stat = string.sub(stat, string.len(asmain) + 1, string.len(stat))

        local foundop = false
        local asop = ""

        for op, func in pairs(ARC9.AutoStatsOperations) do
            if string.StartWith(stat, op) then
                local pre, post, isneg = func(value, weapon, asmain, unit)
                autostat = autostat .. post
                autostatnum = pre
                neg = isneg
                foundop = true
                asop = op
                break
            end
        end

        if asop == "Hook" then continue end

        if !foundop then
            -- autostat = tostring(value) .. " " .. autostat

            -- if isnumber(value) then neg = value <= (weapon[asmain] or 0) else neg = value end
            local pre, post, isneg = ARC9.AutoStatsOperations.Override(value, weapon, asmain, unit)
            autostat = autostat .. post
            autostatnum = pre
            neg = isneg
            foundop = true
            asop = "Override"
        else
            stat = string.sub(stat, string.len(asop) + 1, string.len(stat))
        end

        if stat == "_Priority" then continue end

        if string.len(stat) > 0 then

            local before = ARC9:GetPhrase("autostat.secondary._beforephrase")
            local div = ARC9:GetPhrase("autostat.secondary._divider")
            if div == true then div = "" end

            for cond, postfix in pairs(ARC9.AutoStatsConditions) do
                if string.StartWith(stat, cond) then
                    local phrase = (ARC9:GetPhrase("autostat.secondary." .. string.lower(cond)) or "")
                    if before then
                        autostat = phrase .. div .. autostat
                    else
                        autostat = autostat .. div .. phrase
                    end
                    break
                end
            end
        end

        if neg and negisgood or !neg and !negisgood then
            table.insert(prosname, autostat)
            table.insert(prosnum, autostatnum)
        else
            table.insert(consname, autostat)
            table.insert(consnum, autostatnum)
        end
    end

    -- custom stats
    if istable(atttbl.CustomPros) then
        for stat, value in pairs(atttbl.CustomPros) do
            table.insert(prosname, stat)
            table.insert(prosnum, value)
        end
    end

    if istable(atttbl.CustomCons) then
        for stat, value in pairs(atttbl.CustomCons) do
            table.insert(consname, stat)
            table.insert(consnum, value)
        end
    end

    return prosname, prosnum, consname, consnum
    -- return pros, cons
end