local materials = {
    [0] = "effects/peanut",
    [1] = "effects/fas_debris_add_a"
}

function EFFECT:Init(data)
    local vOffset = data:GetOrigin()
    local vMat = data:GetMaterialIndex() or 0
    local NumParticles = data:GetScale() or 50
    local emitter = ParticleEmitter(vOffset, true)

    for i = 0, NumParticles do
        -- local Pos = Vector(math.Rand(-1.5, 1.5), math.Rand(-1.5, 1.5), math.Rand(-.5, .5))
        local Pos = Vector(math.sin(math.rad(i * 1.5)) * math.Rand(-1.5, 1.5), math.cos(math.rad(i * 1.5)) * math.Rand(-1.5, 1.5), math.Rand(0, .5)) -- :trollscream:
        local particle = emitter:Add(materials[data:GetMaterialIndex()], vOffset + Pos * 10)

        if particle then
            if data:GetMaterialIndex() == 0 then
                particle:SetVelocity(Pos * 80)
                particle:SetLifeTime(0)
                particle:SetDieTime(0.5 + vMat)
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(vMat * 200)
                local Size = math.Rand(2, 3) * (vMat + 1)
                particle:SetStartSize(Size)
                particle:SetEndSize(0)
                particle:SetRoll(math.Rand(0, 360))
                -- particle:SetRoll(145)
                particle:SetRollDelta(math.Rand(-2, 2))
                particle:SetAirResistance(50)
                particle:SetGravity(Vector(0, 0, -900))
                particle:SetColor(180, 180, 180)
                particle:SetCollide(true)
                particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
                particle:SetBounce(0.3 + vMat)
                particle:SetLighting(false)
            else
                particle:SetVelocity(Pos * 80)
                particle:SetLifeTime(0)
                particle:SetDieTime(0.5 + vMat)
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(vMat * 200)
                local Size = math.Rand(2, 3) * (vMat + 1)
                particle:SetStartSize(Size)
                particle:SetEndSize(0)
                particle:SetRoll(math.Rand(0, 360))
                -- particle:SetRoll(145)
                particle:SetRollDelta(math.Rand(-2, 2))
                particle:SetAirResistance(50)
                particle:SetGravity(Vector(0, 0, -900))
                particle:SetColor(180, 180, 180)
                particle:SetCollide(true)
                particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
                particle:SetBounce(0.3 + vMat)
                particle:SetLighting(true)
            end
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return
end

function EFFECT:Render()
end
