-- credits : feusg for some things

local function CacheAModel(mdl)
    if SERVER then
        if util.IsValidModel(tostring(mdl)) then
            local cmdl = ents.Create("prop_dynamic")
            cmdl:SetModel(mdl)
            cmdl:Spawn()
            cmdl:Remove()
        end
    end
end

function ARC9.CacheAttsModels()
    if SERVER then
        if !ARC9.AttMdlPrecached then
            print("ARC9: Starting caching all attachments models assets.")
            for _, mdl in ipairs(ARC9.ModelToPrecacheList) do
                CacheAModel(mdl)
            end

            ARC9.AttMdlPrecached = true
            print("ARC9: Done caching attachments models. Pretty heavy isn't it?")
        end
    end
end

ARC9.PrecachedWepSounds = {}

local WepPossibleSfx = {
    "BreathInSound",
    "BreathOutSound",
    "BreathRunOutSound",
    "DropMagazineSounds",
    "FirstShootSound",
    "FirstShootSoundSilenced",
    "FirstDistantShootSound",
    "FirstDistantShootSoundSilenced",
    "ShootSound",
    "LayerSound",
    "AtmosSound",
    "ShootSoundSilenced",
    "LayerSoundSilenced",
    "AtmosSoundSilenced",
    "ShootSoundIndoor",
    "LayerSoundIndoor",
    "AtmosSoundIndoor",
    "ShootSoundSilencedIndoor",
    "LayerSoundSilencedIndoor",
    "AtmosSoundSilencedIndoor",
    "DistantShootSound",
    "DistantShootSoundSilenced",
    "DistantShootSoundIndoor",
    "DistantShootSoundSilencedIndoor",
    "ShootSoundTail",
    "ShootSoundTailIndoor",
    "FiremodeSound",
    "ToggleAttSound",
    "DryFireSound",
    "EnterSightsSound",
    "ExitSightsSound",
    "MeleeHitSound",
    "MeleeHitWallSound",
    "MeleeSwingSound",
    "BackstabSound",
    "TriggerDownSound",
    "TriggerUpSound",
    "ShellSounds",
    "RicochetSounds",
}

local function CacheASound(str)
    local ex = string.GetExtensionFromFilename(str)

    if ex == "ogg" or ex == "wav" or ex == "mp3" then
        if SERVER then
            local cmdl = ents.Create("prop_dynamic")
            str = string.Replace(str, "sound\\", "")
            str = string.Replace(str, "sound/", "" )
            cmdl:EmitSound(str, 0, 100, 0.001, CHAN_WEAPON)
            cmdl:Remove()
        else
            if IsValid(LocalPlayer()) then
                LocalPlayer():EmitSound(str, 75, 100, 0.001, CHAN_WEAPON)
            end
        end
    end
end

function ARC9.CacheWepSounds(wep, class)
    if !ARC9.PrecachedWepSounds[class] then
        local SoundsToPrecacheList = {}

        for i, posiblesfx in ipairs(WepPossibleSfx) do
            local sfx = wep[posiblesfx]

            if istable(sfx) then
                for _, sfxinside in ipairs(sfx) do
                    table.insert(SoundsToPrecacheList, sfxinside)
                end
            elseif isstring(sfx) then
                table.insert(SoundsToPrecacheList, sfx)
            end
        end

        for i, sfx in ipairs(SoundsToPrecacheList) do
            timer.Simple(i * 0.01, function()
                CacheASound(sfx)
            end)
        end
        
        ARC9.PrecachedWepSounds[class] = true
    end
end

function ARC9.CacheWeaponsModels()
    if !ARC9.WepMdlPrecached then
        print("ARC9: Precaching all weapon models!")

        for i, wep in ipairs(weapons.GetList()) do
            if weapons.IsBasedOn(wep.ClassName, "arc9_base") then
                if wep.ViewModel then
                    CacheAModel(wep.ViewModel)
                end
            end
        end

        ARC9.WepMdlPrecached = true
        print("ARC9: Finished caching all weapon models, pretty heavy!")
    end
end

function ARC9.CacheAllSounds()
    for i, wep in ipairs(weapons.GetList()) do
        if weapons.IsBasedOn(wep.ClassName, "arc9_base") then
            if wep.ViewModel then
                ARC9.CacheWepSounds(wep, wep.ClassName)
            end
        end
    end
end

timer.Simple(1, function() 
    if SERVER then
        if GetConVar("arc9_precache_wepmodels_onstartup"):GetBool() then
            ARC9.CacheWeaponsModels()
        end
        
        if GetConVar("arc9_precache_attsmodels_onstartup"):GetBool() then
            ARC9.CacheAttsModels()
        end
    end

    if GetConVar("arc9_precache_allsounds_onstartup"):GetBool() then
        ARC9.CacheAllSounds()
    end
end)


concommand.Add("arc9_precache_allsounds", ARC9.CacheAllSounds)
concommand.Add("arc9_precache_wepmodels", ARC9.CacheWeaponsModels)
concommand.Add("arc9_precache_attsmodels", ARC9.CacheAttsModels)

