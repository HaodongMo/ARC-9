function SWEP:ThinkLockOn()
    if !self:GetProcessedValue("LockOn") then
        self:SetLockOnTarget(NULL)
        return
    end

    if IsValid(self:GetLockOnTarget()) then
        local dot = self:GetOwner():GetAimVector():Dot((self:GetLockOnTarget():GetPos() - self:GetShootPos()):GetNormalized())

        local deg_dot = math.deg(math.acos(dot))

        if deg_dot > self:GetProcessedValue("LockedOnFOV") then
            self:SetLockOnTarget(NULL)
        else
            if !self:GetLockedOn() and
            self:GetLockOnStartTime() + self:GetProcessedValue("LockOnTime") <= CurTime() then
                self:SetLockedOn(true)
                self:RunHook("Hook_LockOn", self:GetLockOnTarget())

                local soundtab = {
                    name = "lockedon",
                    sound = self:GetProcessedValue("LockedOnSound"),
                }

                self:PlayTranslatedSound(soundtab)
            end
        end
    end

    local ents = ents.GetAll()

    local bestent = nil
    local bestscore = 0

    for _, ent in ipairs(ents) do
        if self:RunHook("HookC_CannotLockOn", ent) then continue end
        if !IsValid(ent) then continue end
        if ent:IsWorld() then continue end

        local canlock = false

        if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and self:GetProcessedValue("LocksLiving") then
            canlock = true
        end

        local dot = self:GetOwner():GetAimVector():Dot((ent:GetPos() - self:GetShootPos()):GetNormalized())

        local deg_dot = math.deg(math.acos(dot))

        if deg_dot > self:GetProcessedValue("LockOnFOV") then continue end

        if !canlock then
            local lockair = self:GetProcessedValue("LocksAir")
            local lockground = self:GetProcessedValue("LocksGround")

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

        if !canlock and !self:RunHook("HookC_CanLockOn", ent) then continue end

        local score = 0

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

        score = self:RunHook("HookS_GetLockOnScore", ent, score) or score

        if canlock and score > bestscore then
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

        local soundtab = {
            name = "lockon",
            sound = self:GetProcessedValue("LockOnSound"),
        }

        self:PlayTranslatedSound(soundtab)
    end
end