local mat_plus = Material("arc9/ui/plus.png")

local clicksound = "ui/panorama/generic_press_01.wav"

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
        slotbtn:SetFullColorIcon(atttbl.FullColorIcon)

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
                slotbtn:SetIcon(ms_slot.DefaultIcon)
            else
                slotbtn:SetIcon(mat_plus)
            end

            -- slotbtn:SetTooltip(atttxt .. " slot (unoccupied)\n\nLMB - Customisation")
        end

        slotbtn:SetButtonText(atttxt)

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

        slotbtn.Think = function(self2)
            if !IsValid(self) then return end
            if self2:IsHovered() then
                self.CustomizeHints["Select"] = "Expand"
                if self2.slot.Installed then
                    self.CustomizeHints["Deselect"] = "Unattach"
                end
                self2.slot.hovered = true
            else
                self2.slot.hovered = false
            end

        end
    end
end