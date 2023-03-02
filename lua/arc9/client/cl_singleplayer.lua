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

concommand.Add("arc9_dev_printirons", function()
    MsgC(clr_b, "{\n")
    MsgC(color_white, "    Pos")
    MsgC(clr_b, " = ")
    MsgC(clr_r, "Vector")
    MsgC(color_white, "(")
    MsgC(clr_b, tostring(GetConVar("arc9_dev_irons_x"):GetFloat()))
    MsgC(color_white, ",")
    MsgC(clr_b, tostring(GetConVar("arc9_dev_irons_y"):GetFloat()))
    MsgC(color_white, ",")
    MsgC(clr_b, tostring(GetConVar("arc9_dev_irons_z"):GetFloat()))
    MsgC(color_white, "),\n")
    MsgC(color_white, "    Ang")
    MsgC(clr_b, " = ")
    MsgC(clr_r, "Angle")
    MsgC(color_white, "(")
    MsgC(clr_b, tostring(GetConVar("arc9_dev_irons_pitch"):GetFloat()))
    MsgC(color_white, ",")
    MsgC(clr_b, tostring(GetConVar("arc9_dev_irons_yaw"):GetFloat()))
    MsgC(color_white, ",")
    MsgC(clr_b, tostring(GetConVar("arc9_dev_irons_roll"):GetFloat()))
    MsgC(color_white, "),\n")
    MsgC(clr_b, "}\n")

    -- Pos = Vector(GetConVar("arc9_dev_irons_x"):GetFloat(), GetConVar("arc9_dev_irons_y"):GetFloat(), GetConVar("arc9_dev_irons_z"):GetFloat()),
    --                     Ang = Angle(GetConVar("arc9_dev_irons_pitch"):GetFloat(), GetConVar("arc9_dev_irons_yaw"):GetFloat(), GetConVar("arc9_dev_irons_roll"):GetFloat()),
end)

concommand.Add("arc9_dev_listanims", function()
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

local function printattsintable(tbl, depth)
    for k, v in pairs(tbl) do
        if istable(v) and isnumber(k) or k == "SubAttachments" then
            MsgC(clr_b, string.rep("\t", depth), k, " = {\n")
            printattsintable(v, depth + 1)
            MsgC(clr_b, string.rep("\t", depth), "},\n")
        elseif k == "Installed" then
            MsgC(clr_b, string.rep("\t", depth), k, " = ")
            MsgC(clr_r, tostring(v), "\n")
        end
    end
end

concommand.Add("arc9_dev_printatts", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if !IsValid(wep) or !wep.ARC9 or !wep.Attachments then MsgC(clr_r, "Not a valid ARC9 weapon with attachments!") return end

    MsgC(clr_b, "{\n")
    printattsintable(wep.Attachments, 1)
    MsgC(clr_b, "}\n")
end)

concommand.Add("arc9_dev_listbones", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if !wep then return end
    local vm = LocalPlayer():GetViewModel()
    if !vm then return end

    for i = 0, (vm:GetBoneCount() - 1) do
        print(i .. " - " .. vm:GetBoneName(i))
    end
end)

concommand.Add("arc9_dev_listatts", function()
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

concommand.Add("arc9_dev_getjson", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if !wep then return end

    print(wep:GetPresetJSON())
end)

concommand.Add("arc9_dev_export", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if !wep then return end
    if !wep.ARC9 then return end

    print(wep:GeneratePresetExportCode())
end)

concommand.Add("arc9_dev_import", function(ply, cmd, args)
    local wep = LocalPlayer():GetActiveWeapon()
    if !wep then return end
    if !wep.ARC9 then return end

    wep:LoadPresetFromCode(args[1] or "")
end)

concommand.Add("arc9_dev_listbgs", function()
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