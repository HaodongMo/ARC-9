function SWEP:BuildMergeSlots(tree)
    for i, slot in pairs(tree) do
        if slot.MergeSlots then
            slot.MergeSlotAddresses = {}

            for _, merge in pairs(slot.MergeSlots) do
                local mergeslot = tree[merge]

                if !mergeslot then continue end

                mergeslot.MergeSlots = {i}
                mergeslot.MergeSlotAddresses = {slot.Address}

                table.insert(slot.MergeSlotAddresses, mergeslot.Address)
            end
        else
            slot.MergeSlotAddresses = nil
        end

        self:BuildMergeSlots(slot.SubAttachments)
    end
end