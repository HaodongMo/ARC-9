local DevMode = false 

local devselectedatt = 0
local devoffsetmode = false
local selectedbonename = "None"

SWEP.devlockeddrag = false 

function SWEP:DevStuffMenu()
    print("Developers developers developers developers developers developers developers developers developers developers developers developers developers ")
    
    local DevFrame = vgui.Create("DFrame")
    DevFrame:SetPos(ScrW()-1015, ScrH()-315) 
    DevFrame:SetSize(1000, 300) 
    DevFrame:SetTitle("Dev stuff") 
    DevFrame:SetVisible(true) 
    DevFrame:SetDraggable(true) 
    DevFrame:ShowCloseButton(true) 
    DevFrame:MakePopup()

    self.DevFrame = DevFrame

	local LockDragToggle = DevFrame:Add("DCheckBoxLabel") 
	LockDragToggle:SetPos(400, 273)
	LockDragToggle:SetText("Lock dragging")
    LockDragToggle.OnChange = function(non, val)
        self.devlockeddrag = val
    end

    
    local function makecoolslider(y, min, max, text, dec, func)
        local itis = vgui.Create("DNumSlider", DevFrame)
        itis:SetPos(10, y)
        itis:SetSize(1000, 50)
        itis:SetText(text)
        itis:SetMin(min)
        itis:SetMax(max)
        itis:SetDecimals(dec)

        itis.OnValueChanged = func

        return itis
    end

    local SliderX = makecoolslider(30, -25, 25, "X", 3, function(no, value) self:PostModify(true) if devoffsetmode then devselectedatt.Icon_Offset.x = value else devselectedatt.Pos.x = value end end)
    local SliderY = makecoolslider(60, -25, 25, "Y", 3, function(no, value) self:PostModify(true) if devoffsetmode then devselectedatt.Icon_Offset.y = value else devselectedatt.Pos.y = value end end)
    local SliderZ = makecoolslider(90, -25, 25, "Z", 3, function(no, value) self:PostModify(true) if devoffsetmode then devselectedatt.Icon_Offset.z = value else devselectedatt.Pos.z = value end end)

    local SliderPitch = makecoolslider(130, -180, 180, "P", 0, function(no, value) self:PostModify(true) devselectedatt.Ang.p = value end)
    local SliderYaw = makecoolslider(160, -180, 180, "Y", 0, function(no, value) self:PostModify(true) devselectedatt.Ang.y = value end)
    local SliderRoll = makecoolslider(190, -180, 180, "R", 0, function(no, value) self:PostModify(true) devselectedatt.Ang.r = value end)

	local OffsetModeToggle = DevFrame:Add("DCheckBoxLabel") 
	OffsetModeToggle:SetPos(200, 273)
	OffsetModeToggle:SetText("Icon offset mode")
    OffsetModeToggle.OnChange = function(non, val)
        devoffsetmode = val
        
        if val then
            if !devselectedatt.Icon_Offset then devselectedatt.Icon_Offset = Vector() end

            SliderX:SetValue(devselectedatt.Icon_Offset.x)
            SliderY:SetValue(devselectedatt.Icon_Offset.y)
            SliderZ:SetValue(devselectedatt.Icon_Offset.z)
        else
            SliderX:SetValue(devselectedatt.Pos.x)
            SliderY:SetValue(devselectedatt.Pos.y)
            SliderZ:SetValue(devselectedatt.Pos.z)
        end
    end

    local AttSelector = vgui.Create("DComboBox", DevFrame)
    AttSelector:SetPos(15, 300-30)
    AttSelector:SetSize(150, 20)
    AttSelector:SetValue("Select att")
    for i, slot in ipairs(self:GetSubSlotList()) do
        AttSelector:AddChoice(i.." - "..slot.PrintName)
    end
    
    AttSelector.OnSelect = function(no, index, value)
        print(value .. " was selected")
        devselectedatt = self:GetSubSlotList()[tonumber(value[1]..value[2])]

        if devoffsetmode then
            SliderX:SetValue(devselectedatt.Icon_Offset.x)
            SliderY:SetValue(devselectedatt.Icon_Offset.y)
            SliderZ:SetValue(devselectedatt.Icon_Offset.z)

            SliderX:SetMin(devselectedatt.Icon_Offset.x-5)
            SliderX:SetMax(devselectedatt.Icon_Offset.x+5)
            SliderY:SetMin(devselectedatt.Icon_Offset.y-5)
            SliderY:SetMax(devselectedatt.Icon_Offset.y+5)
            SliderZ:SetMin(devselectedatt.Icon_Offset.z-5)
            SliderZ:SetMax(devselectedatt.Icon_Offset.z+5)
        else
            SliderX:SetValue(devselectedatt.Pos.x)
            SliderY:SetValue(devselectedatt.Pos.y)
            SliderZ:SetValue(devselectedatt.Pos.z)
            
            SliderX:SetMin(devselectedatt.Pos.x-3)
            SliderX:SetMax(devselectedatt.Pos.x+3)
            SliderY:SetMin(devselectedatt.Pos.y-10)
            SliderY:SetMax(devselectedatt.Pos.y+10)
            SliderZ:SetMin(devselectedatt.Pos.z-8)
            SliderZ:SetMax(devselectedatt.Pos.z+8)
        end

        SliderPitch:SetValue(devselectedatt.Ang.p)
        SliderYaw:SetValue(devselectedatt.Ang.y)
        SliderRoll:SetValue(devselectedatt.Ang.r)
    end

    local function ExportAtt()
        if !devselectedatt.Icon_Offset then devselectedatt.Icon_Offset = Vector() end
        return string.format("Pos = Vector(%s, %s, %s),\nAng = Angle(%s, %s, %s),\nIcon_Offset = Vector(%s, %s, %s),", math.Round(devselectedatt.Pos.x, 3), math.Round(devselectedatt.Pos.y, 3), math.Round(devselectedatt.Pos.z, 3), math.Round(devselectedatt.Ang.p), math.Round(devselectedatt.Ang.y), math.Round(devselectedatt.Ang.r), math.Round(devselectedatt.Icon_Offset.x, 3), math.Round(devselectedatt.Icon_Offset.y, 3), math.Round(devselectedatt.Icon_Offset.z, 3))
    end

    local ConsoleButton = vgui.Create("DButton", DevFrame)
    ConsoleButton:SetText("To console")
    ConsoleButton:SetPos(640, 260)
    ConsoleButton:SetSize(100, 30)
    ConsoleButton.DoClick = function()
        print("---------\n\n")
        print(ExportAtt())
        print("\n\n---------")
    end
    
    local ClipboardButton = vgui.Create("DButton", DevFrame)
    ClipboardButton:SetText("To clipboard")
    ClipboardButton:SetPos(760, 260)
    ClipboardButton:SetSize(100, 30)
    ClipboardButton.DoClick = function()
        SetClipboardText(ExportAtt())
    end
    
    local ResetButton = vgui.Create("DButton", DevFrame)
    ResetButton:SetText("Reload atts")
    ResetButton:SetPos(880, 260)
    ResetButton:SetSize(100, 30)
    ResetButton.DoClick = function()
        RunConsoleCommand("arc9_reloadatts")
        timer.Simple(0, function() self:PostModify(true) end)
    end
    

    -- local AppList = vgui.Create("DListView", DevFrame)
    -- AppList:Dock(FILL)
    -- AppList:SetMultiSelect(false)
    -- AppList:AddColumn("Bone")

    -- local vm = self:GetVM()
    -- if !vm then return end

    -- for i = 0, (vm:GetBoneCount() - 1) do
    --     AppList:AddLine(vm:GetBoneName(i))
    -- end

    -- AppList.OnRowSelected = function(lst, index, pnl)
    --     print("Selected " .. pnl:GetColumnText(1) .. " at index " .. index)
    --     selectedbone = index
    --     selectedbonename = pnl:GetColumnText(1)
    -- end
end

local devplaybackmult = 1
local devplaybackcycle = 0

function SWEP:DevStuffAnims()
    local DevFrame = vgui.Create("DFrame")
    DevFrame:SetPos(ScrW()/2-(ScrW()-200)/2, 50) 
    DevFrame:SetSize(ScrW()-200, 300) 
    DevFrame:SetTitle("ARC9 Animation table editor - works only in singleplayer in pause menu") 
    DevFrame:SetVisible(true) 
    DevFrame:SetDraggable(true) 
    DevFrame:ShowCloseButton(true) 
    DevFrame:MakePopup()


    ----


    local Controls = DevFrame:Add("Panel")
    Controls:SetTall(20)
    Controls:Dock(BOTTOM)
    Controls:DockMargin(0, 8, 0, 4)
    Controls:MoveToBack()

    local AnimTrack = Controls:Add("DSlider")
    AnimTrack:Dock(FILL)
    AnimTrack:SetNotches(100)
    AnimTrack:SetTrapInside(true)
    AnimTrack:SetLockY(0.5)

    local SeqSelector = Controls:Add("DComboBox")
    SeqSelector:SetValue( "VM sequence" )
	SeqSelector:Dock(LEFT)
	SeqSelector:SetWide(128)

    SeqSelector.OnSelect = function(_, _, value)
        print("------\nHi you need to double press (with a little delay) escape key to apply anim")
        self:GetVM():SendViewModelMatchingSequence(self:GetVM():LookupSequence(value))
    end

    for k, v in ipairs(self:GetVM():GetSequenceList()) do
        SeqSelector:AddChoice(v)

        if v == self:GetVM():GetSequenceName(self:GetVM():GetSequence()) then
            SeqSelector:ChooseOptionID(k)
        end
    end

	local AnimPlay = Controls:Add("DImageButton")
	AnimPlay:SetImage("icon16/control_pause_blue.png")
	AnimPlay:SetStretchToFit(false)
	AnimPlay:SetPaintBackground(true)
	AnimPlay:SetIsToggle(true)
	AnimPlay:SetToggle(false)
	AnimPlay:Dock(LEFT)
	AnimPlay:SetWide(32)

	local PlaybackSpeedMultEntry = Controls:Add("DTextEntry")
	PlaybackSpeedMultEntry:SetPaintBackground(true)
	PlaybackSpeedMultEntry:Dock(RIGHT)
	PlaybackSpeedMultEntry:SetWide(64)
	PlaybackSpeedMultEntry:SetPlaceholderText("Speed mult")
	PlaybackSpeedMultEntry:SetNumeric(true)
	PlaybackSpeedMultEntry.OnEnter = function(no)
        devplaybackmult = no:GetValue()
	end

	local CurFrame = Controls:Add("DLabel")
	CurFrame:Dock(LEFT)
	CurFrame:SetWide(32)
    CurFrame:SetText("  " .. 0)


    ----

    local Animations = DevFrame:Add("Panel")
    Animations:SetTall(20)
    Animations:Dock(TOP)
    Animations:DockMargin(ScrW()/2.5, 0, ScrW()/2.5, 4)
    Animations:MoveToBack()
    
    local AnimSelector = Animations:Add("DComboBox")
    AnimSelector:SetValue("Select animation")
	AnimSelector:Dock(FILL)


    for k, v in pairs(self.Animations) do
        AnimSelector:AddChoice(k)
        AnimSelector:ChooseOptionID(1)
    end
    
    local AddAnimButton = Animations:Add("DImageButton")
    AddAnimButton:SetImage( "icon16/add.png" )
    AddAnimButton:SetSize( 20, 20 )
	AddAnimButton:Dock(RIGHT)
    AddAnimButton.DoClick = function()
        Derma_StringRequest("New animation", "What would you call it?", "", function(text) print("Added new anim to table: " .. text) end, nil, "Add")
    end


    ----

	local EditorPanel = DevFrame:Add("DPropertySheet")
	EditorPanel:Dock(FILL)

	EditorPanelEventTable = EditorPanel:Add("DPanel")
    -- EditorPanelEventTable.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end 
    
	local Keyframes = EditorPanelEventTable:Add("DHorizontalScroller")
    Keyframes:Dock( FILL )
    Keyframes:SetOverlap( -8 )
    
    local KeyframesCount = 0

    local function makekf(time, path, pitch, volume)
        KeyframesCount = KeyframesCount + 1

        Keyframes[KeyframesCount] = Keyframes:Add("DFrame") -- dpanel maybe
        Keyframes[KeyframesCount]:SetDraggable(false)
        Keyframes[KeyframesCount]:ShowCloseButton(false)
        Keyframes[KeyframesCount]:SetWidth(128)

        Keyframes[KeyframesCount].TimeLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].TimeLabel:SetPos( 15, 25 )
        Keyframes[KeyframesCount].TimeLabel:SetText("Time")

        Keyframes[KeyframesCount].Time = Keyframes[KeyframesCount]:Add("DTextEntry")
        Keyframes[KeyframesCount].Time:SetPos(55, 25)
        Keyframes[KeyframesCount].Time:SetPlaceholderText("Time")
        Keyframes[KeyframesCount].Time:SetNumeric(true)
        Keyframes[KeyframesCount].Time:SetValue(time)

        Keyframes[KeyframesCount].SndLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].SndLabel:SetPos(15, 45)
        Keyframes[KeyframesCount].SndLabel:SetText("Sound path")

        Keyframes[KeyframesCount].Snd = Keyframes[KeyframesCount]:Add("DTextEntry")
        Keyframes[KeyframesCount].Snd:SetPos(4, 65)
        Keyframes[KeyframesCount].Snd:SetWidth(120)
        Keyframes[KeyframesCount].Snd:SetPlaceholderText("garrysmod/content_downloaded.wav")
        Keyframes[KeyframesCount].Snd:SetText(path)
        
        Keyframes[KeyframesCount].PitchWangLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].PitchWangLabel:SetPos( 15, 95 )
        Keyframes[KeyframesCount].PitchWangLabel:SetText("Pitch")

        Keyframes[KeyframesCount].PitchWang = Keyframes[KeyframesCount]:Add("DNumberWang")
        Keyframes[KeyframesCount].PitchWang:SetPos(55, 95)
        Keyframes[KeyframesCount].PitchWang:SetMin(0.5)
        Keyframes[KeyframesCount].PitchWang:SetValue(pitch)
        Keyframes[KeyframesCount].PitchWang:SetMax(1.5)
        Keyframes[KeyframesCount].PitchWang:SetInterval(0.05)

        Keyframes[KeyframesCount].VolumeWangLabel = Keyframes[KeyframesCount]:Add("DLabel")
        Keyframes[KeyframesCount].VolumeWangLabel:SetPos( 15, 120 )
        Keyframes[KeyframesCount].VolumeWangLabel:SetText("Volume")

        Keyframes[KeyframesCount].VolumeWang = Keyframes[KeyframesCount]:Add("DNumberWang")
        Keyframes[KeyframesCount].VolumeWang:SetPos(55, 120)
        Keyframes[KeyframesCount].VolumeWang:SetMin(0)
        Keyframes[KeyframesCount].VolumeWang:SetValue(volume)
        Keyframes[KeyframesCount].VolumeWang:SetMax(2)
        Keyframes[KeyframesCount].VolumeWang:SetInterval(0.05)
        
        Keyframes[KeyframesCount].DeleteButton = Keyframes[KeyframesCount]:Add("DButton")
        Keyframes[KeyframesCount].DeleteButton:SetText("Delete")
        Keyframes[KeyframesCount].DeleteButton:SetHeight(16)
        Keyframes[KeyframesCount].DeleteButton:Dock(BOTTOM)

        local nameexloded = string.Explode("/", path)

        Keyframes[KeyframesCount]:SetTitle(nameexloded[#nameexloded]) -- KeyframesCount .. ": " .. 

        Keyframes:AddPanel(Keyframes[KeyframesCount])
    end

    -- makekf(0.1, "wawa/hi.wav", 1, 1)
    
    local function makekfsforanim(animname)
        Keyframes:Remove()
        Keyframes = EditorPanelEventTable:Add("DHorizontalScroller") -- resetting
        Keyframes:Dock( FILL )
        Keyframes:SetOverlap( -8 )
        
        local et = self.Animations[animname].EventTable

        if et then -- we will clear and just add a plus button if no eventtable
            for k, v in ipairs(et) do
                makekf(v.t, v.s, v.p or 1, v.v or 1)
            end
        end

        Keyframes.KeyframesAdd = Keyframes:Add("DButton")
        Keyframes.KeyframesAdd:SetText("+")
        Keyframes.KeyframesAdd:SetWidth(64)
        Keyframes:AddPanel(Keyframes.KeyframesAdd)
    end

    AnimSelector.OnSelect = function(_, _, value)
        print("------\nSelected "..value)
        makekfsforanim(value)
    end


    EditorPanel:AddSheet( "Event Table editor", EditorPanelEventTable)

	EditorPanelIKTable = EditorPanel:Add("DPanel")
    -- EditorPanelEventTable.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end 
    EditorPanel:AddSheet( "LHIK/RHIK editor", EditorPanelIKTable)

	EditorPanelGeneral = EditorPanel:Add("DPanel")
    -- EditorPanelEventTable.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end 
    EditorPanel:AddSheet( "Parameters", EditorPanelGeneral)

    Controls.Think = function(no)
        local vm = self:GetVM()
        local length = vm:SequenceDuration(vm:GetSequence()) * devplaybackmult

	    if AnimTrack:GetDragging() then
            devplaybackcycle = AnimTrack:GetSlideX()
            AnimPlay:SetToggle(false)
        elseif AnimPlay:GetToggle() then
            devplaybackcycle = RealTime()/length%1
	    end

        vm:SetCycle(devplaybackcycle)
        AnimTrack:SetSlideX(devplaybackcycle)
        
        local cursec = math.Round(length*devplaybackcycle/devplaybackmult, 2)
        -- local cursec = math.Round(devplaybackcycle, 2)
        CurFrame:SetText("   " .. cursec)
    end
end

concommand.Add("arc9_dev_togglemenu", function(ply, cmd, args)

    -- add here check for sv_cheats 1 or/and admin

    local wep = ply:GetActiveWeapon()

    if wep.ARC9 then 
        DevMode = !DevMode
        if DevMode then ply:GetActiveWeapon():DevStuffMenu() elseif IsValid(wep.DevFrame) then wep.DevFrame:Close() end
    end
end)

concommand.Add("arc9_dev_toggleanimsmenu", function(ply, cmd, args)

    -- add here check for sv_cheats 1 or/and admin

    local wep = ply:GetActiveWeapon()

    if wep.ARC9 then 
        -- DevMode = !DevMode
        ply:GetActiveWeapon():DevStuffAnims()
    end
end)