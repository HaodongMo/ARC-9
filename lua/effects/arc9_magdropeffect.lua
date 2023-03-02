EFFECT.Type = 1

EFFECT.Model = "models/food/hotdog.mdl"

EFFECT.AlreadyPlayedSound = false
EFFECT.LifeTime = 3
EFFECT.SpawnTime = 0


function EFFECT:Init(data)
    local att = data:GetAttachment()
    local ent = data:GetEntity()

    if !IsValid(ent) then self:Remove() return end
    if !IsValid(ent:GetOwner()) then self:Remove() return end

    if LocalPlayer():ShouldDrawLocalPlayer() or ent:GetOwner() != LocalPlayer() then
        mdl = (ent.WModel or {})[1] or ent
        -- att = 2
    else
        mdl = LocalPlayer():GetViewModel()
    end

    if !IsValid(ent) then self:Remove() return end
    if !mdl or !IsValid(mdl) then self:Remove() return end
    if !mdl:GetAttachment(att) then self:Remove() return end

    local origin, ang = mdl:GetAttachment(att).Pos, mdl:GetAttachment(att).Ang

    local model = ent:GetProcessedValue("DropMagazineModel")
    local skinn = ent:GetProcessedValue("DropMagazineSkin")
    local sounds = ent:GetProcessedValue("DropMagazineSounds")

    local dir = ang:Forward()

    local correctpos = ent:GetProcessedValue("DropMagazinePos") or vector_origin
    local correctang = ent:GetProcessedValue("DropMagazineAng") or angle_zero
    ang:RotateAroundAxis(ang:Forward(), correctang.p)
    ang:RotateAroundAxis(ang:Right(), 90 + correctang.y)
    ang:RotateAroundAxis(ang:Up(), 90 + correctang.r)

    origin:Add(ang:Right() * correctpos.x)
    origin:Add(ang:Up() * correctpos.y)
    origin:Add(ang:Forward() * correctpos.z)

    self:SetPos(origin)
    self:SetModel(model or "")
    self:SetSkin(skinn)
    self:DrawShadow(true)
    self:SetAngles(ang)

    self.Sounds = sounds or ARC9.ShellSoundsTable

    -- self:SetSolid( SOLID_BBOX )
    -- self:SetMoveType( MOVETYPE_VPHYSICS )
    self:PhysicsInit(SOLID_VPHYSICS)
    -- local physbox = ent:GetProcessedValue("ShellPhysBox")

    -- local pb_z = physbox.z
    -- local pb_y = physbox.y
    -- local pb_x = physbox.x

    -- -- local mag = 150

    -- self:PhysicsInitBox(Vector(-pb_z,-pb_y,-pb_x), Vector(pb_z,pb_x,pb_y))

    -- self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local phys = self:GetPhysicsObject()
    if !IsValid(phys) then self:Remove() return end
    phys:Wake()

    local plyvel = vector_origin

    if IsValid(ent.Owner) then
        plyvel = ent.Owner:GetAbsVelocity()
    end

    -- phys:SetDamping(0, 0)
    -- phys:SetMass(1)
    phys:SetMaterial("gmod_silent")
    -- phys:SetMaterial("default_silent")

    local velocity = ent:GetProcessedValue("DropMagazineVelocity") or Vector(0, 0, 0)

    -- phys:SetVelocity((dir * mag * velocity) + plyvel)
    dir:Add(ang:Right() * velocity.x)
    dir:Add(ang:Up() * velocity.y)
    dir:Add(ang:Forward() * velocity.z)

    phys:SetVelocity(dir + plyvel)

    phys:AddAngleVelocity(VectorRand() * 10)
    -- phys:AddAngleVelocity(ang:Up() * 2500 * velocity/0.75)

    self.SpawnTime = CurTime()
end

function EFFECT:PhysicsCollide()
    if self.AlreadyPlayedSound then return end
    local phys = self:GetPhysicsObject()
    self:StopSound("Default.ImpactHard")

    local snd = self.Sounds[math.random(#self.Sounds)]
    if snd then sound.Play(snd, self:GetPos(), 75, 100, 1) end

    self.AlreadyPlayedSound = true
end

function EFFECT:Think()
    if self:GetVelocity():Length() > 20 then self.SpawnTime = CurTime() end
    self:StopSound("Default.ScrapeRough")
    
    if (self.SpawnTime + self.LifeTime) <= CurTime() then
        if !IsValid(self) then return end
        self:SetRenderFX( kRenderFxFadeFast )
        if (self.SpawnTime + self.LifeTime + 0.25) <= CurTime() then
            if !IsValid(self:GetPhysicsObject()) then return end
            self:GetPhysicsObject():EnableMotion(false)
            if (self.SpawnTime + self.LifeTime + 0.5) <= CurTime() then
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
