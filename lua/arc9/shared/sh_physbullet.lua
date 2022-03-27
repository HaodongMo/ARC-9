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
        Gravity = wep:GetProcessedValue("PhysBulletGravity"),
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

            -- Is this supposed to be 200msec? because this is 200 ticks... which on default tickrate would be 2.9 seconds... which is latency so high you would get dropped from the server.
            latency = math.min(latency, 200) // can't let people cheat TOO hard

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

    local frametime = FrameTime()

    ply:LagCompensation(true)
    ply.ARC9_LAGCOMP = true

    for idx, bullet in ipairs(bullets) do
        self:ProgressPhysBullet(bullet, frametime)

        if bullet.Dead then
            table.remove(bullets, idx)
        end
    end

    ply:LagCompensation(false)
    ply.ARC9_LAGCOMP = false
end

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

    local attacker = bullet.Attacker
    local weapon = bullet.Weapon

    if !IsValid(attacker) then bullet.Dead = true return end

    local dir = bullet.Vel:GetNormalized()
    local spd = bullet.Vel:Length() * timestep

    local drag = bullet.Drag * spd * spd * (1 / 150000)
    local gravity = timestep * GetConVar("ARC9_bullet_gravity"):GetFloat() * (bullet.Gravity or 1) * 600

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
        local tr = util.TraceLine({
            start = oldpos,
            endpos = newpos,
            filter = bullet.Filter,
            mask = MASK_SHOT
        })

        if SERVER then
            debugoverlay.Line(oldpos, tr.HitPos, 5, Color(100,100,255), true)
            debugoverlay.Cross(tr.HitPos, 2, 5, Color(100,100,255), true)
        else
            debugoverlay.Line(oldpos, tr.HitPos, 5, Color(255,200,100), true)
            debugoverlay.Cross(tr.HitPos, 2, 5, Color(255,200,100), true)
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

            if SERVER then
                debugoverlay.Cross(tr.HitPos, 5, 5, Color(100,100,255), true)
            else
                debugoverlay.Cross(tr.HitPos, 5, 5, Color(255,200,100), true)
            end

            local eid = tr.Entity:EntIndex()

            if CLIENT then
                if IsValid(bullet.ClientModel) then
                    local t = weapon:GetProcessedValue("PhysBulletModelStick") or 0
                    if t > 0 then
                        local bone = tr.Entity:TranslatePhysBoneToBone(tr.PhysicsBone) or tr.Entity:GetHitBoxBone(tr.HitBox, tr.Entity:GetHitboxSet())
                        local matrix = tr.Entity:GetBoneMatrix(bone or 0)
                        if bone and matrix then
                            local pos = matrix:GetTranslation()
                            local ang = matrix:GetAngles()
                            bullet.ClientModel:FollowBone(tr.Entity, bone)
                            local n_pos, n_ang = WorldToLocal(tr.HitPos, tr.Normal:Angle(), pos, ang)
                            bullet.ClientModel:SetLocalPos(n_pos)
                            bullet.ClientModel:SetLocalAngles(n_ang)
                        else
                            bullet.ClientModel:SetPos(bullet.Pos)
                            bullet.ClientModel:SetAngles(bullet.Vel:Angle())
                            bullet.ClientModel:SetParent(tr.Entity)
                        end
                    end
                    SafeRemoveEntityDelayed(bullet.ClientModel, t)
                end
                bullet.Dead = true
            elseif SERVER then
                bullet.Damaged[eid] = true
                bullet.Dead = true

                if IsValid(bullet.Attacker) then
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
            end
        else


            bullet.Pos = tr.HitPos
            bullet.Vel = newvel
            bullet.Travelled = bullet.Travelled + spd

            if CLIENT or game.SinglePlayer() then
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
    end

    if bullet.Guidance and attacker then
        local tgt_point = attacker:EyePos() + (attacker:EyeAngles():Forward() * 35000)

        local tgt_dir = (tgt_point - oldpos):GetNormalized()

        bullet.Vel = bullet.Vel + (tgt_dir * timestep * (bullet.GuidanceAmount or 15000))
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
            -- local col = Color(255, 225, 200)

            render.SetMaterial(head)
            render.DrawSprite(pos, headsize, headsize, col)

            render.SetMaterial(tracer)
            render.DrawBeam(pos, pos + (vec * math.min(i.Vel:Length() * 0.1, math.min(512, i.Travelled - 64))), size * 0.75, 1, 0, col)
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