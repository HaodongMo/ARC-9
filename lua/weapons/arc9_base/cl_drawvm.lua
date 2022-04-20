function SWEP:PreDrawViewModel()
    if ARC9.PresetCam then
        self:DoBodygroups(false)
        return
    end

    local custdelta = self.CustomizeDelta

    if custdelta > 0 then
        if GetConVar("arc9_cust_blur"):GetBool() then DrawBokehDOF( 10*custdelta, 1, 0.1 ) end

        cam.Start2D()
            surface.SetDrawColor(0, 0, 0, 220*custdelta)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        cam.End2D()
    end

    if GetConVar("arc9_cust_light"):GetBool() and self:GetCustomize() then -- we also maybe can make some button in cust to turn on/off lights :^)
        render.SuppressEngineLighting( true )
        render.ResetModelLighting(0.6, 0.6, 0.6)
        render.SetModelLighting(BOX_TOP, 4, 4, 4)
    else
        render.SuppressEngineLighting( false )
        render.ResetModelLighting(1,1,1)
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

    self:GetVM():SetSubMaterial()

    if self:GetHolster_Time() < CurTime() and self.RTScope and self:GetSightAmount() > 0 then
        self:DoRTScope(self:GetVM(), self:GetTable(), self:GetSightAmount() > 0)
    end

    self:GetVM():SetMaterial(self:GetProcessedValue("Material"))

    cam.IgnoreZ(true)

    if self:GetSightAmount() > 0.75 and self:GetSight().FlatScope and !self:GetSight().FlatScopeKeepVM then
        render.SetBlend(0)
    end
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
    render.SetBlend(1)

    if !GetConVar("ARC9_benchgun"):GetBool() then
        cam.End3D()
    end

    cam.Start3D(nil, nil, self:GetViewModelFOV(), nil, nil, nil, nil, 1, 10000 )
    for _, model in ipairs(self.VModel) do
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