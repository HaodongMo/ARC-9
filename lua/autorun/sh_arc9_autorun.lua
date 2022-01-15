AddCSLuaFile()

ARC9 = {}

ARC9.Overrun = false

local searchdir = "arc9/"

for _, v in pairs(file.Find(searchdir .. "common/*", "LUA")) do
    include(searchdir .. "common/" .. v)
    AddCSLuaFile(searchdir .. "common/" .. v)
end

for _, v in pairs(file.Find(searchdir .. "shared/*", "LUA")) do
    include(searchdir .. "shared/" .. v)
    AddCSLuaFile(searchdir .. "shared/" .. v)
end

for _, v in pairs(file.Find(searchdir .. "client/*", "LUA")) do
    AddCSLuaFile(searchdir .. "client/" .. v)
    if CLIENT then
        include(searchdir .. "client/" .. v)
    end
end

if SERVER or game.SinglePlayer() then
    for _, v in pairs(file.Find(searchdir .. "server/*", "LUA")) do
        include(searchdir .. "server/" .. v)
    end
end