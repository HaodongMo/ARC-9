function SWEP:DoHolosight(mdl, atttbl)
    if self:GetSightAmount() <= 0 then return end
    if ARC9.OverDraw then return end
    if self:GetOwner() != LocalPlayer() then return end

    local ref = 56

    -- render.ClearDepth()

    render.UpdateScreenEffectTexture()
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_REPLACE)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)

    render.SetBlend(0)

    render.SetStencilReferenceValue(ref)

    -- render.OverrideDepthEnable(true, true)
    mdl:DrawModel()
    -- render.OverrideDepthEnable(false, false)
    -- cam.IgnoreZ(true)

    render.SetBlend(1)

    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_EQUAL)

    -- render.ClearBuffersObeyStencil(0, 0, 0, 0, true)
    -- render.ClearDepth()

    -- render.SetColorMaterial()
    -- render.DrawScreenQuad()

    -- cam.Start2D()

    -- surface.SetDrawColor(255, 255, 255)
    -- surface.DrawRect(0, 0, ScrW(), ScrH())

    -- render.SetColorMaterial()
    -- render.DrawScreenQuad()

    local img = atttbl.HoloSightReticle

    -- local eyedist = WorldToLocal(mdl:GetPos(), mdl:GetAngles(), EyePos(), EyeAngles()).x

    -- render.DepthRange(0, 0.0095 + (0.0003 * eyedist / 20))

    self:SetHoloSightRenderDepth(mdl, atttbl.HoloSightDepthAdjustment)

    -- render.DepthRange(0, 0.0098)

    if img then
        local pos = self:GetOwner():EyePos()

        pos = pos + mdl:GetAngles():Forward() * 9000

        -- cam.Start3D()
        -- local dist = (mdl:GetPos() - self:GetOwner():EyePos()):Length()
        -- local s = atttbl.HoloSightSize / math.Clamp(dist / 7, 0.5, 3)
        local s = atttbl.HoloSightSize

        local col = atttbl.HoloSightColor or Color(255, 255, 255)

        if atttbl.HoloSightColorable then
            col = Color(0, 0, 0)
            col.r = GetConVar("arc9_reflex_r"):GetFloat()
            col.g = GetConVar("arc9_reflex_g"):GetFloat()
            col.b = GetConVar("arc9_reflex_b"):GetFloat()
        end

        render.SetMaterial(img)

        local up = mdl:GetAngles():Up()
        local right = mdl:GetAngles():Right()

        local v1 = pos + (up * s / 2) - (right * s / 2)
        local v2 = pos + (up * s / 2) + (right * s / 2)
        local v3 = pos - (up * s / 2) + (right * s / 2)
        local v4 = pos - (up * s / 2) - (right * s / 2)


        -- render.DrawQuadEasy(pos, -mdl:GetAngles():Forward(), s, s, atttbl.HoloSightColor or Color(255, 255, 255))

        render.DrawQuad(v1, v2, v3, v4, col or Color(255, 255, 255))

        if atttbl.HoloSightFunc then
            atttbl.HoloSightFunc(self, pos, mdl)
        end

        -- local toscreen = pos:ToScreen()

        -- local x = toscreen.x
        -- local y = toscreen.y

        -- local ss = ScreenScale(32)
        -- local sx = x - (ss / 2)
        -- local sy = y - (ss / 2)

        -- local shakey = math.min(cross * 35, 3)

        -- sx = sx + math.Round(math.Rand(-shakey, shakey))
        -- sy = sy + math.Round(math.Rand(-shakey, shakey))

        -- surface.SetMaterial(img)
        -- surface.SetDrawColor(255, 255, 255, 255)
        -- surface.DrawTexturedRect(sx, sy, ss, ss)

        -- surface.SetDrawColor(0, 0, 0)
        -- surface.DrawRect(0, 0, w, sy)
        -- surface.DrawRect(0, sy + ss, w, h - sy)

        -- surface.DrawRect(0, 0, sx, h)
        -- surface.DrawRect(sx + ss, 0, w - sx, h)
    end
    -- cam.End2D()


    render.DepthRange(0, 1)

    render.SetStencilEnable(false)

    -- mdl:DrawModel()
end

function SWEP:SetHoloSightRenderDepth(mdl, depthadj)
    local eyedist = WorldToLocal(mdl:GetPos(), mdl:GetAngles(), EyePos(), EyeAngles()).x

    render.DepthRange(0, (depthadj or 0.0093) + (0.0004 * eyedist / 20))
    -- render.DepthRange(0, (eyedist + 77.99) / 10000)
end