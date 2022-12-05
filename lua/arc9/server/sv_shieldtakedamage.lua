hook.Add("EntityTakeDamage", "ARC9_ShieldTakeDamage", function(ent, dmg)
    if !ent.ARC9IsShield then return end
end)