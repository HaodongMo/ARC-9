if game.SinglePlayer() then

net.Receive("arc9_sp_health", function(len, ply)
    local ent = net.ReadEntity()

    if !IsValid(ent) then return end

    ent:SetHealth(0)
    ent.ARC9CLHealth = 0
end)

end


local clr_b = Color(160, 190, 255)
local clr_r = Color(255, 190, 190)

concommand.Add("arc9_listvmanims", function()
    local wep = LocalPlayer():GetActiveWeapon()

    if !wep then return end

    local vm = LocalPlayer():GetViewModel()

    if !vm then return end

    local alist = vm:GetSequenceList()

    for i = 0, #alist do
        MsgC(clr_b, i, " --- ")
        MsgC(color_white, "\t", alist[i], "\n     [")
        MsgC(clr_r, "\t", vm:SequenceDuration(i), "\n")
    end
end)

concommand.Add("arc9_listvmbones", function()
    local wep = LocalPlayer():GetActiveWeapon()

    if !wep then return end

    local vm = LocalPlayer():GetViewModel()

    if !vm then return end

    for i = 0, (vm:GetBoneCount() - 1) do
        print(i .. " - " .. vm:GetBoneName(i))
    end
end)

concommand.Add("arc9_listvmatts", function()
    local wep = LocalPlayer():GetActiveWeapon()

    if !wep then return end

    local vm = LocalPlayer():GetViewModel()

    if !vm then return end

    local alist = vm:GetAttachments()

    for i = 1, #alist do
        MsgC(clr_b, i, " --- ")
        MsgC(color_white, "\tindex : ", alist[i].id, "\n     [")
        MsgC(clr_r, "\tname: ", alist[i].name, "\n")
    end
end)

concommand.Add("arc9_listvmbgs", function()
    local wep = LocalPlayer():GetActiveWeapon()

    if !wep then return end

    local vm = LocalPlayer():GetViewModel()

    if !vm then return end

    local alist = vm:GetBodyGroups()

    for i = 1, #alist do
        local alistsm = alist[i].submodels
        local active = vm:GetBodygroup(alist[i].id)
        MsgC(clr_b, i, " --- ")
        MsgC(color_white, "\tid: ", alist[i].id, "\n     [")
        MsgC(clr_r, "\tname: ", alist[i].name, "\n")
        MsgC(clr_r, "\tnum: ", alist[i].num, "\n")
        if alistsm then
            MsgC(clr_r, "\tsubmodels:\n")
            for j = 0, #alistsm do
                MsgC(active == j and color_white or clr_b, "\t" .. j, " --- ")
                MsgC(active == j and color_white or clr_r, alistsm[j], "\n")
            end
        end
    end
end)
