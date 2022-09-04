SWEP.AttachmentAddresses = {}

function SWEP:LocateSlotFromAddress(address)
    return self.AttachmentAddresses[address]
end

function SWEP:BuildAttachmentAddresses()
    self.AttachmentAddresses = {}

    for c, i in ipairs(self:GetSubSlotList()) do
        i.Address = c

        self.AttachmentAddresses[c] = i
    end

    for _, i in ipairs(self.Attachments) do
        self:BuildParentAddresses(i)
    end
end

function SWEP:BuildParentAddresses(parenttbl)
    for _, i in ipairs(parenttbl.SubAttachments or {}) do
        i.ParentAddress = parenttbl.Address
        self:BuildParentAddresses(i)
    end
end

function SWEP:AttTreeToList(tree)
    if !istable(tree) then return {} end
    local atts = {}

    atts = {tree}

    if tree.SubAttachments then
        for _, sub in ipairs(tree.SubAttachments) do
            table.Add(atts, self:AttTreeToList(sub))
        end
    end

    return atts
end

function SWEP:GetSubSlotList()
    local atts = {}

    for _, i in ipairs(self.Attachments or {}) do
        table.Add(atts, self:AttTreeToList(i))
    end

    return atts
end

function SWEP:GetAttachmentList()
    local atts = {}

    for _, i in ipairs(self:GetSubSlotList()) do
        if i.Installed then
            table.insert(atts, i.Installed)
        end
    end

    return atts
end

-- tbl: The table we are installing on to the gun
-- parenttbl: The parent of the table we are installing on to
function SWEP:BuildSubAttachmentTree(tbl, parenttbl)
    if !tbl.Installed then return {} end

    local atttbl = ARC9.GetAttTable(tbl.Installed)

    tbl.ToggleNum = tbl.ToggleNum or 1

    local subatts = {}

    if atttbl then
        if atttbl.Attachments then
            subatts = table.Copy(atttbl.Attachments)

            for i, k in ipairs(tbl.SubAttachments or {}) do
                subatts[i].Bone = parenttbl.Bone
                local att_pos = parenttbl.Pos
                local att_ang = parenttbl.Ang

                local og_addr = parenttbl.OriginalAddress

                if og_addr then
                    local eles = self:GetElements()

                    for i2, _ in pairs(eles) do
                        local ele = self.AttachmentElements[i2]

                        if !ele then continue end

                        local mods = ele.AttPosMods or {}

                        if mods[og_addr] then
                            att_pos = mods[og_addr].Pos or att_pos
                            att_ang = mods[og_addr].Ang or att_ang
                        end
                    end
                end

                local scale =  parenttbl.Scale or 1

                subatts[i].Scale = (subatts[i].Scale or 1) * scale

                -- local pos, _ = LocalToWorld((subatts[i].Pos or Vector(0, 0, 0)) * scale, subatts[i].Ang or Angle(0, 0, 0), att_pos, att_ang)
                local pos = Vector(0, 0, 0)
                pos:Set(att_pos)

                local off_ang = Angle(0, 0, 0)
                local forward, up, right = off_ang:Forward(), off_ang:Up(), off_ang:Right()

                forward:Rotate(-att_ang)
                up:Rotate(-att_ang)
                right:Rotate(-att_ang)

                subatts[i].Pos = subatts[i].Pos * (subatts[i].Scale or 1)

                pos = pos + (forward * -subatts[i].Pos.x)
                pos = pos + (right * -subatts[i].Pos.y)
                pos = pos + (up * -subatts[i].Pos.z)

                -- print(subatts[i].Pos)

                subatts[i].Pos = pos
                subatts[i].Ang = att_ang + subatts[i].Ang
                subatts[i].Ang:Normalize()
                subatts[i].Installed = tbl.SubAttachments[i].Installed
                if subatts[i].Installed then
                    local satttbl = ARC9.GetAttTable(subatts[i].Installed)

                    if !satttbl then
                        subatts[i].Installed = nil
                    end
                end
                subatts[i].ExtraSightDistance = (subatts[i].ExtraSightDistance or 0) + (parenttbl.ExtraSightDistance or 0)
                -- subatts[i].MergeSlots = subatts[i].MergeSlots
                subatts[i].ToggleNum = tbl.SubAttachments[i].ToggleNum or 1
                subatts[i].CorrectiveAng = parenttbl.CorrectiveAng
                if subatts[i].Installed then
                    subatts[i].SubAttachments = self:BuildSubAttachmentTree(k, subatts[i])
                end
            end
        end
    end

    return subatts
end

-- Call this after changing the attachment structure
function SWEP:BuildSubAttachments(tbl)
    for i, k in ipairs(self.Attachments) do
        k.OriginalAddress = i
        k.SubAttachments = {}
    end

    for i, k in ipairs(tbl) do
        if !self.Attachments[i] then print("Invalid attachment structure!") return end
        self.Attachments[i].Installed = k.Installed

        if !k.Installed then continue end

        local atttbl = ARC9.GetAttTable(k.Installed)
        self.Attachments[i].ToggleNum = k.ToggleNum or 1

        if atttbl then
            if atttbl.Attachments then
                self.Attachments[i].SubAttachments = self:BuildSubAttachmentTree(k, self.Attachments[i])
            end
        end
    end

    self:BuildAttachmentAddresses()
    self:BuildMergeSlots(self.Attachments)
end

-- Checks if the subatt tree is illegal
-- i.e. if it attempts to place attachments the player does not actually own
function SWEP:ValidateInventoryForNewTree(tree)
    local count = self:CountAttsInTree(tree)

    local currcount = self:CountAttsInTree(self.Attachments)

    for att, attc in ipairs(count) do
        local atttbl = ARC9.GetAttTable(att)

        if atttbl.Free then continue end

        if (currcount[att] or 0) + ARC9:PlayerGetAtts(self:GetOwner(), att) > count[att] then
            continue
        end

        return false
    end

    return true
end

-- Gets rid of invalid attachments
function SWEP:PruneAttachments()
    for _, slot in ipairs(self:GetSubSlotList()) do
        if !slot.Installed then continue end

        if !ARC9.Attachments[slot.Installed] then
            slot.Installed = nil
            continue
        end

        local atttbl = ARC9.GetAttTable(slot.Installed)

        if !atttbl or self:SlotInvalid(slot) then
            slot.Installed = false
            slot.SubAttachments = nil
        end

        if slot.MergeSlotAddresses then
            for _, msa in ipairs(slot.MergeSlotAddresses) do
                local mslottbl = self:LocateSlotFromAddress(msa)

                if !mslottbl then continue end

                if mslottbl.Installed then
                    slot.Installed = false
                    slot.SubAttachments = nil
                end
            end
        end
    end
end