-- Render thermal highlighting to the currently active RT.

local lastentcount = 0
local lastents = {}

local coldtime = 20

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

local ref = 32

function SWEP:DoFLIR(atttbl)
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.ClearStencil()

    -- local targets = ents.FindInCone(EyePos(), EyeAngles():Forward(), atttbl.RTScopeFLIRRange or 30000, math.cos(fov + 5))
    local targets = lastents
    local entcount = ents.GetCount()

    if lastentcount != entcount then
        targets = ents.GetAll()
        lastents = targets
    end

    lastentcount = entcount

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
        if atttbl.FLIRHotFunc then
            hot = atttbl.FLIRHotFunc(self, ent)
        end

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
    render.SetStencilPassOperation(STENCIL_KEEP)

    if atttbl.RTScopeFLIRSolid then
        render.SetColorMaterial()
        render.DrawScreenQuad()
    end

    if atttbl.RTScopeFLIRMonochrome then
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        DrawColorModify(monochrometable)
    end

    if atttbl.RTScopeFLIRCCCold then
        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        DrawColorModify(atttbl.RTScopeFLIRCCCold)
        -- DrawColorModify(atttbl.RTScopeFLIRCCHot)
    end

    if atttbl.RTScopeFLIRCCHot then
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        DrawColorModify(atttbl.RTScopeFLIRCCHot)
    end

    render.UpdateScreenEffectTexture()

    if atttbl.RTScopeFLIRFunc then
        atttbl.RTScopeFLIRFunc(self)
    end

    if atttbl.RTScopeFLIRHotOnlyFunc then
        atttbl.RTScopeFLIRHotOnlyFunc(self)
    end

    render.SetStencilEnable(false)
end

local maxrange = (160/ARC9.HUToM)^2 -- 160 m

function SWEP:GetEntityHot(ent)
    if !ent:IsValid() or ent:IsWorld() then return false end

    if self:GetPos():DistToSqr(ent:GetPos()) > maxrange then return end

    if ent:IsPlayer() then
        if ent.ArcticMedShots_ActiveEffects and ent.ArcticMedShots_ActiveEffects["coldblooded"] or ent:Health() <= 0 then return false end -- arc stims
        return true
    end

    if ent:IsNPC() or ent:IsNextBot() then -- npcs
        if ent.ARC9CLHealth and ent.ARC9CLHealth <= 0 or ent:Health() <= 0 then return false end
        return true
    end

    if ent:IsRagdoll() then -- ragdolling
        if !ent.ARC9_ColdTime then ent.ARC9_ColdTime = CurTime() + coldtime end
        return ent.ARC9_ColdTime > CurTime()
    end

    if ent:IsVehicle() or ent:IsOnFire() or ent.ArcCW_Hot or ent:IsScripted() and !ent:GetOwner():IsValid() then -- arccw_hot for compatibillity
        return true
    end

    return false
end