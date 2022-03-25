function SWEP:PreDrawViewModel()
    if ARC9.PresetCam then
        self:DoBodygroups(false)
        return
    end

    if self:GetCustomize() then
        if GetConVar("arc9_cust_blur"):GetBool() then DrawBokehDOF( 10, 1, 0.1 ) end

        cam.Start2D()
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        cam.End2D()
    end

    self:DoPoseParams()
    self:DoBodygroups(false)

    local bipodamount = self:GetBipodAmount()

    self:GetVM():SetPoseParameter("sights", math.max(self:GetSightAmount(), bipodamount))
    self:GetVM():InvalidateBoneCache()

    self.ViewModelFOV = self:GetViewModelFOV()

    if !GetConVar("ARC9_benchgun"):GetBool() then
        cam.Start3D(nil, nil, self:GetViewModelFOV(), nil, nil, nil, nil, 0.5, 10000)
    end

    -- self:DrawCustomModel(true, EyePos() + EyeAngles():Forward() * 16, EyeAngles())

    cam.IgnoreZ(true)
end

function SWEP:ViewModelDrawn()
    -- self:DrawLasers(false)
    self:DrawCustomModel(false)
    self:DoRHIK()
    self:PreDrawThirdArm()

    -- cam.Start3D(nil, nil, self:GetViewModelFOV(), 0, 0, ScrW(), ScrH(), 4, 30000)
    --     cam.IgnoreZ(true)
        self:DrawLasers(false)
    -- cam.End3D()

    -- cam.IgnoreZ(true)
end

function SWEP:PostDrawViewModel()
    if ARC9.PresetCam then return end

    cam.IgnoreZ(false)

    if !GetConVar("ARC9_benchgun"):GetBool() then
        cam.End3D()
    end

    cam.Start3D(nil, nil, self:GetViewModelFOV(), nil, nil, nil, nil, 1, 10000 )
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

    -- render.UpdateFullScreenDepthTexture()
end