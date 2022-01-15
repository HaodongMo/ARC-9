net.Receive("ARC9_networkweapon", function(len, ply)
    local wpn = net.ReadEntity()

    if !wpn.ARC9 then return end

    wpn:ReceiveWeapon()
end)