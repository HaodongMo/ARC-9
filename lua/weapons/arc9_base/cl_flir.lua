-- Render thermal highlighting to the currently active RT.

local color = Material("vgui/white")

function SWEP:DoFLIR(atttbl)
    local ref = 32

    render.SetStencilEnable(true)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.ClearStencil()

    -- local targets = ents.FindInCone(EyePos(), EyeAngles():Forward(), atttbl.RTScopeFLIRRange or 30000, math.cos(fov + 5))
    local targets = ents.GetAll()

    render.SuppressEngineLighting(true)

    if !atttbl.RTScopeFLIRSolid then
        render.SetBlend(atttbl.RTScopeFLIRBlend or 0.25)
        render.SetColorModulation(250, 250, 250)
    else
        render.SetBlend(0)
    end

    cam.IgnoreZ(false)

    render.SetStencilReferenceValue(ref)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)

    for _, ent in ipairs(targets) do
        if ent == self:GetOwner() then continue end
        local hot = self:GetEntityHot(ent)

        if !hot then continue end

        ent:DrawModel()
    end

    cam.IgnoreZ(true)

    render.SetColorModulation(1, 1, 1)
    render.SuppressEngineLighting(false)
    render.MaterialOverride()
    render.SetBlend(1)

    render.SetStencilReferenceValue(ref)
    render.SetStencilCompareFunction(STENCIL_EQUAL)

    if atttbl.RTScopeFLIRSolid then
        render.SetColorMaterial()
        render.DrawScreenQuad()
    end

    if atttbl.RTScopeFLIRMonochrome then
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

    if atttbl.RTScopeFLIRCC then
        DrawColorModify(atttbl.RTScopeFLIRCC)
    end

    if atttbl.RTScopeFLIRFunc then
        atttbl.RTScopeFLIRFunc(self)
    end

    render.SetStencilEnable(false)
end

function SWEP:GetEntityHot(ent)
    if !IsValid(ent) then return end
    if ent:IsWorld() then return end
    if (ent.Health and (ent:Health() <= 0)) then return end
    if ent:IsOnFire() then return true end

    if ent.ARC9HotFunc then
        return ent:ARC9HotFunc()
    end

    if ent:IsPlayer() then
        if ent.ArcticMedShots_ActiveEffects and ent.ArcticMedShots_ActiveEffects["coldblooded"] then
            return false
        end

        return true
    end

    if ent:IsNextBot() then return true end
    if (ent:IsNPC()) then
        if ent.ARC9CLHealth and ent.ARC9CLHealth <= 0 then return false end
        if (ent.Health and (ent:Health() > 0)) then return true end
    elseif (ent:IsRagdoll()) then
        local Time = CurTime()
        if !ent.ARC9_ColdTime then ent.ARC9_ColdTime = Time + coldtime end
        return ent.ARC9_ColdTime > Time
    elseif (ent:IsVehicle()) then
        return true
    end

    return false
end