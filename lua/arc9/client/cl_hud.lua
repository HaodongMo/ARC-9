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
    bg = Color(66, 66, 61),
    fg = Color(220, 220, 188),
    hi = Color(255, 255, 255),
    shadow = Color(17, 17, 9),
    neg = Color(200, 50, 50),
    pos = Color(50, 200, 50)
}

function ARC9.GetHUDColor(part, alpha)
    alpha = alpha or 255
    local col = ARC9.Colors[part]

    col.a = alpha

    return col
end