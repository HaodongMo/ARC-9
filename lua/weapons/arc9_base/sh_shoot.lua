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

    return false
end

function SWEP:SprintLock()
    if self:GetSprintAmount() > 0 then return true end
    if self:GetIsSprinting() then return true end

    return false
end

function SWEP:PrimaryAttack()
    if self:GetOwner():IsNPC() then
        return
    end

    if self:GetReloading() then
        self:SetEndReload(true)
    end

    if self:StillWaiting() then return end

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

    if self:GetCurrentFiremode() > 0 and self:GetBurstCount() >= self:GetCurrentFiremode() then return end

    if self:Clip1() < self:GetProcessedValue("AmmoPerShot") then
        self:PlayAnimation("dryfire")
        self:EmitSound(self:RandomChoice(self:GetProcessedValue("DryFireSound")), 75, 100, 1, CHAN_BODY)
        self:SetBurstCount(0)
        self:SetNeedTriggerPress(true)
        return
    end

    self:SetBaseSettings()

    if self:SprintLock() then return end

    if self:RunHook("HookP_BlockFire") then return end

    if IsFirstTimePredicted() then
        self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
    end

    local idle = true

    self:PlayAnimation("fire", 1, false, idle)

    local ejectdelay = self:GetProcessedValue("EjectDelay")

    if ejectdelay == 0 then
        self:DoEject()
    else
        self:SetTimer(ejectdelay, function()
            self:DoEject()
        end)
    end

    self:GetOwner():DoAnimationEvent(self:GetProcessedValue("AnimShoot"))

    local pvar = self:GetProcessedValue("ShootPitchVariation")
    local pvrand = util.SharedRandom("ARC9_sshoot", -pvar, pvar)

    self:EmitSound(self:RandomChoice(self:GetProcessedValue("ShootSound")) or "", self:GetProcessedValue("ShootVolume"), self:GetProcessedValue("ShootPitch") + pvrand, 1, CHAN_WEAPON)

    self:EmitSound(self:RandomChoice(self:GetProcessedValue("DistantShootSound")) or "", 149, self:GetProcessedValue("ShootPitch") + pvrand, 1, CHAN_WEAPON + 1)

    local delay = 60 / self:GetProcessedValue("RPM")

    local curatt = self:GetNextPrimaryFire()
    local diff = CurTime() - curatt

    if diff > engine.TickInterval() or diff < 0 then
        curatt = CurTime()
    end

    self:SetNextPrimaryFire(curatt + delay)

    self:SetNthShot(self:GetNthShot() + 1)

    self:DoEffects()

    local spread = self:GetProcessedValue("Spread")

    local dir = self:GetShootDir()

    if self:GetProcessedValue("ShootEnt") then
        self:ShootRocket()
    else
        if IsFirstTimePredicted() then
            if GetConVar("ARC9_bullet_physics"):GetBool() then
                for i = 1, self:GetProcessedValue("Num") do
                    dir = dir + (spread * AngleRand() / 3.6)
                    ARC9:ShootPhysBullet(self, self:GetOwner():GetShootPos(), dir:Forward() * self:GetProcessedValue("PhysBulletMuzzleVelocity"))
                end
            else
                self:GetOwner():LagCompensation(true)
                local tr = self:GetProcessedValue("TracerNum")

                self:GetOwner():FireBullets({
                    Damage = self:GetProcessedValue("Damage_Max"),
                    Force = 8,
                    Tracer = tr,
                    Num = self:GetProcessedValue("Num"),
                    Dir = dir:Forward(),
                    Src = self:GetOwner():GetShootPos(),
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

    self:ApplyRecoil()

    self:SetBurstCount(self:GetBurstCount() + 1)

    if self:GetCurrentFiremode() == 1 or self:Clip1() == 0 then
        self:SetNeedTriggerPress(true)
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
        alreadypenned = alreadypenned
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

    dmg:SetDamage(dmgv)

    if tr.Entity and alreadypenned[tr.Entity] then
        dmg:SetDamage(0)
    elseif tr.Entity then
        alreadypenned[tr.Entity] = true
    end

    self:Penetrate(tr, range, penleft, alreadypenned)
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

function SWEP:GetShootDir()
    local dir = self:GetOwner():EyeAngles()

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