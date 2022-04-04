function SWEP:GetSightDelta()
    return self:GetSightAmount()
end

function SWEP:EnterSights()
    if self:GetSprintAmount() > 0 then return end
    if !self:GetProcessedValue("HasSights") then return end
    if self:GetCustomize() then return end
    if !self:GetProcessedValue("ReloadInSights") and self:GetReloading() then return end
    if self:GetHolster_Time() > 0 then return end
    if self:GetProcessedValue("UBGLInsteadOfSights") then return end

    self:ToggleBlindFire(false)
    self:SetInSights(true)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("EnterSightsSound")), 100, 75)

    self:PlayAnimation("enter_sights", self:GetProcessedValue("AimDownSightsTime"))

    self:SetShouldHoldType()

    self:BuildMultiSight()
end

function SWEP:ExitSights()
    self:SetInSights(false)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("ExitSightsSound")), 100, 75)

    self:PlayAnimation("exit_sights", self:GetProcessedValue("AimDownSightsTime"))

    self:SetShouldHoldType()
end

function SWEP:ThinkSights()
    if self:GetSafe() then return end

    local sighted = self:GetInSights()

    local amt = self:GetSightAmount()

    if sighted then
        amt = math.Approach(amt, 1, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
    else
        amt = math.Approach(amt, 0, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
    end

    if CLIENT then
        self:GetVM():SetPoseParameter("sights", amt)
    end

    self:SetSightAmount(amt)

    if sighted and !self:GetOwner():KeyDown(IN_ATTACK2) then
        self:ExitSights()
    elseif !sighted and self:GetOwner():KeyDown(IN_ATTACK2) then
        if self:GetOwner():KeyDown(IN_USE) then
            return
        end

        self:EnterSights()
    end

    if sighted then
        if self:GetOwner():KeyPressed(IN_USE) and self:GetOwner():KeyDown(IN_WALK) and IsFirstTimePredicted() then
            -- if CurTime() - self:GetLastPressedETime() < 0.33 then
            if self:GetOwner():KeyDown(IN_SPEED) then
                self:SwitchMultiSight(-1)
            else
                self:SwitchMultiSight()
            end
            --     self:SetLastPressedETime(0)
            -- else
            --     self:SetLastPressedETime(CurTime())
            -- end
        end
    end
end

SWEP.MultiSightTable = {
    -- {
    --     Pos = Vector(0, 0, 0),
    --     Ang = Angle(0, 0, 0)
    -- }
}

function SWEP:BuildMultiSight()
    self.MultiSightTable = {}
    local modularironsights = {}

    local keepbaseirons = true
    local keepmodularirons = true

    for i, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end
        if slottbl.BlockSights then continue end
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.Sights then
            local isirons = false
            local kbi = false

            for _, sight in pairs(atttbl.Sights) do
                local s = {}

                if CLIENT then
                    s = self:GenerateAutoSight(sight, slottbl)
                end

                if sight.Disassociate then
                    s.Disassociate = true
                end

                s.atttbl = atttbl
                if sight.ExtraSightData then
                    s.atttbl = table.Copy(atttbl)
                    table.Merge(s.atttbl, sight.ExtraSightData)
                    s.ExtraSightData = sight.ExtraSightData
                end
                s.OriginalSightTable = sight
                s.slottbl = slottbl
                s.ViewModelFOV = sight.ViewModelFOV

                if sight.DeferSights then
                    if (slottbl.SubAttachments or {})[1] then
                        s.slottbl = slottbl.SubAttachments[1]
                    end
                end

                if sight.IsIronSight then
                    table.insert(modularironsights, s)
                    isirons = true
                else
                    table.insert(self.MultiSightTable, s)
                end

                if sight.KeepBaseIrons then
                    kbi = true
                end

                if self.ScrollLevels[#self.MultiSightTable] then
                    s.ScrollLevel = self.ScrollLevels[#self.MultiSightTable]
                end
            end

            if !kbi and !slottbl.KeepBaseIrons and !atttbl.KeepBaseIrons then
                keepbaseirons = false

                if !isirons then
                    keepmodularirons = false
                end
            end
        end
    end

    if keepbaseirons then
        local tbl = {}
        table.insert(tbl, self:GetProcessedValue("IronSights"))
        tbl[1].BaseSight = true
        table.Add(tbl, self.MultiSightTable)
        self.MultiSightTable = tbl
    end

    if keepmodularirons then
        table.Add(self.MultiSightTable, modularironsights)
    end

    if self:GetMultiSight() > #self.MultiSightTable then
        self:SetMultiSight(1)
    end
end

function SWEP:SwitchMultiSight(amt)
    if game.SinglePlayer() then
        self:CallOnClient("InvalidateCache")
    end

    amt = amt or 1
    local old_msi = self:GetMultiSight()
    msi = old_msi
    msi = msi + amt

    if msi > #self.MultiSightTable then
        msi = 1
    elseif msi <= 0 then
        msi = #self.MultiSightTable
    end

    self:SetMultiSight(msi)

    self:InvalidateCache()

    if msi != old_msi then
        // eh put some code in here
    end
end

function SWEP:GetSight()
    if GetConVar("developer"):GetBool() then
        self:BuildMultiSight()
    end
    return self.MultiSightTable[self:GetMultiSight()] or self:GetValue("IronSights")
end

function SWEP:GetRTScopeFOV()
    local sights = self:GetSight()

    if !sights then return self:GetOwner():GetFOV() end

    local atttbl

    if sights.BaseSight then
        atttbl = self:GetTable()
    else
        atttbl = self:GetFinalAttTable(sights.slottbl)
    end

    local scrolllevel = sights.ScrollLevel or 0

    if atttbl.RTScopeAdjustable then
        return Lerp(scrolllevel / atttbl.RTScopeAdjustmentLevels, atttbl.RTScopeFOVMax, atttbl.RTScopeFOVMin)
    else
        return atttbl.RTScopeFOV
    end
end

SWEP.ScrollLevels = {}

function SWEP:Scroll(amt)
    local sights = self:GetSight() or {}

    local atttbl = sights.atttbl

    if !atttbl then return end
    if !atttbl.RTScopeAdjustable then return end
    if !atttbl.RTScopeFOVMax then return end
    if !atttbl.RTScopeFOVMin then return end

    local scrolllevel = sights.ScrollLevel or 0
    local old = scrolllevel

    sights.ScrollLevel = scrolllevel + amt

    sights.ScrollLevel = math.Clamp(sights.ScrollLevel, 0, atttbl.RTScopeAdjustmentLevels)

    self.ScrollLevels[self:GetMultiSight()] = sights.ScrollLevel

    if old != sights.ScrollLevel then
        self:EmitSound(atttbl.ZoomSound or "arc9/useatt.wav", 75, math.Rand(95, 105), 1, CHAN_ITEM)
    end
end