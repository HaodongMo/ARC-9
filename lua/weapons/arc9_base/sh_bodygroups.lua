local v0 = Vector(0, 0, 0)
local v1 = Vector(1, 1, 1)

function SWEP:DoBodygroups(wm, clear)
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

    mdl:SetSkin(self.DefaultSkin)
    mdl:SetBodyGroups(dbg or "")

    for i = 0, mdl:GetBoneCount() do
        mdl:ManipulateBoneScale(i, v1)
    end

    local eles = self:GetElements()

    for i, k in pairs(eles) do
        local ele = self.AttachmentElements[i]

        if !ele then continue end

        for _, j in pairs(ele.Bodygroups or {}) do
            if !istable(j) then continue end
            mdl:SetBodygroup(j[1] or 0, j[2] or 0)
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

    local hide = false

    if self.CustomizeDelta > 0 then
        hide = true
    end

    if wm then
        hide = true
    end

    if clear then hide = false end

    local hidebones = self:GetProcessedValue("HideBones")
    local reloadhidebones = self:GetProcessedValue("ReloadHideBoneTables")

    if self:GetReloading() then
        hide = false
    end

    if self:GetReloading() and reloadhidebones and self:ShouldTPIK() and wm then
        local index = self:GetHideBoneIndex()

        if index != 0 then
            for _, bone in ipairs(reloadhidebones[index] or {}) do
                local boneid = mdl:LookupBone(bone)

                if !boneid then continue end

                mdl:ManipulateBoneScale(boneid, v0)
            end
        end
    else
        if hidebones then
            for _, bone in pairs(hidebones) do
                local boneid = mdl:LookupBone(bone)

                if !boneid then continue end

                if hide then
                    mdl:ManipulateBoneScale(boneid, v0)
                end
            end
        end
    end

    if !wm then
        local bulletbones = self:GetProcessedValue("BulletBones")

        for i, bone in pairs(bulletbones) do
            local boneid = mdl:LookupBone(bone)

            if !boneid then continue end

            if i > self:GetLoadedRounds() and !clear then
                mdl:ManipulateBoneScale(boneid, v0)
            end
        end
    end

    self:RunHook("Hook_ModifyBodygroups", {model = mdl, elements = eles})
end

function SWEP:GetElements()
    return {}
end