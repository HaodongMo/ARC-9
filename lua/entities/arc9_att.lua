ENT.Type                  = "anim"
ENT.Base                  = "base_entity"
ENT.PrintName             = "Dropped Attachment"
ENT.Author                = ""
ENT.Information           = ""

ENT.Spawnable             = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Category              = "ARC9 - Attachments"

AddCSLuaFile()

ENT.GiveAttachments = nil -- table of all the attachments to give, and in what quantity. {{["id"] = int quantity}}

ENT.SoundImpact = "weapon.ImpactSoft"
ENT.Model = "models/items/att_plastic_box.mdl"

if SERVER then

function ENT:Initialize()
    if !self.Model then
        self:Remove()
        return
    end

    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetTrigger( true )
    self:SetPos(self:GetPos() + Vector(0, 0, 4))
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetBuoyancyRatio(0)
    end
end

function ENT:PhysicsCollide(colData, collider)
    if colData.DeltaTime < 0.25 then return end

    self:EmitSound(self.SoundImpact)
end

function ENT:Use(activator, caller)
    if !caller:IsPlayer() then return end

    if GetConVar("arc9_free_atts"):GetBool() then return end

    local take = false

    for i, k in pairs(self.GiveAttachments) do
        if i == "BaseClass" then continue end

        if GetConVar("arc9_lock_atts"):GetBool() then
            if ARC9:PlayerGetAtts(caller, i) > 0 then
                continue
            end
        end

        if hook.Run("ARC9_PickupAttEnt", caller, i, k) then continue end

        ARC9:PlayerGiveAtt(caller, i, k)

        take = true
    end

    if take then
        ARC9:PlayerSendAttInv(caller)

        self:EmitSound("weapons/ARC9/useatt.wav")
        self:Remove()
    end
end

else

function ENT:DrawTranslucent()
    self:Draw()
end

function ENT:Draw()
    self:DrawModel()
end

end