util.AddNetworkString("arc9_togglecustomize")
util.AddNetworkString("arc9_networkweapon")
util.AddNetworkString("arc9_sendattinv")
util.AddNetworkString("arc9_sendbullet")
util.AddNetworkString("arc9_givenpcweapon")

util.AddNetworkString("arc9_reloadatts")
util.AddNetworkString("arc9_reloadlangs")

util.AddNetworkString("arc9_randomizeatts")

util.AddNetworkString("arc9_sendblacklist")
util.AddNetworkString("arc9_proppickup")
util.AddNetworkString("arc9_stoppickup")
util.AddNetworkString("arc9_sendnpckill")

if game.SinglePlayer() then

util.AddNetworkString("arc9_sp_health")

end

net.Receive("arc9_togglecustomize", function(len, ply)
    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ARC9 then return end

    local bf = net.ReadBool()

    wpn:ToggleCustomize(bf)
end)

local arc9_atts_nocustomize = GetConVar("arc9_atts_nocustomize")
local arc9_free_atts = GetConVar("arc9_free_atts")

net.Receive("arc9_networkweapon", function(len, ply)
    if arc9_atts_nocustomize:GetBool() then return end

    local wpn = net.ReadEntity()

    if !wpn.ARC9 then return end

    wpn:ReceiveWeapon()
end)

net.Receive("arc9_randomizeatts", function(len, ply)
    if !arc9_free_atts:GetBool() then return end

    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then return end

    if wpn.NextRandomize and wpn.NextRandomize > CurTime() then return end
    wpn.NextRandomize = CurTime() + 0.055

    wpn:QueueForRandomize()
    timer.Simple(0.1, function() 
        if IsValid(wpn) then
            wpn:PruneAttachments()
            wpn:PostModify()
            -- wpn:SendWeapon()
        end
    end)
end)