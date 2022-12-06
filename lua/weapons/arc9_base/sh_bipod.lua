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
    if self:GetBlindFireAmount() > 0 then return end
    if self:GetUBGL() then return end

    local pos = self:GetOwner():EyePos()
    local ang = self:GetOwner():EyeAngles()

    local maxs = Vector(2, 2, 2)
    local mins = Vector(-2, -2, -48)

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (ang:Forward() * 64),
        filter = self:GetOwner(),
        mask = MASK_PLAYERSOLID
    })

    -- if tr.Hit then return end

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