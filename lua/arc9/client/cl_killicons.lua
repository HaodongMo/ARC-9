ARC9OLDKilliconDraw = ARC9OLDKilliconDraw or killicon.Render or killicon.Draw
local killicons_cachednames = {}
local killicons_cachedicons = {}
local killicons_cachedtimes = {}
local killiconmat = Material("arc9/arc9_logo.png", "mips smooth")

local arc9_killfeed_enable = GetConVar("arc9_killfeed_enable")
local arc9_killfeed_dynamic = GetConVar("arc9_killfeed_dynamic")
ARC9NEWKillicondraw = function(x, y, name, alpha)
    if !arc9_killfeed_enable:GetBool() then
        return ARC9OLDKilliconDraw(x, y, name, alpha)
    end

    local wpn = weapons.Get(name)

    if wpn and wpn.ARC9 and wpn.NoDynamicKillIcon then
        return ARC9OLDKilliconDraw(x, y, name, alpha)
    end

    if killicons_cachednames[name] == true then
        local w, h = 96, 96
        x = x - (killicon.Render and 25 or 48) -- killiocn render is only on x64 and they changed offsets or something
        y = y - (killicon.Render and 25 or 34)

        cam.Start2D()

        local selecticon = killicons_cachedicons[name]

        if arc9_killfeed_dynamic:GetBool() and (!killicons_cachedtimes[name] or (killicons_cachedtimes[name] and killicons_cachedtimes[name] < CurTime())) then -- dynamic
            killicons_cachedtimes[name] = CurTime() + 5
            killicons_cachedicons[name] = nil
            -- print("RESET")
        end

        if !selecticon then -- not cached
            local filename = ARC9.PresetPath .. name .. "_icon." .. ARC9.PresetIconFormat
            local loadedmat = Material("data/" .. filename, "smooth")
            -- local loadedmat

            if !loadedmat or loadedmat:IsError() then -- there is no fucking icon in data folder!!!!
                local found

                if game.SinglePlayer() then -- trying find in your hands
                    local probablythegun = LocalPlayer():GetActiveWeapon()

                    if IsValid(probablythegun) and probablythegun:GetClass() == name then
                        loadedmat = probablythegun:DoIconCapture(true)
                        found = true
                    end
                end

                if !found then -- nah, bruteforcing all ents until we find gun with same classname
                    for _, v in ipairs(ents.GetAll()) do
                        if v:GetClass() == name then
                            loadedmat = v:DoIconCapture(true)
                        end
                    end
                end
            end
            
            loadedmat = loadedmat or Material("data/" .. filename, "smooth")

            killicons_cachedicons[name] = loadedmat
            selecticon = loadedmat
        end

        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(selecticon or killiconmat)
        surface.DrawTexturedRectUV( x, y, w, h, 1, 0, 0, 1 ) -- fliping
        cam.End2D()
    else
        if killicons_cachednames[name] == nil then -- not cached yet, checking for arc9
            killicons_cachednames[name] = (weapons.Get(name) and weapons.Get(name).ARC9) or false -- weapons.get() will return nil for any hl2 base gun
        else -- we know it is totally not arc9 gun
            return ARC9OLDKilliconDraw(x, y, name, alpha)
        end
    end
end

timer.Simple(5, function() -- to make Autoicons addon not override our stuff
    killicon.Render = ARC9NEWKillicondraw
    killicon.Draw = ARC9NEWKillicondraw
end)