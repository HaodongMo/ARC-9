gameevent.Listen( "entity_killed" )
hook.Add( "entity_killed", "entity_killed_example", function( data ) 
    local inflictor_index = data.entindex_inflictor		// Same as Weapon:EntIndex() / weapon used to kill victim
    local attacker_index = data.entindex_attacker		// Same as Player/Entity:EntIndex() / person or entity who did the damage
    local damagebits = data.damagebits			// DAMAGE_TYPE - use BIT operations to decipher damage types...
    local victim_index = data.entindex_killed		// Same as Victim:EntIndex() / the entity / player victim

    // Called when a Player or Entity is killed

    if !victim_index then return end
    if !attacker_index then return end
    if !inflictor_index then return end

    local ent = Entity( victim_index )
    local attacker = Entity( attacker_index )
    local inflictor = Entity( inflictor_index )

    if IsValid(inflictor) and inflictor:IsWeapon() and inflictor.ARC9 then
        inflictor:RunHook("Hook_OnKill", ent)
    elseif attacker:IsPlayer() then
        local wpn = attacker:GetActiveWeapon()

        if IsValid(wpn) and wpn.ARC9 then
            wpn:RunHook("Hook_OnKill", ent)
        end
    end
end )