local mat_plus = Material("arc9/ui/plus.png")

local clicksound = "arc9/malfunction.wav"

local ARC9ScreenScale = ARC9.ScreenScale

function SWEP:CreateHUD_Slots(scroll)
    self.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(93), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel.Extended = nil 



    for _, slot in ipairs(self:GetSubSlotList()) do
        if slot.Hidden then continue end
        local ms_slot = self:GetFilledMergeSlot(slot.Address)

        if !ms_slot.Installed and self:GetSlotBlocked(slot) then continue end

        local atttbl = self:GetFinalAttTable(ms_slot)

        local atttxt = ms_slot.PrintName or "Slot"


        local slotbtn = vgui.Create("ARC9AttButton", scroll)

        slotbtn:SetCanAttach(true)
        slotbtn:SetEmpty(!ms_slot.Installed)
        slotbtn:SetHasModes(!!atttbl.ToggleStats)
        slotbtn:SetHasSlots(!!atttbl.Attachments)

        slotbtn:DockMargin(ARC9ScreenScale(5), 0, 0, 0)
        slotbtn:Dock(LEFT)
    
        scroll:AddPanel(slotbtn)

        slotbtn.slot = ms_slot
        ms_slot.lowerbutton = slotbtn
        
        if ms_slot.Installed then
            atttxt = ARC9:GetPhraseForAtt(ms_slot.Installed, "CompactName")
            atttxt = atttxt or ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName") or ""
            slotbtn:SetIcon(atttbl.Icon)
            -- slotbtn:SetTooltip(ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName").."\n\nLMB - Customisation\nRMB - Remove attachment")
        else
            if ms_slot.DefaultCompactName then
                atttxt = ARC9:UseTrueNames() and ms_slot.DefaultCompactName_TrueName or ms_slot.DefaultCompactName
                atttxt = atttxt or ms_slot.DefaultName_TrueName or ms_slot.DefaultName or ""
            end
            if ms_slot.DefaultIcon then
                slotbtn:SetIcon(atttbl.DefaultIcon)
            else
                slotbtn:SetIcon(mat_plus)
            end

            -- slotbtn:SetTooltip(atttxt .. " slot (unoccupied)\n\nLMB - Customisation")
        end
        
        slotbtn:SetButtonText(atttxt)

        slotbtn.Think = function(self2)
            if self2:IsHovered() then
                self2.slot.hovered = true
            else
                self2.slot.hovered = false 
            end
        end

        slotbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then       
                surface.PlaySound(clicksound)                 
                self.BottomBarMode = 1
                self.BottomBarAddress = slot.Address
                self.BottomBarPath = {}
                self.BottomBarFolders = {}
                self.BottomBarAtts = {}
                self:CreateHUD_Bottom()
            elseif kc == MOUSE_RIGHT then
                self:DetachAllFromSubSlot(slot.Address)
                
                timer.Simple(0, function() self:CreateHUD_Bottom() end)
                -- self:CreateHUD_Bottom()
            end
        end
    end

    -- local presetlist = self:GetPresets()

    -- for _, preset in pairs(presetlist) do
    --     if preset == "autosave" or preset == "default" then continue end
    --     local filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. preset .. "." .. ARC9.PresetIconFormat
    --     local btn = vgui.Create("DButton", scroll)
    --     btn:SetSize(ARC9ScreenScale(48), ARC9ScreenScale(48))
    --     btn:DockMargin(ARC9ScreenScale(2), 0, 0, 0)
    --     btn:Dock(LEFT)
    --     btn:SetText("")
    --     scroll:AddPanel(btn)
    --     btn.preset = preset

    --     if file.Exists(filename, "DATA") then
    --         btn.icon = Material("data/" .. filename, "smooth")
    --     end

    --     btn.DoClick = function(self2)
    --         self:LoadPreset(preset)
    --         surface.PlaySound("arc9/preset_install.ogg")
    --     end

    --     btn.DoRightClick = function(self2)
    --         self:DeletePreset(preset)
    --         surface.PlaySound("arc9/preset_delete.ogg")
    --         self:CreateHUD_Bottom()
    --     end

    --     btn.Paint = function(self2, w, h)
    --         if !IsValid(self) then return end

    --         local col1 = ARC9.GetHUDColor("fg")
    --         local icon = self2.icon or mat_default
    --         local hasbg = false

    --         if self2:IsHovered() then
    --             self.CustomizeHints["Select"]   = "Load"
    --             self.CustomizeHints["Deselect"] = "Delete"
    --             col1 = ARC9.GetHUDColor("shadow")
    --             surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    --             surface.DrawRect(ARC9ScreenScale(1), ARC9ScreenScale(1), w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))

    --             if self2:IsHovered() then
    --                 surface.SetDrawColor(ARC9.GetHUDColor("hi"))
    --             else
    --                 surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    --             end

    --             surface.DrawRect(0, 0, w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))
    --             hasbg = true
    --         else
    --             surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100))
    --             surface.DrawRect(0, 0, w, h)
    --         end

    --         preset = string.upper(preset)

    --         if !hasbg then
    --             surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    --             surface.SetMaterial(icon)
    --             surface.DrawTexturedRect(ARC9ScreenScale(2), ARC9ScreenScale(2), w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))

    --             surface.SetTextColor(ARC9.GetHUDColor("shadow"))
    --             surface.SetTextPos(ARC9ScreenScale(14), ARC9ScreenScale(1))
    --             surface.SetFont("ARC9_10")
    --             self:DrawTextRot(self2, preset, 0, 0, ARC9ScreenScale(3), ARC9ScreenScale(1), ARC9ScreenScale(46), true)
    --         end

    --         surface.SetDrawColor(col1)
    --         surface.SetMaterial(icon)
    --         surface.DrawTexturedRect(ARC9ScreenScale(1), ARC9ScreenScale(1), w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))

    --         surface.SetTextColor(col1)
    --         surface.SetTextPos(ARC9ScreenScale(13), 0)
    --         surface.SetFont("ARC9_10")
    --         self:DrawTextRot(self2, preset, 0, 0, ARC9ScreenScale(2), 0, ARC9ScreenScale(46), false)
    --     end
    -- end
end