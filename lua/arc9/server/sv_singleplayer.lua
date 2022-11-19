if game.SinglePlayer() then

hook.Add("EntityTakeDamage", "ARC9_ETD", function(npc, dmg)
    timer.Simple(0, function()
        if !IsValid(npc) then return end
        if npc:Health() <= 0 then
            net.Start("ARC9_sp_health")
            net.WriteEntity(npc)
            net.Broadcast()
        end
    end)
end)

end

hook.Add("OnPlayerPhysicsPickup", "ARC9_PropPickup", function(ply, ent)
    ply.ARC9_HoldingProp = ent
    local gun = ply:GetActiveWeapon()
    if gun.ARC9 then
        gun:SetHoldType("duel")
        ply:DoAnimationEvent(ACT_FLINCH_BACK)
    end
    net.Start("arc9_proppickup")
    net.WriteEntity(ent)
    net.Send(ply)
end)