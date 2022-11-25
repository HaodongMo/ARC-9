hook.Add("PreRender", "ARC9_PreRender", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:RunHook("Hook_DoRT")

    if GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local atttbl = wpn:IsScoping()

    if atttbl then
        wpn:DoRT(wpn:GetRTScopeFOV(), atttbl)
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    if !GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local atttbl = wpn:IsScoping()

    if atttbl then
        local fov = wpn:GetRTScopeFOV()

        fov = wpn:WidescreenFix(wpn:GetViewModelFOV())

        wpn:DoCheapScope(fov, atttbl)
    end
end)