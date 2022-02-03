if game.SinglePlayer() then

net.Receive("arc9_sp_health", function(len, ply)
    local ent = net.ReadEntity()

    if !IsValid(ent) then return end

    ent:SetHealth(0)
    ent.ARC9CLHealth = 0
end)

end