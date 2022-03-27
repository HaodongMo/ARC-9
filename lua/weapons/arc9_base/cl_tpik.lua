// third person inverse kinematics

function SWEP:ShouldTPIK()
    if render.GetDXLevel() < 90 then return false end
    if self:GetSafe() then return false end
    if self:GetBlindFireAmount() > 0 then return false end
    if !self:GetOwner():ShouldDrawLocalPlayer() then return false end
    -- return LocalPlayer() == self:GetOwner()
    -- return false
    return GetConVar("arc9_tpik"):GetBool()
end

function SWEP:DoTPIK()
    if !self:ShouldTPIK() then return end
    if !self.MirrorVMWM then return end

    local vm = self:GetVM()
    local wm = self:GetWM()
    local ply = self:GetOwner()

    if !IsValid(vm) then return end
    if !IsValid(wm) then return end

    local nolefthand = false

    if self:GetHoldType() == "slam" then
        nolefthand = true
    end

    wm:SetupBones()

    wm:SetSequence(vm:GetSequence())
    wm:SetCycle(vm:GetCycle())

    -- for i = 0, vm:GetNumPoseParameters() do
    --     local pp_name = wm:GetPoseParameterName(i)
    --     if !pp_name then continue end
    --     wm:SetPoseParameter(pp_name, vm:GetPoseParameter(pp_name))
    -- end

    -- for i = 0, vm:GetNumBodyGroups() do
    --     local bg = vm:GetBodygroup(i)
    --     if !bg then continue end
    --     wm:SetBodygroup(i, bg)
    -- end

    wm:InvalidateBoneCache()

    self:DoRHIK(true)

    self:SetFiremodePose(true)

    ply:SetupBones()

    local bones = ARC9.TPIKBones

    if nolefthand then
        bones = ARC9.RHIKHandBones
    end

    for _, bone in ipairs(bones) do
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

    local ply_l_shoulder_index = ply:LookupBone("ValveBiped.Bip01_L_UpperArm")
    local ply_r_shoulder_index = ply:LookupBone("ValveBiped.Bip01_R_UpperArm")
    local ply_l_elbow_index = ply:LookupBone("ValveBiped.Bip01_L_Forearm")
    local ply_r_elbow_index = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
    local ply_l_hand_index = ply:LookupBone("ValveBiped.Bip01_L_Hand")
    local ply_r_hand_index = ply:LookupBone("ValveBiped.Bip01_R_Hand")

    local ply_head_index = ply:LookupBone("ValveBiped.Bip01_Head1")

    if !ply_l_shoulder_index then return end
    if !ply_r_shoulder_index then return end
    if !ply_l_elbow_index then return end
    if !ply_r_elbow_index then return end
    if !ply_l_hand_index then return end
    if !ply_r_hand_index then return end

    if !ply_head_index then return end

    local ply_r_shoulder_matrix = ply:GetBoneMatrix(ply_r_shoulder_index)
    local ply_r_elbow_matrix = ply:GetBoneMatrix(ply_r_elbow_index)
    local ply_r_hand_matrix = ply:GetBoneMatrix(ply_r_hand_index)

    local ply_head_matrix = ply:GetBoneMatrix(ply_head_index)

    local r_upperarm_length = 12
    local r_forearm_length = 12
    local l_upperarm_length = 12
    local l_forearm_length = 12

    local ply_r_upperarm_pos, ply_r_forearm_pos = self:Solve2PartIK(ply_r_shoulder_matrix:GetTranslation(), ply_r_hand_matrix:GetTranslation(), r_upperarm_length, r_forearm_length, -35)

    debugoverlay.Line(ply_r_shoulder_matrix:GetTranslation(), ply_r_upperarm_pos, 0.1, Color(255, 255, 255), true)
    debugoverlay.Line(ply_r_upperarm_pos, ply_r_forearm_pos, 0.1, Color(255, 255, 255), true)
    -- debugoverlay.Line(ply_r_forearm_pos, ply_r_hand_matrix:GetTranslation(), 0.1, Color(255, 255, 255), true)

    -- ply_r_shoulder_matrix:SetTranslation(ply_r_upperarm_pos)
    ply_r_elbow_matrix:SetTranslation(ply_r_upperarm_pos)

    local ply_r_shoulder_angle = (ply_r_upperarm_pos - ply_r_shoulder_matrix:GetTranslation()):GetNormalized():Angle()
    ply_r_shoulder_angle.r = 180
    ply_r_shoulder_matrix:SetAngles(ply_r_shoulder_angle)

    local ply_r_elbow_angle = (ply_r_forearm_pos - ply_r_upperarm_pos):GetNormalized():Angle()
    ply_r_elbow_angle.r = -90
    ply_r_elbow_matrix:SetAngles(ply_r_elbow_angle)

    if self:GetCameraControl() then
        local camcontrol = self:GetCameraControl() * 4
        local ply_head_angle = ply:GetBoneMatrix(ply_head_index):GetAngles() + Angle(camcontrol.z, -camcontrol.x, camcontrol.y)

        ply_head_matrix:SetAngles(ply_head_angle)
        ply:SetBoneMatrix(ply_head_index, ply_head_matrix)
    end

    ply:SetBoneMatrix(ply_r_elbow_index, ply_r_elbow_matrix)
    ply:SetBoneMatrix(ply_r_shoulder_index, ply_r_shoulder_matrix)

    if nolefthand then return end

    local ply_l_shoulder_matrix = ply:GetBoneMatrix(ply_l_shoulder_index)
    local ply_l_elbow_matrix = ply:GetBoneMatrix(ply_l_elbow_index)
    local ply_l_hand_matrix = ply:GetBoneMatrix(ply_l_hand_index)

    local ply_l_upperarm_pos, ply_l_forearm_pos = self:Solve2PartIK(ply_l_shoulder_matrix:GetTranslation(), ply_l_hand_matrix:GetTranslation(), l_upperarm_length, l_forearm_length, 35)

    debugoverlay.Line(ply_l_shoulder_matrix:GetTranslation(), ply_l_upperarm_pos, 0.1, Color(255, 255, 255), true)
    debugoverlay.Line(ply_l_upperarm_pos, ply_l_forearm_pos, 0.1, Color(255, 255, 255), true)
    -- debugoverlay.Line(ply_l_forearm_pos, ply_l_hand_matrix:GetTranslation(), 0.1, Color(255, 255, 255), true)

    -- ply_l_shoulder_matrix:SetTranslation(ply_l_upperarm_pos)
    ply_l_hand_matrix:SetTranslation(ply_l_forearm_pos)
    ply_l_elbow_matrix:SetTranslation(ply_l_upperarm_pos)

    local ply_l_shoulder_angle = (ply_l_upperarm_pos - ply_l_shoulder_matrix:GetTranslation()):GetNormalized():Angle()
    ply_l_shoulder_angle.r = -45
    ply_l_shoulder_matrix:SetAngles(ply_l_shoulder_angle)

    local ply_l_elbow_angle = (ply_l_forearm_pos - ply_l_upperarm_pos):GetNormalized():Angle()
    ply_l_elbow_angle.r = -90
    ply_l_elbow_matrix:SetAngles(ply_l_elbow_angle)

    ply:SetBoneMatrix(ply_l_hand_index, ply_l_hand_matrix)
    ply:SetBoneMatrix(ply_l_elbow_index, ply_l_elbow_matrix)
    ply:SetBoneMatrix(ply_l_shoulder_index, ply_l_shoulder_matrix)
end