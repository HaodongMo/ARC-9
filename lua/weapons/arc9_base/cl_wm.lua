function SWEP:DrawWorldModel()
    local owner = self:GetOwner()

    if !self.MirrorVMWM or (!IsValid(owner) and self.MirrorVMWMHeldOnly) then
        self:DrawModel()
        return
    end

    self:DrawCustomModel(true)


    if IsValid(owner) and owner:GetActiveWeapon() == self then -- gravgun moment
        self:DoBodygroups(true)
        self:DrawLasers(true)
        self:DoTPIK()
        self:DrawFlashlightsWM()
    end
end
