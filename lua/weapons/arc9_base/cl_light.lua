SWEP.Flashlights = {} -- tracks projectedlights
-- {{att = int, light = ProjectedTexture}}

function SWEP:GetHasFlashlights()
    for i, k in ipairs(self:GetAttachmentList()) do
        local atttbl = self:GetFinalAttTable(k)

        if atttbl.Flashlight then return true end
    end

    return false
end

function SWEP:CreateFlashlights()
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
                col = atttbl.FlashlightColor or color_white,
                br = atttbl.FlashlightBrightness or 3,
                qca = atttbl.FlashlightAttachment,
                nodotter = atttbl.Flashlight360
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

    if total_lights > 1 then -- you are a madman
        for i, k in ipairs(self.Flashlights) do
            if k.light:IsValid() then k.light:SetEnableShadows(false) end
        end
    end
end

function SWEP:KillFlashlights()
    if !self.Flashlights then return end

    for i, k in ipairs(self.Flashlights) do
        if k.light and k.light:IsValid() then
            k.light:Remove()
        end
    end

    self.Flashlights = nil
end

local arc9_allflash = GetConVar("arc9_allflash")
local fuckingbullshit = Vector(0, 0, 0.001)

function SWEP:DrawFlashlightsWM()
    local owner = self:GetOwner()
    local lp = LocalPlayer()

    if (!arc9_allflash:GetBool()) and owner != lp then return end

    if !self.Flashlights then
        self:CreateFlashlights()
    end
    
    for i, k in ipairs(self.Flashlights) do
        local model = (k.slottbl or {}).WModel

        if !IsValid(model) then continue end

        local pos, ang


        if !model then
            pos = owner:EyePos()
            ang = owner:EyeAngles()
        else
            pos = model:GetPos()
            ang = model:GetAngles()
        end


        if k.qca then
            local a = model:GetAttachment(k.qca)
            if a then pos, ang = a.Pos, a.Ang end
        end
        
        self:DrawLightFlare(pos + fuckingbullshit, ang, k.col, k.br * 20, i, nil, k.nodotter)

        if k.qca then ang:RotateAroundAxis(ang:Up(), 90) end

        -- ang:RotateAroundAxis(ang:Up(), 90)

        local tr = util.TraceLine({
            start = pos,
            endpos = pos + ang:Forward() * 16,
            mask = MASK_OPAQUE,
            filter = lp,
        })
        if tr.Fraction < 1 then -- We need to push the flashlight back
            local tr2 = util.TraceLine({
                start = pos,
                endpos = pos - ang:Forward() * 16,
                mask = MASK_OPAQUE,
                filter = lp,
            })
            -- push it as back as the area behind us allows
            pos = pos + -ang:Forward() * 16 * math.min(1 - tr.Fraction, tr2.Fraction)
        else
            pos = tr.HitPos
        end

        k.light:SetPos(pos)
        k.light:SetAngles(ang)
        k.light:Update()
    end
end

function SWEP:DrawFlashlightsVM()
    if !self.Flashlights then
        self:CreateFlashlights()
    end

    local owner = self:GetOwner()
    local lp = LocalPlayer()
    local eyepos = owner:EyePos()

    for i, k in ipairs(self.Flashlights) do
        local model = (k.slottbl or {}).VModel

        if !model then continue end

        local pos, ang

        if !model then
            pos = eyepos
            ang = owner:EyeAngles()
        else
            pos = model:GetPos()
            ang = model:GetAngles()
        end

        if k.qca then
            a = model:GetAttachment(k.qca)

            if a then
                pos, ang = a.Pos, a.Ang
            else
                ang:RotateAroundAxis(ang:Up(), -90)
            end
        end

        self:DrawLightFlare(pos, ang, k.col, k.br * 25, i, true, k.nodotter)

        if k.qca then ang:RotateAroundAxis(ang:Up(), 90) end

        local tr = util.TraceLine({
            start = eyepos,
            endpos = eyepos - -ang:Forward() * 128,
            mask = MASK_OPAQUE,
            filter = lp,
        })
        if tr.Fraction < 1 then -- We need to push the flashlight back
            local tr2 = util.TraceLine({
                start = eyepos,
                endpos = eyepos + -ang:Forward() * 128,
                mask = MASK_OPAQUE,
                filter = lp,
            })
            -- push it as back as the area behind us allows
            pos = pos + -ang:Forward() * 128 * math.min(1 - tr.Fraction, tr2.Fraction)
        end

        k.light:SetPos(pos)
        k.light:SetAngles(ang)
        k.light:Update()
    end
end