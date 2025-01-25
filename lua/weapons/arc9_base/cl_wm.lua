-- local goodmin, goodmax, extramax = Vector(-16, -16, -16), Vector(16, 16, 16), Vector(16, 16, 2048)

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

        -- if self:GetValue("Laser") and self:GetTactical() then -- too hard to know if any laser is active
        --     self:SetRenderBounds(goodmin, extramax)
        -- else
        --     self:SetRenderBounds(goodmin, goodmax)
        -- end
    end
end

hook.Add("PostDrawTranslucentRenderables", "ARC9_TranslucentDraw", function() -- stolen from tacrp
    for _, ply in player.Iterator() do
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.ARC9 then
            wep:DrawLasers(true)
            wep:DrawFlashlightsWM()
        end
    end
end)