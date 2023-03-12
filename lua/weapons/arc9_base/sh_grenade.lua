function SWEP:ThinkGrenade()
    if !self:GetProcessedValue("Throwable") then return end

    if IsValid(self:GetDetonatorEntity()) then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:TouchOff()
            return
        end
    end

    local fuse = self:GetProcessedValue("FuseTimer")

    if fuse >= 0 and self:GetGrenadePrimed() then
        local time = CurTime() - self:GetGrenadePrimedTime()

        if time >= fuse then
            self:ThrowGrenade(ARC9.NADETHROWTYPE_EXPLODEINHANDS, 0)

            if self:HasAnimation("explodeinhands") then
                self:PlayAnimation("explodeinhands", 1, true)
            else
                self:PlayAnimation("throw", 1, true)
            end
        end
    end

    local tossable = self:GetProcessedValue("Tossable") and self:HasAnimation("toss")

    if !self:GetGrenadePrimed() then
        if self:GetAnimLockTime() > CurTime() then return end

        if self:GetGrenadeRecovering() then
            if self:GetProcessedValue("Disposable") and !self:HasAmmoInClip() and !IsValid(self:GetDetonatorEntity()) and SERVER then
                if self.PairedItem then
                    if self:GetOwner():HasInventoryItemSpecific(self.PairedItem) then
                        self:GetOwner():TakeInventoryItem(self.PairedItem)
                    end
                else
                self:Remove()
                end
            else
                self:PlayAnimation("draw", self:GetProcessedValue("ThrowAnimSpeed"), true)
                self:SetGrenadeRecovering(false)
            end
        elseif ((tossable and self:GetOwner():KeyDown(IN_ATTACK2)) or
            self:GetOwner():KeyDown(IN_ATTACK)) and
            self:HasAmmoInClip() and
            (!self:GetOwner():KeyDown(IN_USE) or !self:GetProcessedValue("PrimaryBash")) and
            !IsValid(self:GetDetonatorEntity())
            then
            self:SetGrenadePrimed(true)
            self:SetGrenadePrimedTime(CurTime())

            if self:GetOwner():KeyDown(IN_ATTACK2) and self:HasAnimation("pullpin_toss") then
                self:PlayAnimation("pullpin_toss", self:GetProcessedValue("ThrowAnimSpeed"), true)
            else
                self:PlayAnimation("pullpin", self:GetProcessedValue("ThrowAnimSpeed"), true)
            end
            self:SetGrenadeTossing(self:GetOwner():KeyDown(IN_ATTACK2))
        end
    else
        if self:GetAnimLockTime() > CurTime() then return end

        if self:GetGrenadeTossing() and (!self:GetOwner():KeyDown(IN_ATTACK2) or self:GetProcessedValue("ThrowInstantly")) then
            local t = self:PlayAnimation("toss", self:GetProcessedValue("ThrowAnimSpeed"), true)
            local mp = self:GetAnimationEntry("toss").MinProgress or 0
            self:ThrowGrenade(ARC9.NADETHROWTYPE_TOSS, t * mp)
        elseif !self:GetGrenadeTossing() and (!self:GetOwner():KeyDown(IN_ATTACK) or self:GetProcessedValue("ThrowInstantly")) then
            local t = self:PlayAnimation("throw", self:GetProcessedValue("ThrowAnimSpeed"), true)
            local mp = self:GetAnimationEntry("throw").MinProgress or 0
            self:ThrowGrenade(ARC9.NADETHROWTYPE_NORMAL, t * mp)
        end

        self:SetGrenadeRecovering(true)
    end
end

function SWEP:ThrowGrenade(nttype, delaytime)
    delaytime = delaytime or 0
    self:SetGrenadePrimed(false)

    self:TakeAmmo()

    if CLIENT then return end

    local time = math.huge
    local fusetimer = self:GetProcessedValue("FuseTimer")
    local forcemax = self:GetProcessedValue("ThrowForceMax")
    local forcemin = self:GetProcessedValue("ThrowForceMin")
    local forcetime = self:GetProcessedValue("ThrowChargeTime")

    time = CurTime() - self:GetGrenadePrimedTime()

    local force = forcemax

    if forcetime > 0 then
        force = forcemin + (forcemax - forcemin) * math.Clamp(time / forcetime, 0, 1)
    end

    local num = self:GetProcessedValue("Num")
    local ent = self:GetProcessedValue("ShootEnt")

    if self:GetOwner():IsNPC() then
        -- ang = self:GetOwner():GetAimVector():Angle()
        spread = self:GetNPCBulletSpread()
    else
        spread = self:GetProcessedValue("Spread")
    end

    spread = math.Max(spread, 0)

    local override = {
        force = force,
        delay = delaytime,
    }
    self:RunHook("Hook_GrenadeThrown", override)

    force = override.force or force
    delaytime = override.delay or delaytime

    self:SetTimer(delaytime, function()

        local src, dir
        if self:GetProcessedValue("ThrowOnGround") then
            src = self:GetOwner():EyePos()
            dir = Angle(0, self:GetOwner():GetAngles().y, 0)

            local shootposoffset = self:GetProcessedValue("ShootPosOffset")

            local angRight = dir:Right()
            local angForward = dir:Forward()
            local angUp = dir:Up()

            angRight:Mul(shootposoffset[1])
            angForward:Mul(shootposoffset[2])
            angUp:Mul(shootposoffset[3])

            src:Add(angRight)
            src:Add(angForward)
            src:Add(angUp)

            src, dir = self:GetRecoilOffset(src, dir)

            local tr = util.TraceLine({
                start = src,
                endpos = src - Vector(0, 0, 64),
                mask = MASK_SOLID,
            })
            src = tr.HitPos
        else
            src, dir = self:GetShootPos()
        end

        local nades = {}
        for i = 1, num do
            local nade = ents.Create(ent)

            if !IsValid(nade) then return end
            local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)

            dispersion = dispersion * spread * 36

            nade:SetPos(src)
            nade:SetAngles(dir)
            nade:SetOwner(self:GetOwner())
            nade:Spawn()

            if fusetimer >= 0 then
                nade.LifeTime = fusetimer - time
            end

            if nttype  == ARC9.NADETHROWTYPE_TOSS then
                force = self:GetProcessedValue("TossForce")
            elseif nttype == ARC9.NADETHROWTYPE_EXPLODEINHANDS then
                force = 0
                time = 0
                nade:Detonate()
            end

            if self:GetProcessedValue("Detonator") then
                self:SetDetonatorEntity(nade)
            end

            local phys = nade:GetPhysicsObject()

            if IsValid(phys) then
                if self:GetProcessedValue("ThrowTumble") then
                    nade:SetAngles(Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
                    phys:AddAngleVelocity(Vector(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
                end

                if self:GetProcessedValue("ShootEntInheritPlayerVelocity") then
                    local vel = self:GetOwner():GetVelocity()
                    local limit = self:GetProcessedValue("ShootEntInheritPlayerVelocityLimit")
                    if isnumber(limit) and limit > 0 and vel:Length() > limit then
                        vel = vel:GetNormalized() * limit
                    end
                    phys:SetVelocity(vel)
                end

                phys:AddVelocity((dir + dispersion):Forward() * force)
            end

            table.insert(nades, nade)
        end

        self:RunHook("Hook_GrenadeCreated", nades)
    end)
end

function SWEP:TouchOff()
    self:PlayAnimation("touchoff", 1, true)

    self:SetGrenadeRecovering(true)

    if SERVER and IsValid(self:GetDetonatorEntity()) then
        self:GetDetonatorEntity():Detonate()
    end
end