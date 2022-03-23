local tick = 0

-- Avoid using this system - it breaks prediction.
function SWEP:InitTimers()
    self.ActiveTimers = {} -- { { time, id, func } }
end

function SWEP:SetTimer(time, callback, id)
    if not IsFirstTimePredicted() and not game.SinglePlayer() then return end

    if not self.ActiveTimers then
        self:InitTimers()
    end

    table.insert(self.ActiveTimers, {time + CurTime(), id or "", callback})
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
        if v[2] ~= id then
            table.insert(keeptimers, v)
        end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:KillTimers()
    self.ActiveTimers = {}
end

function SWEP:ProcessTimers()
    local keeptimers = {}
    local UCT = CurTime()
    -- if CLIENT and UCT == tick then return end

    if not self.ActiveTimers then
        self:InitTimers()
    end

    for _, v in pairs(self.ActiveTimers) do
        if v[1] <= UCT then
            v[3]()
        end
    end

    for _, v in pairs(self.ActiveTimers) do
        if v[1] > UCT then
            table.insert(keeptimers, v)
        end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:PlaySoundTable(soundtable, mult)
    --if CLIENT and game.SinglePlayer() then return end
    local owner = self:GetOwner()
    start = start or 0
    mult = mult

    for i, v in pairs(soundtable) do
        local ttime

        if v.t then
            ttime = v.t * mult
        else
            continue
        end

        if ttime < 0 then continue end
        if not (IsValid(self) and IsValid(owner)) then continue end

        self:SetTimer(ttime, function()
            if v.s then
                self:EmitSound(self:RandomChoice(v.s or ""), v.v or 75, v.p or 100, 1, v.c or CHAN_AUTO)
            end

            if v.pp then
                self.PoseParamState[v.pp] = v.ppv or 0
            end

            if v.hide != nil then
                self:SetHideBoneIndex(v.hide)
            end

            if game.SinglePlayer() and SERVER then
                if (v.v1 or v.v2 or v.vt) then
                    net.Start("ARC9_AnimRumble")
                    net.WriteUInt(v.v1 or 0, 16)
                    net.WriteUInt(v.v2 or 0, 16)
                    net.WriteFloat(v.vt or 0.1)
                    net.Send(self:GetOwner())
                end
            elseif not game.SinglePlayer() and CLIENT then
                SInputAnimRumble(v.v1 or 0, v.v2 or 0, v.vt or 0.1)
            end
        end, "soundtable_" .. tostring(i))
    end
end

if SERVER then
    util.AddNetworkString("ARC9_AnimRumble")
end

if CLIENT then
    local cl_rumble = GetConVar("arc9_rumble")

    net.Receive("ARC9_AnimRumble", function()
        local v1 = net.ReadUInt(16)
        local v2 = net.ReadUInt(16)
        local vt = net.ReadFloat()
        SInputAnimRumble(v1 or 0, v2 or 0, vt or 0.1)
    end)

    function SInputAnimRumble(v1, v2, vt)
        if not sinput then return false end
        if not cl_rumble:GetBool() then return false end

        if not sinput.enabled then
            sinput.Init()
        end

        local P1 = sinput.GetControllerForGamepadIndex(0)
        sinput.TriggerVibration(P1, v1, v2)
        timer.Remove("SInput_ARC9_AnimRumble")

        timer.Create("SInput_ARC9_AnimRumble", vt, 1, function()
            sinput.TriggerVibration(P1, 0, 0)
        end)
    end
end

function SWEP:CancelSoundTable()
    for _, t in pairs(self.ActiveTimers) do
        if isstring(t[2]) and string.sub(t[2], 1, 10) == "soundtable" then
            self:KillTimer(t[2])
        end
    end
end