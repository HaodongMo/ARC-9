SWEP.Peeking = false

local lastpressed = false

function SWEP:ThinkPeek()
    if GetConVar("arc9_togglepeek"):GetBool() then
        if input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context"))) and !lastpressed then
            self.Peeking = !self.Peeking
        end
    else
        self.Peeking = input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context")))
    end

    lastpressed = input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context")))
end