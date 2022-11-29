-- third person inverse kinematics

function SWEP:ShouldTPIK()
    if self.NoTPIK then return end
    local owner = self:GetOwner()
    local lp = LocalPlayer()

    if render.GetDXLevel() < 90 then return end
    if !owner:IsPlayer() then return end
    if owner:InVehicle() then return end
    if owner.ARC9_HoldingProp then return end
    if !self.MirrorVMWM then return end
    if self:ShouldLOD() == 2 then return end
    -- if self:GetSafe() then return end
    -- if self:GetBlindFireAmount() > 0 then return false end
    if lp == owner and !owner:ShouldDrawLocalPlayer() then return end
    -- if !GetConVar("arc9_tpik"):GetBool() then return false end
    if lp != owner then
        return GetConVar("arc9_tpik_others"):GetBool()
    else
        return GetConVar("arc9_tpik"):GetBool()
    end
    -- return false
end

SWEP.TPIKCache = {}
SWEP.LastTPIKTime = 0

local cachelastcycle = 0 -- probably bad

function SWEP:DoTPIK()
    local wm = self:GetWM()
    if !IsValid(wm) then return end

    if !self:ShouldTPIK() then 
        if cachelastcycle > 0 then wm:SetCycle(0) cachelastcycle = 0 end
        return
     end

    local ply = self:GetOwner()

    local tpikdelay = RealFrameTime()
    
    local lod

    if ply != LocalPlayer() then
        local dist = EyePos():DistToSqr(ply:GetPos())

        local convartpiktime = GetConVar("arc9_tpik_framerate"):GetFloat()
        convartpiktime = (convartpiktime == 0) and 250 or math.Clamp(convartpiktime, 5, 250)
        tpikdelay = 1 / convartpiktime

        lod = self:ShouldLOD()

        if lod == 1 then
            tpikdelay = 1 / 20 -- 20 fps if lodding
        elseif lod == 1.5 then
            tpikdelay = 1 / 10
        end
    end

    local shouldfulltpik = true

    if self.LastTPIKTime + tpikdelay > CurTime() then
        shouldfulltpik = false
    end

    local nolefthand = false

    if self:GetHoldType() == "slam" or self:GetHoldType() == "magic" then
        nolefthand = true
    end

    wm:SetupBones()

    local time = self:GetSequenceCycle()
    local seq = self:GetSequenceIndex()

    wm:SetSequence(seq)

    wm:SetCycle(time)
    cachelastcycle = time

    -- wm:SetSequence(vm:GetSequence())
    -- wm:SetCycle(vm:GetCycle())

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

    if lod == 1.5 then -- hackkkkk
        bones = ARC9.LHIKHandBones
    end

    local ply_spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
    if !ply_spine_index then return end
    local ply_spine_matrix = ply:GetBoneMatrix(ply_spine_index)
    local wmpos = ply_spine_matrix:GetTranslation()

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

        bonepos.x = math.Clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38) -- clamping if something gone wrong so no stretching (or animator is fleshy)
        bonepos.y = math.Clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
        bonepos.z = math.Clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

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

    local ply_l_HELPERelbow_index = ply:LookupBone("ValveBiped.Bip01_L_Elbow")
    if ply_l_HELPERelbow_index and !ply:BoneHasFlag(ply_l_HELPERelbow_index, 524032) then ply_l_HELPERelbow_index = nil end -- ply:GetBoneName(ply_l_HELPERelbow_index) == "__INVALIDBONE__" can work too, same performance hit

    local ply_l_bicep_index = ply:LookupBone("ValveBiped.Bip01_L_Bicep")
    local ply_l_ulna_index = ply:LookupBone("ValveBiped.Bip01_L_Ulna") or ply:LookupBone("HumanLForearm2") -- THANK YOU MAl0 FOR NOT RENAMING YOUR BONES
    local ply_l_wrist_index = ply:LookupBone("ValveBiped.Bip01_L_Wrist") or ply:LookupBone("HumanLForearm3")

    local ply_r_HELPERelbow_index = ply:LookupBone("ValveBiped.Bip01_R_Elbow")
    if ply_r_HELPERelbow_index and !ply:BoneHasFlag(ply_r_HELPERelbow_index, 524032) then ply_r_HELPERelbow_index = nil end

    local ply_r_bicep_index = ply:LookupBone("ValveBiped.Bip01_R_Bicep")
    local ply_r_ulna_index = ply:LookupBone("ValveBiped.Bip01_R_Ulna") or ply:LookupBone("HumanRForearm2")
    local ply_r_wrist_index = ply:LookupBone("ValveBiped.Bip01_R_Wrist") or ply:LookupBone("HumanRForearm3")

    if ply_l_bicep_index and !ply:BoneHasFlag(ply_l_bicep_index, 524032) then ply_l_bicep_index = nil end
    if ply_l_ulna_index and !ply:BoneHasFlag(ply_l_ulna_index, 524032) then ply_l_ulna_index = nil end
    if ply_r_bicep_index and !ply:BoneHasFlag(ply_r_bicep_index, 524032) then ply_r_bicep_index = nil end
    if ply_r_ulna_index and !ply:BoneHasFlag(ply_r_ulna_index, 524032) then ply_r_ulna_index = nil end
    
    if !ply_l_shoulder_index then return end
    if !ply_r_shoulder_index then return end
    if !ply_l_elbow_index then return end
    if !ply_r_elbow_index then return end
    if !ply_l_hand_index then return end
    if !ply_r_hand_index then return end

    local ply_r_shoulder_matrix = ply:GetBoneMatrix(ply_r_shoulder_index)
    local ply_r_elbow_matrix = ply:GetBoneMatrix(ply_r_elbow_index)
    local ply_r_hand_matrix = ply:GetBoneMatrix(ply_r_hand_index)

    local r_upperarm_length = 12
    local r_forearm_length = 12
    local l_upperarm_length = 12
    local l_forearm_length = 12

    local ply_r_upperarm_pos, ply_r_forearm_pos

    if shouldfulltpik then
        ply_r_upperarm_pos, ply_r_forearm_pos = self:Solve2PartIK(ply_r_shoulder_matrix:GetTranslation(), ply_r_hand_matrix:GetTranslation(), r_upperarm_length, r_forearm_length, -35)
        self.LastTPIKTime = CurTime()

        self.TPIKCache.r_upperarm_pos = WorldToLocal(ply_r_upperarm_pos, angle_zero, ply_r_shoulder_matrix:GetTranslation(), ply_r_shoulder_matrix:GetAngles())
        self.TPIKCache.r_forearm_pos = WorldToLocal(ply_r_forearm_pos, angle_zero, ply_r_shoulder_matrix:GetTranslation(), ply_r_shoulder_matrix:GetAngles())
    else
        ply_r_upperarm_pos = LocalToWorld(self.TPIKCache.r_upperarm_pos, angle_zero, ply_r_shoulder_matrix:GetTranslation(), ply_r_shoulder_matrix:GetAngles())
        ply_r_forearm_pos = LocalToWorld(self.TPIKCache.r_forearm_pos, angle_zero, ply_r_shoulder_matrix:GetTranslation(), ply_r_shoulder_matrix:GetAngles())
    end

    debugoverlay.Line(ply_r_shoulder_matrix:GetTranslation(), ply_r_upperarm_pos, 0.1)
    debugoverlay.Line(ply_r_upperarm_pos, ply_r_forearm_pos, 0.1)
    -- debugoverlay.Line(ply_r_forearm_pos, ply_r_hand_matrix:GetTranslation(), 0.1)

    -- ply_r_shoulder_matrix:SetTranslation(ply_r_upperarm_pos)
    ply_r_elbow_matrix:SetTranslation(ply_r_upperarm_pos)

    local ply_r_shoulder_angle = (ply_r_upperarm_pos - ply_r_shoulder_matrix:GetTranslation()):GetNormalized():Angle()
    ply_r_shoulder_angle.r = 180
    ply_r_shoulder_matrix:SetAngles(ply_r_shoulder_angle)

    local ply_r_elbow_angle = (ply_r_forearm_pos - ply_r_upperarm_pos):GetNormalized():Angle()
    ply_r_elbow_angle.r = -90
    ply_r_elbow_matrix:SetAngles(ply_r_elbow_angle)

    ply:SetBoneMatrix(ply_r_elbow_index, ply_r_elbow_matrix)
    ply:SetBoneMatrix(ply_r_shoulder_index, ply_r_shoulder_matrix)

    if nolefthand then return end

    local ply_l_shoulder_matrix = ply:GetBoneMatrix(ply_l_shoulder_index)
    local ply_l_elbow_matrix = ply:GetBoneMatrix(ply_l_elbow_index)
    local ply_l_hand_matrix = ply:GetBoneMatrix(ply_l_hand_index)

    local ply_l_HELPERelbow_matrix = ply_l_HELPERelbow_index and ply:GetBoneMatrix(ply_l_HELPERelbow_index)
    local ply_l_bicep_matrix = ply_l_bicep_index and ply:GetBoneMatrix(ply_l_bicep_index)
    local ply_l_ulna_matrix = ply_l_ulna_index and ply:GetBoneMatrix(ply_l_ulna_index)
    local ply_l_wrist_matrix = ply_l_wrist_index and ply:GetBoneMatrix(ply_l_wrist_index)

    local ply_r_HELPERelbow_matrix = ply_r_HELPERelbow_index and ply:GetBoneMatrix(ply_r_HELPERelbow_index)
    local ply_r_bicep_matrix = ply_r_bicep_index and ply:GetBoneMatrix(ply_r_bicep_index)
    local ply_r_ulna_matrix = ply_r_ulna_index and ply:GetBoneMatrix(ply_r_ulna_index)
    local ply_r_wrist_matrix = ply_r_wrist_index and ply:GetBoneMatrix(ply_r_wrist_index)

    -- local ply_r_upperarm_pos = ply:LocalToWorld(self.TPIKCache.r_upperarm_pos)
    -- local ply_r_forearm_pos = ply:LocalToWorld(self.TPIKCache.r_forearm_pos)

    -- if shouldfulltpik then
    --     ply_r_upperarm_pos, ply_r_forearm_pos = self:Solve2PartIK(ply_r_shoulder_matrix:GetTranslation(), ply_r_hand_matrix:GetTranslation(), r_upperarm_length, r_forearm_length, -35)
    --     self.LastTPIKTime = CurTime()

    --     self.TPIKCache.r_upperarm_pos = ply:WorldToLocal(ply_r_upperarm_pos)
    --     self.TPIKCache.r_forearm_pos = ply:WorldToLocal(ply_r_forearm_pos)
    -- end

    local ply_l_upperarm_pos, ply_l_forearm_pos

    if shouldfulltpik then
        ply_l_upperarm_pos, ply_l_forearm_pos = self:Solve2PartIK(ply_l_shoulder_matrix:GetTranslation(), ply_l_hand_matrix:GetTranslation(), l_upperarm_length, l_forearm_length, 35)

        self.LastTPIKTime = CurTime()
        self.TPIKCache.l_upperarm_pos = WorldToLocal(ply_l_upperarm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
        self.TPIKCache.l_forearm_pos = WorldToLocal(ply_l_forearm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
    else
        ply_l_upperarm_pos = LocalToWorld(self.TPIKCache.l_upperarm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
        ply_l_forearm_pos = LocalToWorld(self.TPIKCache.l_forearm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
    end

    debugoverlay.Line(ply_l_shoulder_matrix:GetTranslation(), ply_l_upperarm_pos, 0.1, Color(255, 255, 255), true)
    debugoverlay.Line(ply_l_upperarm_pos, ply_l_forearm_pos, 0.1, Color(255, 255, 255), true)
    -- debugoverlay.Line(ply_l_forearm_pos, ply_l_hand_matrix:GetTranslation(), 0.1, Color(255, 255, 255), true)

    -- ply_l_shoulder_matrix:SetTranslation(ply_l_upperarm_pos)
    ply_l_hand_matrix:SetTranslation(ply_l_forearm_pos)
    ply_l_elbow_matrix:SetTranslation(ply_l_upperarm_pos)

    if ply_l_HELPERelbow_matrix then ply_l_HELPERelbow_matrix:SetTranslation(ply_l_forearm_pos) end
    if ply_l_bicep_matrix then ply_l_bicep_matrix:SetTranslation(ply_l_forearm_pos) end
    if ply_l_ulna_matrix then ply_l_ulna_matrix:SetTranslation(ply_l_forearm_pos) end
    if ply_l_wrist_matrix then ply_l_wrist_matrix:SetTranslation(ply_l_forearm_pos) end

    if ply_r_HELPERelbow_matrix then ply_r_HELPERelbow_matrix:SetTranslation(ply_r_forearm_pos) end
    if ply_r_bicep_matrix then ply_r_bicep_matrix:SetTranslation(ply_r_forearm_pos) end
    if ply_r_ulna_matrix then ply_r_ulna_matrix:SetTranslation(ply_r_forearm_pos) end
    if ply_r_wrist_matrix then ply_r_wrist_matrix:SetTranslation(ply_r_forearm_pos) end

    -- print(ply:GetBoneName(ply_l_ulna_index), ply:GetBoneName(ply_l_wrist_index))

    local ply_l_shoulder_angle = (ply_l_upperarm_pos - ply_l_shoulder_matrix:GetTranslation()):GetNormalized():Angle()
    ply_l_shoulder_angle.r = -45
    ply_l_shoulder_matrix:SetAngles(ply_l_shoulder_angle)

    local ply_l_elbow_angle = (ply_l_forearm_pos - ply_l_upperarm_pos):GetNormalized():Angle()
    ply_l_elbow_angle.r = -90
    ply_l_elbow_matrix:SetAngles(ply_l_elbow_angle)

    if ply_l_HELPERelbow_index then ply:SetBoneMatrix(ply_l_HELPERelbow_index, ply_l_elbow_matrix) end
    if ply_l_bicep_index then ply:SetBoneMatrix(ply_l_bicep_index, ply_l_shoulder_matrix) end
    if ply_l_ulna_index then ply:SetBoneMatrix(ply_l_ulna_index, ply_l_hand_matrix) end
    if ply_l_wrist_index then ply:SetBoneMatrix(ply_l_wrist_index, ply_l_hand_matrix) end

    if ply_r_HELPERelbow_index then ply:SetBoneMatrix(ply_r_HELPERelbow_index, ply_r_elbow_matrix) end
    if ply_r_bicep_index then ply:SetBoneMatrix(ply_r_bicep_index, ply_r_shoulder_matrix) end
    if ply_r_ulna_index then ply:SetBoneMatrix(ply_r_ulna_index, ply_r_hand_matrix) end
    if ply_r_wrist_index then ply:SetBoneMatrix(ply_r_wrist_index, ply_r_hand_matrix) end

    ply:SetBoneMatrix(ply_l_hand_index, ply_l_hand_matrix)
    ply:SetBoneMatrix(ply_l_elbow_index, ply_l_elbow_matrix)
    ply:SetBoneMatrix(ply_l_shoulder_index, ply_l_shoulder_matrix)
end
