SWEP.MaxLeanOffset = 16
SWEP.MaxLeanAngle = 15

SWEP.LeanState = 0

function SWEP:ThinkLean()
    if self:PredictionFilter() then return end

    if !GetConVar("arc9_lean"):GetBool() or !self:GetProcessedValue("CanLean") then
        self:SetLeanAmount(0)
        return
    end

    if !(self:GetOwner():KeyDown(IN_SPEED) and (self:GetOwner():KeyDown(IN_FORWARD) or self:GetOwner():KeyDown(IN_BACK) or self:GetOwner():KeyDown(IN_MOVELEFT) or self:GetOwner():KeyDown(IN_MOVERIGHT))) then
        if self:GetOwner():KeyDown(IN_ALT1) then
            self.LeanState = -1
        elseif self:GetOwner():KeyDown(IN_ALT2) then
            self.LeanState = 1
        else
            self.LeanState = 0
        end
    end

    local maxleanfrac = 1

    if self.LeanState != 0 then
        local tr = util.TraceHull({
            start = self:GetOwner():EyePos(),
            endpos = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Right() * (self.MaxLeanOffset - 2) * self.LeanState,
            filter = self:GetOwner(),
            maxs = Vector(1, 1, 1) * 4,
            mins = Vector(-1, -1, -1) * 4,
        })

        if tr.Hit then
            maxleanfrac = tr.Fraction * 0.5
        end
    end

    local amt = self:GetLeanAmount()
    local tgt = self.LeanState

    if maxleanfrac < 1 then
        tgt = 0
    end

    amt = math.Approach(amt, tgt, FrameTime() * 7)
    amt = math.Clamp(amt, -maxleanfrac, maxleanfrac)

    self:SetLeanAmount(amt)

    if amt != 0 then
        self:GetOwner():SetCollisionBounds(Vector(-32, -32, 0), Vector(32, 32, 64))
    end

    self:DoPlayerModelLean()
end

function SWEP:GetLeanDelta()
    return math.ease.InSine(self:GetLeanAmount()) * (self:GetLeanAmount() > 0 and 1 or -1)
end

function SWEP:GetLeanOffset()
    local amt = self:GetLeanDelta()

    return amt * self.MaxLeanOffset
end

function SWEP:DoCameraLean(pos, ang)
    local amt = self:GetLeanDelta()

    if amt == 0 then return pos, ang end

    local newpos = pos + self:GetOwner():EyeAngles():Right() * self:GetLeanOffset()

    ang:RotateAroundAxis(ang:Forward(), amt * self.MaxLeanAngle)

    return newpos, ang
end

function SWEP:DoWeaponLean(pos, ang)
    local amt = self:GetLeanDelta()

    if amt == 0 then return pos, ang end

    local newpos = pos + self:GetOwner():EyeAngles():Right() * self:GetLeanOffset()

    return newpos, ang
end

local leanbone = "ValveBiped.Bip01_Spine1"

local leanang_left = Angle(3.5, 1.75, 2)
local leanang_right = Angle(3.5, 1.75, 0)

function SWEP:DoPlayerModelLean(cancel)
    local amt = self:GetLeanDelta()

    if amt == 0 then return end

    if cancel then amt = 0 end

    local bone = self:GetOwner():LookupBone(leanbone)

    if !bone then return end

    self:GetOwner():ManipulateBoneAngles(bone, (amt < 0 and leanang_left or leanang_right) * amt * self.MaxLeanAngle, game.SinglePlayer())
end