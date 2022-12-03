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
