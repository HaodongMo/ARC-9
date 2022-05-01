SWEP.SetBreathDSP = true

function SWEP:ThinkHoldBreath()
    if !self:GetOwner():IsPlayer() then return end

    local target_ts = 1

    if self:HoldingBreath() then
        self:SetBreath(self:GetBreath() - (FrameTime() * 100 / self:GetProcessedValue("HoldBreathTime")))
        if self:GetBreath() < 0 then
            self:SetOutOfBreath(true)
            self:SetBreath(0)

            self:EmitSound(self:RandomChoice(self:GetProcessedValue("BreathRunOutSound")))

            if self.SetBreathDSP then
                self:GetOwner():SetDSP(0)
                self.SetBreathDSP = false
            end
        else
            target_ts = Lerp(1 - (self:GetBreath() / 100), 0.33, 0.25)
            if !self.SetBreathDSP then
                self:GetOwner():SetDSP(30)
                self.SetBreathDSP = true
                self:EmitSound(self:RandomChoice(self:GetProcessedValue("BreathInSound")))
            end
        end
    else
        if self.SetBreathDSP then
            self:GetOwner():SetDSP(0)
            self.SetBreathDSP = false
            self:EmitSound(self:RandomChoice(self:GetProcessedValue("BreathOutSound")))
        end

        self:SetBreath(self:GetBreath() + (FrameTime() * 100 / self:GetProcessedValue("RestoreBreathTime")))
        if self:GetBreath() >= 100 then
            self:SetBreath(100)
            self:SetOutOfBreath(false)
        end
    end

    if game.SinglePlayer() and SERVER then
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
    local amt_d = (100 - self:GetBreath()) / 100
    local holding = self:HoldingBreath()
    local out = self:GetOutOfBreath()

    local target = 0

    if holding then target = 1 end

    pp_amount = math.Approach(pp_amount, target, FrameTime() / 0.25)

    DrawSharpen((0.25 * pp_amount) + (1.2 * amt_d), 1.2 * pp_amount)

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
    -- if self:GetSightAmount() < 1 then return end

    -- local amt = self:GetBreath() / 100

    -- local bar_w = ScreenScale(64)
    -- local bar_h = ScreenScale(2)
    -- local bar_y = ScreenScale(16)
    -- local ss_x = ScreenScale(1)
    -- local ss_y = ScreenScale(1)

    -- surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    -- surface.DrawOutlinedRect((ScrW() - bar_w) / 2 + ss_x, ScrH() / 2 + bar_y + ss_y, bar_w, bar_h)
    -- surface.DrawRect((ScrW() - bar_w) / 2 + ss_x, ScrH() / 2 + bar_y + ss_y, bar_w * amt, bar_h)

    -- surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    -- surface.DrawOutlinedRect((ScrW() - bar_w) / 2, ScrH() / 2 + bar_y, bar_w, bar_h)
    -- surface.DrawRect((ScrW() - bar_w) / 2, ScrH() / 2 + bar_y, bar_w * amt, bar_h)

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

    if self:HoldingBreath() then return 0 end

    if self:GetOutOfBreath() then
        sway = sway + ((1 - self:GetBreath() / 100) * 0.75)
    end

    return sway
end