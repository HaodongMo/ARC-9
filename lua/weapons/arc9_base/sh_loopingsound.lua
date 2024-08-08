SWEP.LoopingSound = nil
SWEP.LoopingSoundIndoor = nil

function SWEP:StartLoop()
	if self:GetUBGL() then return end

    if self.LoopingSound then return end
	
	local sil = self:GetProcessedValue("Silencer", true)
    local s = self:GetProcessedValue("ShootSoundLooping", true)
	local ss = self:GetProcessedValue("ShootSoundLoopingSilenced", true)

    if !s then return end

	if sil and ss then
		self.LoopingSound = CreateSound(self, ss)
	else
		self.LoopingSound = CreateSound(self, s)
	end
    self.LoopingSound:Play()
    self.LoopingSound:SetSoundLevel(math.Clamp(self:GetProcessedValue("ShootVolume", true), 51, 149))
    self.LoopingSound:ChangePitch(self:GetProcessedValue("ShootPitch", true), 0)
    self.LoopingSound:ChangeVolume(self:GetProcessedValue("ShootVolumeActual", true))
    -- self.LoopingSound = self:StartLoopingSound(s)

    local si = self:GetProcessedValue("ShootSoundLoopingIndoor")
    local sis = self:GetProcessedValue("ShootSoundLoopingSilencedIndoor")

    if !si then return end
	
	if sil and sis then
		self.LoopingSoundIndoor = CreateSound(self, sis)
	else
		self.LoopingSoundIndoor = CreateSound(self, si)
	end
	self.LoopingSoundIndoor:Play()
	self.LoopingSoundIndoor:SetSoundLevel(math.Clamp(self:GetProcessedValue("ShootVolume", true), 51, 149))
	self.LoopingSoundIndoor:ChangePitch(self:GetProcessedValue("ShootPitch", true), 0)
	self.LoopingSoundIndoor:ChangeVolume(0)
	
end

function SWEP:EndLoop()
    if !self.LoopingSound then return end
	
	local sil = self:GetProcessedValue("Silencer", true)

    self.LoopingSound:Stop()
    -- self:StopLoopingSound(self.LoopingSound)
    self.LoopingSound = nil
	
	if sil then
		if self.LoopingSoundIndoor then
			self.LoopingSoundIndoor:Stop()
			self.LoopingSoundIndoor = nil

			if self:GetIndoor() then
				local soundtab1 = {
					name = "shootlooptailindoorsilenced",
					sound = self:GetProcessedValue("ShootSoundTailIndoorSilenced", true) or self:GetProcessedValue("ShootSoundWindDownSilencedIndoor", true) or "",
				}
				self:PlayTranslatedSound(soundtab1)
			else
				local soundtab1 = {
					name = "shootlooptailsilenced",
					sound = self:GetProcessedValue("ShootSoundTailSilenced", true) or self:GetProcessedValue("ShootSoundWindDownSilenced", true) or "",
				}
				self:PlayTranslatedSound(soundtab1)
			end
		else
			local soundtab1 = {
				name = "shootlooptailsilenced",
				sound = self:GetProcessedValue("ShootSoundTailSilenced", true) or self:GetProcessedValue("ShootSoundWindDownSilenced", true) or "",
			}
			self:PlayTranslatedSound(soundtab1)
		end
	else
		if self.LoopingSoundIndoor then
			self.LoopingSoundIndoor:Stop()
			self.LoopingSoundIndoor = nil

			if self:GetIndoor() then
				local soundtab1 = {
					name = "shootlooptailindoor",
					sound = self:GetProcessedValue("ShootSoundTailIndoor", true) or self:GetProcessedValue("ShootSoundWindDownIndoor", true) or "",
				}
				self:PlayTranslatedSound(soundtab1)
			else
				local soundtab1 = {
					name = "shootlooptail",
					sound = self:GetProcessedValue("ShootSoundTail", true) or self:GetProcessedValue("ShootSoundWindDown", true) or "",
				}
				self:PlayTranslatedSound(soundtab1)
			end
		else
			local soundtab1 = {
				name = "shootlooptail",
				sound = self:GetProcessedValue("ShootSoundTail", true) or self:GetProcessedValue("ShootSoundWindDown", true) or "",
			}
			self:PlayTranslatedSound(soundtab1)
		end
	end
end

function SWEP:ThinkLoopingSound()
    if self.LoopingSound then
        if self:GetNextPrimaryFire() + (60 / self:GetProcessedValue("RPM")) <= CurTime() then
            self:EndLoop()
        else
            self.LoopingSound:Play()

            if self.LoopingSoundIndoor then
                self.LoopingSoundIndoor:Play()

                if self:GetIndoor() then
                    self.LoopingSoundIndoor:ChangeVolume(1, 0.1)
                    self.LoopingSound:ChangeVolume(0, 0.1)
                else
                    self.LoopingSoundIndoor:ChangeVolume(0, 0.1)
                    self.LoopingSound:ChangeVolume(1, 0.1)
                end
            end
        end
    end
end

SWEP.IndoorTick = 0
SWEP.IsIndoors = 0

local traces = {
    -- Up
    {
        Distance = Vector(0, 0, 1024),
        Influence = 1,
    },
    {
        Distance = Vector(512, 0, 768),
        Influence = 1,
    },
    {
        Distance = Vector(-512, 0, 768),
        Influence = 1,
    },
    {
        Distance = Vector(0, 512, 768),
        Influence = 1,
    },
    {
        Distance = Vector(0, -512, 768),
        Influence = 1,
    },
    -- Forward
    {
        Distance = Vector(0, 768, 128),
        Influence = 0.5,
    },
    -- Left/Right
    {
        Distance = Vector(768, 768, 256),
        Influence = 0.5,
    },
    {
        Distance = Vector(-768, 768, 256),
        Influence = 0.5,
    },
}


local traceResultTable = {}

local traceTable = {
    start = 0,
    endpos = 0,
    mask = 16513,
    output = traceResultTable
}

function SWEP:GetIndoor()
    if !self.ShootSoundIndoor and !self.DistantShootSoundIndoor and !self.ShootSoundSilencedIndoor and !self.DistantShootSoundSilencedIndoor then return 0 end -- non realism guns!!!

    if self.IndoorTick == UnPredictedCurTime() then return self.IsIndoors end
    self.IndoorTick = UnPredictedCurTime()

    local vol = 0
    local wo = self:GetOwner()
    if !IsValid(wo) then return end
    local wop = wo:EyePos()
    local woa = Angle(0, wo:EyeAngles().y, 0)
    local t_influ = 0

    for _, tin in ipairs(traces) do
        traceTable.start = wop
        offset = Vector()
        offset = offset + (tin.Distance.x * woa:Right())
        offset = offset + (tin.Distance.y * woa:Forward())
        offset = offset + (tin.Distance.z * woa:Up())
        traceTable.endpos = wop + offset
        traceTable.filter = wo
        t_influ = t_influ + (tin.Influence or 1)
        local result = util.TraceLine(traceTable)
        if ARC9.Dev(2) then
            debugoverlay.Line(wop - (vector_up * 4), result.HitPos - (vector_up * 4), 5, Color((_ / 4) * 255, 0, (1 - (_ / 4)) * 255))
            debugoverlay.Text(result.HitPos - (vector_up * 4), math.Round((result.HitSky and 1 or result.Fraction) * 100) .. "%", 5)
        end
        vol = vol + (result.HitSky and 1 or result.Fraction) ^ 1.5 * tin.Influence
    end

    self.IsIndoors = 1 - vol / t_influ
    if ARC9.Dev(2) then
        print(self.IsIndoors)
    end

    return self.IsIndoors
end