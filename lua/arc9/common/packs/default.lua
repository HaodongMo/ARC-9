PACK.Name = "ARC-9 Default"

PACK.Credits = [[
    ARC-9 Team
]]

-- Not required, leave nil if you don't have it
PACK.WorkshopLink = "https://steamcommunity.com/sharedfiles/filedetails/?id=2131057232" -- define one after publishing addon
PACK.GithubLink = "https://github.com/HaodongMo/ARC-9" 
PACK.DiscordLink = "https://discord.gg/wkafWps44a" -- permanent

PACK.Slots = {
    ["muzzle"] = {
        PrettyName = "Muzzle", -- if not universal please write something about pack and weapon it for. "EFT AK 5.45 Muzzle" for example
        Price = 500, -- not yet implemented
        Box = "models/items/arc9/att_plastic_box.mdl", -- Use att_plastic_box (modern middle sized container), att_wooden_box (old big box) or att_cardboard_box (cheap small box)
        -- Might make it as shared section for atts idk
    }
}
