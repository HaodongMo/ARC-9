local hud_notonground = 0
local hud_velocity = 0
local bobct = 0

function ARC9.HUDBob(pos, ang)
    local step = 10
    local mag = 0.25
    local ts = 0 // self:GetTraversalSprintAmount()
    -- ts = 1

    local v = LocalPlayer():GetVelocity():Length()
    v = math.Clamp(v, 0, 350)
    hud_velocity = v
    local d = math.Clamp(hud_velocity / 350, 0, 1)

    if LocalPlayer():OnGround() and LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP then
        hud_notonground = math.Approach(hud_notonground, 0, FrameTime() / 0.1)
    else
        hud_notonground = math.Approach(hud_notonground, 1, FrameTime() / 0.1)
    end

    mag = mag * d
    step = 10

    -- ang:RotateAroundAxis(ang:Forward(), math.sin(bobct * step * 0.5) * ((math.sin(CurTime() * 6.151) * 0.2) + 1) * 4.5 * d)
    -- ang:RotateAroundAxis(ang:Right(), math.sin(bobct * step * 0.12) * ((math.sin(CurTime() * 1.521) * 0.2) + 1) * 2.11 * d)
    pos = pos - (ang:Forward() * math.sin(bobct * step * 0.35) * 0.12 * mag)
    -- pos = pos + (ang:Forward() * math.sin(bobct * step * 0.3) * 0.11 * ((math.sin(CurTime() * 2) * ts * 1.25) + 1) * ((math.sin(CurTime() * 1.615) * 0.2) + 1) * mag)
    pos = pos + (ang:Right() * (math.sin(bobct * step * 0.7) * 0.25 * mag))

    local steprate = Lerp(d, 1, 2.5)

    steprate = Lerp(hud_notonground, steprate, 0.25)

    if IsFirstTimePredicted() or game.SinglePlayer() then
        bobct = bobct + (FrameTime() * steprate)
    end

    return pos, ang
end

local lasteyeangles = Angle(0, 0, 0)
local hudsway = Angle(0, 0, 0)

function ARC9.HUDSway(pos, ang)
    hudsway = hudsway + (0.75 * Angle(math.AngleDifference(lasteyeangles[1], EyeAngles()[1]) * FrameTime(), math.AngleDifference(lasteyeangles[2], EyeAngles()[2]) * FrameTime(), 0))

    hudsway[1] = math.Clamp(math.NormalizeAngle(hudsway[1]), -2, 2)
    hudsway[2] = math.Clamp(math.NormalizeAngle(hudsway[2]), -2, 2)

    pos = pos + ang:Right() * hudsway[1]
    pos = pos + ang:Forward() * -hudsway[2] * 1.25

    hudsway = LerpAngle(0.2, hudsway, Angle(0, 0, 0))

    lasteyeangles = EyeAngles()

    return pos, ang
end