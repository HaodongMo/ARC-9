ARC9.PhysBulletModels = ARC9.PhysBulletModels or {}
ARC9.PhysBulletModelsLookup = ARC9.PhysBulletModelsLookup or {}

if SERVER then
    util.AddNetworkString("arc9_physbulletmodels")

    net.Receive("arc9_physbulletmodels", function(len, ply)
        if !ply.ARC9_HASPHYSBULLETMODELS then
            ARC9:SendPhysBulletModels(ply)
            ply.ARC9_HASPHYSBULLETMODELS = true
        end
    end)

    function ARC9:SendPhysBulletModels(ply)
        net.Start("arc9_physbulletmodels")
        net.WriteUInt(#ARC9.PhysBulletModels, 8)
        for i, v in ipairs(ARC9.PhysBulletModels) do
            net.WriteString(v)
        end

        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end
end

function ARC9:RegisterPhysBulletModel(model)
    model = string.lower(model)
    if #ARC9.PhysBulletModels >= 255 then return -1 end
    if ARC9.PhysBulletModelsLookup[model] then return ARC9.PhysBulletModelsLookup[model] end
    local index = table.insert(ARC9.PhysBulletModels, model)
    ARC9.PhysBulletModelsLookup[model] = index
    return index
end

function ARC9:SendBullet(bullet, attacker)
    net.Start("ARC9_sendbullet", true)
    net.WriteVector(bullet.Pos)
    net.WriteAngle(bullet.Vel:Angle())
    net.WriteFloat(bullet.Vel:Length())
    net.WriteFloat(bullet.Travelled)
    net.WriteFloat(bullet.Drag)
    net.WriteFloat(bullet.Gravity)
    net.WriteBool(bullet.Indirect or false)
    net.WriteEntity(bullet.Weapon)
    net.WriteEntity(attacker)
    net.WriteUInt(bullet.ModelIndex or 0, 8)

    if attacker and attacker:IsValid() and attacker:IsPlayer() and !game.SinglePlayer() then
        net.SendOmit(attacker)
    else
        net.Broadcast()
    end
end

function ARC9:ShootPhysBullet(wep, pos, vel, tbl)
    local owner = wep:GetOwner()
    local physmdl = wep:GetProcessedValue("PhysBulletModel")
    local mdlindex = ARC9.PhysBulletModelsLookup[string.lower(physmdl or "")] or 0

    if physmdl and mdlindex == 0 then
        print("\nARC9 encountered unregistered PhysBulletModel '" .. physmdl .. "'!\nWe will register and refresh this model for all clients, but this is network-intensive!\n\nPlease tell the addon developer to register the model in a shared lua file like so: ARC9:RegisterPhysBulletModel(\"" .. physmdl .. "\")")
        mdlindex = ARC9:RegisterPhysBulletModel(physmdl)
        if SERVER then ARC9:SendPhysBulletModels() end
    end

    tbl = tbl or {}
    local bullet = {
        Penleft = wep:GetProcessedValue("Penetration"),
        Gravity = wep:GetProcessedValue("PhysBulletGravity") * GetConVar("ARC9_bullet_gravity"):GetFloat(),
        Pos = pos,
        Vel = vel,
        Drag = wep:GetProcessedValue("PhysBulletDrag") * GetConVar("ARC9_bullet_drag"):GetFloat(),
        Travelled = 0,
        StartTime = CurTime(),
        Imaginary = false,
        Underwater = false,
        Weapon = wep,
        ModelIndex = mdlindex,
        Attacker = owner,
        TraceData = {
            start = Vector(0, 0, 0),
            endpos = Vector(0, 0, 0),
            mask = MASK_SHOT,
            filter = {owner}
        },
        Filter = {owner},
        Damaged = {},
        Dead = false,
        Color = wep:GetProcessedValue("TracerColor"),
        Fancy = wep:GetProcessedValue("FancyBullets"),
        Size = wep:GetProcessedValue("TracerSize"),
        Guidance = wep:GetProcessedValue("BulletGuidance"),
        GuidanceAmount = wep:GetProcessedValue("BulletGuidanceAmount"),
    }

    for i, k in pairs(tbl) do
        bullet[i] = k
    end

    if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
        bullet.Underwater = true
    end

    wep:RunHook("HookP_ModifyNewBullet", bullet)
    if bullet.Dead then return end

    if not owner.ARC9Bullets then owner.ARC9Bullets = {} end

    table.insert(owner.ARC9Bullets, bullet)

    ARC9:ProgressPhysBullet(bullet, FrameTime())

    if !game.SinglePlayer() then
        if owner:IsPlayer() and SERVER and !owner:IsListenServerHost() then
            local latency = engine.TickCount() - owner:GetCurrentCommand():TickCount()
            local timestep = engine.TickInterval()

            latency = math.min(latency, ARC9.TimeToTicks(0.2)) // can't let people cheat TOO hard

            while latency > 0 do
                ARC9:ProgressPhysBullet(bullet, timestep)
                latency = latency - 1
            end
        end

        if CLIENT and mdlindex > 0 then
            local mdl = ARC9.PhysBulletModels[mdlindex]
            bullet.ClientModel = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
            bullet.ClientModel:SetMoveType(MOVETYPE_NONE)
        end
    end

    if SERVER then
        ARC9:SendBullet(bullet, owner)
    end
end

if CLIENT then

net.Receive("arc9_sendbullet", function(len, ply)
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local vel = net.ReadFloat()
    local trav = net.ReadFloat()
    local drag = net.ReadFloat()
    local grav = net.ReadFloat()
    local indirect = net.ReadBool()
    local weapon = net.ReadEntity()
    local attacker = net.ReadEntity()
    local modelindex = net.ReadUInt(8)

    if !IsValid(weapon) then return end
    if !weapon.ARC9 then return end

    local bullet = {
        Pos = pos,
        Vel = ang:Forward() * vel,
        Travelled = trav or 0,
        StartTime = CurTime(),
        Imaginary = false,
        Underwater = false,
        Indirect = indirect,
        Dead = false,
        Damaged = {},
        Drag = drag,
        Attacker = attacker,
        Gravity = grav,
        Weapon = weapon,
        ModelIndex = modelindex,
        Color = weapon:GetProcessedValue("TracerColor"),
        Fancy = weapon:GetProcessedValue("FancyBullets"),
        Size = weapon:GetProcessedValue("TracerSize"),
        Filter = {attacker},
        Guidance = weapon:GetProcessedValue("BulletGuidance"),
        GuidanceAmount = weapon:GetProcessedValue("BulletGuidanceAmount"),
        Invisible = false
    }

    if !weapon:ShouldTracer() then
        bullet.Invisible = true
    end

    if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
        bullet.Underwater = true
    end

    if modelindex > 0 then
        local mdl = ARC9.PhysBulletModels[modelindex]
        bullet.ClientModel = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
        bullet.ClientModel:SetMoveType(MOVETYPE_NONE)
    end

    table.insert(attacker.ARC9Bullets, bullet)
end)

net.Receive("arc9_physbulletmodels", function()
    ARC9.PhysBulletModels = {}
    local count = net.ReadUInt(8)
    for i = 1, count do
        ARC9.PhysBulletModels[i] = net.ReadString()
        ARC9.PhysBulletModelsLookup[ARC9.PhysBulletModels[i]] = i
    end
end)

hook.Add("InitPostEntity", "ARC9_RetrievePhysBulletModels", function()
    net.Start("arc9_physbulletmodels")
    net.SendToServer()
end)

end

function ARC9:SimulatePhysBullets(ply)
    local bullets = ply.ARC9Bullets
    if !bullets or #bullets == 0 then
        return
    end

    -- Set the math random seed to prediction random seed before updating bullets to keep them in sync between client and server.
    math.randomseed(ply:GetCurrentCommand():CommandNumber())

    local frametime = FrameTime()
    -- This is gucci af, because since we are simulating in SetupMove all of this is relative to the player's current clock.
    local dietime = CurTime() - GetConVar("ARC9_bullet_lifetime"):GetFloat()

    -- ply:LagCompensation(true)
    -- ply.ARC9_LAGCOMP = true

    for idx, bullet in ipairs(bullets) do
        self:ProgressPhysBullet(bullet, frametime)

        if bullet.Dead or bullet.StartTime <= dietime then
            table.remove(bullets, idx)
        end
    end

    -- ply:LagCompensation(false)
    -- ply.ARC9_LAGCOMP = false
end

local function indim(vec, maxdim)
    if math.abs(vec.x) > maxdim or math.abs(vec.y) > maxdim or math.abs(vec.z) > maxdim then
        return false
    else
        return true
    end
end

function ARC9:DoImpactEffect(trace)
    if trace.HitSky or trace.HitNoDraw then
        return
    end

    local impactData = EffectData()
    impactData:SetStart(trace.StartPos)
    impactData:SetOrigin(trace.HitPos)
    impactData:SetNormal(trace.HitNormal)
    impactData:SetEntity(trace.Entity)
    impactData:SetHitBox(trace.HitBox)
    impactData:SetDamageType(DMG_BULLET)
    impactData:SetSurfaceProp(trace.SurfaceProps)

    util.Effect("Impact", impactData)

    -- TODO: Figure out better way to do this or add MAT_ALIENFLESH, MAT_BLOODYFLESH, etc.
    if SERVER and trace.MatType == MAT_FLESH or trace.MatType == MAT_ANTLION
    and bit.band(trace.SurfaceFlags, SURF_HITBOX) == SURF_HITBOX and IsValid(trace.Entity) then
        local bloodColor = trace.Entity:GetBloodColor() or BLOOD_COLOR_RED
        local bloodData = EffectData()
        bloodData:SetOrigin(trace.HitPos)
        bloodData:SetNormal(trace.HitNormal * -1)
        bloodData:SetColor(bloodColor)
        util.Effect("BloodImpact", bloodData, false, true)
        bloodData:SetColor(BLOOD_COLOR_RED)
        bloodData:SetScale(6)
        bloodData:SetFlags(3)
        util.Effect("bloodspray", bloodData, false, true)
    end
end

-- TODO: Fuse or port stuff from SWEP:AfterFireFunction() and other stuff here...
function ARC9:HandlePhysBulletImpact(bullet, trace)
    -- Create decal at the bullet's impact point
    self:DoImpactEffect(trace)

    -- Do damage if we hit a entity.
    local hitEntity = trace.Entity
    if SERVER and IsValid(hitEntity) then -- TODO: if entity's m_takedamage netvar is DAMAGE_NO then don't do any of this?
        local attacker = bullet.Attacker
        local inflictor = bullet.Weapon
        local damage = inflictor:GetDamageAtRange(bullet.Travelled)
        local damageInfo = DamageInfo()
        damageInfo:SetAttacker(attacker)
        damageInfo:SetInflictor(inflictor)
        damageInfo:SetDamage(damage)
        damageInfo:SetDamagePosition(trace.HitPos)
        damageInfo:SetDamageForce(trace.Normal * 80)
        damageInfo:SetReportedPosition(trace.HitPos)
        damageInfo:SetDamageType(bit.bor(DMG_BULLET, DMG_NEVERGIB))
        damageInfo:SetAmmoType(game.GetAmmoID("")) -- uhhh?

        local suppressDamage = false

        -- WONDER: Do we actually want to do this?
        if hitEntity:IsPlayer() then
            hitEntity:SetLastHitGroup(trace.HitGroup)
            suppressDamage = hook.Run("ScalePlayerDamage", hitEntity, trace.HitGroup, damageInfo)
        elseif hitEntity:IsNPC() or hitEntity:IsNextBot() then
            hook.Run("ScaleNPCDamage", hitEntity, trace.HitGroup, damageInfo)
        end

        -- TODO: If we hit hunter chopper do AP ammo calcs from AfterFireFunction

        -- TODO: body damage cancel thing.
        -- if GetConVar("ARC9_bodydamagecancel"):GetBool() then

        -- end

        if not suppressDamage then
            -- HACK!!
            -- Source engine applies a really annoying hard-coded push back to players when TakeDamageInfo is called.
            -- I don't like this push back because it creates prediction errors and is just in general annoying.
            -- Here's a really hacky way to bypass it.
            -- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/server/player.cpp#L1611

            -- TODO: Check if arc9_bullet_physics_knockback is one or something??
            local solidflags = attacker:GetSolidFlags()
            attacker:AddSolidFlags(FSOLID_TRIGGER)

            hitEntity:TakeDamageInfo(damageInfo)

            attacker:SetSolidFlags(solidflags)
        end
    end
end

-- TODO: Massive clean up on this code, it looks messy and hard to understand.
function ARC9:ProgressPhysBullet(bullet, timestep)
    if bullet.Dead then return end

    local attacker = bullet.Attacker
    local weapon = bullet.Weapon
    if !IsValid(attacker) or !IsValid(weapon) then
        bullet.Dead = true
        return
    end

    local velocity = bullet.Vel
    local spd = bullet.Vel:Length() * timestep

    if spd <= 0.001 then bullet.Dead = true return end

    if bullet.Fancy then
        weapon:RunHook("HookP_ModifyBullet", bullet)

        if bullet.Dead then return end
    end

    local dir = bullet.Vel:GetNormalized()
    local drag = bullet.Drag * spd * spd * (1 / 150000)
    local gravity = (bullet.Gravity or 1) * 600 * timestep -- sv_gravity?

    if bullet.Underwater then
        drag = drag * 3
    end

    local pos = bullet.Pos
    local accel = (ARC9_VECTORUP * -gravity) - (dir * drag)
    if bullet.Guidance and attacker then
        local tgt_point = attacker:EyePos() + (attacker:EyeAngles():Forward() * 35000)
        local tgt_dir = (tgt_point - pos):GetNormalized()

        accel:Add(tgt_dir * timestep * (bullet.GuidanceAmount or 15000))
    end

    local nextpos = pos + (velocity * timestep)
    local nextvelocity = velocity + accel

    local MaxDimensions = 16384 * 4
    local WorldDimensions = 16384

    if !indim(nextpos, MaxDimensions) then
        bullet.Dead = true
        return
    elseif !indim(nextpos, WorldDimensions) then
        bullet.Imaginary = true
    end

    if bullet.Imaginary then
        bullet.Pos:Set(nextpos)
        bullet.Vel:Set(nextvelocity)
        bullet.Travelled = bullet.Travelled + spd
        return
    end

    local traceDataRef = bullet.TraceData

    local debugoverlayColor = Either(SERVER, Color(103, 103, 230, 55), Color(207, 75, 75, 55))

    traceDataRef.start:Set(pos)
    traceDataRef.endpos:Set(nextpos)

    -- For some reason which I can not explain to myself, lag compensation only works if it's done here per trace, rather than in DoPhysBullets(), what the f?
    -- This needs fixing, ASAP, because doing it per bullet and per simulation tick is INCREDIBLY demanding.
    attacker:LagCompensation(true)
    local enterTraceResult = util.TraceLine(traceDataRef)
    attacker:LagCompensation(false)

    local hitPos = enterTraceResult.HitPos

    debugoverlay.Line(enterTraceResult.StartPos, hitPos, 4, debugoverlayColor, true)
    debugoverlay.Cross(hitPos, 3, 4, debugoverlayColor, true)

    bullet.Pos:Set(hitPos)
    bullet.Vel:Set(nextvelocity)
    bullet.Travelled = bullet.Travelled + spd

    -- TODO: Handle trace->water intersections and water splash effects.

    -- We didn't hit anything, move on...
    if enterTraceResult.Fraction == 1 then
        return
    end

    -- sv_showimpacts on budget
    debugoverlay.Box(hitPos, Vector(-1, -1, -1), Vector(1, 1, 1), 4, Either(SERVER, Color(0, 0, 255, 127), Color(255, 0, 0, 127)))

    -- We've hit something here, so let's handle it.

    -- If we hit sky, make the bullet imaginary or yeet it.
    if enterTraceResult.HitSky then
        bullet.Imaginary = true

        if SERVER or (CLIENT and !GetConVar("ARC9_bullet_imaginary"):GetBool())  then
            bullet.Dead = true
        end

        return
    end

    self:HandlePhysBulletImpact(bullet, enterTraceResult)

    if weapon:GetRicochetChance(enterTraceResult) > math.random(0, 100) then
        local degree = enterTraceResult.HitNormal:Dot(enterTraceResult.Normal * -1)
        if degree == 0 or degree == 1 then return end
        -- sound.Play(ArcCW.RicochetSounds[math.random(#ArcCW.RicochetSounds)], enterTraceResult.HitPos)
        if enterTraceResult.Normal:Length() == 0 then return end

        local penMult = math.Rand(0.25, 0.95)
        local deflectDir = (2 * degree * enterTraceResult.HitNormal) + enterTraceResult.Normal
        local deflectAng = deflectDir:Angle()
        deflectAng:Add(AngleRand() * (1 - degree) * 15 / 360)

        -- TODO: Fix lost travelled distance (NITPICK LOL), and ofc find the best way to do it first.
        bullet.Pos:Sub(deflectAng:Forward())
        bullet.Vel:Set(deflectAng:Forward() * nextvelocity:Length())
        bullet.Penleft = bullet.Penleft * penMult

        return
    end

    -- No penetration on this bullet, we did our work here, bye.
    local penetrationPower = bullet.Penleft * 4
    if penetrationPower <= 0 or not GetConVar("ARC9_penetration"):GetBool() then
        bullet.Dead = true
        return
    end

    -- TODO: Wrap this in a "DoWallPenetrationTrace" or "TraceToExit" function to clean up the code
    -- {
    local rayExtension = ARC9.PenetrationTraceStepSize
    local penetrationDepth = 0
    local depthMultiplier = ARC9.PenTable[enterTraceResult.MatType] or 1
    local maxPenetrationDepth = math.max(penetrationPower * depthMultiplier / 8, 1)
    local bulletStopped = true
    local exitTraceData = table.Copy(traceDataRef)
    local exitTraceResult = {}
    exitTraceData.output = exitTraceResult

    while (penetrationDepth < maxPenetrationDepth) do -- TODO: Fix additional travelled distance (NITPICK LOL) by doing < math.min(distanceLeft, maxPenetrationDepth)
        penetrationDepth = penetrationDepth + rayExtension

        exitTraceData.start:Set(hitPos + dir * penetrationDepth)
        exitTraceData.endpos:Set(exitTraceData.start - dir * rayExtension)

        util.TraceLine(exitTraceData)

        -- if IsFirstTimePredicted() then
        --     debugoverlay.Line(exitTraceResult.HitPos, exitTraceResult.StartPos, 4, Either(SERVER, Color(0, 0, 255, 27), Color(255, 0, 0, 27)), true)
        --     debugoverlay.Box(exitTraceResult.HitPos, Vector(1, 1, 1) * -0.5, Vector(1, 1, 1) * 0.5, 4, Either(SERVER, Color(0, 0, 255, 27), Color(255, 0, 0, 27)))
        -- end

        -- FIXME: This will error out if the trace enters a wall and exits from player's hitbox, the player will not take damage because the code sees him as part of the wall.
        -- FIXME: (UNABLE TO FIX): These small traces will not intersect with entity's OBB box and therefore bullet penetration will break if the hitbox we are trying to penetrate through is not inside entity's OBB.
        if exitTraceResult.Hit and not exitTraceResult.StartSolid then
            --If we've exited into an entity's hitbox we offset the penetration exit by 0.1 units forward to prevent the trace from getting stuck inside the hitbox.
            if bit.band(enterTraceResult.SurfaceFlags, SURF_HITBOX) == SURF_HITBOX then
                exitTraceResult.HitPos:Add(dir * 0.1)
            end

            -- TODO: Fix displacement and no-draw surface errors on some maps.
            -- TODO BEFORE THE TODO: Find out when and how these occur in first place.

            bulletStopped = false
            break
        end
    end
    -- }

    if bulletStopped then
        bullet.Dead = true
        return
    end

    if IsFirstTimePredicted() then
        self:DoImpactEffect(exitTraceResult)
    end

    local distanceTravelledInSolid = (hitPos - exitTraceResult.HitPos):Length()
    if not enterTraceResult.HitWorld then
        depthMultiplier = depthMultiplier * 0.5
    end

    local hitEntity = enterTraceResult.Entity
    if hitEntity.mmRHAe then
        depthMultiplier = hitEntity.mmRHAe
    end

    depthMultiplier = depthMultiplier * math.Rand(0.9, 1.1) * math.Rand(0.9, 1.1)


    -- TODO: make bullets loose velocity n stuff on penetration?
    bullet.Pos:Set(exitTraceResult.HitPos)
    bullet.Travelled = bullet.Travelled + distanceTravelledInSolid
    bullet.Penleft = bullet.Penleft - distanceTravelledInSolid * depthMultiplier
end

local head = Material("particle/fire")
local tracer = Material("arc9/tracer")

-- FIXME: Because we are simulating on ticks, on low tick-rate bullets might look choppy or laggy for people with high refresh rate screens
-- TODO: Add Inter-tick interpolation.
function ARC9.DrawPhysBullets()
    cam.Start3D()
    for idx, ply in ipairs(player.GetAll()) do
        if !ply.ARC9Bullets or #ply.ARC9Bullets == 0 then
            continue
        end

        local eyepos = EyePos()
        for _, i in ipairs(ply.ARC9Bullets) do
            if i.Invisible then continue end
            if i.Travelled <= (i.ModelIndex == 0 and 512 or 64) then continue end

            local pos = i.Pos
            local speedvec = -i.Vel:GetNormalized()
            local vec = speedvec
            local shoulddraw = true

            if IsValid(i.Weapon) then
                shoulddraw = i.Weapon:RunHook("HookC_DrawBullet", i)

                local fromvec = (i.Weapon:GetTracerOrigin() - pos):GetNormalized()

                local d = math.min(i.Travelled / 1024, 1)
                if i.Indirect then
                    d = 1
                end

                vec = LerpVector(d, fromvec, speedvec)
            end

            if !shoulddraw then continue end

            if i.ModelIndex != 0 then
                if IsValid(i.ClientModel) then
                    i.ClientModel:SetPos(pos)
                    i.ClientModel:SetAngles(i.Vel:Angle())
                    --i.ClientModel:DrawModel()
                end
                continue
            end

            local size = math.log(eyepos:DistToSqr(pos) - math.pow(512, 2))

            size = math.Clamp(size, 0, math.huge)

            size = size * i.Size

            local headsize = size

            headsize = headsize * math.min(eyepos:DistToSqr(pos) / math.pow(5000, 2), 2.5)

            local col = i.Color or color_white
            local lengthVec = vec * math.min(i.Vel:Length() * 0.1, math.min(512, i.Travelled - 64))
            -- local col = Color(255, 225, 200)

            render.SetMaterial(head)
            render.DrawSprite(pos, headsize, headsize, col)

            render.SetMaterial(tracer)
            render.DrawBeam(pos - lengthVec * 0.5, pos + lengthVec * 0.5, size * 0.75, 1, 0, col)
        end
    end
    cam.End3D()
end

hook.Add("PreDrawEffects", "ARC9_DrawPhysBullets", ARC9.DrawPhysBullets)

hook.Add("PostCleanupMap", "ARC9_CleanPhysBullets", function()
    for idx, ply in ipairs(player.GetAll()) do
        if ply.ARC9Bullets then
            table.Empty(ply.ARC9Bullets)
        end
    end
end)