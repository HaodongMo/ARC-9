
local vmaxs, vmins = Vector(2, 2, 2), Vector(-2, -2, -2)

function SWEP:MeleeAttack(bypass)
    if !bypass then
        if self:StillWaiting() then return end
        if self:SprintLock() then return end
    end

    if self:HasAnimation("bash") then
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

    self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimMelee"))

    self:EmitSound(self:RandomChoice(self:GetProcessedValue("MeleeSwingSound")) or "", 75, 100, 1, CHAN_VOICE)

    local owner = self:GetOwner()

    local tr = util.TraceHull({
        start = owner:EyePos(),
        endpos = owner:EyePos() + (owner:EyeAngles():Forward() * self:GetProcessedValue("BashLungeRange")),
        mask = MASK_SHOT,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs,
        mins = vmins
    })

    if tr.Hit then
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
            self:SetLungeEntity(tr.Entity)
        end
    end

    self:SetFreeAimAngle(angle_zero)

    self:SetInMeleeAttack(true)

    self:SetLastMeleeTime(CurTime())
    self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("PreBashTime") + self:GetProcessedValue("PostBashTime"))
end

local vmaxs2, vmins2 = Vector(2, 2, 2), Vector(-2, -2, -2)

function SWEP:MeleeAttackShoot()
    local owner = self:GetOwner()

    local tr = util.TraceHull({
        start = owner:EyePos(),
        endpos = owner:EyePos() + (owner:EyeAngles():Forward() * self:GetProcessedValue("BashRange")),
        mask = MASK_SHOT,
        filter = {owner, self:GetShieldEntity(), self.ShieldProp},
        maxs = vmaxs2,
        mins = vmins2
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
                util.Effect("BloodImpact", fx, true)
            end
        else
            self:EmitSound(self:RandomChoice(self:GetProcessedValue("MeleeHitWallSound")) or "", 75, 100, 1, CHAN_VOICE)
            util.Decal(self:GetProcessedValue("BashDecal"), tr.HitPos + (tr.HitNormal * 8), tr.HitPos - (tr.HitNormal * 8), owner)

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

            dmg:SetDamage(self:GetProcessedValue("BashDamage"))
            dmg:SetDamageForce(owner:GetAimVector() * 32)
            dmg:SetDamageType(DMG_CLUB)
            dmg:SetAttacker(owner)
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