function EFFECT:Init(data)
	local wpn = data:GetEntity()

	if !IsValid(wpn) then self:Remove() return end

	local smoke = wpn:GetProcessedValue("AfterShotParticle")

	local att = data:GetAttachment() or 1

	local vm = LocalPlayer():GetViewModel()

	local wm = false

	if (LocalPlayer():ShouldDrawLocalPlayer() or wpn.Owner != LocalPlayer()) then
		wm = true
		att = 1
	end

	local parent = wpn

	if !wm then
		parent = vm
	else
		parent = (wpn.WModel or {})[1] or wpn
	end

	local muz = wpn:GetMuzzleDevice(wm)

	if !IsValid(muz) then
		muz = wpn
	end

	if !IsValid(muz) then
		self:Remove()
		return
	end

	-- if !IsValid(parent) then return end

	if smoke then
		if IsValid(wpn.ActiveAfterShotPCF) then
			wpn.ActiveAfterShotPCF:StopEmission()
		end

		local pcf = CreateParticleSystem(muz or parent, smoke, PATTACH_POINT_FOLLOW, att)

		if IsValid(pcf) then
			pcf:StartEmission()
			pcf:SetShouldDraw(false)
		end

		wpn.ActiveAfterShotPCF = pcf
		table.insert(wpn.PCFs, pcf)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end