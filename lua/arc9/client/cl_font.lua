local font_cvar = (game.SinglePlayer() or CLIENT) and GetConVar("arc9_font")

function ARC9:GetFont()
    local f = font_cvar and font_cvar:GetString()
    if !f or f == "" then f = ARC9:GetPhrase("font") or "Exo Regular" end
    return f
end

function ARC9:GetUnscaledFont()
    local f = ARC9:GetPhrase("unscaled_font") or "HD44780A00 5x8"
    return f
end

local sizes_to_make = {
    4,
    6,
    8,
    10,
    12,
    16,
    24,
    32
}

local unscaled_sizes_to_make = {
    24
}

local function generatefonts()

    local font = ARC9:GetFont()
    local unscaled_font = ARC9:GetUnscaledFont()

    for _, i in pairs(sizes_to_make) do

        surface.CreateFont( "ARC9_" .. tostring(i), {
            font = font,
            size = ScreenScale(i),
            weight = 500,
            antialias = true,
            extended = true, -- Required for non-latin fonts
        } )

        surface.CreateFont( "ARC9_" .. tostring(i) .. "_Glow", {
            font = font,
            size = ScreenScale(i),
            weight = 500,
            antialias = true,
            blursize = ScreenScale(i * 0.2),
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
            extended = true,
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

function ARC9.Regen(full)
    if full then
        generatefonts()
    end
end

local lastscrw = ScrW()
local lastscrh = ScrH()

hook.Add( "Think", "ARC9.Regen", function()
    if lastscrw != ScrW() or lastscrh != ScrH() then
        ARC9.Regen(true)
    end

    lastscrw = ScrW()
    lastscrh = ScrH()
end)

cvars.AddChangeCallback("arc9_font", function(cvar, old, new)
    generatefonts()
end, "reload_fonts")