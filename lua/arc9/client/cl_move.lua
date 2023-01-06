local arc9_lean_direction = nil

hook.Add("CreateMove", "ARC9_CreateMove", function(cmd)
    local wpn = LocalPlayer():GetActiveWeapon()
    local ply = LocalPlayer()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    if (GetConVar("arc9_autoreload"):GetBool() or wpn:GetRequestReload()) and
        !wpn:GetCustomize() and
        !wpn:GetCustomize() and
        wpn:CanReload() and
        cmd:TickCount() % 2 == 0
    then
        if wpn:GetUBGL() then
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip2() == 0 and wpn:Ammo2() > 0 and wpn:GetNextPrimaryFire() + 0.5 < CurTime() then
                cmd:AddKey(IN_RELOAD)
            end
        else
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip1() == 0 and wpn:Ammo1() > 0 and wpn:GetNextPrimaryFire() + 0.5 < CurTime() then
                cmd:AddKey(IN_RELOAD)
            end
        end
    end

    if ARC9.KeyPressed_Menu then
        cmd:AddKey(IN_WEAPON1)
    end

    if GetConVar("arc9_autolean"):GetBool() then
        if cmd:KeyDown(IN_ATTACK2) or (wpn:ToggleADS() and arc9_lean_direction != nil and arc9_lean_direction != 0) then
            if arc9_lean_direction != nil and arc9_lean_direction != 0 then
                if wpn:ToggleADS() then
                    local eyepos = ply:EyePos()
                    local forward = ply:EyeAngles():Forward()

                    local covertrace = util.TraceHull({
                        start = eyepos,
                        endpos = eyepos + forward * 32,
                        filter = ply,
                        mins = Vector(-1, -1, -1) * 4,
                        maxs = Vector(1, 1, 1) * 4
                    })

                    if !covertrace.Hit then
                        arc9_lean_direction = 0
                        return
                    end
                end

                if arc9_lean_direction > 0 then
                    cmd:AddKey(IN_ALT2)
                elseif arc9_lean_direction < 0 then
                    cmd:AddKey(IN_ALT1)
                end
            elseif arc9_lean_direction == nil and cmd:KeyDown(IN_ATTACK2) then
                local eyepos = ply:EyePos()
                local right = ply:EyeAngles():Right()
                local forward = ply:EyeAngles():Forward()

                local covertrace = util.TraceHull({
                    start = eyepos,
                    endpos = eyepos + forward * 32,
                    filter = ply,
                    mins = Vector(-1, -1, -1) * 4,
                    maxs = Vector(1, 1, 1) * 4
                })

                if covertrace.Hit then
                    -- See if it's valid to lean left

                    arc9_lean_direction = 0

                    local leftleanamt = 0
                    local rightleanamt = 0

                    local leftleantrace = util.TraceLine({
                        start = eyepos,
                        endpos = eyepos + right * -wpn.MaxLeanOffset,
                        filter = ply,
                    })

                    if !leftleantrace.Hit then
                        -- see if it's possible to lean in this direction

                        local leftleantrace2 = util.TraceLine({
                            start = leftleantrace.HitPos,
                            endpos = leftleantrace.HitPos + (forward * 96),
                            filter = ply,
                        })

                        if !leftleantrace2.Hit then
                            local leftleantrace3 = util.TraceLine({
                                start = leftleantrace2.HitPos,
                                endpos = leftleantrace2.HitPos + (right * wpn.MaxLeanOffset),
                                filter = ply,
                            })

                            leftleanamt = leftleantrace3.Fraction * wpn.MaxLeanOffset
                        end
                    end

                    -- See if it's valid to lean right

                    local rightleantrace = util.TraceLine({
                        start = eyepos,
                        endpos = eyepos + right * wpn.MaxLeanOffset,
                        filter = ply,
                    })

                    if !rightleantrace.Hit then
                        -- see if it's possible to lean in this direction

                        local rightleantrace2 = util.TraceLine({
                            start = rightleantrace.HitPos,
                            endpos = rightleantrace.HitPos + (forward * 96),
                            filter = ply,
                        })

                        if !rightleantrace2.Hit then
                            local rightleantrace3 = util.TraceLine({
                                start = rightleantrace2.HitPos,
                                endpos = rightleantrace2.HitPos + (right * -wpn.MaxLeanOffset),
                                filter = ply,
                            })

                            rightleanamt = rightleantrace3.Fraction * wpn.MaxLeanOffset
                        end
                    end

                    if leftleanamt > rightleanamt then
                        arc9_lean_direction = -1
                    elseif rightleanamt > leftleanamt then
                        arc9_lean_direction = 1
                    else
                        arc9_lean_direction = 0
                    end
                end
            end
        else
            arc9_lean_direction = nil
        end
    end
end)