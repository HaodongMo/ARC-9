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
end

hook.Add("SetupMove", "ARC9.SetupMove", ARC9.Move)

function ARC9.StartCommand(ply, cmd)
    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then ARC9.RecoilRise = Angle(0, 0, 0) return end

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

    local diff = ARC9.LastEyeAngles - cmd:GetViewAngles()
    local recrise = ARC9.RecoilRise

    if recrise.p > 0 then
        recrise.p = math.Clamp(recrise.p, 0, recrise.p - diff.p)
    elseif recrise.p < 0 then
        recrise.p = math.Clamp(recrise.p, recrise.p - diff.p, 0)
    end

    if recrise.y > 0 then
        recrise.y = math.Clamp(recrise.y, 0, recrise.y - diff.y)
    elseif recrise.y < 0 then
        recrise.y = math.Clamp(recrise.y, recrise.y - diff.y, 0)
    end

    recrise:Normalize()
    ARC9.RecoilRise = recrise

    if math.abs(wpn:GetRecoilUp()) > 1e-9 or math.abs(wpn:GetRecoilSide()) > 1e-9 then
        local eyeang = cmd:GetViewAngles()

        local m = 50

        if game.SinglePlayer() then
            m = 100
        end

        local uprec = FrameTime() * wpn:GetRecoilUp() * m
        local siderec = FrameTime() * wpn:GetRecoilSide() * m

        uprec = math.Clamp(uprec, -math.abs(wpn:GetRecoilUp()), math.abs(wpn:GetRecoilUp()))
        siderec = math.Clamp(siderec, -math.abs(wpn:GetRecoilSide()), math.abs(wpn:GetRecoilSide()))

        wpn:SetRecoilUp(wpn:GetRecoilUp() - uprec)
        wpn:SetRecoilSide(wpn:GetRecoilSide() - siderec)

        eyeang.p = eyeang.p + uprec
        eyeang.y = eyeang.y + siderec

        recrise = ARC9.RecoilRise

        recrise = recrise + Angle(uprec, siderec, 0)

        ARC9.RecoilRise = recrise

        cmd:SetViewAngles(eyeang)

        -- local aim_kick_v = rec * math.sin(CurTime() * 15) * FrameTime() * (1 - sightdelta)
        -- local aim_kick_h = rec * math.sin(CurTime() * 12.2) * FrameTime() * (1 - sightdelta)

        -- wpn:SetFreeAimAngle(wpn:GetFreeAimAngle() - Angle(aim_kick_v, aim_kick_h, 0))
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

    recrise = ARC9.RecoilRise

    local recreset = recrise * FrameTime() * wpn:GetProcessedValue("RecoilAutoControl")

    recreset.p = math.max(recreset.p, recrise.p)
    recreset.y = math.max(recreset.y, recrise.y)

    recrise = recrise - recreset

    recrise:Normalize()

    local eyeang = cmd:GetViewAngles()

    -- eyeang.p = math.AngleDifference(eyeang.p, recreset.p)
    -- eyeang.y = math.AngleDifference(eyeang.y, recreset.y)

    eyeang = eyeang - recreset

    cmd:SetViewAngles(eyeang)

    ARC9.RecoilRise = recrise

    ARC9.LastEyeAngles = cmd:GetViewAngles()

    if cmd:GetImpulse() == 100 and wpn:CanToggleAllStatsOnF() then
        if !wpn:GetReloading() and !wpn:GetUBGL() then
            ply:EmitSound(wpn:RandomChoice(wpn:GetProcessedValue("ToggleAttSound")), 75, 100, 1, CHAN_ITEM)
            if CLIENT then
                wpn:ToggleAllStatsOnF()
            end
        end

        cmd:SetImpulse(0)
    end
end

hook.Add("StartCommand", "ARC9_StartCommand", ARC9.StartCommand)