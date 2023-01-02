ARC9.CSModelPile    = {} -- { {Model = NULL, Weapon = NULL} }
ARC9.FlashlightPile = {}

function ARC9.CollectGarbage()
    local removed = 0
    local kept = 0
    local newpile = {}

    for _, k in ipairs(ARC9.CSModelPile) do
        if IsValid(k.Weapon) then
            -- table.insert(newpile, k)
            kept = kept + 1
            newpile[kept] = k
            continue
        end

        SafeRemoveEntity(k.Model)

        removed = removed + 1
    end

    ARC9.CSModelPile = newpile

    if ARC9.Dev(2) then
        if removed > 0 then
            print("ARC9 GC: Removed " .. tostring(removed) .. " CSModels")
        else
            -- print("ARC9 GC: Nothing removed")
        end
    end
end

hook.Add("PostCleanupMap", "ARC9.CleanGarbage", function()
    ARC9.CollectGarbage()
end)

timer.Create("ARC9 CSModel Garbage Collector", 5, 0, ARC9.CollectGarbage)

hook.Add("PostDrawEffects", "ARC9_CleanFlashlights", function()
    local newflashlightpile = {}

    for _, k in ipairs(ARC9.FlashlightPile) do
        if IsValid(k.Weapon) and k.Weapon == LocalPlayer():GetActiveWeapon() then
            table.insert(newflashlightpile, k)

            continue
        end

        if k.ProjectedTexture and k.ProjectedTexture:IsValid() then
            k.ProjectedTexture:Remove()
        end
    end

    ARC9.FlashlightPile = newflashlightpile

    -- local wpn = LocalPlayer():GetActiveWeapon()

    -- if !wpn then return end
    -- if !IsValid(wpn) then return end
    -- if !wpn.ARC9 then return end

    -- if GetViewEntity() == LocalPlayer() then return end

    -- wpn:KillFlashlights()
end)