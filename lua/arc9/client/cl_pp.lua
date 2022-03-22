hook.Add("RenderScreenspaceEffects", "ARC9_SSE", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:HoldBreathPP()
end)