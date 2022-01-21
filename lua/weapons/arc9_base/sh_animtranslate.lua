function SWEP:TranslateAnimation(seq)
    if self:GetSightAmount() > 0 and self:HasAnimation(seq .. "_iron") then
        seq = seq .. "_iron"
    end

    if self:GetSprintAmount() > 0 and self:HasAnimation(seq .. "_sprint") then
        seq = seq .. "_sprint"
    end

    if (self:Clip1() == 0 or self:GetEmptyReload()) and self:HasAnimation(seq .. "_empty") then
        seq = seq .. "_empty"
    end

    seq = self:RunHook("Hook_TranslateAnimation", seq) or seq

    if istable(seq) then
        seq["BaseClass"] = nil
        seq = seq[math.Round(util.SharedRandom("ARC9_animtr", 1, #seq))]
    end

    return seq
end

function SWEP:HasAnimation(seq)
    -- seq = self:TranslateSequence(seq)
    if self.Animations[seq] then
        return true
    end

    local vm = self:GetVM()
    seq = vm:LookupSequence(seq)

    return seq != -1
end

function SWEP:GetSequenceTime(seq)
    local vm = self:GetVM()
    seq = vm:LookupSequence(seq)

    return vm:SequenceDuration(seq)
end

function SWEP:GetAnimationEntry(seq)
    if self:HasAnimation(seq) then
        if self.Animations[seq] then
            return self.Animations[seq]
        else
            return {
                Source = seq,
                Time = self:GetSequenceTime(seq)
            }
        end
    else
        return nil
    end
end