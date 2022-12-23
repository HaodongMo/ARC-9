AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Base Projectile"

ENT.Spawnable 			= false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE

ENT.Model = "models/Items/grenadeAmmo.mdl"
ENT.Ticks = 0
ENT.FuseTime = 0
ENT.Defused = false
ENT.SphereSize = 2
ENT.PhysMat = "grenade"
ENT.SmokeTrail = true
ENT.SmokeTrailMat = "trails/smoke"
ENT.SmokeTrailSize = 6
ENT.SmokeTrailTime = 0.5
ENT.Flare = false
ENT.LifeTime = 5

ENT.Drag = true
ENT.Gravity = true
ENT.DragCoefficient = 0.25
ENT.Boost = 0
ENT.Lift = 0
ENT.GunshipWorkaround = true
ENT.HelicopterWorkaround = true

ENT.Damage = 150
ENT.Radius = 300
ENT.ImpactDamage = nil
ENT.ExplodeOnImpact = false

ENT.Scorch = true
ENT.ExplosionEffect = "explosion"

ENT.Dead = false
ENT.DieTime = 0
ENT.BounceSounds = {""}

ENT.SteerSpeed = 60 -- The maximum amount of degrees per second the missile can steer.
ENT.SeekerAngle = math.cos(35) -- The missile will lose tracking outside of this angle.
ENT.SuperSeeker = false
ENT.SACLOS = false -- This missile is manually guided by its shooter.
ENT.SemiActive = false -- This missile needs to be locked on to the target at all times.
ENT.FireAndForget = false -- This missile automatically tracks its target.
ENT.TopAttack = false -- This missile flies up above its target before going down in a top-attack trajectory.
ENT.TopAttackHeight = 5000
ENT.SuperSteerBoostTime = 5 -- Time given for this projectile to adjust its trajectory from top attack to direct
ENT.NoReacquire = false -- F&F target is permanently lost if it cannot reacquire

ENT.ShootEntData = {}

ENT.IsProjectile = true

ENT.LastHitNormal = Vector(0, 0, 0)

if SERVER then
    local gunship = {["npc_combinegunship"] = true, ["npc_combinedropship"] = true}

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInitSphere(self.SphereSize, self.PhysMat)

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:EnableDrag(self.Drag)
            phys:SetDragCoefficient(self.DragCoefficient)
            phys:EnableGravity(self.Gravity)
            phys:SetMass(5)
            phys:SetBuoyancyRatio(0.4)
        end

        self.SpawnTime = CurTime()

        if self.SmokeTrail then
            util.SpriteTrail(self, 0, Color( 255 , 255 , 255 ), false, self.SmokeTrailSize, 0, self.SmokeTrailTime, 1 / self.SmokeTrailSize * 0.5, self.SmokeTrailMat)
        end
    end

    function ENT:Think()
        if self.Defused then return end

        if self.SpawnTime + self.LifeTime < CurTime() then
            self:Detonate()
            return
        end

        if self:WaterLevel() > 0 then
            self:Detonate()
            return
        end

        local drunk = false

        if self.FireAndForget or self.SemiActive then
            if self.SemiActive then
                if IsValid(self.Weapon) then
                    self.ShootEntData = self.Weapon:RunHook("Hook_GetShootEntData", {})
                end
            end

            if self.ShootEntData.Target and IsValid(self.ShootEntData.Target) then
                local target = self.ShootEntData.Target
                if target.UnTrackable then self.ShootEntData.Target = nil end

                -- if self.TopAttack then
                --     local tpos = target:GetPos() + Vector(0, 0, 5000)
                --     if self.SpawnTime + self.TopAttackTime - 1 < CurTime() or self.TopAttackReached then
                --         tpos = target:GetPos()
                --     end
                --     local dir = (tpos - self:GetPos()):GetNormalized()
                --     local dist = (tpos - self:GetPos()):Length()
                --     local ang = dir:Angle()

                --     local p = self:GetAngles().p
                --     local y = self:GetAngles().y

                --     p = math.ApproachAngle(p, ang.p, FrameTime() * self.SteerSpeed)
                --     y = math.ApproachAngle(y, ang.y, FrameTime() * self.SteerSpeed)

                --     self:SetAngles(Angle(p, y, 0))

                --     if dist <= 1024 then
                --         self.TopAttackReached = true
                --     end
                -- else
                local tpos = target:EyePos()
                if self.TopAttack and !self.TopAttackReached then
                    tpos = tpos + Vector(0, 0, self.TopAttackHeight)

                    local dist = (tpos - self:GetPos()):Length()

                    if dist <= 2000 then
                        self.TopAttackReached = true
                        self.SuperSteerTime = CurTime() + self.SuperSteerBoostTime
                    end
                end
                local dir = (tpos - self:GetPos()):GetNormalized()
                local dot = dir:Dot(self:GetAngles():Forward())
                local ang = dir:Angle()

                if self.SuperSeeker or dot >= self.SeekerAngle or !self.TopAttackReached or (self.SuperSteerTime and self.SuperSteerTime >= CurTime()) then
                    local p = self:GetAngles().p
                    local y = self:GetAngles().y

                    p = math.ApproachAngle(p, ang.p, FrameTime() * self.SteerSpeed)
                    y = math.ApproachAngle(y, ang.y, FrameTime() * self.SteerSpeed)

                    self:SetAngles(Angle(p, y, 0))
                    -- self:SetVelocity(dir * 15000)
                elseif self.NoReacquire then
                    self.ShootEntData.Target = nil
                    drunk = true
                end
                -- end
            else
                drunk = true
            end
        elseif self.SACLOS then
            if self:GetOwner():IsValid() then
                local tpos = self:GetOwner():GetEyeTrace().HitPos
                local dir = (tpos - self:GetPos()):GetNormalized()
                local dot = dir:Dot(self:GetAngles():Forward())
                local ang = dir:Angle()

                if dot >= self.SeekerAngle then
                    local p = self:GetAngles().p
                    local y = self:GetAngles().y

                    p = math.ApproachAngle(p, ang.p, FrameTime() * self.SteerSpeed)
                    y = math.ApproachAngle(y, ang.y, FrameTime() * self.SteerSpeed)

                    self:SetAngles(Angle(p, y, 0))
                else
                    drunk = true
                end
            else
                drunk = true
            end
        end

        if drunk then
            self:SetAngles(self:GetAngles() + (AngleRand() * FrameTime() * 1000 / 360))
        end

        self:GetPhysicsObject():AddVelocity(Vector(0, 0, self.Lift) + self:GetForward() * self.Boost)

        -- Gunships have no physics collection, periodically trace to try and blow up in their face
        if self.GunshipWorkaround and (self.GunshipCheck or 0 < CurTime()) then
            self.GunshipCheck = CurTime() + 0.33
            local tr = util.TraceLine({
                start = self:GetPos(),
                endpos = self:GetPos() + (self:GetVelocity() * 6 * engine.TickInterval()),
                filter = self,
                mask = MASK_SHOT
            })
            if IsValid(tr.Entity) and gunship[tr.Entity:GetClass()] then
                self:SetPos(tr.HitPos)
                self:Detonate()
            end
        end
    end

    function ENT:Detonate()
        if !self:IsValid() then return end
        if self.Defused then return end
        local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )

        if self:WaterLevel() > 0 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
            --self:EmitSound("weapons/underwater_explode3.wav", 125, 100, 1, CHAN_AUTO)
        else
            util.Effect( self.ExplosionEffect, effectdata)
            --self:EmitSound("phx/kaboom.wav", 125, 100, 1, CHAN_AUTO)
        end

        util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), self.Radius, self.DamageOverride or self.Damage)

        if SERVER then
            local dir = self.HitVelocity or self:GetVelocity()

            if self.Boost <= 0 then
                dir = Vector(0, 0, -1)
            end

            self:FireBullets({
                Attacker = self,
                Damage = 0,
                Tracer = 0,
                Distance = 256,
                Dir = dir,
                Src = self:GetPos(),
                Callback = function(att, tr, dmg)
                    if self.Scorch then
                        util.Decal("Scorch", tr.StartPos, tr.HitPos - (tr.HitNormal * 16), self)
                    end
                end
            })
        end
        self.Defused = true
        -- self:Remove()

        SafeRemoveEntityDelayed(self, self.SmokeTrailTime)
        self:SetRenderMode(RENDERMODE_NONE)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    end

    function ENT:PhysicsCollide(colData, physobj)
        if !self:IsValid() then return end

        self.LastHitNormal = colData.HitNormal

        if self.ExplodeOnImpact then
            if CurTime() - self.SpawnTime < self.FuseTime then
                if IsValid(colData.HitEntity) then
                    local v = colData.OurOldVelocity:Length() ^ 0.5
                    local dmg = DamageInfo()
                    dmg:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageType(DMG_CRUSH)
                    dmg:SetDamage(v)
                    dmg:SetDamagePosition(colData.HitPos)
                    dmg:SetDamageForce(colData.OurOldVelocity)
                    colData.HitEntity:TakeDamageInfo(dmg)
                    self:EmitSound("weapons/rpg/shotdown.wav", 80, math.random(90, 110))
                end
                self:Defuse()
                return
            end

            timer.Simple(0, function()  -- to prevent "Changing collision rules within a callback is likely to cause crashes!" errors
                if !self:IsValid() then return end
                self:EmitSound("")

                self:GetPhysicsObject():EnableMotion(false)

                if self:IsValid() then
                    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                end
            end)

            local effectdata = EffectData()
                effectdata:SetOrigin( self:GetPos() )

            -- simulate AP damage on vehicles, mainly simfphys
            local tgt = colData.HitEntity
            while IsValid(tgt) do
                if tgt.GetParent and IsValid(tgt:GetParent()) then
                    tgt = tgt:GetParent()
                elseif tgt.GetBaseEnt and IsValid(tgt:GetBaseEnt()) then
                    tgt = tgt:GetBaseEnt()
                else
                    break
                end
            end
        else
            if colData.DeltaTime > 0.1 then
                self:EmitSound(self.BounceSounds[math.random(1, #self.BounceSounds)], 75)
            end
        end

        if self.ImpactDamage and IsValid(tgt) then
            local dmg = DamageInfo()
            dmg:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_BLAST) -- helicopters
            dmg:SetDamage(self.ImpactDamage)
            dmg:SetDamagePosition(colData.HitPos)
            dmg:SetDamageForce(self:GetForward() * self.ImpactDamage)

            if IsValid(tgt:GetOwner()) and tgt:GetOwner():GetClass() == "npc_helicopter" then
                tgt = tgt:GetOwner()
                dmg:ScaleDamage(0.1)
                dmg:SetDamageType(DMG_BLAST + DMG_AIRBOAT)
                dmg:SetDamageForce(self:GetForward() * 100)
            end

            tgt:TakeDamageInfo(dmg)
        end

        if self.ExplodeOnImpact then
            self.HitPos = colData.HitPos
            self.HitVelocity = colData.OurOldVelocity
            self:Detonate()
        end
    end

    -- Combine Helicopters are hard-coded to only take DMG_AIRBOAT damage
    hook.Add("EntityTakeDamage", "ARC9_HelicopterWorkaround", function(ent, dmginfo)
        if IsValid(ent:GetOwner()) and ent:GetOwner():GetClass() == "npc_helicopter" then ent = ent:GetOwner() end
        if ent:GetClass() == "npc_helicopter" and dmginfo:GetInflictor().HelicopterWorkaround then
            dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_AIRBOAT))
        end
    end)
end

function ENT:Defuse()
    self.Defused = true
    SafeRemoveEntityDelayed(self, 5)
end

local flaremat = Material("effects/arc9_lensflare")
function ENT:Draw()
    if self.Flare and !self.Defused then
        render.SetMaterial(flaremat)
        render.DrawSprite(self:GetPos(), math.Rand(90, 110), math.Rand(90, 110), Color(255, 250, 240))
    else
        self:DrawModel()
    end
end