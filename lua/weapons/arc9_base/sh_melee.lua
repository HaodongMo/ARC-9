local bodyDamageCancel = GetConVar("arc9_mod_bodydamagecancel")
local cancelmults = ARC9.CancelMultipliers[engine.ActiveGamemode()] or ARC9.CancelMultipliers[1]

local vmaxs, vmins = Vector(2, 2, 2), Vector(-2, -2, -2)

function SWEP:MeleeAttack(bypass, bash2)
    if !bypass then
		if !self:GetProcessedValue("BashCancelsReload", true) and self:StillWaiting() then return end
        if !self:GetProcessedValue("BashWhileSprint", true) and self:SprintLock() then return end
    end

	self:CancelReload()
	
    self:CallOnClient("CallNonTPIKAnim", "AnimMelee")

    local soundtab1 = {
        name = "meleeswing",
        sound = self:RandomChoice(self:GetProcessedValue("MeleeSwingSound", true)),
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
        endpos = owner:EyePos() + (owner:GetAimVector() * range),
        mask = MASK_SHOT,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs,
        mins = vmins
    })

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            self:SetLungeEntity(tr.Entity)

            local dot = owner:EyeAngles():Forward():Dot(tr.Entity:EyeAngles():Forward())

            backstab = dot > 0
        end
    end

    if backstab then
        prefix = "Backstab"
    end

	local bashspeed = self:GetProcessedValue("BashSpeed")

    self:SetFreeAimAngle(angle_zero)

    self:SetLastMeleeTime(CurTime())

    self:SetNextPrimaryFire(CurTime() + (self:GetProcessedValue("Pre" .. prefix .. "Time") / bashspeed) + (self:GetProcessedValue("Post" .. prefix .. "Time") / bashspeed))

	self.SetNextAiming = CurTime() + (self:GetProcessedValue("Pre" .. prefix .. "Time") / bashspeed) + (self:GetProcessedValue("Post" .. prefix .. "Time") / bashspeed)

    self:SetBash2(bash2)

    if backstab and self:HasAnimation("backstab") then
        self:PlayAnimation("backstab", 1 / bashspeed, false)
    elseif bash2 and self:HasAnimation("bash2") then
        self:PlayAnimation("bash2", 1 / bashspeed, false)
    elseif self:HasAnimation("bash") then
        self:PlayAnimation("bash", 1 / bashspeed, false)
    else
        if game.SinglePlayer() and SERVER then
            self:CallOnClient("MeleeAttack", "true")
        elseif CLIENT then
            self:PlayThirdArmAnim(self:GetProcessedValue("BashThirdArmAnimation", true), false)

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
        mask = MASK_SHOT + 8,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs2,
        mins = vmins2
    })

    self:RunHook("Hook_Bash", tr)

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            if backstab then
                local soundtab = {
                    name = "backstab",
                    sound = self:RandomChoice(self:GetProcessedValue("BackstabSound", true)),
                    channel = ARC9.CHAN_MELEE
                }

                self:PlayTranslatedSound(soundtab)
            else
                local soundtab = {
                    name = "meleehit",
                    sound = self:RandomChoice(self:GetProcessedValue("MeleeHitSound", true)),
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
                sound = self:RandomChoice(self:GetProcessedValue("MeleeHitWallSound", true)),
                channel = ARC9.CHAN_MELEE
            }

            self:PlayTranslatedSound(soundtab1)

            util.Decal(self:GetProcessedValue(prefix .. "Decal"), tr.HitPos + (tr.HitNormal * 8), tr.HitPos - (tr.HitNormal * 8), owner)

            if self:GetProcessedValue(prefix .. "Impact") and IsFirstTimePredicted() then
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
            self:PlayAnimation(bash2 and "impact2" or "impact", 1, false)
        end

        if SERVER then
            local dmg = DamageInfo()

            dmg:SetDamage(self:GetProcessedValue(prefix .. "Damage"))
            dmg:SetDamageForce(owner:GetAimVector() * 6000)
            dmg:SetDamagePosition(tr.HitPos)
            dmg:SetDamageType(self:GetProcessedValue(prefix .. "DamageType"))
            dmg:SetAttacker(owner)
            dmg:SetInflictor(self)

            local data = {tr = tr, dmg = dmg}
            self:RunHook("Hook_BashHit", data)

            -- do not need to worry about limb damage because hull traces only returns generic hitgroup
            tr.Entity:DispatchTraceAttack(dmg, tr) -- hits breakable glass surfaces, unlike TakeDamageInfo
        end
    end

    self:SetInMeleeAttack(false)
    self:SetLungeEntity(NULL)
end

function SWEP:ThinkMelee()
    local owner = self:GetOwner()

    local prebash = self:GetProcessedValue("PreBashTime") / self:GetProcessedValue("BashSpeed")

    if self:GetBash2() then
        prebash = self:GetProcessedValue("PreBash2Time")
    end

    if !self:GetGrenadePrimed() then

        if owner:KeyDown(IN_ATTACK) and self:GetProcessedValue("PrimaryBash", true) then
            self:MeleeAttack()
        end

        if owner:KeyDown(IN_ATTACK2) and self:GetProcessedValue("SecondaryBash", true) then
            self:MeleeAttack()
        end

        if owner:KeyDown(ARC9.IN_MELEE) and self:GetProcessedValue("Bash", true) and !self:GetInSights() and self:GetLastMeleeTime() + prebash + self:GetProcessedValue("PostBashTime") <= CurTime() then
            self:MeleeAttack()
        end

    end

    if self:GetInMeleeAttack() and self:GetLastMeleeTime() + prebash <= CurTime() then
        self:MeleeAttackShoot(self:GetBash2(), false)
    end
end