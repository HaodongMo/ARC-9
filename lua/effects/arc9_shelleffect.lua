EFFECT.Type = 1

EFFECT.Pitch = 100

EFFECT.Model = "models/shells/shell_57.mdl"

EFFECT.AlreadyPlayedSound = false
EFFECT.ShellTime = 0.5
EFFECT.SpawnTime = 0

-- EFFECT.TypeSettings = {
--     [1] = {
--         Model = "models/weapons/shell.mdl",
--         Sounds = {
--             "player/pl_shell1.wav",
--             "player/pl_shell2.wav",
--             "player/pl_shell3.wav",
--         }
--     },
--     [2] = {
--         Model = "models/weapons/rifleshell.mdl",
--         Sounds = {
--             "player/pl_shell1.wav",
--             "player/pl_shell2.wav",
--             "player/pl_shell3.wav",
--         },
--         Scale = 0.5
--     },
--     [3] = {
--         Model = "models/weapons/shotgun_shell.mdl",
--         Sounds = {
--             "weapons/fx/tink/shotgun_shell1.wav",
--             "weapons/fx/tink/shotgun_shell2.wav",
--             "weapons/fx/tink/shotgun_shell3.wav",
--         }
--     },
-- }

function EFFECT:Init(data)

    local att = data:GetAttachment()
    local ent = data:GetEntity()

    if !IsValid(ent) then self:Remove() return end
    if !IsValid(ent:GetOwner()) then self:Remove() return end

    if LocalPlayer():ShouldDrawLocalPlayer() or ent:GetOwner() != LocalPlayer() then
        mdl = (ent.WModel or {})[1] or ent
        att = 2
    else
        mdl = LocalPlayer():GetViewModel()
    end

    if !IsValid(ent) then self:Remove() return end
    if !mdl or !IsValid(mdl) then self:Remove() return end
    if !mdl:GetAttachment(att) then self:Remove() return end

    local origin, ang = mdl:GetAttachment(att).Pos, mdl:GetAttachment(att).Ang

    -- ang:RotateAroundAxis(ang:Up(), -90)

    -- ang:RotateAroundAxis(ang:Right(), (ent.ShellRotateAngle or Angle(0, 0, 0))[1])
    -- ang:RotateAroundAxis(ang:Up(), (ent.ShellRotateAngle or Angle(0, 0, 0))[2])
    -- ang:RotateAroundAxis(ang:Forward(), (ent.ShellRotateAngle or Angle(0, 0, 0))[3])

    local model = ent:GetProcessedValue("ShellModel")
    local mat = ent:GetProcessedValue("ShellMaterial")
    local scale = ent:GetProcessedValue("ShellScale")
    local physbox = ent:GetProcessedValue("ShellPhysBox")
    local pitch = ent:GetProcessedValue("ShellPitch")
    local sounds = ent:GetProcessedValue("ShellSounds")
    
    local dir = ang:Forward()

    local correctang = ent:GetProcessedValue("ShellCorrectAng") or angle_zero
    ang:RotateAroundAxis(ang:Forward(), 90 + correctang.p)
    ang:RotateAroundAxis(ang:Right(), correctang.y)
    ang:RotateAroundAxis(ang:Up(), correctang.r)

    self:SetPos(origin)
    self:SetModel(model or "")
    self:SetMaterial(mat or "")
    self:DrawShadow(true)
    self:SetAngles(ang)
    self:SetModelScale(scale or 1)

    self.ShellPitch = pitch

    -- if !LocalPlayer():ShouldDrawLocalPlayer() and ent:GetOwner() == LocalPlayer() then
    --     self:SetNoDraw(true)
    -- end

    -- table.insert(ent.EjectedShells, self)

    self.Sounds = sounds or ARC9.ShellSoundsTable

    local pb_z = physbox.z
    local pb_y = physbox.y
    local pb_x = physbox.x

    local mag = 150

    self:PhysicsInitBox(Vector(-pb_z,-pb_y,-pb_x), Vector(pb_z,pb_x,pb_y))

    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local phys = self:GetPhysicsObject()

    local plyvel = vector_origin

    if IsValid(ent.Owner) then
        plyvel = ent.Owner:GetAbsVelocity()
    end

    phys:Wake()
    phys:SetDamping(0, 0)
    phys:SetMass(1)
    phys:SetMaterial("gmod_silent")
    -- phys:SetMaterial("default_silent")

    local velocity = ent:GetProcessedValue("ShellVelocity") or math.Rand(1, 2)

    phys:SetVelocity((dir * mag * velocity) + plyvel)

    phys:AddAngleVelocity(VectorRand() * 100)
    phys:AddAngleVelocity(ang:Up() * 2500 * velocity/0.75)

    if ent:GetProcessedValue("ShellSmoke") then
        local emitter = ParticleEmitter(origin)

        for i = 1, 3 do
            local particle = emitter:Add("particles/smokey", origin + (dir * 2))

            if (particle) then
                particle:SetVelocity(VectorRand() * 10 + (dir * i * math.Rand(48, 64)) + plyvel)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.05, 0.15))
                particle:SetStartAlpha(math.Rand(40, 60))
                particle:SetEndAlpha(0)
                particle:SetStartSize(0)
                particle:SetEndSize(math.Rand(18, 24))
                particle:SetRoll(math.rad(math.Rand(0, 360)))
                particle:SetRollDelta(math.Rand(-1, 1))
                particle:SetLighting(true)
                particle:SetAirResistance(96)
                particle:SetGravity(Vector(-7, 3, 20))
                particle:SetColor(150, 150, 150)
            end
        end
    end

    self.SpawnTime = CurTime()
end

function EFFECT:PhysicsCollide(colData)
    if self.AlreadyPlayedSound then return end
    local phys = self:GetPhysicsObject()
    phys:SetVelocityInstantaneous(colData.HitNormal * -150)
    self:StopSound("Default.ImpactHard")

    sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 75, self.ShellPitch, 1)

    self.AlreadyPlayedSound = true
end

function EFFECT:Think()
    if self:GetVelocity():Length() > 20 then self.SpawnTime = CurTime() end
    self:StopSound("Default.ScrapeRough")
    
    if (self.SpawnTime + self.ShellTime) <= CurTime() then
        if !IsValid(self) then return end
        self:SetRenderFX( kRenderFxFadeFast )
        if (self.SpawnTime + self.ShellTime + 0.25) <= CurTime() then
            if !IsValid(self:GetPhysicsObject()) then return end
            self:GetPhysicsObject():EnableMotion(false)
            if (self.SpawnTime + self.ShellTime + 0.5) <= CurTime() then
                self:Remove()
                return
            end
        end
    end
    return true
end

function EFFECT:Render()
    if !IsValid(self) then return end
    self:DrawModel()
end

function EFFECT:DrawTranslucent()
    self:DrawModel()
end
