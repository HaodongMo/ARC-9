function SWEP:GetSightDelta()
    return self:GetSightAmount()
end

function SWEP:EnterSights()
    if self:GetSprintAmount() > 0 then return end
    if !self:GetProcessedValue("HasSights") then return end
    if self:GetCustomize() then return end
    if !self:GetProcessedValue("ReloadInSights") and self:GetReloading() then return end
    if self:GetHolsterTime() > 0 then return end
    if self:GetProcessedValue("UBGLInsteadOfSights") then return end
    if self:GetSafe() then return end
    if self:GetAnimLockTime() > CurTime() and !self:GetReloading() then return end -- i hope this won't cause any issues later

    -- self:ToggleBlindFire(false)
    self:SetInSights(true)
    if IsFirstTimePredicted() then
        local soundtab1 = {
            name = "entersights",
            sound = self:RandomChoice(self:GetProcessedValue("EnterSightsSound")),
            channel = ARC9.CHAN_FIDDLE,
        }

        self:PlayTranslatedSound(soundtab1)
    end

    if self:GetAnimLockTime() < CurTime() then
        if self:GetProcessedValue("InstantSightIdle") then
            self:PlayAnimation("idle")
        else
            self:PlayAnimation("enter_sights", self:GetProcessedValue("AimDownSightsTime"))
        end
    end

    self:SetShouldHoldType()
end

function SWEP:ExitSights()
    self:SetInSights(false)

    if IsFirstTimePredicted() then
        local soundtab1 = {
            name = "exitsights",
            sound = self:RandomChoice(self:GetProcessedValue("ExitSightsSound")),
            channel = ARC9.CHAN_FIDDLE,
        }

        self:PlayTranslatedSound(soundtab1)
    end

    if self:GetAnimLockTime() < CurTime() then
        if self:GetProcessedValue("InstantSightIdle") then
            self:PlayAnimation("idle")
        else
            self:PlayAnimation("exit_sights", self:GetProcessedValue("AimDownSightsTime"))
        end
    end

    self:SetShouldHoldType()
end

function SWEP:ToggleADS()
    return self:GetOwner():GetInfoNum("arc9_toggleads", 0) >= 1
end

SWEP.MultiSightTable = {
    -- {
    --     Pos = Vector(0, 0, 0),
    --     Ang = Angle(0, 0, 0)
    -- }
}

function SWEP:BuildMultiSight()
    if game.SinglePlayer() then self:CallOnClient("BuildMultiSight", "") end
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
                if !self:GetUBGL() and sight.UBGLOnly then continue end
                if self:GetUBGL() and self:GetProcessedValue("UBGLExclusiveSights") and !sight.UBGLOnly then continue end
                local s = {}

                if CLIENT then
                    if ARC9.Dev(3) then
                        s = self:GenerateAutoSight({
                            Pos = Vector(GetConVar("arc9_dev_irons_x"):GetFloat(), GetConVar("arc9_dev_irons_y"):GetFloat(), GetConVar("arc9_dev_irons_z"):GetFloat()),
                            Ang = Angle(GetConVar("arc9_dev_irons_pitch"):GetFloat(), GetConVar("arc9_dev_irons_yaw"):GetFloat(), GetConVar("arc9_dev_irons_roll"):GetFloat()),
                            ViewModelFOV = 40,
                            Magnification = 1.1
                        }, slottbl)
                    else
                        s = self:GenerateAutoSight(sight, slottbl)
                    end
                end

                if sight.Disassociate then
                    s.Disassociate = true
                end

                s.CrosshairInSights = sight.CrosshairInSights

                s.atttbl = atttbl
                if sight.ExtraSightData then
                    s.atttbl = table.Copy(atttbl)
                    table.Merge(s.atttbl, sight.ExtraSightData)
                    s.ExtraSightData = sight.ExtraSightData
                end

                s.OnSwitchToSight = sight.OnSwitchToSight
                s.OnSwitchFromSight = sight.OnSwitchFromSight

                if ARC9.Dev(3) then
                    s.OriginalSightTable = {
                        Pos = Vector(GetConVar("arc9_dev_irons_x"):GetFloat(), GetConVar("arc9_dev_irons_y"):GetFloat(), GetConVar("arc9_dev_irons_z"):GetFloat()),
                        Ang = Angle(GetConVar("arc9_dev_irons_pitch"):GetFloat(), GetConVar("arc9_dev_irons_yaw"):GetFloat(), GetConVar("arc9_dev_irons_roll"):GetFloat()),
                        ViewModelFOV = 40,
                        Magnification = 1.1
                    }
                else
                    s.OriginalSightTable = sight
                end
                s.slottbl = slottbl
                s.ViewModelFOV = sight.ViewModelFOV
                s.InvertColors = sight.InvertColors or false

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

                if sight.Blur == false then s.Blur = false end -- false exactly, not nil because nil is yes

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
        if ARC9.Dev(3) then
            table.insert(tbl, {
                Pos = Vector(GetConVar("arc9_dev_irons_x"):GetFloat(), GetConVar("arc9_dev_irons_y"):GetFloat(), GetConVar("arc9_dev_irons_z"):GetFloat()),
                Ang = Angle(GetConVar("arc9_dev_irons_pitch"):GetFloat(), GetConVar("arc9_dev_irons_yaw"):GetFloat(), GetConVar("arc9_dev_irons_roll"):GetFloat()),
                ViewModelFOV = 40,
                Magnification = 1.1
            })
        else
            table.insert(tbl, self:GetProcessedValue("IronSights"))
        end
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

    if self.NextSightSwitch and self.NextSightSwitch > CurTime() then return end
    self.NextSightSwitch = CurTime() + 0.25

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

    self:RunHook("Hook_SwitchSight", self.MultiSightTable[msi])

    if self.MultiSightTable[msi].OnSwitchToSight then
        self.MultiSightTable[msi].OnSwitchToSight(self, self.MultiSightTable[msi].slottbl)
    end

    if self.MultiSightTable[old_msi].OnSwitchFromSight then
        self.MultiSightTable[old_msi].OnSwitchFromSight(self, self.MultiSightTable[msi].slottbl)
    end

    self:InvalidateCache()

    if msi != old_msi then
        if self:StillWaiting() then return end

        if (self.MultiSightTable[old_msi].atttbl or {}).ID == (self.MultiSightTable[msi].atttbl or {}).ID then
            self:PlayAnimation("switchsights", 1, false)
        end
    end
end

do
    local ENTITY = FindMetaTable("Entity")
    local entityGetOwner = ENTITY.GetOwner
    local entitySetPoseParameter = ENTITY.SetPoseParameter

    local PLAYER = FindMetaTable("Player")
    local playerKeyDown = PLAYER.KeyDown
    local playerKeyPressed = PLAYER.KeyPressed

    local swepGetIsNearWall = SWEP.GetIsNearWall
    local swepToggleADS = SWEP.ToggleADS
    local swepExitSights = SWEP.ExitSights
    local swepEnterSights = SWEP.EnterSights
    local swepGetBipodAmount = SWEP.GetBipodAmount
    local swepBuildMultiSight = SWEP.BuildMultiSight
    local swepSwitchMultiSight = SWEP.SwitchMultiSight

    function SWEP:ThinkSights()
        -- if self:GetSafe() then return end
        local vm = self:GetVM()
        local swepDt = self.dt

        local sighted = swepDt.InSights
        if swepDt.Safe or swepGetIsNearWall(self) then
            sighted = false
        end

        local oldamt = swepDt.SightAmount
        local amt = math.Approach(
            oldamt, sighted and 1 or 0, FrameTime() / self:GetProcessedValue("AimDownSightsTime"))

        if CLIENT then
            entitySetPoseParameter(vm, "sights", amt)
        end

        if oldamt ~= amt then
            self:SetSightAmount(amt)
        end

        local owner = entityGetOwner(self)
        local toggle = swepToggleADS(self)
        local inatt = playerKeyDown(owner, IN_ATTACK2)
        local pratt = playerKeyPressed(owner, IN_ATTACK2)

        if toggle then
            if sighted and pratt then
                swepExitSights(self)
            elseif not sighted and pratt then
                -- if self:GetOwner():KeyDown(IN_USE) then
                    -- return
                -- end why was this here?
                swepEnterSights(self)
            end
    
            if pratt then
                swepBuildMultiSight(self)
            end
        else
            if sighted and !inatt then
                swepExitSights(self)
            elseif not sighted and inatt then
                -- if self:GetOwner():KeyDown(IN_USE) then
                    -- return
                -- end why was this here?
                swepEnterSights(self)
                swepBuildMultiSight(self)
            end
        end

        if sighted and playerKeyPressed(owner, IN_USE) and playerKeyDown(owner, IN_WALK) then
            -- if CurTime() - self:GetLastPressedETime() < 0.33 then
            if playerKeyDown(owner, IN_SPEED) then
                swepSwitchMultiSight(self, -1)
            else
                swepSwitchMultiSight(self)
            end
            --     self:SetLastPressedETime(0)
            -- else
            --     self:SetLastPressedETime(CurTime())
            -- end
        end

        entitySetPoseParameter(vm, "sights", math.max(swepDt.SightAmount, swepGetBipodAmount(self)))
    end
end

function SWEP:GetSight()
    if ARC9.Dev(2) then
        self:BuildMultiSight() -- this is what was fixing toggle sights
    end
    -- if !self.MultiSightTable and self:GetValue("Sights") then self:BuildMultiSight() end
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
        return sights.RTScopeFOV or atttbl.RTScopeFOV
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
        local soundtab1 = {
            name = "zoom",
            sound = atttbl.ZoomSound or "arc9/useatt.wav",
            pitch = math.Rand(95, 105),
            vol = 1,
            chan = CHAN_ITEM
        }

        self:PlayTranslatedSound(soundtab1)
    end
end

function SWEP:IsScoping()
    local sight = self:GetSight()

    local atttbl

    if sight.BaseSight then
        atttbl = self:GetTable()
    else
        atttbl = self:GetFinalAttTable(sight.slottbl)
    end

    if sight.ExtraSightData then
        atttbl = table.Copy(atttbl)
        table.Merge(atttbl, sight.ExtraSightData)
    end

    return self:GetSightAmount() > 0 and atttbl.RTScope and atttbl
end