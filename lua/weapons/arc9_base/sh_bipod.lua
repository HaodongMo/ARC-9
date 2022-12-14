function SWEP:ThinkBipod()
    if self:PredictionFilter() then return end

    local bip = self:GetBipod()

    if bip then
        if self:MustExitBipod() or self:GetOwner():KeyDown(IN_BACK) then
            self:ExitBipod()
        end
    else
        if self:CanBipod() and self:GetOwner():KeyPressed(IN_ATTACK2) then
            self:EnterBipod()
        end
    end
end

function SWEP:MustExitBipod()
    if !self:GetProcessedValue("Bipod") then return true end
    if self:GetSprintAmount() > 0 then return true end
    if self:GetBlindFireAmount() > 0 then return true end
    if self:GetUBGL() then return true end

    if self:GetOwner():GetVelocity():LengthSqr() > 100 then return true end

    return false
end

function SWEP:CanBipod(ang)
    if !self:GetProcessedValue("Bipod") then return end
    if self:GetSprintAmount() > 0 then return end
    if self:GetReloading() and !self:GetBipod() then return end
    if self:GetBlindFireAmount() > 0 then return end
    if self:GetUBGL() then return end

    local pos = self:GetOwner():EyePos()
    ang = ang or self:GetOwner():EyeAngles()

    local maxs = Vector(2, 2, 2)
    local mins = Vector(-2, -2, -48)

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (ang:Forward() * 64),
        filter = self:GetOwner(),
        mask = MASK_PLAYERSOLID
    })

    if tr.Hit then return end

    -- ang:RotateAroundAxis(ang:Right(), -30)

    local d = (tr.HitPos - pos):Length()
    d = d / 2

    mins.z = -d

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
    local soundtab1 = {
        name = "enterbipod",
        sound = self:RandomChoice(self:GetProcessedValue("EnterBipodSound"))
    }
    self:PlayTranslatedSound(soundtab1)
    self:PlayAnimation("enter_bipod", 1, true)
    self:SetEnterBipodTime(CurTime())

    self:SetBipodAng(self:GetOwner():EyeAngles())
    self:SetBipodPos(self:GetOwner():EyePos() + (self:GetOwner():EyeAngles():Forward() * 4) - Vector(0, 0, 2))

    self:ExitSights()
end

function SWEP:ExitBipod()
    if !self:GetBipod() then return end

    self:SetBipod(false)
    local soundtab1 = {
        name = "exitbipod",
        sound = self:RandomChoice(self:GetProcessedValue("ExitBipodSound"))
    }
    self:PlayTranslatedSound(soundtab1)

    if self:GetAnimLockTime() <= CurTime() then
        self:PlayAnimation("exit_bipod", 1, true)
    end

    self:CancelReload()

    self:ExitSights()
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