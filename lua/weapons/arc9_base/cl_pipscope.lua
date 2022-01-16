local rtmat = GetRenderTarget("arc9_pipscope", 512, 512, false)

local rtsize = 512

function SWEP:ShouldDoScope()
    if self:GetSight().Disassociate then return false end

    return true
end

function SWEP:DoRT(fov)
    if ARC9.OverDraw then return end

    local rt = {
        x = 0,
        y = 0,
        w = rtsize,
        h = rtsize,
        angles = self:GetShootDir(),
        origin = self:GetOwner():GetShootPos(),
        drawviewmodel = false,
        fov = fov,
    }

    render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)

    if self:ShouldDoScope() then
        ARC9.OverDraw = true
        render.RenderView(rt)
        ARC9.OverDraw = false
    else
        render.Clear(0, 0, 0, 255, true, true)
    end

    self:DoRTScopeEffects()

    render.PopRenderTarget()
end

local rtsurf = Material("effects/arc9_rt")
local shadow = Material("arc9/shadow.png", "mips smooth")

local matRefract = Material("pp/arc9/refract_rt")
local pp_ca_base, pp_ca_r, pp_ca_g, pp_ca_b = Material("pp/arc9/ca_base"), Material("pp/arc9/ca_r"), Material("pp/arc9/ca_g"), Material("pp/arc9/ca_b")

-- local pp_cc_tab = {
--     [ "$pp_colour_brightness" ] = -0.15,
--     [ "$pp_colour_contrast" ] = 1,
--     [ "$pp_colour_colour" ] = 1,
-- }

function SWEP:DoRTScopeEffects()
    if !render.SupportsPixelShaders_2_0() then return end

    local refractratio = 0.15
    local refractamount = (-0.6 + 1 / 30) * refractratio

    matRefract:SetFloat( "$refractamount", refractamount )
    pp_ca_base:SetTexture("$basetexture", rtmat)
    pp_ca_r:SetTexture("$basetexture", rtmat)
    pp_ca_g:SetTexture("$basetexture", rtmat)
    pp_ca_b:SetTexture("$basetexture", rtmat)

    render.SetMaterial( pp_ca_base )
    render.DrawScreenQuad()
    render.SetMaterial( pp_ca_r )
    render.DrawScreenQuad()
    render.SetMaterial( pp_ca_g )
    render.DrawScreenQuad()
    render.SetMaterial( pp_ca_b )
    render.DrawScreenQuad()

    -- Color modify
    -- DrawColorModify( pp_cc_tab )

    -- Sharpen
    -- DrawSharpen(-0.5, 5) -- dont work for some reason

    render.SetMaterial(matRefract)
    render.DrawScreenQuad()
end

function SWEP:DoRTScope(model, atttbl)
    local pos = model:GetPos()
    local ang = EyeAngles()

    local sightpos = (self:GetSight().OriginalSightTable or {}).Pos or Vector(0, 0, 0)

    pos = pos + (sightpos.x * ang:Right())
    -- pos = pos + (sightpos.y * ang:Forward())
    pos = pos + (sightpos.z * -ang:Up())

    local screenpos = pos:ToScreen()

    local sh_x = (screenpos.x - (ScrW() / 2)) + (rtsize / 2)
    local sh_y = (screenpos.y - (ScrH() / 2)) + (rtsize / 2)

    local sh_s = math.floor(rtsize * 1)

    sh_x = sh_x - (sh_s / 2)
    sh_y = sh_y - (sh_s / 2)

    render.PushRenderTarget(rtmat)

    cam.Start2D()

    if self:ShouldDoScope() then

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(atttbl.RTScopeReticle)
        surface.DrawTexturedRect(0, 0, rtsize, rtsize)

        surface.SetDrawColor(0, 0, 0)
        surface.SetMaterial(shadow)
        surface.DrawTexturedRect(sh_x, sh_y, sh_s, sh_s)

        if !screenpos.visible then
            surface.DrawRect(0, 0, rtsize, rtsize)
        else
            surface.DrawRect(sh_x - rtsize, sh_y - rtsize, rtsize * 4, rtsize)
            surface.DrawRect(sh_x - rtsize, sh_y - rtsize, rtsize, rtsize * 4)
            surface.DrawRect(sh_x + sh_s, sh_y - rtsize, rtsize, rtsize * 4)
            surface.DrawRect(sh_x - rtsize, sh_y + sh_s, rtsize * 4, rtsize)
        end

    end

    surface.SetDrawColor(0, 0, 0, 255 * (1 - self:GetSightAmount()))
    surface.DrawRect(0, 0, rtsize, rtsize)

    cam.End2D()

    render.PopRenderTarget()

    rtsurf:SetTexture("$basetexture", rtmat)

    model:SetSubMaterial()

    model:SetSubMaterial(atttbl.RTScopeSubmatIndex, "effects/arc9_rt")
end

local hascostscoped = false

function SWEP:DoCheapScope(fov)
    if !self:ShouldDoScope() then
        render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)
        render.Clear(0, 0, 0, 255, true, true)
        render.PopRenderTarget()

        return
    end

    local scrw = ScrW()
    local scrh = ScrH()

    scrw = scrw
    scrh = scrh * scrh / scrw

    local s = 4

    local scrx = (ScrW() - scrw * s) / 2
    local scry = (ScrH() - scrh * s) / 2

    scrx = scrx + 8
    scry = scry + 8

    local pos = self:GetOwner():GetShootPos() + (self:GetShootDir():Forward() * 12000)

    local screenpos = pos:ToScreen()

    scrx = scrx - (screenpos.x - (ScrW() / 2)) * s / 1.4
    scry = scry - (screenpos.y - (ScrH() / 2)) * s / 1.4

    ARC9:DrawPhysBullets()

    render.UpdateScreenEffectTexture()
    local screen = render.GetScreenEffectTexture()
    render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)

    -- cam.Start2D()
    render.DrawTextureToScreenRect(screen, scrx, scry, scrw * s, scrh * s)
    -- render.DrawTextureToScreenRect(ITexture tex, number x, number y, number width, number height)
    -- cam.End2D()

    self:DoRTScopeEffects()

    render.PopRenderTarget()
end