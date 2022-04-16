function SWEP:PlayAnimation(anim, mult, lock)
    mult = mult or 1
    lock = lock or false
    anim = self:TranslateAnimation(anim)

    mult = self:RunHook("Hook_TranslateAnimSpeed", {mult = mult, anim = anim}).Mult or mult

    if !self:HasAnimation(anim) then return end

    local vm = self:GetVM()

    if !IsValid(vm) then return end

    local animation = self:GetAnimationEntry(anim)

    local source = self:RandomChoice(animation.Source)

    if animation.RareSource then
        if util.SharedRandom("ARC9_raresource", 0, 1) <= (animation.RareSourceChance or 0.01) then
            source = self:RandomChoice(animation.RareSource)
        end
    end

    local seq = vm:LookupSequence(source)

    if seq == -1 then return end

    local time = animation.Time or vm:SequenceDuration(seq)

    mult = mult * (animation.Mult or 1)

    local tmult = (vm:SequenceDuration(seq) / time) / mult

    if animation.Reverse then
        tmult = tmult * -1
    end

    vm:SendViewModelMatchingSequence(seq)
    vm:SetPlaybackRate(tmult)

    mult = math.abs(mult)

    if animation.EjectAt then
        self:SetTimer(animation.EjectAt * mult, function()
            self:DoEject()
        end)
    end

    if animation.RestoreAmmo then
        local minprogress = animation.MinProgress or 0.5
        minprogress = math.min(minprogress, 1)
        self:SetTimer(time * mult * minprogress, function()
            self:RestoreClip(animation.RestoreAmmo)
        end)
    end

    if animation.EventTable then
        self:PlaySoundTable(animation.EventTable or animation.SoundTable, mult)
    end

    self:SetHideBoneIndex(animation.HideBoneIndex or 0)

    if animation.IKTimeLine then
        self:SetIKAnimation(anim)
        self:SetIKTimeLineStart(CurTime())
        self:SetIKTime(time * mult)
    end

    if lock then
        self:SetAnimLockTime(CurTime() + (time * mult))
    else
        self:SetAnimLockTime(CurTime())
    end

    if !animation.NoIdle then
        self:SetNextIdle(CurTime() + (time * mult))
    else
        self:SetNextIdle(math.huge)
    end

    if animation.PoseParamChanges then
        for i, k in pairs(animation.PoseParamChanges) do
            self.PoseParamState[i] = k
        end
    end

    self:SetFinishFiremodeAnimTime(CurTime())

    return time * mult
end

function SWEP:IdleAtEndOfAnimation()
    local vm = self:GetVM()
    local cyc = vm:GetCycle()
    local duration = vm:SequenceDuration()
    local rate = vm:GetPlaybackRate()

    local time = (1 - cyc) * (duration / rate)

    self:SetNextIdle(CurTime() + time)
end

function SWEP:Idle()
    if self:GetPrimedAttack() then return end
    if self:GetSafe() then return end

    self:PlayAnimation("idle")
end

SWEP.PoseParamState = {}

function SWEP:DoPoseParams()
    local vm = self:GetVM()

    if !vm or !IsValid(vm) then return end

    for i, k in pairs(self.PoseParamState) do
        vm:SetPoseParameter(i, k)
    end
end
