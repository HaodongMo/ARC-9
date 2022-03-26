SWEP.ThirdArmModel = nil
SWEP.ThirdArmAnimationTime = 0
SWEP.ThirdArmAnimationLength = 0
SWEP.ThirdArmAnimation = {}
SWEP.ThirdArmPersist = false

SWEP.ThirdArmGunOffsetPos = Vector(0, 0, 0)
SWEP.ThirdArmGunOffsetAngle = Angle(0, 0, 0)

SWEP.ThirdArmCamOffsetPos = Vector(0, 0, 0)
SWEP.ThirdArmCamOffsetAngle = Angle(0, 0, 0)

-- local tbl = {
--     rig = "path/to/model.mdl",
--     sequence = "sequence",
--     mult = 1,
--     invisible = false,
--     gun_controller_attachment = 1,
--     cam_controller_attachment = 2,
--     offsetang = Angle(0, 0, 0),
--     timeline = {
--         {
--             t = 0,
--             lhik = 0,
--             rhik = 0.2
--         },
--         {
--             t = 0.5,
--             lhik = 1,
--         },
--         {
--             t = 1,
--             lhik = 0
--         }
--     },
--     soundtable = {}
-- }

local function qerp(delta, a, b)
    local qdelta = -(delta ^ 2) + (delta * 2)

    qdelta = math.Clamp(qdelta, 0, 1)

    return Lerp(qdelta, a, b)
end

function SWEP:PlayThirdArmAnim(tbl, persist)
    local rig = tbl.rig

    -- if !self.ThirdArmModel or tbl.rig != (self.ThirdArmAnimation or {}).rig then
        if self.ThirdArmModel then
            SafeRemoveEntity(self.ThirdArmModel)
        end
        self.ThirdArmModel = ClientsideModel(rig)
    -- end

    if !self.ThirdArmModel then return end

    local seq = self.ThirdArmModel:LookupSequence(tbl.sequence)
    self.ThirdArmModel:ResetSequence(seq)

    -- if tbl.invisible then
        self.ThirdArmModel:SetNoDraw(true)
    -- end

    local mult = tbl.mult or 1

    self.ThirdArmModel:SetPlaybackRate(mult)

    self.ThirdArmAnimation = tbl
    self.ThirdArmAnimationTime = CurTime()
    self.ThirdArmAnimationLength = math.abs(self.ThirdArmModel:SequenceDuration() / self.ThirdArmModel:GetPlaybackRate())

    self.ThirdArmPersist = persist

    self.ThirdArmModel:SetPos(ARC9_VECTORZERO)
    self.ThirdArmModel:SetAngles(ARC9_ANGLEZERO)

    self.ThirdArmModel:SetupBones()
    self.ThirdArmModel:InvalidateBoneCache()

    if tbl.gun_controller_attachment != nil then
        local posang = self.ThirdArmModel:GetAttachment(tbl.gun_controller_attachment)
        self.ThirdArmGunOffsetAngle:Set(posang.Ang)
        self.ThirdArmGunOffsetPos:Set(posang.Pos)
    end

    if tbl.cam_controller_attachment != nil then
        local posang = self.ThirdArmModel:GetAttachment(tbl.cam_controller_attachment)
        self.ThirdArmCamOffsetAngle:Set(posang.Ang)
        self.ThirdArmCamOffsetPos:Set(posang.Pos)
    end

    if tbl.soundtable then
        self:PlaySoundTable(tbl.soundtable, mult)
    end

    self.ThirdArmModel:SetPos(EyePos())
    self.ThirdArmModel:SetAngles(EyeAngles())
end

function SWEP:PreDrawThirdArm()
    if self.ThirdArmModel then
        self.ThirdArmModel:SetPos(EyePos())
        self.ThirdArmModel:SetAngles(EyeAngles())

        local iket = self.ThirdArmAnimationLength
        local iklt = math.Clamp((CurTime() - self.ThirdArmAnimationTime) / iket, 0, 1)
        self.ThirdArmModel:SetCycle(iklt)

        if !self.ThirdArmAnimation.invisible then
            self.ThirdArmModel:DrawModel()
        end
    end
end

function SWEP:ThinkThirdArm()
    if self.ThirdArmModel then
        if (!self.ThirdArmPersist) and (self.ThirdArmAnimationTime + self.ThirdArmAnimationLength < CurTime()) then
            SafeRemoveEntity(self.ThirdArmModel)
            self.ThirdArmModel = nil
        end
    end
end

function SWEP:LHIKThirdArm()
    -- local vm = self:GetOwner():GetHands()
    local vm = self:GetVM()

    if !IsValid(vm) then return end
    if !self.UseHands then return end

    -- vm:SetupBones()

    local lh_delta = 1
    local rh_delta = 1

    local iktl = self.ThirdArmAnimation.timeline

    if !iktl then return end

    local iket = self.ThirdArmAnimationLength
    local iklt = math.Clamp((CurTime() - self.ThirdArmAnimationTime) / iket, 0, 1)

    if iktl then
        local next_stage_index

        for i, k in ipairs(iktl) do
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

        local next_stage_index

        for i, k in ipairs(iktl) do
            if !k or !k.t then continue end
            if k.t > iklt then
                next_stage_index = i
                break
            end
        end

        if next_stage_index then
            if next_stage_index == 1 then
                -- we are on the first stage.
                stage = {t = 0, rhik = 0}
                next_stage = iktl[next_stage_index]
            else
                stage = iktl[next_stage_index - 1]
                next_stage = iktl[next_stage_index]
            end
        else
            stage = iktl[#iktl]
            next_stage = {t = iket, rhik = iktl[#iktl].rhik}
        end

        local local_time = iklt

        local delta_time = next_stage.t - stage.t
        delta_time = (local_time - stage.t) / delta_time

        delta_time = math.ease.InOutQuart(delta_time)

        rh_delta = qerp(delta_time, stage.rhik, next_stage.rhik)
    end

    local rhik_model = self.ThirdArmModel

    if rhik_model then
        rhik_model:SetupBones()
        for _, bone in ipairs(ARC9.RHIKBones) do
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

    local lhik_model = self.ThirdArmModel

    if lhik_model then
        lhik_model:SetupBones()
        for _, bone in ipairs(ARC9.LHIKBones) do
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
end

function SWEP:CamThirdArm()
end

function SWEP:GunControllerThirdArm(pos, ang)
    if (self.ThirdArmAnimationTime + self.ThirdArmAnimationLength) < CurTime() then return pos, ang end

    if self.ThirdArmModel and self.ThirdArmAnimation.gun_controller_attachment != nil then
        local posang = self.ThirdArmModel:GetAttachment(self.ThirdArmAnimation.gun_controller_attachment)

        local offset_pos, offset_ang = WorldToLocal(posang.Pos, posang.Ang, EyePos(), EyeAngles() + (self.ThirdArmAnimation.offsetang or Angle(0, 0, 0)))

        -- offset_pos = offset_pos - self.ThirdArmGunOffsetPos
        -- offset_ang = offset_ang - self.ThirdArmGunOffsetAngle

        offset_pos, offset_ang = WorldToLocal(offset_pos, offset_ang, self.ThirdArmGunOffsetPos, self.ThirdArmGunOffsetAngle - (self.ThirdArmAnimation.offsetang or Angle(0, 0, 0)))

        -- print(offset_pos)

        pos, ang = LocalToWorld(offset_pos, offset_ang, pos, ang)

        return pos, ang
    end

    return pos, ang
end