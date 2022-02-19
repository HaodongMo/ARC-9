hook.Add("CreateMove", "ARC9_CreateMove", function(cmd)
    local wpn = LocalPlayer():GetActiveWeapon()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    if wpn:Clip1() == 0 and wpn:Ammo1() > 0 and !wpn:GetCustomize() then
        if cmd:TickCount() % 2 == 0 then
            local buttons = cmd:GetButtons()

            buttons = buttons + IN_RELOAD

            cmd:SetButtons(buttons)
        end
    end
end)