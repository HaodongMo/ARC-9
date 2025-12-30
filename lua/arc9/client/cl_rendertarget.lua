local ARC9_cheapscopes = GetConVar("ARC9_cheapscopes")

hook.Add("PreRender", "ARC9_PreRender", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:RunHook("Hook_DoRT")

    if ARC9_cheapscopes:GetBool() then return end

    local atttbl = wpn:IsScoping()

    -- if atttbl then
    if ARC9_ENABLE_NEWSCOPES_MEOW then
        wpn:RenderRT(wpn:GetRTScopeFOV(), atttbl)
    end

    if !ARC9_ENABLE_NEWSCOPES_MEOW and atttbl then
        wpn:DoRT(wpn:GetRTScopeFOV(), atttbl)
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    if !ARC9_cheapscopes:GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local atttbl = wpn:IsScoping()

    if atttbl then
        local fov = wpn:GetRTScopeFOV()

        fov = wpn:WidescreenFix(wpn:GetViewModelFOV())

        wpn:DoCheapScope(fov, atttbl)
    end
end)