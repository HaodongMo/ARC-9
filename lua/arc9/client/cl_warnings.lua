ARC9.IncompatibleAddons = {
    -- My Hands 8.1
    ["847269692"] = "Causes viewmodel flickering, double viewmodel, may crash when customization menu opens",

    -- My Hands 8
    ["1890577397"] = "Causes viewmodel flickering, double viewmodel, may crash when customization menu opens",

    -- Quick Weapon Menu
    ["306149085"] = "Makes the customize menu mouse unable to appear.",

    -- Neurotec
    ["541434990"] = "Neurotec is ancient, half the base is missing, and it flat-out doesn't work. Causes all sorts of problems. For the love of god, let go.",

    -- Improved Combine NPCs
    ["476997621"] = "Causes issues with arms.",

    -- Realistic Bullet Overhaul
    ["1588705429"] = "Causes damage calculation to not work properly.",

    -- Quake/Half Life View bobbing
    ["378401390"] = "Causes most animations to not play properly.",

    -- Thirteen's Physgun Glow
    ["111249028"] = "Causes LHIK animations to flicker and not work properly.",

    -- Viewmodel Lagger
    ["1146104662"] = "Misaligns viewmodel in sights.",

    -- Viewmodel Lagger (fixed)
    ["2566560460"] = "Misaligns viewmodel in sights.",

    -- VTools
    ["DisplayDistancePlane"] = "Tool contains faulty hook.",

    -- TFA's Tactical Lean
    ["TacticalLean"] = "Mod is old, buggy, laggy, and interferes with ARC9 lean.",

    -- fixed maybe     SLVBase 2 
    -- ["1516699044"] = "Causes black screen",

    -- Minecraft drops
    ["2879200766"] = "Teleports viewmodel to any dropped gun",

    -- Advanced color tool
    ["692778306"] = "Incompatible",

    -- TF2 Killstreak Weapon Sheen
    ["973050319"] = "Fucks up model rendering and other shit",
}

local ScreenScaleMulti = ARC9.ScreenScale

function ARC9.MakeIncompatibleWindow(tbl)
    local startTime = CurTime()

    local window = vgui.Create( "DFrame" )
    window:SetSize( ScrW() * 0.6, ScrH() * 0.6)
    window:Center()
    window:SetTitle("")
    window:SetDraggable(false)
    window:SetVisible(true)
    window:ShowCloseButton(false)
    window:MakePopup()
    window.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
    end

    local title = vgui.Create("DLabel", window)
    title:SetSize(ScreenScaleMulti(256), ScreenScaleMulti(26))
    title:Dock(TOP)
    title:SetFont("ARC9_24")
    title:SetText(ARC9:GetPhrase("incompatible.title"))
    title:DockMargin(ScreenScaleMulti(16), 0, ScreenScaleMulti(16), ScreenScaleMulti(8))

    local desc = vgui.Create("DLabel", window)
    desc:SetSize(ScreenScaleMulti(256), ScreenScaleMulti(12))
    desc:Dock(TOP)
    desc:DockMargin(ScreenScaleMulti(4), 0, ScreenScaleMulti(4), 0)
    desc:SetFont("ARC9_12")
    desc:SetText(ARC9:GetPhrase("incompatible.line1"))
    desc:SetContentAlignment(5)

    local desc2 = vgui.Create("DLabel", window)
    desc2:SetSize(ScreenScaleMulti(256), ScreenScaleMulti(12))
    desc2:Dock(TOP)
    desc2:DockMargin(ScreenScaleMulti(4), 0, ScreenScaleMulti(4), ScreenScaleMulti(4))
    desc2:SetFont("ARC9_12")
    desc2:SetText(ARC9:GetPhrase("incompatible.line2"))
    desc2:SetContentAlignment(5)

    local neverAgain = vgui.Create("DButton", window)
    neverAgain:SetSize(ScreenScaleMulti(256), ScreenScaleMulti(20))
    neverAgain:SetText("")
    neverAgain:Dock(BOTTOM)
    neverAgain:DockMargin(ScreenScaleMulti(48), ScreenScaleMulti(2), ScreenScaleMulti(48), ScreenScaleMulti(2))
    neverAgain.OnMousePressed = function(spaa, kc)
        if CurTime() > startTime + 10 then
            local simpleTbl = {}
            for _, v in pairs(tbl) do simpleTbl[tostring(v.wsid)] = true end
            file.Write("ARC9_incompatible.txt", util.TableToJSON(simpleTbl))
            window:Close()
            window:Remove()
            chat.AddText(Color(255,0,0),ARC9:GetPhrase("incompatible.never.confirm"))
        end
    end
    neverAgain.Paint = function(spaa, w, h)
        local Bfg_col = Color(255, 255, 255, 255)
        local Bbg_col = Color(0, 0, 0, 200)

        if CurTime() > startTime + 10 and spaa:IsHovered() then
            Bbg_col = Color(255, 100, 100, 100)
            Bfg_col = Color(255, 255, 255, 255)
        end

        surface.SetDrawColor(Bbg_col)
        surface.DrawRect(0, 0, w, h)

        local txt = (CurTime() > startTime + 10) and (spaa:IsHovered() and ARC9:GetPhrase("incompatible.never.hover") or ARC9:GetPhrase("incompatible.never")) or ARC9:GetPhrase("incompatible.wait", {time = math.ceil(startTime + 10 - CurTime())})
        surface.SetTextColor(Bfg_col)
        surface.SetTextPos(ScreenScaleMulti(8), ScreenScaleMulti(2))
        surface.SetFont("ARC9_12")
        surface.DrawText(txt)
    end

    local addonList = vgui.Create("DScrollPanel", window)
    addonList:SetText("")
    addonList:Dock(FILL)
    addonList.Paint = function(span, w, h) end
    local sbar = addonList:GetVBar()
    sbar.Paint = function() end
    sbar.btnUp.Paint = function(span, w, h) end
    sbar.btnDown.Paint = function(span, w, h) end
    sbar.btnGrip.Paint = function(span, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(0, 0, w, h)
    end


    local accept = vgui.Create("DButton", window)
    accept:SetSize(ScreenScaleMulti(256), ScreenScaleMulti(20))
    accept:SetText("")
    accept:Dock(BOTTOM)
    accept:DockMargin(ScreenScaleMulti(48), ScreenScaleMulti(2), ScreenScaleMulti(48), ScreenScaleMulti(2))
    accept.OnMousePressed = function(spaa, kc)
        if CurTime() > startTime + 5 then
            window:Close()
            window:Remove()
        end
    end
    accept.Paint = function(spaa, w, h)
        local Bfg_col = Color(255, 255, 255, 255)
        local Bbg_col = Color(0, 0, 0, 200)

        if CurTime() > startTime + 5 and spaa:IsHovered() then
            Bbg_col = Color(255, 255, 255, 100)
            Bfg_col = Color(0, 0, 0, 255)
        end

        surface.SetDrawColor(Bbg_col)
        surface.DrawRect(0, 0, w, h)

        local txt = ARC9:GetPhrase("incompatible.confirm") .. ((CurTime() > startTime + 5) and "" or (" - " .. ARC9:GetPhrase("incompatible.wait", {time = math.ceil(startTime + 5 - CurTime())})))
        surface.SetTextColor(Bfg_col)
        surface.SetTextPos(ScreenScaleMulti(8), ScreenScaleMulti(2))
        surface.SetFont("ARC9_12")
        surface.DrawText(txt)
    end

    for _, addon in pairs(tbl) do
        local addonBtn = vgui.Create("DButton", window)
        addonBtn:SetSize(ScreenScaleMulti(256), ScreenScaleMulti(28))
        addonBtn:Dock(TOP)
        addonBtn:DockMargin(ScreenScaleMulti(36), ScreenScaleMulti(2), ScreenScaleMulti(36), ScreenScaleMulti(2))
        addonBtn:SetFont("ARC9_12")
        addonBtn:SetText("")
        addonBtn:SetContentAlignment(5)
        addonBtn.Paint = function(spaa, w, h)
            local Bfg_col = Color(255, 255, 255, 255)
            local Bbg_col = Color(0, 0, 0, 200)

            if spaa:IsHovered() then
                Bbg_col = Color(255, 255, 255, 100)
                Bfg_col = Color(0, 0, 0, 255)
            end

            surface.SetDrawColor(Bbg_col)
            surface.DrawRect(0, 0, w, h)

            local txt = addon.title
            surface.SetTextColor(Bfg_col)
            surface.SetTextPos(ScreenScaleMulti(18), ScreenScaleMulti(2))
            surface.SetFont("ARC9_12")
            surface.DrawText(txt)

            local txt2 = ARC9.IncompatibleAddons[tostring(addon.wsid)]
            surface.SetTextColor(Bfg_col)
            surface.SetTextPos(ScreenScaleMulti(18), ScreenScaleMulti(16))
            surface.SetFont("ARC9_8")
            surface.DrawText(txt2)
        end
        addonBtn.OnMousePressed = function(spaa, kc)
            if addon.nourl then return end
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. tostring(addon.wsid))
        end
    end
end

function ARC9.DoCompatibilityCheck()
    local incompatList = {}
    local addons = engine.GetAddons()
    for _, addon in pairs(addons) do
        if ARC9.IncompatibleAddons[tostring(addon.wsid)] and addon.mounted then
            incompatList[tostring(addon.wsid)] = addon
        end
    end

    local predrawvmhooks = hook.GetTable().PreDrawViewModel
    if predrawvmhooks and (predrawvmhooks.DisplayDistancePlaneLS or predrawvmhooks.DisplayDistancePlane) then -- vtools lua breaks ARC9 with stupid return in vm hook, ya dont need it if you going to play with guns
        hook.Remove("PreDrawViewModel", "DisplayDistancePlane")
        hook.Remove("PreDrawViewModel", "DisplayDistancePlaneLS")
        incompatList["DisplayDistancePlane"] = {
            title = "Light Sprayer / Scenic Dispenser tool",
            wsid = "DisplayDistancePlane",
            nourl = true,
        }
    end

    local playerspawnhooks = hook.GetTable().PlayerSpawn
    if playerspawnhooks and (playerspawnhooks.PlayerSpawn) then
        incompatList["TacticalLean"] = {
            title = "Tactical Leaning",
            wsid = "TacticalLean",
            nourl = true,
        }
    end

    local shouldDo = true
    -- If never show again is on, verify we have no new addons
    if file.Exists("arc9_incompatible.txt", "DATA") then
        shouldDo = false
        local oldTbl = util.JSONToTable(file.Read("arc9_incompatible.txt"))
        for id, addon in pairs(incompatList) do
            if !oldTbl[id] then shouldDo = true break end
        end
        if shouldDo then file.Delete("arc9_incompatible.txt") end
    end
    if shouldDo and !table.IsEmpty(incompatList) then
        ARC9.MakeIncompatibleWindow(incompatList)
    elseif !table.IsEmpty(incompatList) then
        print("ARC9 ignored " .. table.Count(incompatList) .. " incompatible addons. If things break, it's your fault.")
    end
end

concommand.Add("arc9_dev_showwarnings", ARC9.DoCompatibilityCheck)

hook.Add("InitPostEntity", "ARC9_CheckContent", function()
    for _, k in pairs(weapons.GetList()) do
        if weapons.IsBasedOn(k.ClassName, "arc9_base") and k.ClassName != "arc9_base" then
            return
        end
    end
    chat.AddText(Color(255,255,255), "You have installed the ARC9 base but have no weapons installed. Search the workshop for some!")
end)