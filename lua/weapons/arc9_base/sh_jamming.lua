function SWEP:RollJam()
    if !self:GetProcessedValue("Malfunction") then return end

    local chance = 1 / self:GetProcessedValue("MalfunctionMeanShotsToFail")

    if math.Rand(0, 1) <= chance then
        if self:GetProcessedValue("MalfunctionJam") then
            self:SetJammed(true)
        end

        self:PlayAnimation("jam", 1, true)
        self:EmitSound(self:GetProcessedValue("MalfunctionSound"), 75, 100, 1, CHAN_ITEM)
        self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("MalfunctionWait"))

        return true
    end
end

function SWEP:DoHeat()
    if !self:GetProcessedValue("Overheat") then return end

    self:SetHeatAmount(self:GetHeatAmount() + self:GetProcessedValue("HeatPerShot"))

    if self:GetHeatAmount() >= self:GetProcessedValue("HeatCapacity") then
        self:SetHeatAmount(self:GetProcessedValue("HeatCapacity"))
        if self:GetProcessedValue("HeatLockout") then
            self:SetHeatLockout(true)
        end
        self:PlayAnimation("fix", self:GetProcessedValue("OverheatTime"), true)
        if self:GetProcessedValue("HeatFix") then
            self:SetHeatAmount(0)
        end
    end
end

function SWEP:ThinkHeat()
    local heat = self:GetHeatAmount()

    if self:GetNextPrimaryFire() + self:GetProcessedValue("HeatDelayTime") < CurTime() then
        heat = heat - (FrameTime() * self:GetProcessedValue("HeatDissipation"))
        heat = math.Clamp(heat, 0, math.huge)

        if heat <= 0 and self:GetHeatLockout() then
            self:SetHeatLockout(false)
        end

        self:SetHeatAmount(heat)
    end
end

function SWEP:UnJam()
    if self:StillWaiting() then return end

    self:SetJammed(false)
    self:PlayAnimation("fix", 1, true)
end