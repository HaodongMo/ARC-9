hook.Add("PlayerBindPress", "ARC9_Binds", function(ply, bind, pressed, code)
    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ARC9 then return end

    if !pressed then return end

    -- print(bind)

    if bind == "impulse 100" then
       local toggled = wpn:ToggleAllStatsOnF()

       if toggled then
            return true
       end
    end

    if bind == "+use" and !LocalPlayer():KeyDown(IN_USE) then
        return ARC9.AttemptGiveNPCWeapon()
    end

    if bind == "+menu_context" then
        if !LocalPlayer():KeyDown(IN_ATTACK2) and !LocalPlayer():KeyDown(IN_USE) then
            if wpn:GetCustomize() then
                net.Start("ARC9_togglecustomize")
                net.WriteBool(false)
                net.SendToServer()
                -- wpn:DoIconCapture()
            else
                net.Start("ARC9_togglecustomize")
                net.WriteBool(true)
                net.SendToServer()
            end

            return true
        elseif LocalPlayer():KeyDown(IN_ATTACK2) then
            return true
        end
    end

    if wpn:GetInSights() then
        if bind == "invnext" then
            wpn:Scroll(1)

            return true
        elseif bind == "invprev" then
            wpn:Scroll(-1)

            return true
        end
    end
end)

function ARC9.GetBindKey(bind)
    local key = input.LookupBinding(bind)

    if !key then
        return ""
    else
        return string.upper(key)
    end
end