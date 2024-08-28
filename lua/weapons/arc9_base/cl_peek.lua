SWEP.Peeking = false
-- SWEP.CantPeek = false

local lastpressed = false
local arc9_togglepeek_reset = GetConVar("arc9_togglepeek_reset")
local arc9_togglepeek = GetConVar("arc9_togglepeek")

local soundin = {
    name = "firemode",
    sound = "arc9/cloth_5.ogg",
    channel = ARC9.CHAN_FIDDLE,
    volume = 0.3,
}
local soundout = {
    name = "firemode",
    sound = "arc9/cloth_4.ogg",
    channel = ARC9.CHAN_FIDDLE,
    volume = 0.3,
}

function SWEP:ThinkPeek()
	if !self.dt.InSights then return end

    if arc9_togglepeek_reset:GetBool() and self:GetSightAmount() < 0.5 or self:GetBipod() or self:GetProcessedValue("CantPeek", true) then self.Peeking = false return end
    local binding = input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context") or "???"))

    if arc9_togglepeek:GetBool() then
        if binding and !lastpressed then
            self.Peeking = !self.Peeking
            
            self:PlayTranslatedSound(self.Peeking and soundout or soundin)
        end
    else
        self.Peeking = binding

        if binding != lastpressed then
            self:PlayTranslatedSound(self.Peeking and soundout or soundin)
        end
    end
    

    lastpressed = binding
end