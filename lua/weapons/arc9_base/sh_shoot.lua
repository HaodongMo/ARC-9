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
    if self:GetNextPrimaryFire() > CurTime() then return true end
    if self:GetNextSecondaryFire() > CurTime() then return true end
    if self:GetAnimLockTime() > CurTime() then return true end
    if self:GetPrimedAttack() then return true end
    if self:GetHolsterTime() > 0 then return true end

    return false
end

function SWEP:SprintLock()
    if self:GetSprintAmount() > 0 then return true end
    -- if self:GetTraversalSprintAmount() > 0 then return true end
    -- if self:GetIsSprinting() then return true end

    return false
end

function SWEP:DryFire()
    self:PlayAnimation("dryfire")
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("DryFireSound")), 75, 100, 1, CHAN_BODY)
    self:SetBurstCount(0)
    self:SetNeedTriggerPress(true)
end

function SWEP:DoShootSounds()
    local pvar = self:GetProcessedValue("ShootPitchVariation")
    local pvrand = util.SharedRandom("ARC9_sshoot", -pvar, pvar)

    local sstr = "ShootSound"
    local sslr = "LayerSound"
    local dsstr = "DistantShootSound"

    local silenced = self:GetProcessedValue("Silencer") and !self:GetUBGL()
    local indoor = self:GetIndoor()
    local indoormix = math.max(0, 1 - (indoor or 0))
    
    local havedistant = self:GetProcessedValue(dsstr)

    if silenced and self:GetProcessedValue(sstr .. "Silenced") then sstr = sstr .. "Silenced" end
    if silenced and self:GetProcessedValue(sslr .. "Silenced") then sslr = sslr .. "Silenced" end
    if havedistant and silenced and self:GetProcessedValue(dsstr .. "Silenced") then dsstr = dsstr .. "Silenced" end

    if self:GetBurstCount() == 0 and self:GetProcessedValue("First" .. sstr) then sstr = "First" .. sstr end
    if havedistant and self:GetBurstCount() == 0 and self:GetProcessedValue("First" .. dsstr) then dsstr = "First" .. dsstr end

    local ss = self:GetProcessedValue(sstr)
    ss = self:RandomChoice(ss)
    local sl = self:GetProcessedValue(sslr)
    sl = self:RandomChoice(sl)
    if havedistant then
        local dss = self:GetProcessedValue(dsstr)
        dss = self:RandomChoice(dss)
    end

    local svolume, spitch, svolumeactual = self:GetProcessedValue("ShootVolume"), self:GetProcessedValue("ShootPitch") + pvrand, (self:GetProcessedValue("ShootVolumeActual") or 1)
    local dvolume, dpitch, dvolumeactual
    if havedistant then dvolume, dpitch, dvolumeactual = math.min(149, (self:GetProcessedValue("DistantShootVolume") or svolume) * 2), (self:GetProcessedValue("DistantShootPitch") or spitch) + pvrand, self:GetProcessedValue("DistantShootVolumeActual") or svolumeactual or 1 end

    if indoormix > 0 then
        self:EmitSound(ss or "", svolume, spitch, svolumeactual * indoormix, CHAN_WEAPON)
        self:EmitSound(sl or "", svolume, spitch, svolumeactual * indoormix, CHAN_WEAPON + 4)
        if havedistant then self:EmitSound(dss or "", dvolume, dpitch, dvolume * indoormix, CHAN_WEAPON + 1) end
    end

    if indoor then
        local ssIN = self:GetProcessedValue(sstr .. "Indoor")
        ssIN = self:RandomChoice(ssIN)
        local slIN = self:GetProcessedValue(sslr .. "Indoor")
        slIN = self:RandomChoice(slIN)
        if havedistant then local dssIN = self:GetProcessedValue(dsstr .. "Indoor")
        dssIN = self:RandomChoice(dssIN) end

        self:EmitSound(ssIN or "", svolume, spitch, svolumeactual * indoor, CHAN_WEAPON + 5)
        self:EmitSound(slIN or "", svolume, spitch, svolumeactual * indoor, CHAN_WEAPON + 6)
        if havedistant then self:EmitSound(dssIN or "", dvolume, dpitch, dvolume * indoor, CHAN_WEAPON + 7) end
    end

    self:StartLoop()
end

function SWEP:PrimaryAttack()
    if self.NotAWeapon then return end

    if self:GetProcessedValue("PrimaryBash") then
        self:MeleeAttack()
        self:SetNeedTriggerPress(true)
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

    self:DoPrimaryAttack()
end

function SWEP:DoPrimaryAttack()
    if self:GetOwner():IsNPC() then
        self:NPC_PrimaryAttack()
        return
    end

    if self:GetReloading() then
        self:SetEndReload(true)
    end

    if self:SprintLock() then return end

    if self:StillWaiting() then return end
    if self:GetNeedsCycle() then return end

    if self:GetCustomize() then return end

    -- if self:GetProcessedValue("CanQuickNade") then
    --     if self:GetOwner():KeyDown(IN_USE) then
    --         self:PrimeGrenade()
    --         self:SetBurstCount(0)
    --         return
    --     end
    -- end

    -- if self:GetProcessedValue("Melee") then
    --     if self:GetOwner():KeyDown(IN_USE) then
    --         self:Melee()
    --         return
    --     end
    -- end

    if self:GetNeedTriggerPress() then return end

    if self:GetProcessedValue("Bash") and self:GetOwner():KeyDown(IN_USE) and !self:GetInSights() then
        self:MeleeAttack()
        self:SetNeedTriggerPress(true)
        return
    end

    if self:GetCurrentFiremode() > 0 and self:GetBurstCount() >= self:GetCurrentFiremode() then return end

    local clip = self:Clip1()

    if self:GetProcessedValue("BottomlessClip") then
        clip = self:Ammo1()
        self:RestoreClip(math.huge)
    end

    if self:GetUBGL() then
        clip = self:Clip2()

        if self:GetProcessedValue("BottomlessClip") then
            clip = self:Ammo2()
            self:RestoreClip(math.huge)
        end
    end

    if clip < self:GetProcessedValue("AmmoPerShot") then
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

    if self:GetProcessedValue("TriggerDelay") then
        if self:GetTriggerDelay() != 1 then
            return
        elseif self:GetProcessedValue("TriggerDelayRepeat") then
            self:SetTriggerDelay(0)
        end
    end

    self:SetBaseSettings()

    if self:RunHook("HookP_BlockFire") then return end

    if self:GetJammed() or self:GetHeatLockout() then
        self:DryFire()
        return
    end

    if IsFirstTimePredicted() then
        if self:GetUBGL() then
            self:TakeSecondaryAmmo(self:GetProcessedValue("AmmoPerShot"))
        else
            if self:GetValue("BottomlessClip") then
                if !self:GetInfiniteAmmo() then
                    self:RestoreClip(self:GetValue("ClipSize"))

                    if self:Ammo1() > 0 then
                        local ammotype = self:GetValue("Ammo")
                        self:GetOwner():SetAmmo(self:GetOwner():GetAmmoCount(ammotype) - self:GetValue("AmmoPerShot"), ammotype)
                    else
                        self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
                    end
                end
            else
                self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
            end
        end
    end

    if self:GetProcessedValue("DoFireAnimation") then
        local anim = "fire"

        if self:GetProcessedValue("Akimbo") then
            if bit.band(self:GetNthShot(), 1) == 0 then
                anim = "fire_left"
            else
                anim = "fire_right"
            end
        end

        local banim = anim

        for i = 0, self:GetBurstCount() do
            local b = i + 1

            if self:HasAnimation(anim .. "_" .. tostring(b)) then
                banim = anim .. "_" .. tostring(b)
            end
        end

        self:PlayAnimation(banim, 1, false)
    end

    self:SetLoadedRounds(self:Clip1())

    self:DoVisualRecoil()

    if !self:GetProcessedValue("NoShellEject") and !(self:GetProcessedValue("ManualAction") and !self:GetProcessedValue("ManualActionEjectAnyway")) then
        local ejectdelay = self:GetProcessedValue("EjectDelay")

        if ejectdelay == 0 then
            self:DoEject()
        else
            self:SetTimer(ejectdelay, function()
                self:DoEject()
            end)
        end
    end

    self:DoShootSounds()

    self:RunHook("Hook_PrimaryAttack")

    self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimShoot"))

    local delay = 60 / self:GetProcessedValue("RPM")

    local curatt = self:GetNextPrimaryFire()
    local diff = CurTime() - curatt

    if diff > engine.TickInterval() or diff < 0 then
        curatt = CurTime()
    end

    self:SetNextPrimaryFire(curatt + delay)

    self:DoEffects()

    if game.SinglePlayer() and SERVER then
        self:CallOnClient("SInputRumble")
    elseif !game.SinglePlayer() and CLIENT then
        self:SInputRumble()
    end

    local spread = self:GetProcessedValue("Spread")

    spread = math.Max(spread, 0)

    local dir = self:GetShootDir()

    self:DoProjectileAttack(self:GetShootPos(), dir, spread)

    -- if IsFirstTimePredicted() then
        self:ApplyRecoil()
    -- end

    self:SetBurstCount(self:GetBurstCount() + 1)

    if self:GetProcessedValue("ManualAction") then
        if self:Clip1() > 0 or !self:GetProcessedValue("ManualActionNoLastCycle") then
            if self:GetNthShot() % self:GetProcessedValue("ManualActionChamber") == 0 then
                self:SetNeedsCycle(true)
            end
        end
    end

    if self:GetCurrentFiremode() == 1 or clip == 0 then
        self:SetNeedTriggerPress(true)
    end

    if IsFirstTimePredicted() then
        self:RollJam()
        self:DoHeat()
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

function SWEP:DoProjectileAttack(pos, ang, spread)
    if self:GetProcessedValue("ShootEnt") then
        self:ShootRocket()
    else
        local shouldtracer = self:ShouldTracer()

        local bullettbl = {}

        if !shouldtracer then
            bullettbl.Color = Color(0, 0, 0)
        end

        local tr = 0

        if shouldtracer then
            tr = 1
        end

        bullettbl.Size = self:GetProcessedValue("TracerSize")

        self:SetNthShot(self:GetNthShot() + 1)

        if IsFirstTimePredicted() then
            if (GetConVar("ARC9_bullet_physics"):GetBool() or self:GetProcessedValue("AlwaysPhysBullet")) and !self:GetProcessedValue("NeverPhysBullet") then
                for i = 1, self:GetProcessedValue("Num") do
                    local newang = ang + (spread * AngleRand() / 3.6)
                    ARC9:ShootPhysBullet(self, pos, newang:Forward() * self:GetProcessedValue("PhysBulletMuzzleVelocity"), bullettbl)
                end
            else
                self:GetOwner():LagCompensation(true)
                -- local tr = self:GetProcessedValue("TracerNum")

                self:GetOwner():FireBullets({
                    Damage = self:GetProcessedValue("Damage_Max"),
                    Force = 8,
                    Tracer = tr,
                    TracerName = self:GetProcessedValue("TracerEffect"),
                    Num = self:GetProcessedValue("Num"),
                    Dir = ang:Forward(),
                    Src = pos,
                    Spread = Vector(spread, spread, spread),
                    IgnoreEntity = self:GetOwner():GetVehicle(),
                    Distance = self:GetProcessedValue("Distance"),
                    Callback = function(att, btr, dmg)
                        local range = (btr.HitPos - btr.StartPos):Length()

                        self:AfterShotFunction(btr, dmg, range, self:GetProcessedValue("Penetration"), {})

                        if ARC9.Dev(2) then
                            if SERVER then
                                debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 0, 0), false)
                            else
                                debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 255, 255), false)
                            end
                        end
                    end
                })

                self:GetOwner():LagCompensation(false)
            end
        end
    end
end

function SWEP:AfterShotFunction(tr, dmg, range, penleft, alreadypenned, secondary)
    if !IsFirstTimePredicted() and !game.SinglePlayer() then return end

    local lastsecondary = self:GetUBGL()

    self:SetUBGL(secondary)

    dmg:SetDamageType(self:GetProcessedValue("DamageType") or DMG_BULLET)

    local dmgv = self:GetDamageAtRange(range)

    self:RunHook("Hook_BulletImpact", {
        tr = tr,
        dmg = dmg,
        range = range,
        penleft = penleft,
        alreadypenned = alreadypenned,
        dmgv = dmgv
    })

    local bodydamage = self:GetProcessedValue("BodyDamageMults")

    local dmgbodymult = 1

    if bodydamage[tr.HitGroup] then
        dmgbodymult = dmgbodymult * bodydamage[tr.HitGroup]
    end

    if GetConVar("arc9_mod_bodydamagecancel"):GetBool() and cancelmults[tr.HitGroup] then
    -- if cancelmults[tr.HitGroup] then
        dmgbodymult = dmgbodymult / cancelmults[tr.HitGroup]
    end

    dmgv = dmgv * dmgbodymult

    if tr.HitGroup == HITGROUP_HEAD then
        dmgv = dmgv * self:GetProcessedValue("HeadshotDamage")
    elseif tr.HitGroup == HITGROUP_CHEST then
        dmgv = dmgv * self:GetProcessedValue("ChestDamage")
    elseif tr.HitGroup == HITGROUP_STOMACH then
        dmgv = dmgv * self:GetProcessedValue("StomachDamage")
    elseif tr.HitGroup == HITGROUP_LEFTARM or tr.HitGroup == HITGROUP_RIGHTARM then
        dmgv = dmgv * self:GetProcessedValue("ArmDamage")
    elseif tr.HitGroup == HITGROUP_LEFTLEG or tr.HitGroup == HITGROUP_RIGHTLEG then
        dmgv = dmgv * self:GetProcessedValue("LegDamage")
    end

    local pendelta = penleft / self:GetProcessedValue("Penetration")

    pendelta = math.Clamp(pendelta, 0.1, 1)

    dmgv = dmgv * pendelta

    if self:GetOwner():IsNPC() and !GetConVar("ARC9_npc_equality"):GetBool() then
        dmgv = dmgv * 0.25
    end

    local ap = self:GetProcessedValue("ArmorPiercing")

    ap = math.min(ap, 1)

    if tr.Entity:GetClass() == "npc_helicopter" then
        local apdmg = DamageInfo()
        apdmg:SetDamage(dmgv * ap)
        apdmg:SetDamageType(DMG_AIRBOAT)
        apdmg:SetInflictor(dmg:GetInflictor())
        apdmg:SetAttacker(dmg:GetAttacker())

        tr.Entity:TakeDamageInfo(apdmg)
    elseif tr.Entity:GetClass() == "npc_gunship" then
        local apdmg = DamageInfo()
        apdmg:SetDamage(dmgv * ap)
        apdmg:SetDamageType(DMG_BLAST)
        apdmg:SetInflictor(dmg:GetInflictor())
        apdmg:SetAttacker(dmg:GetAttacker())

        tr.Entity:TakeDamageInfo(apdmg)
    else
        local apdmg = dmgv * ap
        tr.Entity:SetHealth(tr.Entity:Health() - apdmg)
    end

    dmgv = dmgv * (1 - ap)

    dmg:SetDamage(dmgv)

    if self:GetProcessedValue("ImpactDecal") then
        util.Decal(self:GetProcessedValue("ImpactDecal"), tr.StartPos, tr.HitPos - (tr.HitNormal * 2), self:GetOwner())
    end

    if self:GetProcessedValue("ImpactEffect") then
        local fx = EffectData()
        fx:SetOrigin(tr.HitPos)
        fx:SetNormal(tr.HitNormal)
        util.Effect(self:GetProcessedValue("ImpactEffect"), fx, true)
    end

    if self:GetProcessedValue("ExplosionDamage") > 0 then
        util.BlastDamage(self, self:GetOwner(), tr.HitPos, self:GetProcessedValue("ExplosionRadius"), self:GetProcessedValue("ExplosionDamage"))
    end

    if self:GetProcessedValue("ExplosionEffect") then
        local fx = EffectData()
        fx:SetOrigin(tr.HitPos)
        fx:SetNormal(tr.HitNormal)

        if bit.band(util.PointContents(tr.HitPos), CONTENTS_WATER) == CONTENTS_WATER then
            util.Effect("WaterSurfaceExplosion", fx, true)
        else
            util.Effect(self:GetProcessedValue("ExplosionEffect"), fx, true)
        end
    end

    if tr.Entity and alreadypenned[tr.Entity] then
        dmg:SetDamage(0)
    elseif tr.Entity then
        alreadypenned[tr.Entity] = true
    end

    self:Penetrate(tr, range, penleft, alreadypenned)

    self:SetUBGL(lastsecondary)
end

function SWEP:ShouldTracer()
    if self:GetProcessedValue("TracerNum") <= 0 then return false end

    local shouldtracer = self:GetNthShot() % self:GetProcessedValue("TracerNum") == 0

    if self:Clip1() <= self:GetProcessedValue("TracerFinalMag") then
        shouldtracer = true
    end

    return shouldtracer
end

function SWEP:GetDamageAtRange(range)
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

    local dmgv = Lerp(d, self:GetProcessedValue("DamageMax"), self:GetProcessedValue("DamageMin"))

    dmgv = self:GetProcessedValue("Damage", dmgv)

    dmgv = math.ceil(dmgv)

    return dmgv
end

function SWEP:GetShootPos()
    if self:GetOwner():IsNPC() then
        return self:GetOwner():GetShootPos()
    end

    local pos = self:GetOwner():EyePos()

    if self:GetBlindFire() then
        pos = self:GetOwner():EyePos()
        local eyeang = self:GetOwner():EyeAngles()

        local testpos = pos + eyeang:Up() * 24

        if self:GetBlindFireDirection() != 0 then
            testpos = pos + eyeang:Forward() * 24
        end

        local tr = util.TraceLine({
            start = pos,
            endpos = testpos,
            filter = self:GetOwner()
        })

        pos = tr.HitPos + (tr.HitNormal * 2)
    end

    local ang = self:GetShootDir()

    pos = pos + (ang:Up() * -self:GetProcessedValue("HeightOverBore"))

    return pos
end

function SWEP:GetShootDir()
    if !self:GetOwner():IsValid() then return self:GetAngles() end
    local dir = self:GetOwner():EyeAngles()

    if self:GetBlindFireDirection() < 0 then
        dir:RotateAroundAxis(dir:Up(), 90)
    elseif self:GetBlindFireDirection() > 0 then
        dir:RotateAroundAxis(dir:Up(), -90)
    end

    dir = dir + self:GetFreeAimOffset()

    dir = dir + self:GetFreeSwayAngles()

    return dir
end

function SWEP:ShootRocket()
    if CLIENT then return end

    local src = self:GetShootPos()
    local dir = self:GetShootDir()

    local num = self:GetProcessedValue("Num")
    local ent = self:GetProcessedValue("ShootEnt")

    local spread

    if self:GetOwner():IsNPC() then
        -- ang = self:GetOwner():GetAimVector():Angle()
        spread = self:GetNPCBulletSpread()
    else
        spread = self:GetProcessedValue("Spread")
    end

    spread = math.Max(spread, 0)

    for i = 1, num do
        local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)

        dispersion = dispersion * spread * 36

        local rocket = ents.Create(ent)
        if !IsValid(rocket) then return end

        rocket:SetPos(src)
        rocket:SetAngles(dir + dispersion)
        rocket:Spawn()
        rocket.Owner = self:GetOwner()
        rocket:SetOwner(self:GetOwner())
        rocket.Weapon = self
        rocket.ShootEntData = self:RunHook("Hook_GetShootEntData", {})
        rocket.ARC9Projectile = true

        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            phys:ApplyForceCenter((dir + dispersion):Forward() * self:GetProcessedValue("ShootEntForce"))
        end
    end
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
    return true
end