local mat_default = Material("arc9/arccw_bird.png")
local mat_new = Material("arc9/plus.png")
local mat_reset = Material("arc9/reset.png")
local mat_export = Material("arc9/arrow_up.png")
local mat_import = Material("arc9/arrow_down.png")
local nextpreset = 0

local mat_plus = Material("arc9/ui/plus.png")

function SWEP:CreateHUD_Slots(scroll)
    self.CustomizeHUD.lowerpanel:MoveTo(ScreenScale(19), ScrH() - ScreenScale(93), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ScreenScale(38), ScreenScale(74), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel.Extended = nil 



    for _, slot in ipairs(self:GetSubSlotList()) do
        if slot.Hidden then continue end
        local ms_slot = self:GetFilledMergeSlot(slot.Address)

        if !ms_slot.Installed and self:GetSlotBlocked(slot) then continue end

        local atttbl = self:GetFinalAttTable(ms_slot)

        local atttxt = ms_slot.PrintName or "Slot"


        local slotbtn = vgui.Create("ARC9AttButton", scroll)

        -- slotbtn:SetButtonText("slot")
        -- slotbtn:SetIcon(mat_default)
        slotbtn:SetCanAttach(true)
        slotbtn:SetEmpty(!ms_slot.Installed)
        slotbtn:SetHasModes(!!atttbl.ToggleStats)
        slotbtn:SetHasSlots(!!atttbl.Attachments)

        slotbtn:DockMargin(ScreenScale(5), 0, 0, 0)
        slotbtn:Dock(LEFT)
    
        scroll:AddPanel(slotbtn)


        if ms_slot.Installed then
            atttxt = ARC9:GetPhraseForAtt(ms_slot.Installed, "CompactName")
            atttxt = atttxt or ARC9:GetPhraseForAtt(ms_slot.Installed, "PrintName") or ""
            slotbtn:SetIcon(atttbl.Icon)
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
        end

        slotbtn:SetButtonText(atttxt)

        slotbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then                        
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
    --     btn:SetSize(ScreenScale(48), ScreenScale(48))
    --     btn:DockMargin(ScreenScale(2), 0, 0, 0)
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
    --             surface.DrawRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

    --             if self2:IsHovered() then
    --                 surface.SetDrawColor(ARC9.GetHUDColor("hi"))
    --             else
    --                 surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    --             end

    --             surface.DrawRect(0, 0, w - ScreenScale(1), h - ScreenScale(1))
    --             hasbg = true
    --         else
    --             surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100))
    --             surface.DrawRect(0, 0, w, h)
    --         end

    --         preset = string.upper(preset)

    --         if !hasbg then
    --             surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    --             surface.SetMaterial(icon)
    --             surface.DrawTexturedRect(ScreenScale(2), ScreenScale(2), w - ScreenScale(1), h - ScreenScale(1))

    --             surface.SetTextColor(ARC9.GetHUDColor("shadow"))
    --             surface.SetTextPos(ScreenScale(14), ScreenScale(1))
    --             surface.SetFont("ARC9_10")
    --             self:DrawTextRot(self2, preset, 0, 0, ScreenScale(3), ScreenScale(1), ScreenScale(46), true)
    --         end

    --         surface.SetDrawColor(col1)
    --         surface.SetMaterial(icon)
    --         surface.DrawTexturedRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

    --         surface.SetTextColor(col1)
    --         surface.SetTextPos(ScreenScale(13), 0)
    --         surface.SetFont("ARC9_10")
    --         self:DrawTextRot(self2, preset, 0, 0, ScreenScale(2), 0, ScreenScale(46), false)
    --     end
    -- end
end