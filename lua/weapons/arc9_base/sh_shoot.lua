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
    if self:GetHolster_Time() > 0 then return true end

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

    local ss = self:RandomChoice(self:GetProcessedValue("ShootSound")) or ""

    if self:GetProcessedValue("Silencer") then
        ss = self:RandomChoice(self:GetProcessedValue("ShootSoundSilenced")) or ss

        if self:GetBurstCount() == 0 then
            ss = self:RandomChoice(self:GetProcessedValue("FirstShootSoundSilenced")) or ss
        end
    else
        if self:GetBurstCount() == 0 then
            ss = self:RandomChoice(self:GetProcessedValue("FirstShootSound")) or ss
        end
    end

    self:EmitSound(ss or "", self:GetProcessedValue("ShootVolume"), self:GetProcessedValue("ShootPitch") + pvrand, 1, CHAN_WEAPON)

    local dss = self:RandomChoice(self:GetProcessedValue("DistantShootSound")) or ""

    if self:GetProcessedValue("Silencer") then
        dss = self:RandomChoice(self:GetProcessedValue("DistantShootSoundSilenced")) or dss

        if self:GetBurstCount() == 0 then
            dss = self:RandomChoice(self:GetProcessedValue("FirstDistantShootSoundSilenced")) or dss
        end
    else
        if self:GetBurstCount() == 0 then
            dss = self:RandomChoice(self:GetProcessedValue("FirstDistantShootSound")) or dss
        end
    end

    self:EmitSound(dss, math.min(149, self:GetProcessedValue("ShootVolume") * 2), self:GetProcessedValue("ShootPitch") + pvrand, 1, CHAN_WEAPON + 1)

    self:StartLoop()
end

function SWEP:PrimaryAttack()
    if self:GetOwner():IsNPC() then
        self:NPC_PrimaryAttack()
        return
    end

    if self:GetReloading() then
        self:SetEndReload(true)
    end

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

    if self:GetSafe() then
        self:ToggleSafety(false)
        self:SetNeedTriggerPress(true)
        return
    end

    if self:GetOwner():KeyDown(IN_USE) then
        self:MeleeAttack()
        return
    end

    if self:GetCurrentFiremode() > 0 and self:GetBurstCount() >= self:GetCurrentFiremode() then return end

    if self:Clip1() < self:GetProcessedValue("AmmoPerShot") then
        self:DryFire()
        return
    end

    if !self:GetProcessedValue("CanFireUnderwater") then
        if bit.band(util.PointContents(self:GetShootPos()), CONTENTS_WATER) == CONTENTS_WATER then
            self:DryFire()
            return
        end
    end

    self:SetBaseSettings()

    if self:SprintLock() then return end

    if self:RunHook("HookP_BlockFire") then return end

    if self:GetJammed() or self:GetHeatLockout() then
        self:DryFire()
        return
    end

    if IsFirstTimePredicted() then
        if self:GetProcessedValue("BottomlessClip") then
            if !self:GetProcessedValue("InfiniteAmmo") then
                self:RestoreClip(self:GetProcessedValue("ClipSize"))

                if self:Ammo1() > 0 then
                    local ammotype = self:GetProcessedValue("Ammo")
                    self:GetOwner():SetAmmo(self:GetOwner():GetAmmoCount(ammotype) - self:GetProcessedValue("AmmoPerShot"), ammotype)
                else
                    self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
                end
            end
        else
            self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
        end
    end

    local idle = true

    self:PlayAnimation("fire", 1, false, idle)

    self:DoVisualRecoil()

    local ejectdelay = self:GetProcessedValue("EjectDelay")

    if ejectdelay == 0 then
        self:DoEject()
    else
        self:SetTimer(ejectdelay, function()
            self:DoEject()
        end)
    end

    self:DoShootSounds()

    self:GetOwner():DoAnimationEvent(self:GetProcessedValue("AnimShoot"))

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

    local dir = self:GetShootDir()

    self:DoProjectileAttack(self:GetShootPos(), dir, spread)

    self:ApplyRecoil()

    self:SetBurstCount(self:GetBurstCount() + 1)

    if self:GetValue("ManualAction") then
        if self:Clip1() > 0 or !self:GetValue("ManualActionNoLastCycle") then
            if self:GetNthShot() % self:GetValue("ManualActionChamber") == 0 then
                self:SetNeedsCycle(true)
            end
        end
    end

    if self:GetCurrentFiremode() == 1 or self:Clip1() == 0 then
        self:SetNeedTriggerPress(true)
    end

    self:RollJam()
    self:DoHeat()
end

if CLIENT then
    local cl_rumble = GetConVar("arc9_rumble")
    function SWEP:SInputRumble()
        if !sinput then return false end
        if !cl_rumble:GetBool() then return false end
        if !sinput.enabled then sinput.Init() end

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
                    ang = ang + (spread * AngleRand() / 3.6)
                    ARC9:ShootPhysBullet(self, pos, ang:Forward() * self:GetProcessedValue("PhysBulletMuzzleVelocity"), bullettbl)
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
                    Callback = function(att, btr, dmg)
                        local range = (btr.HitPos - btr.StartPos):Length()

                        self:AfterShotFunction(btr, dmg, range, self:GetProcessedValue("Penetration"), {})

                        if GetConVar("developer"):GetBool() then
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

function SWEP:AfterShotFunction(tr, dmg, range, penleft, alreadypenned)
    if !IsFirstTimePredicted() and !game.SinglePlayer() then return end
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

    if GetConVar("ARC9_bodydamagecancel"):GetBool() and cancelmults[tr.HitGroup] then
    -- if cancelmults[tr.HitGroup] then
        dmgbodymult = dmgbodymult / cancelmults[tr.HitGroup]
    end

    dmgv = dmgv * dmgbodymult

    local pendelta = penleft / self:GetProcessedValue("Penetration")

    pendelta = math.Clamp(pendelta, 0.1, 1)

    dmgv = dmgv * pendelta

    if self:GetOwner():IsNPC() and !GetConVar("ARC9_npc_equality"):GetBool() then
        dmgv = dmgv * 0.25
    end

    local ap = self:GetProcessedValue("ArmorPiercing")

    ap = math.min(ap, 1)

    local apdmg = DamageInfo()
    apdmg:SetDamage(dmgv * ap)
    apdmg:SetDamageType(DMG_DIRECT)
    apdmg:SetInflictor(dmg:GetInflictor())
    apdmg:SetAttacker(dmg:GetAttacker())

    tr.Entity:TakeDamageInfo(apdmg)

    dmgv = dmgv * (1 - ap)

    dmg:SetDamage(dmgv)

    if self:GetProcessedValue("ImpactDecal") then
        util.Decal(self:GetProcessedValue("ImpactDecal"), tr.StartPos, tr.HitPos - (tr.HitNormal * 2), self:GetOwner())
    end

    if self:GetProcessedValue("ImpactEffect") then
        local fx = EffectData()
        fx:SetOrigin(tr.HitPos)
        fx:SetNormal(tr.HitNormal)
        util.Effect(self:GetProcessedValue("ImpactEffect"), fx)
    end

    if tr.Entity and alreadypenned[tr.Entity] then
        dmg:SetDamage(0)
    elseif tr.Entity then
        alreadypenned[tr.Entity] = true
    end

    self:Penetrate(tr, range, penleft, alreadypenned)
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

        pos = tr.HitPos
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

    local src = self:GetMuzzleOrigin()
    local dir = self:GetShootDir()

    local num = self:GetProcessedValue("Num")
    local ent = self:GetProcessedValue("ShootEnt")

    local spread

    if self:GetOwner():IsNPC() then
        -- ang = self:GetOwner():GetAimVector():Angle()
        spread = self:GetNPCSpread()
    else
        spread = self:GetSpread()
    end

    for i = 1, num do
        local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)

        dispersion = dispersion * spread * 36

        local rocket = ents.Create(ent)
        if !IsValid(rocket) then return end

        rocket:SetPos(src)
        rocket:SetOwner(self:GetOwner())
        rocket:SetAngles(dir + dispersion)
        rocket:Spawn()

        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            phys:ApplyForceCenter((dir + dispersion):Forward() * self:GetProcessedValue("ShootEntForce"))
        end
    end
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
    return true
end