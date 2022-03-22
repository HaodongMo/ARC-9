-- Here, you can mass-define attachments in order to save on Lua files.
-- Defining attachments here can be messy, but can reduce loading time.
-- In addition, make sure to name your attachments uniquely!

local ATT = {}

ATT.PrintName = "Konstantin Red Dot"
ATT.CompactName = "RDSx1"
ATT.Icon = Material("")
ATT.Description = [[Collimated red dot optic sight.]]
ATT.Pros = {}
ATT.Cons = {}
ATT.SortOrder = 0
ATT.MenuCategory = "ARC-9 - Attachments"

Arc9.LoadAttachment(ATT, "optic_rds")
