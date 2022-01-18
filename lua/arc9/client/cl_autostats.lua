ARC9.AutoStatsMains = {
    ["DamageMax"] = {"Close Range Damage", false},
    ["DamageMin"] = {"Long Range Damage", false},
    ["DamageRand"] = {"Damage Variance", true},
    ["RangeMin"] = {"Minimum Damage Range", false},
    ["RangeMax"] = {"Maximum Range", false},
    ["Num"] = {"Projectile Count", false},
    ["Penetration"] = {"Material Penetration", false},
    ["RicochetAngleMax"] = {"Ricochet Angle", false},
    ["RicochetChance"] = {"Ricochet Chance", false},
    ["ArmorPiercing"] = {"Armor Piercing", false},
    ["EntityMuzzleVelocity"] = {"Projectile Muzzle Velocity", false},
    ["PhysBulletMuzzleVelocity"] = {"Muzzle Velocity", false},
    ["PhysBulletDrag"] = {"Bullet Drag", true},
    ["PhysBulletGravity"] = {"Bullet Drop", true},
    ["ChamberSize"] = {"Chamber Load Count", false},
    ["ClipSize"] = {"Magazine Capacity", false},
    ["SupplyLimit"] = {"Reserve Magazines", false},
    ["SecondarySupplyLimit"] = {"Reserve Secondary Ammo", false},
    ["AmmoPerShot"] = {"Ammo Per Shot", true},
    ["ManualActionChamber"] = {"Shots Per Cycle", false},
    ["TriggerDelay"] = {"Trigger Delay Rime", true},
    ["RPM"] = {"Fire Rate", false},
    ["PostBurstDelay"] = {"Burst Delay", true},
    ["Recoil"] = {"Recoil", true},
    ["RecoilPatternDrift"] = {"Recoil Drift", true},
    ["RecoilUp"] = {"Vertical Recoil", true},
    ["RecoilSide"] = {"Horizontal Recoil", true},
    ["RecoilRandomUp"] = {"Vertical Recoil Spread", true},
    ["RecoilRandomSide"] = {"Horizontal Recoil Spread", true},
    ["RecoilDissipationRate"] = {"Recoil Dissipation Rate", true},
    ["RecoilResetTime"] = {"Recoil Reset Time", true},
    ["RecoilAutoControl"] = {"Recoil Control", false},
    ["RecoilKick"] = {"Felt Recoil", true},
    ["Spread"] = {"Spread", true},
    ["PelletSpread"] = {"Clump Spread", true},
    ["FreeAimRadius"] = {"Free Aim Radius", true},
    ["Sway"] = {"Sway", true},
    ["AimDownSightsTime"] = {"Aim Down Sights Time", true},
    ["SprintToFireTime"] = {"Sprint To Fire Time", true},
    ["ReloadTime"] = {"Reload Time", true},
    ["DeployTime"] = {"Draw Time", true},
    ["CycleTime"] = {"Cycle Time", true},
    ["FixTime"] = {"Unjam Time", true},
    ["OverheatTime"] = {"Overheat Fix Time", true},
    ["Speed"] = {"Movement Speed", false},
    ["BashDamage"] = {"Melee Damage", false},
    ["BashLungeRange"] = {"Melee Range", false},
    ["HeatCapacity"] = {"Heat Capacity", false},
    ["HeatDissipation"] = {"Heat Dissipation", false},
    ["MalfunctionMeanShotsToFail"] = {"Mean Shots Between Failures", false},
    ["ShootVolume"] = {"Report Volume", true},
    ["AlwaysPhysBullet"] = {"Always Physical Bullets", false},
    ["NeverPhysBullet"] = {"Non-Physical Bullets", true},
    ["InfiniteAmmo"] = {"Infinite Ammunition", false},
    ["BottomlessClip"] = {"Bottomless Magazine", false},
    ["ShotgunReload"] = {"Individual Reloading", false},
    ["HybridReload"] = {"Hybrid Individual Reloading", false},
    ["ManualAction"] = {"Manual Action", true},
    ["CanFireUnderwater"] = {"Underwater Shooting", false},
    ["AutoReload"] = {"Idle Reloading", false},
    ["AutoBurst"] = {"Automatic Burst Fire", false},
    ["RunAwayBurst"] = {"Runaway Burst", false},
    ["ShootWhileSprint"] = {"Shoot While Sprinting", false},
    ["Bash"] = {"Melee Attacks", false},
    ["Overheat"] = {"Overheating", true},
    ["Malfunction"] = {"Jamming", true},
    ["Bipod"] = {"Bipod", false},
}

ARC9.AutoStatsOperations = {
    ["Mult"] = function(a, weapon, stat)
        local neg = false
        if a > 1 then
            a = (a - 1) * 100
        else
            a = (a - 1) * -100
            neg = true
        end

        if neg then
            return "-" .. tostring(a) .. "% ", "", true
        else
            return "+" .. tostring(a) .. "% ", "", false
        end
    end,
    ["Add"] = function(a, weapon, stat)
        local neg = false
        if a < 0 then
            neg = true
            a = a * -1
        end

        if neg then
            return "-" .. tostring(a) .. " ", "", true
        else
            return "+" .. tostring(a) .. " ", "", false
        end
    end,
    ["Override"] = function(a, weapon, stat)
        if isbool(a) then
            if a then
                return "Enable ", "", a
            else
                return "Disable ", "", a
            end
        end

        return tostring(a) .. " ", "", a <= (weapon[stat] or 0)
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
    ["Move"] = "While Moving"
}

function ARC9.GetProsAndCons(atttbl, weapon)
    local pros = table.Copy(atttbl.Pros or {})
    local cons = table.Copy(atttbl.Cons or {})

    for stat, value in pairs(atttbl) do
        if !isnumber(value) and !isbool(value) then continue end
        local autostat = ""
        local canautostat = false
        local neg = false
        local negisgood = false
        local asmain = ""

        local maxlen = 0

        for main, tbl in pairs(ARC9.AutoStatsMains) do
            if string.len(main) > maxlen and string.StartWith(stat, main) then
                autostat = tbl[1]
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
                local pre, post, isneg = func(value, weapon, asmain)
                autostat = pre .. autostat .. post
                neg = isneg
                foundop = true
                asop = op
                break
            end
        end

        if !foundop then
            autostat = tostring(value) .. " " .. autostat

            if isnumber(value) then neg = value <= (weapon[asmain] or 0) else neg = value end
        else
            stat = string.sub(stat, string.len(asop) + 1, string.len(stat))
        end

        if string.len(stat) > 0 then
            for cond, postfix in pairs(ARC9.AutoStatsConditions) do
                if string.StartWith(stat, cond) then
                    autostat = autostat .. " " .. postfix
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