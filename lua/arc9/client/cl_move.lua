hook.Add("CreateMove", "ARC9_CreateMove", function(cmd)
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    if wpn:GetRequestReload() and !wpn:GetCustomize() and wpn:CanReload() then
        if cmd:TickCount() % 2 == 0 then
            local buttons = cmd:GetButtons()

            buttons = buttons + IN_RELOAD

            cmd:SetButtons(buttons)
        end
    end
end)