ATT.PrintName = "Konstantin Red Dot"
ATT.CompactName = "RDSx1"
ATT.Icon = Material("")
ATT.FullColorIcon = false -- This icon spans the entire area of the material and needs special treatment.
ATT.Description = [[Collimated red dot optic sight.]]
ATT.Pros = {}
ATT.Cons = {}
ATT.SortOrder = 0
ATT.MenuCategory = "ARC-9 - Attachments"

ATT.AdminOnly = false
ATT.Free = false
ATT.Ignore = true

ATT.Model = ""
ATT.WorldModel = "" -- optional
ATT.BoxModel = nil --"models/items/arc9/att_plastic_box.mdl" 
--                                          ^ Use att_plastic_box (modern middle sized container), att_wooden_box (old big box) or att_cardboard_box (cheap small box)
-- If nil, will use slot defined ATT.Pack
ATT.Scale = 1
ATT.ModelOffset = Vector(0, 0, 0)
ATT.ModelAngleOffset = Angle(0, 0, 0)
ATT.DrawFunc = function(swep, model, wm) end
ATT.ModelSkin = 0
ATT.ModelBodygroups = ""
ATT.ModelMaterial = ""

ATT.Material = ""

ATT.InvAtt = "" -- Having this other attachment will grant access to this one.

ATT.Category = "" -- can be "string" or {"list", "of", "strings"}

ATT.Folder = "" -- a string separated by slashes (/), e.g. "my/folder/hierarchy"
-- to give a folder a name, add a localization string "folder.FOLDERNAME"

ATT.ActivateElements = {"plum_stock"}

ATT.ToggleOnF = false -- This attachment is toggleable with the flashlight key.
ATT.ToggleStats = {
    ["On"] = {
        SpreadAddHipFire = -0.1,
    },
    ["Off"] = {}
}
-- max of 256 togglestats

ATT.MuzzleDevice = false -- set to true if you want to use this to emit particles
ATT.MuzzleDevice_Priority = 0

ATT.Flashlight = false
ATT.FlashlightColor = Color(255, 255, 255)
ATT.FlashlightMaterial = Material("")
ATT.FlashlightDistance = 1024
ATT.FlashlightFOV = 70
ATT.FlashlightAttachment = 0

ATT.Laser = false
ATT.LaserStrength = 1
ATT.LaserColor = Color(255, 0, 0)
ATT.LaserAttachment = 0

ATT.Flare = false
ATT.FlareColor = Color(255, 255, 255)
ATT.FlareSize = 200
ATT.FlareAttachment = 0
ATT.FlareFocus = false -- This flare comes from a source of light that persists over distance, like a laser.

-- Allows a custom sight position to be defined

ATT.Sights = {
    {
        Pos = Vector(0, 0, 0),
        Ang = Angle(0, 0, 0),
        ExtraSightData = {
            // like an atttbl, only works for sight related data
        },
        DeferSights = false, // the first parent sight will be used for sight data instead. Use for magnifiers
        Magnification = 1,
        Disassociate = false, // don't associate with parent slot
        IsIronSight = false, // disable if another sight is installed
        KeepBaseIrons = false
    }
}

ATT.HoloSight = false
ATT.HoloSightReticle = ""
ATT.HoloSightSize = 32
ATT.HoloSightColor = Color(255, 255, 255)
ATT.HoloSightColorable = true -- Holosight takes color from player settings
ATT.HoloSightFunc = function(swep, pos, mdl) end -- pos = reticle position
ATT.HoloSightDepthAdjustment = 0.0093 -- Increase this slightly if holosight clips into the model

ATT.FLIRHotFunc = function(swep, ent) end -- return true for hot and false for cold

ATT.RTScope = true
ATT.RTScopeSubmatIndex = 1
ATT.RTScopeFOV = 2.5
ATT.RTScopeRes = 512
ATT.RTScopeReticle = Material("")
ATT.RTScopeReticleScale = 1
ATT.RTScopeShadowIntensity = 1.5
ATT.RTScopeNoPP = false
ATT.RTScopeNoShadow = false
ATT.RTScopeBlackBox = false
ATT.RTScopeBlackBoxShadow = true
ATT.RTScopeColorable = true -- Scope takes color from player settings
-- Lets you draw more things on to the reticle
ATT.RTScopeDrawFunc = function(swep, rtsize) end

ATT.ScopeScreenRatio = 1.4 -- Needed for Cheap Scopes

ATT.RTScopeNightVision = true
ATT.RTScopeNightVisionMonochrome = true
ATT.RTScopeNightVisionCC = {
    ["$pp_colour_addr"] = -255,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = -255,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 4,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}
ATT.RTScopeNightVisionFunc = function(swep) end

ATT.RTScopeFLIR = true
ATT.RTScopeFLIRSolid = false -- Solid color FLIR instead of like a shaded look
ATT.RTScopeFLIRHighlightColor = Color(255, 255, 255)
ATT.RTScopeFLIRMonochrome = true
ATT.RTScopeFLIRNoPP = false
ATT.RTScopeFLIRBlend = 0.25
ATT.RTScopeFLIRCCHot = { -- Color correction drawn only on FLIR targets
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = -255,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 4,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}
ATT.RTScopeFLIRCCCold = { -- Color correction drawn only on FLIR targets
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = -255,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 4,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}
ATT.RTScopeFLIRFunc = function(swep) end

ATT.RTScopeMotionBlur = false

ATT.Attachments = {
    {
        PrintName = "",
        DefaultIcon = Material(""),
        InstalledElements = "", -- single or list of elements to activate when something is installed here
        UnInstalledElements = "",
        Integral = false, -- cannot be removed
        Category = "", -- single or {"list", "of", "values"}
        Bone = "",
        Pos = Vector(0, 0, 0),
        Ang = Angle(0, 0, 0),
        KeepBaseIrons = false,
    }
}

ATT.LHIK = false
ATT.LHIK_Priority = 0

ATT.RHIK = false
ATT.RHIK_Priority = 0

