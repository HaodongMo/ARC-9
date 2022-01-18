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
            mult = mult / Lerp(wpn:GetSightAmount(), 1, ply:GetRunSpeed() / ply:GetWalkSpeed())
        end
    end

    mv:SetMaxSpeed(basespd * mult)
    mv:SetMaxClientSpeed(basespd * mult)
end

hook.Add("SetupMove", "ARC9.SetupMove", ARC9.Move)

function ARC9.StartCommand(ply, cmd)
    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then ARC9.RecoilRise = Angle(0, 0, 0) return end

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

    if math.abs(wpn:GetRecoilUp()) > 0 or math.abs(wpn:GetRecoilSide()) > 0 then
        local eyeang = cmd:GetViewAngles()

        local uprec = FrameTime() * wpn:GetRecoilUp() * 100
        local siderec = FrameTime() * wpn:GetRecoilSide() * 100

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

    if wpn:GetSightAmount() > 0 then
        local swayspeed = 1
        local swayamt = wpn:GetFreeSwayAmount()
        local swayang = Angle(math.sin(CurTime() * 0.6 * swayspeed) + (math.cos(CurTime() * 2) * 0.5), math.sin(CurTime() * 0.4 * swayspeed) + (math.cos(CurTime() * 1.6) * 0.5), 0)

        swayang = swayang * wpn:GetSightAmount() * swayamt

        local eyeang = cmd:GetViewAngles()

        eyeang.p = eyeang.p + (swayang.p * FrameTime())
        eyeang.y = eyeang.y + (swayang.y * FrameTime())

        cmd:SetViewAngles(eyeang)
    end

    recrise = ARC9.RecoilRise

    local recreset = recrise * FrameTime() * 3.5 * wpn:GetProcessedValue("RecoilAutoControl")

    recrise = recrise - recreset

    recrise:Normalize()

    local eyeang = cmd:GetViewAngles()

    -- eyeang.p = math.AngleDifference(eyeang.p, recreset.p)
    -- eyeang.y = math.AngleDifference(eyeang.y, recreset.y)

    eyeang = eyeang - recreset

    cmd:SetViewAngles(eyeang)

    ARC9.RecoilRise = recrise

    ARC9.LastEyeAngles = cmd:GetViewAngles()
end

hook.Add("StartCommand", "ARC9_StartCommand", ARC9.StartCommand)