local ATT = {}

ATT.PrintName = "Baby Crycry"
ATT.CompactName = "BABY"
ATT.Free = true
ATT.Ignore = true -- Remove to use

ATT.Description = [[Baby wants a nap-nap.]]

ATT.MenuCategory = "ARC9 - Charms"

ATT.Model = "models/items/arc9/att_charmbase.mdl"
ATT.BoxModel = "models/items/arc9/att_cardboard_box.mdl"

ATT.CharmModel = "models/props_c17/doll01.mdl"
ATT.CharmBone = "ring3"
ATT.CharmScale = 0.1
ATT.CharmOffset = Vector(0, -0.1, 0.9)
ATT.CharmAngle = Angle(0, 0, 180)

ATT.Category = "charm"

ARC9.LoadAttachment(ATT, "charm_baby")

ATT = {}

ATT.PrintName = "Kill Counter"
ATT.CompactName = "KILLS"
ATT.Icon = Material("entities/arc9_att_charm_gs_killcounter.png", "mips smooth")
ATT.Free = true

ATT.Description = [[Device for tracking your weapon's kill stats.]]

ATT.MenuCategory = "ARC9 - Charms"

ATT.Model = "models/items/arc9/att_screenbase.mdl"
ATT.BoxModel = "models/items/arc9/att_cardboard_box.mdl"

ATT.Category = {"charm", "gunscreen"}


local rtsurf = Material("effects/arc9/gunscreen")

ATT.Hook_OnKill = function(self, ent)
    if SERVER then return end

    -- tracks kills on the basis of weapon class
    local weapon = self:GetClass()
    -- check whether arc9_gunscreen table exists

    if not sql.TableExists("arc9_killcounter") then
        sql.Query("CREATE TABLE arc9_killcounter (weapon TEXT, npckills INTEGER, playerkills INTEGER)")
    end

    local npckills, playerkills = 0, 0

    -- check whether the weapon is already in the table

    if sql.QueryValue("SELECT weapon FROM arc9_killcounter WHERE weapon = '" .. weapon .. "'") then
        npckills = sql.QueryValue("SELECT npckills FROM arc9_killcounter WHERE weapon = '" .. weapon .. "'")
        playerkills = sql.QueryValue("SELECT playerkills FROM arc9_killcounter WHERE weapon = '" .. weapon .. "'")
    else
        sql.Query("INSERT INTO arc9_killcounter (weapon, npckills, playerkills) VALUES ('" .. weapon .. "', 0, 0)")
    end

    if ent:IsNPC() or ent:IsNextBot() then
        npckills = npckills + 1
        sql.Query("UPDATE arc9_killcounter SET npckills = " .. npckills .. " WHERE weapon = '" .. weapon .. "'")
    else
        playerkills = playerkills + 1
        sql.Query("UPDATE arc9_killcounter SET playerkills = " .. playerkills .. " WHERE weapon = '" .. weapon .. "'")
    end

    self.NPCKills = npckills
    self.PlayerKills = playerkills
end

if CLIENT then
    local rtmat = GetRenderTarget("arc9_gunscreen", 256, 256, false)

    ATT.DrawFunc = function(self, model, wm)
        if wm then return end

        render.PushRenderTarget(rtmat, 0, 0, 256, 256)

        render.Clear(0, 0, 0, 0)

        cam.Start2D()

        local text = "KILLS"

        surface.SetFont("ARC9_32_LCD")

        local w, h = surface.GetTextSize(text)

        surface.SetTextPos(128 - w / 2, 32)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(text)

        local text_pk = "PLY | NPC"

        surface.SetFont("ARC9_32_LCD")

        local wpk, hpk = surface.GetTextSize(text_pk)

        surface.SetTextPos(128 - wpk / 2, 64 + 8)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(text_pk)

        local text2 = tostring(self.PlayerKills or 0)

        surface.SetFont("ARC9_48_LCD")

        local w2, h2 = surface.GetTextSize(text2)

        surface.SetTextPos(32, 120)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(text2)

        local text3 = tostring(self.NPCKills or 0)

        surface.SetFont("ARC9_48_LCD")

        local w3, h3 = surface.GetTextSize(text3)

        surface.SetTextPos(256 - w3 - 16, 128 + 48)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(text3)

        cam.End2D()

        render.PopRenderTarget()

        rtsurf:SetTexture("$basetexture", rtmat)

        model:SetSubMaterial()

        model:SetSubMaterial(2, "effects/arc9/gunscreen")
    end
end

ARC9.LoadAttachment(ATT, "charm_gs_killcounter")


ATT = {}

ATT.PrintName = "Basic Clock"
ATT.CompactName = "CLOCK"
ATT.Icon = Material("entities/arc9_att_charm_gs_clock.png", "mips smooth")
ATT.Free = true

ATT.Description = [[Shows the real-world time.]]

ATT.MenuCategory = "ARC9 - Charms"

ATT.Model = "models/items/arc9/att_screenbase.mdl"
ATT.BoxModel = "models/items/arc9/att_cardboard_box.mdl"

ATT.Category = {"charm", "gunscreen"}


if CLIENT then
    local rtmat = GetRenderTarget("arc9_gunscreen", 256, 256, false)

    ATT.DrawFunc = function(self, model, wm)
        if wm then return end

        render.PushRenderTarget(rtmat, 0, 0, 256, 256)

        render.Clear(0, 0, 0, 0)

        cam.Start2D()

        local text = os.date("%H:%M")

        if CurTime() % 2 < 1 then
            text = string.Replace(text, ":", " ")
        end

        surface.SetFont("ARC9_48_LCD")

        local w, h = surface.GetTextSize(text)

        surface.SetTextPos(128 - w / 2, 128 - h / 2 - 24)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(text)

        local text_date = os.date("%d %b")

        surface.SetFont("ARC9_32_LCD")

        local w_date, h_date = surface.GetTextSize(text_date)

        surface.SetTextPos(128 - w_date / 2, 128 - h_date / 2 + 24)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(text_date)

        cam.End2D()

        render.PopRenderTarget()

        rtsurf:SetTexture("$basetexture", rtmat)

        model:SetSubMaterial()

        model:SetSubMaterial(2, "effects/arc9/gunscreen")
    end
end

ARC9.LoadAttachment(ATT, "charm_gs_clock")

ATT = {}

ATT.PrintName = "Sticker Panel"
ATT.CompactName = "STICKER"
ATT.Icon = Material("entities/arc9_att_charm_gs_sticker.png", "mips smooth")
ATT.Free = true

ATT.Description = [[Allows a sticker to be applied to the screen.]]

ATT.MenuCategory = "ARC9 - Charms"

ATT.Model = "models/items/arc9/att_screenbase.mdl"
ATT.BoxModel = "models/items/arc9/att_cardboard_box.mdl"

ATT.Category = {"charm", "gunscreen"}

ATT.Attachments = {
    {
        PrintName = ARC9:GetPhrase("attachment.sticker"),
        StickerModel = "models/items/arc9/sticker_screenbase.mdl",
        Category = "stickers",
        Pos = Vector(0, 0, 0),
        Ang = Angle(0, 0, 0),
        Icon_Offset = Vector(-2, 0, 0)
    }
}

ARC9.LoadAttachment(ATT, "charm_gs_sticker")
