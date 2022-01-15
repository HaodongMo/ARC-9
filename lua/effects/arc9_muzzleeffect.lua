function EFFECT:Init(data)
    local wpn = data:GetEntity()

    if !IsValid(wpn) then self:Remove() return end

    local muzzle = wpn:GetValue("MuzzleEffect")

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

    parent = wpn:GetMuzzleDevice(wm)

    -- if !IsValid(parent) then return end

    if muzzle then
        ParticleEffectAttach(muzzle, PATTACH_POINT_FOLLOW, parent, att)
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
    return false
end