function SWEP:GetAttPos(slottbl, wm, idle)
    idle = idle or false
    local parentmdl = self:GetVM()

    if wm then
        if slottbl.WMBase then
            parentmdl = self:GetOwner()
        else
            parentmdl = self.WModel[1]
        end
    end

    if idle then
        parentmdl = ClientsideModel(self.ViewModel)
        parentmdl:SetPos(Vector(0, 0, 0))
        parentmdl:SetAngles(Angle(0, 0, 0))
        parentmdl:SetNoDraw(true)

        local anim = self:TranslateSequence("idle")
        local seq = parentmdl:LookupSequence(anim)

        parentmdl:ResetSequence(seq)
        parentmdl:SetPoseParameter("sights", 1)

        parentmdl:SetupBones()
    end

    local bone = slottbl.Bone
    local atttbl = {}

    if slottbl.WMBase then
        bone = "ValveBiped.Bip01_R_Hand"
    end

    if slottbl.Installed then
        atttbl = ARC9.GetAttTable(slottbl.Installed)
    end

    local offset_pos = slottbl.Pos or Vector(0, 0, 0)
    local offset_ang = slottbl.Ang or Angle(0, 0, 0)

    local boneindex = parentmdl:LookupBone(bone)

    if !boneindex then return Vector(0, 0, 0), Angle(0, 0, 0) end

    local bonemat = parentmdl:GetBoneMatrix(boneindex)
    if bonemat then
        bpos = bonemat:GetTranslation()
        bang = bonemat:GetAngles()
    end

    local apos, aang

    apos = bpos + bang:Forward() * offset_pos.x
    apos = apos + bang:Right() * offset_pos.y
    apos = apos + bang:Up() * offset_pos.z

    aang = Angle()
    aang:Set(bang)

    aang:RotateAroundAxis(aang:Right(), offset_ang.p)
    aang:RotateAroundAxis(aang:Up(), offset_ang.y)
    aang:RotateAroundAxis(aang:Forward(), offset_ang.r)

    local moffset = (atttbl.ModelOffset or Vector(0, 0, 0)) * (slottbl.Scale or 1)

    apos = apos + aang:Forward() * moffset.x
    apos = apos + aang:Right() * moffset.y
    apos = apos + aang:Up() * moffset.z

    if idle then
        SafeRemoveEntity(parentmdl)
    end

    return apos, aang
end

function SWEP:CreateAttachmentModel(wm, atttbl, slottbl)
    local model = atttbl.Model

    if wm and atttbl.WorldModel then
        model = atttbl.WorldModel
    end

    local csmodel = ClientsideModel(model)

    if !IsValid(csmodel) then return end

    csmodel:SetNoDraw(true)
    csmodel.atttbl = atttbl
    csmodel.slottbl = slottbl

    local scale = Matrix()
    local vec = Vector(1, 1, 1) * (atttbl.Scale or 1)
    vec = vec * (slottbl.Scale or 1)
    scale:Scale(vec)
    csmodel:EnableMatrix("RenderMultiply", scale)

    local tbl = {
        Model = csmodel,
        Weapon = self
    }

    table.insert(ARC9.CSModelPile, tbl)

    if wm then
        table.insert(self.WModel, csmodel)
    else
        table.insert(self.VModel, csmodel)
    end

    return csmodel
end

function SWEP:SetupModel(wm)
    self:KillModel()

    if !wm and !IsValid(self:GetOwner()) then return end

    if !wm then
        self.VModel = {}
    else
        self.WModel = {}

        local csmodel = ClientsideModel(self.MirrorModel or self.ViewModel)

        if !IsValid(csmodel) then return end

        csmodel:SetNoDraw(true)
        csmodel.atttbl = {}
        csmodel.slottbl = {
            WMBase = true,
            Pos = self.WorldModelOffset.Pos,
            Ang = self.WorldModelOffset.Ang
        }

        local scale = Matrix()
        local vec = Vector(1, 1, 1) * (self.WorldModelOffset.Scale or 1)
        scale:Scale(vec)
        csmodel:EnableMatrix("RenderMultiply", scale)

        local tbl = {
            Model = csmodel,
            Weapon = self
        }

        table.insert(ARC9.CSModelPile, tbl)

        table.insert(self.WModel, 1, csmodel)
    end

    self:DoBodygroups(wm)

    if !wm and self:GetOwner() != LocalPlayer() then return end

    for _, slottbl in pairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = ARC9.GetAttTable(slottbl.Installed)

        if !atttbl.Model then continue end

        local csmodel = self:CreateAttachmentModel(wm, atttbl, slottbl)

        if atttbl.MuzzleDevice then
            local slmodel = self:CreateAttachmentModel(wm, atttbl, slottbl)
            slmodel.IsMuzzleDevice = true
            slmodel.NoDraw = true
        end

        if wm then
            slottbl.WModel = csmodel
        else
            slottbl.VModel = csmodel
        end
    end

    if !wm then
        self:CreateFlashlightsVM()
    end
end

SWEP.VModel = nil
SWEP.WModel = nil

function SWEP:KillModel()
    for _, model in pairs(self.VModel or {}) do
        SafeRemoveEntity(model)
    end
    for _, model in pairs(self.WModel or {}) do
        SafeRemoveEntity(model)
    end

    self.VModel = nil
    self.WModel = nil
end