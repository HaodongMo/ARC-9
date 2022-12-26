hook.Add("EntityTakeDamage", "ARC9_ShieldTakeDamage", function(ent, dmg)
    if !ent.ARC9IsShield then return end

    if !IsValid(ent.ARC9Weapon) then return end

    if !IsValid(ent.ARC9Weapon:GetOwner()) then return end
    if !ent.ARC9Weapon:GetOwner():IsPlayer() then return end

    ent.ARC9Weapon:PlayAnimation("blowback")
end)