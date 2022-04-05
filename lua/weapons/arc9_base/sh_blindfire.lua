
/*

ValveBiped.Bip01_Spine
ValveBiped.Bip01_Spine1
ValveBiped.Bip01_Spine2
ValveBiped.Bip01_Spine4
ValveBiped.Bip01_Neck1
ValveBiped.Bip01_Head1
ValveBiped.forward
ValveBiped.Bip01_R_Clavicle
ValveBiped.Bip01_R_UpperArm
ValveBiped.Bip01_R_Forearm
ValveBiped.Bip01_R_Hand
ValveBiped.Anim_Attachment_RH
ValveBiped.Bip01_L_Clavicle
ValveBiped.Bip01_L_UpperArm
ValveBiped.Bip01_L_Forearm
ValveBiped.Bip01_L_Hand
ValveBiped.Anim_Attachment_LH
ValveBiped.Bip01_R_Thigh
ValveBiped.Bip01_R_Calf
ValveBiped.Bip01_R_Foot
ValveBiped.Bip01_R_Toe0
ValveBiped.Bip01_L_Thigh
ValveBiped.Bip01_L_Calf
ValveBiped.Bip01_L_Foot
ValveBiped.Bip01_L_Toe0
ValveBiped.Bip01_L_Finger4
ValveBiped.Bip01_L_Finger41
ValveBiped.Bip01_L_Finger42
ValveBiped.Bip01_L_Finger3
ValveBiped.Bip01_L_Finger31
ValveBiped.Bip01_L_Finger32
ValveBiped.Bip01_L_Finger2
ValveBiped.Bip01_L_Finger21
ValveBiped.Bip01_L_Finger22
ValveBiped.Bip01_L_Finger1
ValveBiped.Bip01_L_Finger11
ValveBiped.Bip01_L_Finger12
ValveBiped.Bip01_L_Finger0
ValveBiped.Bip01_L_Finger01
ValveBiped.Bip01_L_Finger02
ValveBiped.Bip01_R_Finger4
ValveBiped.Bip01_R_Finger41
ValveBiped.Bip01_R_Finger42
ValveBiped.Bip01_R_Finger3
ValveBiped.Bip01_R_Finger31
ValveBiped.Bip01_R_Finger32
ValveBiped.Bip01_R_Finger2
ValveBiped.Bip01_R_Finger21
ValveBiped.Bip01_R_Finger22
ValveBiped.Bip01_R_Finger1
ValveBiped.Bip01_R_Finger11
ValveBiped.Bip01_R_Finger12
ValveBiped.Bip01_R_Finger0
ValveBiped.Bip01_R_Finger01
ValveBiped.Bip01_R_Finger02

*/

function SWEP:ToggleBoneMods(on, dir)
    if on then
        if dir < 0 then
            for i, k in pairs(self:GetValue("BlindFireLeftBoneMods")) do
                local boneindex = self:GetOwner():LookupBone(i)

                if !boneindex then continue end

                self:GetOwner():ManipulateBonePosition(boneindex, k.pos or Vector(0, 0, 0))
                self:GetOwner():ManipulateBoneAngles(boneindex, k.ang or Angle(0, 0, 0))
            end
        elseif dir > 0 then
            for i, k in pairs(self:GetValue("BlindFireRightBoneMods")) do
                local boneindex = self:GetOwner():LookupBone(i)

                if !boneindex then continue end

                self:GetOwner():ManipulateBonePosition(boneindex, k.pos or Vector(0, 0, 0))
                self:GetOwner():ManipulateBoneAngles(boneindex, k.ang or Angle(0, 0, 0))
            end
        else
            for i, k in pairs(self:GetValue("BlindFireBoneMods")) do
                local boneindex = self:GetOwner():LookupBone(i)

                if !boneindex then continue end

                self:GetOwner():ManipulateBonePosition(boneindex, k.pos or Vector(0, 0, 0))
                self:GetOwner():ManipulateBoneAngles(boneindex, k.ang or Angle(0, 0, 0))
            end
        end
    else
        for i, k in pairs(self:GetValue("BlindFireBoneMods")) do
            local boneindex = self:GetOwner():LookupBone(i)

            if !boneindex then continue end

            self:GetOwner():ManipulateBonePosition(boneindex, Vector(0, 0, 0))
            self:GetOwner():ManipulateBoneAngles(boneindex, Angle(0, 0, 0))
        end

        for i, k in pairs(self:GetValue("BlindFireRightBoneMods")) do
            local boneindex = self:GetOwner():LookupBone(i)

            if !boneindex then continue end

            self:GetOwner():ManipulateBonePosition(boneindex, Vector(0, 0, 0))
            self:GetOwner():ManipulateBoneAngles(boneindex, Angle(0, 0, 0))
        end

        for i, k in pairs(self:GetValue("BlindFireLeftBoneMods")) do
            local boneindex = self:GetOwner():LookupBone(i)

            if !boneindex then continue end

            self:GetOwner():ManipulateBonePosition(boneindex, Vector(0, 0, 0))
            self:GetOwner():ManipulateBoneAngles(boneindex, Angle(0, 0, 0))
        end
    end
end

function SWEP:ToggleBlindFire(bf, dir)
    dir = dir or 0
    if !self:GetValue("CanBlindFire") then return end

    if bf == self:GetBlindFire() and dir == self:GetBlindFireDirection() then return end
    if bf and self:GetIsSprinting() then return end
    if bf and self:GetAnimLockTime() > CurTime() then return end
    if bf and self:GetSafe() then return end

    if dir < 0 and !self:GetValue("BlindFireLeft") then dir = 0 bf = false end
    if dir > 0 and !self:GetValue("BlindFireRight") then dir = 0 bf = false end

    if bf and self:GetSightAmount() > 0 then return end

    self:SetBlindFire(bf)
    self:ToggleCustomize(false)

    self:ToggleBoneMods(false, false)
    self:ToggleBoneMods(bf, dir)

    if !bf then
        self:SetBlindFireDirection(0)
    else
        self:SetBlindFireDirection(dir)
    end

    if self:StillWaiting() then self:IdleAtEndOfAnimation() return end

    self:Idle()
end

function SWEP:ThinkBlindFire()
    local amt = self:GetBlindFireAmount()
    local oldamt = amt

    if self:GetBlindFire() then
        amt = math.Approach(amt, 1, FrameTime() / 0.25)
    else
        amt = math.Approach(amt, 0, FrameTime() / 0.25)
    end

    if oldamt != amt then
        self:SetBlindFireAmount(amt)
    end

    local amt2 = self:GetBlindFireCornerAmount()
    local oldamt2 = amt2

    if self:GetBlindFireDirection() > 0 then
        amt2 = math.Approach(amt2, 1, FrameTime() / 0.25)
    elseif self:GetBlindFireDirection() < 0 then
        amt2 = math.Approach(amt2, -1, FrameTime() / 0.25)
    else
        amt2 = math.Approach(amt2, 0, FrameTime() / 0.25)
    end

    if oldamt2 != amt2 then
        self:SetBlindFireCornerAmount(amt2)
    end

    if self:GetOwner():KeyDown(IN_ALT1) then
        if self:GetOwner():KeyDown(IN_BACK) then
            self:ToggleBlindFire(false)
        elseif self:GetOwner():KeyDown(IN_FORWARD) then
            self:ToggleBlindFire(true, 0)
        elseif self:GetOwner():KeyDown(IN_MOVELEFT) then
            self:ToggleBlindFire(true, -1)
        elseif self:GetOwner():KeyDown(IN_MOVERIGHT) then
            self:ToggleBlindFire(true, 1)
        end
    end

    -- if self:GetBlindFire() then
    --     if self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyPressed(IN_MOVELEFT) then
    --         self:SetBlindFireCorner(!self:GetBlindFireCorner())
    --     end
    -- else
    --     if self:GetBlindFireCorner() then
    --         self:SetBlindFireCorner(false)
    --     end
    -- end
end