hook.Add("PreRender", "ARC9_PreRender", function()
    if GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local sight = wpn:GetSight()

    local atttbl = wpn:GetFinalAttTable(sight.slottbl)

    if sight.ExtraSightData then
        atttbl = table.Copy(atttbl)
        table.Merge(atttbl, sight.ExtraSightData)
    end

    if atttbl and atttbl.RTScope and wpn:GetSightAmount() > 0 then
        wpn:DoRT(wpn:GetRTScopeFOV(), sight.atttbl)
    end
end)

hook.Add("PreDrawViewModels", "ARC9_PreDrawViewModels", function()
    if !GetConVar("ARC9_cheapscopes"):GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    local sight = wpn:GetSight()

    local atttbl = wpn:GetFinalAttTable(sight.slottbl)

    if sight.ExtraSightData then
        atttbl = table.Copy(atttbl)
        table.Merge(atttbl, sight.ExtraSightData)
    end

    if atttbl and atttbl.RTScope and wpn:GetSightAmount() > 0 then
        wpn:DoCheapScope(wpn:GetRTScopeFOV(), atttbl)
    end
end)