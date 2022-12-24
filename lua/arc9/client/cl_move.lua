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

    if GetConVar("arc9_autoreload"):GetBool() then
        if wpn:GetUBGL() then
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip2() == 0 and wpn:Ammo2() > 0 and wpn:GetNextPrimaryFire() + 0.5 < CurTime() then
                local buttons = cmd:GetButtons()

                buttons = buttons + IN_RELOAD

                cmd:SetButtons(buttons)
            end
        else
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip1() == 0 and wpn:Ammo1() > 0 and wpn:GetNextPrimaryFire() + 0.5 < CurTime() then
                local buttons = cmd:GetButtons()

                buttons = buttons + IN_RELOAD

                cmd:SetButtons(buttons)
            end
        end
    end

    if ARC9.KeyPressed_Menu then
        local buttons = cmd:GetButtons()

        buttons = buttons + IN_BULLRUSH

        cmd:SetButtons(buttons)
    end
end)