SWEP.SetBreathDSP = false

local sfxconvar = GetConVar("arc9_breath_sfx")
local slomoconvar = GetConVar("arc9_breath_slowmo")
local togglconvar = GetConVar("arc9_togglebreath")
local ppconvar = GetConVar("arc9_breath_pp")
local hudconvar = GetConVar("arc9_breath_hud")
local swayconvar = GetConVar("arc9_mod_sway")

function SWEP:ThinkHoldBreath()
    if !self:GetOwner():IsPlayer() then return end
    local holdbreathtime = self:GetValue("HoldBreathTime")
    if holdbreathtime <= 0 then return end

    local sfx = sfxconvar:GetBool()

    local target_ts = 1

    if self:HoldingBreath() then
        self:SetBreath(self:GetBreath() - (FrameTime() * 100 / holdbreathtime))
        if self:GetBreath() < 0 then
            self:SetOutOfBreath(true)
            self:SetBreath(0)
            self.IsHoldingBreath = false

            if sfx then
                local soundtab = {
                    name = "breathrunout",
                    sound = self:RandomChoice(self:GetProcessedValue("BreathRunOutSound", true)),
                    channel = ARC9.CHAN_BREATH
                }
                
                self.BreathOutPlayed = true
                self.BreathInPlayed = nil
                if CLIENT then self:PlayTranslatedSound(soundtab) end

                -- if self.SetBreathDSP then
                --     self:GetOwner():SetDSP(0)
                --     self.SetBreathDSP = false
                -- end
            end
        else
            target_ts = Lerp(1 - (self:GetBreath() / 100), 0.33, 0.25)
            if sfx and !self.BreathInPlayed then
            -- if sfx and !self.SetBreathDSP then
                -- self:GetOwner():SetDSP(30)
                -- self.SetBreathDSP = true
                
                self.BreathInPlayed = true
                self.BreathOutPlayed = nil

                local soundtab = {
                    name = "breathin",
                    sound = self:RandomChoice(self:GetProcessedValue("BreathInSound", true)),
                    channel = ARC9.CHAN_BREATH
                }

                if CLIENT then self:PlayTranslatedSound(soundtab) end
            end
        end
    else
        if sfx and !self.BreathOutPlayed and !self:GetOutOfBreath() then
        -- if sfx and self.SetBreathDSP then
            -- self:GetOwner():SetDSP(0)
            -- self.SetBreathDSP = false
            local soundtab = {
                name = "breathout",
                sound = self:RandomChoice(self:GetProcessedValue("BreathOutSound", true)),
                channel = ARC9.CHAN_BREATH
            }

            self.BreathOutPlayed = true
            self.BreathInPlayed = nil

            if CLIENT then self:PlayTranslatedSound(soundtab) end
        end

        self:SetBreath(self:GetBreath() + (FrameTime() * 100 / self:GetProcessedValue("RestoreBreathTime", true)))
        if self:GetBreath() >= 100 then
            self:SetBreath(100)
            self:SetOutOfBreath(false)
        end
    end

    if game.SinglePlayer() and SERVER and slomoconvar:GetBool() then
        local ts = game.GetTimeScale()

        ts = math.Approach(ts, target_ts, FrameTime() / ts / 0.5)
        game.SetTimeScale(ts)
        Entity(1):SetLaggedMovementValue(1 + ((1-ts)*2))
    end
end

function SWEP:CanHoldBreath()
    return self:GetBreath() > 0 and !self:GetOutOfBreath()
end

local lastpressed = false
SWEP.IsHoldingBreath = false

function SWEP:HoldingBreath()
    if self:GetSightAmount() < 0.05 then self.IsHoldingBreath = false return end

    local ownerkeydownspeed = self:GetOwner():KeyDown(IN_SPEED)

    if togglconvar:GetBool() then
        if ownerkeydownspeed and !lastpressed then
            self.IsHoldingBreath = !self.IsHoldingBreath
        end
    else
        self.IsHoldingBreath = ownerkeydownspeed
    end

    lastpressed = ownerkeydownspeed
    
    return self:CanHoldBreath() and self.IsHoldingBreath and (self:GetSightAmount() >= 1) and self:GetValue("HoldBreathTime") > 0
end

local pp_amount = 0

function SWEP:HoldBreathPP()
    if self:GetValue("HoldBreathTime") <= 0 then return end
    if !ppconvar:GetBool() then return end
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
    if self:GetValue("HoldBreathTime") <= 0 then return end

    if !hudconvar:GetBool() then return end

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
    if !swayconvar:GetBool() then return 0 end
    if !self:GetOwner():IsPlayer() then return 0 end
    local sway = self:GetProcessedValue("Sway")

    sway = math.Max(sway, 0)

    if self:HoldingBreath() then return sway * 0.15 end

    if self:GetOutOfBreath() then
        sway = sway + ((1 - self:GetBreath() / 100) * 0.75)
    end

    return sway
end