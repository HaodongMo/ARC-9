local arc9_dev_show_shield = GetConVar("arc9_dev_show_shield")

function SWEP:CreateShield()
    self:KillShield()

    local model = self:GetProcessedValue("ShieldModel", true)

    if !model then return end

    local shield = ents.Create("prop_physics")

    if !IsValid(shield) then return end

    self.ShieldProp = shield

    local bonename = self:GetProcessedValue("ShieldBone", true)
    local boneindex = self:GetOwner():LookupBone(bonename)
    local bpos, bang = self:GetOwner():GetBonePosition(boneindex)
    local pos = self:GetProcessedValue("ShieldOffset", true)
    local ang = self:GetProcessedValue("ShieldAngle", true)
    local newpos = Vector(pos)

    newpos.y = -newpos.y

    local apos = LocalToWorld(newpos, ang, bpos, bang)

    shield:SetModel(model)
    shield:FollowBone(self:GetOwner(), boneindex)
    shield:SetPos(apos)
    shield:SetAngles(self:GetOwner():GetAngles() + ang)
    shield:SetOwner(self:GetOwner())

    -- shield:SetCollisionGroup(COLLISION_GROUP_WORLD)
    -- shield:SetSolid(SOLID_NONE)
    -- shield:SetMoveType(MOVETYPE_NONE)
	
    shield:SetRenderMode(RENDERMODE_TRANSCOLOR)
    shield:SetMoveType( MOVETYPE_NOCLIP )
    shield:SetSolid( SOLID_NONE )
    shield:SetCollisionGroup( COLLISION_GROUP_WORLD ) 

    if arc9_dev_show_shield:GetBool() then
        shield:SetColor(Color(0, 0, 0, 255))
    else
        shield:SetNoDraw(true)
    end

    shield.ARC9IsShield = true
    shield.ARC9Weapon = self

    shield:Spawn()
    shield:SetModelScale(self:GetProcessedValue("ShieldScale", true) or 1, 0.1)
    shield:Activate()

    -- function shield:OnTakeDamage(damage)
        -- self:PlayAnimation("blowback")
    -- end
	
    -- Enhanced damage handling for various attack types, can't believe i had to ask an AI to write this....
    function shield:OnTakeDamage(dmginfo)
        local attacker = dmginfo:GetAttacker()
        local inflictor = dmginfo:GetInflictor()
        local damage = dmginfo:GetDamage()
        local damageType = dmginfo:GetDamageType()

        -- Block bullets, melee, and explosives
        if bit.band(damageType, bit.bor(DMG_BULLET, DMG_CLUB, DMG_SLASH, DMG_BLAST)) ~= 0 then
            -- Absorb damage and play animation
            dmginfo:SetDamage(0)
            self:PlayAnimation("blowback")

            -- Optional: Apply a force to simulate impact
            local forceDir = (self:GetPos() - dmginfo:GetDamagePosition()):GetNormalized()
            local force = forceDir * damage * 10
            self:GetPhysicsObject():ApplyForceCenter(force)

            -- Optional: Create impact effect or sound
            local effectData = EffectData()
            effectData:SetOrigin(dmginfo:GetDamagePosition())
            util.Effect("cball_bounce", effectData)
            self:EmitSound("physics/metal/metal_sheet_impact_bullet" .. math.random(1, 3) .. ".wav")
        end
    end

    self:SetShieldEntity(shield)
    self:GetOwner().ARC9ShieldEntity = shield
end

function SWEP:KillShield()
    SafeRemoveEntity(self.ShieldProp)
    SafeRemoveEntity(self:GetOwner().ARC9ShieldEntity)
end