local pistolammotypes = {
    ["pistol"] = true,
    ["357"] = true
}

local rpgammotypes = {
    ["rpg_round"] = true,
    ["smg1_grenade"] = true,
    ["grenade"] = true
}

local sniperammotypes = {
    ["SniperRound"] = true,
    ["SniperPenetratedRound"] = true
}

function ARC9.GuessWeaponType(swep)
    if swep.ARC9WeaponCategory then return swep.ARC9WeaponCategory end

    if swep.NotAWeapon or swep.Throwable then
        return ARC9.WEAPON_MISC
    elseif swep.PrimaryBash then
        return ARC9.WEAPON_MELEE
    elseif swep.ShootEnt or rpgammotypes[swep.Ammo] then
        return ARC9.WEAPON_RPG
    elseif (swep.Num or 1) > 1 or swep.Ammo == "Buckshot" then
        return ARC9.WEAPON_SHOTGUN
    elseif sniperammotypes[swep.Ammo] then
        return ARC9.WEAPON_SNIPER
    end

    local bestfiremode = 1

    for _, mode in ipairs(swep.Firemodes or {}) do
        if mode.Mode != 1 and mode.Mode != 0 then
            bestfiremode = mode.Mode
            break
        end
    end

    if bestfiremode == 1 then
        if pistolammotypes[swep.Ammo] then
            return ARC9.WEAPON_PISTOL
        else
            return ARC9.WEAPON_SNIPER
        end
    else
        if pistolammotypes[swep.Ammo] then
            return ARC9.WEAPON_SMG
        else
            return ARC9.WEAPON_AR
        end
    end

    return ARC9.WEAPON_MISC
end

ARC9.WeaponClasses = {}

function ARC9.PopulateWeaponClasses()
    for _, wep in ipairs(weapons.GetList()) do
        if weapons.IsBasedOn(wep.ClassName, "arc9_base") then
            if wep.NotForNPCs then continue end
            local weptype = ARC9.GuessWeaponType(wep)
            ARC9.WeaponClasses[weptype] = ARC9.WeaponClasses[weptype] or {}
            table.insert(ARC9.WeaponClasses[weptype], wep.ClassName)
        end
    end
end

ARC9.PopulateWeaponClasses()

hook.Add("InitPostEntity", "ARC9_PopulateWeaponClasses", ARC9.PopulateWeaponClasses)

function ARC9.ReplaceSpawnedWeapon(ent)
    if CLIENT then return end

    if !GetConVar("arc9_npc_autoreplace"):GetBool() then return end

    if ent:IsNPC() then
        timer.Simple(0, function()
            if !ent:IsValid() then return end
            local cap = ent:CapabilitiesGet()

            if bit.band(cap, CAP_USE_WEAPONS) != CAP_USE_WEAPONS then return end

            local class

            if IsValid(ent:GetActiveWeapon()) then
                class = ent:GetActiveWeapon():GetClass()
            end

            if ARC9.HL2Replacements[class] then
                local weptbl = ARC9.HL2Replacements[class]
                local wepcategory = table.Random(weptbl)
                local wepclass = table.Random(ARC9.GetWeaponClasses(wepcategory))

                if wepclass then
                    ent:Give(wepclass)
                end
            end
        end)
    elseif ent:IsWeapon() then
        if !GetConVar("arc9_replace_spawned"):GetBool() then return end
        timer.Simple(0, function()
            if !ent:IsValid() then return end
            if IsValid(ent:GetOwner()) then return end
            if ent.ARC9 then return end

            local class = ent:GetClass()

            if ARC9.HL2Replacements[class] then
                local weptbl = ARC9.HL2Replacements[class]
                local wepcategory = table.Random(weptbl)
                local wepclass = table.Random(ARC9.GetWeaponClasses(wepcategory))

                if wepclass then
                    local wpnent = ents.Create(wepclass)
                    wpnent:SetPos(ent:GetPos())
                    wpnent:SetAngles(ent:GetAngles())

                    wpnent:NPC_Initialize()

                    wpnent:Spawn()

                    timer.Simple(0, function()
                        if !ent:IsValid() then return end
                        wpnent:OnDrop(true)
                        ent:Remove()
                    end)
                end
            end
        end)
    end
end

hook.Add("OnEntityCreated", "ARC9_ReplaceSpawnedWeapons", ARC9.ReplaceSpawnedWeapon)

function ARC9.WeaponIsAllowed(class)
    local blacklist = GetConVar("arc9_npc_blacklist"):GetString()
    local whitelist = GetConVar("arc9_npc_whitelist"):GetString()

    if whitelist == "" then
        // Check blacklist

        local blacklist_tbl = {}

        for _, v in ipairs(string.Explode(" ", blacklist)) do
            blacklist_tbl[v] = true
        end

        if blacklist_tbl[class] then
            return false
        end

        return true
    else
        // Check whitelist

        local whitelist_tbl = {}

        for _, v in ipairs(string.Explode(" ", whitelist)) do
            whitelist_tbl[v] = true
        end

        if whitelist_tbl[class] then
            return true
        end

        return false
    end
end

function ARC9.GetWeaponClasses(weptype)
    local weptbl = ARC9.WeaponClasses[weptype]
    local wepclasses = {}

    for _, class in ipairs(weptbl) do
        if ARC9.WeaponIsAllowed(class) then
            table.insert(wepclasses, class)
        end
    end

    return wepclasses
end

ARC9.RandomizeQueue = {}

function ARC9.TryRandomize()
    for _, wpn in ipairs(ARC9.RandomizeQueue) do
        if IsValid(wpn) then
            wpn:RollRandomAtts(wpn.Attachments)

            wpn:PostModify()
            wpn:PruneAttachments()
            wpn:SendWeapon()
        end
    end

    ARC9.RandomizeQueue = {}
end

hook.Add("Think", "ARC9_Think_TryRandomize", ARC9.TryRandomize)