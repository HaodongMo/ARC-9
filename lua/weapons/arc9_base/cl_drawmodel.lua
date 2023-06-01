function SWEP:ShouldLOD()
    local owner = self:GetOwner()
    if LocalPlayer() == owner then return 0 end

    local dsquared

    if IsValid(owner) then
        dsquared = EyePos():DistToSqr(owner:GetPos())
    else
        dsquared = EyePos():DistToSqr(self:GetPos()) * 2 -- make lod appear sooner on dropped gunss
    end

    if dsquared >= 800000 then
        return 2
    elseif dsquared >= 400000 then
        return 1.5
    elseif dsquared >= 200000 then -- middle value for tpik lod
        return 1
    else
        return 0
    end
end

function SWEP:DrawCustomModel(wm, custompos, customang)
    local owner = self:GetOwner()

    if !wm and !IsValid(owner) then return end
    if !wm and owner:IsNPC() then return end
    if custompos then wm = true end

    local mdl = self.VModel
    local lod = 0

    if wm then
        if custompos then
            mdl = self.CModel
        else
            mdl = self.WModel
            lod = self:ShouldLOD()
            
            if mdl and mdl[1]:IsValid() then 
                mdl[1]:SetMaterial(self:GetProcessedValue("Material", true)) 
            end
        end

        if lod >= 2 then
            self:DrawModel()
            return
        end
    end

    if !mdl then
        self:SetupModel(wm, lod, !!custompos)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
            if custompos then
                mdl = self.CModel
            end
        end
    end

    local onground = wm and !IsValid(owner)

    local hidebones = self:GetHiddenBones(wm)

    if lod < 2 then
        for _, model in ipairs(mdl or {}) do
            if model.IsAnimationProxy then continue end
            local slottbl = model.slottbl
            local atttbl = self:GetFinalAttTable(slottbl)

            if !onground or model.OptimizPrevWMPos != self:GetPos() then -- mega optimiz
                model.OptimizPrevWMPos = onground and self:GetPos() or nil

                if model.charmparent then
                    continue
                else
                    if hidebones[slottbl.Bone or -1] then
                        continue
                    end

                    if model.Duplicate then
                        local duplitbl = (slottbl.DuplicateModels or {})[model.Duplicate]

                        if hidebones[(duplitbl or {}).Bone or -1] then
                            continue
                        end
                    end

                    local apos, aang = self:GetAttachmentPos(slottbl, wm, false, false, custompos, customang or angle_zero, model.Duplicate)
                    model:SetPos(apos)
                    model:SetAngles(aang)
                    model:SetRenderOrigin(apos)
                    model:SetRenderAngles(aang)
                    model:SetupBones()

                    if model.charmmdl then
                        local bpos, bang

                        local bonename = atttbl.CharmBone
                        local boneindex = model:LookupBone(bonename)

                        local bonemat = model:GetBoneMatrix(boneindex)
                        if bonemat then
                            bpos = bonemat:GetTranslation()
                            bang = bonemat:GetAngles()
                        end

                        if bpos and bang then
                            local coffset = atttbl.CharmOffset or Vector(0, 0, 0)
                            local cangle = atttbl.CharmAngle or Angle(0, 0, 0)

                            bpos = bpos + bang:Forward() * coffset.y
                            bpos = bpos + bang:Up() * coffset.z
                            bpos = bpos + bang:Right() * coffset.x

                            local up, right, forward = bang:Up(), bang:Right(), bang:Forward()

                            bang:RotateAroundAxis(up, cangle.p)
                            bang:RotateAroundAxis(right, cangle.y)
                            bang:RotateAroundAxis(forward, cangle.r)

                            model.charmmdl:SetPos(bpos)
                            model.charmmdl:SetAngles(bang)
                            model.charmmdl:SetupBones()
                            model.charmmdl:DrawModel()
                        end
                    end
                end

                -- if !wm and atttbl.HoloSight then
                --     self:DoHolosight(model, atttbl)
                -- end

                if !ARC9.PresetCam then
                    if !wm and atttbl.RTScope then
                        local active = slottbl.Address == self:GetActiveSightSlotTable().Address
                        self:DoRTScope(model, atttbl, active)
                    elseif wm and atttbl.RTScope then
                        self:DoRTScope(model, atttbl, false)
                    end
                end
            end

            model.CustomCamoTexture = self:GetProcessedValue("CustomCamoTexture")
            model.CustomCamoScale = self:GetProcessedValue("CustomCamoScale")
            model.CustomBlendFactor = self:GetProcessedValue("CustomBlendFactor")


            if !model.NoDraw then
                model:DrawModel()
            end

            if atttbl.DrawFunc then
                atttbl.DrawFunc(self, model, wm)
            end

        --     -- if model.Flare and !self:GetCustomize() then
        --     --     if model.Flare.Attachment then
        --     --         local attpos = model:GetAttachment(model.Flare.Attachment)

        --     --         if attpos then
        --     --             self:DrawLightFlare(attpos.Pos, -attpos.Ang:Right(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
        --     --         else
        --     --             self:DrawLightFlare(apos, aang:Forward(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
        --     --         end
        --     --     else
        --     --         self:DrawLightFlare(apos, aang:Forward(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
        --     --     end
        --     -- end
        end
    end
end

function SWEP:GetActiveSightSlotTable()
    local sight = self:GetSight() or {}

    return sight.slottbl or {}
end
