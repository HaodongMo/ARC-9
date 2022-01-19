function SWEP:SanityCheck()
    if !IsValid(self) then return false end
    if !IsValid(self:GetOwner()) then return false end
    if !IsValid(self:GetVM()) then return false end
end

function SWEP:GetWM()
    if self.WModel then
        return self.WModel[1]
    else
        return NULL
    end
end

function SWEP:GetVM()
    return self:GetOwner():GetViewModel()
end

function SWEP:Curve(x)
    return 0.5 * math.cos((x + 1) * math.pi) + 0.5
end

function SWEP:IsAnimLocked()
    return self:GetAnimLockTime() > CurTime()
end

function SWEP:RandomChoice(choice)
    if istable(choice) then
        choice = table.Random(choice)
    end

    return choice
end

function SWEP:PatternWithRunOff(pattern, runoff, num)
    if num < #pattern then
        return pattern[num]
    else
        num = num - #pattern
        num = num % #runoff

        return runoff[num + 1]
    end
end