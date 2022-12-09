function SWEP:RollJam()
    if !self:GetProcessedValue("Malfunction") then return end
    if self:Clip1() == 0 and self.MalfunctionNeverLastShoot then return end

    local chance = 1 / self:GetProcessedValue("MalfunctionMeanShotsToFail")

    if util.SharedRandom("arc9_jam", 0, 1000) / 1000 <= chance then
        if self:GetProcessedValue("MalfunctionJam") then
            self:SetJammed(true)
        end

        self:ExitSights()
        self:PlayAnimation("jam", 1, true)
        local soundtab1 = {
            name = "jam",
            sound = self:RandomChoice(self:GetProcessedValue("MalfunctionSound")),
            channel = CHAN_ITEM
        }
        self:PlayTranslatedSound(soundtab1)
        self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("MalfunctionWait"))
        self:SetNeedsCycle(false)

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

        self:SetJammed(true)

        self:SetNextPrimaryFire(CurTime() + self:GetProcessedValue("MalfunctionWait"))
    end
end

function SWEP:FixHeat()
    if self:StillWaiting() then return end

    self:ExitSights()
    self:PlayAnimation("fix", self:GetProcessedValue("OverheatTime"), true)
    self:SetJammed(false)

    if self:GetProcessedValue("HeatFix") then
        self:SetHeatAmount(0)
    end
end

function SWEP:ThinkHeat(dt)
    if self:PredictionFilter() then return end
    dt = dt or FrameTime()
    local heat = self:GetHeatAmount()

    if heat <= 0 then return end

    if !self:GetProcessedValue("Overheat") then return end

    if self:GetNextPrimaryFire() + self:GetProcessedValue("HeatDelayTime") < CurTime() then
        heat = heat - (dt * self:GetProcessedValue("HeatDissipation"))
        heat = math.Clamp(heat, 0, math.huge)

        if heat <= 0 and self:GetHeatLockout() then
            self:SetHeatLockout(false)
        end

        if self:GetJammed() then
            self:FixHeat()
        end

        self:SetHeatAmount(heat)
    end
end

function SWEP:UnJam()
    if self:StillWaiting() then return end
    self:SetJammed(false)
    self:PlayAnimation("fix", 1, true)
end