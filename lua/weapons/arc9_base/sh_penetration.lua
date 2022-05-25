local function IsPenetrating(ptr, ptrent)
    if ptrent:IsWorld() then
        return !ptr.StartSolid or ptr.AllSolid
    elseif IsValid(ptrent) then
        local mins, maxs = ptrent:WorldSpaceAABB()
        local wsc = ptrent:WorldSpaceCenter()
        -- Expand the bounding box by a bit to account for hitboxes outside it
        -- This is more consistent but less accurate
        mins = mins + (mins - wsc) * 0.25
        maxs = maxs + (maxs - wsc) * 0.25
        local withinbounding = ptr.HitPos:WithinAABox(mins, maxs)
        if ARC9.Dev(2) then
            debugoverlay.Cross(ptr.HitPos, withinbounding and 2 or 6, 5, withinbounding and Color(255, 255, 0) or Color(128, 255, 0), true)
        end

        if withinbounding then return true end
    end
    return false
end

local ricochetsounds = {
    "arc9/ricochet01.wav",
    "arc9/ricochet02.wav",
    "arc9/ricochet03.wav",
    "arc9/ricochet04.wav",
    "arc9/ricochet05.wav",
}

function SWEP:Penetrate(tr, range, penleft, alreadypenned)
    if !GetConVar("arc9_mod_penetration"):GetBool() then return end

    if !IsValid(self) then return end
    if !IsValid(self:GetOwner()) then return end

    local hitpos, startpos = tr.HitPos, tr.StartPos
    local dir    = (hitpos - startpos):GetNormalized()

    if tr.HitSky then return end

    if penleft <= 0 then return end

    alreadypenned = alreadypenned or {}

    local skip = false

    local trent = tr.Entity

    local penmult     = ARC9.PenTable[tr.MatType] or 1
    // local pentracelen = math.max(penleft * penmult / 8, 1)
    local curr_ent    = trent

    if self:GetRicochetChance(tr) > math.random(0, 100) then
        local degree = tr.HitNormal:Dot((tr.StartPos - tr.HitPos):GetNormalized())
        if degree == 0 or degree == 1 then return end
        -- sound.Play(ArcCW.RicochetSounds[math.random(#ArcCW.RicochetSounds)], tr.HitPos)
        if (tr.Normal:Length() == 0) then return end
        -- ACT3_ShootPBullet(tr.HitPos, ((2 * degree * tr.HitNormal) + tr.Normal) * (vel * math.Rand(0.25, 0.75)), owner, inflictor, bulletid, false, 1, penleft, dist)
        -- return

        dir = (2 * degree * tr.HitNormal) + tr.Normal
        ang = dir:Angle()
        ang = ang + (AngleRand() * (1 - degree) * 15 / 360)
        dir = ang:Forward()

        local d = math.Rand(0.25, 0.95)

        penleft = penleft * d

        sound.Play(ricochetsounds[math.random(#ricochetsounds)], tr.HitPos, 75, math.Rand(90, 110), 1)

        skip = true
    end

    // if !tr.HitWorld then penmult = penmult * 0.5 end

    if trent.mmRHAe then penmult = trent.mmRHAe end

    penmult = penmult * math.Rand(0.9, 1.1) * math.Rand(0.9, 1.1)

    local endpos = hitpos

    local td  = {}
    td.start  = endpos
    td.endpos = endpos + (dir * 520000)
    td.mask   = MASK_SHOT

    td.filter = tr.Entity

    // print(SURF_HITBOX)

    // if bit.band(!tr.SurfaceFlags or 0, SURF_HITBOX) == 0 then
        td.start = endpos + dir
    // end

    local ptr = util.TraceLine(td)

    // Penetrate through to whatever the next thing is

    if !ptr.Hit then return end
    if ptr.HitSky then return end

    // If we'd shoot through to the sky, then we don't really care if we can penetrate or not.

    local ntr = util.TraceLine({
        start = ptr.HitPos,
        endpos = endpos,
        mask = MASK_SHOT
    })

    // Go backwards to find out where this thing ends

    debugoverlay.Line(endpos, ntr.HitPos, 10, Color(255, 0, 0), true)

    local dist = (endpos - ntr.HitPos):Length()
    local amt = dist * penmult
    endpos = ntr.HitPos

    penleft = penleft - amt
    range = range + amt

    // while !skip and penleft > 0 and IsPenetrating(ptr, ptrent) and ptr.Fraction < 1 and ptrent == curr_ent do
    //     penleft = penleft - (pentracelen * penmult)

    //     td.start  = endpos
    //     td.endpos = endpos + (dir * pentracelen)
    //     td.mask   = MASK_SHOT

    //     ptr = util.TraceLine(td)

    //     if ARC9.Dev(2) then
    //         local pdeltap = penleft / self:GetValue("Penetration")
    //         local colorlr = Lerp(pdeltap, 0, 255)

    //         debugoverlay.Line(endpos, endpos + (dir * pentracelen), 10, Color(255, colorlr, colorlr), true)
    //     end

    //     endpos = endpos + (dir * pentracelen)
    //     range = range + pentracelen
    // end

    if penleft > 0 then
        if (dir:Length() == 0) then return end

        if GetConVar("ARC9_bullet_physics"):GetBool() then
            ARC9:ShootPhysBullet(self, endpos, dir * self:GetProcessedValue("PhysBulletMuzzleVelocity"), {
                Penleft = penleft,
                Travelled = range,
                Damaged = alreadypenned,
                Indirect = true
            })
        else
            self:GetOwner():FireBullets({
                Damage = self:GetValue("Damage_Max"),
                Force = 4,
                Tracer = 0,
                Num = 1,
                Dir = dir,
                Src = endpos,
                Callback = function(att, btr, dmg)
                    range = range + (btr.HitPos - btr.StartPos):Length()
                    self:AfterShotFunction(btr, dmg, range, penleft, alreadypenned)

                    if ARC9.Dev(2) then
                        if SERVER then
                            debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 0, 0), false)
                        else
                            debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 255, 255), false)
                        end
                    end
                end
            })
        end

        self:GetOwner():FireBullets({
            Damage = 0,
            Force = 0,
            Tracer = 0,
            Num = 1,
            Distance = (ptr.HitPos - ntr.HitPos):Length() + 1,
            Dir = -dir,
            Src = ptr.HitPos - (dir * 1),
        })
    end
end

function SWEP:GetRicochetChance(tr)
    if !GetConVar("ARC9_ricochet"):GetBool() then return 0 end
    local degree = tr.HitNormal:Dot((tr.StartPos - tr.HitPos):GetNormalized())

    degree = 90 - math.deg(math.acos(degree))

    local ricmult = ARC9.PenTable[tr.MatType] or 1

    -- 0 at 1
    -- 100 at 0

    if degree > self:GetProcessedValue("RicochetAngleMax") then return 0 end

    local c = self:GetProcessedValue("RicochetChance")

    c = c * ricmult

    -- c = c * GetConVar("arccw_ricochet_mult"):GetFloat()

    -- c = 100

    c = c * 100

    return math.Clamp(c, 0, 100)
end