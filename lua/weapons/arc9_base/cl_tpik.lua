-- third person inverse kinematics

local arc9_tpik = GetConVar("arc9_tpik")
local arc9_tpik_others = GetConVar("arc9_tpik_others")
local arc9_tpik_framerate = GetConVar("arc9_tpik_framerate")

local activeposvector = Vector(-1, -1, 1)
local peekvector = Vector(0, 2, 4)
local someangforsights = Angle(3, -3, -8)
local nearwallpos = Vector(1, 0, 18)
local nearwallang = Angle(-70, 0, 0)

local PlayerReanimsOffsets = {
    default = {
        passive = { Pos = Vector(-8, -1, -3) },
        normal = { Pos = Vector(-8, -1, 0) },
        crouch = { Pos = Vector(-3, 0, 2) },
        customization = { Pos = Vector(-5, 0, -5) }
    },

    csgo = {
        crouch = { Pos = Vector(-2, -3, 1) },
        revolver = { Pos = Vector(4.5, -3, -6) },
    },

    l4d = {
        passive = { Pos = Vector(-4, -1, -1) },
        normal = { Pos = Vector(-7, -1, 0) },
        crouch = { Pos = Vector(-5, 0, 1) },
        revolver = { Pos = Vector(3, -1, 1) },
    },

    payday2 = {
        active = { Pos = Vector(-1, -2, 0) },
        passive = { Pos = Vector(-2, 1, 2) },
        normal = { Pos = Vector(-7, 1, 0) },
        crouch = { Pos = Vector(-1, 0, 1) },
        revolver = { Pos = Vector(3.6, 2, 1) },
    },
}

local playeranimset = "default"

local xdrlist = { -- idk what else mods have custom anims
    ["3267580122"] = "payday2",
    ["2916762576"] = "l4d",
    ["2261825706"] = "csgo",
}

for _, addon in pairs(engine.GetAddons()) do
    if addon.mounted and xdrlist[tostring(addon.wsid)] then
        playeranimset = xdrlist[tostring(addon.wsid)]
    end
end

local function HasCustomOffset(holdtype)
    local animsetlocal = playeranimset
    if !PlayerReanimsOffsets[animsetlocal] or !PlayerReanimsOffsets[animsetlocal][holdtype] then animsetlocal = "default" end

    if PlayerReanimsOffsets[animsetlocal] then
        return PlayerReanimsOffsets[animsetlocal][holdtype]
    end

    return false
end

local function GetCustomOffset(holdtype)
    return HasCustomOffset(holdtype) and HasCustomOffset(holdtype).Pos
end


local forcednotpik = ARC9.NoTPIK
local Lerp = Lerp

local cached_children = {}

local function recursive_get_children(ent, bone, bones, endbone) -- evil recursive children hack (works only one time for each model)
    local bone = isstring(bone) and ent:LookupBone(bone) or bone

    if not bone or isstring(bone) or bone == -1 then return end
    
    local children = ent:GetChildBones(bone)
    if #children > 0 then
        local id
        for i = 1,#children do
            id = children[i]
            if id == endbone then continue end
            recursive_get_children(ent, id, bones, endbone)
            table.insert(bones, id)
        end
    end
end

local function get_children(ent, bone, endbone)
    local bones = {}

    local mdl = ent:GetModel()
    if cached_children[mdl] and cached_children[mdl][bone] then return cached_children[mdl][bone] end -- cache that shit or else...........

    recursive_get_children(ent, bone, bones, endbone)

    cached_children[mdl] = cached_children[mdl] or {}
    cached_children[mdl][bone] = bones

    return bones
end

local function bone_apply_matrix(ent, bone, new_matrix, endbone)
    local bone = isstring(bone) and ent:LookupBone(bone) or bone

    if not bone or isstring(bone) or bone == -1 then return end

    local matrix = ent:GetBoneMatrix(bone)
    if not matrix then return end
    local inv_matrix = matrix:GetInverse()
    if not inv_matrix then return end

    local children = get_children(ent, bone, endbone)
    
    local translate = (new_matrix * inv_matrix)
    local id
    for i = 1,#children do
        id = children[i]
        local mat = ent:GetBoneMatrix(id)
        if not mat then continue end
        ent:SetBoneMatrix(id, translate * mat) -- WTF
    end

    ent:SetBoneMatrix(bone, new_matrix)
end

local function SetTPIKOffset(self, wm, owner, lp)
    local pos, ang = Vector(self.WorldModelOffset.TPIKPos or self.WorldModelOffset.Pos), Angle(self.WorldModelOffset.TPIKAng or self.WorldModelOffset.Ang) -- how come you don't have tpikpos in 2025
    local sightdelta = self:GetSightAmount()

    if self.WorldModelOffset.TPIKPosAlternative and self:GetValue("TPIKAlternativePos") then
        pos = Vector(self.WorldModelOffset.TPIKPosAlternative)
    end

    if self.WorldModelOffset.TPIKPosSightOffset then
        if sightdelta > 0 then -- sight offset
            local sightdelta2 = math.ease.InOutCubic(sightdelta)
            pos:Add(self.WorldModelOffset.TPIKPosSightOffset * sightdelta2)
            ang:Add(someangforsights * math.sin(3.1415926 * math.ease.InOutSine(sightdelta)))
        end

        if self.WorldModelOffset.TPIKPosReloadOffset then
            local fuckingreloadprocessinfluence = self:GetReloadingProgress()
            if fuckingreloadprocessinfluence > 0 then    
                pos:Add(self.WorldModelOffset.TPIKPosReloadOffset * fuckingreloadprocessinfluence)
                ang:Add(self.WorldModelOffset.TPIKAngReloadOffset * fuckingreloadprocessinfluence)
            end
        end
    end

    local ht = self:GetHoldType()
    
    if !DynamicHeightTwo then -- Dynamic height 2 breaks crouching 👍
        local viewOffsetZ = owner:GetViewOffset().z
        local crouchdelta = math.Clamp((viewOffsetZ - owner:GetCurrentViewOffset().z) / (viewOffsetZ - owner:GetViewOffsetDucked().z), 0, 1)
        if ht == "revolver" then crouchdelta = crouchdelta * -2
        elseif ht == "ar2" or ht == "smg" then crouchdelta = crouchdelta * -1 end
        if prone and owner:IsProne() then crouchdelta = 1 end
        if HasCustomOffset("crouch") then pos:Add(GetCustomOffset("crouch") * crouchdelta) end
    end

    do -- holdtype offsets
        self.TPIKSmoothPassiveHoldType = Lerp(FrameTime() * 1, self.TPIKSmoothPassiveHoldType or 0, ht == "passive" and 1 or 0)
        pos:Add(GetCustomOffset("passive") * self.TPIKSmoothPassiveHoldType)
        self.TPIKSmoothNormalHoldType = Lerp(FrameTime() * 1, self.TPIKSmoothNormalHoldType or 0, ht == "normal" and 1 or 0)
        pos:Add(GetCustomOffset("normal") * self.TPIKSmoothNormalHoldType)
        if self.WorldModelOffset.TPIKHolsterOffset then pos:Add(self.WorldModelOffset.TPIKHolsterOffset * self.TPIKSmoothNormalHoldType) end
        
        if HasCustomOffset("revolver") then
            self.TPIKSmoothRevolverHoldType = Lerp(FrameTime() * 1, self.TPIKSmoothRevolverHoldType or 0, ht == "revolver" and 1 or 0)
            pos:Add(GetCustomOffset("revolver") * self.TPIKSmoothRevolverHoldType)
        end

        if HasCustomOffset("active") then pos:Add(GetCustomOffset("active")) end
    end

    do -- nearwalling
        local nearwalldelta = self:GetNearWallAmount()

        if nearwalldelta > 0 and ht != "passive" and ht != "normal" then
            nearwalldelta = math.ease.InOutQuad(nearwalldelta) - self.CustomizeDelta
            pos:Add(nearwallpos * nearwalldelta)
            ang:Add(nearwallang * nearwalldelta)
        end
    end

    if !self.NoTPIKVMPos then -- and ht != "passive"
        if self.CustomizeDelta == 0 then
            -- if lp == owner then -- old
            --     pos:Sub(self.ViewModelPos * activeposvector)
            --     ang:Add(Angle(self.ViewModelAng.p, -self.ViewModelAng.y, self.ViewModelAng.r))
            -- else
                local apos = Vector(self.ActivePos.y, -self.ActivePos.x, self.ActivePos.z) * activeposvector
                pos:Sub(apos)


                if sightdelta > 0 then -- fake sights
                    local sightdelta2 = math.ease.InOutCubic(sightdelta)
                    local ispos = Vector(self.IronSights.Pos.x * -0.1, self.IronSights.Pos.y * 0.4, self.IronSights.Pos.z * 1.5)
                    pos:Sub(ispos * sightdelta2)
                    ang:Add(someangforsights * math.sin(3.1415926 * math.ease.InOutSine(sightdelta)))
                end
            -- end
        else
            pos:Add(GetCustomOffset("customization") * self.CustomizeDelta)
        end
    end

    if lp == owner then -- peeking is clientside
        self.PeekingSmooth = Lerp(FrameTime() * 2, self.PeekingSmooth or 0, self.Peeking and 1 or 0)
        if self.PeekingSmooth > 0.1 then
            pos:Add(peekvector * sightdelta * self.PeekingSmooth)
            ang:Add(self.PeekAng * sightdelta * self.PeekingSmooth)
        end

        if self.EFTErgo then -- only eft cuz this is not ideal
            -- visual recoil, cuz we don't add vm pos anymore
            local vrp, vra = self:GetVisualRecoilPos(), self:GetVisualRecoilAng() * 2.5
            self.TPIKSmoothRecoilPos = LerpVector(FrameTime() * 1, self.TPIKSmoothRecoilPos or vrp, Vector(-vrp.y, vrp.x, vrp.z * -10))
            self.TPIKSmoothRecoilAng = LerpVector(FrameTime() * 1, self.TPIKSmoothRecoilAng or vra, vra)
            pos:Sub(self.TPIKSmoothRecoilPos)
            ang:Add(Angle(-self.TPIKSmoothRecoilAng.x, self.TPIKSmoothRecoilAng.y, self.TPIKSmoothRecoilAng.z))
        end
    end

    wm.slottbl.Pos = pos
    wm.slottbl.Ang = ang
end

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
        if !should then
            wm.slottbl.Pos = self.WorldModelOffset.Pos
            wm.slottbl.Ang = self.WorldModelOffset.Ang
        else
            SetTPIKOffset(self, wm, owner, lp)
        end
    end

    return should
end

SWEP.TPIKCache = {}
SWEP.LastTPIKTime = 0

local cachelastcycle = 0 -- probably bad

-- local headcontrol = {"ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Head1"}

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
        if (htype == "normal" or htype == "passive") and (seq == wm:LookupSequence("draw") or seq == wm:LookupSequence("holster")) then seq = wm:LookupSequence("idle") end -- no draw/holster with some holdtypes. bad code but whatever.

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

    -- local headcam = self:GetCameraControl(wm)
    -- if IsValid(headcam) then
    --     for _, bone in ipairs(headcontrol) do
    --         local ply_boneindex = ply:LookupBone(bone)
    --         if !ply_boneindex then continue end
    --         local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
    --         if !ply_bonematrix then continue end
    
    --         local boneang = ply_bonematrix:GetAngles()
    --         boneang:Add(headcam)
    
    --         ply_bonematrix:SetAngles(boneang)
    
    --         ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
    --     end
    -- end
    
    local sightdelta = self:GetSightAmount()
    -- local reloadprogress = math.max(0, self:GetReloadingProgress() - sightdelta)
    self.TPIKReloadProgressSmooth = Lerp(FrameTime() * 10, self.TPIKReloadProgressSmooth or 0, self:GetReloading() and 1 - sightdelta or 0)

    if sightdelta > 0 or self.TPIKReloadProgressSmooth > 0.12 then
        local ply_boneindex = ply:LookupBone("ValveBiped.Bip01_Head1")
        if ply_boneindex then
            if #ply:GetChildBones(ply_boneindex) < 2 then -- dont move if more than 1 child bone on head
                local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
                if ply_bonematrix then
                    local boneang = ply_bonematrix:GetAngles()

                    boneang:Add(Angle(5, -15, 15) * sightdelta + Angle(9, -5, -2) * self.TPIKReloadProgressSmooth)

                    ply_bonematrix:SetAngles(boneang)

                    ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
                end
            end
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

    local ply_l_upperarm_index = ply:LookupBone("ValveBiped.Bip01_L_UpperArm")
    local ply_r_upperarm_index = ply:LookupBone("ValveBiped.Bip01_R_UpperArm")
    local ply_l_forearm_index = ply:LookupBone("ValveBiped.Bip01_L_Forearm")
    local ply_r_forearm_index = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
    local ply_l_hand_index = ply:LookupBone("ValveBiped.Bip01_L_Hand")
    local ply_r_hand_index = ply:LookupBone("ValveBiped.Bip01_R_Hand")

    if !ply_l_upperarm_index then return end
    if !ply_r_upperarm_index then return end
    if !ply_l_forearm_index then return end
    if !ply_r_forearm_index then return end
    if !ply_l_hand_index then return end
    if !ply_r_hand_index then return end

    local ply_r_upperarm_matrix = ply:GetBoneMatrix(ply_r_upperarm_index)
    local ply_r_forearm_matrix = ply:GetBoneMatrix(ply_r_forearm_index)
    local ply_r_hand_matrix = ply:GetBoneMatrix(ply_r_hand_index)

    local limblength = ply:BoneLength(ply_l_forearm_index)
    if !limblength or limblength == 0 then limblength = 12 end

    local r_upperarm_length = limblength
    local r_forearm_length = limblength
    local l_upperarm_length = limblength
    local l_forearm_length = limblength

    local ply_r_upperarm_pos, ply_r_forearm_pos, ply_r_upperarm_angle, ply_r_forearm_angle

    local eyeahg = ply:EyeAngles()

    if htype == "passive" or htype == "normal" then -- passive holdtype doesn't follow eyeang
        eyeahg.y = eyeahg.y - (ply:GetPoseParameter("aim_yaw") or 0) * 160 + 80 or 0
    end

    if shouldfulltpik then
        ply_r_upperarm_pos, ply_r_forearm_pos, ply_r_upperarm_angle, ply_r_forearm_angle = self:Solve2PartIK(ply_r_upperarm_matrix:GetTranslation(), ply_r_hand_matrix:GetTranslation(), r_upperarm_length, r_forearm_length, -1.3, eyeahg)
        self.LastTPIKTime = CurTime()

        self.TPIKCache.r_upperarm_pos, self.TPIKCache.ply_r_upperarm_angle = WorldToLocal(ply_r_upperarm_pos, ply_r_upperarm_angle, ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_matrix:GetAngles())
        self.TPIKCache.r_forearm_pos, self.TPIKCache.ply_r_forearm_angle = WorldToLocal(ply_r_forearm_pos, ply_r_forearm_angle, ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_matrix:GetAngles())
    else
        ply_r_upperarm_pos, ply_r_upperarm_angle = LocalToWorld(self.TPIKCache.r_upperarm_pos, self.TPIKCache.ply_r_upperarm_angle, ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_matrix:GetAngles())
        ply_r_forearm_pos, ply_r_forearm_angle = LocalToWorld(self.TPIKCache.r_forearm_pos, self.TPIKCache.ply_r_forearm_angle, ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_matrix:GetAngles())
    end

    -- play rain world!!!

    -- if ARC9.Dev(2) then
        -- debugoverlay.Line(ply_r_upperarm_matrix:GetTranslation(), ply_r_upperarm_pos, 0.1)
        -- debugoverlay.Line(ply_r_upperarm_pos, ply_r_forearm_pos, 0.1)
        -- debugoverlay.Line(ply_r_forearm_pos, ply_r_hand_matrix:GetTranslation(), 0.1)
    -- end

    ply_r_upperarm_matrix:SetAngles(ply_r_upperarm_angle)
    ply_r_forearm_matrix:SetTranslation(ply_r_upperarm_pos)
    ply_r_forearm_matrix:SetAngles(ply_r_forearm_angle)
    ply_r_hand_matrix:SetTranslation(ply_r_forearm_pos) -- weird shit with left hand??? idk cant figure, here's a bandaid

    bone_apply_matrix(ply, ply_r_upperarm_index, ply_r_upperarm_matrix, ply_r_forearm_index)
    bone_apply_matrix(ply, ply_r_forearm_index, ply_r_forearm_matrix, ply_r_hand_index)
    bone_apply_matrix(ply, ply_r_hand_index, ply_r_hand_matrix)

    if nolefthand then return end

    local ply_l_upperarm_matrix = ply:GetBoneMatrix(ply_l_upperarm_index)
    local ply_l_forearm_matrix = ply:GetBoneMatrix(ply_l_forearm_index)
    local ply_l_hand_matrix = ply:GetBoneMatrix(ply_l_hand_index)

    -- local ply_r_upperarm_pos = ply:LocalToWorld(self.TPIKCache.r_upperarm_pos)
    -- local ply_r_forearm_pos = ply:LocalToWorld(self.TPIKCache.r_forearm_pos)

    -- if shouldfulltpik then
    --     ply_r_upperarm_pos, ply_r_forearm_pos = self:Solve2PartIK(ply_r_upperarm_matrix:GetTranslation(), ply_r_hand_matrix:GetTranslation(), r_upperarm_length, r_forearm_length, -35)
    --     self.LastTPIKTime = CurTime()

    --     self.TPIKCache.r_upperarm_pos = ply:WorldToLocal(ply_r_upperarm_pos)
    --     self.TPIKCache.r_forearm_pos = ply:WorldToLocal(ply_r_forearm_pos)
    -- end

    local ply_l_upperarm_pos, ply_l_forearm_pos, ply_l_upperarm_angle, ply_l_forearm_angle

    if shouldfulltpik or !(self.TPIKCache.l_upperarm_pos and self.TPIKCache.l_forearm_pos and self.TPIKCache.ply_l_upperarm_angle and self.TPIKCache.ply_l_forearm_angle) then
        ply_l_upperarm_pos, ply_l_forearm_pos, ply_l_upperarm_angle, ply_l_forearm_angle = self:Solve2PartIK(ply_l_upperarm_matrix:GetTranslation(), ply_l_hand_matrix:GetTranslation(), l_upperarm_length, l_forearm_length, 1, eyeahg)

        self.LastTPIKTime = CurTime()
        self.TPIKCache.l_upperarm_pos, self.TPIKCache.ply_l_upperarm_angle = WorldToLocal(ply_l_upperarm_pos, ply_l_upperarm_angle, ply_l_upperarm_matrix:GetTranslation(), ply_l_upperarm_matrix:GetAngles())
        self.TPIKCache.l_forearm_pos, self.TPIKCache.ply_l_forearm_angle = WorldToLocal(ply_l_forearm_pos, ply_l_forearm_angle, ply_l_upperarm_matrix:GetTranslation(), ply_l_upperarm_matrix:GetAngles())
    else
        ply_l_upperarm_pos, ply_l_upperarm_angle = LocalToWorld(self.TPIKCache.l_upperarm_pos, self.TPIKCache.ply_l_upperarm_angle, ply_l_upperarm_matrix:GetTranslation(), ply_l_upperarm_matrix:GetAngles())
        ply_l_forearm_pos, ply_l_forearm_angle = LocalToWorld(self.TPIKCache.l_forearm_pos, self.TPIKCache.ply_l_forearm_angle, ply_l_upperarm_matrix:GetTranslation(), ply_l_upperarm_matrix:GetAngles())
    end

    ply_l_upperarm_matrix:SetAngles(ply_l_upperarm_angle)
    ply_l_forearm_matrix:SetTranslation(ply_l_upperarm_pos)
    ply_l_forearm_matrix:SetAngles(ply_l_forearm_angle)
    ply_l_hand_matrix:SetTranslation(ply_l_forearm_pos)

    bone_apply_matrix(ply, ply_l_upperarm_index, ply_l_upperarm_matrix, ply_l_forearm_index)
    bone_apply_matrix(ply, ply_l_forearm_index, ply_l_forearm_matrix, ply_l_hand_index)
    bone_apply_matrix(ply, ply_l_hand_index, ply_l_hand_matrix)
end
