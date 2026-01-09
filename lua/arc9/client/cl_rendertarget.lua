local ARC9_cheapscopes = GetConVar("ARC9_cheapscopes")

hook.Add("PreRender", "ARC9_PreRender", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:RunHook("Hook_DoRT")

    if ARC9_cheapscopes:GetBool() then return end

    local atttbl = wpn:IsScoping()

    -- if atttbl then
    if ARC9_ENABLE_NEWSCOPES_MEOW then
        wpn:RenderRT(wpn:GetRTScopeMagnification(), atttbl)
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
        -- render.DepthRange( 0.1, 0.1 )
        wpn:RenderRTCheap(wpn:GetRTScopeMagnification(), atttbl)
        -- wpn:RenderRT(wpn:GetRTScopeMagnification(), atttbl)

    -- if atttbl then
    --     local mag = wpn:GetRTScopeMagnification()

    --     -- fov = wpn:WidescreenFix(wpn:GetViewModelFOV())

    --     wpn:DoCheapScope(mag, atttbl)
    -- end
end)