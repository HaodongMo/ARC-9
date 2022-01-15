function SWEP:ThinkRecoil()
    if (self:GetLastRecoilTime() + self:GetProcessedValue("RecoilResetTime")) < CurTime() then
        local rec = self:GetRecoilAmount()

        rec = rec - (FrameTime() * self:GetProcessedValue("RecoilDissipationRate"))

        self:SetRecoilAmount(math.max(rec, 0))
    end

    self:SetRecoilUp(self:GetRecoilUp() - (FrameTime() * self:GetRecoilUp() * self:GetProcessedValue("RecoilDissipationRate")))

    self:SetRecoilSide(self:GetRecoilSide() - (FrameTime() * self:GetRecoilSide() * self:GetProcessedValue("RecoilDissipationRate")))
end

function SWEP:ApplyRecoil()
    local rec = self:GetRecoilAmount()

    local rps = 1

    rec = rec + rps

    local delay = 60 / self:GetProcessedValue("RPM")

    local recoilup = 1
    local recoilside = 0

    local seed = self:GetProcessedValue("RecoilSeed") or self:GetClass()
    local shot = math.floor(self:GetRecoilAmount())

    if isstring(seed) then
        local numseed = 0

        for _, i in ipairs(string.ToTable(seed)) do
            numseed = numseed + string.byte(i)
        end

        numseed = numseed % 16777216

        seed = numseed
    end

    seed = seed + shot

    if self:GetProcessedValue("RecoilLookupTable") then
        local recoilpattern = self:PatternWithRunOff(self:GetProcessedValue("RecoilLookupTable"), self:GetProcessedValue("RecoilLookupTableOverrun") or self:GetProcessedValue("RecoilLookupTable"), shot)
        recoilup = recoilpattern.y or 1
        recoilside = recoilpattern.x or 0
    else
        math.randomseed(seed)
        recoilup = math.random(-1.5, 0.5)
        recoilside = math.random(-1.25, 0.75)

        local randomrecoilup = util.SharedRandom("arc9_recoil_up_r", -1, 1)
        local randomrecoilside = util.SharedRandom("arc9_recoil_side_r", -1, 1)

        recoilup = recoilup * self:GetProcessedValue("RecoilUp")
        recoilside = recoilside * self:GetProcessedValue("RecoilSide")

        randomrecoilup = randomrecoilup * self:GetProcessedValue("RecoilRandomUp")
        randomrecoilside = randomrecoilside * self:GetProcessedValue("RecoilRandomSide")

        recoilup = recoilup + randomrecoilup
        recoilside = recoilside + randomrecoilside

        recoilup = recoilup * self:GetProcessedValue("Recoil")
        recoilside = recoilside * self:GetProcessedValue("Recoil")
    end

    self:SetRecoilUp(recoilup)
    self:SetRecoilSide(recoilside)

    -- self:SetRecoilDirection(-90)
    self:SetRecoilAmount(rec)

    self:SetLastRecoilTime(CurTime() + (delay * 2))

    -- local vis_kick = self:GetProcessedValue("RecoilKick")
    -- local vis_shake = 0

    -- vis_kick = vis_kick * rps
    -- vis_shake = vis_kick * rps

    -- local vis_kick_v = vis_kick * 0.5
    -- local vis_kick_h = vis_kick * util.SharedRandom("ARC9_vis_kick_h", -1, 1)
    -- vis_shake = vis_shake * util.SharedRandom("ARC9_vis_kick_shake", -1, 1)

    -- self:GetOwner():SetViewPunchAngles(Angle(vis_kick_v, vis_kick_h, vis_shake))

    -- self:GetOwner():SetFOV(self:GetOwner():GetFOV() * 0.99, 0)
    -- self:GetOwner():SetFOV(0, 60 / (self:GetProcessedValue("RPM")))
end