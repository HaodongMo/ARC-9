ARC9.LastEyeAngles = Angle(0, 0, 0)
ARC9.RecoilRise = Angle(0, 0, 0)

function ARC9.Move(ply, mv, cmd)
    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then return end

    local basespd = (Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length()
    basespd = math.min(basespd, mv:GetMaxClientSpeed())

    local mult = wpn:GetProcessedValue("Speed", 1)

    if wpn:GetSightAmount() > 0 then
        if ply:KeyDown(IN_SPEED) then
            mult = mult / Lerp(wpn:GetSightAmount(), 1, ply:GetRunSpeed() / ply:GetWalkSpeed()) * (wpn:HoldingBreath() and 0.5 or 1)
        end
    -- else
    --     if wpn:GetTraversalSprint() then
    --         mult = 1
    --     end
    end

    mv:SetMaxSpeed(basespd * mult)
    mv:SetMaxClientSpeed(basespd * mult)

    if wpn:GetInMeleeAttack() and wpn:GetLungeEntity():IsValid() then
        mv:SetMaxSpeed(10000)
        mv:SetMaxClientSpeed(10000)
        local targetpos = (wpn:GetLungeEntity():EyePos() + wpn:GetLungeEntity():EyePos()) / 2
        local lungevec = targetpos - ply:EyePos()
        local lungedir = lungevec:GetNormalized()
        local lungedist = lungevec:Length()
        local lungespd = (2 * (lungedist / math.Max(0.01, wpn:GetProcessedValue("PreBashTime"))))
        mv:SetVelocity(lungedir * lungespd)
    end

    if wpn:GetBipod() then
        if ply:Crouching() then
            cmd:AddKey(IN_DUCK)
            mv:AddKey(IN_DUCK)
        else
            cmd:RemoveKey(IN_DUCK)
            local buttons = mv:GetButtons()
            buttons = bit.band(buttons, bit.bnot(IN_DUCK))
            mv:SetButtons(buttons)
        end
    end

    if cmd:GetImpulse() == ARC9.IMPULSE_TOGGLEATTS then
        if !wpn:StillWaiting() and !wpn:GetUBGL() then
            ply:EmitSound(wpn:RandomChoice(wpn:GetProcessedValue("ToggleAttSound")), 75, 100, 1, CHAN_ITEM)
            wpn:PlayAnimation("toggle")
        end
    end
end

hook.Add("SetupMove", "ARC9.SetupMove", ARC9.Move)

ARC9.RecoilTimeStep = 0.03

ARC9.ClientRecoilTime = 0

ARC9.ClientRecoilUp = 0
ARC9.ClientRecoilSide = 0

ARC9.ClientRecoilProgress = 0

function ARC9.StartCommand(ply, cmd)
    if !IsValid(ply) then return end

    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then ARC9.RecoilRise = Angle(0, 0, 0) return end

    if ply:IsBot() then timescalefactor = 1 end -- ping is infinite for them lol

    if wpn:GetBipod() then
        local bipang = wpn:GetBipodAng()

        local eyeang = cmd:GetViewAngles()

        if math.AngleDifference(bipang.y, eyeang.y) < -40 then
            eyeang.y = bipang.y + 40
        elseif math.AngleDifference(bipang.y, eyeang.y) > 40 then
            eyeang.y = bipang.y - 40
        end

        if math.AngleDifference(bipang.p, eyeang.p) > 15 then
            eyeang.p = bipang.p - 15
        elseif math.AngleDifference(bipang.p, eyeang.p) < -15 then
            eyeang.p = bipang.p + 15
        end

        cmd:SetViewAngles(eyeang)

        if game.SinglePlayer() then
            ply:SetEyeAngles(eyeang)
        end
    end

    local isScope = wpn:GetSight() and wpn:GetSight().atttbl and wpn:GetSight().atttbl.RTScope
    local cheap = CLIENT and isScope and GetConVar("ARC9_cheapscopes"):GetBool()

    if wpn:GetSightAmount() > 0.5 and cheap then
        local swayspeed = 2
        local swayamt = wpn:GetFreeSwayAmount()
        local swayang = Angle(math.sin(CurTime() * 0.6 * swayspeed) + (math.cos(CurTime() * 2) * 0.5), math.sin(CurTime() * 0.4 * swayspeed) + (math.cos(CurTime() * 1.6) * 0.5), 0)

        swayang = swayang * wpn:GetSightAmount() * swayamt

        local eyeang = cmd:GetViewAngles()

        eyeang.p = eyeang.p + (swayang.p * FrameTime())
        eyeang.y = eyeang.y + (swayang.y * FrameTime())

        cmd:SetViewAngles(eyeang)
    end

    if wpn:GetProcessedValue("NoSprintWhenLocked") and wpn:GetAnimLockTime() > CurTime() then
        cmd:RemoveKey(IN_SPEED)
    end

    local eyeang = cmd:GetViewAngles()

    if eyeang.p != eyeang.p then eyeang.p = 0 end
    if eyeang.y != eyeang.y then eyeang.y = 0 end
    if eyeang.r != eyeang.r then eyeang.r = 0 end

    local m = 25

    if CLIENT then
        local diff = ARC9.LastEyeAngles - cmd:GetViewAngles()
        local recrise = ARC9.RecoilRise

        -- 0 can be negative or positive!!!!! Insane

        if recrise.p == 0 then
        elseif recrise.p > 0 then
            recrise.p = math.Clamp(recrise.p, 0, recrise.p - diff.p)
        elseif recrise.p < 0 then
            recrise.p = math.Clamp(recrise.p, recrise.p - diff.p, 0)
        end

        if recrise.y == 0 then
        elseif recrise.y > 0 then
            recrise.y = math.Clamp(recrise.y, 0, recrise.y - diff.y)
        elseif recrise.y < 0 then
            recrise.y = math.Clamp(recrise.y, recrise.y - diff.y, 0)
        end

        recrise:Normalize()

        ARC9.RecoilRise = recrise

        local catchup = 0

        if ARC9.ClientRecoilTime < CurTime() then
            ARC9.ClientRecoilUp = wpn:GetRecoilUp() * ARC9.RecoilTimeStep
            ARC9.ClientRecoilSide = wpn:GetRecoilSide() * ARC9.RecoilTimeStep

            ARC9.ClientRecoilTime = CurTime() + ARC9.RecoilTimeStep

            if ARC9.ClientRecoilProgress < 1 then
                catchup = ARC9.RecoilTimeStep * (1 - ARC9.ClientRecoilProgress)
            end

            ARC9.ClientRecoilProgress = 0
        end

        local cft = math.min(FrameTime(), ARC9.RecoilTimeStep)

        local progress = cft / ARC9.RecoilTimeStep

        if progress > 1 - ARC9.ClientRecoilProgress then
            cft = (1 - ARC9.ClientRecoilProgress) * ARC9.RecoilTimeStep
            progress = (1 - ARC9.ClientRecoilProgress)
        end

        cft = cft + catchup

        ARC9.ClientRecoilProgress = ARC9.ClientRecoilProgress + progress

        if math.abs(ARC9.ClientRecoilUp) > 1e-5 then
            eyeang.p = eyeang.p + ARC9.ClientRecoilUp * m * cft / ARC9.RecoilTimeStep
        end

        if math.abs(ARC9.ClientRecoilSide) > 1e-5 then
            eyeang.y = eyeang.y + ARC9.ClientRecoilSide * m * cft / ARC9.RecoilTimeStep
        end

        local diff_p = ARC9.ClientRecoilUp * m * cft / ARC9.RecoilTimeStep
        local diff_y = ARC9.ClientRecoilSide * m * cft / ARC9.RecoilTimeStep

        ARC9.RecoilRise = ARC9.RecoilRise + Angle(diff_p, diff_y, 0)

        local recreset = ARC9.RecoilRise * wpn:GetProcessedValue("RecoilAutoControl") * cft * 2

        if math.abs(recreset.p) > 1e-5 then
            eyeang.p = eyeang.p - recreset.p
        end

        if math.abs(recreset.y) > 1e-5 then
            eyeang.y = eyeang.y - recreset.y
        end

        ARC9.RecoilRise = ARC9.RecoilRise - Angle(recreset.p, recreset.y, 0)

        ARC9.RecoilRise:Normalize()

        cmd:SetViewAngles(eyeang)

        ARC9.LastEyeAngles = eyeang
    end

    if cmd:GetImpulse() == 100 and wpn:CanToggleAllStatsOnF() and !wpn:GetCustomize() then
        if !wpn:GetReloading() and !wpn:GetUBGL() then
            ply:EmitSound(wpn:RandomChoice(wpn:GetProcessedValue("ToggleAttSound")), 75, 100, 1, CHAN_ITEM)
            if CLIENT then
                wpn:ToggleAllStatsOnF()
            end
        end

        cmd:SetImpulse(ARC9.IMPULSE_TOGGLEATTS)
    end

    if ply:KeyDown(IN_USE) and wpn:GetInSights() and cmd:GetMouseWheel() != 0 and #wpn.MultiSightTable > 0 then
        wpn:SwitchMultiSight(-cmd:GetMouseWheel())
    end
end

hook.Add("StartCommand", "ARC9_StartCommand", ARC9.StartCommand)