function SWEP:GetSightDelta()
    return self:GetSightAmount()
end

function SWEP:EnterSights()
    if self:GetSprintAmount() > 0 then return end
    if !self:GetProcessedValue("HasSights") then return end

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

SWEP.LastPressedETime = 0

function SWEP:ThinkSights()
    if self:GetSafe() then return end

    local sighted = self:GetInSights()

    local amt = self:GetSightAmount()

    if sighted then
        amt = math.Approach(amt, 1, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
    else
        amt = math.Approach(amt, 0, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))
    end

    self:GetVM():SetPoseParameter("sights", amt)

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
        if self:GetOwner():KeyPressed(IN_USE) then
            if CurTime() - self:GetLastPressedETime() < 0.33 then
                self:SwitchMultiSight()
                self:SetLastPressedETime(0)
            else
                self:SetLastPressedETime(CurTime())
            end
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

    local keepbaseirons = true

    for i, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.Sights then
            for _, sight in pairs(atttbl.Sights) do
                local s = {}

                if CLIENT then
                    s = self:GenerateAutoSight(sight, slottbl)
                end

                if sight.Disassociate then
                    s.Disassociate = true
                end

                s.atttbl = atttbl
                s.ExtraSightDistance = slottbl.ExtraSightDistance or 0
                s.OriginalSightTable = sight
                s.slotbl = slottbl

                table.insert(self.MultiSightTable, s)
            end

            if !slottbl.KeepBaseIrons and !atttbl.KeepBaseIrons then
                keepbaseirons = false
            end
        end
    end

    if keepbaseirons then
        local tbl = {}
        table.Add(tbl, self.BaseSights)
        table.Add(self.MultiSightTable, self.BaseSights)
        self.MultiSightTable = tbl
    end

    if self:GetMultiSight() > #self.MultiSightTable then
        self:SetMultiSight(1)
    end
end

function SWEP:SwitchMultiSight()
    local old_msi = self:GetMultiSight()
    msi = old_msi
    msi = msi + 1

    if msi > #self.MultiSightTable then
        msi = 1
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
    return self.MultiSightTable[self:GetMultiSight()] or self.IronSights
end