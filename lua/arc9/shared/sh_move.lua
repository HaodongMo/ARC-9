ARC9.LastEyeAngles = Angle(0, 0, 0) -- Unsused global varaiable: ARC9.LastEyeAngles, variable should be local to the file.
ARC9.RecoilRise = Angle(0, 0, 0) -- Unsused global varaiable: ARC9.RecoilRise, variable should be local to the file.
ARC9.SwayAngle = Angle(0, 0, 0) -- Unsused global varaiable: ARC9.SwayAngle, variable should be local to the file.

function ARC9.Move(ply, mv, cmd)
    local wpn = ply:GetActiveWeapon()
    if !wpn.ARC9 then return end

    local basespd = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), cmd:GetUpMove()):Length()
    basespd = math.min(basespd, mv:GetMaxClientSpeed())

    local mult = wpn:GetProcessedValue("Speed", 1)

    if wpn:GetSightAmount() > 0 then
        if ply:KeyDown(IN_SPEED) then
            mult = mult / Lerp(wpn:GetSightAmount(), 1, ply:GetRunSpeed() / ply:GetWalkSpeed())
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
        local targetpos = (wpn:GetLungeEntity():WorldSpaceCenter() + wpn:GetLungeEntity():EyePos()) / 2
        local lungevec = targetpos - ply:EyePos()
        local lungedir = lungevec:GetNormalized()
        local lungespd = (2 * (lungevec:Length() / math.Max(0.01, wpn:GetProcessedValue("PreBashTime")))) + 100
        ply:SetEyeAngles(lungedir:Angle())
        mv:SetVelocity(lungedir * lungespd)
        -- mv:SetForwardSpeed(lungespd)
    end
end

hook.Add("SetupMove", "ARC9.SetupMove", ARC9.Move)

function ARC9.StartCommand(ply, cmd)
    local wpn = ply:GetActiveWeapon()
    local curtime = CurTime()
    local frametime = FrameTime()
    local viewangles = cmd:GetViewAngles()

    if !wpn.ARC9 then ARC9.RecoilRise:Set(ARC9_ANGLEZERO) return end

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

    if math.abs(wpn:GetRecoilUp()) > 0 or math.abs(wpn:GetRecoilSide()) > 0 then
        local uprec = frametime * wpn:GetRecoilUp() * 100
        local siderec = frametime * wpn:GetRecoilSide() * 100
        local recoilang = Angle(uprec, siderec, 0)

        viewangles:Add(recoilang)
        recrise:Add(recoilang)

        -- local aim_kick_v = rec * math.sin(curtime * 15) * frametime * (1 - sightdelta)
        -- local aim_kick_h = rec * math.sin(curtime * 12.2) * frametime * (1 - sightdelta)

        -- wpn:SetFreeAimAngle(wpn:GetFreeAimAngle() - Angle(aim_kick_v, aim_kick_h, 0))
    end

    if wpn:GetSightAmount() > 0 then
        local swayspeed = 1
        local swayamt = wpn:GetFreeSwayAmount()

        local swayang = ARC9.SwayAngle
        swayang.p = math.sin(curtime * 0.6 * swayspeed) + (math.cos(curtime * 2) * 0.5)
        swayang.y = math.sin(curtime * 0.4 * swayspeed) + (math.cos(curtime * 1.6) * 0.5)
        swayang:Mul(wpn:GetSightAmount() * swayamt)

        viewangles:Add(swayang * frametime)
    end

    local recdecay = recrise * frametime * wpn:GetProcessedValue("RecoilAutoControl")
    recrise:Sub(recdecay)
    recrise:Normalize()

    viewangles:Sub(recdecay)
    cmd:SetViewAngles(viewangles)

    ARC9.RecoilRise = recrise
    ARC9.LastEyeAngles = cmd:GetViewAngles()
end

hook.Add("StartCommand", "ARC9_StartCommand", ARC9.StartCommand)