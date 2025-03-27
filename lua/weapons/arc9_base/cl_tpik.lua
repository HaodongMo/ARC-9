-- third person inverse kinematics

local arc9_tpik = GetConVar("arc9_tpik")
local arc9_tpik_others = GetConVar("arc9_tpik_others")
local arc9_tpik_framerate = GetConVar("arc9_tpik_framerate")

local somevector3 = Vector(-1, -1, 1)
local somevector4 = Vector(0, 2, 4)
local someang = Angle(3, -3, -8)
local forcednotpik = ARC9.NoTPIK

function SWEP:ShouldTPIK()
    if self.NoTPIK or forcednotpik then return end
    local owner = self:GetOwner()
    local lp = LocalPlayer()

    if render.GetDXLevel() < 90 then return end
    if !owner:IsPlayer() then return end
    if owner:IsPlayingTaunt() then return end
    if owner:InVehicle() and !owner:GetAllowWeaponsInVehicle() then return end
    if owner.ARC9_HoldingProp then return end
    if !self.MirrorVMWM then return end
    if self:ShouldLOD() == 2 then return end
    -- if self:GetSafe() then return end
    -- if self:GetBlindFireAmount() > 0 then return false end
    if lp == owner and !owner:ShouldDrawLocalPlayer() then return end
    -- if !arc9_tpik:GetBool() then return false end

    local should = false

    if lp != owner then
        should = arc9_tpik:GetBool() and arc9_tpik_others:GetBool()
    else
        should = arc9_tpik:GetBool()
    end
    
    if self:RunHook("Hook_BlockTPIK") then should = false end

    local wm = self:GetWM()
    if IsValid(wm) and wm.slottbl then
        wm.slottbl.Pos = (should and self.WorldModelOffset.TPIKPos) or self.WorldModelOffset.Pos
        wm.slottbl.Ang = (should and self.WorldModelOffset.TPIKAng) or self.WorldModelOffset.Ang

        if should then
            if self.WorldModelOffset.TPIKPosAlternative and self:GetValue("TPIKAlternativePos") then
                wm.slottbl.Pos = self.WorldModelOffset.TPIKPosAlternative
            end

            if self.WorldModelOffset.TPIKPosSightOffset then
                local sightdelta = self:GetSightAmount()

                if sightdelta > 0 then
                    -- sightdelta = self:GetInSights() and math.ease.OutBack(sightdelta) or math.ease.InBack(sightdelta) -- InOutBack
                    local sightdelta2 = math.ease.InOutCubic(sightdelta)
                    wm.slottbl.Pos = wm.slottbl.Pos + self.WorldModelOffset.TPIKPosSightOffset * sightdelta2
                    wm.slottbl.Ang = wm.slottbl.Ang + someang * math.sin(3.1415926 * math.ease.InOutSine(sightdelta))

                    
                    if lp == owner then -- peeking is clientside
                        self.PeekingSmooth = Lerp(FrameTime() * 2, self.PeekingSmooth or 0, self.Peeking and 1 or 0)
                        if self.PeekingSmooth > 0.1 then
                            wm.slottbl.Pos = wm.slottbl.Pos + somevector4 * sightdelta * self.PeekingSmooth
                            wm.slottbl.Ang = wm.slottbl.Ang + self.PeekAng * sightdelta * self.PeekingSmooth
                        end
                    end
                end

                if self.WorldModelOffset.TPIKPosReloadOffset then
                    -- self.GetReloadingSmooth = Lerp(FrameTime() * 2, self.GetReloadingSmooth or 0, self:GetReloading() and 1 or 0)
                    -- if self.GetReloadingSmooth > 0.1 then
                    --     wm.slottbl.Pos = wm.slottbl.Pos + self.WorldModelOffset.TPIKPosReloadOffset * self.GetReloadingSmooth
                    -- end
            
                    if self:GetReloading() and !self:GetProcessedValue("ShotgunReload", true) then -- reused from reloadpos vm code
                        local fuckingreloadprocessinfluence = 1
                        local fuckingreloadprocess = math.Clamp(1 - (self:GetReloadFinishTime() - CurTime()) / (self.ReloadTime * self:GetAnimationTime("reload")), 0, 1)
                        if fuckingreloadprocess <= 0.1 then
                            fuckingreloadprocessinfluence = fuckingreloadprocess * 10
                        elseif fuckingreloadprocess > 0.75 then
                            fuckingreloadprocessinfluence = math.max(0, 1 - ((fuckingreloadprocess - 0.75) * 8))
                        end
                        
                        fuckingreloadprocessinfluence = math.ease.InCirc(fuckingreloadprocessinfluence)

                        wm.slottbl.Pos = wm.slottbl.Pos + self.WorldModelOffset.TPIKPosReloadOffset * fuckingreloadprocessinfluence
                        wm.slottbl.Ang = wm.slottbl.Ang + self.WorldModelOffset.TPIKAngReloadOffset * fuckingreloadprocessinfluence
                    end
                end
            end

            if lp == owner and self.CustomizeDelta == 0 then
                if !self.NoTPIKVMPos then
                    wm.slottbl.Pos = wm.slottbl.Pos - self.ViewModelPos * somevector3
                    wm.slottbl.Ang = wm.slottbl.Ang + Angle(self.ViewModelAng.p, -self.ViewModelAng.y, self.ViewModelAng.r)
                end
            end
        end
    end

    return should
end

SWEP.TPIKCache = {}
SWEP.LastTPIKTime = 0

local cachelastcycle = 0 -- probably bad

local headcontrol = {"ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Head1"}

function SWEP:DoTPIK()
    local wm = self:GetWM()

    if !IsValid(wm) then return end

    local everythingfucked = false

    if wm:GetPos():IsZero() and self.wmnormalpos then -- VERY STUPID BUT SetupModel() on wm makes wm go to 0 0 0 BUT ONLY ON CERTAIN PLAYERMODELS???????
        wm:SetPos(self.wmnormalpos) 
        wm:SetAngles(self.wmnormalang)
        everythingfucked = true
    else 
        self.wmnormalpos = wm:GetPos()
        self.wmnormalang = wm:GetAngles()
    end
    
    if !self:ShouldTPIK() then
        if cachelastcycle > 0 then wm:SetCycle(0) cachelastcycle = 0 end
        return
     end

    local ply = self:GetOwner()

    local tpikdelay = 0

    local lod

    if ply != LocalPlayer() then
        local dist = EyePos():DistToSqr(ply:GetPos())

        local convartpiktime = arc9_tpik_framerate:GetFloat()
        convartpiktime = (convartpiktime == 0) and 250 or math.Clamp(convartpiktime, 5, 250)
        tpikdelay = 1 / convartpiktime

        lod = self:ShouldLOD()

        if lod == 1 then
            tpikdelay = math.max(0.05, tpikdelay)  -- max 20 fps if lodding
        elseif lod == 1.5 then
            tpikdelay = math.max(0.1, tpikdelay)
        end
    end

    local shouldfulltpik = true

    if self.LastTPIKTime + tpikdelay > CurTime() then
        shouldfulltpik = false
    end

    local nolefthand = false

    local htype = self:GetHoldType()

    if !self.TPIKforcelefthand and !self.NotAWeapon and !(self:GetReloading() and !self.TPIKforcenoreload) and (htype == "slam" or htype == "magic" or htype == "pistol"  or htype == "normal" or self.TPIKnolefthand) then
        nolefthand = true
    end

    if ply:IsTyping() then nolefthand = true end
    if ply:GetNW2Int("CurrentCustomGesture", 0) > 0 then nolefthand = true end -- custom thing

    if shouldfulltpik then
        wm:SetupBones()

        local time = self:GetSequenceCycle()
        local seq = self:GetSequenceIndex()

        if self:GetSequenceProxy() != 0 then seq = wm:LookupSequence("idle") end -- lhik ubgls fix
        
        if self.TPIKNoSprintAnim and self:GetIsSprinting() then seq = wm:LookupSequence("idle") end -- no sprint anim in tpik (less ugly)

        wm:SetSequence(seq)

        wm:SetCycle(time)
        cachelastcycle = time

        wm:InvalidateBoneCache()
    end

    if !everythingfucked then self:DoRHIK(true) end

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

    local headcam = self:GetCameraControl(wm)
    if IsValid(headcam) then
        for _, bone in ipairs(headcontrol) do
            local ply_boneindex = ply:LookupBone(bone)
            if !ply_boneindex then continue end
            local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
            if !ply_bonematrix then continue end
    
            local boneang = ply_bonematrix:GetAngles()
            boneang:Add(headcam)
    
            ply_bonematrix:SetAngles(boneang)
    
            ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
        end
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
    if ply_l_wrist_index and !ply:BoneHasFlag(ply_l_wrist_index, 524032) then ply_l_wrist_index = nil end
    if ply_r_wrist_index and !ply:BoneHasFlag(ply_r_wrist_index, 524032) then ply_r_wrist_index = nil end

    if !ply_l_shoulder_index then return end
    if !ply_r_shoulder_index then return end
    if !ply_l_elbow_index then return end
    if !ply_r_elbow_index then return end
    if !ply_l_hand_index then return end
    if !ply_r_hand_index then return end

    local ply_r_shoulder_matrix = ply:GetBoneMatrix(ply_r_shoulder_index)
    local ply_r_elbow_matrix = ply:GetBoneMatrix(ply_r_elbow_index)
    local ply_r_hand_matrix = ply:GetBoneMatrix(ply_r_hand_index)

    local limblength = ply:BoneLength(ply_l_elbow_index)
    if !limblength or limblength == 0 then limblength = 12 end

    local r_upperarm_length = limblength
    local r_forearm_length = limblength
    local l_upperarm_length = limblength
    local l_forearm_length = limblength

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

    -- if ARC9.Dev(2) then
        -- debugoverlay.Line(ply_r_shoulder_matrix:GetTranslation(), ply_r_upperarm_pos, 0.1)
        -- debugoverlay.Line(ply_r_upperarm_pos, ply_r_forearm_pos, 0.1)
        -- debugoverlay.Line(ply_r_forearm_pos, ply_r_hand_matrix:GetTranslation(), 0.1)
    -- end
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

    if shouldfulltpik or !(self.TPIKCache.l_upperarm_pos and self.TPIKCache.l_forearm_pos) then
        ply_l_upperarm_pos, ply_l_forearm_pos = self:Solve2PartIK(ply_l_shoulder_matrix:GetTranslation(), ply_l_hand_matrix:GetTranslation(), l_upperarm_length, l_forearm_length, 35)

        self.LastTPIKTime = CurTime()
        self.TPIKCache.l_upperarm_pos = WorldToLocal(ply_l_upperarm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
        self.TPIKCache.l_forearm_pos = WorldToLocal(ply_l_forearm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
    else
        ply_l_upperarm_pos = LocalToWorld(self.TPIKCache.l_upperarm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
        ply_l_forearm_pos = LocalToWorld(self.TPIKCache.l_forearm_pos, angle_zero, ply_l_shoulder_matrix:GetTranslation(), ply_l_shoulder_matrix:GetAngles())
    end

    -- if ARC9.Dev(2) then
        -- debugoverlay.Line(ply_l_shoulder_matrix:GetTranslation(), ply_l_upperarm_pos, 0.1, Color(255, 255, 255), true)
        -- debugoverlay.Line(ply_l_upperarm_pos, ply_l_forearm_pos, 0.1, Color(255, 255, 255), true)
        -- debugoverlay.Line(ply_l_forearm_pos, ply_l_hand_matrix:GetTranslation(), 0.1, Color(255, 255, 255), true)
    -- end

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
