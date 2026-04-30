hook.Add("PreRender", "ARC9_PreRender", function()
    local lp = LocalPlayer()
    if lp:ShouldDrawLocalPlayer() then return end
    local wpn = lp:GetActiveWeapon()

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

local nextrendermeow = 0

hook.Add("RenderScreenspaceEffects", "ARC9_PofsttDrawViewModels", function()
    local lp = LocalPlayer()
    if lp:ShouldDrawLocalPlayer() then return end
    local wpn = lp:GetActiveWeapon()

    if !wpn.ARC9 then return end
    
    local atttbl = wpn:IsScoping()
    
    if atttbl and atttbl.FPSLock and nextrendermeow >= CurTime() and wpn:GetSightAmount() > 0.99 then return end
    if atttbl and atttbl.FPSLock then nextrendermeow = CurTime() + (atttbl.FPSLock or 45) end
    if wpn.RTScope then wpn.RTScopeModel = wpn:GetVM() end
    
    wpn:DrawRTReticle(wpn.RTScopeModel, atttbl or {}, nil, wpn:IsCheapScope())
end)