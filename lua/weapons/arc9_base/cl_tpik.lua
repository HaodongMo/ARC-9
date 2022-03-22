// third person inverse kinematics

function SWEP:ShouldTPIK()
    return LocalPlayer() == self:GetOwner()
end

function SWEP:DoTPIK()
    if !self:ShouldTPIK() then return end
    if !self.MirrorVMWM then return end

    local vm = self:GetVM()
    local wm = self:GetWM()
    local ply = self:GetOwner()

    if !IsValid(vm) then return end
    if !IsValid(wm) then return end

    wm:SetSequence(vm:GetSequence())
    wm:SetCycle(vm:GetCycle())

    for i = 0, wm:GetNumPoseParameters() do
        local pp_name = wm:GetPoseParameterName(i)
        if !pp_name then continue end
        wm:SetPoseParameter(pp_name, vm:GetPoseParameter(pp_name))
    end

    wm:SetupBones()

    ply:SetupBones()

    for _, bone in pairs(ARC9.TPIKBones) do
        local wm_boneindex = wm:LookupBone(bone)
        if !wm_boneindex then continue end
        local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
        if !wm_bonematrix then continue end

        local ply_boneindex = ply:LookupBone(bone)
        if !ply_boneindex then continue end
        local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
        if !ply_bonematrix then continue end

        local bonepos = wm_bonematrix:GetTranslation()
        local boneang = wm_bonematrix:GetAngles()

        ply_bonematrix:SetTranslation(bonepos)
        ply_bonematrix:SetAngles(boneang)

        ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
        ply:SetBonePosition(ply_boneindex, bonepos, boneang)
    end
end