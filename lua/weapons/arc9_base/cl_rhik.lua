local function qerp(delta, a, b)
    local qdelta = -(delta ^ 2) + (delta * 2)

    qdelta = math.Clamp(qdelta, 0, 1)

    return Lerp(qdelta, a, b)
end

local lhik_ts_delta = 0

function SWEP:DoRHIK()
    -- local vm = self:GetOwner():GetHands()
    local vm = self:GetVM()

    if !IsValid(vm) then return end
    if !self.UseHands then return end

    vm:SetupBones()

    local lh_delta = 1
    local rh_delta = 1

    local lhik_bf_d = self:GetBlindFireAmount() - self:GetBlindFireCornerAmount()

    local hide_lh_d = 0
    local hide_rh_d = 0

    hide_lh_d = math.max(lhik_bf_d, self.CustomizeDelta)
    hide_rh_d = self.CustomizeDelta

    hide_lh_d = math.ease.InCubic(hide_lh_d)
    hide_rh_d = math.ease.InCubic(hide_rh_d)

    local iktl = (self.Animations[self:GetIKAnimation() or ""] or {}).IKTimeLine
    local iket = self:GetIKTime()
    local iklt = math.Clamp((CurTime() - self:GetIKTimeLineStart()) / iket, 0, 1)

    if iktl then
        if self:GetProcessedValue("LHIK") then
            local next_stage_index

            for i, k in pairs(iktl) do
                if !k or !k.t then continue end
                if k.t > iklt then
                    next_stage_index = i
                    break
                end
            end

            if next_stage_index then
                if next_stage_index == 1 then
                    -- we are on the first stage.
                    stage = {t = 0, lhik = 0}
                    next_stage = iktl[next_stage_index]
                else
                    stage = iktl[next_stage_index - 1]
                    next_stage = iktl[next_stage_index]
                end
            else
                stage = iktl[#iktl]
                next_stage = {t = iket, lhik = iktl[#iktl].lhik}
            end

            local local_time = iklt

            local delta_time = next_stage.t - stage.t
            delta_time = (local_time - stage.t) / delta_time

            delta_time = math.ease.InOutQuart(delta_time)

            lh_delta = qerp(delta_time, stage.lhik, next_stage.lhik)
        end

        if self:GetProcessedValue("RHIK") then
            local next_stage_index

            for i, k in pairs(iktl) do
                if !k or !k.t then continue end
                if k.t > iklt then
                    next_stage_index = i
                    break
                end
            end

            if next_stage_index then
                if next_stage_index == 1 then
                    -- we are on the first stage.
                    stage = {t = 0, lhik = 0}
                    next_stage = iktl[next_stage_index]
                else
                    stage = iktl[next_stage_index - 1]
                    next_stage = iktl[next_stage_index]
                end
            else
                stage = iktl[#iktl]
                next_stage = {t = iket, lhik = iktl[#iktl].rhik}
            end

            local local_time = iklt

            local delta_time = next_stage.t - stage.t
            delta_time = (local_time - stage.t) / delta_time

            delta_time = math.ease.InOutQuart(delta_time)

            lh_delta = qerp(delta_time, stage.rhik, next_stage.rhik)
        end
    end

    local rhik_model = self.RHIKModel

    if rhik_model then
        rhik_model:SetupBones()
        for _, bone in pairs(ARC9.RHIKBones) do
            local vm_bone = vm:LookupBone(bone)
            local target_bone = rhik_model:LookupBone(bone)

            if !vm_bone or !target_bone then continue end

            local vm_bone_matrix = vm:GetBoneMatrix(vm_bone)
            local target_bone_matrix = rhik_model:GetBoneMatrix(target_bone)

            local lerped_pos = LerpVector(rh_delta, vm_bone_matrix:GetTranslation(), target_bone_matrix:GetTranslation())
            local lerped_ang = LerpAngle(rh_delta, vm_bone_matrix:GetAngles(), target_bone_matrix:GetAngles())

            local newtransform = Matrix()
            newtransform:SetTranslation(lerped_pos)
            newtransform:SetAngles(lerped_ang)

            local matrix = Matrix(newtransform)

            vm:SetBoneMatrix(vm_bone, matrix)
        end
    end

    local lhik_model = self.LHIKModel

    if lhik_model then
        lhik_model:SetupBones()
        for _, bone in pairs(ARC9.LHIKBones) do
            local vm_bone = vm:LookupBone(bone)
            local target_bone = lhik_model:LookupBone(bone)

            if !vm_bone or !target_bone then continue end

            local vm_bone_matrix = vm:GetBoneMatrix(vm_bone)
            local target_bone_matrix = lhik_model:GetBoneMatrix(target_bone)

            local lerped_pos = LerpVector(lh_delta, vm_bone_matrix:GetTranslation(), target_bone_matrix:GetTranslation())
            local lerped_ang = LerpAngle(lh_delta, vm_bone_matrix:GetAngles(), target_bone_matrix:GetAngles())

            local newtransform = Matrix()
            newtransform:SetTranslation(lerped_pos)
            newtransform:SetAngles(lerped_ang)

            vm:SetBoneMatrix(vm_bone, newtransform)
        end
    end

    local rupperarm, rforearm, rulna, rwrist, rhand = vm:LookupBone("ValveBiped.Bip01_R_UpperArm"), vm:LookupBone("ValveBiped.Bip01_R_Forearm"), vm:LookupBone("ValveBiped.Bip01_R_Ulna"), vm:LookupBone("ValveBiped.Bip01_R_Wrist"), vm:LookupBone("ValveBiped.Bip01_R_Hand")
    local lupperarm, lforearm, lulna, lwrist, lhand = vm:LookupBone("ValveBiped.Bip01_L_UpperArm"), vm:LookupBone("ValveBiped.Bip01_L_Forearm"), vm:LookupBone("ValveBiped.Bip01_L_Ulna"), vm:LookupBone("ValveBiped.Bip01_L_Wrist"), vm:LookupBone("ValveBiped.Bip01_L_Hand")

    local rupperarm_matrix, rhand_matrix = vm:GetBoneMatrix(rupperarm), vm:GetBoneMatrix(rhand)
    local lupperarm_matrix, lhand_matrix = vm:GetBoneMatrix(lupperarm), vm:GetBoneMatrix(lhand)
    local rforearm_matrix = vm:GetBoneMatrix(rforearm)
    local lforearm_matrix = vm:GetBoneMatrix(lforearm)
    local rarm_start, rhand_end = rupperarm_matrix:GetTranslation(), rhand_matrix:GetTranslation()
    local larm_start, lhand_end = lupperarm_matrix:GetTranslation(), lhand_matrix:GetTranslation()

    local rupperarm_length, rarm_length = vm:BoneLength(rupperarm), vm:BoneLength(rforearm)
    if rupperarm_length > 15 or rarm_length > 15 or rupperarm_length < 5 or rarm_length < 5 then
        rupperarm_length = 8
        rarm_length = 8
    end
    local lupperarm_length, larm_length = vm:BoneLength(lupperarm), vm:BoneLength(lforearm)
    if lupperarm_length > 15 or larm_length > 15 or lupperarm_length < 5 or larm_length < 5 then
        lupperarm_length = 8
        larm_length = 8
    end

    -- lupperarm_length = lupperarm_length + 2
    -- larm_length = larm_length + 2

    rupperarm_matrix, rhand_matrix = vm:GetBoneMatrix(rupperarm), vm:GetBoneMatrix(rhand)
    lupperarm_matrix, lhand_matrix = vm:GetBoneMatrix(lupperarm), vm:GetBoneMatrix(lhand)

    rarm_start = rupperarm_matrix:GetTranslation()
    larm_start = lupperarm_matrix:GetTranslation()

    local rupperarm_position, rforearm_position = self:Solve2PartIK(rarm_start, rhand_end, rupperarm_length , rarm_length, -35)
    local lupperarm_position, lforearm_position = self:Solve2PartIK(larm_start, lhand_end, lupperarm_length , larm_length, 35)

    debugoverlay.Line(rarm_start, rupperarm_position, 0.1, Color( 255, 255, 255 ), true)
    debugoverlay.Line(rforearm_position, rupperarm_position, 0.1, Color( 255, 255, 255 ), true)
    debugoverlay.Line(rforearm_position, rhand_end, 0.1, Color( 255, 255, 255 ), true)

    debugoverlay.Line(larm_start, lupperarm_position, 0.1, Color( 255, 255, 255 ), true)
    debugoverlay.Line(lforearm_position, lupperarm_position, 0.1, Color( 255, 255, 255 ), true)
    debugoverlay.Line(lforearm_position, lhand_end, 0.1, Color( 255, 255, 255 ), true)

    -- rupperarm_matrix:SetTranslation(rupperarm_position)
    -- brought to you by: https://rubberduckdebugging.com/
    -- get one today!
    -- right

    local enable_ik = false

    if self:GetValue("RHIK") and enable_ik then
        local rupperarm_dir = (rupperarm_position - rupperarm_matrix:GetTranslation())
        rupperarm_matrix:SetAngles(rupperarm_dir:Angle())
        local rupperarm_norm = (rupperarm_position-rarm_start)
        rupperarm_norm:Normalize()
        rupperarm_matrix:SetTranslation(rarm_start - rupperarm_norm * 4)

        local rforearm_norm = (rforearm_position-rforearm_matrix:GetTranslation())
        rforearm_norm:Normalize()
        rforearm_matrix:SetTranslation(rupperarm_position + rforearm_norm * 2)
        local rforearm_dir = rhand_end - rupperarm_position
        rforearm_matrix:SetAngles(rforearm_dir:Angle())

        vm:SetBoneMatrix(rupperarm, rupperarm_matrix)
        vm:SetBoneMatrix(rforearm, rforearm_matrix)

        if rulna and rwrist then
            local rwrist_matrix = vm:GetBoneMatrix(rwrist)
            local rulna_matrix = vm:GetBoneMatrix(rulna)

            local rwrist_angle = (rwrist_matrix:GetTranslation() - rupperarm_position):Angle()
            rwrist_matrix:SetAngles(rwrist_angle)
            vm:SetBoneMatrix(rwrist, rwrist_matrix)

            -- rwrist_angle.r = rwrist_matrix:GetAngles().r + 90

            rulna_matrix:SetTranslation(rwrist_matrix:GetTranslation() - (rwrist_angle:Forward() * 4))
            rulna_matrix:SetAngles(rwrist_angle)
            vm:SetBoneMatrix(rulna, rulna_matrix)
        end
    end

    -- brought to you by: https://rubberduckdebugging.com/
    -- get one today!
    -- left
    if self:GetValue("LHIK") and enable_ik then
        local lupperarm_dir = (lupperarm_position - lupperarm_matrix:GetTranslation())
        lupperarm_matrix:SetAngles(lupperarm_dir:Angle())
        local lupperarm_norm = (lupperarm_position-larm_start)
        lupperarm_norm:Normalize()
        lupperarm_matrix:SetTranslation(larm_start - (lupperarm_norm * 0))

        local lforearm_norm = (lforearm_position-lforearm_matrix:GetTranslation())
        lforearm_norm:Normalize()
        lforearm_matrix:SetTranslation(lupperarm_position + (lforearm_norm * 0))
        local lforearm_dir = lhand_end - lupperarm_position
        lforearm_matrix:SetAngles(lforearm_dir:Angle())

        vm:SetBoneMatrix(lupperarm, lupperarm_matrix)
        vm:SetBoneMatrix(lforearm, lforearm_matrix)

        if lulna and lwrist then
            local lwrist_matrix = vm:GetBoneMatrix(lwrist)
            local lulna_matrix = vm:GetBoneMatrix(lulna)

            local lwrist_angle = (lwrist_matrix:GetTranslation() - lupperarm_position):Angle()
            lwrist_matrix:SetTranslation(lwrist_matrix:GetTranslation())
            lwrist_matrix:SetAngles(lwrist_angle)
            vm:SetBoneMatrix(lwrist, lwrist_matrix)

            -- lwrist_angle.r = lwrist_matrix:GetAngles().r + 90

            lulna_matrix:SetTranslation(lwrist_matrix:GetTranslation() - (lwrist_angle:Forward() * 4))
            lulna_matrix:SetAngles(lwrist_angle)
            vm:SetBoneMatrix(lulna, lulna_matrix)
        end
    end

    if hide_lh_d > 0 then
        for _, bone in ipairs(ARC9.LHIKBones) do
            local vmbone = vm:LookupBone(bone)

            if !vmbone then continue end -- Happens when spectating someone prolly

            local vmtransform = vm:GetBoneMatrix(vmbone)

            if !vmtransform then continue end -- something very bad has happened

            local vm_pos = vmtransform:GetTranslation()
            local vm_ang = vmtransform:GetAngles()

            local newtransform = Matrix()

            newtransform:SetTranslation(LerpVector(hide_lh_d, vm_pos, vm_pos - (EyeAngles():Up() * 48) - (EyeAngles():Forward() * 16)))
            newtransform:SetAngles(vm_ang)

            vm:SetBoneMatrix(vmbone, newtransform)
        end
    end

    if hide_rh_d > 0 then
        for _, bone in ipairs(ARC9.RHIKBones) do
            local vmbone = vm:LookupBone(bone)

            if !vmbone then continue end -- Happens when spectating someone prolly

            local vmtransform = vm:GetBoneMatrix(vmbone)

            if !vmtransform then continue end -- something very bad has happened

            local vm_pos = vmtransform:GetTranslation()
            local vm_ang = vmtransform:GetAngles()

            local newtransform = Matrix()

            newtransform:SetTranslation(LerpVector(hide_rh_d, vm_pos, vm_pos - (EyeAngles():Up() * 48) - (EyeAngles():Forward() * 16)))
            newtransform:SetAngles(vm_ang)

            vm:SetBoneMatrix(vmbone, newtransform)
        end
    end
end


// Written by and used with permission from AWholeCream
// start_p: Shoulder
// end_p: Hand
// length0: Shoulder to elbow
// length1: Elbow to hand
// rotation: rotates??? prevents chicken winging
function SWEP:Solve2PartIK(start_p, end_p, length0, length1, rotation)
    local circle = math.sqrt((end_p.x-start_p.x) ^ 2 + (end_p.y-start_p.y) ^ 2 )
    local length2 = math.sqrt(circle ^ 2 + (end_p.z-start_p.z) ^ 2 )
    local cosAngle0 = math.Clamp(((length2 * length2) + (length0 * length0) - (length1 * length1)) / (2 * length2 * length0), -1, 1)
    local angle0 = -math.deg(math.acos(cosAngle0))

    local cosAngle1 = math.Clamp(((length1 * length1) + (length0 * length0) - (length2 * length2)) / (2 * length1 * length0), -1, 1)
    local angle1 = -math.deg(math.acos(cosAngle1))

    local diff = end_p-start_p
    local angle2 = math.deg(math.atan2(-math.sqrt(diff.x ^ 2 + diff.y ^ 2), diff.z)) - 90
    local angle3 = -math.deg(math.atan2(diff.x, diff.y)) - 90

    local axis = diff * 1
    axis:Normalize()
    local Joint0 = Angle(angle0 + angle2,angle3,0)
    Joint0:RotateAroundAxis(axis,rotation)
    Joint0 = (Joint0:Forward() * length0)

    local Joint1 = Angle(angle0 + angle2 + 180 + angle1,angle3,0)
    Joint1:RotateAroundAxis(axis,rotation)
    Joint1 = (Joint1:Forward() * length1)

    local Joint0_F = start_p + Joint0
    local Joint1_F = Joint0_F + Joint1

    return Joint0_F, Joint1_F
end

// returns two vectors
// upper arm and forearm