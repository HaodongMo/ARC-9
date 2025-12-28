local rtmat = GetRenderTargetEx(
    "arc9_pipscope_awesome", 
    ScrW(), 
    ScrH(), 
    RT_SIZE_FULL_FRAME_BUFFER, 
    0, 
    0, 
    1, 
    IMAGE_FORMAT_RGBA8888
)

function SWEP:ShouldDoScope()
    if self:GetSight().Disassociate or self:GetOwner().ARC9NoScopes then return false end
	
    return true
end

local rtsurf = Material("effects/arc9/rt")
local arc9_fx_rtvm = GetConVar("arc9_fx_rtvm")
local shadow = Material("arc9/shadow.png", "mips smooth")
local shadow2 = Material("arc9/shadow2.png", "mips smooth")
-- local black = Material("arc9/ahmad.png", "mips smooth")
local black = Material("vgui/black")
-- local fisheyelens = Material("models/props_c17/fisheyelens")
local fisheyelens = Material("effects/shaders/merc_chromaticaberration")
-- local fisheyelens = Material("effects/shaders/merc_fisheye")
local arc9_scope_r = GetConVar("arc9_scope_r")
local arc9_scope_g = GetConVar("arc9_scope_g")
local arc9_scope_b = GetConVar("arc9_scope_b")


function SWEP:DoRT(magnification, atttbl)
    if ARC9.OverDraw then return end
    -- print(self.FOV, magnification)
    local fov = (self.FOV) / magnification + 16.7
    local rtvm = arc9_fx_rtvm:GetBool()
    
    ARC9.RTScopeRenderFOV = fov
    
    local rt = {
        x = 0,
        y = 0,
        w = ScrW(),
        h = ScrH(),
        angles = EyeAngles(),
        origin = EyePos(),
        drawviewmodel = rtvm,
        fov = fov,
        znear = 8,
        zfar = 30000
    }

    render.PushRenderTarget(rtmat)


        ARC9.OverDraw = true
        ARC9.RTScopeRender = rtvm
        render.RenderView(rt)
        ARC9.RTScopeRender = false
        ARC9.OverDraw = false

    render.PopRenderTarget()
end

local function drawscopequad(scale, range, ang, pos, mat, color)
    local up, right, forward = ang:Up(), ang:Right(), ang:Forward()
    local v1 = pos + (up * scale / 2) - (right * scale / 2) + forward * range
    local v2 = pos + (up * scale / 2) + (right * scale / 2) + forward * range
    local v3 = pos - (up * scale / 2) + (right * scale / 2) + forward * range
    local v4 = pos - (up * scale / 2) - (right * scale / 2) + forward * range
    render.SetMaterial(mat)
    render.DrawQuad(v1, v2, v3, v4, color)

    render.SetMaterial(black)
    scale = scale * 0.999 -- to prevent edges

    local v1 = pos + (up * scale * 4) - (right * scale * 8) + forward * range
    local v2 = pos + (up * scale * 4) - (right * scale * 0.5) + forward * range
    local v3 = pos - (up * scale * 4) - (right * scale * 0.5) + forward * range
    local v4 = pos - (up * scale * 4) - (right * scale * 8) + forward * range
    -- render.DrawQuad(v1, v2, v3, v4, color)

    local v1 = pos + (up * scale * 4) + (right * scale * 0.5) + forward * range
    local v2 = pos + (up * scale * 4) + (right * scale * 8) + forward * range
    local v3 = pos - (up * scale * 4) + (right * scale * 8) + forward * range
    local v4 = pos - (up * scale * 4) + (right * scale * 0.5)+ forward * range
    -- render.DrawQuad(v1, v2, v3, v4, color)

    local v1 = pos - (up * scale / 2) - (right * scale / 2) + forward * range
    local v2 = pos - (up * scale / 2) + (right * scale / 2) + forward * range
    local v3 = pos - (up * scale * 4) + (right * scale / 2) + forward * range
    local v4 = pos - (up * scale * 4) - (right * scale / 2) + forward * range
    -- render.DrawQuad(v1, v2, v3, v4, color)

    local v1 = pos + (up * scale * 4) - (right * scale / 2) + forward * range
    local v2 = pos + (up * scale * 4) + (right * scale / 2) + forward * range
    local v3 = pos + (up * scale / 2) + (right * scale / 2) + forward * range
    local v4 = pos + (up * scale / 2) - (right * scale / 2) + forward * range
    -- render.DrawQuad(v1, v2, v3, v4, color)
end

local scopebounds = {}

local function getscopebound(model)
    local modelmodel = model:GetModel()
    if !scopebounds[modelmodel] then
        local owo, uwu = model:GetModelBounds()
        scopebounds[modelmodel] = {owo.x, uwu.x}
    end
    return scopebounds[modelmodel]
end

function SWEP:DoRTScope(model, atttbl, active)
    local eyeang = EyeAngles()
    local eyepos = EyePos()

    if active then
        local sightzang = 0
        if self:ShouldDoScope() then
            self.RenderingRTScope = true
            local sight = self:GetSight()

            -- local sp, sa = self:GetShootPos()
            -- local sp, sa = self.LastViewModelPos, self.LastViewModelAng
            -- local endpos = sp + (sa:Forward() * 9000)
            -- local toscreen = endpos:ToScreen()

            -- local offsetx, offsety = toscreen.x - ScrW()/2, toscreen.y - ScrH()/2
            render.PushRenderTarget(rtmat)
            
            local modelang = model:GetAngles()
            local reticle = sight.Reticle or atttbl.RTScopeReticle
            local color = atttbl.RTScopeColor or color_white
            
            if atttbl.RTScopeColorable then
                color = Color(0, 0, 0)
                color.r = arc9_scope_r:GetInt()
                color.g = arc9_scope_g:GetInt()
                color.b = arc9_scope_b:GetInt()
            end

            -- drawscopequad(0.5, 1, modelang, eyepos, shadow, color_white)
            -- drawscopequad(0.5, 1, modelang, reticle, color)
            -- render.SetMaterial(fisheyelens)
            -- render.DrawScreenQuad()
            -- drawscopequad(0.5, 1, modelang, eyepos, fisheyelens, color)

            -- local s = 5
            -- local modelang = eyeang + (model:GetAngles() - eyeang) * -4
            -- modelang.r = modelang.r / -4
            -- local up, right, forward = modelang:Up(), modelang:Right(), modelang:Forward()
            -- local v1 = eyepos + (up * s / 2) - (right * s / 2) + forward * s * 2
            -- local v2 = eyepos + (up * s / 2) + (right * s / 2) + forward * s * 2
            -- local v3 = eyepos - (up * s / 2) + (right * s / 2) + forward * s * 2
            -- local v4 = eyepos - (up * s / 2) - (right * s / 2) + forward * s * 2
            -- render.DrawQuad(v1, v2, v3, v4, color_white)

            -- cam.End3D()


            -- cam.Start2D()

            -- if reticle then
                -- surface.SetDrawColor(color)
                -- surface.SetMaterial(reticle)
                -- surface.DrawTexturedRect(ScrW()/2 - ScrH()/2 + offsetx, 0 + offsety, ScrH(), ScrH())
            -- end

            
            -- surface.SetDrawColor(0, 0, 0)
            -- surface.DrawRect(rtr_x - size * 4, rtr_y - size * 8, size * 8, size * 8) -- top
            -- surface.DrawRect(ScrW()/2 - ScrH()*1 + offsetx, 0 + offsety, ScrH()/2, ScrH()) -- left
            -- surface.DrawRect(rtr_x - size * 4, rtr_y + size - 1, size * 8, size * 8) -- bottom
            -- surface.DrawRect(ScrW()/2 + ScrH()/2 + offsetx, 0 + offsety, ScrH()/2, ScrH()) -- right
            -- surface.SetDrawColor(0, 0, 0)
            -- surface.SetMaterial(shadow)
            -- surface.DrawTexturedRect(ScrW()/2 - ScrH()/2 + offsetx, 0 + offsety, ScrH(), ScrH())

            local eyeforward = eyeang:Forward()
            
            cam.Start3D(eyepos + eyeforward * -1, nil, nil, nil, nil, nil, nil, 0.5, 10000)
                cam.IgnoreZ(true)
                    drawscopequad(2, 1, modelang, eyepos, shadow, color_white)
                cam.IgnoreZ(false)
            cam.End3D()

            cam.Start3D(eyepos + eyeforward * -10, nil, nil, nil, nil, nil, nil, 0.1, 10000)
                cam.IgnoreZ(true)
                    -- drawscopequad(15, 6, modelang, eyepos, shadow, color_white)
                    -- drawscopequad(15, 6, modelang, eyepos, reticle, color)
                cam.IgnoreZ(false)
            cam.End3D()
            -- PrintTable(sight)
            
            -- local modelpos = model:GetPos() + model:GetAngles():Forward() * -10 - sight.Pos
            -- local modelpos = model:GetPos() + model:GetAngles():Forward() * -1 
            -- local modelpos = model:GetPos() - model:GetAngles():Up() * sight.Pos.z

            local scopebound = getscopebound(model)
            local modelpos = model:GetPos()
             - model:GetAngles():Up() * sight.OriginalSightTable.Pos.z / (atttbl.Scale or 1)
            --  - model:GetAngles():Forward() * (sight.OriginalSightTable.Pos.y * 0.5 - 2) / (atttbl.Scale or 1)
             - model:GetAngles():Forward() * (-scopebound[1]) / (atttbl.Scale or 1)
             - model:GetAngles():Right() * sight.OriginalSightTable.Pos.x / (atttbl.Scale or 1)
            -- PrintTable(sight)

            -- cam.Start3D(nil, nil, nil, nil, nil, nil, nil, 0.1, 10000)
                cam.IgnoreZ(true)
                    local sightamt = self:GetSightDelta()
                    if self:GetInSights() then sightamt = math.ease.OutQuart(sightamt)
                    else sightamt = math.ease.InQuart(sightamt) end
                    
                    -- local lerpscale = Lerp(sightamt, 4, 0.3)
                    local lerpscale = Lerp(sightamt, 4, 0.6)

                    local modelpos2 = modelpos - model:GetAngles():Forward() * (scopebound[1] - scopebound[2])
                    local lerped2 = LerpVector(sightamt, modelpos2, eyepos)
                    drawscopequad(4, 10, modelang, lerped2, shadow, color_white)

                    local lerped = LerpVector(sightamt, modelpos, eyepos)
                    drawscopequad(lerpscale, 1.5, modelang, lerped, reticle, color)

                    local modelpos3 = modelpos - model:GetAngles():Forward() * 2
                    local lerped3 = LerpVector(sightamt, modelpos3, eyepos)
                    drawscopequad(Lerp(sightamt, 1, 0.6), 2, modelang, lerped3, shadow, color_white)

                cam.IgnoreZ(false)
            -- cam.End3D()

        else
            render.PushRenderTarget(rtmat)
        end

	-- DrawMaterialOverlay( "models/props_c17/fisheyelens", 0.2 )
        render.PopRenderTarget()
        rtsurf:SetTexture("$basetexture", rtmat)

        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "effects/arc9/rt")
    else
        -- rtsurf:SetTexture("$basetexture", "vgui/black")
        -- model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "vgui/black")
    end
end

function SWEP:GetCheapScopeScale(scale)
    local ratio = scale - (!self.ExtraSightDistanceNoRT and self:GetSight().ExtraSightDistance or 0) * 0.045

    return 1 / ratio * (ScrW() / ScrH() / 1.12)
end



local testmat = CreateMaterial( "example_rt_mat2", "UnlitGeneric", {
	["$basetexture"] = rtmat:GetName(), -- You can use "example_rt" as well
	["$translucent"] = 0,
	["$vertexcolor"] = 1
} )

hook.Add("HUDPaint", "arc9_test_pipscope", function()
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(testmat)
    surface.DrawTexturedRect(ScrW()-ScrW()/4, ScrH()/2-ScrH()/8, ScrW()/4, ScrH()/4)
end)
--[[



local rtsize = math.min(1024, ScrW(), ScrH())

local rtmat = GetRenderTarget("arc9_pipscope", rtsize, rtsize, false)
local rtmat_spare = GetRenderTarget("arc9_rtmat_spare", ScrW(), ScrH(), false)

function SWEP:ShouldDoScope()
    if self:GetSight().Disassociate or self:GetOwner().ARC9NoScopes then return false end
	
    return true
end

local arc9_fx_rtvm = GetConVar("arc9_fx_rtvm")

function SWEP:DoRT(fov, atttbl)
    if ARC9.OverDraw then return end

    local rtpos, rtang = self:GetShootPos()

    rtang.r = rtang.r + EyeAngles().z -- lean fix

    local sighttbl = self:GetSight()

    local rtvm = arc9_fx_rtvm:GetBool()

    local rt = {
        x = 0,
        y = 0,
        w = rtsize,
        h = rtsize,
        angles = rtang,
        origin = rtpos,
        drawviewmodel = rtvm or false,
        fov = fov,
        znear = 16,
        zfar = 30000
    }
    
    ARC9.RTScopeRenderFOV = fov

    render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)

    if self:ShouldDoScope() then
        ARC9.OverDraw = true
        ARC9.RTScopeRender = rtvm
        render.RenderView(rt)
        ARC9.RTScopeRender = false
        ARC9.OverDraw = false

        cam.Start3D(rtpos, rtang, fov, 0, 0, rtsize, rtsize)
            cam.IgnoreZ(true)
            self:DrawLasers(false, true)
            cam.IgnoreZ(false)
        cam.End3D()
    else
        render.Clear(0, 0, 0, 255, true, true)
    end

    if atttbl.RTScopeFLIR then
        cam.Start3D(rtpos, rtang, fov, 0, 0, rtsize, rtsize, 16, 30000)

        self:DoFLIR(atttbl)

        cam.End3D()
    end

    if atttbl.RTScopeNightVision then
        self:DoNightScopeEffects(atttbl)
    end

    cam.Start3D(rtpos, rtang, fov, 0, 0, rtsize, rtsize, 16, 30000)
        self:DrawLockOnHUD(true)
    cam.End3D()

    self:DoRTScopeEffects()

    render.PopRenderTarget()

    if sighttbl.InvertColors then
        render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)
            render.CopyTexture( rtmat, rtmat_spare )

            render.Clear(255, 255, 255, 255, true, true)
            render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_REVERSE_SUBTRACT)

            render.DrawTextureToScreen(rtmat_spare)

            render.OverrideBlend(false)

            if atttbl.RTScopePostInvertFunc then
                atttbl.RTScopePostInvertFunc(self)
            end

        render.PopRenderTarget()
    end
end

local rtsurf = Material("effects/arc9/rt")
local shadow = Material("arc9/shadow.png", "mips smooth")
local shadow2 = Material("arc9/shadow2.png", "mips smooth")

-- local pp_ca_base, pp_ca_r, pp_ca_g, pp_ca_b = Material("pp/arc9/ca_base"), Material("pp/arc9/ca_r"), Material("pp/arc9/ca_g"), Material("pp/arc9/ca_b")

local pp_cc_tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0.03,
    ["$pp_colour_contrast"] = 0.92,
    ["$pp_colour_colour"] = 1.1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

local monochrometable = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

local noise = Material("arc9/nvnoise")

function SWEP:DoNightScopeEffects(atttbl)
    if atttbl.RTScopeNightVisionMonochrome then
        DrawColorModify(monochrometable)
    end

    if !atttbl.RTScopeNightVisionNoPP then
        cam.Start2D()
        surface.SetMaterial(noise)
        surface.SetDrawColor(atttbl.RTScopeNightVisionNoiseColor or color_white)
        surface.DrawTexturedRectRotated((rtsize / 2) + (rtsize * math.Rand(-0.25, 0.25)), (rtsize / 2) + (rtsize * math.Rand(-0.25, 0.25)), rtsize, rtsize, math.Rand(0, 360))
        surface.DrawTexturedRectRotated((rtsize / 2) + (rtsize * math.Rand(-0.5, 0.5)), (rtsize / 2) + (rtsize * math.Rand(-0.5, 0.5)), rtsize * 2, rtsize * 2, math.Rand(0, 360))
        cam.End2D()

        DrawBloom(0, 1, 10, 1, 1, 1, 1, 1, 1)
    end

    if atttbl.RTScopeNightVisionCC then
        DrawColorModify(atttbl.RTScopeNightVisionCC)
    end

    if atttbl.RTScopeNightVisionFunc then
        atttbl.RTScopeNightVisionFunc(self)
    end
end

function SWEP:DoRTScopeEffects()
    if !render.SupportsPixelShaders_2_0() then return end

    local atttbl = ((self:GetSight() or {}).atttbl or {})

    render.UpdateScreenEffectTexture()

    if atttbl.RTScopeNoPP then return end

    -- pp_ca_r:SetTexture("$basetexture", rtmat)
    -- pp_ca_g:SetTexture("$basetexture", rtmat)
    -- pp_ca_b:SetTexture("$basetexture", rtmat)

    -- render.SetMaterial( pp_ca_r )
    -- render.DrawScreenQuad()
    -- render.SetMaterial( pp_ca_g )
    -- render.DrawScreenQuad()
    -- render.SetMaterial( pp_ca_b )
    -- render.DrawScreenQuad()

    -- Color modify
    DrawColorModify( pp_cc_tab )

    -- Sharpen
    -- DrawSharpen(0.05, 12) -- dont work for some reason

    if atttbl.RTScopeCustomPPFunc then
        atttbl.RTScopeCustomPPFunc(self)
    end
    -- if atttbl.RTScopeMotionBlur then
        -- DrawMotionBlur(0.8, 1, 1/35)

        -- It is bad on some maps (gm_eft_customs for example)
        -- Whole screen becomes picture from sights
        -- We should use delayed low fps rendering like on arccw thermals (wait time before next draw call) 
        -- It'll be better for performance and won't cause any issues
    -- end
end

local vec1 = Vector(1, 1, 1)

local arc9_scope_r = GetConVar("arc9_scope_r")
local arc9_scope_g = GetConVar("arc9_scope_g")
local arc9_scope_b = GetConVar("arc9_scope_b")
local arc9_cheapscopes = GetConVar("arc9_cheapscopes")

function SWEP:DoRTScope(model, atttbl, active)
    local pos = model:GetPos()
    local ang = EyeAngles()

    if active then
        local sightzang = 0
        if self:ShouldDoScope() then
            self.RenderingRTScope = true
            local sight = self:GetSight()
            sightzang = sight.Ang.z
            local sightpos = sight.ShadowPos or (sight.OriginalSightTable or {}).Pos or sight.Pos or Vector(0, 0, 0)
            sightpos = sightpos * ((sight.slottbl or {}).Scale or 1)

            sightpos.x = -sightpos.x -- to fix pso-like side scopes

            pos = pos + (sightpos.x * ang:Right())
            -- pos = pos + (sightpos.y * ang:Forward())
            pos = pos + (sightpos.z * -ang:Up())

            local screenpos

            if sight.BaseSight then
                screenpos = {
                    visible = true,
                    x = ScrW() / 2,
                    y = ScrH() / 2
                }
            else
                screenpos = pos:ToScreen()
            end

            local shadow_intensity = atttbl.RTScopeShadowIntensity or 10

            local sh_x = ((screenpos.x - (ScrW() / 2)) * shadow_intensity)
            local sh_y = ((screenpos.y - (ScrH() / 2)) * shadow_intensity)

            local ret_x = (screenpos.x - (ScrW() / 2)) * 10
            local ret_y = (screenpos.y - (ScrH() / 2)) * 10

            local sh_s = math.floor(rtsize * 1.3)

            sh_x = sh_x - ((sh_s-rtsize) / 2)
            sh_y = sh_y - ((sh_s-rtsize) / 2)

            ret_x = ret_x - ((sh_s-rtsize) / 2)
            ret_y = ret_y - ((sh_s-rtsize) / 2)

            render.PushRenderTarget(rtmat)


            cam.Start2D()

            local reticle = sight.Reticle or atttbl.RTScopeReticle
            local color = atttbl.RTScopeColor or color_white

            if atttbl.RTScopeColorable then
                color = Color(0, 0, 0)
                color.r = arc9_scope_r:GetInt()
                color.g = arc9_scope_g:GetInt()
                color.b = arc9_scope_b:GetInt()
            end

            -- I'm not sure this is a good feature to add
            -- local drawfunc = nil
            local size = rtsize * (atttbl.RTScopeReticleScale or 1)
            -- if atttbl.RTScopeDefer then
            --     local slot = sight.slottbl
            --     for k, v in pairs(slot.SubAttachments) do
            --         local at = ARC9.Attachments[v.Installed or ""]
            --         if at and (at.RTScopeReticle or at.HoloSightReticle) then
            --             reticle = (at.RTScopeReticle or at.HoloSightReticle)
            --             color = (at.RTScopeColor or at.HoloSightColor)
            --             drawfunc = at.HoloSightFunc
            --             size = (at.HoloSightSize and at.HoloSightSize * 0.5) or size
            --             break
            --         end
            --     end
            -- end

            if reticle then
                -- local rtr_x = (rtsize - size) / 2 - (-ret_x - sh_s / 2 + rtsize / 2) * 0.25
                -- local rtr_y = (rtsize - size) / 2 - (-ret_y - sh_s / 2 + rtsize / 2) * 0.25

                local rtr_x = (rtsize - size) / 2
                local rtr_y = (rtsize - size) / 2

                if atttbl.RTScopeBlackBox != false then
                    surface.SetDrawColor(0, 0, 0)
                    surface.DrawRect(rtr_x - size * 4, rtr_y - size * 8, size * 8, size * 8) -- top
                    surface.DrawRect(rtr_x - size * 8, rtr_y - size * 4, size * 8, size * 8) -- left
                    surface.DrawRect(rtr_x - size * 4, rtr_y + size - 1, size * 8, size * 8) -- bottom
                    surface.DrawRect(rtr_x + size - 1, rtr_y - size * 4, size * 8, size * 8) -- right

                    if atttbl.RTScopeBlackBoxShadow != false then
                        surface.SetMaterial(shadow2)
                        surface.SetDrawColor(0, 0, 0)
                        surface.DrawTexturedRect(rtr_x, rtr_y, size, size)
                    end
                end
                -- surface.DrawTexturedRect((rtsize - size) / 2, (rtsize - size) / 2, size, size)
                -- surface.DrawTexturedRectUV((rtsize - size) / 2, (rtsize - size) / 2, size, size, 1, 0, 0, 1)

                surface.SetDrawColor(color)
                surface.SetMaterial(reticle)
                -- surface.DrawTexturedRect(rtr_x, rtr_y, size, size)
                local counterrotation = (self.LastViewModelAng and self.LastViewModelAng.z or 0) - sightzang + self.SubtleVisualRecoilAng.z * 2 - EyeAngles().z
                surface.DrawTexturedRectRotated(size / 2 + rtr_x, size / 2 + rtr_y, size, size, -counterrotation)
            end

            if atttbl.RTScopeDrawFunc then
                atttbl.RTScopeDrawFunc(self, rtsize, sight)
            end

            -- if drawfunc then -- doesn't seem to be working
            --     drawfunc(self, pos, model)
            -- end

            if !atttbl.RTScopeNoShadow then
                surface.SetDrawColor(0, 0, 0)
                surface.SetMaterial(shadow)
                surface.DrawTexturedRect(sh_x, sh_y, sh_s, sh_s)

                if !screenpos.visible then
                    surface.SetDrawColor(0, 0, 0)
                    surface.DrawRect(0, 0, rtsize, rtsize)
                else
                    surface.SetDrawColor(0, 0, 0)
                    surface.DrawRect(sh_x - sh_s * 4, sh_y - sh_s * 8, sh_s * 8, sh_s * 8) -- top
                    surface.DrawRect(sh_x - sh_s * 8, sh_y - sh_s * 4, sh_s * 8, sh_s * 8) -- left
                    surface.DrawRect(sh_x - sh_s * 4, sh_y + sh_s, sh_s * 8, sh_s * 8) -- bottom
                    surface.DrawRect(sh_x + sh_s, sh_y - sh_s * 4, sh_s * 8, sh_s * 8) -- right
                end
            end
        else
            render.PushRenderTarget(rtmat)
            cam.Start2D()
        end

        local sd = self:GetSightAmount()

        surface.SetDrawColor(0, 0, 0, 255 * (1 - sd))
        surface.DrawRect(0, 0, rtsize, rtsize)

        cam.End2D()

        render.PopRenderTarget()
        -- if sd > 0 then render.SetToneMappingScaleLinear(render.GetToneMappingScaleLinear()*0.2) end

        if sd > 0.33 then render.SetToneMappingScaleLinear(LerpVector(sd * 1.5 - 0.5, render.GetToneMappingScaleLinear(), vec1)) end

        local counterrotation = self.LastViewModelAng.z - sightzang + (arc9_cheapscopes:GetBool() and 0 or self.SubtleVisualRecoilAng.z * 2) - EyeAngles().z
        -- rtsurf:SetTexture("$basetexture", rtmat)
        rtsurf:SetFloat("$rot", ((atttbl.RTScopeShadowIntensity or 0) > 1 or atttbl.RTCollimator) and counterrotation or 0)
        -- rtsurf:SetMatrix("$basetexturetransform", Matrix({{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}))

        -- model:SetSubMaterial()

        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "effects/arc9/rt")
    else
        -- model:SetSubMaterial()
        rtsurf:SetTexture("$basetexture", "vgui/black")
        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "vgui/black")
    end

    -- if atttbl.RTScopeUseSubmatReticle then        gross
    --     atttbl.RTScopeReticle:SetInt("$flags", bit.bor(32768, 2097152))
    --     atttbl.RTScopeReticle:SetVector("$color2", Vector(atttbl.RTScopeColor or color_white))
    --     model:SetSubMaterial(atttbl.RTScopeReticleSubmatIndex, "!"..atttbl.RTScopeReticle:GetName())
    -- end
end

function SWEP:GetCheapScopeScale(scale)
    local ratio = scale - (!self.ExtraSightDistanceNoRT and self:GetSight().ExtraSightDistance or 0) * 0.045

    return 1 / ratio * (ScrW() / ScrH() / 1.12)
end

local hascostscoped = false

function SWEP:DoCheapScope(fov, atttbl)
    if !self:ShouldDoScope() then
        render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)
        render.Clear(0, 0, 0, 255, true, true)
        render.PopRenderTarget()

        return
    end

    if !hascostscoped then
        self:DoRT(fov, atttbl)
        hascostscoped = true
    end

    ARC9:DrawPhysBullets()

    self:DrawLockOnHUD(true)

    render.UpdateScreenEffectTexture()
    render.UpdateFullScreenDepthTexture()
    local screen = render.GetScreenEffectTexture()

    render.CopyTexture( screen, rtmat_spare )

    local scrw = ScrW()
    local scrh = ScrH()

    scrw = scrw
    scrh = scrh * scrh / scrw

    local s = self:GetCheapScopeScale(atttbl.ScopeScreenRatio or 0.5)

    local scrx = (ScrW() - scrw * s) / 2
    local scry = (ScrH() - scrh * s) / 2

    -- scrx = scrx + 8
    -- scry = scry + 8

    cam.Start3D()
    if atttbl.RTScopeFLIR then
        self:DoFLIR(atttbl)
    end
    cam.End3D()

    local sighttbl = self:GetSight()

    render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)

    -- cam.Start2D()

    render.DrawTextureToScreenRect(screen, scrx, scry, scrw * s, scrh * s)
    -- render.DrawTextureToScreenRect(ITexture tex, number x, number y, number width, number height)
    -- cam.End2D()

    cam.Start3D(nil, nil, fov, 0, 0, rtsize, rtsize)
        cam.IgnoreZ(true)
        self:DrawLasers(false, true)
        cam.IgnoreZ(false)
    cam.End3D()

    if atttbl.RTScopeNightVision then
        self:DoNightScopeEffects(atttbl)
    end

    self:DoRTScopeEffects()

    render.PopRenderTarget()

    render.DrawTextureToScreen(rtmat_spare)
    render.UpdateFullScreenDepthTexture()

    if sighttbl.InvertColors then

        render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)

            render.CopyTexture( rtmat, rtmat_spare )

            render.Clear(255, 255, 255, 255, true, true)
            render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_REVERSE_SUBTRACT)

            render.DrawTextureToScreen(rtmat_spare)

            render.OverrideBlend(false)

        render.PopRenderTarget()
    end
end

]]--