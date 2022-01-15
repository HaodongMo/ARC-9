function SWEP:Inspect(force)
    if !force and self:StillWaiting() then return end

    self:PlayAnimation("inspect", 1, true)
end