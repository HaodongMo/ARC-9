function SWEP:DoEffects()
    if !IsFirstTimePredicted() then return end
    if self:GetProcessedValue("NoMuzzleEffect", true) then return end

    local muzz_qca = self:GetQCAMuzzle()

    local data = EffectData()
    data:SetEntity(self)
    data:SetAttachment(muzz_qca)
    data:SetSurfaceProp(self:GetNthShot() % 2) -- hopefully nobody uses this on a muzzle effect

    local muzzle = "arc9_muzzleeffect"

    local muzefect = self:GetProcessedValue("MuzzleEffect", true)

    if !self:GetProcessedValue("MuzzleParticle", true) and muzefect then
        muzzle = muzefect
        data:SetScale(1)
        data:SetFlags(0)
        data:SetEntity(self:GetVM())
    end

    util.Effect(muzzle, data, true)

    if IsValid(self.ActiveAfterShotPCF) then
        self.ActiveAfterShotPCF:StopEmission()
    end
end

function SWEP:GetQCAMuzzle()
    return self:GetProcessedValue("MuzzleEffectQCA", true)
end

function SWEP:GetQCAEject()
    return self:GetProcessedValue("CaseEffectQCA", true)
end

function SWEP:GetQCAMagdrop()
    return self:GetProcessedValue("DropMagazineQCA", true) or self:GetProcessedValue("CaseEffectQCA", true)
end

SWEP.EjectedShells = {}

function SWEP:DoEject(index, attachment)
    if !IsFirstTimePredicted() then return end

    -- if self:GetProcessedValue("NoShellEject") then return end

    local eject_qca = attachment or self:GetQCAEject()

    local data = EffectData()
    data:SetEntity(self)
    data:SetAttachment(eject_qca)
    data:SetFlags(index or 0)

    for i = 1, self:GetProcessedValue("ShellEffectCount", true) do
        util.Effect(self:GetProcessedValue("ShellEffect", true) or "ARC9_shelleffect", data, true)
    end
end

function SWEP:GetTracerOrigin()
    local ow = self:GetOwner()
    local vm = ow.GetViewModel and ow:GetViewModel() or nil
    local wm = ow:IsNPC() or !ow:IsValid() or !vm:IsValid() or ow:ShouldDrawLocalPlayer()
    local att = self:GetQCAMuzzle()
    local muzz = self

    if !wm then
        muzz = vm
    end

    if muzz and muzz:IsValid() then
        local posang = muzz:GetAttachment(att)
        if !posang then return muzz:GetPos() end
        local pos = posang.Pos

        return pos
    end
end

function SWEP:GetMuzzleDevice(wm, n)
    if self:GetProcessedValue("IgnoreMuzzleDevice", true) then
        if wm then return self:GetWM() else return self:GetVM() end
    end

    local model
    local muzz
    local nthShot = n or self:GetNthShot()

    local ubgl = self:GetUBGL()

    if wm then
        model = self.WModel
        muzz = self:GetWM()

        if ubgl and self.MuzzleDeviceUBGLWM then
            if istable(self.MuzzleDeviceUBGLWM) then
                return self.MuzzleDeviceUBGLWM[(nthShot % #self.MuzzleDeviceUBGLWM) + 1]
            else
                return self.MuzzleDeviceUBGLWM
            end
        elseif self.MuzzleDeviceWM then
            if istable(self.MuzzleDeviceWM) then
                return self.MuzzleDeviceWM[(nthShot % #self.MuzzleDeviceWM) + 1]
            else
                return self.MuzzleDeviceWM
            end
        end
    else
        model = self.VModel
        muzz = self:GetVM()

        if ubgl and self.MuzzleDeviceUBGLVM then
            if istable(self.MuzzleDeviceUBGLVM) then
                return self.MuzzleDeviceUBGLVM[(nthShot % #self.MuzzleDeviceUBGLVM) + 1]
            else
                return self.MuzzleDeviceUBGLVM
            end
        elseif self.MuzzleDeviceVM then
            if istable(self.MuzzleDeviceVM) then
                return self.MuzzleDeviceVM[(nthShot % #self.MuzzleDeviceVM) + 1]
            else
                return self.MuzzleDeviceVM
            end
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