function SWEP:DrawWorldModel()
    if !self.MirrorVMWM then
        self:DrawModel()
        return
    end

    self:DrawCustomModel(true)
    
    local owner = self:GetOwner()

    if IsValid(owner) and owner:GetActiveWeapon() == self then -- gravgun moment
        self:DoBodygroups(true)
        self:DrawLasers(true)
        self:DoTPIK()
        self:DrawFlashlightsWM()
    end
end
