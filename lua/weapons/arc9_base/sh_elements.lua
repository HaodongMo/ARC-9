SWEP.ElementsCache = {}

function SWEP:GetElements()
    if self.ElementsCache then return self.ElementsCache end

    local eles = {}

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if slottbl.Installed then
            table.Add(eles, slottbl.InstalledElements or {})
            local atttbl = ARC9.GetAttTable(slottbl.Installed)
            table.Add(eles, atttbl.ActivateElements or {})
            local cat = atttbl.Category
            if !istable(cat) then
                cat = {cat}
            end
            table.Add(eles, cat)
            table.insert(eles, slottbl.Installed)
        else
            table.Add(eles, slottbl.UnInstalledElements or {})
        end
    end

    table.insert(eles, self.DefaultElements or {})

    if !ARC9.Overrun then
        ARC9.Overrun = true
        table.insert(eles, self:GetCurrentFiremodeTable().ActivateElements or {})
        ARC9.Overrun = false
    end

    local eles2 = {}

    for _, ele in pairs(eles) do
        eles2[ele] = true
    end

    self.ElementsCache = eles2

    return eles2
end

function SWEP:HasElement(ele)
    if !self.ElementsCache then self:GetElements() end
    return self.ElementsCache[ele] == true
end