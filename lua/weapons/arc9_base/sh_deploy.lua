
function SWEP:Deploy()
    local owner = self:GetOwner()

    if self:GetOwner():IsNPC() then
        return
    end

    self:InvalidateCache()

    self:SetBaseSettings()

    self:SetNextPrimaryFire(0)
    self:SetNextSecondaryFire(0)
    self:SetAnimLockTime(0)
    self:SetLastMeleeTime(0)
    self:SetRecoilAmount(0)
    self:SetRecoilUp(0)
    self:SetRecoilSide(0)
    self:SetPrimedAttack(false)
    self:SetReloading(false)
    self:SetRequestReload(false)
    self:SetEmptyReload(false)
    self:SetLeanState(0)

    owner:SetCanZoom(false)
    -- self:SetTraversalSprint(false)
    -- self:SetLastPressedWTime(0)

    -- self:SetBlindFire(false)
    -- self:SetBlindFireDirection(0)

    self:SetHolster_Entity(NULL)
    self:SetHolsterTime(0)

    self:SetFreeAimAngle(Angle(0, 0, 0))
    self:SetLastAimAngle(Angle(0, 0, 0))

    if self:GetProcessedValue("AutoReload", _, _, true) then
        self:RestoreClip(math.huge)
    end

    self:DoDeployAnimation()

    self:SetBurstCount(0)
    self:SetSightAmount(0)
    self:SetCustomize(false)
    self:SetBreath(100)
    self:SetInspecting(false)
    self:SetLoadedRounds(self:Clip1())
    self:SetGrenadeRecovering(false)
    self:SetUBGL(false)
    self:SetLeanAmount(0)

    self:SetGrenadePrimed(false)

    self:SetBipod(false)

    self:SetTriggerDown(owner:KeyDown(IN_ATTACK))

    local holsteredtime = CurTime() - self:GetLastHolsterTime()

    self:ThinkHeat(holsteredtime)

    if self:GetValue("AnimDraw") then
        self:DoPlayerAnimationEvent(self:GetValue("AnimDraw"))
    end

    if game.SinglePlayer() then
        self:CallOnClient("RecalculateIKGunMotionOffset")
    end

    if SERVER then
        self:CreateShield()

        -- self:NetworkWeapon()
        self:SetTimer(0.25, function()
            self:SendWeapon()
        end)
        if IsValid(owner:GetHands()) then
            owner:GetHands():SetLightingOriginEntity(owner:GetViewModel())
        end
    end

    self:SetShouldHoldType()

    self:RunHook("Hook_Deploy")

    return true
end

function SWEP:GiveDefaultAmmo()
    self:SetClip1(self:GetValue("ClipSize"))
    self:GetOwner():GiveAmmo(self:GetValue("ClipSize") * 2, self:GetValue("Ammo"))
end

local v0 = Vector(0, 0, 0)
local v1 = Vector(1, 1, 1)
local a0 = Angle(0, 0, 0)

function SWEP:ClientHolster()
    if game.SinglePlayer() then
        self:CallOnClient("ClientHolster")
    end

    local vm = self:GetVM()

    vm:SetSubMaterial()
    vm:SetMaterial()

    for i = 0, vm:GetBoneCount() do
        vm:ManipulateBoneScale(i, v1)
        vm:ManipulateBoneAngles(i, a0)
        vm:ManipulateBonePosition(i, v0)
    end
end

function SWEP:Holster(wep)
    -- May cause issues? But will fix HL2 weapons playing a wrong animation on ARC9 holster
    if game.SinglePlayer() and CLIENT then return end

    local owner = self:GetOwner()

    if CLIENT and owner != LocalPlayer() then return end

    if owner:IsNPC() then
        return
    end

    if self:GetReloading() then
        self:CancelReload()
    end

    self:SetCustomize(false)
    
    local animdrwa = self:GetValue("AnimDraw")

    if animdrwa then
        self:DoPlayerAnimationEvent(animdrwa)
    end

    if self:GetHolsterTime() > CurTime() then return false end

    if (self:GetHolsterTime() != 0 and self:GetHolsterTime() <= CurTime()) or !IsValid(wep) then
        -- Do the final holster request
        -- Picking up props try to switch to NULL, by the way
        self:SetHolsterTime(0)
        self:SetHolster_Entity(NULL)

        self:KillTimers()
        owner:SetFOV(0, 0)
        owner:SetCanZoom(true)
        self:EndLoop()

        self:ClientHolster()

        if game.SinglePlayer() then
            game.SetTimeScale(1)
        end

        -- if self.SetBreathDSP then
        --     self:GetOwner():SetDSP(0)
        --     self.SetBreathDSP = false
        -- end

        self:RunHook("Hook_Holster")

        if SERVER then
            self:KillShield()
        end

        if SERVER and self:GetProcessedValue("Disposable", _, _, true) and self:Clip1() == 0 and self:Ammo1() == 0 and !IsValid(self:GetDetonatorEntity()) then
            self:Remove()
        end

        self:SetLastHolsterTime(CurTime())

        self:DoPlayerModelLean(true)

        return true
    else
        -- Prepare the holster and set up the timer
        if self:HasAnimation("holster") then
            local animation = self:PlayAnimation("holster", self:GetProcessedValue("DeployTime", 1, _, true), true, false) or 0
            self:SetHolsterTime(CurTime() + animation)
            self:SetHolster_Entity(wep)
        else
            self:SetHolsterTime(CurTime() + (self:GetProcessedValue("DeployTime", 1, _, true)))
            self:SetHolster_Entity(wep)
        end

        -- self:ToggleBlindFire(false)
        self:SetInSights(false)
        self:ToggleUBGL(false)
    end
end

local holsteranticrash = false

hook.Add("StartCommand", "ARC9_Holster", function(ply, ucmd)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.ARC9 then
        if wep:GetHolsterTime() != 0 and wep:GetHolsterTime() <= CurTime() then
            if IsValid(wep:GetHolster_Entity()) then
                wep:SetHolsterTime(-math.huge) -- Pretty much force it to work

                if !holsteranticrash then
                    holsteranticrash = true
                    ucmd:SelectWeapon(wep:GetHolster_Entity()) -- Call the final holster request
                    holsteranticrash = false
                end
            end
        end
    end
end)

local arc9_never_ready = GetConVar("arc9_never_ready")
local arc9_dev_always_ready = GetConVar("arc9_dev_always_ready")

function SWEP:DoDeployAnimation()
    if !arc9_never_ready:GetBool() and (arc9_dev_always_ready:GetBool() or !self:GetReady()) and self:HasAnimation("ready") then
        local t, min = self:PlayAnimation("ready", self:GetProcessedValue("DeployTime", 1, _, true), true)

        self:SetReadyTime(CurTime() + t * min)
        self:SetReady(true)
    else
        self:PlayAnimation("draw", self:GetProcessedValue("DeployTime", 1, _, true), true)
        self:SetReady(true)
    end
end
