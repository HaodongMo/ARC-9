function SWEP:Reload()
    if self:GetOwner():IsNPC() then
        self:NPC_Reload()
        return
    end

    if !self:GetOwner():KeyPressed(IN_RELOAD) then
        return
    end

    if self:GetOwner():KeyDown(IN_USE) then
        -- firemode switch
        return
    end

    if self:GetOwner():KeyDown(IN_WALK) then
        self:Inspect()
        return
    end

    if self:GetCustomize() then
        return
    end

    if self:StillWaiting() then return end
    if self:GetCapacity() <= 0 then return end
    if self:GetTraversalSprintAmount() >= 1 then return end
    if self:Ammo1() <= 0 then return end

    if !self:GetProcessedValue("BottomlessClip") then
        if self:Clip1() >= self:GetCapacity() then return end

        if !self:GetValue("InfiniteAmmo") then
            if self:Ammo1() <= 0 then return end
        end
    end

    -- self:ScopeToggle(0)
    -- self:ToggleCustomize(false)

    if self:Clip1() == 0 then
        self:SetEmptyReload(true)
    else
        self:SetEmptyReload(false)
    end

    local anim = "reload"

    if self:GetShouldShotgunReload() then
        anim = "reload_start"
    end

    anim = self:RunHook("Hook_SelectReloadAnimation", anim) or anim

    local t = self:PlayAnimation(anim, self:GetProcessedValue("ReloadTime"), true, true)

    self:GetOwner():DoAnimationEvent(self:GetProcessedValue("AnimReload"))

    if !self:GetShouldShotgunReload() then
        local minprogress = self:GetAnimationEntry(anim).MinProgress or 1

        self:SetTimer(t * minprogress, function()
            self:SetLoadedRounds(math.min(self:GetValue("ClipSize"), self:Clip1() + self:Ammo1()))
        end)
    end

    if SERVER then
        if self:Clip1() == 0 then
            self:SetTimer(self:GetProcessedValue("DropMagazineTime"), function()
                self:DropMagazine()
            end)
        end
    end

    self:SetLoadedRounds(self:Clip1())

    self:SetReloading(true)
    self:SetEndReload(false)

    -- self:SetTimer(t * 0.9, function()
    --     if !IsValid(self) then return end

    --     self:SetEndReload(false)
    --     self:EndReload()
    -- end)

    self:SetReloadFinishTime(CurTime() + (t * 0.95))
end

function SWEP:DropMagazine()
    -- if !IsFirstTimePredicted() and !game.SinglePlayer() then return end
    if self:GetProcessedValue("DropMagazineModel") then
        for i = 1, self:GetProcessedValue("DropMagazineAmount") do
            local mag = ents.Create("ARC9_droppedmag")

            if mag then
                mag:SetPos(self:GetOwner():EyePos() - (self:GetOwner():EyeAngles():Up() * 8))
                mag:SetAngles(self:GetOwner():EyeAngles())
                mag.Model = self:GetProcessedValue("DropMagazineModel")
                mag.ImpactSounds = self:GetProcessedValue("DropMagazineSounds")
                mag:SetOwner(self:GetOwner())
                mag:Spawn()

                local phys = mag:GetPhysicsObject()

                if IsValid(phys) then
                    phys:AddAngleVelocity(Vector(math.Rand(-300, 300), math.Rand(-300, 300), math.Rand(-300, 300)))
                end
            end
        end
    end
end

function SWEP:GetCapacity()
    return self:GetValue("ClipSize") + self:GetValue("ChamberSize")
end

function SWEP:RestoreClip(amt)
    local reserve = self:Clip1() + self:Ammo1()

    if self:GetValue("InfiniteAmmo") then
        reserve = math.huge
    end

    local lastclip1 = self:Clip1()

    self:SetClip1(math.min(math.min(self:Clip1() + amt, self:GetCapacity()), reserve))

    reserve = reserve - self:Clip1()

    self:GetOwner():SetAmmo(reserve, self.Primary.Ammo)

    return self:Clip1() - lastclip1
end

function SWEP:GetShouldShotgunReload()
    if self:GetProcessedValue("HybridReload") then
        if self:Clip1() >= self:GetProcessedValue("ChamberSize") then
            return true
        else
            return false
        end
    end

    return self:GetProcessedValue("ShotgunReload")
end

function SWEP:EndReload()
    if self:GetShouldShotgunReload() then
        if self:Clip1() >= self:GetCapacity() or self:Ammo1() == 0 or self:GetEndReload() then
            // finish
            self:PlayAnimation("reload_finish", self:GetProcessedValue("ReloadTime", 1), true, true)
            self:SetReloading(false)

            self:SetNthShot(0)
            self:SetNthReload(self:GetNthReload() + 1)
        else
            local t = self:PlayAnimation("reload_insert", self:GetProcessedValue("ReloadTime", 1), true)

            local res = math.min(math.min(3, self:GetCapacity() - self:Clip1()), self:Ammo1())

            self:SetLoadedRounds(res)

            for i = 1, res do
                self:SetTimer(t * 0.95 * ((i - 1) / 3), function()
                    self:RestoreClip(1)
                end)
            end

            self:SetReloadFinishTime(CurTime() + (t * 0.95 * (res / 3)))

            -- self:SetTimer(t * 0.95 * (res / 3), function()
            --     if !IsValid(self) then return end

            --     self:EndReload()
            -- end)
        end
    else
        self:RestoreClip(self:GetValue("ClipSize"))
        self:SetReloading(false)

        self:SetNthShot(0)
        self:SetNthReload(self:GetNthReload() + 1)
        self:SetEmptyReload(false)
    end
end

function SWEP:ThinkReload()
    if self:GetReloading() and self:GetReloadFinishTime() < CurTime() then
        self:EndReload()
    end
end

function SWEP:DoBulletPose()
    local pp = self:Clip1()

    local vm = self:GetVM()

    pp = self:RunHook("HookP_ModifyBulletPoseParam", pp) or pp

    vm:SetPoseParameter("bullets", pp)
end