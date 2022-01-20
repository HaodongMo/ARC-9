function SWEP:GetPresetBase()
    return self.SaveBase or self:GetClass()
end

function SWEP:GetPresets()
    local path = ARC9.PresetPath .. self:GetPresetBase() .. "/*.arc9save"

    local files = file.Find(path, "DATA")

    return files
end

function SWEP:SavePreset(name)
end

function SWEP:LoadPreset(name)
end