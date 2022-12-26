local vignette = Material("arc9/bgvignette.png", "mips smooth")
-- local vignette2 = Material("arc9/bgvignette2.png", "mips smooth")


local adsblur = Material("pp/arc9/adsblur")
local function arc9toytown(amount) -- cool ass blur
    if amount > 0 then
        local scrw, scrh = ScrW(), ScrH()
        cam.Start2D()
            surface.SetMaterial(adsblur)
            surface.SetDrawColor(255, 255, 255, 255)
            
            for i = 1, 5 * amount do -- 5 looking pretty cool
                render.CopyRenderTargetToTexture(render.GetScreenEffectTexture())
                surface.DrawTexturedRect(scrw*.5-scrh*.5, scrh*.58, scrh, scrh*0.42)
            end
        cam.End2D()
    end
end

local bluramt = 0

function SWEP:PreDrawViewModel()
    if ARC9.PresetCam then
        self:DoBodygroups(false)
        return
    end


    local getsights = self:GetSight()
    local sightamount = self:GetSightAmount()

    local blurtarget = 0

    local blurenable = GetConVar("arc9_fx_rtblur"):GetBool()

    local shouldrtblur = sightamount > 0 and blurenable and !input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) and getsights.atttbl and getsights.atttbl.RTScope and !getsights.Disassociate and !getsights.atttbl.RTCollimator and !getsights.atttbl.RTScopeNoBlur

    if shouldrtblur then
        blurtarget = 2 * sightamount
    end

    if GetConVar("arc9_fx_reloadblur"):GetBool() then
        if self:GetReloading() then
            blurtarget = 1.5
        elseif !self:GetReady() and GetConVar("arc9_fx_animblur"):GetBool() then
            blurtarget = 1.5
        end
    end

    local custdelta = self.CustomizeDelta

    if custdelta > 0 then
        if GetConVar("arc9_cust_blur"):GetBool() then
            blurtarget = 5 * custdelta
        end

        cam.Start2D()
            surface.SetDrawColor(0, 0, 0, 180 * custdelta)
            surface.DrawRect(0, 0, ScrW(), ScrH())
            surface.SetDrawColor(0, 0, 0, 255 * custdelta)
            surface.SetMaterial(vignette)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        cam.End2D()
    end

    if blurenable then
        DrawBokehDOF(bluramt, 1, 0)
    end

    bluramt = math.Approach(bluramt, blurtarget, FrameTime() * 10)

    if GetConVar("arc9_cust_light"):GetBool() and self:GetCustomize() then
        -- render.SuppressEngineLighting(true)
        -- render.ResetModelLighting(0.6, 0.6, 0.6)
        -- render.SetModelLighting(BOX_TOP, 4, 4, 4)
        local light = DynamicLight(self:EntIndex(), true)
        light.pos = EyePos() + (EyeAngles():Up() * 12)
        light.r = 255
        light.g = 255
        light.b = 255
        light.brightness = 0.2 * (GetConVar("arc9_cust_light_brightness"):GetFloat())
        light.Decay = 1000
        light.Size = 500
        light.DieTime = CurTime() + 0.1
    -- else
    --     render.SuppressEngineLighting(false)
    --     render.ResetModelLighting(1,1,1)
    end

    self:DoPoseParams()
    self:DoBodygroups(false)

    local bipodamount = self:GetBipodAmount()
    local vm = self:GetVM()

    vm:SetPoseParameter("sights", math.max(sightamount, bipodamount))
    if self:GetValue("BoneMods") then for i, k in pairs(self:GetValue("BoneMods")) do
        local boneindex = vm:LookupBone(i)

        if !boneindex then continue end

        vm:ManipulateBonePosition(boneindex, k.pos or vector_origin)
        vm:ManipulateBoneAngles(boneindex, k.ang or angle_zero)
        vm:ManipulateBoneScale(boneindex, k.scale or vector_origin)
    end end
    vm:InvalidateBoneCache()

    local vmfov = self:GetViewModelFOV()

    self.ViewModelFOV = vmfov

    if !GetConVar("arc9_dev_benchgun"):GetBool() then
        cam.Start3D(nil, nil, self:WidescreenFix(vmfov), nil, nil, nil, nil, 0.5, 10000)
    end

    -- self:DrawCustomModel(true, EyePos() + EyeAngles():Forward() * 16, EyeAngles())

    vm:SetSubMaterial()

    if self:GetHolsterTime() < CurTime() and self.RTScope and sightamount > 0 then
        self:DoRTScope(vm, self:GetTable(), ssightamount > 0)
    end

    vm:SetMaterial(self:GetProcessedValue("Material"))

    cam.IgnoreZ(true)

    self:SetFiremodePose()
    vm:SetPoseParameter("sights", math.max(sightamount, bipodamount))

    if sightamount > 0.75 and getsights.FlatScope and !getsights.FlatScopeKeepVM then
        render.SetBlend(0)
    end
end

function SWEP:ViewModelDrawn()
    -- self:DrawLasers(false)
    self:DrawCustomModel(false)
    self:DoRHIK()
    self:PreDrawThirdArm()

    -- cam.Start3D(nil, nil, self:WidescreenFix(self:GetViewModelFOV()), 0, 0, ScrW(), ScrH(), 4, 30000)
    --     cam.IgnoreZ(true)
        self:DrawLasers(false)
    -- cam.End3D()

    -- cam.IgnoreZ(true)
    -- local custdelta = self.CustomizeDelta
    -- cam.Start2D()
    --     surface.SetDrawColor(0, 0, 0, 230 * custdelta)
    --     surface.SetMaterial(vignette2)
    --     surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    -- cam.End2D()
end

function SWEP:PostDrawViewModel()
    local newpcfs = {}

    for _, pcf in ipairs(self.PCFs) do
        if IsValid(pcf) then
            pcf:Render()
            table.insert(newpcfs, pcf)
        end
    end

    self.PCFs = newpcfs

    if ARC9.PresetCam then return end

    cam.IgnoreZ(false)
    render.SetBlend(1)

    if !GetConVar("arc9_dev_benchgun"):GetBool() then
        cam.End3D()
    end

    cam.Start3D(nil, nil, self:WidescreenFix(self:GetViewModelFOV()), nil, nil, nil, nil, 1, 10000)
    for _, model in ipairs(self.VModel) do
        local slottbl = model.slottbl
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.HoloSight then
            -- cam.IgnoreZ(true)
            self:DoHolosight(model, atttbl)
            -- cam.IgnoreZ(false)
        end
    end
    cam.End3D()

    if GetConVar("arc9_fx_adsblur"):GetBool() and self:GetSight().Blur != false then arc9toytown(self:GetSightAmount()) end -- cool ass blur
    -- render.UpdateFullScreenDepthTexture()
end