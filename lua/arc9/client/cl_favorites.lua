ARC9.Favorites = {}

ARC9.FavoritesWeight = 9999

function ARC9:LoadFavorites()
    local f = file.Open("arc9_favorites.txt", "r", "DATA")
    if !f then return end

    ARC9.Favorites = {}

    while !f:EndOfFile() do
        local line = f:ReadLine()
        line = string.Trim(line, "\n")

        ARC9.Favorites[line] = true
    end

    f:Close()
end

function ARC9:SaveFavorites()
    local f = file.Open("arc9_favorites.txt", "w", "DATA")

    for i, k in pairs(ARC9.Favorites) do
        f:Write(i)
        f:Write("\n")
    end

    f:Close()
end

function ARC9:AddAttToFavorites(att)
    ARC9.Favorites[att] = true
    ARC9:SaveFavorites()
end

function ARC9:RemoveAttFromFavorites(att)
    ARC9.Favorites[att] = nil
    ARC9:SaveFavorites()
end

function ARC9:ToggleFavorite(att)
    if ARC9.Favorites[att] then
        ARC9.Favorites[att] = nil
        surface.PlaySound("arc9/newui/ui_part_favourite2.ogg")
    else
        ARC9.Favorites[att] = true
        surface.PlaySound("arc9/newui/ui_part_favourite1.ogg")
    end
    ARC9:SaveFavorites()
end

hook.Add("PreGamemodeLoaded", "ARC9_PreGamemodeLoaded_LoadFavorites", function()
    ARC9:LoadFavorites()
end)