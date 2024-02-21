local defaulttracemat = Material("arc9/laser2")
local defaultflaremat = Material("sprites/light_glow02_add", "mips smooth")
local lasercolorred = Color(255, 0, 0)
local lasercolor200 = Color(200, 200, 200)

function SWEP:DrawLaser(pos, dir, atttbl, behav)
    behav = behav or false
    local strength = atttbl.LaserStrength or 1
    local flaremat = atttbl.LaserFlareMat or defaultflaremat
    local lasermat = atttbl.LaserTraceMat or defaulttracemat
    local owner = self:GetOwner()

    local dist = 5000

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (dir * 15000),
        mask = MASK_SHOT,
        filter = owner
    })

    if tr.StartSolid then return end

    local width = math.Rand(0.1, 0.5) * strength

    local hit = tr.Hit
    local hitpos = tr.HitPos

    if tr.HitSky then
        hit = false
        hitpos = pos + (dir * dist)
    end

    local truedist = math.min((tr.Fraction or 1) * 15000, dist)
    local fraction = truedist / dist

    local laspos = pos + (dir * truedist)

    if self.LaserAlwaysOnTargetInPeek and owner == LocalPlayer() then
        local sightamount = self:GetSightAmount()
        if sightamount > 0 and self.Peeking then

            local fuckingreloadprocess
            local fuckingreloadprocessinfluence = 1

            if self:GetReloading() then
                if !self:GetProcessedValue("ShotgunReload", true) then
                    fuckingreloadprocess = math.Clamp((self:GetReloadFinishTime() - CurTime()) / (self.ReloadTime * self:GetAnimationTime(self:GetIKAnimation())), 0, 1)

                    if fuckingreloadprocess <= 0.2 then
                        fuckingreloadprocessinfluence = 1 - (fuckingreloadprocess * 5)
                    elseif fuckingreloadprocess >= 0.9 then
                        fuckingreloadprocessinfluence = (fuckingreloadprocess - 0.9) * 10
                    else
                        fuckingreloadprocessinfluence = 0
                    end
                end
            end

            local trrr = util.TraceLine({
                start = self:GetShootPos(),
                endpos = self:GetShootPos() + (self:GetShootDir():Forward() * 15000),
                mask = MASK_SHOT,
                filter = owner
            })

            local realhitpos = trrr.HitPos
            laspos = LerpVector(sightamount*fuckingreloadprocessinfluence, laspos, realhitpos)
            hitpos = LerpVector(sightamount*fuckingreloadprocessinfluence, hitpos, realhitpos)
        end
    end

    local color = atttbl.LaserColor or lasercolorred
	local colorplayer = owner:GetWeaponColor():ToColor()

	if (atttbl.LaserColorPlayer or atttbl.LaserPlayerColor) then color = colorplayer end

    if !behav then
        render.SetMaterial(lasermat)
        render.DrawBeam(pos, laspos, width * 0.2, 0, fraction, lasercolor200)
        render.DrawBeam(pos, laspos, width, 0, fraction, color)
    end

    if hit then
        local rad = math.Rand(4, 6) * strength * math.max(fraction * 7, 1)
        local dotcolor = color
        local whitedotcolor = lasercolor200

        dotcolor.a = 255 - math.min(fraction * 30, 250)
        whitedotcolor.a = 255 - math.min(fraction * 25, 250)

        render.SetMaterial(flaremat)

        render.DrawSprite(hitpos, rad, rad, dotcolor)
        render.DrawSprite(hitpos, rad * 0.4, rad * 0.3, whitedotcolor)
    end
end

function SWEP:DrawLasers(wm, behav)
    local owner = self:GetOwner()
    if !wm and !IsValid(owner) then return end
    if !wm and owner:IsNPC() then return end

    local mdl = self.VModel

    if wm then
        mdl = self.WModel
    end

    if !mdl then
        self:KillModel()
        self:SetupModel(wm)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
        end
    end

    for _, model in ipairs(mdl) do
        local slottbl = model.slottbl
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.Laser then
            local pos, ang = self:GetAttachmentPos(slottbl, wm, false)
            model:SetPos(pos)
            model:SetAngles(ang)

            local a

            if atttbl.LaserAttachment then
                a = model:GetAttachment(atttbl.LaserAttachment)
            else
                a = {
                    Pos = model:GetPos(),
                    Ang = model:GetAngles()
                }

                a.Ang:RotateAroundAxis(a.Ang:Up(), -90)
            end

            if !a then return end

            local lasercorrectionangle = model.LaserCorrectionAngle
            local lasang = a.Ang

            if lasercorrectionangle then
                local up, right, forward = lasang:Up(), lasang:Right(), lasang:Forward()

                lasang:RotateAroundAxis(up, lasercorrectionangle.p)
                lasang:RotateAroundAxis(right, lasercorrectionangle.y)
                lasang:RotateAroundAxis(forward, lasercorrectionangle.r)
            end

			local color = atttbl.LaserColor or lasercolorred
			local colorplayer = owner:GetWeaponColor():ToColor()

			if (atttbl.LaserColorPlayer or atttbl.LaserPlayerColor) then color = colorplayer end
			
            self:DrawLightFlare(a.Pos, lasang, color, wm and 5 or 10, (slottbl.Address or 0) + 69, !wm)

            if !wm or owner == LocalPlayer() or wm and owner:IsNPC() then
                if behav then
                    self:DrawLaser(a.Pos, self:GetShootDir():Forward(), atttbl, behav)
                else
                    self:DrawLaser(a.Pos, -lasang:Right(), atttbl, behav)
                end
            else
                self:DrawLaser(a.Pos, self:GetShootDir():Forward(), atttbl, behav)
            end
        end
    end
end