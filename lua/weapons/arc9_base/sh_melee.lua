function SWEP:MeleeAttack()
    if self:StillWaiting() then return end

    self:PlayAnimation("bash", 1, true)
end