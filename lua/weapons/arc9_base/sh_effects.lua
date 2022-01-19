function SWEP:DoEffects()
    if !IsFirstTimePredicted() then return end
    local muzz_qca = self:GetQCAMuzzle()

    local data = EffectData()
    data:SetEntity(self)
    data:SetAttachment(muzz_qca)

    util.Effect( "ARC9_muzzleeffect", data )
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

    local eject_qca = self:GetQCAEject()

    local data = EffectData()
    data:SetEntity(self)
    data:SetFlags(2)
    data:SetAttachment(eject_qca)

    util.Effect("ARC9_shelleffect", data)
end

function SWEP:GetTracerOrigin()
    local ow = self:GetOwner()
    local wm = !ow:GetViewModel():IsValid() or ow:ShouldDrawLocalPlayer()
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
    local model = self.VModel
    local muzz = self:GetVM()

    if wm then
        model = self.WModel
        muzz = self:GetWM()
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