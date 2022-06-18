SWEP.Flashlights = {} -- tracks projectedlights
-- {{att = int, light = ProjectedTexture}}

function SWEP:GetHasFlashlights()
    for i, k in ipairs(self:GetAttachmentList()) do
        local atttbl = ARC9.GetAttTable(k)

        if atttbl.Flashlight then return true end
    end

    return false
end

function SWEP:CreateFlashlightsVM()
    self:KillFlashlights()
    self.Flashlights = {}

    local total_lights = 0

    for _, k in ipairs(self:GetSubSlotList()) do
        if !k.Installed then continue end
        local atttbl = self:GetFinalAttTable(k)

        if atttbl.Flashlight then
            local newlight = {
                slottbl = k,
                light = ProjectedTexture(),
                col = color_white,
                br = 3,
            }
            total_lights = total_lights + 1

            local l = newlight.light
            if !IsValid(l) then continue end

            table.insert(self.Flashlights, newlight)

            l:SetFOV(atttbl.FlashlightFOV or 50)


            l:SetFarZ(atttbl.FlashlightDistance or 1024)
            l:SetNearZ(4)

            l:SetQuadraticAttenuation(100)

            l:SetColor(atttbl.FlashlightColor or color_white)
            l:SetTexture(atttbl.FlashlightMaterial or "effects/flashlight001")
            l:SetBrightness(atttbl.FlashlightBrightness or 3)
            l:SetEnableShadows(true)
            l:Update()

            local g_light = {
                Weapon = self,
                ProjectedTexture = l
            }

            table.insert(ARC9.FlashlightPile, g_light)
        end
    end

    if total_lights > 2 then -- you are a madman
        for i, k in ipairs(self.Flashlights) do
            if k.light:IsValid() then k.light:SetEnableShadows(false) end
        end
    end
end

function SWEP:KillFlashlights()
    self:KillFlashlightsVM()
    -- self:KillFlashlightsWM()
end

function SWEP:KillFlashlightsVM()
    if !self.Flashlights then return end

    for i, k in ipairs(self.Flashlights) do
        if k.light and k.light:IsValid() then
            k.light:Remove()
        end
    end

    self.Flashlights = nil
end

function SWEP:DrawFlashlightsVM()
    if !self.Flashlights then
        self:CreateFlashlightsVM()
    end

    for i, k in ipairs(self.Flashlights) do
        local model = (k.slottbl or {}).VModel

        if !model then continue end

        local pos, ang

        if !model then
            pos = self:GetOwner():EyePos()
            ang = self:GetOwner():EyeAngles()
        else
            pos = model:GetPos()
            ang = model:GetAngles()
        end

        local tr = util.TraceLine({
            start = self:GetOwner():EyePos(),
            endpos = self:GetOwner():EyePos() - -ang:Forward() * 128,
            mask = MASK_OPAQUE,
            filter = LocalPlayer(),
        })
        if tr.Fraction < 1 then -- We need to push the flashlight back
            local tr2 = util.TraceLine({
                start = self:GetOwner():EyePos(),
                endpos = self:GetOwner():EyePos() + -ang:Forward() * 128,
                mask = MASK_OPAQUE,
                filter = LocalPlayer(),
            })
            -- push it as back as the area behind us allows
            pos = pos + -ang:Forward() * 128 * math.min(1 - tr.Fraction, tr2.Fraction)
        end

        -- ang:RotateAroundAxis(ang:Up(), 90)

        k.light:SetPos(pos)
        k.light:SetAngles(ang)
        k.light:Update()

        -- local col = k.col

        -- local dl = DynamicLight(self:EntIndex())

        -- if dl then
        --     dl.pos = pos
        --     dl.r = col.r
        --     dl.g = col.g
        --     dl.b = col.b
        --     dl.brightness = k.br or 2
        --     -- print(z / maxz)
        --     dl.Decay = 1000 / 0.1
        --     dl.dietime = CurTime() + 0.1
        --     dl.size = (k.br or 2) * 64
        -- end
    end
end