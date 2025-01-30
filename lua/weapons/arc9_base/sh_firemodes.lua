SWEP.FinishFiremodeAnimTime = 0

function SWEP:SwitchFiremode()
    if self:StillWaiting() then return end

    if self:GetProcessedValue("NoFiremodeWhenEmpty", true) and self:Clip1() <= 0 then return end

    if self:GetSafe() then
        self:ToggleSafety(false)
        return
    end

    if self:GetUBGL() then return end

    local fmodes = self:GetValue("Firemodes")

    if #fmodes < 2 then return end

    local fm = self:GetFiremode()

    local anim = "firemode_" .. tostring(fm)

    fm = fm + 1

    if fm > #fmodes then
        fm = 1
    end

    if IsFirstTimePredicted() then
        local soundtab1 = {
            name = "firemode",
            sound = self:RandomChoice(self:GetProcessedValue("FiremodeSound", true)),
            channel = ARC9.CHAN_FIDDLE
        }
        self:PlayTranslatedSound(soundtab1)
    end

    self:SetFiremode(fm)

    local lock = self:GetValue("FiremodeAnimLock")

    if self:HasAnimation(anim) then
        local t = self:PlayAnimation(anim, 1, lock)

        self:SetFinishFiremodeAnimTime(CurTime() + t)
        -- self:SetFiremodePose()
    elseif self:HasAnimation("firemode") then
        local t = self:PlayAnimation("firemode", 1, lock)

        self:SetFinishFiremodeAnimTime(CurTime() + t)
    end

    self:InvalidateCache()

    if game.SinglePlayer() then
        self:CallOnClient("InvalidateCache")
    end
	
	-- self.FMHintTimeP = self.FMHintTime or "N/A"
	
	-- self.FMHintTime = CurTime()
	-- print( " " )
	-- print( "SWITCHED FIRING MODE" )
	-- print( "Cur. " .. string.format( "%.3f", self.FMHintTime ) )
	-- print( "Pre. " .. string.format( "%.3f", self.FMHintTimeP ) )
	
end

function SWEP:SetFiremodePose(wm)
    if SERVER then return end
    local vm = self:GetVM()

    if wm then vm = self:GetWM() end

    if !vm then return end

    if self.CustomPoseParamsHandler then self:CustomPoseParamsHandler(vm, wm) end

    local pp = self:GetFiremode()

    if pp > #self:GetValue("Firemodes") then
        pp = 1
        self:SetFiremode(pp)
    end

    local fmt = self:GetCurrentFiremodeTable()

    if fmt.PoseParam then
        pp = fmt.PoseParam
    end

    pp = self:RunHook("HookP_ModifyFiremodePoseParam", pp) or pp

    if self.HasFiremodePoseparam then
        if self:GetFinishFiremodeAnimTime() < CurTime() then
            vm:SetPoseParameter("firemode", pp)
        else
            vm:SetPoseParameter("firemode", 1)
        end
    end
end

function SWEP:GetCurrentFiremode()
    if self:GetUBGL() then
        return self:GetProcessedValue("UBGLFiremode", true)
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
    if self.CantSafety then return end

    if onoff == nil then
        onoff = !self:GetSafe()
    end

    local last = self:GetSafe()

    self:SetSafe(onoff)

    if onoff != last then
        if IsFirstTimePredicted() then
            local soundtab1 = {
                name = "safety",
                sound = self:RandomChoice(self:GetProcessedValue("FiremodeSound", true)),
                channel = ARC9.CHAN_FIDDLE
            }
            self:PlayTranslatedSound(soundtab1)
        end

        if onoff == false then
            self:ExitSights()
        end
    end
	
	-- self.FMHintTimeP = self.FMHintTime or "N/A"
	
	-- self.FMHintTime = CurTime()
	-- print( " " )
	-- print( "TOGGLED SAFETY" )
	-- print( "Cur. " .. string.format( "%.3f", self.FMHintTime ) )
	-- print( "Pre. " .. string.format( "%.3f", self.FMHintTimeP ) )
	
end

function SWEP:ThinkFiremodes()

	-- if CurTime() < self.FMHintTime +1 then return end

    if self:GetOwner():KeyPressed(IN_ZOOM) and self:GetOwner():KeyDown(IN_USE) then
        self:ToggleSafety()
        return
    end

    if self:GetOwner():KeyPressed(IN_ZOOM) then
        self:SwitchFiremode()
    end
end

function SWEP:GetFiremodeName()
    if self:GetUBGL() then
        return self:GetProcessedValue("UBGLFiremodeName", true)
    end

    local arc9_mode = self:GetCurrentFiremodeTable()

    local firemode_text = "UNKNOWN"

    if arc9_mode.PrintName then
        firemode_text = arc9_mode.PrintName
    else
        if arc9_mode.Mode == 1 then
            firemode_text = ARC9:GetPhrase("hud.firemode.single")
        elseif arc9_mode.Mode == 0 then
            firemode_text = ARC9:GetPhrase("hud.firemode.safe")
        elseif arc9_mode.Mode < 0 then
            firemode_text = ARC9:GetPhrase("hud.firemode.auto")
        elseif arc9_mode.Mode > 1 then
            firemode_text = tostring(arc9_mode.Mode) .. "-" .. ARC9:GetPhrase("hud.firemode.burst")
        end
    end

    if self:GetSafe() then
        firemode_text = ARC9:GetPhrase("hud.firemode.safe")
    end

    return firemode_text
end