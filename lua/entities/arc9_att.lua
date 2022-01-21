ENT.Type                  = "anim"
ENT.Base                  = "base_entity"
ENT.PrintName             = "Base Dropped Attachment"
ENT.Author                = ""
ENT.Information           = ""

ENT.Spawnable             = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Category              = "ARC-9 - Attachments"

AddCSLuaFile()

ENT.GiveAttachments = nil -- table of all the attachments to give, and in what quantity. {{["id"] = int quantity}}

ENT.SoundImpact = "weapon.ImpactSoft"
ENT.Model = ""

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

    //if GetConVar("arc9_attinv_free"):GetBool() then return end

    local take = false

    for i, k in pairs(self.GiveAttachments) do
        if i == "BaseClass" then continue end

        /*if GetConVar("arc9_attinv_lockmode"):GetBool() then
            if ArcCW:PlayerGetAtts(caller, i) > 0 then
                continue
            end
        end*/

        if hook.Run("Arc9_PickupAttEnt", caller, i, k) then continue end

        ARC9:PlayerGiveAtt(caller, i, k)

        take = true
    end

    if take then
        ARC9:PlayerSendAttInv(caller)

        self:EmitSound("weapons/arc9/useatt.wav")
        self:Remove()
    end
end

else

//local defaulticon = Material("arccw/hud/atts/default.png")


function ENT:DrawTranslucent()

    self:Draw()

end

function ENT:Draw()
    self:DrawModel()

    //if !GetConVar("arc9_2d3d"):GetBool() then return end

    /*if self.PrintName == "Base Dropped Attachment" and self:GetNWInt("attid", -1) != -1 then
        local att = Arc9.AttachmentIDTable[self:GetNWInt("attid", -1)]

        if !att then return end

        local atttbl = Arc9.AttachmentTable[att]

        if !atttbl then return end

        self.PrintName = atttbl.PrintName or att
        self.Icon = atttbl.Icon// or defaulticon
    end*/

    if (EyePos() - self:WorldSpaceCenter()):LengthSqr() <= 262144 then -- 512^2
        local ang = LocalPlayer():EyeAngles()

        ang:RotateAroundAxis(ang:Forward(), 180)
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), 90)

        cam.Start3D2D(self:WorldSpaceCenter() + Vector(0, 0, 16), ang, 0.1)
            surface.SetFont("Default")

            local w = surface.GetTextSize(self.PrintName)

            surface.SetTextPos(-w / 2, 0)
            surface.SetTextColor(255, 255, 255, 255)
            surface.DrawText(self.PrintName)

            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(self.Icon or defaulticon)
            local iw = 64
            surface.DrawTexturedRect(-iw / 2, -iw - 8, iw, iw)
        cam.End3D2D()
    end
end

end