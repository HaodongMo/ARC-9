local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "ARC9_HideHUD", function(name)
    if !IsValid(LocalPlayer()) then return end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    if wpn:GetCustomize() then
        if hide[name] then return false end
    end
end)

ARC9.Colors = {
    bg      = Color(66, 66, 61),
    fg      = Color(220, 220, 188),
    sel     = Color(255, 150, 100),
    occupied = Color(150, 255, 100),
    hi      = Color(255, 255, 255),
    shadow  = Color(17, 17, 9),

    neg     = Color(255, 100, 100),
    pos     = Color(100, 255, 100),
}

function ARC9.GetHUDColor(part, alpha)
    local col = ARC9.Colors[part] or ARC9.Colors.hi
    col.a = alpha or 255
    return col
end