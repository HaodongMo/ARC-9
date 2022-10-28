function SWEP:ShouldLOD()
    if LocalPlayer() == self:GetOwner() then return 0 end

    local dsquared

    if IsValid(self:GetOwner()) then
        dsquared = EyePos():DistToSqr(self:GetOwner():GetPos())
    else
        dsquared = EyePos():DistToSqr(self:GetPos())
    end

    if dsquared >= 25000000 then
        return 2
    elseif dsquared >= 4000000 then
        return 1
    else
        return 0
    end
end

function SWEP:DrawCustomModel(wm, custompos, customang)
    if !wm and !IsValid(self:GetOwner()) then return end
    if !wm and self:GetOwner():IsNPC() then return end
    if custompos then wm = true end

    local mdl = self.VModel
    local lod = 0

    if wm then
        if custompos then
            mdl = self.CModel
        else
            mdl = self.WModel
            lod = self:ShouldLOD()
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

    if lod < 2 then
        for _, model in ipairs(mdl or {}) do
            local slottbl = model.slottbl
            local atttbl = self:GetFinalAttTable(slottbl)

            if model.charmparent then
                continue
            else
                local apos, aang = self:GetAttPos(slottbl, wm, false, false, custompos, customang or Angle(0, 0, 0))

                if model.IsAnimationProxy then
                    apos = Vector(0, 0, 0)
                    aang = Angle(0, 0, 0)
                end

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

            if !model.NoDraw then
                model:DrawModel()
            end

            if model.Flare and !self:GetCustomize() then
                if model.Flare.Attachment then
                    local attpos = model:GetAttachment(model.Flare.Attachment)

                    if attpos then
                        self:DrawLightFlare(attpos.Pos, -attpos.Ang:Right(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
                    else
                        self:DrawLightFlare(apos, aang:Forward(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
                    end
                else
                    self:DrawLightFlare(apos, aang:Forward(), model.Flare.Color, model.Flare.Size, model.Flare.Focus)
                end
            end

            if atttbl.DrawFunc then
                atttbl.DrawFunc(self, model, wm)
            end
        end

        if wm then
            self:DrawFlashlightsWM()
        else
            self:DrawFlashlightsVM()
        end
    end
end

function SWEP:GetActiveSightSlotTable()
    local sight = self:GetSight() or {}

    return sight.slottbl or {}
end