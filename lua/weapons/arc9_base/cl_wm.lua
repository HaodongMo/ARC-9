function SWEP:DrawWorldModel()
    if !self.MirrorVMWM then
        self:DrawModel()
        return
    end

    self:DrawCustomModel(true)

    if IsValid(self:GetOwner()) then
        self:DoBodygroups(true)
        self:DrawLasers(true)
        self:DoTPIK()
    end
end
