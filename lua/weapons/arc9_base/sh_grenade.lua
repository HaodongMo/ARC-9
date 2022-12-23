function SWEP:ThinkGrenade()
    if self:PredictionFilter() then return end
    if !self:GetProcessedValue("Throwable") then return end

    if IsValid(self:GetDetonatorEntity()) and self:GetOwner():KeyDown(IN_ATTACK) then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:TouchOff()
        end
        return
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

    if self:GetAnimLockTime() > CurTime() then return end

    local tossable = self:GetProcessedValue("Tossable") and self:HasAnimation("toss")

    if !self:GetGrenadePrimed() then
        if self:GetGrenadeRecovering() then
            if self:GetProcessedValue("Disposable") and !self:HasAmmoInClip() and !IsValid(self:GetDetonatorEntity()) then
                self:Remove()
            else
                self:PlayAnimation("draw", self:GetProcessedValue("ThrowAnimSpeed"), true)
                self:SetGrenadeRecovering(false)
            end
        elseif ((tossable and self:GetOwner():KeyDown(IN_ATTACK2)) or
            self:GetOwner():KeyDown(IN_ATTACK)) and
            self:HasAmmoInClip()
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

    local src, dir = self:GetShootPos()

    local num = self:GetProcessedValue("Num")
    local ent = self:GetProcessedValue("ShootEnt")

    if self:GetOwner():IsNPC() then
        -- ang = self:GetOwner():GetAimVector():Angle()
        spread = self:GetNPCBulletSpread()
    else
        spread = self:GetProcessedValue("Spread")
    end

    spread = math.Max(spread, 0)

    self:SetTimer(delaytime, function()
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

                phys:SetVelocity(self:GetOwner():GetVelocity())

                phys:AddVelocity((dir + dispersion):Forward() * force)
            end
        end
    end)
end

function SWEP:TouchOff()
    self:PlayAnimation("touchoff", 1, true)

    self:SetGrenadeRecovering(true)

    self:GetDetonatorEntity():Detonate()
end