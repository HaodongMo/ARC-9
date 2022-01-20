ARC9.PhysBullets = {
}

function ARC9:SendBullet(bullet, attacker)
    net.Start("ARC9_sendbullet", true)
    net.WriteVector(bullet.Pos)
    net.WriteAngle(bullet.Vel:Angle())
    net.WriteFloat(bullet.Vel:Length())
    net.WriteFloat(bullet.Travelled)
    net.WriteFloat(bullet.Drag)
    net.WriteFloat(bullet.Gravity)
    net.WriteEntity(bullet.Weapon)

    if attacker and attacker:IsValid() and attacker:IsPlayer() and !game.SinglePlayer() then
        net.SendOmit(attacker)
    else
        if game.SinglePlayer() then
            net.WriteEntity(attacker)
        end
        net.Broadcast()
    end
end

function ARC9:ShootPhysBullet(wep, pos, vel, tbl)
    tbl = tbl or {}
    local bullet = {
        Penleft = wep:GetProcessedValue("Penetration"),
        Gravity = wep:GetProcessedValue("PhysBulletGravity"),
        Pos = pos,
        Vel = vel,
        Drag = wep:GetProcessedValue("PhysBulletDrag"),
        Travelled = 0,
        StartTime = CurTime(),
        Imaginary = false,
        Underwater = false,
        Weapon = wep,
        Attacker = wep:GetOwner(),
        Filter = {wep:GetOwner()},
        Damaged = {},
        Dead = false,
    }

    for i, k in pairs(tbl) do
        bullet[i] = k
    end

    if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
        bullet.Underwater = true
    end

    table.insert(ARC9.PhysBullets, bullet)

    if !game.SinglePlayer() then
        local owner = wep:GetOwner()
        if owner:IsPlayer() and SERVER then
            local latency = engine.TickCount() - owner:GetCurrentCommand():TickCount()
            local timestep = engine.TickInterval()

            latency = math.max(latency, 300) // can't let people cheat TOO hard

            while latency > 0 do
                ARC9:ProgressPhysBullet(bullet, timestep)
                latency = latency - 1
            end
        end
    end

    if SERVER then
        -- ARC9:ProgressPhysBullet(bullet, FrameTime())

        ARC9:SendBullet(bullet, wep:GetOwner())
    end
end

if CLIENT then

net.Receive("ARC9_sendbullet", function(len, ply)
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local vel = net.ReadFloat()
    local trav = net.ReadFloat()
    local drag = net.ReadFloat()
    local grav = net.ReadFloat()
    local weapon = net.ReadEntity()
    local ent = nil

    if game.SinglePlayer() then
        ent = net.ReadEntity()
    end

    local bullet = {
        Pos = pos,
        Vel = ang:Forward() * vel,
        Travelled = trav or 0,
        StartTime = CurTime(),
        Imaginary = false,
        Underwater = false,
        Dead = false,
        Damaged = {},
        Drag = drag,
        Attacker = ent,
        Gravity = grav,
        Weapon = weapon,
        Color = weapon:GetProcessedValue("TracerColor"),
        Fancy = weapon:GetProcessedValue("FancyBullets"),
        Size = weapon:GetProcessedValue("TracerSize"),
        Invisible = false
    }

    if !weapon:ShouldTracer() then
        bullet.Invisible = true
    end

    if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
        bullet.Underwater = true
    end

    table.insert(ARC9.PhysBullets, bullet)
end)

end

function ARC9:DoPhysBullets()
    local new = {}
    for _, i in pairs(ARC9.PhysBullets) do
        ARC9:ProgressPhysBullet(i, FrameTime())

        if !i.Dead then
            table.insert(new, i)
        end
    end

    ARC9.PhysBullets = new
end

hook.Add("Think", "ARC9_DoPhysBullets", ARC9.DoPhysBullets)

local function indim(vec, maxdim)
    if math.abs(vec.x) > maxdim or math.abs(vec.y) > maxdim or math.abs(vec.z) > maxdim then
        return false
    else
        return true
    end
end

function ARC9:ProgressPhysBullet(bullet, timestep)
    timestep = timestep or FrameTime()

    if bullet.Dead then return end

    local oldpos = bullet.Pos
    local oldvel = bullet.Vel
    local dir = bullet.Vel:GetNormalized()
    local spd = bullet.Vel:Length() * timestep
    local drag = bullet.Drag * spd * spd * (1 / 150000)
    local gravity = timestep * GetConVar("ARC9_bullet_gravity"):GetFloat() * (bullet.Gravity or 1) * 600

    local attacker = bullet.Attacker
    local weapon = bullet.Weapon

    -- if !IsValid(attacker) then
    --     bullet.Dead = true
    --     return
    -- end

    if !IsValid(weapon) then
        bullet.Dead = true
        return
    end

    if bullet.Fancy then
        weapon:RunHook("HookP_ModifyBullet", bullet)

        if bullet.Dead then return end
    end

    if bullet.Underwater then
        drag = drag * 3
    end

    drag = drag * GetConVar("ARC9_bullet_drag"):GetFloat()

    if spd <= 0.001 then bullet.Dead = true return end

    local newpos = oldpos + (oldvel * timestep)
    local newvel = oldvel - (dir * drag)
    newvel = newvel - (Vector(0, 0, 1) * gravity)

    if bullet.Imaginary then
        -- the bullet has exited the map, but will continue being visible.
        bullet.Pos = newpos
        bullet.Vel = newvel
        bullet.Travelled = bullet.Travelled + spd

        if CLIENT and !GetConVar("ARC9_bullet_imaginary"):GetBool() then
            bullet.Dead = true
        end
    else
        if attacker:IsPlayer() then
            attacker:LagCompensation(true)
        end

        local tr = util.TraceLine({
            start = oldpos,
            endpos = newpos,
            filter = bullet.Filter,
            mask = MASK_SHOT
        })

        if attacker:IsPlayer() then
            attacker:LagCompensation(false)
        end

        if SERVER then
            debugoverlay.Line(oldpos, tr.HitPos, 5, Color(100,100,255), true)
        else
            debugoverlay.Line(oldpos, tr.HitPos, 5, Color(255,200,100), true)
        end

        if tr.HitSky then
            if CLIENT and GetConVar("ARC9_bullet_imaginary"):GetBool() then
                bullet.Imaginary = true
            else
                bullet.Dead = true
            end

            bullet.Pos = newpos
            bullet.Vel = newvel
            bullet.Travelled = bullet.Travelled + spd

            if SERVER then
                bullet.Dead = true
            end
        elseif tr.Hit then
            bullet.Travelled = bullet.Travelled + (oldpos - tr.HitPos):Length()
            bullet.Pos = tr.HitPos
            -- if we're the client, we'll get the bullet back when it exits.

            if attacker:IsPlayer() then
                attacker:LagCompensation(true)
            end

            if SERVER then
                debugoverlay.Cross(tr.HitPos, 5, 5, Color(100,100,255), true)
            else
                debugoverlay.Cross(tr.HitPos, 5, 5, Color(255,200,100), true)
            end

            local eid = tr.Entity:EntIndex()

            if CLIENT then
                -- do an impact effect and forget about it
                if !game.SinglePlayer() then
                    attacker:FireBullets({
                        Src = oldpos,
                        Dir = dir,
                        Distance = spd + 16,
                        Tracer = 0,
                        Damage = 0,
                        IgnoreEntity = bullet.Attacker
                    })
                end
                bullet.Dead = true
            elseif SERVER then
                bullet.Damaged[eid] = true
                bullet.Dead = true

                bullet.Attacker:FireBullets({
                    Damage = weapon:GetProcessedValue("Damage_Max"),
                    Force = 8,
                    Tracer = 0,
                    Num = 1,
                    Dir = bullet.Vel:GetNormalized(),
                    Src = oldpos,
                    Spread = Vector(0, 0, 0),
                    Callback = function(att, btr, dmg)
                        local range = bullet.Travelled

                        weapon:AfterShotFunction(btr, dmg, range, bullet.Penleft, bullet.Damaged)
                    end
                })
            end

            if attacker:IsPlayer() then
                attacker:LagCompensation(false)
            end
        else
            -- bullet did not impact anything
            -- break glass in the way
            -- attacker:FireBullets({
            --     Src = oldpos,
            --     Dir = dir,
            --     Distance = spd,
            --     Tracer = 0,
            --     Damage = 0,
            --     IgnoreEntity = bullet.Attacker
            -- })

            bullet.Pos = tr.HitPos
            bullet.Vel = newvel
            bullet.Travelled = bullet.Travelled + spd

            if bullet.Underwater then
                if bit.band( util.PointContents( tr.HitPos ), CONTENTS_WATER ) != CONTENTS_WATER then
                    local utr = util.TraceLine({
                        start = tr.HitPos,
                        endpos = oldpos,
                        filter = bullet.Attacker,
                        mask = MASK_WATER
                    })

                    if utr.Hit then
                        local fx = EffectData()
                        fx:SetOrigin(utr.HitPos)
                        fx:SetScale(5)
                        fx:SetFlags(0)
                        util.Effect("gunshotsplash", fx)
                    end

                    bullet.Underwater = false
                end
            else
                if bit.band( util.PointContents( tr.HitPos ), CONTENTS_WATER ) == CONTENTS_WATER then
                    local utr = util.TraceLine({
                        start = oldpos,
                        endpos = tr.HitPos,
                        filter = bullet.Attacker,
                        mask = MASK_WATER
                    })

                    if utr.Hit then
                        local fx = EffectData()
                        fx:SetOrigin(utr.HitPos)
                        fx:SetScale(5)
                        fx:SetFlags(0)
                        util.Effect("gunshotsplash", fx)
                    end

                    bullet.Underwater = true
                end
            end
        end
    end

    local MaxDimensions = 16384 * 4
    local WorldDimensions = 16384

    if bullet.StartTime <= (CurTime() - GetConVar("ARC9_bullet_lifetime"):GetFloat()) then
        bullet.Dead = true
    elseif !indim(bullet.Pos, MaxDimensions) then
        bullet.Dead = true
    elseif !indim(bullet.Pos, WorldDimensions) then
        bullet.Imaginary = true
    end
end

local head = Material("particle/fire")
local tracer = Material("arc9/tracer.png", "additive")

function ARC9.DrawPhysBullets()
    cam.Start3D()
    for _, i in pairs(ARC9.PhysBullets) do
        if i.Invisible then continue end
        if i.Travelled <= 512 then continue end

        local pos = i.Pos

        local size = 1

        size = size * math.log(EyePos():DistToSqr(pos) - math.pow(512, 2))

        size = math.Clamp(size, 0, math.huge)

        local headsize = size

        local delta = (EyePos():DistToSqr(pos) / math.pow(10000, 2))

        headsize = math.pow(headsize, Lerp(delta, 0, 2))

        size = size * i.Size

        -- cam.Start3D()

        local col = i.Color or Color(255, 225, 200)
        -- local col = Color(255, 225, 200)

        render.SetMaterial(head)
        render.DrawSprite(pos, headsize, headsize, col)

        render.SetMaterial(tracer)

        local fromvec = (i.Weapon:GetTracerOrigin() - pos):GetNormalized()
        local speedvec = -i.Vel:GetNormalized()

        local d = math.min(i.Travelled / 1024, 1)

        local vec = LerpVector(d, fromvec, speedvec)

        render.DrawBeam(pos, pos + (vec * math.min(i.Vel:Length() * 0.1, math.min(512, i.Travelled))), size * 0.75, 0, 1, col)

        -- cam.End3D()
    end
    cam.End3D()
end

hook.Add("PreDrawEffects", "ARC9_DrawPhysBullets", ARC9.DrawPhysBullets)

hook.Add("PostCleanupMap", "ARC9_CleanPhysBullets", function()
    ARC9.PhysBullets = {}
end)