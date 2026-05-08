hook.Add("PreRender", "ARC9_PreRender", function()
    local lp = LocalPlayer()
    if lp:ShouldDrawLocalPlayer() then return end
    local wpn = lp:GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:RunHook("Hook_DoRT")

    if wpn:IsCheapScope() then return end

    if ARC9_ENABLE_NEWSCOPES_MEOW and wpn.RTScopeModel and wpn.RTScopeModel.RTScopeDrawingRN then
        wpn:RenderRT(false, wpn:GetRTScopeMagnification())
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    if !wpn:IsCheapScope() then return end

    if ARC9_ENABLE_NEWSCOPES_MEOW and wpn.RTScopeModel and wpn.RTScopeModel.RTScopeDrawingRN then
        wpn:RenderRT(true)
    end
end)

local mat_dof = Material( "effects/arc9/vm_dof" )

hook.Add("RenderScreenspaceEffects", "ARC9_PostDrawViewModels", function()
    local lp = LocalPlayer()
    if lp:ShouldDrawLocalPlayer() then return end
    local wpn = lp:GetActiveWeapon()

    if !wpn.ARC9 then return end
    
    if mat_dof:GetFloat("$c0_x") > 0.4 then -- thats prob cheaper than checking for all conditions, handled in cl_vm anyway
        wpn:RenderDoF()
    end

    local atttbl = wpn:IsScoping()
    
    if wpn.RTScope then wpn.RTScopeModel = wpn:GetVM() end

    wpn:DrawRTReticle(wpn.RTScopeModel, atttbl or {}, nil, wpn:IsCheapScope())
end)