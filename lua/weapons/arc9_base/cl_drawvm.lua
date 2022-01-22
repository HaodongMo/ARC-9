function SWEP:PreDrawViewModel()
    if ARC9.PresetCam then return end

    self:DoRHIK()

    if self:GetCustomize() then
        if GetConVar("arc9_cust_blur"):GetBool() then DrawBokehDOF( 10, 1, 0.1 ) end

        cam.Start2D()
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        cam.End2D()
    end

    self:DoBodygroups(false)

    -- self:SetFiremodePose()
    self:GetVM():SetPoseParameter("sights", self:GetSightAmount())

    self.ViewModelFOV = self:GetViewModelFOV()

    if GetConVar("ARC9_benchgun"):GetBool() then
        cam.Start3D()
    else
        cam.Start3D(nil, nil, self:GetViewModelFOV(), nil, nil, nil, nil, 1, 512)
    end

    cam.IgnoreZ(true)
end

function SWEP:PostDrawViewModel()
    if ARC9.PresetCam then return end

    cam.IgnoreZ(false)

    if GetConVar("ARC9_benchgun"):GetBool() then
        cam.End3D()
    else
        cam.End3D()
    end

    cam.Start3D(nil, nil, self:GetViewModelFOV())
    for _, model in pairs(self.VModel) do
        local slottbl = model.slottbl
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.HoloSight then
            cam.IgnoreZ(true)
            self:DoHolosight(model, atttbl)
            cam.IgnoreZ(false)
        end
    end
    cam.End3D()
end

function SWEP:ViewModelDrawn()
    self:DrawCustomModel(false)
    self:DrawLasers(false)
    -- self:DrawLasers()
end

function SWEP:DrawCustomModel(wm)

    if !wm and !IsValid(self:GetOwner()) then return end
    if !wm and self:GetOwner():IsNPC() then return end

    local mdl = self.VModel

    if wm then
        mdl = self.WModel
    end

    if !mdl then
        self:SetupModel(wm)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
        end
    end

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