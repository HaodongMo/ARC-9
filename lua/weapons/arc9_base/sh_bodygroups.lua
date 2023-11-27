local v0 = Vector(0, 0, 0)
local v1 = Vector(1, 1, 1)

function SWEP:DoBodygroups(wm, cm)
    if cm then wm = true end
    local owner = self:GetOwner()

    if !wm and !IsValid(owner) then return end
    if !wm and owner:IsNPC() then return end

    local dbg = self.DefaultBodygroups

    local mdl

    if wm then
        mdl = self:GetWM()
        if cm then
            mdl = self.CModel[1]
        end
    else
        mdl = self:GetVM()
    end

    if !IsValid(mdl) then return end

    mdl:SetSkin(self.DefaultSkin)
    mdl:SetBodyGroups(dbg or "")

    for i = 0, mdl:GetBoneCount() do
        mdl:ManipulateBoneScale(i, v1)
    end

    local eles = self:GetAttachmentElements()

    for _, ele in ipairs(eles) do
        for _, j in pairs(ele.Bodygroups or {}) do
            if !istable(j) then continue end
            mdl:SetBodygroup(j[1] or 0, j[2] or 0)
        end

        if ele.Skin then
            mdl:SetSkin(ele.Skin)
        end
    end

    local bbg = self.BulletBodygroups

    if bbg then
        local amt = self:Clip1()

        if self:GetReloading() then
            amt = self:GetLoadedRounds()
        end

        for c, bgs in ipairs(bbg or {}) do
            if !isnumber(c) then continue end
            if amt < c then
                mdl:SetBodygroup(bgs[1], bgs[2])
                break
            end
        end
    end

    local stbg = self.SoundTableBodygroups
    if stbg then
        for i, k in pairs(stbg) do
            mdl:SetBodygroup(i, k)
        end
    end

    for i = 0, mdl:GetNumPoseParameters() - 1 do
        mdl:SetPoseParameter(i, 0)
        local ii = mdl:GetPoseParameterName(i)

        if self.SoundTablePoseParams[ii] then
            mdl:SetPoseParameter(i, self.SoundTablePoseParams[ii])
        end
    end

    local hidebones = self:GetHiddenBones(wm)

    for bone, a in pairs(hidebones or {}) do
        if !a then continue end
        local boneid = isnumber(bone) and bone or mdl:LookupBone(bone)

        if !boneid then continue end

        mdl:ManipulateBoneScale(boneid, v0)
    end

    local bulletbones = self:GetProcessedValue("BulletBones", true)
    
    if bulletbones then
        for i, bone in ipairs(bulletbones or {}) do
            local bones = bone
            if !istable(bones) then
                bones = {bone}
            end

            local loaded = self:GetLoadedRounds()
            if self:GetProcessedValue("BottomlessClip", true) then loaded = self:Ammo1() end

            for _, bone2 in ipairs(bones) do
                local boneid = isnumber(bone2) and bone2 or mdl:LookupBone(bone2)

                if !boneid then continue end

                if i > loaded and !clear then
                    mdl:ManipulateBoneScale(boneid, v0)
                end
            end
        end
    end

    local stripperbones = self:GetProcessedValue("StripperClipBones", true)
    if stripperbones then
        for i, bone in ipairs(stripperbones or {}) do
            local bones = bone
            if !istable(bones) then
                bones = {bone}
            end

            for _, bone2 in ipairs(bones) do
                local boneid = isnumber(bone2) and bone2 or mdl:LookupBone(bone2)

                if !boneid then continue end

                if i > self:GetLoadingIntoClip() and !clear then
                    mdl:ManipulateBoneScale(boneid, v0)
                end
            end
        end
    end

    mdl.CustomCamoTexture = self:GetProcessedValue("CustomCamoTexture", true)
    mdl.CustomCamoScale = self:GetProcessedValue("CustomCamoScale", true)
    mdl.CustomBlendFactor = self:GetProcessedValue("CustomBlendFactor", true)

    -- PrintTable(mdl:GetMaterials())

    self:RunHook("Hook_ModifyBodygroups", {model = mdl, elements = eles})
end

function SWEP:GetHiddenBones(wm)
    local hide = false
    -- optimize this later pls
    
    if self.CustomizeDelta > 0 then
        hide = true
    end

    local hidefp = self:GetProcessedValue("ReloadHideBonesFirstPerson", true)

    if wm or hidefp then
        hide = true
    end

    local hidebones = self:GetProcessedValue("HideBones", true)
    local reloadhidebones = self:GetProcessedValue("ReloadHideBoneTables", true)

    local bones = {}

    if self:GetReloading() then
        hide = false
    end

    local index = self:GetHideBoneIndex()

    if hidefp or (self:GetAnimLockTime() >= CurTime() and reloadhidebones and self:ShouldTPIK() and wm) and index != 0 then
        for _, bone in ipairs(reloadhidebones[index] or {}) do
            bones[bone] = true
        end
    else
        if hidebones and hide then
            for _, bone in ipairs(hidebones) do
                bones[bone] = true
            end
        end
    end

    bones = self:RunHook("Hook_HideBones", bones) or bones

    return bones
end

-- function SWEP:GetElements()
--     return {}
-- end