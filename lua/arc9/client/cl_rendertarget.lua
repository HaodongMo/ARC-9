hook.Add("PreRender", "ARC9_PreRender", function()
    if GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local sight = wpn:GetSight()

    if sight.atttbl and sight.atttbl.RTScope and wpn:GetSightAmount() > 0 then
        wpn:DoRT(wpn:GetRTScopeFOV())
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    if !GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local sight = wpn:GetSight()

    if sight.atttbl and sight.atttbl.RTScope and wpn:GetSightAmount() > 0 then
        wpn:DoCheapScope(wpn:GetRTScopeFOV())
    end
end)