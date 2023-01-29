local font_cvar = (game.SinglePlayer() or CLIENT) and GetConVar("arc9_font")
local fontaddsize_cvar = (game.SinglePlayer() or CLIENT) and GetConVar("arc9_font_addsize")

function ARC9:GetFont()
    local f = font_cvar and font_cvar:GetString()
    if !f or f == "" then f = ARC9:GetPhrase("font") or "Venryn Sans" end
    --if !f or f == "" then f = "Venryn Sans" end
    return f
end

function ARC9:GetUnscaledFont()
    local f = ARC9:GetPhrase("unscaled_font") or "HD44780A00 5x8"
    return f
end

if !ARC9.ScreenScale then ARC9.ScreenScale = function(size) return size * (ScrW() / 640) * GetConVar("arc9_hud_scale"):GetFloat() * 0.9 end end -- idk

local sizes_to_make = {
    4,
    6,
    7,
    8,
    9,
    10,
    12,
    16,
    20,
    24,
    32
}

local unscaled_sizes_to_make = {
    12,
    16,
    24,
    32,
    48,
    64
}

local function generatefonts()
    local font = ARC9:GetFont()
    local unscaled_font = ARC9:GetUnscaledFont()
    local addsize = fontaddsize_cvar:GetInt() or 0

    for _, i in pairs(sizes_to_make) do

        surface.CreateFont( "ARC9_" .. tostring(i), {
            font = font,
            size = ARC9.ScreenScale(i + addsize),
            weight = i < 16 and 650 or 600,
            antialias = true,
            extended = true, -- Required for non-latin fonts
        } )

        surface.CreateFont( "ARC9_" .. tostring(i) .. "_Slim", {
            font = font,
            size = ARC9.ScreenScale(i + addsize),
            weight = 300,
            antialias = true,
            extended = true,
        } )

        surface.CreateFont( "ARC9_" .. tostring(i) .. "_Glow", {
            font = font,
            size = ARC9.ScreenScale(i + addsize),
            weight = 600,
            antialias = true,
            blursize = ARC9.ScreenScale(i * 0.2),
            extended = true,
        } )

    end

    for _, i in pairs(unscaled_sizes_to_make) do

        surface.CreateFont( "ARC9_" .. tostring(i) .. "_Unscaled", {
            font = unscaled_font,
            size = i,
            weight = 500,
            antialias = true,
            extended = true,
        } )

        surface.CreateFont( "ARC9_" .. tostring(i) .. "_Unscaled_Glow", {
            font = unscaled_font,
            size = i,
            weight = 500,
            antialias = true,
            blursize = i * 0.2,
            extended = false,
        } )

        surface.CreateFont( "ARC9_" .. tostring(i) .. "_LCD", {
            font = "HD44780A00 5x8",
            size = i,
            weight = 500,
            antialias = true,
            extended = true,
        } )

        surface.CreateFont( "ARC9_" .. tostring(i) .. "_LCD_Glow", {
            font = "HD44780A00 5x8",
            size = i,
            weight = 500,
            antialias = true,
            blursize = i * 0.2,
            extended = false,
        } )

    end

end

surface.CreateFont( "ARC9_Deco_8_Unscaled", {
    font = "Consolas",
    size = 8,
    weight = 500,
    antialias = true,
    extended = true,
} )

generatefonts()

function ARC9.Regen()
    generatefonts()
end

concommand.Add("arc9_font_reload", ARC9.Regen)

hook.Add("OnScreenSizeChanged", "ARC9.FontRegen", function(oldWidth, oldHeight)
    print("Warning: Resolution was changed. If ARC9 fonts are too small/big now, try type  arc9_font_reload  in console ")
    timer.Simple(5, ARC9.Regen)
end)

-- cvars.AddChangeCallback("arc9_font", ARC9.Regen, "reload_fonts")
