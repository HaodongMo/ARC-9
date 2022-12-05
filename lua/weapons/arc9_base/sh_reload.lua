function SWEP:Reload()
    if self:GetOwner():IsNPC() then
        self:NPC_Reload()
        return
    end

    if !self:GetOwner():KeyPressed(IN_RELOAD) then
        return
    end

    if !self:GetProcessedValue("UBGLInsteadOfSights") and self:GetValue("UBGL") then
        if self:GetOwner():KeyDown(IN_USE) then
            return
        end
    end

    if self:GetJammed() then
        self:UnJam()
        return
    end

    if self:GetOwner():KeyDown(IN_WALK) then
        return
    end

    if !self:CanReload() then return end

    local clip = self:Clip1()
    local ammo = self:Ammo1()

    if self:GetUBGL() then
        clip = self:Clip2()
        ammo = self:Ammo2()
    end

    if !self:GetProcessedValue("BottomlessClip") then
        if clip >= self:GetCapacity(self:GetUBGL()) then return end

        if !self:GetInfiniteAmmo() and ammo <= 0 then
            return
        end
    else
        return
    end


    -- if CLIENT and !self:ShouldTPIK() then
        -- self:DoPlayerAnimationEvent(self:GetProcessedValue("NonTPIKAnimReload"))
    -- else
        -- self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimReload"))
    -- end

    self:CallOnClient("CallNonTPIKReloadAnim", "")

    -- self:ScopeToggle(0)
    -- self:ToggleCustomize(false)

    if clip == 0 then
        self:SetEmptyReload(true)
    else
        self:SetEmptyReload(false)
    end

    local anim = "reload"

    if self:GetUBGL() then
        anim = "reload_ubgl"
    end

    if self:GetShouldShotgunReload() then
        anim = "reload_start"

        if self:GetUBGL() then
            anim = "reload_ubgl_start"
        end

        local nanim = anim

        for i = 1, self:GetCapacity(self:GetUBGL()) - clip do
            if self:HasAnimation(anim .. "_" .. tostring(i)) then
                nanim = anim .. "_" .. tostring(i)
            end
        end

        anim = nanim

    end

    if !self:GetProcessedValue("ReloadInSights") then
        self:ExitSights()
    end

    anim = self:RunHook("Hook_SelectReloadAnimation", anim) or anim

    local t = self:PlayAnimation(anim, self:GetProcessedValue("ReloadTime"), true)

    if !self:GetShouldShotgunReload() then
        local minprogress = self:GetAnimationEntry(self:TranslateAnimation(anim)).MinProgress or 1
        minprogress = math.min(minprogress, 0.95)

        if self:GetUBGL() then
            self:SetTimer(t * minprogress, function()
                self:RestoreClip(self:GetValue("UBGLClipSize"))
            end, "reloadtimer")
        else
            self:SetTimer(t * minprogress, function()
                self:RestoreClip(self:GetValue("ClipSize"))
            end, "reloadtimer")
        end

        local newcliptime = self:GetAnimationEntry(self:TranslateAnimation(anim)).MagSwapTime or 0.5

        if !self:GetUBGL() then
            self:SetTimer(self:GetProcessedValue("ReloadTime") * newcliptime, function()
                local ammo1 = self:Ammo1()

                if self:GetInfiniteAmmo() then
                    ammo1 = math.huge
                end
                self:SetLoadedRounds(math.min((clip == 0 and self:GetValue("ClipSize") or self:GetCapacity(false)), self:Clip1() + ammo1))
            end)
        end
    end

    if SERVER then
        if self:GetProcessedValue("ShouldDropMag") or self:GetProcessedValue("ShouldDropMagEmpty") and clip == 0 then
            self:SetTimer(self:GetProcessedValue("DropMagazineTime"), function()
                self:DropMagazine()
            end)
        end
    end

    self:SetLoadedRounds(self:Clip1())

    self:SetReloading(true)
    self:SetEndReload(false)
    self:ToggleBlindFire(false)
    self:SetRequestReload(false)
    self:SetRecoilAmount(0)

    -- self:SetTimer(t * 0.9, function()
    --     if !IsValid(self) then return end

    --     self:SetEndReload(false)
    --     self:EndReload()
    -- end)

    self:SetReloadFinishTime(CurTime() + (t * 0.95))
end

function SWEP:CanReload()
    if self:GetOwner():KeyDown(IN_WALK) then return false end
    if self:StillWaiting() then return end
    if self:GetCapacity(self:GetUBGL()) <= 0 then return end
    -- if self:GetTraversalSprintAmount() >= 0 then return end
    local ammo = self:Ammo1()
    if self:GetUBGL() then
        ammo = self:Ammo2()
    end
    if ammo <= 0 and !self:GetInfiniteAmmo() then return end
    if !self:GetProcessedValue("ReloadWhileSprint") and self:GetSprintAmount() > 0 then
        return
    end
    if self:GetJammed() then return end
    if self:GetCustomize() then
        return
    end

    return true
end

function SWEP:CancelReload()
    if !self:GetReloading() then return end

    self:SetReloading(false)
    self:SetReloadFinishTime(0)
    local vm = self:GetVM()
    vm:SetSequence(0)
    vm:SetCycle(0)
    self:SetAnimLockTime(0)
    self:PlayAnimation("idle")
    self:DoPlayerAnimationEvent(ACT_HL2MP_GESTURE_RELOAD_MAGIC)
    self:CancelSoundTable()
    self:KillTimer("reloadtimer")
    self:SetIKTimeLineStart(0)
    self:SetIKTime(0)
    self:SetEmptyReload(false)
end

function SWEP:DropMagazine()
    -- if !IsFirstTimePredicted() and !game.SinglePlayer() then return end
    if !self:GetProcessedValue("ShouldDropMag") then return end

    local mdl = self:GetProcessedValue("DropMagazineModel")

    if mdl then
        util.PrecacheModel(mdl) -- garry newman moment

        for i = 1, self:GetProcessedValue("DropMagazineAmount") do
            local drop_qca = self:GetQCAMagdrop()

            local data = EffectData()
            data:SetEntity(self)
            data:SetAttachment(drop_qca)

            util.Effect("arc9_magdropeffect", data, true)
            -- local mag = ents.Create("ARC9_droppedmag")

            -- if mag then
            --     mag:SetPos(self:GetOwner():EyePos() - (self:GetOwner():EyeAngles():Up() * 8))
            --     mag:SetAngles(self:GetOwner():EyeAngles())
            --     mag.Model = self:GetProcessedValue("DropMagazineModel")
            --     mag.ImpactSounds = self:GetProcessedValue("DropMagazineSounds")
            --     mag:SetOwner(self:GetOwner())
            --     mag:Spawn()
            --     mag:SetSkin(self:GetProcessedValue("DropMagazineSkin"))

            --     local phys = mag:GetPhysicsObject()

            --     if IsValid(phys) then
            --         phys:AddAngleVelocity(Vector(math.Rand(-300, 300), math.Rand(-300, 300), math.Rand(-300, 300)))
            --     end
            -- end
        end
    end
end

function SWEP:TakeAmmo()
    if self:GetUBGL() then
        self:TakeSecondaryAmmo(self:GetProcessedValue("AmmoPerShot"))
    else
        if self:GetValue("BottomlessClip") then
            if !self:GetInfiniteAmmo() then
                self:RestoreClip(self:GetValue("ClipSize"))

                if self:Ammo1() > 0 then
                    local ammotype = self:GetValue("Ammo")
                    self:GetOwner():SetAmmo(self:GetOwner():GetAmmoCount(ammotype) - self:GetValue("AmmoPerShot"), ammotype)
                else
                    self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
                end
            end
        else
            self:TakePrimaryAmmo(self:GetProcessedValue("AmmoPerShot"))
        end
    end
end

function SWEP:GetCapacity(ubgl)
    local cap = 0

    if ubgl then
        cap = math.Round(self:GetValue("UBGLClipSize")) + math.Round(self:GetValue("UBGLChamberSize"))
    else
        cap = math.Round(self:GetValue("ClipSize")) + math.Round(self:GetValue("ChamberSize"))
    end

    return cap
end

function SWEP:RestoreClip(amt)
    if CLIENT then return end

    amt = amt or math.huge

    amt = math.Round(amt)

    local inf = self:GetInfiniteAmmo()
    local clip = self:Clip1()
    local ammo = self:Ammo1()

    if self:GetUBGL() then
        clip = self:Clip2()
        ammo = self:Ammo2()
    end

    local reserve = inf and math.huge or (clip + ammo)

    local lastclip

    if self:GetUBGL() then
        lastclip = self:Clip2()

        self:SetClip2(math.min(math.min(clip + amt, self:GetCapacity(true)), reserve))

        reserve = reserve - self:Clip2()

        if !inf then
            if IsValid(self:GetOwner()) then
                self:GetOwner():SetAmmo(reserve, self.Secondary.Ammo)
            end
        end

        clip = self:Clip2()
    else
        lastclip = self:Clip1()

        self:SetClip1(math.min(math.min(clip + amt, self:GetCapacity(false)), reserve))

        reserve = reserve - self:Clip1()

        if !inf then
            if IsValid(self:GetOwner()) then
                self:GetOwner():SetAmmo(reserve, self.Primary.Ammo)
            end
        end

        clip = self:Clip1()

        self:SetLoadedRounds(self:Clip1())
    end

    return clip - lastclip
end

function SWEP:GetShouldShotgunReload()
    if self:GetProcessedValue("HybridReload") then
        if self:Clip1() > self:GetProcessedValue("ChamberSize") then
            return true
        else
            return false
        end
    end

    return self:GetProcessedValue("ShotgunReload")
end

function SWEP:GetInfiniteAmmo()
    return self:GetProcessedValue("InfiniteAmmo") or GetConVar("arc9_infinite_ammo"):GetBool()
end

function SWEP:EndReload()
    if self:GetShouldShotgunReload() then
        local clip = self:Clip1()
        local ammo = self:Ammo1()

        if self:GetUBGL() then
            clip = self:Clip2()
            ammo = self:Ammo2()
        end

        if self:GetInfiniteAmmo() then
            ammo = math.huge
        end

        if clip >= self:GetCapacity(self:GetUBGL()) or ammo == 0 or (self:GetEndReload() and clip > 0) then
            // finish
            local anim = "reload_finish"

            if self:GetUBGL() then
                anim = "reload_ubgl_finish"
            end

            local canim = anim

            for i = 1, self:GetCapacity(self:GetUBGL()) - clip do
                if self:HasAnimation(anim .. "_" .. tostring(i)) then
                    canim = anim .. "_" .. tostring(i)
                end
            end

            anim = canim

            self:PlayAnimation(anim, self:GetProcessedValue("ReloadTime", 1), true)
            self:SetReloading(false)

            self:SetNthShot(0)

            if self:GetEmptyReload() or self:GetProcessedValue("PartialReloadCountsTowardsNthReload") then
                self:SetNthReload(self:GetNthReload() + 1)
            end

            self:SetEmptyReload(false)
        else
            local anim = "reload_insert"
            if self:GetUBGL() then
                anim = "reload_ubgl_insert"
            end
            local attempt_to_restore = 1

            local banim = anim

            for i = 1, self:GetCapacity(self:GetUBGL()) - clip do
                if self:HasAnimation(anim .. "_" .. tostring(i)) then
                    banim = anim .. "_" .. tostring(i)
                    attempt_to_restore = i
                elseif self:HasAnimation(anim .. "_bullet_" .. tostring(i)) then
                    banim = anim .. "_bullet_" .. tostring(i)
                    attempt_to_restore = 1
                end
            end

            anim = banim

            local minprogress = (self:GetAnimationEntry(anim) or {}).MinProgress or 0.75
            minprogress = math.min(minprogress, 0.99)

            local t = self:PlayAnimation(anim, self:GetProcessedValue("ReloadTime", 1), true)

            -- local res = math.min(math.min(attempt_to_restore, self:GetCapacity(self:GetUBGL()) - clip), ammo)

            -- self:SetLoadedRounds(res)
            self:SetLoadedRounds(math.max(1, self:Clip1())) -- probably very dumb but idk i just want it work correctly with bullet b ones

            self:SetTimer(minprogress * t, function()
                self:RestoreClip(attempt_to_restore)
            end)

            self:SetReloadFinishTime(CurTime() + t)

            -- self:SetTimer(t * 0.95 * (res / 3), function()
            --     if !IsValid(self) then return end

            --     self:EndReload()
            -- end)
        end
    else
        self:SetReloading(false)

        self:SetNthShot(0)

        if self:GetEmptyReload() or self:GetProcessedValue("PartialReloadCountsTowardsNthReload") then
            self:SetNthReload(self:GetNthReload() + 1)
        end
        -- self:SetLoadedRounds(self:Clip1())

        self:SetEmptyReload(false)
    end
end

function SWEP:ThinkReload()
    if self:GetReloading() and self:GetReloadFinishTime() < CurTime() then
        self:EndReload()
    end
end

function SWEP:GetLoadedClip()
    local clip = self:Clip1()
    local ammo = self:Ammo1()
    local ammo2 = self:Ammo2()

    if self:GetInfiniteAmmo() then
        ammo = math.huge
    end

    if self:GetProcessedValue("BottomlessClip") then
        clip = ammo
        self:RestoreClip(math.huge)
    end

    if self:GetUBGL() then
        clip = self:Clip2()

        if self:GetProcessedValue("BottomlessClip") then
            clip = ammo2
        end
    end

    return clip
end

function SWEP:HasAmmoInClip()
    return self:GetLoadedClip() >= self:GetProcessedValue("AmmoPerShot")
end

function SWEP:DoBulletPose()
    local pp = self:Clip1()

    local vm = self:GetVM()

    pp = self:RunHook("HookP_ModifyBulletPoseParam", pp) or pp

    vm:SetPoseParameter("bullets", pp)
end

function SWEP:Ammo1()
    if !IsValid(self:GetOwner()) then return math.huge end

    if self:GetInfiniteAmmo() then
        return math.huge
    end

    return self:GetOwner():GetAmmoCount(self:GetProcessedValue("Ammo"))
end

function SWEP:Ammo2()
    if !IsValid(self:GetOwner()) then return math.huge end

    if self:GetInfiniteAmmo() then
        return math.huge
    end

    return self:GetOwner():GetAmmoCount(self:GetProcessedValue("UBGLAmmo"))
end

if CLIENT then
    function SWEP:CallNonTPIKReloadAnim()
        if !self:ShouldTPIK() then
            self:DoPlayerAnimationEvent(self:GetProcessedValue("NonTPIKAnimReload"))
        else
            self:DoPlayerAnimationEvent(self:GetProcessedValue("AnimReload"))
        end
    end
end