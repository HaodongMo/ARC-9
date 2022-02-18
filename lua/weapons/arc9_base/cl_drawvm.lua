function SWEP:PreDrawViewModel()
    if ARC9.PresetCam then return end

    if self:GetCustomize() then
        if GetConVar("arc9_cust_blur"):GetBool() then DrawBokehDOF( 10, 1, 0.1 ) end

        cam.Start2D()
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        cam.End2D()
    end

    self:DoBodygroups(false)

    -- local bipodamount = (self:GetBipod() and 1) or 0

    -- self:SetFiremodePose()
    self:GetVM():SetPoseParameter("sights", self:GetSightAmount())
    self:GetVM():InvalidateBoneCache()

    self.ViewModelFOV = self:GetViewModelFOV()

    if !GetConVar("ARC9_benchgun"):GetBool() then
        cam.Start3D(nil, nil, self:GetViewModelFOV(), nil, nil, nil, nil, 0.5, 512)
    end

    cam.IgnoreZ(true)
end

function SWEP:PostDrawViewModel()
    if ARC9.PresetCam then return end

    cam.IgnoreZ(false)

    if !GetConVar("ARC9_benchgun"):GetBool() then
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