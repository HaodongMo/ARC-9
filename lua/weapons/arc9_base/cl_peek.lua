SWEP.Peeking = false

local lastpressed = false

function SWEP:ThinkPeek()
    if GetConVar("arc9_togglepeek_reset"):GetBool() and self:GetSightAmount() < 0.5 then self.Peeking = false return end

    if GetConVar("arc9_togglepeek"):GetBool() then
        if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context") or "???")) and !lastpressed then
            self.Peeking = !self.Peeking
        end
    else
        self.Peeking = input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context") or "???"))
    end

    lastpressed = input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context") or "???"))
end