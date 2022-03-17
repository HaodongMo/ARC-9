function SWEP:MeleeAttack()
    if self:StillWaiting() then return end
    if self:SprintLock() then return end

    self:PlayAnimation("bash", 1, true)

    self:EmitSound(self:RandomChoice(self:GetProcessedValue("MeleeSwingSound")) or "", 75, 100, 1, CHAN_VOICE)

    local tr = util.TraceHull({
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + (self:GetOwner():EyeAngles():Forward() * self:GetProcessedValue("BashLungeRange")),
        mask = MASK_SHOT,
        filter = self:GetOwner(),
        maxs = Vector(16, 16, 16),
        mins = Vector(-16, -16, -16)
    })

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            self:SetLungeEntity(tr.Entity)
        end
    end

    self:SetFreeAimAngle(Angle(0, 0, 0))

    self:SetInMeleeAttack(true)

    self:SetLastMeleeTime(CurTime())
    self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("PreBashTime") + self:GetProcessedValue("PostBashTime"))
end

function SWEP:MeleeAttackShoot()
    local tr = util.TraceHull({
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + (self:GetOwner():EyeAngles():Forward() * self:GetProcessedValue("BashRange")),
        mask = MASK_SHOT,
        filter = self:GetOwner(),
        maxs = Vector(2, 2, 2),
        mins = Vector(-2, -2, -2)
    })

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            self:EmitSound(self:RandomChoice(self:GetProcessedValue("MeleeHitSound")) or "", 75, 100, 1, CHAN_VOICE)

            if IsFirstTimePredicted() then
                local fx = EffectData()
                fx:SetStart(tr.StartPos)
                fx:SetOrigin(tr.HitPos)
                fx:SetEntity(tr.Entity)
                fx:SetSurfaceProp(tr.SurfaceProps)
                fx:SetHitBox(tr.HitBox)
                util.Effect("BloodImpact", fx)
            end
        else
            self:EmitSound(self:RandomChoice(self:GetProcessedValue("MeleeHitWallSound")) or "", 75, 100, 1, CHAN_VOICE)
            util.Decal(self:GetProcessedValue("BashDecal"), tr.HitPos + (tr.HitNormal * 8), tr.HitPos - (tr.HitNormal * 8), self:GetOwner())

            if IsFirstTimePredicted() then
                local fx = EffectData()
                fx:SetStart(tr.StartPos)
                fx:SetOrigin(tr.HitPos)
                fx:SetEntity(tr.Entity)
                fx:SetSurfaceProp(tr.SurfaceProps)
                fx:SetHitBox(tr.HitBox)
                util.Effect("Impact", fx)
            end
        end

        if SERVER then
            local dmg = DamageInfo()

            dmg:SetDamage(self:GetProcessedValue("BashDamage"))
            dmg:SetDamageForce(self:GetOwner():GetAimVector() * 32)
            dmg:SetDamageType(DMG_CLUB)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)

            tr.Entity:TakeDamageInfo(dmg)
        end
    end

    self:SetInMeleeAttack(false)
    self:SetLungeEntity(NULL)
end

function SWEP:ThinkMelee()
    if self:GetInMeleeAttack() and self:GetLastMeleeTime() + self:GetProcessedValue("PreBashTime") <= CurTime() then
        self:MeleeAttackShoot()
    end
end