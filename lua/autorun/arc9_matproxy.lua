AddCSLuaFile()

if SERVER then return end

local envmaptint = "$envmaptint"
local envmap = "$envmap"
local lastPos = Vector()
local lastValue = 0

matproxy.Add( {
    name = "Arc9EnvMapTint",
    
    init = function(self, mat, values)
        local color = {1, 1, 1} 

        if (values.color != nil) then
            color = string.Explode(" ", string.Replace(string.Replace(values.color, "[", ""), "]", ""))
        end

        self.min = values.min || 0
        self.max = values.max || 1
        self.color = Vector(color[1], color[2], color[3])
        mat:SetTexture(envmap, values.envmap || "arc9/shared/envmaps/specularity_50")
    end,

    bind = function(self, mat, ent)
        if (!IsValid(ent)) then return end

        if (!lastPos:IsEqualTol(ent:GetPos(), 1)) then
            local c = render.GetLightColor(ent:GetPos())
            lastValue = (c.x * 0.2126) + (c.y * 0.7152) + (c.z * 0.0722)
            lastValue = math.min(lastValue * 2, 1)
            lastPos = ent:GetPos()
        end

        ent.m_Arc9EnvMapTint = Lerp(10 * FrameTime(), ent.m_Arc9EnvMapTint || 0, lastValue)
        mat:SetVector(envmaptint, self.color * Lerp(ent.m_Arc9EnvMapTint, self.min, self.max))
    end
})

----- Add this to your VMT to fix garbage/shitty reflection

    -- "Proxies"
    -- {
        -- "Arc9EnvMapTint"
        -- {
            -- "specularity" "0.5"
            -- "min" "0"
            -- "max" "0.2" // Change this if its too bright in game
        -- }
    -- }
-- }

