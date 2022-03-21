local rtsize = 1024 -- better use scrh()

local rtmat = GetRenderTarget("arc9_pipscope2", rtsize, rtsize, false)

matproxy.Add({
    name = "arc9_scope_alpha",
    init = function(self, mat, values)
        self.ResultTo = values.resultvar
    end,
    bind = function(self, mat, ent)
        local ply = LocalPlayer() -- we re on client, right?
        if IsValid(ply) then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) and weapon.ARC9 then
                local amt = 1 - weapon:GetSightAmount() / 3

                if render.GetHDREnabled() and amt < 0.07 then
                    render.SetToneMappingScaleLinear(Vector(1,1,1)) -- hdr fix
                end

                mat:SetVector(self.ResultTo, Vector(amt,amt,amt))
            end
        end
   end
})

function SWEP:ShouldDoScope()
    if self:GetSight().Disassociate then return false end

    return true
end

function SWEP:DoRT(fov, atttbl)
    if ARC9.OverDraw then return end

    local rtpos = self.LastViewModelPos
    rtpos = rtpos - self.LastViewModelAng:Right() * self.ViewModelPos.x
    rtpos = rtpos - self.LastViewModelAng:Forward() * (self.ViewModelPos.y - (self:GetSight().atttbl.ScopeLength or 20))
    rtpos = rtpos - self.LastViewModelAng:Up() * self.ViewModelPos.z

    local rtang = self.LastViewModelAng

    local rt = {
        x = 0,
        y = 0,
        w = rtsize,
        h = rtsize,
        angles = rtang,
        origin = rtpos,
        drawviewmodel = false,  -- for some reason, turning it on makes everything black. 
                                -- gun render in scope is fine rn (except fov, maybe copy it from arccw).  
                                -- also i found out that if comment out 2d stuff (shadow and reticle), everything becomes as it should be. might be some problem with cam2d.
                                -- if you can fix it it will be very cool
        fov = fov,
        znear = 16,
        zfar = 30000
    }

    render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)

    if self:ShouldDoScope() then
        ARC9.OverDraw = true
        render.RenderView(rt)
        ARC9.OverDraw = false

        cam.Start3D(nil, nil, fov, 0, 0, rtsize, rtsize)
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

    self:DoRTScopeEffects()

    render.PopRenderTarget()
end

local rtsurf = Material("effects/arc9/rt")
local shadow = Material("arc9/shadow.png", "mips smooth")

local pp_ca_base, pp_ca_r, pp_ca_g, pp_ca_b = Material("pp/arc9/ca_base"), Material("pp/arc9/ca_r"), Material("pp/arc9/ca_g"), Material("pp/arc9/ca_b")

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

local noise = Material("arc9/nvnoise")

function SWEP:DoNightScopeEffects(atttbl)
    if atttbl.RTScopeNightVisionMonochrome then
        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
    end

    if !atttbl.RTScopeNightVisionNoPP then
        cam.Start2D()
        surface.SetMaterial(noise)
        surface.SetDrawColor(atttbl.RTScopeNightVisionNoiseColor or Color(255, 255, 255))
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

    pp_ca_r:SetTexture("$basetexture", rtmat)
    pp_ca_g:SetTexture("$basetexture", rtmat)
    pp_ca_b:SetTexture("$basetexture", rtmat)

    render.SetMaterial( pp_ca_r )
    render.DrawScreenQuad()
    render.SetMaterial( pp_ca_g )
    render.DrawScreenQuad()
    render.SetMaterial( pp_ca_b )
    render.DrawScreenQuad()

    -- Color modify
    DrawColorModify( pp_cc_tab )

    -- Sharpen
    -- DrawSharpen(0.05, 12) -- dont work for some reason

    if atttbl.RTScopeMotionBlur then
        DrawMotionBlur(0.1, 0.5, 0)
    end

end

function SWEP:DoRTScope(model, atttbl, active)
    local pos = model:GetPos()
    local ang = EyeAngles()

    if active then
        if self:ShouldDoScope() then
            local sightpos = (self:GetSight().OriginalSightTable or {}).Pos or Vector(0, 0, 0)
            sightpos = sightpos * ((self:GetSight().slottbl or {}).Scale or 1)

            pos = pos + (sightpos.x * ang:Right())
            -- pos = pos + (sightpos.y * ang:Forward())
            pos = pos + (sightpos.z * -ang:Up())

            local screenpos = pos:ToScreen()

            local shadow_intensity = atttbl.RTScopeShadowIntensity or 30

            local sh_x = ((screenpos.x - (ScrW() / 2)) * shadow_intensity)
            local sh_y = ((screenpos.y - (ScrH() / 2)) * shadow_intensity)

            local sh_s = math.floor(rtsize * 1.3)

            sh_x = sh_x - ((sh_s-rtsize) / 2)
            sh_y = sh_y - ((sh_s-rtsize) / 2)

            render.PushRenderTarget(rtmat)
            cam.Start2D()

            local reticle = atttbl.RTScopeReticle
            local color = atttbl.RTScopeColor or color_white

            if atttbl.RTScopeColorable then
                color = Color(0, 0, 0)
                color.r = GetConVar("arc9_scope_r"):GetInt()
                color.g = GetConVar("arc9_scope_g"):GetInt()
                color.b = GetConVar("arc9_scope_b"):GetInt()
            end

            -- I'm not sure this is a good feature to add
            -- local drawfunc = nil
            local size = rtsize
            -- if atttbl.RTScopeDefer then
            --     local slot = self:GetSight().slottbl
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
                surface.SetDrawColor(color)
                surface.SetMaterial(reticle)
                surface.DrawTexturedRect((rtsize - size) / 2, (rtsize - size) / 2, size, size)
            end

            if atttbl.RTScopeDrawFunc then
                atttbl.RTScopeDrawFunc(self, rtsize)
            end

            if drawfunc then -- doesn't seem to be working
                drawfunc(self, pos, model)
            end

            if !atttbl.RTScopeNoShadow then
                surface.SetDrawColor(0, 0, 0)
                surface.SetMaterial(shadow)
                surface.DrawTexturedRect(sh_x, sh_y, sh_s, sh_s)
            end

            if !screenpos.visible then
                surface.DrawRect(0, 0, rtsize, rtsize)
            else
                surface.DrawRect(sh_x - sh_s * 4, sh_y - sh_s * 8, sh_s * 8, sh_s * 8) -- top
                surface.DrawRect(sh_x - sh_s * 8, sh_y - sh_s * 4, sh_s * 8, sh_s * 8) -- left
                surface.DrawRect(sh_x - sh_s * 4, sh_y + sh_s, sh_s * 8, sh_s * 8) -- bottom
                surface.DrawRect(sh_x + sh_s, sh_y - sh_s * 4, sh_s * 8, sh_s * 8) -- right
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

        rtsurf:SetTexture("$basetexture", rtmat)

        model:SetSubMaterial()

        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "effects/arc9/rt")
    else
        model:SetSubMaterial()
        model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "vgui/black")
    end

    -- if atttbl.RTScopeUseSubmatReticle then        gross
    --     atttbl.RTScopeReticle:SetInt("$flags", bit.bor(32768, 2097152))
    --     atttbl.RTScopeReticle:SetVector("$color2", Vector(atttbl.RTScopeColor or color_white))
    --     model:SetSubMaterial(atttbl.RTScopeReticleSubmatIndex, "!"..atttbl.RTScopeReticle:GetName())
    -- end
end

function SWEP:GetCheapScopeScale(scale)
    return 2 / (scale or 0.5)
end

local hascostscoped = false
local rtmat_spare = GetRenderTarget("arc9_rtmat_spare", ScrW(), ScrH(), false)

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

    render.UpdateScreenEffectTexture()
    render.UpdateFullScreenDepthTexture()
    local screen = render.GetScreenEffectTexture()

    render.CopyTexture( screen, rtmat_spare )

    local scrw = ScrW()
    local scrh = ScrH()

    scrw = scrw
    scrh = scrh * scrh / scrw

    local s = self:GetCheapScopeScale(atttbl.ScopeScreenRatio)

    local scrx = (ScrW() - scrw * s) / 2
    local scry = (ScrH() - scrh * s) / 2

    scrx = scrx + 8
    scry = scry + 8

    cam.Start3D()
    if atttbl.RTScopeFLIR then
        self:DoFLIR(atttbl)
    end
    cam.End3D()

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
end