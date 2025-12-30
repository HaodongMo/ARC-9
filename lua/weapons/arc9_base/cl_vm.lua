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
local arc9_fx_adsblur = GetConVar("arc9_fx_adsblur")

SWEP.RT_ScopeModelsEndPositions = {}

local function getscopebound(self, scopeent, worldvmpos, worldvmang)
    if !IsValid(scopeent) then return 20 end
    local modelmodel = scopeent:GetModel()
    if !self.RT_ScopeModelsEndPositions[modelmodel] then
        self.RT_ScopeModelsEndPositions[modelmodel] = 20 -- fallback until we get good one
        timer.Simple(1.5, function() 
            if !IsValid(scopeent) then return 20 end
            local owo, uwu = scopeent:GetModelBounds()
            owo = owo * (scopeent.Scale or Vector(1, 1, 1))
            uwu = uwu * (scopeent.Scale or Vector(1, 1, 1))
            local awoo, uwoo = self:GetAttachmentPos(scopeent.slottbl, false, false, true)

            self.RT_ScopeModelsEndPositions[modelmodel] = math.Clamp(WorldToLocal(awoo, uwoo, worldvmpos, worldvmang).x + uwu.x, 3, 20.5)
            -- debugoverlay.BoxAngles(awoo, owo, uwu, uwoo, 0.1, color_white)
        end)
    end

    return self.RT_ScopeModelsEndPositions[modelmodel]
end

local meowector = Vector(1, 0, 0)

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
            
            local vmvmpos = -self.ViewModelPos
            
            meowector.x = getscopebound(self, self.RTScopeModel, worldvmpos, worldvmang)

            worldvmpos = worldvmpos + worldvmang:Forward() * meowector.x
            worldvmang = worldvmang - Angle(worldvmang.p, worldvmang.y, 0) + MainEyeAngles()

            local vmpos, vmang = LocalToWorld(vmvmpos, -self.ViewModelAng, worldvmpos, worldvmang)

            cam.Start3D(vmpos, vmang, ARC9.RTScopeRenderFOV, nil, nil, nil, nil, 0.5, 1600)
        else
            local vmpso, vmagn, spso = self.LastViewModelPos, self.LastViewModelAng, self:GetSightPositions()

            vmpso = vmpso - vmagn:Forward() * (spso.y - 15) -- i sure do hope fixed number will be good (clueless)
            vmpso = vmpso - vmagn:Up() * spso.z
            vmpso = vmpso - vmagn:Right() * spso.x

            cam.Start3D(vmpso, nil, ARC9.RTScopeRenderFOV * 0.85, nil, nil, nil, nil, 3, 100040)

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

    	    local scrw, scrh = ScrW(), ScrH()

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
    	-- if self:GetHolsterTime() < CurTime() and sightamount > 0 then
    	if self:GetHolsterTime() < CurTime() then
            if hook.Run("NeedsDepthPass") == true then self:DrawRTReticle(self.RTScopeModel, self.RTScopeAtttbl, 1, true) end
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
    self:DrawCustomModel(false)
    render.DepthRange( 0.0, 0.1 )
    self:DoRHIK()
    if ARC9.RTScopeRender then return end
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

function SWEP:PostDrawViewModel(vm, weapon, ply, flags)
    if !IsValid(self:GetVM()) then return end
	flags = flags or STUDIO_RENDER
    local isDepthPass = ( bit.band( flags, STUDIO_SSAODEPTHTEXTURE ) != 0 || bit.band( flags, STUDIO_SHADOWDEPTHTEXTURE ) != 0 )
	
    local inrt = ARC9.RTScopeRender

    self:DrawTranslucentPass()

	if !isDepthPass then
    	local newmzpcfs = {}
        if ARC9.RTScopeRender then cam.IgnoreZ(false) end

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



    	    -- self:DoRTScope(self.RTScopeModel, self.RTScopeAtttbl, 1)

    self.RenderingHolosight = false
    cam.Start3D(nil, nil, self:WidescreenFix(self:GetViewModelFOV()), nil, nil, nil, nil, 1, 10000)
    if self.VModel then
        for _, model in ipairs(self.VModel) do
            local slottbl = model.slottbl
            local atttbl = self:GetFinalAttTable(slottbl)

            if atttbl.HoloSight then
                -- cam.IgnoreZ(true)
                self:DoHolosight(model, atttbl)
                -- cam.IgnoreZ(false)
            end
        end
    end
    cam.End3D()

    if arc9_fx_adsblur:GetBool() and self:GetSight().Blur != false and !self.Peeking then arc9toytown(self:GetSightAmount()) end -- cool ass blur
    -- render.UpdateFullScreenDepthTexture()
end
