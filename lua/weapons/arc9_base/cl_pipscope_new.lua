ARC9_ENABLE_NEWSCOPES_MEOW = true  
ARC9_ENABLE_NEWSCOPES_SHADER = true
ARC9.DepthBufferEnabled = false 

local scrw, scrh = ScrW(), ScrH()

local lenseshader = Material("arc9/lense_shader")

local rtmat = GetRenderTargetEx( "arc9_pipscope_awesome", scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_SHARED, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)

local rtmat_shader = GetRenderTargetEx("arc9_pipscope_awesome_shaderpass",  scrw, scrh, 
    RT_SIZE_FULL_FRAME_BUFFER, 
    MATERIAL_RT_DEPTH_NONE, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGB888
)

local rtmat_legacy = GetRenderTargetEx("arc9_pipscope_legacy_drawfunc",  scrh, scrh,
    RT_SIZE_LITERAL, 
    MATERIAL_RT_DEPTH_NONE, 
    bit.bor(4,8,256,512), 
    0, 
    IMAGE_FORMAT_RGBA8888
)

local mat_rtmat_legacy = CreateMaterial( "arc9_pipscope_legacy_mat", "UnlitGeneric", {
    ["$basetexture"] = rtmat_legacy:GetName(),
    ["$translucent"] = 1,
    ["$vertexcolor"] = 1
} )

-- Shader precalculations on cpu sideeeee

local function smoothstep(edge0, edge1, x)
    local t = math.Clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
end

-- static stuff

local shader_LENS_K = -0.525 -- lens K
local shader_CA_STRENGTH = -5 -- CA

local shader_VIG_FORG = 8.75 -- vignette forgiveness
local shader_VIG_OFFSET = 4.75 -- vignette offset
local shader_VIG_R1 = 0.124 -- vignette rad1
local shader_VIG_R2 = 0.7 -- vignette rad2

local shader_EYE_OFFSET_INFLUENCE = 0.75
local shader_EYE_DISTANCE_INFLUENCE = 0.05

local scrlength = math.sqrt(scrw * scrw + scrh * scrh)

local function shadersetstaticvalues()
    lenseshader:SetFloat("$c1_z", shader_VIG_R2 * scrh)
    lenseshader:SetFloat("$c1_w", 0.8 * shader_VIG_R2 * scrh)
    lenseshader:SetFloat("$c3_x", shader_LENS_K)
    lenseshader:SetFloat("$c3_z", scrw)
    lenseshader:SetFloat("$c3_w", scrh)
end

timer.Simple(10, shadersetstaticvalues)

-- dynamic stuff

local function CalculateShaderCPU(eye_x, eye_y, eye_dist) -- 0.5, 0.5, -0.05
    local eyelength = math.sqrt(eye_x * eye_x + eye_y * eye_y)

    local center_p_x = scrw * 0.5
    local center_p_y = scrh * 0.5
    local mouse_p_x = 0
    local mouse_p_y = 0

    if eyelength < 0.01 then
        mouse_p_x = 0.5 * scrw
        mouse_p_y = 0.5 * scrh
    else
        mouse_p_x = eye_x * scrw
        mouse_p_y = eye_y * scrh
    end

    local dir_p_x = mouse_p_x - center_p_x
    local dir_p_y = mouse_p_y - center_p_y
    local dir_len = math.sqrt(dir_p_x * dir_p_x + dir_p_y * dir_p_y)

    local norm_dir_x = 0
    local norm_dir_y = 0

    if dir_len >= 1 then
        norm_dir_x = dir_p_x / dir_len
        norm_dir_y = dir_p_y / dir_len
    end

    -- mouse
    local max_dist = 0.25 * scrlength * shader_VIG_FORG
    local t = math.Clamp(dir_len / max_dist, 0, 1)


    local offset_len = shader_VIG_OFFSET * math.min(scrw, scrh) * t
    local c1_p_x = center_p_x + norm_dir_x * offset_len * 1.75
    local c1_p_y = center_p_y + norm_dir_y * offset_len * 1.75

    lenseshader:SetFloat("$c0_x", c1_p_x)
    lenseshader:SetFloat("$c0_y", c1_p_y)

    -- some radius
    local rad1_p = ((0.8 - eye_dist) + shader_VIG_R1) * scrh

    lenseshader:SetFloat("$c0_z", rad1_p)
    lenseshader:SetFloat("$c0_w", (0.55 - eye_dist) * rad1_p)

    -- vignette
    local c2_p_x = center_p_x - norm_dir_x * offset_len * t * t
    local c2_p_y = center_p_y - norm_dir_y * offset_len * t * t

    lenseshader:SetFloat("$c1_x", c2_p_x)
    lenseshader:SetFloat("$c1_y", c2_p_y)
    
    -- ca
    local mouse_ca_boost = t * 200
    local lateral_ca = (0.025 + eye_dist / 15) * (1 + mouse_ca_boost)
    local ca_base = (0.5 + shader_CA_STRENGTH) * 1.5
    local forg_scale = (1 / shader_VIG_FORG * shader_VIG_FORG) * 0.05
    local ca_t = t * 0.5 + smoothstep(0.02, 0.2, t) * 100
    local ca_scale = ca_base * forg_scale * ca_t * 0.5

    lenseshader:SetFloat("$c2_x", norm_dir_x * ca_scale * 2)
    lenseshader:SetFloat("$c2_y", norm_dir_y * ca_scale * 2)
    lenseshader:SetFloat("$c2_z", lateral_ca * 0.2)
    lenseshader:SetFloat("$c2_w", lateral_ca * 0.8 * t)
end

local Lerp = Lerp
local LerpVector = LerpVector


function SWEP:ShouldDoScope()
    if self:GetSight().Disassociate or self:GetOwner().ARC9NoScopes then return false end
	
    return true
end

local rtsurf = Material("effects/arc9/rt")
local arc9_fx_rtvm = GetConVar("arc9_fx_rtvm")
local shadow = Material("arc9/shadow3.png", "mips smooth")
local shadow2 = Material("arc9/shadow2.png", "mips smooth")
-- local black = Material("arc9/ahmad.png", "mips smooth")
local black = Material("vgui/black")
-- local black = Material("models/wireframe")
local arc9_scope_r = GetConVar("arc9_scope_r")
local arc9_scope_g = GetConVar("arc9_scope_g")
local arc9_scope_b = GetConVar("arc9_scope_b")

-- local function cropfovsqaure(fov, fullratio)
--     local verticalfov = 2 * math.atan(math.tan(math.rad(fov) / 2) * (1 / fullratio))
--     local properhorizontalfov = 2 * math.atan(math.tan(verticalfov / 2))
--     return math.deg(properhorizontalfov)
-- end


local rt_eyeang = Angle()
local rt_eyepos = Vector()
local rt_viewsetup_fov = 90
local rt_viewsetup_fov_unscaled = 90

local invertcolormodif = {
	[ "$pp_colour_addr" ] = 0, [ "$pp_colour_addg" ] = 0, [ "$pp_colour_addb" ] = 0, 
    [ "$pp_colour_brightness" ] = 0, [ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1, [ "$pp_colour_mulr" ] = 0, [ "$pp_colour_mulg" ] = 0, [ "$pp_colour_mulb" ] = 0,
	[ "$pp_colour_inv" ] = 1,
}

function SWEP:RenderRT(magnification, atttbl)
    if ARC9.OverDraw then return end

    local viewstup = render.GetViewSetup()
    rt_viewsetup_fov, rt_viewsetup_fov_unscaled = viewstup.fov, viewstup.fov_unscaled
    local rtfov = rt_viewsetup_fov_unscaled / magnification
    local rtvm = arc9_fx_rtvm:GetBool()
    
    ARC9.RTScopeRenderFOV = rtfov
    
    ARC9.DepthBufferEnabled = hook.Run("NeedsDepthPass")
    
    -- EyeAngles/Pos -- late for one frame!
    -- ply:EyeAngles/Pos -- not late but custom CalcViews and punch, probably more doesn't work
    -- MainEyeAngles/Pos -- good 👍 🐾
    -- NO ITS NOT FUCKING GOOD
    -- BREAKS model:GetPos GetAngles if depth buffer is off
    -- Wtf is this shit

    -- local rtang = LocalPlayer():EyeAngles() + LocalPlayer():GetViewPunchAngles()
    -- local rtpos = LocalPlayer():EyePos()
    -- hook.Run("CalcView", LocalPlayer(), rtpos, rtang, self.FOV)

    rt_eyeang = ARC9.DepthBufferEnabled and MainEyeAngles() or EyeAngles()
    rt_eyepos = ARC9.DepthBufferEnabled and MainEyePos() or EyePos()
    
    local rt = {
        x = scrw/2-scrh/2,
        y = 0,
        w = scrh,
        h = scrh,
        angles = rt_eyeang,
        origin = rt_eyepos,
        drawviewmodel = rtvm,
        fov = rtfov,
        znear = 8,
        zfar = 30000,
        aspectratio = 1,
    }

    render.PushRenderTarget(rtmat)
    -- render.Clear(0,0,0,0)

        ARC9.OverDraw = true
        ARC9.RTScopeRender = rtvm
        render.RenderView(rt)
        
        if !rtvm then
            local laserthing = EyePos()
            laserthing = laserthing + rt_eyeang:Forward() * 40
            cam.Start3D(laserthing, rt_eyeang, rtfov, nil, nil, nil, nil, 1, 10000)
                cam.IgnoreZ(true)
                self:DrawLasers(false)
                cam.IgnoreZ(false)
            cam.End3D()
        end

        atttbl = atttbl or {}

        if atttbl.RTScopeFLIR then
            cam.Start3D()
                self:DoFLIR(atttbl)
            cam.End3D()
        end

        if atttbl.RTScopeNightVision then
            self:DoNightScopeEffects(atttbl)
        end

        cam.Start3D()
            self:DrawLockOnHUD(true)
        cam.End3D()

        self:DoRTScopeEffects()

        ARC9.RTScopeRender = false
        ARC9.OverDraw = false


        if self:GetSight().InvertColors then
            DrawColorModify(invertcolormodif)
            if atttbl.RTScopePostInvertFunc then
                atttbl.RTScopePostInvertFunc(self)
            end
        end

    render.PopRenderTarget()

    if !ARC9.DepthBufferEnabled then
        if !self.RTScope then -- integrated rt
            self:DrawRTReticle(self.RTScopeModel, self.RTScopeAtttbl or {}, 1)
        else
            self:DrawRTReticle(self:GetVM(), self:GetTable(), 1, true)
        end
    end
end

local function drawscopequad(scale, range, ang, pos, mat, color, nobox)
    local up, right, forward = ang:Up(), ang:Right(), ang:Forward()
    up, right, forward = up * scale, right * scale, forward * range
    
    local v1 = pos + (up / 2) - (right / 2) + forward
    local v2 = pos + (up / 2) + (right / 2) + forward
    local v3 = pos - (up / 2) + (right / 2) + forward
    local v4 = pos - (up / 2) - (right / 2) + forward

    render.SetMaterial(mat)
    render.DrawQuad(v1, v2, v3, v4, color)

        -- BLACK BOXXXX
    if !nobox then
        render.SetMaterial(black)
        up, right = up * 0.999, right * 0.999 -- less scale to prevent visible pixel gaps

        local v1 = pos + (up * 4) - (right * 8) + forward
        local v2 = pos + (up * 4) - (right * 0.5) + forward
        local v3 = pos - (up * 4) - (right * 0.5) + forward
        local v4 = pos - (up * 4) - (right * 8) + forward
        render.DrawQuad(v1, v2, v3, v4, color) -- LEFT

        local v1 = pos + (up * 4) + (right * 0.5) + forward
        local v2 = pos + (up * 4) + (right * 8) + forward
        local v3 = pos - (up * 4) + (right * 8) + forward
        local v4 = pos - (up * 4) + (right * 0.5)+ forward
        render.DrawQuad(v1, v2, v3, v4, color) -- RIGHT

        local v1 = pos + (up * 4) - (right / 2) + forward
        local v2 = pos + (up * 4) + (right / 2) + forward
        local v3 = pos + (up / 2) + (right / 2) + forward
        local v4 = pos + (up / 2) - (right / 2) + forward
        render.DrawQuad(v1, v2, v3, v4, color) -- TOP

        local v1 = pos - (up / 2) - (right / 2) + forward
        local v2 = pos - (up / 2) + (right / 2) + forward
        local v3 = pos - (up * 4) + (right / 2) + forward
        local v4 = pos - (up * 4) - (right / 2) + forward
        render.DrawQuad(v1, v2, v3, v4, color) -- BOTTOM
    end
end

local scopebounds = {}

local function getscopebound(scopeent)
    local modelmodel = scopeent:GetModel()
    if !scopebounds[modelmodel] then
        local owo, uwu = scopeent:GetModelBounds()
        scopebounds[modelmodel] = {owo.x, uwu.x}
    end
    return scopebounds[modelmodel]
end

function SWEP:DrawRTReticle(model, atttbl, active, nonatt)
    if !IsValid(model) then return end
    
    if active then
        if self:ShouldDoScope() then
            self.RenderingRTScope = true
            local sight = self:GetSight()

            local sightamt = self:GetSightDelta()
            if self:GetInSights() then sightamt = math.ease.OutQuart(sightamt)
            else sightamt = math.ease.InQuart(sightamt) end

            render.PushRenderTarget(rtmat)
            
            local globalscalie = 1.41 * (atttbl.RTScopeReticleScale or 1)

            local reticle = sight.Reticle or atttbl.RTScopeReticle
            local color = atttbl.RTScopeColor or color_white
            
            if atttbl.RTScopeColorable then
                color = Color(0, 0, 0)
                color.r = arc9_scope_r:GetInt()
                color.g = arc9_scope_g:GetInt()
                color.b = arc9_scope_b:GetInt()
            end

            local legacydrawfunc = atttbl.RTScopeDrawFunc
            local newdrawfunc = atttbl.RTScopeNew_DrawFunc3D

            if legacydrawfunc then -- LEGACY
                render.PushRenderTarget(rtmat_legacy)
                    render.Clear(0, 0, 0, 0)
                    cam.Start2D()
                        legacydrawfunc(self, scrh, sight)
                    cam.End2D()
                render.PopRenderTarget()
            end

            if atttbl.RTScopeNew_DrawFunc2D then
                cam.Start2D()
                    atttbl.RTScopeNew_DrawFunc2D(self, scrw, scrh, sight)
                cam.End2D()
            end

            local origsighttable = sight.OriginalSightTable
            local origsighttablepos = sight.OriginalSightTable and sight.OriginalSightTable.Pos or Vector(0, 0, 0)

            local scopebound = nonatt and {20, 10} or getscopebound(model)
            
            local modelang = model:GetAngles()
            local modelforward = modelang:Forward()
            local modelpos = model:GetPos()
            - modelang:Up() * origsighttablepos.z / (atttbl.Scale or 1)
            - modelforward * (-scopebound[1]) / (atttbl.Scale or 1)
            - modelang:Right() * origsighttablepos.x / (atttbl.Scale or 1)

            -- lua_run_cl hook.Add("NeedsDepthPass","a",function() return !LASTMEOW end) LASTMEOW = hook.Run("NeedsDepthPass") print(LASTMEOW)

            local fuck_fov = (ARC9.DepthBufferEnabled and rt_viewsetup_fov or rt_viewsetup_fov_unscaled) -- ????
            fuck_fov = fuck_fov + Lerp(sightamt, (self.SmoothedViewModelFOV or 90) - self.FOV, math.Remap(LocalPlayer():GetFOV(), 75, 100, 0, -21))

            cam.Start3D(nil, nil, fuck_fov, nil, nil, nil, nil, 0.1, 10000)
                cam.IgnoreZ(true)
                    if atttbl.RTScopeNew_FrontShadow != false or atttbl.RTScopeBlackBoxShadow != false then
                        local modelpos2 = modelpos - modelforward * (scopebound[1] - scopebound[2] - 5)
                        local lerped2 = LerpVector(sightamt, modelpos2, rt_eyepos)
                        drawscopequad(Lerp(sightamt, 5, 7) * globalscalie * (atttbl.RTScopeNew_FrontShadowScale or 1) * (atttbl.RTScopeNew_ShadowScale or 1), 13, modelang, lerped2, shadow, color_white) -- end of scope shadow
                    end

                    if reticle or legacydrawfunc or newdrawfunc then
                        local lerped = LerpVector(sightamt, modelpos, rt_eyepos)
                        if reticle then drawscopequad(Lerp(sightamt, 3, 0.6) * globalscalie, 1.5, modelang, lerped, reticle, color, !atttbl.RTScopeNew_ReticleBlackBox) end -- reticle

                        if legacydrawfunc then drawscopequad(Lerp(sightamt, 3, 0.6) * globalscalie, 1.5, modelang, lerped, mat_rtmat_legacy, color_white) end

                        if newdrawfunc then newdrawfunc(self, scrh, sight, modelang, lerped) end
                    end

                    if atttbl.RTScopeNew_BackShadow != false or !atttbl.RTScopeNoShadow then
                        local modelpos3 = modelpos - modelforward * 2
                        local lerped3 = LerpVector(sightamt, modelpos3, rt_eyepos)
                        drawscopequad(Lerp(sightamt, 0.7, 1) * globalscalie * (atttbl.RTScopeNew_BackShadowScale or 1) * (atttbl.RTScopeNew_ShadowScale or 1), 2, modelang, lerped3, shadow, color_white) -- small shadow before reticle
                    end

                    if ARC9_ENABLE_NEWSCOPES_SHADER and !atttbl.RTScopeNew_DisableShader then
                        local toscreen = !nonatt and modelpos:ToScreen() or {x = scrw/2, y = scrh/2}
                        local offsetx, offsety = 
                            (math.Clamp(toscreen.x / scrw, 0.3, 0.8) - 0.5) * shader_EYE_OFFSET_INFLUENCE,
                            (math.Clamp(toscreen.y / scrh, 0.3, 0.8) - 0.5) * shader_EYE_OFFSET_INFLUENCE
                            -- print(offsetx, offsety)

                        local mreow =  math.max(math.abs(offsetx), math.abs(offsety)) * 1
                        mreow = math.Clamp((lerped and lerped:Distance(rt_eyepos) or 0) * shader_EYE_DISTANCE_INFLUENCE - 0.15 + mreow, -0.15, 0.8)

                        CalculateShaderCPU(offsetx + 0.5, offsety + 0.5, mreow)
                        
                        -- lenseshader:SetFloat("$c3_x", offsetx + 0.5)
                        -- lenseshader:SetFloat("$c3_y", offsety + 0.5)
                        -- lenseshader:SetFloat("$c0_x", mreow)
                    end
                cam.IgnoreZ(false)
            cam.End3D()

            render.CopyRenderTargetToTexture(rtmat_shader)

            lenseshader:SetTexture("$basetexture", rtmat)

            render.PopRenderTarget()
        end

        render.PushRenderTarget(rtmat_shader)
            if ARC9_ENABLE_NEWSCOPES_SHADER and !atttbl.RTScopeNew_DisableShader then
                -- render.SetMaterial(lenseshader)
                -- render.DrawScreenQuad()
            end

            cam.Start2D() -- shader bleeds a bit, drawing a box to keep it square
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, 0, scrw/2 - scrh/2, scrh)
                surface.DrawRect(scrw/2 + scrh/2, 0, scrw, scrh)
                surface.SetMaterial(shadow2)
                surface.DrawTexturedRect(scrw/2-scrh/2, 0, scrh, scrh) -- global shadow
            cam.End2D()
        render.PopRenderTarget()

        rtsurf:SetTexture("$basetexture", rtmat_shader)

        model = model or self:GetVM()
        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "effects/arc9/rt")
        -- model:SetSubMaterial(1, "effects/arc9/rt")
    else
        -- rtsurf:SetTexture("$basetexture", "vgui/black")
        -- model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "vgui/black")
    end
end

function SWEP:GetCheapScopeScale(scale)
    local ratio = scale - (!self.ExtraSightDistanceNoRT and self:GetSight().ExtraSightDistance or 0) * 0.045

    return 1 / ratio * (scrw / scrh / 1.12)
end


if ARC9.Dev(2) then
    local testmat = CreateMaterial( "testpipscope", "UnlitGeneric", {
        ["$basetexture"] = rtmat_shader:GetName(), -- You can use "example_rt" as well
        ["$translucent"] = 0,
        ["$vertexcolor"] = 1
    } )

    hook.Add("HUDPaint", "arc9_test_pipscope", function()
        if ARC9.Dev(2) then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(testmat)
            surface.DrawTexturedRect(scrw-scrw/4, scrh/2-scrh/3, scrw/4, scrh/4)
        end
    end)
end