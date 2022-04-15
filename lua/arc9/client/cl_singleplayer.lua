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

function RecoilPatternGUI()
    local wep = LocalPlayer():GetActiveWeapon()
    if !wep.ARC9 then return end

    local weptable = wep.RecoilLookupTable
    if !weptable then
        wep.RecoilLookupTable = {}
        weptable = wep.RecoilLookupTable
    end
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(8 * 50, 8 * 50)
    Frame:SetTitle("")
    Frame:SetVisible(true)
    Frame:Center(true)
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(true)
    Frame:MakePopup()
    local DermaButton = vgui.Create("DButton", Frame)
    DermaButton:SetText("RS")
    DermaButton:SetPos(10, 10)
    DermaButton:SetSize(20, 20)

    DermaButton.DoClick = function()
        Frame:Remove()
        RecoilPatternGUI()
    end

    local frames = {}
    local prevrecX, prevrecY = 0, 0

    for i = 1, #weptable do
        local x = math.deg(math.cos(weptable[i]))
        local y = math.deg(math.sin(weptable[i]))
        local rx, ry = prevrecX - x * 4, prevrecY + y * 4.7
        frames[i] = vgui.Create("DFrame")
        frames[i]:SetParent(Frame)
        frames[i]:SetSize(10, 10)
        frames[i]:SetDraggable(true)
        frames[i]:SetPos(200 + rx - 5, ry + 400 - 5)
        frames[i]:ShowCloseButton(false)
        frames[i].id = i

        frames[i].TestHover = function(self)
            local qx, qy = self:GetPos()
        end

        -- self:SetPos(qx, ry+400)
        frames[i].Paint = function(self, w, h)
            surface.SetDrawColor(0, 0, 0, 230)
            surface.DrawRect(0, 0, w, h)
        end

        prevrecX = rx
        prevrecY = ry
        -- frames[i] = frames.i
    end

    local DermaButton2 = vgui.Create("DButton", Frame)
    DermaButton2:SetText("Apply")
    DermaButton2:SetPos(35, 10)
    DermaButton2:SetSize(35, 20)

    DermaButton2.DoClick = function()
        LocalPlayer():GetActiveWeapon().RecoilLookupTable = {}
        local prevoneX, prevoneY = 195, 395

        for i = 1, #frames do
            local fx, fy = frames[i]:GetPos()
            print(math.deg(math.atan2(fy - prevoneY) / 4.7, -(fx - prevoneX)) / 4)
            -- LocalPlayer():GetActiveWeapon().RecoilLookupTable[i] = Angle((fy - prevoneY) / 4.7, -(fx - prevoneX) / 4, 0)
            LocalPlayer():GetActiveWeapon().RecoilLookupTable[i] = math.deg(math.atan2(fy - prevoneY) / 4.7, -(fx - prevoneX) / 4)
            LocalPlayer():GetActiveWeapon().RecoilLookupTable[#weptable + 1] = 0
            prevoneX, prevoneY = frames[i]:GetPos()
        end
    end

    -- 'function Frame:Paint( w, h )' works too
    Frame.Paint = function(self, w, h)
        surface.SetDrawColor(180, 180, 180, 255)
        surface.DrawRect(0, 0, w, h)
        local hovered = vgui.GetHoveredPanel()

        if hovered then
            local id = hovered.id

            if id then
                draw.SimpleText("" .. vgui.GetHoveredPanel().id, "DermaDefault", 50, 50, color_white)
            end
        end
    end
end

concommand.Add("arc9_makerecoilpattern", RecoilPatternGUI)