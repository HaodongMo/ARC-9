SWEP.SetBreathDSP = false

function SWEP:ThinkHoldBreath()

    if !self:GetOwner():IsPlayer() then return end

    local sfx = GetConVar("arc9_breath_sfx"):GetBool()

    local target_ts = 1

    if self:HoldingBreath() then
        self:SetBreath(self:GetBreath() - (FrameTime() * 100 / self:GetProcessedValue("HoldBreathTime")))
        if self:GetBreath() < 0 then
            self:SetOutOfBreath(true)
            self:SetBreath(0)

            if sfx then
                local soundtab = {
                    name = "breathrunout",
                    sound = self:RandomChoice(self:GetProcessedValue("BreathRunOutSound")),
                    channel = ARC9.CHAN_BREATH
                }
                self:PlayTranslatedSound(soundtab)

                if self.SetBreathDSP then
                    self:GetOwner():SetDSP(0)
                    self.SetBreathDSP = false
                end
            end
        else
            target_ts = Lerp(1 - (self:GetBreath() / 100), 0.33, 0.25)
            if sfx and !self.SetBreathDSP then
                self:GetOwner():SetDSP(30)
                self.SetBreathDSP = true
                local soundtab = {
                    name = "breathin",
                    sound = self:RandomChoice(self:GetProcessedValue("BreathInSound")),
                    channel = ARC9.CHAN_BREATH
                }

                self:PlayTranslatedSound(soundtab)
            end
        end
    else
        if sfx and self.SetBreathDSP then
            self:GetOwner():SetDSP(0)
            self.SetBreathDSP = false
            local soundtab = {
                name = "breathout",
                sound = self:RandomChoice(self:GetProcessedValue("BreathOutSound")),
                channel = ARC9.CHAN_BREATH
            }
            self:PlayTranslatedSound(soundtab)
        end

        self:SetBreath(self:GetBreath() + (FrameTime() * 100 / self:GetProcessedValue("RestoreBreathTime")))
        if self:GetBreath() >= 100 then
            self:SetBreath(100)
            self:SetOutOfBreath(false)
        end
    end

    if game.SinglePlayer() and SERVER and GetConVar("arc9_breath_slowmo"):GetBool() then
        local ts = game.GetTimeScale()

        ts = math.Approach(ts, target_ts, FrameTime() / ts / 0.5)
        game.SetTimeScale(ts)
        Entity(1):SetLaggedMovementValue(1 + ((1-ts)*2))
    end
end

function SWEP:CanHoldBreath()
    return self:GetBreath() > 0 and !self:GetOutOfBreath()
end

function SWEP:HoldingBreath()
    return self:CanHoldBreath() and self:GetOwner():KeyDown(IN_SPEED) and (self:GetSightAmount() >= 1)
end

local pp_amount = 0

function SWEP:HoldBreathPP()
    if !GetConVar("arc9_breath_pp"):GetBool() then return end
    local amt_d = (100 - self:GetBreath()) / 100
    local holding = self:HoldingBreath()
    local out = self:GetOutOfBreath()

    local target = 0

    if holding then target = 0.5 end

    pp_amount = math.Approach(pp_amount, target, FrameTime() / 0.25)

    DrawSharpen((0.5 * pp_amount) + (1.2 * amt_d), 2 * pp_amount)

    local tint = Color(253, 255, 255)

    local tab = {
        [ "$pp_colour_addr" ] = (-1 + (tint.r / 255)) * pp_amount,
        [ "$pp_colour_addg" ] = (-1 + (tint.g / 255)) * pp_amount,
        [ "$pp_colour_addb" ] = (-1 + (tint.b / 255)) * pp_amount,
        [ "$pp_colour_brightness" ] = pp_amount * -0.05,
        [ "$pp_colour_contrast" ] = 1 + (0.2 * pp_amount),
        [ "$pp_colour_colour" ] = 1 - (amt_d * 0.25),
        [ "$pp_colour_mulr" ] = 0,
        [ "$pp_colour_mulg" ] = 0,
        [ "$pp_colour_mulb" ] = 0
    }
    DrawColorModify(tab)
end

function SWEP:HoldBreathHUD()
    if self:GetSightAmount() < 1 then return end

    if !GetConVar("arc9_breath_hud"):GetBool() then return end

    local amt = self:GetBreath() / 100

    if amt == 1 then return end

    local bar_w = ScreenScale(48)
    local bar_h = ScreenScale(4)
    local bar_y = ScreenScale(92)
    -- local ss_x = ScreenScale(1)
    -- local ss_y = ScreenScale(1)

    -- surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    -- surface.DrawOutlinedRect((ScrW() - bar_w) / 2 + ss_x, ScrH() / 2 + bar_y + ss_y, bar_w, bar_h)
    -- surface.DrawRect((ScrW() - bar_w) / 2 + ss_x, ScrH() / 2 + bar_y + ss_y, bar_w * amt, bar_h)
    local a = (1 - math.max(amt, 0.9)) * 255*10
    surface.SetDrawColor(ARC9.GetHUDColor("shadow", a*0.5))
    surface.DrawRect((ScrW() - bar_w) / 2, ScrH() - bar_y, bar_w, bar_h)
    surface.SetDrawColor(ARC9.GetHUDColor("fg", a))
    surface.DrawOutlinedRect((ScrW() - bar_w) / 2, ScrH() - bar_y, bar_w, bar_h)
    -- surface.SetDrawColor(ARC9.GetHUDColor("hi", a))
    -- surface.DrawRect((ScrW() - bar_w) / 2 + bar_w * amt, ScrH() - bar_y, bar_w * (1-amt), bar_h)
    surface.SetDrawColor(ARC9.GetHUDColor("hi", a))
    surface.DrawRect((ScrW() - bar_w) / 2, ScrH() - bar_y, bar_w * amt, bar_h)

    -- surface.SetTextColor(ARC9.GetHUDColor("fg"))
    -- surface.SetFont("ARC9_12")
    -- local text = "HOLD BREATH (" .. ARC9.GetBindKey("+speed") .. ")"
    -- local tw = surface.GetTextSize(text)
    -- surface.SetTextColor(ARC9.GetHUDColor("shadow"))
    -- surface.SetTextPos((ScrW() - tw) / 2 + ss_x, ScrH() / 2 + ScreenScale(20) + ss_y)
    -- surface.DrawText(text)

    -- surface.SetTextColor(ARC9.GetHUDColor("fg"))
    -- surface.SetTextPos((ScrW() - tw) / 2, ScrH() / 2 + ScreenScale(20))
    -- surface.DrawText(text)
end

function SWEP:GetFreeSwayAmount()
    if !GetConVar("arc9_mod_sway"):GetBool() then return 0 end
    if !self:GetOwner():IsPlayer() then return 0 end
    local sway = self:GetProcessedValue("Sway")

    sway = math.Max(sway, 0)

    if self:HoldingBreath() then return sway * 0.15 end

    if self:GetOutOfBreath() then
        sway = sway + ((1 - self:GetBreath() / 100) * 0.75)
    end

    return sway
end