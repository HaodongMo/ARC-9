SWEP.Peeking = false
-- SWEP.CantPeek = false

local lastpressed = false
local arc9_togglepeek_reset = GetConVar("arc9_togglepeek_reset")
local arc9_togglepeek = GetConVar("arc9_togglepeek")

function SWEP:ThinkPeek()
	if !self.dt.InSights then return end

    if arc9_togglepeek_reset:GetBool() and self:GetSightAmount() < 0.5 or self:GetBipod() or self:GetProcessedValue("CantPeek", true) then self.Peeking = false return end
    local binding = input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context") or "???"))

    if arc9_togglepeek:GetBool() then
        if binding and !lastpressed then
            self.Peeking = !self.Peeking
        end
    else
        self.Peeking = binding
    end

    lastpressed = binding
end