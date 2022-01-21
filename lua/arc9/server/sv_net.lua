util.AddNetworkString("arc9_togglecustomize")
util.AddNetworkString("arc9_networkweapon")
util.AddNetworkString("arc9_sendattinv")
util.AddNetworkString("arc9_sendbullet")

util.AddNetworkString("arc9_reloadatts")
util.AddNetworkString("arc9_reloadlangs")

net.Receive("arc9_togglecustomize", function(len, ply)
    local bf = net.ReadBool()

    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ARC9 then return end

    wpn:ToggleCustomize(bf)
end)

net.Receive("arc9_networkweapon", function(len, ply)
    local wpn = net.ReadEntity()

    if !wpn.ARC9 then return end

    wpn:ReceiveWeapon()
end)