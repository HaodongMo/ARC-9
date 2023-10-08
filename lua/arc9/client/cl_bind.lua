ARC9.KeyPressed_Menu = false

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

    if bind == "+use" and !LocalPlayer():KeyDown(IN_USE) then
        return ARC9.AttemptGiveNPCWeapon()
    end

    if bind == "+showscores" and wpn:GetCustomize() then
        if ply:KeyDown(IN_USE) then
            wpn:CycleSelectedAtt(-1)
        else
            wpn:CycleSelectedAtt(1)
        end
        return true
    end

    if bind == "impulse 100" and wpn:GetCustomize() then
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

    if bind == "+reload" and wpn:GetCustomize() then
        local attpnl = wpn.CustomizeLastHovered
        local foldpnl = wpn.CustomizeLastHoveredFolder
        local slotpnl = wpn.CustomizeLastHoveredSlot

        if attpnl and attpnl:IsHovered() then
            -- print("att", attpnl.att)
        end

        if foldpnl and foldpnl:IsHovered() then
            -- print("folder", foldpnl)

            local randompool = {}

            for _, v in ipairs(wpn.BottomBarAtts) do
                local atbl = ARC9.GetAttTable(v.att)

                local checkfolder = foldpnl.folder

                local pathprefix = string.Implode("/", wpn.BottomBarPath)
                if pathprefix != "" then checkfolder = pathprefix .. "/" .. foldpnl.folder end
                
                if atbl.Folder == checkfolder or (foldpnl.folder == "!favorites" and ARC9.Favorites[v.att]) then
                    table.insert(randompool, atbl)
                    randompool[#randompool].fuckthis = v.slot
                end               
            end

            local thatatt = randompool[math.random(0, #randompool)]
            if thatatt then
                wpn:Attach(thatatt.fuckthis, thatatt.ShortName, true)
            end

            surface.PlaySound(randsound)
        end
        
        if slotpnl and (slotpnl:IsHovered() or slotpnl.validforrand) then
            if !wpn:GetSlotBlocked(slotpnl.slot) then
                -- print("slot", slotpnl)

                wpn:RollRandomAtts({[1] = wpn:LocateSlotFromAddress(slotpnl.slot.Address)}, true)
                
                wpn:PruneAttachments()
                wpn:PostModify()
                wpn:SendWeapon()

                timer.Simple(0, function() wpn:CreateHUD_Bottom() end)

                surface.PlaySound(randsound)
            end
        end

        return true
    end

    if wpn:GetInSights() then
        if bind == "invnext" then
            wpn:Scroll(1)

            return true
        elseif bind == "invprev" then
            wpn:Scroll(-1)

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
        -- if bind == "+zoom" then return "pls bind Suit Zoom!" end -- fucking blind stupid retards please open settings
        -- if bind == "+menu_context" then return "pls bind Open Context Menu!" end
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