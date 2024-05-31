SWEP.ElementsCache = {}

function SWEP:GetElements(exclude)
    if !exclude and self.ElementsCache then
        local eles = self.ElementsCache

        if !ARC9.ModifyElementsOverrun then
            ARC9.ModifyElementsOverrun = true
            eles = self:RunHook("Hook_ModifyElements", eles) or eles
            ARC9.ModifyElementsOverrun = false
        end

        return eles
    end

    local eles = {}

    for _, slottbl in ipairs(self:GetSubSlotList()) do
        if exclude and exclude[slottbl.Address] then continue end
        if slottbl.Installed then
            table.Add(eles, slottbl.InstalledElements or {})
            table.insert(eles, slottbl.Installed)
        else
            table.Add(eles, slottbl.UnInstalledElements or {})
        end
    end

    table.Add(eles, self.DefaultElements or {})

    if !ARC9.Overrun then
        ARC9.Overrun = true

        for _, affector in ipairs(self:GetAllAffectors()) do
            table.Add(eles, affector.ActivateElements or {})

            local cat = affector.Category
            if !istable(cat) then
                cat = {cat}
            end

            table.Add(eles, cat)
        end

        ARC9.Overrun = false
    end

    local eles2 = {}

    for _, ele in pairs(eles) do
        eles2[ele] = true
    end

    if !exclude then
        self.ElementsCache = eles2
    end

    if !ARC9.ModifyElementsOverrun then
        ARC9.ModifyElementsOverrun = true
        eles2 = self:RunHook("Hook_ModifyElements", eles2) or eles2
        ARC9.ModifyElementsOverrun = false
    end

    return eles2
end

function SWEP:HasElement(ele)
    if !self.ElementsCache then self:GetElements() end
    return self.ElementsCache[ele] == true
end