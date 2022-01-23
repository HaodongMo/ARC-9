local lasermat = Material("effects/laser1")
local flaremat = Material("effects/whiteflare")

function SWEP:DrawLaser(pos, dir, atttbl, behav)
    behav = behav or false
    local strength = atttbl.LaserStrength or 1
    local color = atttbl.LaserColor or Color(255, 0, 0)

    -- ang = self:GetShootDir()

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + (dir * 30000),
        mask = MASK_SHOT,
        filter = self:GetOwner()
    })

    if tr.StartSolid then return end

    local width = math.Rand(0.1, 0.2) * strength

    if behavior then
        cam.Start3D()
        pos = pos - (dir * 256)
    end

    if !behav then
        render.SetMaterial(lasermat)
        render.DrawBeam(pos, tr.HitPos, width * 0.3, 0, 1, Color(200, 200, 200))
        render.DrawBeam(pos, tr.HitPos, width, 0, 1, color)
    end

    if tr.Hit then
        local mul = strength
        local rad = math.Rand(4, 6) * mul

        render.SetMaterial(flaremat)
        render.DrawSprite(tr.HitPos, rad, rad, color)

        render.DrawSprite(tr.HitPos, rad * 0.3, rad * 0.3, Color(200, 200, 200))
    end

    if behavior then
        cam.End3D()
    end
end

function SWEP:DrawLasers(wm, behav)
    if !wm and !IsValid(self:GetOwner()) then return end
    if !wm and self:GetOwner():IsNPC() then return end

    local mdl = self.VModel

    if wm then
        mdl = self.WModel
    end

    if !mdl then
        self:SetupModel(wm)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
        end
    end

    for _, model in pairs(mdl) do
        local slottbl = model.slottbl
        local atttbl = self:GetFinalAttTable(slottbl)

        if atttbl.Laser then
            -- if behav then
            --     self:DrawLaser(EyePos() - (EyeAngles():Up() * 4), self:GetShootDir():Forward(), atttbl)
            -- else
                local pos, ang = self:GetAttPos(slottbl, wm, false)
                model:SetPos(pos)
                model:SetAngles(ang)

                local a = model:GetAttachment(atttbl.LaserAttachment)

                if !wm or self:GetOwner() == LocalPlayer() then
                    if behav then
                        self:DrawLaser(a.Pos, self:GetShootDir():Forward(), atttbl, behav)
                    else
                        self:DrawLaser(a.Pos, -a.Ang:Right(), atttbl, behav)
                    end
                else
                    self:DrawLaser(a.Pos, self:GetShootDir():Forward(), atttbl, behav)
                end
            -- end
        end
    end
end