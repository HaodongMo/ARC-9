net.Receive("ARC9_networkweapon", function(len, ply)
    local wpn = net.ReadEntity()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:ReceiveWeapon()
end)

net.Receive("arc9_proppickup", function(len)
    local ent = net.ReadEntity()
    if !IsValid(ent) then return end
    LocalPlayer().ARC9_HoldingProp = ent
end)

net.Receive("arc9_stoppickup", function(len)
    LocalPlayer().ARC9_HoldingProp = nil
end)

net.Receive("arc9_sendnpckill", function(len)
    local ent = net.ReadEntity()

    local wpn = LocalPlayer():GetActiveWeapon()
    if IsValid(wpn) and wpn.ARC9 then
        wpn:RunHook("Hook_OnKill", ent)
    end
end)