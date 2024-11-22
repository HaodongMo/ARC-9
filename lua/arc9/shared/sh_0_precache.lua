-- credits : feusg for some things

local function CacheAModel(mdl)
    if SERVER then
        if util.IsValidModel(tostring(mdl)) then -- apparently isvalidmodel precaches
            -- local cmdl = ents.Create("prop_dynamic")
            -- cmdl:SetModel(mdl)
            -- cmdl:Spawn()
            -- cmdl:Remove()
        end
    end
end

function ARC9.CacheAttsModels()
    if SERVER then
        if !ARC9.AttMdlPrecached then
            print("ARC9: Starting caching all attachments models assets.")
            for i, mdl in ipairs(ARC9.ModelToPrecacheList) do
                timer.Simple(i * 0.01, function()
                    CacheAModel(mdl)
                end)
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
    "ShootSoundSilenced",
    "LayerSoundSilenced",
    "ShootSoundIndoor",
    "LayerSoundIndoor",
    "ShootSoundSilencedIndoor",
    "LayerSoundSilencedIndoor",
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

local function CacheASound(str, cmdl)
    local ex = string.GetExtensionFromFilename(str)

    if ex == "ogg" or ex == "wav" or ex == "mp3" then
        if SERVER then
            str = string.Replace(str, "sound\\", "")
            str = string.Replace(str, "sound/", "" )
            if IsValid(cmdl) then cmdl:EmitSound(str, 0, 100, 0.001, CHAN_WEAPON) end
        else
            if IsValid(LocalPlayer()) then
                -- LocalPlayer():EmitSound(str, 75, 100, 0.001, CHAN_WEAPON)
            end
        end
    end
end

function ARC9.CacheWepSounds(wep, class, cmdl)
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
                CacheASound(sfx, cmdl)
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
                    timer.Simple(i * 0.01, function()
                        CacheAModel(wep.ViewModel)
                    end)
                end
            end
        end

        ARC9.WepMdlPrecached = true
        print("ARC9: Finished caching all weapon models, pretty heavy!")
    end
end

function ARC9.CacheAllSounds()
    if game.SinglePlayer() and CLIENT then return end
    local cmdl
    if SERVER then cmdl = ents.Create("prop_dynamic") end

    for i, wep in ipairs(weapons.GetList()) do
        if weapons.IsBasedOn(wep.ClassName, "arc9_base") then
            if wep.ViewModel then
                ARC9.CacheWepSounds(wep, wep.ClassName, cmdl)
            end
        end
    end
    
    if SERVER then timer.Simple(5, function() cmdl:Remove() end) end
end

timer.Simple(1, function() 
    if SERVER then
        if GetConVar("arc9_precache_wepmodels_onstartup"):GetBool() then
            ARC9.CacheWeaponsModels()
        end
        
        if GetConVar("arc9_precache_attsmodels_onstartup"):GetBool() then
            ARC9.CacheAttsModels()
        end
    else
        RunConsoleCommand("arc9_dev_benchgun", "0") -- meow
    end

    if GetConVar("arc9_precache_allsounds_onstartup"):GetBool() then
        ARC9.CacheAllSounds()
    end
end)


concommand.Add("arc9_precache_allsounds", ARC9.CacheAllSounds)
concommand.Add("arc9_precache_wepmodels", ARC9.CacheWeaponsModels)
concommand.Add("arc9_precache_attsmodels", ARC9.CacheAttsModels)

