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

    local engineTickCount = engine.TickCount

    function SWEP:GetIsNearWall()
        local now = engineTickCount()

        if self.NearWallTick == now then return self.NearWallCached end

        if (self.NearWallLastCheck or 0) > now then return self.NearWallCached end
        self.NearWallLastCheck = now + 8 -- 8 ticks before next check

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
    local time = self:GetProcessedValue("SprintToFireTime", true) * 0.75 -- less time
    if math.abs(self:GetOwner():GetNW2Float("leaning_fraction", 0)) > 0.1 then time = 0.1 end -- leaning mod support

    self:SetNearWallAmount(math_Approach(
        self.dt.NearWallAmount,
        swepGetIsNearWall(self) and 1 or 0,
        FrameTime() / time))
end