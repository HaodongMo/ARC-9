local vignette = Material("arc9/bgvignette.png", "mips smooth")
-- local vignette2 = Material("arc9/bgvignette2.png", "mips smooth")

local scrw, scrh = ScrW(), ScrH()

local bluramt = 0
-- please cache fucking convars
local arc9_fx_rtblur = GetConVar("arc9_fx_rtblur")
local arc9_fx_animblur = GetConVar("arc9_fx_animblur")
local arc9_fx_reloadblur = GetConVar("arc9_fx_reloadblur")
local arc9_fx_inspectblur = GetConVar("arc9_fx_inspectblur")
local arc9_cust_blur = GetConVar("arc9_cust_blur")
local arc9_hud_lightmode = GetConVar("arc9_hud_lightmode")
local arc9_dev_greenscreen = GetConVar("arc9_dev_greenscreen")
local arc9_cust_light = GetConVar("arc9_cust_light")
local arc9_cust_light_brightness = GetConVar("arc9_cust_light_brightness")
local arc9_dev_benchgun = GetConVar("arc9_dev_benchgun")
local arc9_fx_adsblur_new = GetConVar("arc9_fx_adsblur_new")
local arc9_fx_adsblur_always = GetConVar("arc9_fx_adsblur_always")

function SWEP:PreDrawViewModel(vm, weapon, ply, flags)
    if ARC9.RTScopeRender then -- basically a copy of code in that func for rt barrels but without useless stuff and bad stuff, and also offset of cam in scope
        self:DoBodygroups(false)
        local vm = self:GetVM()
        if self.HasSightsPoseparam then
            vm:SetPoseParameter("sights", self:GetSightAmount())
        end
        self:SetFiremodePose()
        vm:InvalidateBoneCache()

        if ARC9_ENABLE_NEWSCOPES_MEOW then
            local worldvmpos, worldvmang = vm:GetPos(), vm:GetAngles()
        
            local scopelength = (IsValid(self.RTScopeModel) and self.RTScopeModel.RTScopeLength or 20) * 0.9

            worldvmpos = worldvmpos + worldvmang:Forward() * scopelength

            local vmpos, vmang = LocalToWorld(-self.ViewModelPos, -self.ViewModelAng, worldvmpos, worldvmang)
            vmang = MainEyeAngles()
            
            local funnyfov = self:WidescreenFix(self:GetViewModelFOV()) / self:GetRealZoom(self:GetSight())

            if !arc9_dev_benchgun:GetBool() then cam.Start3D(vmpos, vmang, funnyfov, nil, nil, nil, nil, 2, 16000) end
        else
            local vmpso, vmagn, spso = self.LastViewModelPos, self.LastViewModelAng, self:GetSightPositions()

            vmpso = vmpso - vmagn:Forward() * (spso.y - 15) -- i sure do hope fixed number will be good (clueless)
            vmpso = vmpso - vmagn:Up() * spso.z
            vmpso = vmpso - vmagn:Right() * spso.x

            if !arc9_dev_benchgun:GetBool() then cam.Start3D(vmpso, nil, ARC9.RTScopeRenderFOV * 0.85, nil, nil, nil, nil, 3, 16000) end
        end
        render.DepthRange( 0.1, 0.1 )

        return
    end

    if ARC9.PresetCam then
        self:DoBodygroups(false)
        return
    end

    local getsights = self:GetSight()
    local sightamount = self:GetSightAmount()

	flags = flags or STUDIO_RENDER
    local isDepthPass = ( bit.band( flags, STUDIO_SSAODEPTHTEXTURE ) != 0 || bit.band( flags, STUDIO_SHADOWDEPTHTEXTURE ) != 0 )
    local custdelta = self.CustomizeDelta

	if !isDepthPass then
    	local blurtarget = 0

    	local blurenable = arc9_fx_rtblur:GetBool()

    	local shouldrtblur = sightamount > 0 and blurenable and !self.Peeking and getsights.atttbl and getsights.atttbl.RTScope and !getsights.Disassociate and !getsights.atttbl.RTCollimator and !getsights.atttbl.RTScopeNoBlur

    	if shouldrtblur then
    	    blurtarget = 2 * sightamount
    	end

    	if (arc9_fx_reloadblur:GetBool() and self:GetReloading() and sightamount < 0.99) or (arc9_fx_animblur:GetBool() and self:GetReadyTime() >= CurTime()) or (arc9_fx_inspectblur:GetBool() and self:GetInspecting() and sightamount < 0.01) then
    	    blurtarget = 1.5
    	    shouldrtblur = true
    	end

    	if custdelta > 0 then
    	    if arc9_cust_blur:GetBool() then
    	        blurtarget = 5 * custdelta
    	    end

    	    cam.Start2D()
            	surface.SetDrawColor(15, 15, 15, 180 * custdelta)
            	surface.DrawRect(0, 0, scrw, scrh)
            	surface.SetDrawColor(0, 0, 0, 255 * custdelta)
            	if arc9_hud_lightmode:GetBool() then
                	surface.SetMaterial(vignette)
                	surface.DrawTexturedRect(0, 0, scrw, scrh)
            	end

            	if arc9_dev_greenscreen:GetBool() then
                	-- print(GetConVar("mat_bloom_scalefactor_scalar"):SetFloat())
                	surface.SetDrawColor(0, 255, 0, 255 * custdelta)
                	surface.DrawRect(0, 0, scrw, scrh)
            	end
        	cam.End2D()
    	end

    	if ((shouldrtblur and blurenable) or (custdelta > 0 and blurtarget > 0)) and system.HasFocus() then
        	DrawBokehDOF(bluramt, 1, 0)
    	end

    	bluramt = math.Approach(bluramt, blurtarget, FrameTime() * 10)

    	if arc9_cust_light:GetBool() and self:GetCustomize() then
        	-- render.SuppressEngineLighting(true)
        	-- render.ResetModelLighting(0.6, 0.6, 0.6)
        	-- render.SetModelLighting(BOX_TOP, 4, 4, 4)
        	local light = DynamicLight(self:EntIndex(), true)
        	light.pos = EyePos() + (EyeAngles():Up() * 12)
        	light.r = 255
        	light.g = 255
        	light.b = 255
        	light.brightness = 0.2 * (arc9_cust_light_brightness:GetFloat())
        	light.Decay = 1000
        	light.Size = 500
        	light.DieTime = CurTime() + 0.1
    	-- else
    	--     render.SuppressEngineLighting(false)
    	--     render.ResetModelLighting(1,1,1)
    	end
	end

    self:DoPoseParams()
    self:DoBodygroups(false)

    local bipodamount = self:GetBipodAmount()
    local vm = self:GetVM()
    if !IsValid(vm) then return end

    if self.HasSightsPoseparam then
        vm:SetPoseParameter("sights", math.max(sightamount, bipodamount, custdelta))
    end

    local bonemods = self:GetValue("BoneMods")

    if bonemods then for _, k in pairs(bonemods) do
        local boneindex = vm:LookupBone(i)

        if !boneindex then continue end

        vm:ManipulateBonePosition(boneindex, k.pos or vector_origin)
        vm:ManipulateBoneAngles(boneindex, k.ang or angle_zero)
        vm:ManipulateBoneScale(boneindex, k.scale or vector_origin)
    end end
    

    local vmfov = self:GetViewModelFOV()

    self.ViewModelFOV = vmfov

    

	if !isDepthPass then
    	if !ARC9_ENABLE_NEWSCOPES_MEOW and self:GetHolsterTime() < CurTime() and self.RTScope and sightamount > 0 then
    	    self:DoRTScope(vm, self:GetTable(), sightamount > 0)
    	end
    end

    if !arc9_dev_benchgun:GetBool() then
        cam.Start3D(nil, nil, self:WidescreenFix(vmfov), nil, nil, nil, nil, 0.5, 10000)
    end

	self.RenderingRTScope = false 

	if !isDepthPass then
    	vm:SetSubMaterial()

    	for ind = 0, 31 do
    	    local val = self:GetProcessedValue("SubMaterial" .. ind, true)
    	    if val then
    	        vm:SetSubMaterial(ind, val)
    	    end
    	end

    	vm:SetMaterial(self:GetProcessedValue("Material", true))
	end

    render.DepthRange( 0.0, 0.1 )
    if ARC9.PresetCam or custdelta > 0 then cam.IgnoreZ(true) end

    self:SetFiremodePose()
    
    if self.HasSightsPoseparam then
        vm:SetPoseParameter("sights", math.max(sightamount, bipodamount, custdelta))
    end

    vm:InvalidateBoneCache()
    
    if sightamount > 0.75 and getsights.FlatScope and !getsights.FlatScopeKeepVM then
        render.SetBlend(0)
    end
end

function SWEP:ViewModelDrawn(ent, flags)
	flags = flags or STUDIO_RENDER
    local isDepthPass = ( bit.band( flags, STUDIO_SSAODEPTHTEXTURE ) != 0 || bit.band( flags, STUDIO_SHADOWDEPTHTEXTURE ) != 0 )
	
    self.StoredVMAngles = self:GetCameraControl()
    self:DrawCustomModel(false, nil, nil, flags)
    render.DepthRange( 0.0, 0.1 )
    
    self:DoRHIK()

    if ARC9.RTScopeRender then 
        if !isDepthPass then
            render.DepthRange( 0.1, 0.1 )
            self:DrawLasers(false)
            render.DepthRange( 0.0, 0.1 )
        end
        return 
    end

    self:PreDrawThirdArm()

	if !isDepthPass then
    	self:DrawFlashlightsVM()

    	self:DrawLasers(false)
	end
		
    local vm = self:GetVM()
    if !IsValid(vm) then return end
    vm:SetMaterial("")
	for ind = 0, 31 do
		vm:SetSubMaterial(ind, "")
	end

    if !isDepthPass then
	    local newpcfs = {}

	    for _, pcf in ipairs(self.PCFs) do
	        if IsValid(pcf) then
	            pcf:Render()
	            table.insert(newpcfs, pcf)
	        end
	    end
	
	    if !inrt then self.PCFs = newpcfs end
	end

    local newfx = {}

    for _, fx in ipairs(self.ActiveEffects) do
        if IsValid(fx) then
            if !fx.VMContext then continue end
            fx:DrawModel()
            table.insert(newfx, fx)
        end
    end

    if !inrt then self.ActiveEffects = newfx end
end

local mat_dof = Material( "effects/arc9/vm_dof" )
local mat_dof_debug = Material( "effects/arc9/vm_dof_debug" )
local mat_white = Material( "effects/arc9/whiteunlit" )
local mat_black = Material( "effects/arc9/blackunlit" )
local tune_nohdr = Vector(1, 0, 0 )

local rt_dofmask = GetRenderTargetEx("arc9_optic_dof_mask2", scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_SHARED, 
    bit.bor(4,8,256,512), 
    0, 
    5 -- IMAGE_FORMAT_I8
)

local function shadersetstaticvalues()
    mat_dof:SetFloat("$c1_x", 1 / scrw)
    mat_dof:SetFloat("$c1_y", 1 / scrh)
    mat_dof:SetTexture("$texture1", rt_dofmask:GetName())
    mat_dof:SetFloat("$c0_x", 8)
    mat_dof:SetFloat("$c0_y", 0.07)
    mat_dof_debug:SetTexture("$texture1", rt_dofmask:GetName())
    mat_dof_debug:SetFloat("$c0_y", 0.07)
end

timer.Simple(10, shadersetstaticvalues)

local mat_dof_mask_debug = CreateMaterial("mat_debug_arc9_dof_mask5", "UnlitGeneric", {
    ["$basetexture"] = rt_dofmask:GetName(),
    ["$translucent"] = 0,
    ["$vertexcolor"] = 1,
    ["$ignorez"] = 1,
    ["$additive"] = 1,
} )

function SWEP:RenderDoF(strength)
    render.UpdateScreenEffectTexture()
    mat_dof:SetFloat("$c0_x", 8 * strength)

    if !self.DoFDepthSet then 
        mat_dof:SetFloat("$c0_y", self.DoFDepth or 0.07)
        self.DoFDepthSet = true
    end

    render.SetMaterial(mat_dof)
    render.DrawScreenQuad()

    -- if ARC9.Dev(2) then
        -- render.SetMaterial(mat_dof_debug)
        -- render.DrawScreenQuadEx( 10, 100+scrh/2, scrw/4, scrh/4 )
        -- render.SetMaterial(mat_dof_mask_debug)
        -- render.DrawScreenQuadEx( 10, 100+scrh/2, scrw/4, scrh/4 )

        -- render.SetMaterial(mat_dof_debug)
        -- render.DrawScreenQuadEx( -100, 100+scrh/2, scrw/8, scrh/8 )
        -- render.SetMaterial(mat_black)
        -- render.DrawScreenQuadEx( -100, 100+scrh/2+scrh/8, scrw/8, scrh/8 )
        -- render.SetMaterial(mat_dof_mask_debug)
        -- render.DrawScreenQuadEx( -100, 100+scrh/2+scrh/8, scrw/8, scrh/8 )
    -- end
end

function SWEP:RenderDoFMask(clear)
    render.PushRenderTarget(rt_dofmask)
        render.Clear(0, 0, 0, 255)
    render.PopRenderTarget()

    if clear then return end

    local scopemodel = self.RTScopeModel
    if scopemodel == self:GetVM() then return end
    if IsValid(self.RTScope_ForceBlurModel) then scopemodel = self.RTScope_ForceBlurModel end
    if !IsValid(scopemodel) then return end
    
    local glassindex = 0

    local mats = {}
    for k, v in pairs( scopemodel:GetMaterials() or {} ) do -- table.flip
        mats[ v ] = k
    end
    
    local glassindex = mats["effects/arc9/rtglass"] or mats["effects/arc9/rtglasssquare"] or mats["effects/arc9/rt"] or mats["___error"] or 0
    if scopemodel.RTScope_BlurTexture then glassindex = mats[scopemodel.RTScope_BlurTexture] or 0 end
    render.PushRenderTarget(rt_dofmask)
        -- render.Clear(0, 0, 0, 255)
        local oldtune = render.GetToneMappingScaleLinear()
        render.SetToneMappingScaleLinear(tune_nohdr) -- Turns off hdr
        render.ClearDepth()
        local sa = self:GetSightAmount()
        sa = sa * sa
        render.SetColorModulation(sa, sa, sa)
        render.SuppressEngineLighting(true)
        render.MaterialOverride(mat_black)
        render.MaterialOverrideByIndex(glassindex - 1, mat_white)

        scopemodel:DrawModel()
        
        -- render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)
        render.SuppressEngineLighting(false)
        render.MaterialOverride()
        render.MaterialOverrideByIndex(nil, nil)
    render.PopRenderTarget()

    render.SetToneMappingScaleLinear(oldtune) -- Resets hdr
end



function SWEP:PostDrawViewModel(vm, weapon, ply, flags)
    if !IsValid(self:GetVM()) then return end
	flags = flags or STUDIO_RENDER
    local isDepthPass = ( bit.band( flags, STUDIO_SSAODEPTHTEXTURE ) != 0 || bit.band( flags, STUDIO_SHADOWDEPTHTEXTURE ) != 0 )
	
    local inrt = ARC9.RTScopeRender

    self:DrawTranslucentPass()

	if !isDepthPass then
    	local newmzpcfs = {}
        if ARC9.RTScopeRender then render.DepthRange( 0.1, 0.1 ) end

    	for _, pcf in ipairs(self.MuzzPCFs) do
    	    if IsValid(pcf) then
    	        pcf:Render()
    	        table.insert(newmzpcfs, pcf)
    	    end
    	end

    	if !inrt then self.MuzzPCFs = newmzpcfs end
	end

    if ARC9.PresetCam then return end

    cam.IgnoreZ(false)
    render.SetBlend(1)

    if !arc9_dev_benchgun:GetBool() then
        cam.End3D()
    end

	if isDepthPass then return end
    if inrt then return end

    local sigt, sa, notactivemask
    local activedof = arc9_fx_adsblur_new:GetBool()

    if activedof then
        sigt = self:GetSight()
        sa = self:GetSightAmount()
        notactivemask = sa < 0.01 or !(sigt.atttbl and (sigt.atttbl.RTScope or sigt.atttbl.RTScopeNew_BlurTexture)) or self.Peeking
    end

    self.RenderingHolosight = false
    cam.Start3D(nil, nil, self:WidescreenFix(self:GetViewModelFOV()), nil, nil, nil, nil, 1, 10000)
    if self.VModel then
        for _, model in ipairs(self.VModel) do
            local slottbl = model.slottbl
            local atttbl = self:GetFinalAttTable(slottbl)

            if atttbl.HoloSight then
                self:DoHolosight(model, atttbl)
            end
        end

        if activedof then
            self:RenderDoFMask(notactivemask)
        end
    end
    cam.End3D()

    if activedof then
        if arc9_fx_adsblur_always:GetBool() then sa = 1 * (1 - self.CustomizeDelta) end

        if sa > 0.01 and sigt.Blur != false then
            self:RenderDoF(sa)   
        end
    end
end