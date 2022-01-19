function SWEP:DoBodygroups(wm)
    if !wm and !IsValid(self:GetOwner()) then return end
    if !wm and self:GetOwner():IsNPC() then return end

    local dbg = self:GetValue("DefaultBodygroups")

    local mdl

    if wm then
        mdl = self:GetWM()
    else
        mdl = self:GetVM()
    end

    if !IsValid(mdl) then return end

    self:SetFiremodePose()

    mdl:SetSkin(self.DefaultSkin)
    mdl:SetBodyGroups(dbg or "")

    local eles = self:GetElements()

    for i, k in pairs(eles) do
        local ele = self.AttachmentElements[i]

        if !ele then continue end

        for _, j in pairs(ele.Bodygroups or {}) do
            mdl:SetBodygroup(j[1], j[2])
        end

        if ele.Skin then
            mdl:SetSkin(ele.Skin)
        end
    end

    local bbg = self:GetValue("BulletBodygroups")

    if bbg then
        local amt = self:Clip1()

        if self:GetReloading() then
            amt = self:GetLoadedRounds()
        end

        for c, bgs in pairs(bbg) do
            if !isnumber(c) then continue end
            if amt < c then
                mdl:SetBodygroup(bgs[1], bgs[2])
                break
            end
        end
    end
end

function SWEP:GetElements()
    return {}
end