net.Receive("ARC9_networkweapon", function(len, ply)
    local wpn = net.ReadEntity()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:ReceiveWeapon()
end)