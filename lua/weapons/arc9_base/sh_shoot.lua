local cancelmults = {
    [HITGROUP_HEAD] = 2,
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 1,
    [HITGROUP_LEFTARM] = 0.25,
    [HITGROUP_RIGHTARM] = 0.25,
    [HITGROUP_LEFTLEG] = 0.25,
    [HITGROUP_RIGHTLEG] = 0.25,
    [HITGROUP_GEAR] = 0.25
}

function SWEP:StillWaiting()
    local time = CurTime()

    if self:GetNextPrimaryFire() > time then return true end
    if self:GetNextSecondaryFire() > time then return true end
    if self:GetAnimLockTime() > time then return true end
    if self:GetPrimedAttack() then return true end
    if self:GetHolsterTime() > 0 then return true end

    return false
end

function SWEP:SprintLock()
    if self:GetSprintAmount() > 0 then return true end
    -- if self:GetTraversalSprintAmount() > 0 then retur    n true end
    -- if self:GetIsSprinting() then return true end

    return false
end

local soundTab = {
    name = "dryfire",
    sound = "",
    level = 75,
    pitch = 100,
    volume = 1,
    channel = ARC9.CHAN_FIDDLE
}

local sound

function SWEP:DryFire()
    local nthShot = self:GetNthShot()

    self:PlayAnimation("dryfire")
    self:SetBurstCount(0)
    self:SetNeedTriggerPress(true)

    if nthShot > 0 and self:GetProcessedValue("DryFireSingleAction") then return end

    soundTab.sound = self:RandomChoice(self:GetProcessedValue("DryFireSound"))
    self:PlayTranslatedSound(soundtab)

    self:SetNthShot(nthShot + 1)
end

local lsstr = "ShootSound"
local lsslr = "LayerSound"
local ldsstr = "DistantShootSound"

local sstrSilenced = "ShootSoundSilenced" -- made cuz it'll just pointless to concate.
local sslrSilenced = "LayerSoundSilenced"
local dsstrSilenced = "DistantShootSoundSilenced"

local soundtab1 = {
    name = "shootsound"
}

local soundtab2 = {
    name = "shootlayer"
}

local soundtab3 = {
    name = "shootdistant"
}

local soundtab4 = {
    name = "shootsoundindoor"
}

local soundtab5 = {
    name = "shootlayerindoor"
}

local soundtab6 = {
    name = "shootdistantindoor"
}

function SWEP:DoShootSounds()
    local pvar = self:GetProcessedValue("ShootPitchVariation")
    local pvrand = util.SharedRandom("ARC9_sshoot", -pvar, pvar)
    local sstr = lsstr
    local sslr = lsslr
    local dsstr = ldsstr
    local silenced = self:GetProcessedValue("Silencer") and not self:GetUBGL()
    local indoor = self:GetIndoor() -- GetIndoor returns number and that's not fact. that's a lie. It can return false
    local indoormix = 1 - (indoor or 0) -- it can be negative, but there is a check if indoormix > 0
    local havedistant = self:GetProcessedValue(dsstr)

    if silenced and self:GetProcessedValue(sstrSilenced) then
        sstr = sstrSilenced
    end

    if silenced and self:GetProcessedValue(sslrSilenced) then
        sslr = sslrSilenced
    end

    if havedistant and silenced and self:GetProcessedValue(dsstrSilenced) then
        dsstr = dsstrSilenced
    end

    do
        local burstCountZero = self:GetBurstCount() == 0
        local sstrFirst = "First" .. sstr
        local dsstrFirst = "First" .. dsstr

        if burstCountZero and self:GetProcessedValue(sstrFirst) then
            sstr = sstrFirst
        end

        if havedistant and burstCountZero and self:GetProcessedValue(dsstrFirst) then
            dsstr = dsstrFirst
        end
    end

    local ss = self:RandomChoice(self:GetProcessedValue(sstr))
    local sl = self:RandomChoice(self:GetProcessedValue(sslr))
    local dss

    if havedistant then
        dss = self:RandomChoice(self:GetProcessedValue(dsstr))
    end

    local svolume, spitch, svolumeactual = self:GetProcessedValue("ShootVolume"), self:GetProcessedValue("ShootPitch") + pvrand, self:GetProcessedValue("ShootVolumeActual") or 1
    local dvolume, dpitch, dvolumeactual

    if havedistant then
        dvolume, dpitch, dvolumeactual = math.min(149, (self:GetProcessedValue("DistantShootVolume") or svolume) * 2), (self:GetProcessedValue("DistantShootPitch") or spitch) + pvrand, self:GetProcessedValue("DistantShootVolumeActual") or svolumeactual or 1
    end

    local volumeMix = svolumeactual * indoormix

    if indoormix > 0 then

        -- doing this cuz it uses only 1 cached table and it works way faster
        do
            soundtab1.sound = ss or ""
            soundtab1.level = svolume
            soundtab1.pitch = spitch
            soundtab1.volume = volumeMix
            soundtab1.channel = ARC9.CHAN_WEAPON
        end

        do
            soundtab2.sound = sl or ""
            soundtab2.level = svolume
            soundtab2.pitch = spitch
            soundtab2.volume = volumeMix
            soundtab2.channel = ARC9.CHAN_LAYER + 2
        end

        self:PlayTranslatedSound(soundtab1)
        self:PlayTranslatedSound(soundtab2)

        if havedistant then
            do
                soundtab3.sound = dss or ""
                soundtab3.level = dvolume
                soundtab3.pitch = dpitch
                soundtab3.volume = dvolume * indoormix
                soundtab3.channel = ARC9.CHAN_DISTANT
            end

            self:PlayTranslatedSound(soundtab3)
        end
    end

    if indoor then
        local ssIN = self:RandomChoice(self:GetProcessedValue(sstr .. "Indoor"))
        local slIN = self:RandomChoice(self:GetProcessedValue(sslr .. "Indoor"))
        local dssIN = havedistant and self:RandomChoice(self:GetProcessedValue(dsstr .. "Indoor")) or nil

        do
            soundtab4.sound = ssIN
            soundtab4.level = svolume
            soundtab4.pitch = spitch
            soundtab4.volume = volumeMix
            soundtab4.channel = ARC9.CHAN_INDOOR
        end

       

        do
            soundtab5.sound = slIN or ""
            soundtab5.level = svolume
            soundtab5.pitch = spitch
            soundtab5.volume = volumeMix
            soundtab5.channel = ARC9.CHAN_INDOORLAYER
        end


        self:PlayTranslatedSound(soundtab4)
        self:PlayTranslatedSound(soundtab5)

        if havedistant then
            do
                soundtab6.sound = dssIN or ""
                soundtab6.level = dvolume
                soundtab6.pitch = dpitch
                soundtab6.volume = dvolume * indoor
                soundtab6.channel = ARC9.CHAN_INDOORDISTANT
            end

            self:PlayTranslatedSound(soundtab6)
        end
    end

    self:StartLoop()
end

function SWEP:PrimaryAttack()
    if self.NotAWeapon then return end

    local owner = self:GetOwner()

    if owner:IsNPC() then
        self:NPC_PrimaryAttack()
        return
    end

    if self:GetProcessedValue("Throwable") then
        return
    end

    if self:GetProcessedValue("PrimaryBash") then
        return
    end

    if self:GetProcessedValue("UBGLInsteadOfSights") then
        self:ToggleUBGL(false)
    end

    if self:GetSafe() then
        self:ToggleSafety(false)
        self:SetNeedTriggerPress(true)
        return
    end

    if self:GetNeedTriggerPress() then return end

    if self:GetNeedsCycle() then return end

    if self:SprintLock() then return end

    if self:GetCustomize() then return end

    if self:GetProcessedValue("Bash") and owner:KeyDown(IN_USE) and !self:GetInSights() then
        self:MeleeAttack()
        self:SetNeedTriggerPress(true)
        return
    end

    if self:HasAmmoInClip() then
        if self:GetProcessedValue("TriggerDelay") then
            local primedAttack = self:GetPrimedAttack()
            local time = CurTime()

            if self:GetBurstCount() == 0 and !primedAttack and !self:StillWaiting() then
                self:SetTriggerDelay(time + self:GetProcessedValue("TriggerDelayTime"))
                if self:GetProcessedValue("TriggerStartFireAnim") then
                    self:PlayAnimation("fire")
                else
                    self:PlayAnimation("trigger")
                end
                self:SetPrimedAttack(true)
                return
            elseif primedAttack and self:GetTriggerDelay() > time then
                return
            elseif primedAttack then
                self:SetPrimedAttack(false)
            end
        end
    else
        self:SetPrimedAttack(false)
    end

    if self:GetReloading() then
        self:SetEndReload(true)
    end

    self:DoPrimaryAttack()
end

function SWEP:DoPrimaryAttack()

    if self:StillWaiting() then return end

    local currentFiremode = self:GetCurrentFiremode()
    local burstCount = self:GetBurstCount()

    if currentFiremode > 0 and burstCount >= currentFiremode then return end

    local clip = self:GetLoadedClip()

    if self:GetProcessedValue("BottomlessClip") then
        self:RestoreClip(math.huge)
    end

    if !self:HasAmmoInClip() then
        if self:GetUBGL() and !self:GetProcessedValue("UBGLInsteadOfSights") then
            self:ToggleUBGL(false)
            self:SetNeedTriggerPress(true)
            return
        else
            self:DryFire()
            return
        end
    end

    if !self:GetProcessedValue("CanFireUnderwater") then
        if bit.band(util.PointContents(self:GetShootPos()), CONTENTS_WATER) == CONTENTS_WATER then
            self:DryFire()
            return
        end
    end

    self:SetBaseSettings()

    if self:RunHook("HookP_BlockFire") then return end

    if self:GetJammed() or self:GetHeatLockout() then
        self:DryFire()
        return
    end

    self:RunHook("Hook_PrimaryAttack")

    self:TakeAmmo()

    local triggerStartFireAnim = self:GetProcessedValue("TriggerStartFireAnim")
    local nthShot = self:GetNthShot()

    if self:GetProcessedValue("DoFireAnimation") and !triggerStartFireAnim then
        local anim = "fire"

        if self:GetProcessedValue("Akimbo") then
            if nthShot % 2 == 0 then
                anim = "fire_right"
            else
                anim = "fire_left"
            end
        end

        local banim = anim

        if !self.SuppressCumulativeShoot then
            for i = 1, burstCount+1 do
                local b = tostring(i)

                if self:HasAnimation(anim .. "_" .. tostring(b)) then
                    banim = anim .. "_" .. tostring(b)
                end
            end
        end

        self:PlayAnimation(banim, 1, false, true)
    end

    local clip1 = self:Clip1()

    self:SetLoadedRounds(clip1)

    local manualaction = self:GetProcessedValue("ManualAction")

    if !self:GetProcessedValue("NoShellEject") and !(manualaction and !self:GetProcessedValue("ManualActionEjectAnyway")) then
        local ejectdelay = self:GetProcessedValue("EjectDelay")

        if ejectdelay == 0 then
            self:DoEject()
        else
            self:SetTimer(ejectdelay, function()
                self:DoEject()
            end)
        end
    end

    self:SetAfterShot(true)

    self:DoShootSounds()

    self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimShoot"))

    local delay = 60 / self:GetProcessedValue("RPM")
    local time = CurTime()

    local curatt = self:GetNextPrimaryFire()
    local diff = time - curatt

    if diff > engine.TickInterval() or diff < 0 then
        curatt = time
    end

    self:SetNextPrimaryFire(curatt + delay)

    self:SetNthShot(nthShot + 1)

    self:DoEffects()

    if game.SinglePlayer() then
        if SERVER then
            self:CallOnClient("SInputRumble")
        end
    else
        if CLIENT then
            self:SInputRumble()
        end
    end

    local spread = self:GetProcessedValue("Spread")

    spread = math.Max(spread, 0)

    local sp, sa = self:GetShootPos()

    if IsValid(self:GetLockOnTarget()) and self:GetLockedOn() and self:GetProcessedValue("LockOnAutoaim") then
        sa = (self:GetLockOnTarget():EyePos() - sp):Angle()
    end

    self:DoProjectileAttack(sp, sa, spread)

    self:ApplyRecoil()
    self:DoVisualRecoil()

    if burstCount == 0 and currentFiremode > 1 and self:GetProcessedValue("RunawayBurst") then
        if !self:GetProcessedValue("AutoBurst") then
            self:SetNeedTriggerPress(true)
        end
    end

    self:SetBurstCount(burstCount + 1)

    if manualaction then
        if clip1 > 0 or !self:GetProcessedValue("ManualActionNoLastCycle") then
            if nthShot % self:GetProcessedValue("ManualActionChamber") == 0 then
                self:SetNeedsCycle(true)
            end
        end
    end

    if currentFiremode == 1 or clip == 0 then
        self:SetNeedTriggerPress(true)
    end

    self:DoHeat()

    if !manualaction or manualaction and !self.MalfunctionCycle then
        self:RollJam()
    end

    if clip1 == 0 then
        self:SetNthShot(0)
    end

    if self:GetProcessedValue("TriggerDelayRepeat") and self:GetOwner():KeyDown(IN_ATTACK) and currentFiremode != 1 then
        self:SetTriggerDelay(time + self:GetProcessedValue("TriggerDelayTime"))
        if triggerStartFireAnim then
            self:PlayAnimation("fire")
        else
            self:PlayAnimation("trigger")
        end
        self:SetPrimedAttack(true)
    end
end

if CLIENT then
    local cl_rumble = GetConVar("arc9_controller_rumble")
    function SWEP:SInputRumble()
        if !sinput then return false end
        if !cl_rumble:GetBool() then return false end

        local P1 = sinput.GetControllerForGamepadIndex(0)

        sinput.TriggerVibration(P1, self.RumbleHeavy, self.RumbleLight)
        sinput.SetLEDColor(P1, 255, 255, 255, false)

        timer.Remove( "SInput_ARC9_Rumble" )
        timer.Create( "SInput_ARC9_Rumble", self.RumbleDuration, 1, function()
            sinput.TriggerVibration(P1, 0, 0)
            sinput.SetLEDColor(P1, 255, 255, 255, true)
        end )
    end
end

local bulletPhysics = GetConVar("ARC9_bullet_physics")
local fireBullets = {}
local black = Color(0,0,0) -- if anything, let's just safe ourselves.

function SWEP:DoProjectileAttack(pos, ang, spread)
    if self:GetProcessedValue("ShootEnt") then
        self:ShootRocket()
    else
        local shouldtracer = self:ShouldTracer()

        local bullettbl = {}

        if !shouldtracer then
            bullettbl.Color = black
        end

        local tr = 0

        if shouldtracer then
            tr = 1
        end

        bullettbl.Size = self:GetProcessedValue("TracerSize")

        local ang2 = Angle(ang)

        if (bulletPhysics:GetBool() or self:GetProcessedValue("AlwaysPhysBullet")) and !self:GetProcessedValue("NeverPhysBullet") then
            if IsFirstTimePredicted() then
                for i = 1, self:GetProcessedValue("Num") do
                    ang2:Set(ang)

                    local angleRand = AngleRand()
                    angleRand:Div(3.6)
                    angleRand:Mul(spread)

                    ang2:Add(angleRand)

                    local vec = ang2:Forward()
                    vec:Mul(self:GetProcessedValue("PhysBulletMuzzleVelocity"))

                    ARC9:ShootPhysBullet(self, pos, vec, bullettbl)
                end
            end
        else
            local owner = self:GetOwner()

            if owner:IsPlayer() then
                owner:LagCompensation(true)
            end

            -- local tr = self:GetProcessedValue("TracerNum")

            local veh = NULL

            if owner:IsPlayer() then
                veh = owner:GetVehicle()
            end


            local distance = self:GetProcessedValue("Distance")

            fireBullets.Damage = self:GetProcessedValue("DamageMax")
            fireBullets.Force = self:GetProcessedValue("ImpactForce")
            fireBullets.Tracer = tr
            fireBullets.TracerName = self:GetProcessedValue("TracerEffect")
            fireBullets.Num = self:GetProcessedValue("Num")
            fireBullets.Dir = ang:Forward()
            fireBullets.Src = pos
            fireBullets.Spread = Vector(spread,spread,spread)
            fireBullets.IgnoreEntity = veh
            fireBullets.Distance = distance
            fireBullets.Callback = function(att, btr, dmg)
                local range = btr.Fraction*distance

                self.Penned = 0
                self:AfterShotFunction(btr, dmg, range, self:GetProcessedValue("Penetration"), {})

                if ARC9.Dev(2) then
                    if SERVER then
                        debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 0, 0), false)
                    else
                        debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 255, 255), false)
                    end
                end
            end

            owner:FireBullets(fireBullets)

            if owner:IsPlayer() then
                owner:LagCompensation(false)
            end
        end
    end
end

local runHook = {}
local bodyDamageCancel = GetConVar("arc9_mod_bodydamagecancel")

local soundTab = {
    name = "impact"
}

function SWEP:AfterShotFunction(tr, dmg, range, penleft, alreadypenned, secondary)
    if !IsFirstTimePredicted() and !game.SinglePlayer() then return end

    local lastsecondary = self:GetUBGL()

    self:SetUBGL(secondary)

    dmg:SetDamageType(self:GetProcessedValue("DamageType") or DMG_BULLET)

    local dmgv = self:GetDamageAtRange(range)

    runHook.tr = tr
    runHook.dmg = dmg
    runHook.range = range
    runHook.penleft = penleft
    runHook.alreadypenned = alreadypenned
    runHook.dmgv = dmgv

    self:RunHook("Hook_BulletImpact", runHook)

    local bodydamage = self:GetProcessedValue("BodyDamageMults")

    local dmgbodymult = 1

    local hitGroup = tr.HitGroup

    if bodydamage[hitGroup] then
        dmgbodymult = dmgbodymult * bodydamage[hitGroup]
    end

    if bodyDamageCancel:GetBool() and cancelmults[hitGroup] then
        dmgbodymult = dmgbodymult / cancelmults[hitGroup]
    end

    dmgv = dmgv * dmgbodymult

    if hitGroup == HITGROUP_HEAD then
        dmgv = dmgv * self:GetProcessedValue("HeadshotDamage")
    elseif hitGroup == HITGROUP_CHEST then
        dmgv = dmgv * self:GetProcessedValue("ChestDamage")
    elseif hitGroup == HITGROUP_STOMACH then
        dmgv = dmgv * self:GetProcessedValue("StomachDamage")
    elseif hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM then
        dmgv = dmgv * self:GetProcessedValue("ArmDamage")
    elseif hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG then
        dmgv = dmgv * self:GetProcessedValue("LegDamage")
    end

    local pendelta = penleft / self:GetProcessedValue("Penetration")

    pendelta = Lerp(pendelta, self:GetProcessedValue("PenetrationDelta"), 1) -- it arleady clamps inside

    dmgv = dmgv * pendelta

    local owner = self:GetOwner()

    if owner:IsNPC() and !GetConVar("ARC9_npc_equality"):GetBool() then
        dmgv = dmgv * 0.25
    end

    local ap = self:GetProcessedValue("ArmorPiercing")

    ap = math.min(ap, 1)

    local traceEntity = tr.Entity

    if traceEntity:GetClass() == "npc_helicopter" then
        local apdmg = DamageInfo()
        apdmg:SetDamage(dmgv * ap)
        apdmg:SetDamageType(DMG_AIRBOAT)
        apdmg:SetInflictor(dmg:GetInflictor())
        apdmg:SetAttacker(dmg:GetAttacker())

        traceEntity:TakeDamageInfo(apdmg)
    elseif traceEntity:GetClass() == "npc_gunship" then
        local apdmg = DamageInfo()
        apdmg:SetDamage(dmgv * ap)
        apdmg:SetDamageType(DMG_BLAST)
        apdmg:SetInflictor(dmg:GetInflictor())
        apdmg:SetAttacker(dmg:GetAttacker())

        traceEntity:TakeDamageInfo(apdmg)
    else
        local apdmg = dmgv * ap
        traceEntity:SetHealth(traceEntity:Health() - apdmg)
    end

    dmgv = dmgv * (1 - ap)

    dmg:SetDamage(dmgv)

    local hitPos = tr.HitPos
    local hitNormal = tr.HitNormal

    if self:GetProcessedValue("ImpactDecal") then
        util.Decal(self:GetProcessedValue("ImpactDecal"), tr.StartPos, hitPos - (hitNormal * 2), owner)
    end

    if self:GetProcessedValue("ImpactEffect") then
        local fx = EffectData()
        fx:SetOrigin(hitPos)
        fx:SetNormal(hitNormal)
        util.Effect(self:GetProcessedValue("ImpactEffect"), fx, true)
    end

    if self:GetProcessedValue("ImpactSound") then
        soundTab.sound = self:GetProcessedValue("ImpactSound")

        soundTab = self:RunHook("HookP_TranslateSound", soundtab) or soundtab

        sound.Play(soundtab.sound, hitPos, soundtab.level, soundtab.pitch, soundtab.volume)
    end

    if self:GetProcessedValue("ExplosionDamage") > 0 then
        util.BlastDamage(self, owner, hitPos, self:GetProcessedValue("ExplosionRadius"), self:GetProcessedValue("ExplosionDamage"))
    end

    if self:GetProcessedValue("ExplosionEffect") then
        local fx = EffectData()
        fx:SetOrigin(hitPos)
        fx:SetNormal(hitNormal)
        fx:SetAngles(tr.HitNormal:Angle())

        if bit.band(util.PointContents(hitPos), CONTENTS_WATER) == CONTENTS_WATER then
            util.Effect("WaterSurfaceExplosion", fx, true)
        else
            util.Effect(self:GetProcessedValue("ExplosionEffect"), fx, true)
        end
    end

    if traceEntity and alreadypenned[traceEntity] then
        dmg:SetDamage(0)
    elseif traceEntity then
        alreadypenned[traceEntity] = true
    end

    self:Penetrate(tr, range, penleft, alreadypenned)

    self:SetUBGL(lastsecondary)
end

function SWEP:ShouldTracer()
    local tracerNum = self:GetProcessedValue("TracerNum")

    if tracerNum <= 0 then return false end

    local shouldtracer = self:GetNthShot() % tracerNum == 0

    if self:Clip1() <= self:GetProcessedValue("TracerFinalMag") then
        shouldtracer = true
    end

    return shouldtracer
end

function SWEP:GetDamageDeltaAtRange(range)
    local d = 1

    local r_min = self:GetProcessedValue("RangeMin")
    local r_max = self:GetProcessedValue("RangeMax")

    if range <= r_min then
        d = 0
    elseif range >= r_max then
        d = 1
    else
        d = (range - r_min) / (r_max - r_min)
    end

    if self:GetProcessedValue("CurvedDamageScaling") then
        d = math.cos((d + 1) * math.pi) / 2 + 0.5
    end

    return d
end

local damageAtRangeHook = {}
local emptyTable = {}

function SWEP:GetDamageAtRange(range)
    local damagelut = self:GetProcessedValue("DamageLookupTable")

    local dmgMin = self:GetProcessedValue("DamageMin")

    local dmgv = dmgMin

    if damagelut then
        for _, tbl in ipairs(damagelut) do
            if range < tbl[1] then
                dmgv = tbl[2]
                break
            end
        end
    else
        local d = self:GetDamageDeltaAtRange(range)

        dmgv = Lerp(d, self:GetProcessedValue("DamageMax"), dmgMin)

        dmgv = self:GetProcessedValue("Damage", dmgv)

        if self:GetProcessedValue("DistributeDamage") then
            dmgv = dmgv / self:GetProcessedValue("Num")
        end
    end

    damageAtRangeHook.dmg = dmgv
    damageAtRangeHook.range = range
    damageAtRangeHook.d = d

    local data = self:RunHook("Hook_GetDamageAtRange", damageAtRangeHook) or emptyTable

    dmgv = data.dmg or dmgv

    return dmgv
end

function SWEP:GetShootPos()
    local owner = self:GetOwner()

    if owner:IsNPC() then
        return owner:GetShootPos()
    end

    local pos = owner:EyePos()

    local ang = self:GetShootDir()
    local angUp = ang:Up()
    
    angUp:Mul(self:GetProcessedValue("HeightOverBore"))
    pos:Add(angUp)

    --pos = pos + (owner:EyeAngles():Right() * self:GetLeanOffset())

    local rightVec = owner:EyeAngles():Right()
    rightVec:Mul(self:GetLeanOffset())

    pos:Add(rightVec)

    local shootposoffset = self:GetProcessedValue("ShootPosOffset")

    local angRight = ang:Right()
    local angForward = ang:Forward()
    local angUp = ang:Up()

    angRight:Mul(shootposoffset[1])
    angForward:Mul(shootposoffset[2])
    angUp:Mul(shootposoffset[3])

    pos:Add(angRight)
    pos:Add(angForward)
    pos:Add(angUp)

    pos, ang = self:GetRecoilOffset(pos, ang)

    return pos, ang
end

function SWEP:GetShootDir()
    local owner = self:GetOwner()
    if not owner:IsValid() then return self:GetAngles() end
    local dir = owner:EyeAngles()
    local shootangoffset = self:GetProcessedValue("ShootAngOffset")

    dir:RotateAroundAxis(dir:Right(), shootangoffset[1])
    dir:RotateAroundAxis(dir:Up(), shootangoffset[2])
    dir:RotateAroundAxis(dir:Forward(), shootangoffset[3])

    dir:Add(self:GetFreeAimOffset())
    dir:Add(self:GetFreeSwayAngles())

    return dir
end

function SWEP:ShootRocket()
    if CLIENT then return end

    local owner = self:GetOwner()

    local src = self:GetShootPos()
    local dir = self:GetShootDir()

    local num = self:GetProcessedValue("Num")
    local ent = self:GetProcessedValue("ShootEnt")

    local spread

    if owner:IsNPC() then
        spread = self:GetNPCBulletSpread()
    else
        spread = self:GetProcessedValue("Spread")
    end

    spread = math.max(spread, 0)

    for i = 1, num do
        local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)
        dispersion:Mul(spread*36)
        dispersion:Add(dir)

        local newAng = dispersion:Angle()

        local rocket = ents.Create(ent)
        if !IsValid(rocket) then return end


        rocket:SetPos(src)
        rocket:SetAngles(newAng)
        rocket:Spawn()
        rocket.Owner = owner
        rocket:SetOwner(owner)
        rocket.Weapon = self
        rocket.ShootEntData = self:RunHook("Hook_GetShootEntData", {
            Target = (IsValid(self:GetLockOnTarget()) and self:GetLockedOn() and self:GetLockOnTarget())
        })
        rocket.ARC9Projectile = true

        if self:GetProcessedValue("Detonator") then
            self:SetDetonatorEntity(rocket)
        end

        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            dispersion:Normalize()
            dispersion:Mul(self:GetProcessedValue("ShootEntForce"))

            phys:AddVelocity(dispersion)
            if self:GetProcessedValue("ShootEntInheritPlayerVelocity") then
                phys:AddVelocity(owner:GetVelocity())
            end
        end
    end
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
    return true
end