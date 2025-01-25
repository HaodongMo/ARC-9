hook.Add("PostDrawHUD", "ARC9_SSE_PP", function()
    if !IsValid(LocalPlayer()) then return end
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    wpn:HoldBreathPP()

    if wpn:GetSight().FlatScope and wpn:GetSight().FlatScopeCC and wpn:GetSightAmount() > 0.75 then
        DrawColorModify(wpn:GetSight().FlatScopeCC)
    end
end)