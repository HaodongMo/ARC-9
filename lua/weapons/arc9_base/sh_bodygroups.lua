local v0 = Vector(0, 0, 0)
local v1 = Vector(1, 1, 1)

local swepGetProcessedValue = SWEP.GetProcessedValue

function SWEP:DoBodygroups(wm, cm)
    wm = wm or cm
    local owner = self:GetOwner()
    local validowner = IsValid(owner)
    local isnpc = (validowner and owner:IsNPC()) or self:ShouldLOD() > 0

    if !wm and !validowner then return end

    local mdl = wm and self:GetWM() or self:GetVM()
    if cm then mdl = self.CModel[1] end

    if !IsValid(mdl) then return end

    mdl:SetSkin(self.DefaultSkin)
    mdl:SetBodyGroups(self.DefaultBodygroups or "")

    for _, ele in ipairs(self:GetAttachmentElements()) do
        for _, j in pairs(ele.Bodygroups or {}) do
            if !istable(j) then continue end

            local id = j[1]
            if !isnumber(id) then continue end

            mdl:SetBodygroup(id, j[2] or 0)
        end

        if ele.Skin then mdl:SetSkin(ele.Skin)  end
    end

    if !isnpc then
        for i = 0, mdl:GetBoneCount() do
            mdl:ManipulateBoneScale(i, v1)
        end
        
        local swepDt = self.dt
        local amt = swepDt.Reloading and swepDt.LoadedRounds or self:Clip1()
        local bbg = self.BulletBodygroups

        if bbg then
            for c, bgs in ipairs(bbg) do
                if amt < c and istable(bgs) then
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

        if CLIENT then
            local poseParams = self.SoundTablePoseParams
            for i = 0, mdl:GetNumPoseParameters() - 1 do
                mdl:SetPoseParameter(i, 0)
                local name = mdl:GetPoseParameterName(i)

                if poseParams and poseParams[name] then
                    mdl:SetPoseParameter(i, poseParams[name])
                end
            end
        end

        local hidebones = self:GetHiddenBones(wm)

        for bone, enabled in pairs(hidebones or {}) do
            if !enabled then continue end

            local boneid = isnumber(bone) and bone or mdl:LookupBone(bone)
            if boneid then mdl:ManipulateBoneScale(boneid, v0) end
        end


        local bulletbones = swepGetProcessedValue(self, "BulletBones", true)

        if bulletbones then
            local loaded = swepGetProcessedValue(self, "BottomlessClip", true) and self:Ammo1() or swepDt.LoadedRounds - (self.BulletBonesSub1 and 1 or 0)

            for i, bone in ipairs(bulletbones) do
                local bones = istable(bone) and bone or {bone}
                if i > loaded then
                    for _, bone2 in ipairs(bones) do
                        local boneid = isnumber(bone2) and bone2 or mdl:LookupBone(bone2)
                        if boneid then
                            mdl:ManipulateBoneScale(boneid, v0)
                        end
                    end
                end
            end
        end


        local stripperbones = swepGetProcessedValue(self, "StripperClipBones", true)

        if stripperbones then
            local loadingIntoClip = self:GetLoadingIntoClip()
            for i, bone in ipairs(stripperbones) do
                local bones = istable(bone) and bone or {bone}
                if i > loadingIntoClip then
                    for _, bone2 in ipairs(bones) do
                        local boneid = isnumber(bone2) and bone2 or mdl:LookupBone(bone2)
                        if boneid then
                            mdl:ManipulateBoneScale(boneid, v0)
                        end
                    end
                end
            end
        end
    else
        local hidebones = self:GetHiddenBones(wm)

        for bone, enabled in pairs(hidebones or {}) do
            if !enabled then continue end

            local boneid = isnumber(bone) and bone or mdl:LookupBone(bone)
            if boneid then mdl:ManipulateBoneScale(boneid, v0) end
        end
    end

    mdl.CustomCamoTexture = swepGetProcessedValue(self, "CustomCamoTexture", true)
    mdl.CustomCamoScale = swepGetProcessedValue(self, "CustomCamoScale", true)
    mdl.CustomBlendFactor = swepGetProcessedValue(self, "CustomBlendFactor", true)

    self:RunHook("Hook_ModifyBodygroups", {model = mdl, elements = self:GetElements()})

    if CLIENT and not isnpc then
        for pp, ppv in pairs(self:GetReloadPoseParameterTable(wm)) do
            if !pp then continue end
            mdl:SetPoseParameter(pp, ppv)
        end
    end
end

function SWEP:GetReloadPoseParameterTable(wm)
    local pptables = swepGetProcessedValue(self, "ReloadPoseParameterTables", true)
    local index = self:GetPoseParameterIndex()
    local pps = {}

    if index ~= 0 then
        for pp, ppv in pairs(pptables and pptables[index] or {}) do
            pps[pp] = ppv
        end
    end

    return pps
end

function SWEP:GetHiddenBones(wm)
    local hidefp = swepGetProcessedValue(self, "ReloadHideBonesFirstPerson", true)
    local hide = self.CustomizeDelta > 0 or wm or hidefp
    local hidebones = swepGetProcessedValue(self, "HideBones", true)
    local reloadhidebones = swepGetProcessedValue(self, "ReloadHideBoneTables", true)
    local bones = {}

    if self:GetReloading() then
        hide = false
    end

    local index = self:GetHideBoneIndex()
    if index ~= 0 and ((hidefp and not wm) or (reloadhidebones and self:ShouldTPIK() and wm)) then
        for _, bone in ipairs(reloadhidebones[index] or {}) do
            bones[bone] = true
        end
    elseif hidebones and hide then
        for _, bone in ipairs(hidebones) do
            bones[bone] = true
        end
    end

    return self:RunHook("Hook_HideBones", bones) or bones
end

-- function SWEP:GetElements()
--     return {}
-- end