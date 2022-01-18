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
}

local font = "Exo Regular"

local function generatefonts()

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
            font = font,
            size = i,
            weight = 500,
            antialias = true,
            extended = true,
        } )

    end

end

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