local startPressFTime = 0

ARC9.RadialMenuOpen = false

function SWEP:ThinkRadialMenu()

    ARC9.RadialMenuOpen = false

    self:DrawRadialMenu()

    if self:CanToggleAllStatsOnF() > 1 then
        local impulse100key = input.LookupBinding("impulse 100", true)

        if !impulse100key then return end

        local impulse100keybutton = input.GetKeyCode(impulse100key)

        if input.WasKeyPressed(impulse100keybutton) then
            startPressFTime = CurTime()
        elseif input.IsKeyDown(impulse100keybutton) then
            if CurTime() - startPressFTime >= 0.5 then
                ARC9.RadialMenuOpen = true
            end
        elseif input.WasKeyReleased(impulse100keybutton) then
            if CurTime() - startPressFTime < 0.5 then
                ARC9.DeferToggleAtts = true
            end
        end
    end
end

function SWEP:GetListOfToggleableAtts()
    local toggleableAtts = {}

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = self:GetFinalAttTable(slottbl)

        if !atttbl.ToggleStats then continue end
        if !atttbl.ToggleOnF then continue end

        table.insert(toggleableAtts, atttbl)
    end

    return toggleableAtts
end

local a = 0

function SWEP:DrawRadialMenu()
    if a <= 0 and !ARC9.RadialMenuOpen then return end

    if ARC9.RadialMenuOpen then
        a = math.Approach(a, 1, FrameTime() / 0.2)
    else
        a = math.Approach(a, 0, FrameTime() / 0.5)
    end
end