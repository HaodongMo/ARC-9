function EFFECT:Init(data)
    local wpn = data:GetEntity()

    if !IsValid(wpn) then self:Remove() return end

    local muzzle = wpn:GetValue("MuzzleParticle")

    local att = data:GetAttachment() or 1

    local wm = false

    if (LocalPlayer():ShouldDrawLocalPlayer() or wpn.Owner != LocalPlayer()) then
        wm = true
        att = 1
    end

    local parent = wpn

    if !wm then
        parent = LocalPlayer():GetViewModel()
    end

    local pa = parent:GetAttachment(att)
    local pos = pa.Pos

    parent = wpn:GetMuzzleDevice(wm)

    -- if !IsValid(parent) then return end

    if muzzle then
        ParticleEffectAttach(muzzle, PATTACH_POINT_FOLLOW, parent, att)
    end

    if !wpn:GetProcessedValue("Silencer") and !wpn:GetProcessedValue("NoFlash") then
        local light = DynamicLight(self:EntIndex())
        local clr = Color(244, 209, 66)
        if (light) then
            light.Pos = pos
            light.r = clr.r
            light.g = clr.g
            light.b = clr.b
            light.Brightness = 2
            light.Decay = 2500
            light.Size = wpn:GetOwner() == LocalPlayer() and 256 or 128
            light.DieTime = CurTime() + 0.1
        end
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
    return false
end