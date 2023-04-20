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
        local now = engine.TickCount()

        if self.NearWallTick == now then
            return self.NearWallCached
        end

        local length = self:GetProcessedValue("BarrelLength", true)

        if length == 0 then return false end

        local startPos = self:GetShootPos()

        local endPos = angleForward(self:GetShootDir())
        vectorMul(endPos, length)
        vectorAdd(endPos, startPos)

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

local swepGetIsNearWall = SWEP.GetIsNearWall
local math_Approach = math.Approach
local FrameTime = FrameTime

function SWEP:ThinkNearWall()
    self:SetNearWallAmount(math_Approach(
        self.dt.NearWallAmount,
        swepGetIsNearWall(self) and 1 or 0,
        FrameTime() / self:GetProcessedValue("SprintToFireTime")))
end