SWEP.NearWallTick = 0
SWEP.NearWallCached = false

function SWEP:GetIsNearWall()
    if self.NearWallTick == CurTime() then
        return self.NearWallCached
    end

    local tr = util.TraceLine({
        start = self:GetShootPos(),
        endpos = self:GetShootPos() + self:GetShootDir():Forward() * self:GetProcessedValue("BarrelLength"),
        filter = self:GetOwner(),
        mask = MASK_SHOT_HULL
    })

    self.NearWallCached = tr.Hit
    self.NearWallTick = CurTime()

    return tr.Hit
end

function SWEP:ThinkNearWall()
    local target = 0

    if self:GetIsNearWall() then
        target = 1
    end

    local amt = self:GetNearWallAmount()

    amt = math.Approach(amt, target, FrameTime() / self:GetProcessedValue("SprintToFireTime"))

    self:SetNearWallAmount(amt)
end