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

function SWEP:DrawCustomModel(wm)
    if !wm and !IsValid(self:GetOwner()) then return end
    if !wm and self:GetOwner():IsNPC() then return end

    local mdl = self.VModel
    local lod = 0

    if wm then
        mdl = self.WModel
        lod = self:ShouldLOD()

        if lod >= 2 then
            self:KillModel()
            self:DrawModel()
            return
        end
    end

    if !mdl then
        self:SetupModel(wm, lod)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
        end
    end

    if lod < 2 then
        for _, model in pairs(mdl) do
            local slottbl = model.slottbl
            local atttbl = self:GetFinalAttTable(slottbl)

            local apos, aang = self:GetAttPos(slottbl, wm)

            model:SetPos(apos)
            model:SetAngles(aang)
            model:SetRenderOrigin(apos)
            model:SetRenderAngles(aang)

            -- if !wm and atttbl.HoloSight then
            --     self:DoHolosight(model, atttbl)
            -- end

            if !ARC9.PresetCam then
                if atttbl.DrawFunc then
                    atttbl.DrawFunc(self, model, wm)
                end

                if !wm and atttbl.RTScope then
                    self:DoRTScope(model, atttbl)
                end
            end

            if !model.NoDraw then
                model:DrawModel()
            end
        end

        if !wm then
            self:DrawFlashlightsVM()
        end
    end
end