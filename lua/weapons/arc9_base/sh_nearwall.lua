SWEP.NearWallTick = 0
SWEP.NearWallCached = false

do
    local traceResults = {}

    local traceData = {
        start = true,
        endpos = true,
        filter = true,
        mask = MASK_SHOT_HULL,
        output = traceResults
    }

    local VECTOR = FindMetaTable("Vector")
    local vectorAdd = VECTOR.Add
    local vectorMul = VECTOR.Mul

    local angleForward = FindMetaTable("Angle").Forward
    local entityGetOwner = FindMetaTable("Entity").GetOwner 

    function SWEP:GetIsNearWall()
        local now = CurTime()

        if self.NearWallTick == now then
            return self.NearWallCached
        end

        local length = self:GetProcessedValue("BarrelLength")

        if length == 0 then return false end

        local startPos = self:GetShootPos()

        local shootDir = angleForward(self:GetShootDir())
        vectorMul(shootDir, length)

        local endPos = Vector(startPos)
        vectorAdd(endPos, shootDir)

        traceData.start = startPos
        traceData.endpos = endPos
        traceData.filter = entityGetOwner(self)

        util.TraceLine(traceData)
        local hit = traceResults.Hit

        self.NearWallCached = hit
        self.NearWallTick = now

        return hit
    end
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