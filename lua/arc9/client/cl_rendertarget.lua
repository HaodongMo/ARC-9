hook.Add("PreRender", "ARC9_PreRender", function()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    wpn:RunHook("Hook_DoRT")

    if GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local sight = wpn:GetSight()

    local atttbl

    if sight.BaseSight then
        atttbl = wpn:GetTable()
    else
        atttbl = wpn:GetFinalAttTable(sight.slottbl)
    end

    if sight.ExtraSightData then
        atttbl = table.Copy(atttbl)
        table.Merge(atttbl, sight.ExtraSightData)
    end

    if atttbl and atttbl.RTScope and wpn:GetSightAmount() > 0 then
        wpn:DoRT(wpn:GetRTScopeFOV(), atttbl)
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    if !GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local sight = wpn:GetSight()

    local atttbl

    if sight.BaseSight then
        atttbl = wpn:GetTable()
    else
        atttbl = wpn:GetFinalAttTable(sight.slottbl)
    end

    if sight.ExtraSightData then
        atttbl = table.Copy(atttbl)
        table.Merge(atttbl, sight.ExtraSightData)
    end

    if atttbl and atttbl.RTScope and wpn:GetSightAmount() > 0 then
        local fov = wpn:GetRTScopeFOV()

        fov = wpn:WidescreenFix(wpn:GetViewModelFOV())

        wpn:DoCheapScope(fov, atttbl)
    end
end)