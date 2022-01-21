local tick = 0

// Avoid using this system - it breaks prediction.

function SWEP:InitTimers()
    self.ActiveTimers = {} -- { { time, id, func } }
end

function SWEP:SetTimer(time, callback, id)
    if !IsFirstTimePredicted() and !game.SinglePlayer() then return end

    table.insert(self.ActiveTimers, { time + CurTime(), id or "", callback })
end

function SWEP:TimerExists(id)
    for _, v in pairs(self.ActiveTimers) do
        if v[2] == id then return true end
    end

    return false
end

function SWEP:KillTimer(id)
    local keeptimers = {}

    for _, v in pairs(self.ActiveTimers) do
        if v[2] != id then table.insert(keeptimers, v) end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:KillTimers()
    self.ActiveTimers = {}
end

function SWEP:ProcessTimers()
    local keeptimers = {}
    local UCT = CurTime()

    if CLIENT and UCT == tick then return end

    if !self.ActiveTimers then self:InitTimers() end

    for _, v in pairs(self.ActiveTimers) do
        if v[1] <= UCT then v[3]() end
    end

    for _, v in pairs(self.ActiveTimers) do
        if v[1] > UCT then table.insert(keeptimers, v) end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:PlaySoundTable(soundtable, mult)
    --if CLIENT and game.SinglePlayer() then return end

    local owner = self:GetOwner()

    start = start or 0
    mult = mult

    for _, v in pairs(soundtable) do
        local ttime
        if v.t then
            ttime = v.t * mult
        else
            continue
        end
        if ttime < 0 then continue end
        if !(IsValid(self) and IsValid(owner)) then continue end

        self:SetTimer(ttime, function()
            self:EmitSound(self:RandomChoice(v.s or ""), v.v or 75, v.p or 100, 1, v.c or CHAN_AUTO)
        end)
    end
end