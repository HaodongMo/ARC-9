util.AddNetworkString("ARC9_togglecustomize")
util.AddNetworkString("ARC9_networkweapon")
util.AddNetworkString("ARC9_sendattinv")
util.AddNetworkString("ARC9_sendbullet")

net.Receive("ARC9_togglecustomize", function(len, ply)
    local bf = net.ReadBool()

    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ARC9 then return end

    wpn:ToggleCustomize(bf)
end)

net.Receive("ARC9_networkweapon", function(len, ply)
    local wpn = net.ReadEntity()

    if !wpn.ARC9 then return end

    wpn:ReceiveWeapon()
end)