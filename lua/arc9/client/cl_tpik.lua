hook.Add("PrePlayerDraw", "ARC9_TPIK", function(ply, flags)
    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:DoTPIK()
end)