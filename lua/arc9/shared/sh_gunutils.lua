gameevent.Listen( "entity_killed" )
hook.Add( "entity_killed", "entity_killed_example", function( data ) 
    local inflictor_index = data.entindex_inflictor		-- Same as Weapon:EntIndex() / weapon used to kill victim
    local attacker_index = data.entindex_attacker		-- Same as Player/Entity:EntIndex() / person or entity who did the damage
    local damagebits = data.damagebits			-- DAMAGE_TYPE - use BIT operations to decipher damage types...
    local victim_index = data.entindex_killed		-- Same as Victim:EntIndex() / the entity / player victim

    -- Called when a Player or Entity is killed

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

timer.Simple(10, function() -- tfa does same thing, no need to copy (timer here cuz tfa loads after arc9)
    if !TFA then 
        -- code stolen from wiki
        local cheats = GetConVar("sv_cheats" )
        local timeScale = GetConVar("host_timescale" )

        hook.Add("EntityEmitSound", "ARC9_TimeWarpSounds", function(t)
            local p = t.Pitch
            
            if game.GetTimeScale() != 1 then
                p = p * game.GetTimeScale()
            end
            
            if timeScale:GetInt() != 1 and cheats >= 1 then
                p = p * timeScale:GetInt()
            end
            
            if p != t.Pitch then
                t.Pitch = math.Clamp(p, 0, 255)
                return true
            end
            
            if CLIENT and engine.GetDemoPlaybackTimeScale() != 1 then
                t.Pitch = math.Clamp(t.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255)
                return true
            end
            
        end)
    end
end)