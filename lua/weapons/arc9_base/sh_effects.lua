function SWEP:DoEffects()
    if !IsFirstTimePredicted() then return end
    local muzz_qca = self:GetQCAMuzzle()

    local data = EffectData()
    data:SetEntity(self)
    data:SetAttachment(muzz_qca)

    local muzzle = "ARC9_muzzleeffect"

    if !self:GetProcessedValue("MuzzleParticle") and self:GetProcessedValue("MuzzleEffect") then
        muzzle = self:GetProcessedValue("MuzzleEffect")
        data:SetScale(1)
        data:SetFlags(0)
        data:SetEntity(self:GetVM())
    end

    util.Effect( muzzle, data )
end

function SWEP:GetQCAMuzzle()
    return self:GetProcessedValue("MuzzleEffectQCA")
end

function SWEP:GetQCAEject()
    return self:GetProcessedValue("CaseEffectQCA")
end

SWEP.EjectedShells = {}

function SWEP:DoEject()
    if !IsFirstTimePredicted() then return end

    if self:GetProcessedValue("NoShellEject") then return end

    local eject_qca = self:GetQCAEject()

    local data = EffectData()
    data:SetEntity(self)
    data:SetAttachment(eject_qca)

    util.Effect("ARC9_shelleffect", data)
end

function SWEP:GetTracerOrigin()
    local ow = self:GetOwner()
    local wm = ow:IsNPC() or !ow:IsValid() or !ow:GetViewModel():IsValid() or ow:ShouldDrawLocalPlayer()
    local att = self:GetQCAMuzzle()
    local muzz = self

    if !wm then
        muzz = ow:GetViewModel()
    end

    if muzz and muzz:IsValid() then
        local posang = muzz:GetAttachment(att)
        if !posang then return muzz:GetPos() end
        local pos = posang.Pos

        return pos
    end
end

function SWEP:GetMuzzleDevice(wm)
    local model
    local muzz

    if wm then
        model = self.WModel
        muzz = self:GetWM()

        if self.MuzzleDeviceWM then
            return self.MuzzleDeviceWM
        end
    else
        model = self.VModel
        muzz = self:GetVM()

        if self.MuzzleDeviceVM then
            return self.MuzzleDeviceVM
        end
    end

    if model then
        for i, k in pairs(model) do
            if k.IsMuzzleDevice then
                return k
            end
        end
    end

    return muzz
end

function SWEP:DrawEjectedShells()
    local newshells = {}

    for i, k in pairs(self.EjectedShells) do
        if !k:IsValid() then continue end

        k:DrawModel()
        table.insert(newshells, k)
    end

    self.EjectedShells = newshells
end