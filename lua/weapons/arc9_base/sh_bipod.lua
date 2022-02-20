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
    if self:GetSprintAmount() > 0 then return end
    if self:GetReloading() and !self:GetBipod() then return end

    local pos = self:GetOwner():EyePos()
    local ang = self:GetOwner():EyeAngles()

    local maxs = Vector(2, 2, 2)
    local mins = Vector(-2, -2, -32)

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
    if self:GetBipod() then return end

    self:SetBipod(true)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("EnterBipodSound")))
    self:CancelReload()
    self:PlayAnimation("enter_bipod", 1, true)
    self:SetEnterBipodTime(CurTime())
end

function SWEP:ExitBipod()
    if !self:GetBipod() then return end

    self:SetBipod(false)
    self:EmitSound(self:RandomChoice(self:GetProcessedValue("ExitBipodSound")))
    self:CancelReload()
    self:PlayAnimation("exit_bipod", 1, true)
end

SWEP.BipodTime = 0.5

function SWEP:GetBipodAmount()
    local bipodamount = 0

    if self:GetBipod() then
        local d = math.Clamp(CurTime() - self:GetEnterBipodTime(), 0, self:GetValue("BipodTime"))
        bipodamount = d / self:GetValue("BipodTime")
    end

    return bipodamount
end