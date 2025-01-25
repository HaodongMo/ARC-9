function SWEP:DrawWorldModel()
    local owner = self:GetOwner()

    if !self.MirrorVMWM or (!IsValid(owner) and self.MirrorVMWMHeldOnly) then
        self:DrawModel()
        return
    end

    self:DrawCustomModel(true)


    if IsValid(owner) and owner:GetActiveWeapon() == self then -- gravgun moment
        self:DoBodygroups(true)
        -- self:DrawLasers(true)
        self:DoTPIK()
        -- self:DrawFlashlightsWM()
        self.LastWMDrawn = UnPredictedCurTime()
    end
end

hook.Add("PostDrawTranslucentRenderables", "ARC9_TranslucentDraw", function() -- stolen from tacrp
    for _, ply in player.Iterator() do
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.ARC9 then
            wep:DrawLasers(true)
            wep:DrawFlashlightsWM()
            -- wep:DrawFlashlightGlares()
            -- wep:DoScopeGlint()
        end
    end
end)