-- i heard this lower fps to 5




function SWEP:CanLockOn(ent)
    local _, reject = self:RunHook("HookC_CannotLockOn", ent)
    if reject then return false end
    if !IsValid(ent) then return false end
    if ent:IsWorld() then return false end
    if ent == self:GetOwner() then return false end

    local canlock = false

    if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and self:GetProcessedValue("LocksLiving", true) then
        canlock = true
    end

    if !canlock then
        local lockair = self:GetProcessedValue("LocksAir", true)
        local lockground = self:GetProcessedValue("LocksGround", true)

        if lockair and lockground then
            canlock = true
        elseif lockair or lockground then
            local tr = util.TraceHull({
                start = ent:GetPos(),
                endpos = ent:GetPos() - Vector(0, 0, 256),
                filter = ent,
                mask = MASK_NPCWORLDSTATIC,
                mins = ent:OBBMins(),
                maxs = ent:OBBMaxs()
            })

            if lockair and (!tr.HitWorld or tr.HitSky) then
                canlock = true
            elseif lockground and tr.HitWorld and !tr.HitSky then
                canlock = true
            end
        end
    end

    if ent:Health() == 0 then canlock = false end

    if !canlock then
        local _, can = self:RunHook("HookC_CanLockOn", ent)

        if can then return true end
    end

    return canlock
end

function SWEP:GetLockOnScore(ent, pure)
    local score = 0

    local dot = self:GetOwner():GetAimVector():Dot((ent:GetPos() - self:GetShootPos()):GetNormalized())

    if math.deg(math.acos(dot)) > self:GetProcessedValue("LockOnFOV", true) then return 0 end

    score = score + (math.deg(math.acos(dot)) / 2)
    if pure then return score end

    if ent:IsPlayer() then
        score = score + 100
    end

    if ent:IsNPC() then
        score = score + 25
    end

    if ent:Health() > 0 then
        score = score + (ent:Health() / 7.5)
    end

    score = score + (ent:BoundingRadius() / 10)

    local _, newscore = self:RunHook("HookS_GetLockOnScore", ent)

    score = newscore or score

    return score
end

function SWEP:LockOnTargetInFOV(ent)
    local dot = self:GetOwner():GetAimVector():Dot((ent:GetPos() - self:GetShootPos()):GetNormalized())

    local deg_dot = math.deg(math.acos(dot))

    if deg_dot > self:GetProcessedValue("LockOnFOV", true) then return false end

    return true
end

function SWEP:ThinkLockOn()
    if !self:GetProcessedValue("LockOn", true) then
        self:SetLockOnTarget(NULL)
        return
    end

    if IsValid(self:GetLockOnTarget()) then
        if self:GetLockOnScore(self:GetLockOnTarget(), true) == 0 then
            self:SetLockOnTarget(NULL)
        else
            if !self:GetLockedOn() and
            self:GetLockOnStartTime() + self:GetProcessedValue("LockOnTime") <= CurTime() then
                self:SetLockedOn(true)
                self:RunHook("Hook_LockOn", self:GetLockOnTarget())

                local soundtab = {
                    name = "lockedon",
                    sound = self:GetProcessedValue("LockedOnSound", true),
                }

                self:PlayTranslatedSound(soundtab)
            end
        end
    end

    local bestent = nil
    local bestscore = 0

    for _, ent in ipairs(ents.GetAll()) do
        if !IsValid(ent) or ent:IsWorld() then continue end

        local score = self:GetLockOnScore(ent)

        if score == 0 then continue end
        if !self:CanLockOn(ent) then continue end

        if score > bestscore then
            bestent = ent
            bestscore = score
        end
    end

    if !bestent then
        self:SetLockOnTarget(NULL)
        return
    end

    if bestent != self:GetLockOnTarget() then
        self:SetLockOnStartTime(CurTime())
        self:SetLockOnTarget(bestent)
        self:SetLockedOn(false)

        local soundtab = {
            name = "lockon",
            sound = self:GetProcessedValue("LockOnSound", true),
        }

        self:PlayTranslatedSound(soundtab)
    end
end

local lockonmat = Material("arc9/lockon.png", "noclamp smooth")
-- local rtsize = math.min(1024, ScrW(), ScrH())
local arc9_cheapscopes = GetConVar("arc9_cheapscopes")

function SWEP:DrawLockOnHUD(iam3d)
    if self:IsScoping() and !iam3d then return end

    if !self:GetProcessedValue("LockOn", true) then
        return
    end

    local locks = {}

    if IsValid(self:GetLockOnTarget()) then
        local toscreen = self:GetLockOnTarget():WorldSpaceCenter():ToScreen()

        table.insert(locks, {
            x = toscreen.x,
            y = toscreen.y,
            locktarget = true
        })
    end

    local bestent = nil
    local bestscore = 0
    local bestlock = {}

    for _, ent in ipairs(ents.GetAll()) do
        if !IsValid(ent) then continue end
        if ent:IsWorld() then continue end
        if ent == self:GetLockOnTarget() then continue end

        if !self:CanLockOn(ent) then continue end

        local score = self:GetLockOnScore(ent)

        local toscreen = ent:WorldSpaceCenter():ToScreen()

        local locktbl = {
            x = toscreen.x,
            y = toscreen.y,
        }

        table.insert(locks, locktbl)

        if score == 0 then
            locktbl.outoffov = true
            continue
        end

        if score > bestscore then
            bestent = ent
            bestscore = score
            bestlock = locktbl
        end
    end

    if bestent then
        bestlock.bestlock = true
    end

    cam.Start2D()

    for _, lock in ipairs(locks) do
        local x = lock.x
        local y = lock.y
        local size = 32

        if iam3d then
            if !arc9_cheapscopes:GetBool() then
                x = x / 2
                size = ScreenScale(32)
            else
                size = ScreenScale(12)
            end
        else
            size = ScreenScale(12)
        end

        if lock.locktarget then
            surface.SetDrawColor(255, 15, 15, 200)
        elseif lock.outoffov then
            surface.SetDrawColor(255, 255, 255, 50)
        else
            surface.SetDrawColor(200, 255, 50, 200)
        end

        surface.SetMaterial(lockonmat)
        surface.DrawTexturedRect(x - size / 2, y - size / 2, size, size)
    end

    cam.End2D()
end