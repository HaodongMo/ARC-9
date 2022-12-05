function SWEP:CreateShield()
    self:KillShield()

    local model = self:GetProcessedValue("ShieldModel")

    if !model then return end

    local shield = ents.Create("prop_physics")

    if !IsValid(shield) then return end

    self.ShieldProp = shield

    local bonename = self:GetProcessedValue("ShieldBone")

    local boneindex = self:GetOwner():LookupBone(bonename)

    local bpos, bang = self:GetOwner():GetBonePosition(boneindex)

    local pos = self:GetProcessedValue("ShieldOffset")
    local ang = self:GetProcessedValue("ShieldAngle")

    local newpos = Vector(pos)

    newpos.y = -newpos.y

    local apos = LocalToWorld(newpos, ang, bpos, bang)

    shield:SetModel(model)
    shield:FollowBone(self:GetOwner(), boneindex)
    shield:SetPos(apos)
    shield:SetAngles(self:GetOwner():GetAngles() + ang)

    shield:SetOwner(self:GetOwner())

    shield:SetCollisionGroup(COLLISION_GROUP_WORLD)
    shield:SetSolid(SOLID_NONE)
    shield:SetMoveType(MOVETYPE_NONE)

    if GetConVar("arc9_dev_show_shield"):GetBool() then
        shield:SetColor(Color(0, 0, 0, 255))
    else
        shield:SetNoDraw(true)
    end

    shield.ARC9IsShield = true

    shield:Spawn()
    shield:SetModelScale(self:GetProcessedValue("ShieldScale") or 1, 0.1)
    shield:Activate()

    function shield:OnTakeDamage(damage)
        print(damage)
    end

    self:SetShieldEntity(shield)
    self:GetOwner().ARC9ShieldEntity = shield
end

function SWEP:KillShield()
    SafeRemoveEntity(self.ShieldProp)
    SafeRemoveEntity(self:GetOwner().ARC9ShieldEntity)
end