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
    if swep.NotAWeapon then
        return ARC9.WEAPON_MISC
    elseif swep.PrimaryBash then
        return ARC9.WEAPON_MELEE
    elseif swep.ShootEnt or rpgammotypes[swep.Ammo] then
        return ARC9.WEAPON_RPG
    elseif swep.Num > 0 or swep.Ammo == "Buckshot" then
        return ARC9.WEAPON_SHOTGUN
    elseif sniperammotypes[swep.Ammo] then
        return ARC9.WEAPON_SNIPER
    end

    local bestfiremode = 1

    for _, mode in ipairs(swep.Firemodes) do
        if mode.Mode <= -1 then
            bestfiremode = mode.Mode
            break
        elseif mode.Mode > bestfiremode then
            bestfiremode = mode.Mode
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
end