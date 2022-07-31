hook.Add("PlayerBindPress", "ARC9_Binds", function(ply, bind, pressed, code)
    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ARC9 then return end

    if !pressed then return end

    if bind == "+use" and !LocalPlayer():KeyDown(IN_USE) then
        return ARC9.AttemptGiveNPCWeapon()
    end


    if bind == "+showscores" then
        if wpn:GetCustomize() then
            if ply:KeyDown(IN_USE) then
                wpn:CycleSelectedAtt(-1)
            else
                wpn:CycleSelectedAtt(1)
            end
            return true
        end
    end

    if bind == "+menu_context" then
        if !wpn:GetInSights() and !LocalPlayer():KeyDown(IN_USE) then
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
        elseif wpn:GetInSights() and !LocalPlayer():KeyDown(IN_USE) then
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

    local CTRL = ARC9.ControllerMode()

    if CTRL then
        return bind
    elseif !key then
        return "?" .. bind .. "?"
    else
        return string.upper(key)
    end
end