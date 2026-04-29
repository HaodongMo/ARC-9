hook.Add("PreRender", "ARC9_PreRender", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:RunHook("Hook_DoRT")

    if wpn:IsCheapScope() then return end

    local atttbl = wpn:IsScoping()

    if !ARC9_ENABLE_NEWSCOPES_MEOW and atttbl then
        wpn:DoRT(wpn:GetRTScopeFOV(), atttbl)
    end

    
    if ARC9_ENABLE_NEWSCOPES_MEOW and wpn.RTScopeModel and wpn.RTScopeModel.RTScopeDrawingRN then
        -- if atttbl then
        wpn:RenderRT(wpn:GetRTScopeMagnification(), atttbl)
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    if !wpn:IsCheapScope() then return end

    if ARC9_ENABLE_NEWSCOPES_MEOW and wpn.RTScopeModel and wpn.RTScopeModel.RTScopeDrawingRN then
        local atttbl = wpn:IsScoping()
        ARC9.DrawPhysBullets()
        wpn:RenderRTCheap(atttbl)
    end
end)

hook.Add("RenderScreenspaceEffects", "ARC9_PofsttDrawViewModels", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local atttbl = wpn:IsScoping()
    wpn:DrawRTReticle(wpn.RTScopeModel, wpn.RTScopeAtttbl or {}, 1, nil, wpn:IsCheapScope())
end)