SWEP.FinishFiremodeAnimTime = 0

function SWEP:SwitchFiremode()
    if self:StillWaiting() then return end

    if self:GetSafe() then
        self:ToggleSafety(false)
        return
    end

    if #self:GetValue("Firemodes") < 2 then return end

    local fm = self:GetFiremode()

    local anim = "firemode_" .. tostring(fm)

    fm = fm + 1

    if fm > #self:GetValue("Firemodes") then
        fm = 1
    end

    if IsFirstTimePredicted() then
        self:EmitSound(self:RandomChoice(self:GetProcessedValue("FiremodeSound")), 75, 100, 1, CHAN_ITEM)
    end

    self:SetFiremode(fm)

    self:InvalidateCache()

    if self:HasAnimation(anim) then
        local t = self:PlayAnimation(anim, 1, false)

        self:SetFinishFiremodeAnimTime(CurTime() + t)
        -- self:SetFiremodePose()
    end
end

function SWEP:SetFiremodePose(wm)
    local vm = self:GetVM()

    if wm then vm = self:GetWM() end

    if !vm then return end

    local pp = self:GetFiremode()

    if pp > #self:GetValue("Firemodes") then
        pp = 1
        self:SetFiremode(pp)
    end

    pp = self:RunHook("HookP_ModifyFiremodePoseParam", pp) or pp

    if self:GetFinishFiremodeAnimTime() < CurTime() then
        vm:SetPoseParameter("firemode", pp)
    else
        vm:SetPoseParameter("firemode", 1)
    end
end

function SWEP:GetCurrentFiremode()
    if self:GetUBGL() then
        return self:GetProcessedValue("UBGLFiremode")
    end

    mode = self:GetCurrentFiremodeTable().Mode

    mode = self:RunHook("Hook_TranslateMode") or mode

    return mode
end

function SWEP:GetCurrentFiremodeTable()
    local fm = self:GetFiremode()

    if fm > #self:GetValue("Firemodes") then
        fm = 1
        self:SetFiremode(fm)
    end

    return self:GetValue("Firemodes")[fm]
end

function SWEP:ToggleSafety(onoff)
    if onoff == nil then
        onoff = !self:GetSafe()
    end

    local last = self:GetSafe()

    self:SetSafe(onoff)

    if onoff != last then
        if IsFirstTimePredicted() then
            self:EmitSound(self:RandomChoice(self:GetProcessedValue("FiremodeSound")), 75, 100, 1, CHAN_ITEM)
        end
    end
end

function SWEP:ThinkFiremodes()
    if IsFirstTimePredicted() and self:GetOwner():KeyPressed(IN_ZOOM) and self:GetOwner():KeyDown(IN_USE) then
        self:ToggleSafety()
        return
    end

    if IsFirstTimePredicted() and self:GetOwner():KeyPressed(IN_ZOOM) then
        self:SwitchFiremode()
    end

    self:SetFiremodePose()
end