ARC9.KeyPressed_Menu = false
ARC9.DeferToggleAtts = false
ARC9.DeferFakeToggleAtts = false

local randsound = "arc9/newui/ui_part_randomize.ogg"

hook.Add("PlayerBindPress", "ARC9_Binds", function(ply, bind, pressed, code)
    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ARC9 then return end

    if bind == "+menu_context" then
        if !wpn:GetInSights() and !LocalPlayer():KeyDown(IN_USE) then
            -- if wpn:GetCustomize() then
            --     surface.PlaySound("arc9/newui/ui_close.ogg")
            --     net.Start("ARC9_togglecustomize")
            --     net.WriteBool(false)
            --     net.SendToServer()
            --     -- wpn:DoIconCapture()
            -- else
            --     surface.PlaySound("arc9/newui/ui_open.ogg")
            --     net.Start("ARC9_togglecustomize")
            --     net.WriteBool(true)
            --     net.SendToServer()
            -- end

            ARC9.KeyPressed_Menu = pressed

            return true
        elseif wpn:GetInSights() and !LocalPlayer():KeyDown(IN_USE) then
            return true
        end
    end

    if !pressed then return end

    local plususe = ((ARC9.ControllerMode() and bind == "+zoom" and !LocalPlayer():KeyDown(IN_ZOOM)) -- Gamepad
                    or (!ARC9.ControllerMode() and bind == "+use" and !LocalPlayer():KeyDown(IN_USE)))


    if wpn:GetCustomize() then
        if bind == "+showscores" then
            if ply:KeyDown(IN_USE) then
                wpn:CycleSelectedAtt(-1)
            else
                wpn:CycleSelectedAtt(1)
            end
            return true
        end

        if bind == "impulse 100" then
            if wpn.CustomizeLastHovered and wpn.CustomizeLastHovered:IsHovered() then
                local att = wpn.CustomizeLastHovered.att
                ARC9:ToggleFavorite(att)
                if ARC9.Favorites[att] and wpn.BottomBarFolders["!favorites"] then
                    wpn.BottomBarFolders["!favorites"][att] = true
                elseif wpn.BottomBarFolders["!favorites"] then
                    wpn.BottomBarFolders["!favorites"][att] = nil
                end
            end
            return true
        end

        if bind == "+reload" then
            local attpnl = wpn.CustomizeLastHovered
            local foldpnl = wpn.CustomizeLastHoveredFolder
            local slotpnl = wpn.CustomizeLastHoveredSlot
            local slotpnl2 = wpn.CustomizeLastHoveredSlot2
            local addr

            if foldpnl and foldpnl:IsHovered() then -- when hovering folder
                -- print("folder", foldpnl)

                local randompool = {}

                for _, v in ipairs(wpn.BottomBarAtts) do
                    local atbl = ARC9.GetAttTable(v.att)

                    local checkfolder = foldpnl.folder

                    local pathprefix = string.Implode("/", wpn.BottomBarPath)
                    if pathprefix != "" then checkfolder = pathprefix .. "/" .. foldpnl.folder end

                    if (atbl.Folder == checkfolder or (foldpnl.folder == "!favorites" and ARC9.Favorites[v.att]))
                            and wpn:CanAttach(v.slot, v.att) then
                        table.insert(randompool, atbl)
                        randompool[#randompool].fuckthis = v.slot
                    end
                end

                local thatatt = randompool[math.random(0, #randompool)]
                if thatatt and wpn:Attach(thatatt.fuckthis, thatatt.ShortName, true) then
                    wpn:PruneAttachments()
                    wpn:PostModify()
                    wpn:SendWeapon()

                    timer.Simple(0, function() wpn:CreateHUD_Bottom() end)
                end

                surface.PlaySound(randsound)
            end

            if slotpnl and slotpnl.slot then -- when hovering slot in bottom bar
                if !wpn:GetSlotBlocked(slotpnl.slot) then
                    wpn:RollRandomAtts({[1] = wpn:LocateSlotFromAddress(slotpnl.slot.Address)}, true, true, true)

                    wpn:PruneAttachments()
                    wpn:PostModify()
                    wpn:SendWeapon()

                    timer.Simple(0, function() wpn:CreateHUD_Bottom() end)

                    surface.PlaySound(randsound)
                end
            end
            

            local slotpnl2 = wpn.CustomizeLastHoveredSlot2

            if attpnl and attpnl:IsHovered() then -- when hovering att in attachment selector. not really rqeuired
                addr = attpnl.address
            end

            if slotpnl2 and slotpnl2.fuckinghovered then -- when hovering slot in 3d space
                addr = slotpnl2.Address
            end

            if addr then
                wpn:RollRandomAtts({[1] = wpn:LocateSlotFromAddress(addr)}, true, true, true)

                wpn:PruneAttachments()
                wpn:PostModify()
                wpn:SendWeapon()

                timer.Simple(0, function() wpn:CreateHUD_Bottom() end)

                surface.PlaySound(randsound)
            end

            return true
        end

        if plususe then
            local attpnl = wpn.CustomizeLastHovered
            local addr

            local slotpnl2 = wpn.CustomizeLastHoveredSlot2

            if attpnl and attpnl:IsHovered() then
                addr = attpnl.address
            end

            if slotpnl2 and slotpnl2.fuckinghovered then
                addr = slotpnl2.Address
            end

            if addr then
                local atttbl = wpn:GetFinalAttTable(wpn:GetFilledMergeSlot(addr))

                if ((atttbl.ToggleStats and !atttbl.AdvancedCamoSupport) or (atttbl.AdvancedCamoSupport and wpn.AdvancedCamoCache)) then
                    wpn:EmitSound(wpn:RandomChoice(wpn:GetProcessedValue("ToggleAttSound", true)), 75, 100, 1, CHAN_ITEM)
                    wpn:ToggleStat(addr, input.IsKeyDown(KEY_LSHIFT) and -1 or 1)
                    wpn:PostModify()
                end
            end

            return true
        end
    else
        if bind == "impulse 100" then
            if wpn:CanToggleAllStatsOnF() > 1 and !ARC9.DeferToggleAtts then
                -- We are going to defer the logic to cl_radialmenu
                return true
            else
                ARC9.DeferToggleAtts = false
            end
        end

        if plususe then
            return ARC9.AttemptGiveNPCWeapon()
        end
    end

    if wpn:GetInSights() then
        if bind == "invnext" then
            wpn:Scroll(1)
            wpn.Peeking = false

            return true
        elseif bind == "invprev" then
            wpn:Scroll(-1)
            wpn.Peeking = false

            return true
        end
    end
end)

function ARC9.GetBindKey(bind)
    local key = input.LookupBinding(bind)

    local CTRL = ARC9.ControllerMode()

    if CTRL then
        return bind
    elseif !key then
        if bind == "+zoom" then return ARC9:GetPhrase("hud.error.missingbind_zoom") -- fucking blind stupid retards please open settings
        elseif bind == "+menu_context" then return ARC9:GetPhrase("hud.error.missingbind_context")
        elseif bind == "impulse 100" then return ARC9:GetPhrase("hud.error.missingbind_flight")
        elseif bind == "+use" then return ARC9:GetPhrase("hud.error.missingbind_use")
        elseif bind == "invnext" then return ARC9:GetPhrase("hud.error.missingbind_invnext")
        elseif bind == "invprev" then return ARC9:GetPhrase("hud.error.missingbind_invprev") end
        -- return "bind KEY " ..  bind

        return string.format(ARC9:GetPhrase("hud.error.missingbind"), bind)
    else
        return string.upper(key)
    end
end

function ARC9.GetKeyIsBound(bind)
    local key = input.LookupBinding(bind)

    if !key then
        return false
    else
        return true
    end
end

function ARC9.GetKey(bind)
    local key = input.LookupBinding(bind)

    return input.GetKeyCode(key)
end

ARC9.KeyPressed_Melee = false
ARC9.KeyPressed_UBGL = false
ARC9.KeyPressed_Inspect = false
ARC9.KeyPressed_SwitchSights = false

concommand.Add("+arc9_melee", function()
    ARC9.KeyPressed_Melee = true
end)

concommand.Add("-arc9_melee", function()
    ARC9.KeyPressed_Melee = false
end)

concommand.Add("+arc9_ubgl", function()
    ARC9.KeyPressed_UBGL = true
end)

concommand.Add("-arc9_ubgl", function()
    ARC9.KeyPressed_UBGL = false
end)

concommand.Add("+arc9_inspect", function()
    ARC9.KeyPressed_Inspect = true
end)

concommand.Add("-arc9_inspect", function()
    ARC9.KeyPressed_Inspect = false
end)

concommand.Add("+arc9_switchsights", function()
    ARC9.KeyPressed_SwitchSights = true
end)

concommand.Add("-arc9_switchsights", function()
    ARC9.KeyPressed_SwitchSights = false
end)