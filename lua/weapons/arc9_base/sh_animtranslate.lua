function SWEP:TranslateAnimation(seq)
    if self:GetOwner():IsNPC() then return seq end

    local sds = self:GetProcessedValue("SuppressDefaultSuffixes")

    if !sds then
        if self:GetUBGL() and self:HasAnimation(seq .. "_ubgl") then
            seq = seq .. "_ubgl"
        end

        if self:GetGrenadePrimed() and self:HasAnimation(seq .. "_primed") then
            seq = seq .. "_primed"
        end

        if self:GetInSights() and self:HasAnimation(seq .. "_iron") then
            seq = seq .. "_iron"
        end

        if self:GetInSights() and self:HasAnimation(seq .. "_sights") then
            seq = seq .. "_sights"
        end

        -- if self:GetBlindFire() and self:GetBlindFireDirection() < 0 and self:HasAnimation(seq .. "_blindfire_left") then
        --     seq = seq .. "_blindfire_left"
        -- end

        -- if self:GetBlindFire() and self:GetBlindFireDirection() < 0 and self:HasAnimation(seq .. "_blindfire_right") then
        --     seq = seq .. "_blindfire_right"
        -- end

        -- if self:GetBlindFire() and self:HasAnimation(seq .. "_blindfire") then
        --     seq = seq .. "_blindfire"
        -- end

        if self:GetBipod() and self:HasAnimation(seq .. "_bipod") then
            seq = seq .. "_bipod"
        end

        if !self:GetProcessedValue("SuppressSprintSuffix") and self:GetSprintAmount() > 0 and self:GetIsSprinting() and self:HasAnimation(seq .. "_sprint") then
            seq = seq .. "_sprint"
        elseif self:GetIsWalking() and self:HasAnimation(seq .. "_walk") then
            seq = seq .. "_walk"
        end

        if !self:GetProcessedValue("SuppressEmptySuffix") and (self:Clip1() == 0 or self:GetEmptyReload()) and self:HasAnimation(seq .. "_empty") then
            seq = seq .. "_empty"
        end

        if self:GetUBGL() and self:HasAnimation(seq .. "_ubgl") then
            seq = seq .. "_ubgl"
        end

        if self:GetNeedsCycle() and self:HasAnimation(seq .. "_uncycled") then
            seq = seq .. "_uncycled"
        end

        if IsValid(self:GetDetonatorEntity()) and self:HasAnimation(seq .. "_detonator") then
            seq = seq .. "_detonator"
        end
    end

    local traq = self:RunHook("Hook_TranslateAnimation", seq) or seq

    if self:HasAnimation(traq) then
        seq = traq
    end

    if istable(seq) then
        seq["BaseClass"] = nil
        seq = seq[math.Round(util.SharedRandom("ARC9_animtr", 1, #seq))]
    end

    -- print(seq)

    return seq
end

function SWEP:HasAnimation(seq)
    -- seq = self:TranslateSequence(seq)
    if self.Animations[seq] or self.IKAnimationProxy[seq] then
        return true
    end

    local vm = self:GetVM()

    if !IsValid(vm) then return true end
    seq = vm:LookupSequence(seq)

    return seq != -1
end

function SWEP:GetAnimationTime(anim)
    local entry = self:GetAnimationEntry(anim)

    if !entry then return 0 end

    if entry.Time then return entry.Time end

    local seq = entry.Source

    if istable(seq) then seq = seq[1] end

    return self:GetSequenceTime(seq)
end

function SWEP:GetSequenceTime(seq)
    local vm = self:GetVM()
    if !IsValid(vm) then return 1 end
    seq = vm:LookupSequence(seq or "")

    return vm:SequenceDuration(seq)
end

function SWEP:GetAnimationEntry(seq)
    if self:HasAnimation(seq) then
        if self.IKAnimationProxy[seq] then
            return self.IKAnimationProxy[seq]
        else
            if self.Animations[seq] then
                return self.Animations[seq]
            elseif !self:GetProcessedValue("SuppressDefaultAnimations") then
                return {
                    Source = seq,
                    Time = self:GetSequenceTime(seq)
                }
            end
        end
    else
        return {}
    end
end

SWEP.IKAnimationProxy = {}

function SWEP:AddProxyToAnimProxyTable(tbl, model, atttbl, address)
    for anim, animtable in pairs(tbl) do
        local newanimtable = table.Copy(animtable)
        if !self.IKAnimationProxy[anim] then
            self.IKAnimationProxy[anim] = newanimtable
        else
            if tbl.Priority > self.IKAnimationProxy[anim].Priority then
                self.IKAnimationProxy[anim] = newanimtable
            else
                continue
            end
        end

        newanimtable.ProxyAnimation = true
        newanimtable.Model = model
        newanimtable.Priority = newanimtable.Priority or 0
        newanimtable.ModelName = atttbl.Model
        newanimtable.Address = address
        newanimtable.MotionAttachment = atttbl.IKGunMotionQCA
    end
end

function SWEP:SetupAnimProxy()
    self.IKAnimationProxy = {}

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.IKAnimationProxy then
            self:AddProxyToAnimProxyTable(atttbl.IKAnimationProxy, slottbl.GunDriverModel or slottbl.VModel or slottbl.WModel, atttbl, slottbl.Address)
        end
    end
end