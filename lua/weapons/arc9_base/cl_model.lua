function SWEP:GetAttPos(slottbl, wm, idle, nomodeloffset, custompos, customang)
    idle = idle or false
    local parentmdl = nil
    if custompos then wm = true end

    if wm then
        if slottbl.WMBase then
            parentmdl = self:GetOwner()

            if !IsValid(parentmdl) then
                parentmdl = self
            end

            if custompos then
                parentmdl = nil
            end
        else
            if custompos then
                parentmdl = self.CModel[1]
                parentmdl:SetupBones()
            else
                parentmdl = self.WModel[1]
            end
        end
    else
        parentmdl = self:GetVM()
    end

    if idle then
        parentmdl = ClientsideModel(self.ViewModel)
        parentmdl:SetPos(Vector(0, 0, 0))
        parentmdl:SetAngles(ARC9_ANGLEZERO)
        parentmdl:SetNoDraw(true)

        local anim = self:TranslateAnimation("idle")
        local ae = self:GetAnimationEntry(anim)
        local seq = parentmdl:LookupSequence(self:RandomChoice(ae.Source))

        parentmdl:ResetSequence(seq)
        parentmdl:SetPoseParameter("sights", 1)

        parentmdl:SetupBones()
        parentmdl:InvalidateBoneCache()
    end

    local bone = slottbl.Bone
    local atttbl = {}

    if slottbl.WMBase then
        bone = "ValveBiped.Bip01_R_Hand"

        -- if self:ShouldTPIK() then
        --     bone = "ValveBiped.Bip01_Head1"
        -- end
    end

    if slottbl.Installed then
        atttbl = ARC9.GetAttTable(slottbl.Installed)
    end

    local offset_pos = slottbl.Pos or Vector(0, 0, 0)
    local offset_ang = slottbl.Ang or Angle(0, 0, 0)
    local bpos, bang

    if parentmdl then
        local boneindex = parentmdl:LookupBone(bone)

        if !boneindex then return Vector(0, 0, 0), ARC9_VECTORZERO end

        if parentmdl == self:GetOwner() then
            parentmdl:SetupBones()
            parentmdl:InvalidateBoneCache()
        end
        local bonemat = parentmdl:GetBoneMatrix(boneindex)
        if bonemat then
            bpos = bonemat:GetTranslation()
            bang = bonemat:GetAngles()
        end
    elseif custompos then
        bpos = custompos
        bang = customang or Angle(0, 0, 0)
    end

    if slottbl.OriginalAddress then
        local eles = self:GetElements()

        for i, k in pairs(eles) do
            local ele = self.AttachmentElements[i]

            if !ele then continue end

            local mods = ele.AttPosMods or {}

            if mods[slottbl.OriginalAddress] then
                offset_pos = mods[slottbl.OriginalAddress].Pos or offset_pos
                offset_ang = mods[slottbl.OriginalAddress].Ang or offset_ang
            end
        end
    end

    local attachmentPos = Vector(bpos)
    local attachmentAng = Angle(bang)

    attachmentPos:Add(attachmentAng:Forward() * offset_pos.x)
    attachmentPos:Add(attachmentAng:Right() * offset_pos.y)
    attachmentPos:Add(attachmentAng:Up() * offset_pos.z)

    if !nomodeloffset then
        offset_ang = offset_ang + (atttbl.ModelAngleOffset or Angle(0, 0, 0))
    end

    -- attachmentAng:Set(bang)
    attachmentAng:RotateAroundAxis(attachmentAng:Right(), offset_ang.p)
    attachmentAng:RotateAroundAxis(attachmentAng:Up(), offset_ang.y)
    attachmentAng:RotateAroundAxis(attachmentAng:Forward(), offset_ang.r)

    if !nomodeloffset then
        local moffset = (atttbl.ModelOffset or Vector(0, 0, 0)) * (slottbl.Scale or 1)

        attachmentPos:Add(attachmentAng:Forward() * moffset.x)
        attachmentPos:Add(attachmentAng:Right() * moffset.y)
        attachmentPos:Add(attachmentAng:Up() * moffset.z)
    end

    if idle then
        SafeRemoveEntity(parentmdl)
    end

    return attachmentPos, attachmentAng
end

function SWEP:CreateAttachmentModel(wm, atttbl, slottbl, ignorescale, cm)
    ignorescale = ignorescale or false

    local model = atttbl.Model

    if wm and atttbl.WorldModel then
        model = atttbl.WorldModel
    end

    local csmodel = ClientsideModel(model)

    if !IsValid(csmodel) then return end

    csmodel:SetNoDraw(true)
    csmodel.atttbl = atttbl
    csmodel.slottbl = slottbl

    if !ignorescale then
        local scale = Matrix()
        -- Is this double multiplication accidental? wtf??
        -- local vec = Vector(1, 1, 1) * (atttbl.Scale or 1)
        -- vec = vec * (slottbl.Scale or 1)
        local vec = Vector(1, 1, 1) * (atttbl.Scale or 1) * (slottbl.Scale or 1)
        scale:Scale(vec)
        csmodel:EnableMatrix("RenderMultiply", scale)
    end

    local tbl = {
        Model = csmodel,
        Weapon = self
    }

    table.insert(ARC9.CSModelPile, tbl)

    if cm then
        table.insert(self.CModel, csmodel)
    else
        if wm then
            table.insert(self.WModel, csmodel)
        else
            table.insert(self.VModel, csmodel)
        end
    end

    return csmodel
end

SWEP.LHIKModel = nil
SWEP.LHIK_Priority = -1000
SWEP.RHIKModel = nil
SWEP.RHIK_Priority = -1000
SWEP.LHIKModelWM = nil
SWEP.RHIKModelWM = nil

function SWEP:SetupModel(wm, lod, cm)
    lod = lod or 0
    if !wm then lod = 0 end
    if cm then wm = true end

    self:KillModel(cm)

    if !wm and !IsValid(self:GetOwner()) then return end

    self.LHIK_Priority = -1000
    self.RHIK_Priority = -1000

    local mdl = {}

    if !wm then
        self.VModel = mdl
        self.LHIKModel = nil
        self.RHIKModel = nil

        -- local RenderOverrideFunction = function(self2)
        --     if LocalPlayer():GetActiveWeapon() != self then LocalPlayer():GetViewModel().RenderOverride = nil return end
        --     if !IsValid(self) then LocalPlayer():GetViewModel().RenderOverride = nil return end

        --     self:SetFiremodePose()
        --     self2:DrawModel()
        -- end

        -- local vm = self:GetVM()

        -- vm.RenderOverride = RenderOverrideFunction
    else
        if cm then
            self.CModel = mdl
        else
            self.LHIKModelWM = nil
            self.RHIKModelWM = nil
            self.WModel = mdl
        end

        local csmodel = ClientsideModel(self.WorldModelMirror or self.ViewModel)

        if !IsValid(csmodel) then return end

        csmodel:SetNoDraw(true)
        csmodel.atttbl = {}

        if cm then
            csmodel.slottbl = {
                WMBase = true,
                Pos = Vector(0, 0, 0),
                Ang = Angle(0, 0, 0)
            }
        else
            csmodel.slottbl = {
                WMBase = true,
                Pos = self.WorldModelOffset.Pos,
                Ang = self.WorldModelOffset.Ang
            }
        end

        local scale = Matrix()
        local vec = Vector(1, 1, 1) * (self.WorldModelOffset.Scale or 1)
        scale:Scale(vec)
        csmodel:EnableMatrix("RenderMultiply", scale)

        local tbl = {
            Model = csmodel,
            Weapon = self
        }

        table.insert(ARC9.CSModelPile, tbl)

        table.insert(mdl, 1, csmodel)
    end

    if !wm and self:GetOwner() != LocalPlayer() then return end
    if lod > 0 then return end

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = ARC9.GetAttTable(slottbl.Installed)

        if !atttbl.Model then continue end

        local csmodel = self:CreateAttachmentModel(wm, atttbl, slottbl, false, cm)

        if atttbl.MuzzleDevice and !cm then
            local slmodel = self:CreateAttachmentModel(wm, atttbl, slottbl)
            slmodel.IsMuzzleDevice = true
            slmodel.NoDraw = true
        end

        if !cm then
            if wm then
                slottbl.WModel = csmodel
            else
                slottbl.VModel = csmodel
            end
        end

        if !cm and atttbl.LHIK or atttbl.RHIK then
            local proxmodel = self:CreateAttachmentModel(wm, atttbl, slottbl, true)
            proxmodel.NoDraw = true

            if atttbl.LHIK then
                if (atttbl.LHIK_Priority or 0) > self.LHIK_Priority then
                    self.LHIK_Priority = atttbl.LHIK_Priority or 0
                    if wm then
                        self.LHIKModelWM = proxmodel
                    else
                        self.LHIKModel = proxmodel
                    end
                end
            elseif atttbl.RHIK then
                if (atttbl.RHIK_Priority or 0) > self.RHIK_Priority then
                    self.RHIK_Priority = atttbl.RHIK_Priority or 0
                    if wm then
                        self.RHIKModelWM = proxmodel
                    else
                        self.RHIKModel = proxmodel
                    end
                end
            end
        end
    end

    if !wm then
        self:CreateFlashlightsVM()
    end

    self:DoBodygroups(wm, cm)
end

SWEP.VModel = nil
SWEP.WModel = nil
SWEP.CModel = nil

function SWEP:KillModel(cmo)
    if cmo then
        for _, model in ipairs(self.CModel or {}) do
            SafeRemoveEntity(model)
        end

        self.CModel = nil

        return
    end

    for _, model in ipairs(self.VModel or {}) do
        SafeRemoveEntity(model)
    end
    for _, model in ipairs(self.WModel or {}) do
        SafeRemoveEntity(model)
    end

    self.VModel = nil
    self.WModel = nil
end