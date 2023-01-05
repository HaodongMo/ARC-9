
local vmaxs, vmins = Vector(2, 2, 2), Vector(-2, -2, -2)

function SWEP:MeleeAttack(bypass, bash2)
    if !bypass then
        if self:StillWaiting() then return end
        if self:SprintLock() then return end
    end

    self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimMelee"))

    local soundtab1 = {
        name = "meleeswing",
        sound = self:RandomChoice(self:GetProcessedValue("MeleeSwingSound")),
        channel = ARC9.CHAN_MELEE
    }

    self:PlayTranslatedSound(soundtab1)

    local owner = self:GetOwner()
    local backstab = false

    local prefix = "Bash"

    if bash2 then
        prefix = "Bash2"
    end

    local range = self:GetProcessedValue(prefix .. "LungeRange")

    local tr = util.TraceHull({
        start = owner:EyePos(),
        endpos = owner:EyePos() + (owner:EyeAngles():Forward() * range),
        mask = MASK_SHOT,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs,
        mins = vmins
    })

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            self:SetLungeEntity(tr.Entity)

            local dot = self:GetOwner():EyeAngles():Forward():Dot(tr.Entity:EyeAngles():Forward())

            backstab = dot > 0
        end
    end

    if backstab then
        prefix = "Backstab"
    end

    self:SetFreeAimAngle(angle_zero)

    self:SetLastMeleeTime(CurTime())

    self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("Pre" .. prefix .. "Time") + self:GetProcessedValue("Post" .. prefix .. "Time"))

    self:SetBash2(bash2)

    if backstab and self:HasAnimation("backstab") then
        self:PlayAnimation("backstab", 1, false)
    elseif bash2 and self:HasAnimation("bash2") then
        self:PlayAnimation("bash2", 1, false)
    elseif self:HasAnimation("bash") then
        self:PlayAnimation("bash", 1, false)
    else
        if game.SinglePlayer() and SERVER then
            self:CallOnClient("MeleeAttack", "true")
        elseif CLIENT then
            self:PlayThirdArmAnim(self:GetProcessedValue("BashThirdArmAnimation"), false)

            if game.SinglePlayer() and CLIENT then
                return
            end
        end
    end

    if !backstab then
        self:SetInMeleeAttack(true)
    else
        self:MeleeAttackShoot(bash2, true)
    end
end

local vmaxs2, vmins2 = Vector(2, 2, 2), Vector(-2, -2, -2)

function SWEP:MeleeAttackShoot(bash2, backstab)
    local owner = self:GetOwner()

    local prefix = "Bash"

    if bash2 then
        prefix = "Bash2"
    end

    if backstab then
        prefix = "Backstab"
    end

    local tr = util.TraceHull({
        start = owner:EyePos(),
        endpos = owner:EyePos() + (owner:EyeAngles():Forward() * self:GetProcessedValue(prefix .. "Range")),
        mask = MASK_SHOT,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs2,
        mins = vmins2
    })

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            if backstab then
                local soundtab = {
                    name = "backstab",
                    sound = self:RandomChoice(self:GetProcessedValue("BackstabSound")),
                    channel = ARC9.CHAN_MELEE
                }

                self:PlayTranslatedSound(soundtab)
            else
                local soundtab = {
                    name = "meleehit",
                    sound = self:RandomChoice(self:GetProcessedValue("MeleeHitSound")),
                    channel = ARC9.CHAN_MELEE
                }

                self:PlayTranslatedSound(soundtab)
            end

            if IsFirstTimePredicted() then
                local fx = EffectData()
                fx:SetStart(tr.StartPos)
                fx:SetOrigin(tr.HitPos)
                fx:SetEntity(tr.Entity)
                fx:SetSurfaceProp(tr.SurfaceProps)
                fx:SetHitBox(tr.HitBox)
                util.Effect("BloodImpact", fx, true)
            end
        else
            local soundtab1 = {
                name = "meleehitwall",
                sound = self:RandomChoice(self:GetProcessedValue("MeleeHitWallSound")),
                channel = ARC9.CHAN_MELEE
            }

            self:PlayTranslatedSound(soundtab1)

            util.Decal(self:GetProcessedValue(prefix .. "Decal"), tr.HitPos + (tr.HitNormal * 8), tr.HitPos - (tr.HitNormal * 8), owner)

            if IsFirstTimePredicted() then
                local fx = EffectData()
                fx:SetStart(tr.StartPos)
                fx:SetOrigin(tr.HitPos)
                fx:SetEntity(tr.Entity)
                fx:SetSurfaceProp(tr.SurfaceProps)
                fx:SetHitBox(tr.HitBox)
                util.Effect("Impact", fx, true)
            end
        end

        if self:HasAnimation("impact") then
            self:PlayAnimation("impact", 1, false)
        end

        if SERVER then
            local dmg = DamageInfo()

            dmg:SetDamage(self:GetProcessedValue(prefix .. "Damage"))
            dmg:SetDamageForce(owner:GetAimVector() * 6000)
            dmg:SetDamagePosition(tr.HitPos)
            dmg:SetDamageType(self:GetProcessedValue(prefix .. "DamageType"))
            dmg:SetAttacker(owner)
            dmg:SetInflictor(self)

            tr.Entity:TakeDamageInfo(dmg)
        end
    end

    self:SetInMeleeAttack(false)
    self:SetLungeEntity(NULL)
end

function SWEP:ThinkMelee()
    if !self:GetGrenadePrimed() then

        if self:GetOwner():KeyDown(IN_ATTACK) and self:GetProcessedValue("PrimaryBash") then
            self:MeleeAttack()
        end

        if self:GetOwner():KeyDown(IN_ATTACK2) and self:GetProcessedValue("SecondaryBash") then
            self:MeleeAttack(false, true)
        end

    end

    local prebash = self:GetProcessedValue("PreBashTime")

    if self:GetBash2() then
        prebash = self:GetProcessedValue("PreBash2Time")
    end

    if self:GetInMeleeAttack() and self:GetLastMeleeTime() + prebash <= CurTime() then
        self:MeleeAttackShoot(self:GetBash2(), false)
    end
end