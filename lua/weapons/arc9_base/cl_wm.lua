function SWEP:DrawWorldModel()
    self:DoBodygroups(true)
    self:DrawCustomModel(true)
    self:DrawLasers(true)
    -- self:DoTPIK()
end
