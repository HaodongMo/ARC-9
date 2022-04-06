function SWEP:DrawWorldModel()
    if !self.MirrorVMWM then
        self:DrawModel()
        return
    end

    self:DoBodygroups(true)
    self:DrawCustomModel(true)
    self:DrawLasers(true)
    self:DoTPIK()
end
