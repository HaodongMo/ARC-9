local hutom = function(i) return math.Round(i * ARC9.HUToM) .. (ARC9:GetPhrase("unit.meter") or "m") end
local hutoms = function(i) return math.Round(i * ARC9.HUToM) .. (ARC9:GetPhrase("unit.meterpersecond") or "m/s") end
local hutoms_1 = function(i) return math.Round(i * ARC9.HUToM, 1) .. (ARC9:GetPhrase("unit.meterpersecond") or "m/s") end
local degtomoa = function(i) return math.Round(i / ARC9.MOAToAcc, 2) .. (ARC9:GetPhrase("unit.moa") or "MOA") end

-- [AutoStatName] = {unit, lower_is_better}
-- unit can be:
--   false - as is (e.g. 30 round capacity)
--   string - suffix (e.g. +1 chamber size)
--   true - true percentage (e.g. 80% move speed)
--   function - return a string to use as the value
ARC9.AutoStatsMains = {
    ["DamageMax"] = {false, false},
    ["DamageMin"] = {false, false},
    ["DamageRand"] = {true, true},
    ["RangeMin"] = {hutom, false},
    ["RangeMax"] = {hutom, false},
    ["Distance"] = {hutom, false},
    ["Num"] = {false, false},
    ["Penetration"] = {"HU", false},
    ["RicochetAngleMax"] = {"°", false},
    ["RicochetChance"] = {true, false},
    ["ArmorPiercing"] = {false, false},
    ["EntityMuzzleVelocity"] = {hutoms, false},
    ["PhysBulletMuzzleVelocity"] = {hutoms, false},
    ["PhysBulletDrag"] = {true, true},
    ["PhysBulletGravity"] = {true, true},
    ["ChamberSize"] = {false, false},
    ["ClipSize"] = {false, false},
    ["SupplyLimit"] = {false, false},
    ["SecondarySupplyLimit"] = {false, false},
    ["AmmoPerShot"] = {false, true},
    ["ManualActionChamber"] = {false, false},
    ["TriggerDelay"] = {"s", true},
    ["RPM"] = {"RPM", false},
    ["PushBackForce"] = {hutoms_1, false},
    ["PostBurstDelay"] = {"s", true},
    ["Recoil"] = {false, true},
    ["RecoilPatternDrift"] = {false, true},
    ["RecoilUp"] = {false, true},
    ["RecoilSide"] = {false, true},
    ["RecoilRandomUp"] = {false, true},
    ["RecoilRandomSide"] = {false, true},
    ["RecoilDissipationRate"] = {false, true},
    ["RecoilResetTime"] = {"s", true},
    ["RecoilAutoControl"] = {false, false},
    ["RecoilKick"] = {false, true},
    ["Spread"] = {degtomoa, true},
    ["PelletSpread"] = {degtomoa, true},
    ["FreeAimRadius"] = {"°", true},
    ["Sway"] = {false, true},
    ["AimDownSightsTime"] = {"s", true},
    ["SprintToFireTime"] = {"s", true},
    ["ReloadTime"] = {true, true},
    ["DeployTime"] = {true, true},
    ["CycleTime"] = {true, true},
    ["FixTime"] = {true, true},
    ["OverheatTime"] = {true, true},
    ["Speed"] = {true, false},
    ["BashDamage"] = {false, false},
    ["BashRange"] = {"HU", false},
    ["BashLungeRange"] = {"HU", false},
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
    ["RunAwayBurst"] = {false, false},
    ["ShootWhileSprint"] = {false, true},
    ["Bash"] = {false, true},
    ["Overheat"] = {false, false},
    ["Malfunction"] = {false, false},
    ["Bipod"] = {false, true},
    ["NoFlash"] = {false, true},
    ["BulletGuidance"] = {false, true},
    ["BulletGuidanceAmount"] = {false, false},
    ["ExplosionDamage"] = {false, false},
    ["ExplosionRadius"] = {false, false},
    ["HeadshotDamage"] = {false, false},
    ["ChestDamage"] = {false, false},
    ["StomachDamage"] = {false, false},
    ["ArmDamage"] = {false, false},
    ["LegDamage"] = {false, false},
}

ARC9.AutoStatsOperations = {
    ["Mult"] = function(a, weapon, stat, unit)
        if unit == true then
            return "×" .. math.Round(a * 100, 2) .. "% ", "", a < 1
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
            return "-" .. tostring(a) .. "% ", "", true
        else
            return "+" .. tostring(a) .. "% ", "", false
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
            str = tostring(a) .. unit
        elseif isfunction(unit) then
            str = unit(a)
        else
            str = tostring(a)
        end

        if neg then
            return "-" .. str .. " ", "", true
        else
            return "+" .. str .. " ", "", false
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
            str = tostring(a) .. unit
        elseif isfunction(unit) then
            str = unit(a)
        else
            str = tostring(a)
        end

        return str .. " ", "", a <= (weapon[stat] or 0)
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
    ["HipFire"] = "In Hipfire",
    ["Shooting"] = "While Shooting",
    ["Recoil"] = "With Each Shot",
    ["Move"] = "While Moving",
    ["BlindFire"] = "While Blind Firing"
}

function ARC9.GetProsAndCons(atttbl, weapon)
    local pros = table.Copy(atttbl.Pros or {})
    local cons = table.Copy(atttbl.Cons or {})

    for stat, value in pairs(atttbl) do
        if !isnumber(value) and !isbool(value) then continue end
        local autostat = ""
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
                autostat = pre .. autostat .. post
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
            autostat = pre .. autostat .. post
            neg = isneg
            foundop = true
            asop = "Override"
        else
            stat = string.sub(stat, string.len(asop) + 1, string.len(stat))
        end

        if stat == "_Priority" then continue end

        if string.len(stat) > 0 then
            for cond, postfix in pairs(ARC9.AutoStatsConditions) do
                if string.StartWith(stat, cond) then
                    autostat = ARC9:GetPhrase("autostat.secondary." .. string.lower(cond), {autostat}) or ""
                    break
                end
            end
        end

        autostat = autostat .. "."

        if neg and negisgood or !neg and !negisgood then
            table.insert(pros, autostat)
        else
            table.insert(cons, autostat)
        end
    end

    return pros, cons
end