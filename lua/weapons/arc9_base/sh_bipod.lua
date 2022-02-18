function SWEP:ThinkBipod()
    local bip = self:GetBipod()
    local canbip = self:CanBipod()

    if bip then
        if !canbip then
            self:ExitBipod()
        end
    else
        if canbip then
            self:EnterBipod()
        end
    end
end

function SWEP:CanBipod()
    if !self:GetProcessedValue("Bipod") then return end

    local pos = self:GetOwner():EyePos()
    local ang = self:GetOwner():EyeAngles()

    local maxs = Vector(2, 2, 16)
    local mins = Vector(-2, -2, -16)

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (ang:Forward() * 24),
        filter = self:GetOwner(),
        mask = MASK_PLAYERSOLID
    })

    if tr.Hit then return end

    -- ang:RotateAroundAxis(ang:Right(), -30)

    local tr2 = util.TraceHull({
        start = pos,
        endpos = pos + (ang:Forward() * 24),
        filter = self:GetOwner(),
        maxs = maxs,
        mins = mins,
        mask = MASK_PLAYERSOLID
    })

    if tr2.Hit then
        return true
    else
        return false
    end
end

function SWEP:EnterBipod()
    self:SetBipod(true)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("EnterBipodSound")))
end

function SWEP:ExitBipod()
    self:SetBipod(false)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("ExitBipodSound")))
end