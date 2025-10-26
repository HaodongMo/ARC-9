local startPressFTime = 0

local lastRadialMenuState = false
ARC9.RadialMenuOpen = false

function SWEP:ThinkRadialMenu()

    ARC9.RadialMenuOpen = false

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

    if ARC9.RadialMenuOpen and !lastRadialMenuState then
        self.MouseAngle = 0
        self.LastSelectedAttSlot = nil
        gui.EnableScreenClicker(true)
    elseif !ARC9.RadialMenuOpen and lastRadialMenuState then
        gui.EnableScreenClicker(false)
    elseif ARC9.RadialMenuOpen then
        local mx, my = gui.MousePos()
        local centerX = ScrW() / 2
        local centerY = ScrH() / 2

        local dx = mx - centerX
        local dy = my - centerY

        local angle = math.deg(math.atan2(dy, dx)) + 90
        if angle < 0 then
            angle = angle + 360
        end

        self.MouseAngle = angle
    end

    lastRadialMenuState = ARC9.RadialMenuOpen
end

SWEP.ListOfToggleableAttSlots = nil
SWEP.MouseAngle = 0
SWEP.LastSelectedAttSlot = nil

function SWEP:GetListOfToggleableAttSlots()
    if self.ListOfToggleableAttSlots then
        return self.ListOfToggleableAttSlots
    end

    local toggleableAtts = {}

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if !slottbl.Installed then continue end

        local atttbl = self:GetFinalAttTable(slottbl)

        if !atttbl.ToggleStats then continue end
        if !atttbl.ToggleOnF then continue end

        table.insert(toggleableAtts, {
            Slot = slottbl,
            AttTable = atttbl
        })
    end

    self.ListOfToggleableAttSlots = toggleableAtts

    return toggleableAtts
end

local ARC9ScreenScale = ARC9.ScreenScale

local a = 0

local hud_bg = Material("arc9/hud_bg_radial.png", "mips smooth")
local placeholder_att = Material("arc9/ui/settings.png", "mips smooth")

function SWEP:DrawRadialMenu()
    if a <= 0 and !ARC9.RadialMenuOpen then return end

    if ARC9.RadialMenuOpen then
        a = math.Approach(a, 1, FrameTime() / 0.2)
    else
        a = math.Approach(a, 0, FrameTime() / 0.5)
    end

    // Draw the radial background in the center
    surface.SetDrawColor(ARC9.GetHUDColor("bg", 175 * a))
    surface.SetMaterial(hud_bg)
    local size = ARC9ScreenScale(220)
    surface.DrawTexturedRect((ScrW() - size) / 2, (ScrH() - size) / 2, size, size)

    local toggleableAttSlots = self:GetListOfToggleableAttSlots()

    local centerX = ScrW() / 2
    local centerY = ScrH() / 2
    local radius = ARC9ScreenScale(75)

    local attCount = #toggleableAttSlots
    local angle = 0
    local angleStep = 360 / attCount
    local selectedAtt = nil

    for i, attslot in ipairs(toggleableAttSlots) do
        local atttbl = attslot.AttTable
        local slottbl = attslot.Slot
        local attIcon = atttbl.Icon or placeholder_att
        local mat = attIcon

        local isSelected = false

        if self.MouseAngle != nil and selectedAtt == nil then
            local startAngle = angle - angleStep / 2
            local endAngle = angle + angleStep / 2

            if startAngle < 0 then
                startAngle = startAngle + 360
            end
            if endAngle >= 360 then
                endAngle = endAngle - 360
            end

            if startAngle > endAngle then
                if (self.MouseAngle >= startAngle and self.MouseAngle < 360) or (self.MouseAngle >= 0 and self.MouseAngle <= endAngle) then
                    isSelected = true
                end
            else
                if self.MouseAngle >= startAngle and self.MouseAngle <= endAngle then
                    isSelected = true
                end
            end

            if isSelected then
                selectedAtt = atttbl
                self.LastSelectedAttSlot = attslot
            end
        end

        local attX = centerX + radius * math.cos(math.rad(angle - 90))
        local attY = centerY + radius * math.sin(math.rad(angle - 90))

        local iconSize = ARC9ScreenScale(32)
        if isSelected then
            iconSize = ARC9ScreenScale(40)
        end
        surface.SetDrawColor(255, 255, 255, 255 * a)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(attX - iconSize / 2, attY - iconSize / 2, iconSize, iconSize)

        local textX = attX
        local textY = attY - ARC9ScreenScale(24)
        local textTop = ARC9:GetPhraseForAtt(atttbl.ShortName , "CompactName") or atttbl.CompactName or ARC9:GetPhraseForAtt(atttbl.ShortName , "PrintName") or atttbl.PrintName or atttbl.ShortName

        if isSelected then
            surface.SetTextColor(ARC9.GetHUDColor("hi", 255 * a))
            surface.SetFont("ARC9_10")
        else
            surface.SetTextColor(ARC9.GetHUDColor("fg", 255 * a))
            surface.SetFont("ARC9_8")
        end

        local textWidth, textHeight = surface.GetTextSize(textTop)

        surface.SetTextPos(textX - textWidth / 2, textY - textHeight / 2)
        surface.DrawText(textTop)

        local textBottom = atttbl.ToggleStats[slottbl.ToggleNum] and ARC9:GetPhrase(atttbl.ToggleStats[slottbl.ToggleNum].PrintName) or atttbl.ToggleStats[slottbl.ToggleNum].PrintName or "Toggle"

        local bottomY = attY + ARC9ScreenScale(20)
        local bottomWidth, bottomHeight = surface.GetTextSize(textBottom)
        surface.SetTextPos(textX - bottomWidth / 2, bottomY - bottomHeight / 2)
        surface.DrawText(textBottom)

        if atttbl.ToggleStats[slottbl.ToggleNum].ToggleIcon then
            local toggleIcon = atttbl.ToggleStats[slottbl.ToggleNum].ToggleIcon
            local toggleMat = toggleIcon

            local iconX = attX
            local iconY = attY + ARC9ScreenScale(40)
            local toggleSize = ARC9ScreenScale(16)

            surface.SetDrawColor(255, 255, 255, 255 * a)
            surface.SetMaterial(toggleMat)
            surface.DrawTexturedRect(iconX - toggleSize / 2, iconY - toggleSize / 2, toggleSize, toggleSize)
        end

        angle = angle + angleStep
    end
end