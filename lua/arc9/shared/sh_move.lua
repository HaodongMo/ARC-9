ARC9.LastEyeAngles = Angle(0, 0, 0)
ARC9.RecoilRise = Angle(0, 0, 0)

function ARC9.Move(ply, mv, cmd)
    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then return end

    local basespd = (Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length()
    basespd = math.min(basespd, mv:GetMaxClientSpeed())

    local mult = wpn:GetProcessedValue("Speed", nil, 1)

    if wpn:GetSightAmount() > 0 then
        if ply:KeyDown(IN_SPEED) then
            mult = mult / Lerp(wpn:GetSightAmount(), 1, ply:GetRunSpeed() / ply:GetWalkSpeed()) * (wpn:HoldingBreath() and 0.5 or 1)
        end
    -- else
    --     if wpn:GetTraversalSprint() then
    --         mult = 1
    --     end
    end

    mv:SetMaxSpeed(basespd * mult)
    mv:SetMaxClientSpeed(basespd * mult)

    if wpn:GetInMeleeAttack() and wpn:GetLungeEntity():IsValid() then
        mv:SetMaxSpeed(10000)
        mv:SetMaxClientSpeed(10000)
        local targetpos = (wpn:GetLungeEntity():EyePos() + wpn:GetLungeEntity():EyePos()) / 2
        local lungevec = targetpos - ply:EyePos()
        local lungedir = lungevec:GetNormalized()
        local lungedist = lungevec:Length()
        local lungespd = (2 * (lungedist / math.Max(0.01, wpn:GetProcessedValue("PreBashTime", true))))
        mv:SetVelocity(lungedir * lungespd)
    end

    if wpn:GetBipod() then
        if ply:Crouching() then
            cmd:AddKey(IN_DUCK)
            mv:AddKey(IN_DUCK)
        else
            cmd:RemoveKey(IN_DUCK)
            local buttons = mv:GetButtons()
            buttons = bit.band(buttons, bit.bnot(IN_DUCK))
            mv:SetButtons(buttons)
        end
    end

    if cmd:GetImpulse() == ARC9.IMPULSE_TOGGLEATTS then
        if !wpn:StillWaiting() and !wpn:GetUBGL() then
            ply:EmitSound(wpn:RandomChoice(wpn:GetProcessedValue("ToggleAttSound", true)), 75, 100, 1, CHAN_ITEM)
            wpn:PlayAnimation("toggle")
        end
    end
end

hook.Add("SetupMove", "ARC9.SetupMove", ARC9.Move)

ARC9.RecoilTimeStep = 0.03

ARC9.ClientRecoilTime = 0

ARC9.ClientRecoilUp = 0
ARC9.ClientRecoilSide = 0

ARC9.ClientRecoilProgress = 0

local ARC9_cheapscopes = GetConVar("ARC9_cheapscopes")

local function approxEqualsZero(a)
    return math.abs(a) < 0.0001
end

local function tgt_pos(ent, head) -- From ArcCW
    local mins, maxs = ent:WorldSpaceAABB()
    local pos = ent:WorldSpaceCenter()
    pos.z = pos.z + (maxs.z - mins.z) * 0.2 -- Aim at chest level
    if head and ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        pos = ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    end
    return pos
end

local arc9_aimassist_cone = GetConVar("arc9_aimassist_cone")
local arc9_aimassist_distance = GetConVar("arc9_aimassist_distance")
local arc9_aimassist_intensity = GetConVar("arc9_aimassist_intensity")
local arc9_aimassist_head = GetConVar("arc9_aimassist_head")
local arc9_aimassist = GetConVar("arc9_aimassist")
local arc9_aimassist_lockon = GetConVar("arc9_aimassist_lockon")

function ARC9.StartCommand(ply, cmd)
    if !IsValid(ply) or cmd:CommandNumber() == 0 then return end
    -- commandnumber may reduce inaccurate inputs on client

    local wpn = ply:GetActiveWeapon()

    if !wpn.ARC9 then ARC9.RecoilRise = Angle(0, 0, 0) return end

    if ply:IsBot() then timescalefactor = 1 end -- ping is infinite for them lol
	
    -- Aim assist imported from ArcCW
    if CLIENT and IsValid(wpn) then
		local cone = arc9_aimassist_cone:GetFloat()
		-- local dist = arc9_aimassist_distance:GetFloat() * (wpn:GetProcessedValue("AARangeMult") or 1)
		local dist = math.min(wpn.RangeMax * 0.95, 4000) -- 4000hu is somewhat about 100m
		local inte = arc9_aimassist_intensity:GetFloat() * (wpn:GetProcessedValue("AimAssistStrength", true) or 1)
		local head = arc9_aimassist_head:GetBool()

		-- Check if current target is beyond tracking cone
		local tgt = ply.ARC9_AATarget
		if IsValid(tgt) and (tgt_pos(tgt, head) - ply:EyePos()):Cross(ply:EyeAngles():Forward()):Length() > cone * 2 then ply.ARC9_AATarget = nil end -- lost track

		-- Try to seek target if not exists
		tgt = ply.ARC9_AATarget
		if !IsValid(tgt) or (tgt.Health and tgt:Health() <= 0) or util.QuickTrace(ply:EyePos(), tgt_pos(tgt, head) - ply:EyePos(), ply).Entity ~= tgt then
			local min_diff
			ply.ARC9_AATarget = nil
			-- for _, ent in ipairs(ents.FindInCone(ply:EyePos(), ply:EyeAngles():Forward(), 244, math.cos(math.rad(cone)))) do
			for _, ent in ipairs(ents.FindInCone(ply:EyePos(), ply:EyeAngles():Forward(), dist, math.cos(math.rad(cone)))) do
				if ent == ply or (!ent:IsNPC() and !ent:IsNextBot() and !ent:IsPlayer()) or ent:Health() <= 0
						or (ent:IsPlayer() and ent:Team() ~= TEAM_UNASSIGNED and ent:Team() == ply:Team()) then continue end
				local tr = util.TraceLine({
					start = ply:EyePos(),
					endpos = tgt_pos(ent, head),
					mask = MASK_SHOT,
					filter = ply
				})
				if tr.Entity ~= ent then continue end
				local diff = (tgt_pos(ent, head) - ply:EyePos()):Cross(ply:EyeAngles():Forward()):Length()
				if !ply.ARC9_AATarget or diff < min_diff then
					ply.ARC9_AATarget = ent
					min_diff = diff
				end
			end
		end

		-- Aim towards target
		tgt = ply.ARC9_AATarget
		if arc9_aimassist:GetBool() and ply:GetInfoNum("arc9_aimassist_cl", 0) == 1 then
			if IsValid(tgt) and !wpn:GetCustomize() then
                if wpn:GetProcessedValue("AimAssist", true) then
                    local ang = cmd:GetViewAngles()
                    local pos = tgt_pos(tgt, head)
                    local tgt_ang = (pos - ply:EyePos()):Angle()
                    local ang_diff = (pos - ply:EyePos()):Cross(ply:EyeAngles():Forward()):Length()
                    if ang_diff > 0.1 then
                        ang = LerpAngle(math.Clamp(inte / ang_diff, 0, 1), ang, tgt_ang)
                        cmd:SetViewAngles(ang)
                    end
                end
			end
		end
    end
	
    if wpn:GetBipod() then
        local bipang = wpn:GetBipodAng()

        local eyeang = cmd:GetViewAngles()

        if math.AngleDifference(bipang.y, eyeang.y) < -40 then
            eyeang.y = bipang.y + 40
        elseif math.AngleDifference(bipang.y, eyeang.y) > 40 then
            eyeang.y = bipang.y - 40
        end

        if math.AngleDifference(bipang.p, eyeang.p) > 15 then
            eyeang.p = bipang.p - 15
        elseif math.AngleDifference(bipang.p, eyeang.p) < -15 then
            eyeang.p = bipang.p + 15
        end

        cmd:SetViewAngles(eyeang)

        if game.SinglePlayer() then
            ply:SetEyeAngles(eyeang)
        end
    end

    local isScope = wpn:IsUsingRTScope()

    if isScope then
        local swayspeed = 2
        local swayamt = wpn:GetFreeSwayAmount()
        local swayang = Angle(math.sin(CurTime() * 0.6 * swayspeed) + (math.cos(CurTime() * 2) * 0.5), math.sin(CurTime() * 0.4 * swayspeed) + (math.cos(CurTime() * 1.6) * 0.5), 0)

        swayang = swayang * wpn:GetSightAmount() * swayamt * 0.2

        local eyeang = cmd:GetViewAngles()

        eyeang.p = eyeang.p + (swayang.p * FrameTime())
        eyeang.y = eyeang.y + (swayang.y * FrameTime())

        cmd:SetViewAngles(eyeang)
    end

    if wpn:GetProcessedValue("NoSprintWhenLocked", true) and wpn:GetAnimLockTime() > CurTime() then
        cmd:RemoveKey(IN_SPEED)
    end

    local eyeang = cmd:GetViewAngles()

    if eyeang.p != eyeang.p then eyeang.p = 0 end
    if eyeang.y != eyeang.y then eyeang.y = 0 end
    if eyeang.r != eyeang.r then eyeang.r = 0 end

    local m = 25

    if CLIENT then
        local diff = ARC9.LastEyeAngles - cmd:GetViewAngles()
        local recrise = ARC9.RecoilRise
        
        if !wpn.RecoilAutoControl_DontTryToReturnBack then
            -- 0 can be negative or positive!!!!! Insane
            if approxEqualsZero(recrise.p) then
            elseif recrise.p > 0 then
                recrise.p = math.Clamp(recrise.p, 0, recrise.p - diff.p)
            elseif recrise.p < 0 then
                recrise.p = math.Clamp(recrise.p, recrise.p - diff.p, 0)
            end

            if approxEqualsZero(recrise.y) then
            elseif recrise.y > 0 then
                recrise.y = math.Clamp(recrise.y, 0, recrise.y - diff.y)
            elseif recrise.y < 0 then
                recrise.y = math.Clamp(recrise.y, recrise.y - diff.y, 0)
            end
        end

        recrise:Normalize()

        ARC9.RecoilRise = recrise

        local catchup = 0

        if ARC9.ClientRecoilTime < CurTime() then
            ARC9.ClientRecoilUp = wpn:GetRecoilUp() * ARC9.RecoilTimeStep
            ARC9.ClientRecoilSide = wpn:GetRecoilSide() * ARC9.RecoilTimeStep

            ARC9.ClientRecoilTime = CurTime() + ARC9.RecoilTimeStep

            if ARC9.ClientRecoilProgress < 1 then
                catchup = ARC9.RecoilTimeStep * (1 - ARC9.ClientRecoilProgress)
            end

            ARC9.ClientRecoilProgress = 0
        end

        local cft = math.min(FrameTime(), ARC9.RecoilTimeStep)

        local progress = cft / ARC9.RecoilTimeStep

        if progress > 1 - ARC9.ClientRecoilProgress then
            cft = (1 - ARC9.ClientRecoilProgress) * ARC9.RecoilTimeStep
            progress = (1 - ARC9.ClientRecoilProgress)
        end

        cft = cft + catchup

        ARC9.ClientRecoilProgress = ARC9.ClientRecoilProgress + progress

        if math.abs(ARC9.ClientRecoilUp) > 1e-5 then
            eyeang.p = eyeang.p + ARC9.ClientRecoilUp * m * cft / ARC9.RecoilTimeStep
        end

        if math.abs(ARC9.ClientRecoilSide) > 1e-5 then
            eyeang.y = eyeang.y + ARC9.ClientRecoilSide * m * cft / ARC9.RecoilTimeStep
        end

        local diff_p = ARC9.ClientRecoilUp * m * cft / ARC9.RecoilTimeStep
        local diff_y = ARC9.ClientRecoilSide * m * cft / ARC9.RecoilTimeStep

        ARC9.RecoilRise = ARC9.RecoilRise + Angle(diff_p, diff_y, 0)

        local recreset = ARC9.RecoilRise * wpn:GetProcessedValue("RecoilAutoControl", true) * cft * 2

        if math.abs(recreset.p) > 1e-5 then
            eyeang.p = eyeang.p - recreset.p
        end

        if math.abs(recreset.y) > 1e-5 then
            eyeang.y = eyeang.y - recreset.y
        end

        ARC9.RecoilRise = ARC9.RecoilRise - Angle(recreset.p, recreset.y, 0)

        ARC9.RecoilRise:Normalize()

        cmd:SetViewAngles(eyeang)

        ARC9.LastEyeAngles = eyeang
    end

    if cmd:GetImpulse() == 100 and wpn:CanToggleAllStatsOnF() and !wpn:GetCustomize() then
        if !wpn:GetReloading() and !wpn:GetUBGL() then
            ply:EmitSound(wpn:RandomChoice(wpn:GetProcessedValue("ToggleAttSound", true)), 75, 100, 1, CHAN_ITEM)
            if CLIENT then
                wpn:ToggleAllStatsOnF()
            end
        end

        cmd:SetImpulse(ARC9.IMPULSE_TOGGLEATTS)
    end

    local maus = cmd:GetMouseWheel()
    if wpn:GetInSights() and cmd:GetMouseWheel() != 0 then
        if ply:KeyDown(IN_USE) and #wpn.MultiSightTable > 0 and !wpn:StillWaiting() then
            wpn:SwitchMultiSight(maus) -- switchsights is hardcoded to scroll wheel and can't be dealt with using invnext/invprev atm
        elseif CLIENT and (maus < 0 and !input.LookupBinding("invnext") or maus > 0 and !input.LookupBinding("invprev")) then
            wpn:Scroll(-maus) -- if invnext is bound use those, if not then use mouse wheel
        end
    end
end

hook.Add("StartCommand", "ARC9_StartCommand", ARC9.StartCommand)