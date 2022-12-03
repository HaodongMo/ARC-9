function SWEP:CreateShield()
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

    shield:SetRenderMode(RENDERMODE_TRANSALPHA)

    // shield:SetNoDraw(true)

    shield:SetColor(Color(0, 0, 0, 0))

    shield:Spawn()
    shield:SetModelScale(self:GetProcessedValue("ShieldScale") or 1, 0.1)
    shield:Activate()
end

function SWEP:KillShield()
    SafeRemoveEntity(self.ShieldProp)
end