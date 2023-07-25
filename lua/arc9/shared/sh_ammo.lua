-- arccw code lol
function ARC9:AddGrenadeAmmo()
    if GetConVar("arc9_equipment_generate_ammo"):GetBool() then
        for i, k in pairs(weapons.GetList()) do
            local class = k.ClassName
            local wpntbl = weapons.Get(class)
            if !wpntbl.ARC9 then continue end

            if (wpntbl.Throwing or wpntbl.Disposable) and !wpntbl.DoNotEquipmentAmmo then
                -- ammoid check will cause inconsistency between SV/CL on map change
                -- Initialize is only run once anyways, so it should be fine
                --local ammoid = game.GetAmmoID(class)
                --if ammoid == -1 then
                    -- if ammo type does not exist, build it
                    game.AddAmmoType({
                        name = class,
                    })
                    print("ARC9 adding ammo type " .. class)
                    if CLIENT then
                        language.Add(class .. "_ammo", wpntbl.PrintName)
                    end
                    ARC9.PhraseTable["en"]["ammo." .. class] = wpntbl.PrintName
                --end

                k.Ammo = class
                k.OldAmmo = class
            end
        end
    end
end

hook.Add("Initialize", "ARC9_AddGrenadeAmmo", ARC9.AddGrenadeAmmo)