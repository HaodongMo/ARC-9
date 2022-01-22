SWEP.AttachmentAddresses = {}

function SWEP:LocateSlotFromAddress(address)
    return self.AttachmentAddresses[address]
end

function SWEP:BuildAttachmentAddresses()
    self.AttachmentAddresses = {}

    for c, i in pairs(self:GetSubSlotList()) do
        i.Address = c

        self.AttachmentAddresses[c] = i
    end
end

function SWEP:AttTreeToList(tree)
    if !istable(tree) then return {} end
    local atts = {}

    atts = {tree}

    if tree.SubAttachments then
        for _, sub in pairs(tree.SubAttachments) do
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

    for _, i in pairs(self:GetSubSlotList()) do
        if i.Installed then
            table.insert(atts, i.Installed)
        end
    end

    return atts
end

function SWEP:BuildSubAttachmentTree(tbl, parenttbl)
    if !tbl.Installed then return {} end

    local atttbl = ARC9.GetAttTable(tbl.Installed)

    local subatts = {}

    if atttbl then
        if atttbl.Attachments then
            subatts = table.Copy(atttbl.Attachments)

            for i, k in ipairs(tbl.SubAttachments) do
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

                local pos, _ = LocalToWorld(subatts[i].Pos or Vector(0, 0, 0), subatts[i].Ang or Angle(0, 0, 0), att_pos, att_ang)

                subatts[i].Pos = pos
                subatts[i].Ang = att_ang + subatts[i].Ang
                subatts[i].Ang:Normalize()
                subatts[i].Installed = tbl.SubAttachments[i].Installed
                subatts[i].ExtraSightDistance = subatts[i].ExtraSightDistance
                subatts[i].MergeSlots = subatts[i].MergeSlots
                subatts[i].SubAttachments = self:BuildSubAttachmentTree(k, subatts[i])
            end
        end
    end

    return subatts
end

function SWEP:BuildSubAttachments(tbl)
    for i, k in pairs(self.Attachments) do
        k.OriginalAddress = i
        k.SubAttachments = {}
    end

    for i, k in pairs(tbl) do
        self.Attachments[i].Installed = k.Installed

        if !k.Installed then continue end

        local atttbl = ARC9.GetAttTable(k.Installed)

        if atttbl then
            if atttbl.Attachments then
                self.Attachments[i].SubAttachments = self:BuildSubAttachmentTree(k, self.Attachments[i])
            end
        end
    end

    self:BuildAttachmentAddresses()
    self:BuildMergeSlots(self.Attachments)

    PrintTable(self.Attachments)

    self:PruneAttachments()
end

function SWEP:ValidateInventoryForNewTree(tree)
    local count = self:CountAttsInTree(tree)

    local currcount = self:CountAttsInTree(self.Attachments)

    for att, attc in pairs(count) do
        local atttbl = ARC9.GetAttTable(att)

        if atttbl.Free then continue end

        if (currcount[att] or 0) + ARC9:PlayerGetAtts(self:GetOwner(), att) > count[att] then
            continue
        end

        return false
    end

    return true
end

function SWEP:PruneAttachments()
    for _, slot in pairs(self:GetSubSlotList()) do
        if !slot.Installed then continue end

        if !self:CanAttach(slot.Address, slot.Installed, slot) then
            slot.Installed = false
            slot.SubAttachments = nil
        end
    end
end