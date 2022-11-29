AddCSLuaFile()

SWEP.Spawnable = false
SWEP.Category = "ARC-9"
SWEP.AdminOnly = false

-- IMPORTANT:
-- ARC9 uses a procedural stat system.
-- You can create a huge number of weapon stats with this system.
-- Simply chain a Base with an optional Modifier and then optionally a Condition.
-- Base stats are all laid out in this file.
-- Modifiers: Add, Mult, Override, Hook. If no modifier is specified, it will default to an override.
-- Conditions:
-- True (Enabled when TrueNames is active)
-- Silenced
-- UBGL (Enabled when UBGL is active)
-- MidAir
-- Crouch
-- Reload (While reloading)
-- FirstShot
-- Empty
-- EvenShot
-- OddShot
-- EvenReload
-- OddReload
-- BlindFire
-- Sights
-- HipFire
-- Hot (Scales with overheat)
-- Shooting (Enabled when constantly shooting)
-- Recoil (Scales with long bursts)
-- Move (Scaled with move speed)

-- Example:
-- VisualRecoil (Base), Mult (Modifier), Sights (Condition)
-- Usage:
-- SWEP.VisualRecoilMultSights = 0.1
-- This stat will reduce the visual recoil when in sights by 90%.

-- Another example:
-- DamageMax (Base) FirstShot (Condition)
-- Usage:
-- SWEP.DamageMaxFirstShot = 100
-- This will give the gun a close-range damage of 100 for the first shot in a burst.

-- One more example:
-- DamageMin (Base) Mult (Modifier)
-- Usage:
-- SWEP.DamageMinMult = 0.9
-- This will reduce the long range damage of the gun by 10%.

-- The following are INCORRECT:
-- VisualRecoilMultSightsMult (VisualRecoil is the base, not VisualRecoilMult. Also, modifier always comes before condition.)
-- SpreadMoveMult (Modifier comes between base and condition)
-- MultSpeed (Base is always first)
-- SpeedSightsMult (Condition is always last)
-- ReloadTimeAddMult (One modifier max, per stat)

-- For more information, see README.md

-- Any string can be replaced with a localized string by using # in front of it.
-- Get the appropriate localized string for the weapon with #WEAPON_NAME_VARIABLE.
-- For example, #ARC9_BASE_PRINTNAME.
-- Otherwise, it'll just use the direct string.
-- If a localized string is unavailable in your language, English will be used. Otherwise, the default language will be used.

SWEP.PrintName = "ARC9 Base"
SWEP.TrueName = nil
-- PrintName could be a game's fictional name for a gun, while TrueName is its real name.
-- You could also have it be a generic name, like "Assault Rifle" vs. "AK-47".
-- TrueName should be something that improves the cross-compatibility of weapon naming.

SWEP.Class = "Unclassified Weapon"
SWEP.Trivia = {} -- Optional. Any stats you like can be added.  Number in end of title orders line in list (otherwise they will be in alphabet in menus). "_" will be replaced with space
-- SWEP.Trivia = {
--     Manufacturer1 = "Arctic Armament International",
--     Calibre2 = "9x21mm Jager",
--     Mechanism3 = "Roller-Delayed Blowback",
--     Country4 = "UK-Australia-China",
--     Year5 = 2022
-- }
SWEP.Credits = {}
-- SWEP.Credits = {   -- Number in end of title orders line in list (otherwise they will be in alphabet in menus). "_" will be replaced with space
--     Author1 = "Arctic",
--     Contact2 = "https://steamcommunity.com/id/ArcticWinterZzZ/",
-- }

SWEP.Description = [[Description Unavailable.]]
-- Multi-line strings are possible with the double square brackets.]]

SWEP.UseHands = true -- Same as weapon_base
SWEP.DefaultSelectIcon = nil -- Material(), use if auto select icons aren't generated yet or in case player has it turned off

SWEP.ViewModel = ""
SWEP.WorldModel = "" -- If you are going to MirrorVMWM: Put here some optimized model with collisions. Css/hl2 weapon worldmodels that are included in gmod are great for it - like "models/weapons/w_rif_m4a1.mdl"

SWEP.MirrorVMWM = false -- Use this to use the viewmodel as a worldmodel.
-- Highly recommended to save effort!
SWEP.WorldModelMirror = nil -- Use this to set a lower-quality version of the viewmodel, with the same bone structure, as a worldmodel, to take advantage of MirrorVMWM without having to use the viewmodel.
SWEP.WorldModelOffset = nil
-- SWEP.WorldModelOffset = {
--     Pos = Vector(0, 0, 0), -- non tpik (while on ground, on npc etc) 
--     Ang = Angle(0, 0, 0),
--     TPIKPos = Vector(0, 0, 0), -- arc9_tpik 1, you can make cool poses with it
--     TPIKAng = Angle(0, 0, 0),
--     Scale = 1
-- }
SWEP.NoTPIK = false
SWEP.NoTPIKVMPos = false -- TPIK position is not affected by viewmodel position
SWEP.Material = ""

SWEP.Crosshair = false
SWEP.LauncherCrosshair = false -- Force the launcher crosshair
SWEP.MissileCrosshair = false -- Force the missile launcher crosshair

SWEP.ViewModelFOVBase = nil -- Set to override viewmodel FOV

SWEP.NotAWeapon = false -- Set to true to indicate that this is not a weapon.
-- Disables pretty much all base features except for controls and aesthetics, allowing for custom weapons to be implemented.

-------------------------- SAVING

SWEP.SaveBase = nil -- set to a weapon class to make this weapon share saves with it.

-------------------------- DEFAULT ELEMENTS

-- Using MirrorVMWM will use viewmodel parameters for the world model.

SWEP.DefaultBodygroups = ""
-- {
--     {
--         ind = 0,
--         bg = 0,
--     }
-- }

SWEP.DefaultWMBodygroups = ""

SWEP.DefaultSkin = 0

-------------------------- DAMAGE PROFILE

SWEP.DamageMax = 20 -- Damage done at point blank range
SWEP.DamageMin = 15 -- Damage done at maximum range

SWEP.ImpactForce = 8 -- Force that bullets apply on hit

SWEP.DamageRand = 0 -- Damage varies randomly per shot by this fraction. 0.1 = +- 10% damage per shot.

SWEP.RangeMin = 0 -- How far bullets retain their maximum damage for.
SWEP.RangeMax = 5000 -- In Hammer units, how far bullets can travel before dealing DamageMin.
SWEP.Distance = 33000 -- In Hammer units, how far bullets can travel, period.

SWEP.Num = 1 -- Number of bullets to shoot

SWEP.DistributeDamage = false -- If true, damage is distributed evenly across all bullets. If false, damage is dealt to the first bullet only.

SWEP.Penetration = 5 -- Units of wood that can be penetrated by this gun.
SWEP.PenetrationDelta = 0.1 -- The damage multiplier after all penetration distance is spent.

SWEP.RicochetAngleMax = 45 -- Maximum angle at which a ricochet can occur. Between 1 and 90. Angle of 0 is impossible but would theoretically always ricochet.
SWEP.RicochetChance = 0.5 -- If the angle is right, what is the chance that a ricochet can occur?
SWEP.RicochetSeeking = false -- Whether ricochet bullets will seek living targets in a cone.
SWEP.RicochetSeekingAngle = 30
SWEP.RicochetSeekingRange = 1024

SWEP.DamageType = DMG_BULLET -- The damage type of the gun.
-- DMG_BLAST will create explosive effects and create AOE damage.
-- DMG_BURN will ignite the target.
-- DMG_AIRBOAT will damage Combine Hunter-Choppers.

SWEP.ArmorPiercing = 0 -- Between 0-1. A proportion of damage that is done as direct damage, ignoring protection.

SWEP.HeadshotDamage = 1.25
SWEP.ChestDamage = 1.05
SWEP.StomachDamage = 1
SWEP.ArmDamage = 0.9
SWEP.LegDamage = 0.9

SWEP.BodyDamageMults = {
    [HITGROUP_HEAD] = 2.5,
    [HITGROUP_CHEST] = 1.15,
    [HITGROUP_STOMACH] = 1,
    [HITGROUP_LEFTARM] = 1,
    [HITGROUP_RIGHTARM] = 1,
    [HITGROUP_LEFTLEG] = 0.9,
    [HITGROUP_RIGHTLEG] = 0.9,
}

-- Set the multiplier for each part of the body.
-- If a limb is not set the damage multiplier will default to 1
-- That means gmod's stupid default limb mults will **NOT** apply
-- {
--     [HITGROUP_HEAD] = 1.25,
--     [HITGROUP_CHEST] = 1,
--     [HITGROUP_LEFTARM] = 0.9,
--     [HITGROUP_RIGHTARM] = 0.9,
-- }

SWEP.ExplosionDamage = 0
SWEP.ExplosionRadius = 0
SWEP.ExplosionEffect = nil

-------------------------- ENTITY LAUNCHING

SWEP.ShootEnt = nil -- Set to an entity to launch it out of this weapon.
SWEP.ShootEntForce = 10000
SWEP.ShootEntInheritPlayerVelocity = false -- Set to true to inherit velocity
SWEP.ShootEntityData = {} -- Extra data that can be given to a projectile. Sets SENT.WeaponDataLink with this table.

SWEP.Throwable = false -- Set to true to give this weapon throwing capabilities.
SWEP.Tossable = true -- When grenade is enabled, right click will toss. Set to false to disable, allowing you to aim down sights.
SWEP.ThrowAnimSpeed = 1

SWEP.FuseTimer = -1 -- Length of time that the grenade will take to explode in your hands. -1 = Won't explode.

SWEP.ThrowForceMin = 3000 -- Minimum force that the grenade will be thrown with.
SWEP.ThrowForceMax = 5000 -- Maximum force that the grenade will be thrown with.
SWEP.TossForce = 500 -- Force that the grenade will be thrown with when right clicked.

SWEP.ThrowChargeTime = 1 -- How long it takes to charge the grenade to its maximum throw force.

SWEP.ThrowTumble = true -- Grenade tumbles when thrown.

-------------------------- PHYS BULLET BALLISTICS

-- These settings override the player's physical bullet options.
SWEP.AlwaysPhysBullet = false
SWEP.NeverPhysBullet = false

SWEP.PhysBulletMuzzleVelocity = 150000 -- Physical bullet muzzle velocity in Hammer Units/second. 1 HU != 1 inch.
SWEP.PhysBulletDrag = 1 -- Drag multiplier
SWEP.PhysBulletGravity = 1 -- Gravity multiplier
SWEP.PhysBulletDontInheritPlayerVelocity = false -- Set to true to disable "Browning Effect"

SWEP.FancyBullets = false -- set to true to allow for multicolor mags and crap
-- Each bullet runs HookP_ModifyBullet, within which modifications can be made

-- if true, bullets follow the player's cursor
SWEP.BulletGuidance = false
SWEP.BulletGuidanceAmount = 15000 -- the amount of guidance to apply

-- Make the physical bullet use a model instead of the tracer effect.
-- You MUST register the model beforehand in a SHARED context (such as the SWEP file) like so: ARC9:RegisterPhysBulletModel("models/weapons/w_missile.mdl")
SWEP.PhysBulletModel = nil
SWEP.PhysBulletModelStick = nil -- The amount of time a physbullet model will stick on impact.

-------------------------- TRACERS

SWEP.TracerNum = 1 -- Tracer every X
SWEP.TracerFinalMag = 0 -- The last X bullets in a magazine are all tracers
SWEP.TracerEffect = "ARC9_tracer" -- The effect to use for hitscan tracers
SWEP.TracerColor = Color(255, 255, 255) -- Color of tracers. Only works if tracer effect supports it. For physical bullets, this is compressed down to 9-bit color.
SWEP.TracerSize = 1

-------------------------- MAGAZINE

SWEP.Ammo = "pistol" -- What ammo type this gun uses.

SWEP.ChamberSize = 1 -- The amount of rounds this gun can chamber.
SWEP.ClipSize = 25 -- Self-explanatory.
SWEP.SupplyLimit = 5 -- Amount of magazines of ammo this gun can take from an ARC-9 supply crate.
SWEP.SecondarySupplyLimit = 2 -- Amount of reserve UBGL magazines you can take.

SWEP.ForceDefaultClip = nil -- Set to force a default amount of ammo this gun can have. Otherwise, this is controlled by console variables.

SWEP.AmmoPerShot = 1 -- Ammo to use per shot
SWEP.InfiniteAmmo = false -- Weapon does not take from reserve ammo
SWEP.BottomlessClip = false -- Weapon never has to reload

SWEP.ShotgunReload = false -- Weapon reloads like shotgun. Uses insert_1, insert_2, etc animations instead.
SWEP.HybridReload = false -- Enable on top of Shotgun Reload. If the weapon is completely empty, use the normal reload animation.
-- Use SWEP.Hook_TranslateAnimation in order to do custom animation stuff.

SWEP.ManualActionChamber = 1 -- How many shots we go between needing to cycle again.
SWEP.ManualAction = false -- Pump/bolt action. Play the "cycle" animation after firing, when the trigger is released.
SWEP.ManualActionNoLastCycle = false -- Do not cycle on the last shot.
SWEP.ManualActionEjectAnyway = false -- Eject a shell when firing anyway.
SWEP.EjectDelay = 0 -- When eject shell on cycle (pretty dumb, better'd just use EjectAt)

SWEP.ReloadWhileSprint = true -- This weapon can reload while the user is sprinting.
SWEP.ReloadInSights = true -- This weapon can aim down sights while reloading.
SWEP.PartialReloadCountsTowardsNthReload = true -- If the gun is not empty, it counts towards the Nth reload. Useful for guns with spare magazine animations.

SWEP.CanFireUnderwater = false -- This weapon can shoot while underwater.

SWEP.Disposable = false -- When all ammo is expended, this gun will remove itself from the inventory.

SWEP.AutoReload = false -- When the gun is drawn, it will automatically reload.

SWEP.TriggerDelay = 0 -- Set to > 0 to play the "trigger" animation before shooting. Delay time is based on this value.

SWEP.ShouldDropMag = false
SWEP.ShouldDropMagEmpty = true

SWEP.DropMagazineModel = nil -- Set to a string or table to drop this magazine when reloading.
SWEP.DropMagazineSounds = {} -- Table of sounds a dropped magazine should play.
SWEP.DropMagazineAmount = 1 -- Amount of mags to drop.
SWEP.DropMagazineSkin = 0 -- Model skin of mag.
SWEP.DropMagazineTime = 0.25
SWEP.DropMagazineQCA = nil -- QC Attachment drop mag from, would drop from shell port if not defined
SWEP.DropMagazinePos = Vector(0, 0, 0) -- offsets
SWEP.DropMagazineAng = Angle(0, 0, 0)
SWEP.DropMagazineVelocity = Vector(0, 0, 0) -- Put something here if your anim throws the mag with force

-------------------------- FIREMODES

SWEP.RPM = 750

SWEP.TriggerDelay = false -- Add a delay before the weapon fires.
SWEP.TriggerDelayTime = 0.2 -- Time until weapon fires.
SWEP.TriggerDelayRepeat = false -- Whether to do it for every shot on automatics.

-- Works different to ArcCW

-- -1: Automatic
-- 0: Safe. Don't use this for safety.
-- 1: Semi.
-- 2: Two-round burst.
-- 3: Three-round burst.
-- n: n-round burst.
SWEP.Firemodes = {
    {
        Mode = 1,
        -- add other attachment modifiers
    }
}

SWEP.SlamFire = false -- Manual action weapons cycle themselves

SWEP.AutoBurst = false -- Hold fire to keep firing bursts
SWEP.PostBurstDelay = 0
SWEP.RunawayBurst = false -- Burst will keep firing until all of the burst has been expended.

SWEP.Akimbo = false

-- Use this hook to modify features of a firemode.
-- SWEP.HookP_ModifyFiremode = function(self, firemode) return firemode end

-------------------------- RECOIL

SWEP.RecoilSeed = nil -- Leave blank to use weapon class name as recoil seed.
-- Should be a number.
SWEP.RecoilPatternDrift = 12 -- Higher values = more extreme recoil patterns.
SWEP.RecoilLookupTable = nil -- Use to set specific values for predictible recoil. If it runs out, it'll just use Recoil Seed.
-- SWEP.RecoilLookupTable = {
--     15,
--     3,
-- }
SWEP.RecoilLookupTableOverrun = nil -- Repeatedly take values from this table if we run out in the main table

-- General recoil multiplier
SWEP.Recoil = 1

-- These multipliers affect the predictible recoil by making the pattern taller, shorter, wider, or thinner.
SWEP.RecoilUp = 1 -- Multiplier for vertical recoil
SWEP.RecoilSide = 1 -- Multiplier for vertical recoil

-- This is for recoil that goes directly to camera, makes gun shoot where sights at but center of screen will be in different place. Like escape from t
SWEP.ViewRecoil = nil -- true
SWEP.ViewRecoilUpMult = nil -- 40-100
SWEP.ViewRecoilSideMult = nil -- 1-20

-- These values determine how much extra movement is applied to the recoil entirely randomly, like in a circle.
-- This type of recoil CANNOT be predicted.
SWEP.RecoilRandomUp = 0.1
SWEP.RecoilRandomSide = 0.1

SWEP.RecoilDissipationRate = 10 -- How much recoil dissipates per second.
SWEP.RecoilResetTime = 0.1 -- How long the gun must go before the recoil pattern starts to reset.

SWEP.RecoilAutoControl = 1 -- Multiplier for automatic recoil control.

SWEP.PushBackForce = 0 -- Push the player back when shooting.

-- SInput rumble configuration
-- Max of 65535
SWEP.RumbleHeavy = 30000
SWEP.RumbleLight = 30000
SWEP.RumbleDuration = 0.12

-------------------------- UBGL
-- Underbarrel weapons
-- Stats that BEGIN with UBGL are actual specific stats
SWEP.UBGL = false
SWEP.UBGLAmmo = "smg1_grenade"
SWEP.UBGLClipSize = 1
SWEP.UBGLFiremode = 1
SWEP.UBGLFiremodeName = "UBGL"
SWEP.UBGLChamberSize = 0
SWEP.UBGLInsteadOfSights = false -- Right clicking fires UBGL instead of going into irons.

-- Otherwise, these are just stats that get overwritten when selecting a UBGL.
SWEP.AmmoPerShotUBGL = 1
SWEP.SpreadUBGL = 0.0
SWEP.RecoilUBGL = 1
SWEP.DoFireAnimationUBGL = true
SWEP.NoShellEjectUBGL = true
SWEP.ManualActionUBGL = false
SWEP.ShouldDropMagUBGL = false

-------------------------- VISUAL RECOIL

SWEP.UseVisualRecoil = false

SWEP.PhysicalVisualRecoil = true -- Visual recoil actually affects your aim point.

SWEP.VisualRecoilUp = 0.01 -- Vertical tilt for visual recoil.F
SWEP.VisualRecoilSide = 0.05 -- Horizontal tilt for visual recoil.
SWEP.VisualRecoilRoll = 0.23 -- Roll tilt for visual recoil.

SWEP.VisualRecoilCenter = Vector(2, 4, 2) -- The "axis" of visual recoil. Where your hand is.

SWEP.VisualRecoilPunch = 1.5 -- How far back visual recoil moves the gun.
SWEP.VisualRecoilPunchMultSights = 0.1

-- SWEP.VisualRecoilMult = 1
-- SWEP.VisualRecoilADSMult = 0.1
-- SWEP.VisualRecoilPunchADSMult = 0.1

SWEP.VisualRecoil = 1
SWEP.VisualRecoilMultSights = 0.1
SWEP.VisualRecoilPositionBump = 1.5

SWEP.VisualRecoilHipFire = 1

SWEP.VisualRecoilDampingConst = nil -- How spring will be visual recoil, 120 is default
SWEP.VisualRecoilSpringMagnitude = 1

SWEP.RecoilKick = 1 -- Camera recoil
SWEP.RecoilKickDamping = 70.151 -- Camera recoil damping

SWEP.FOV_RecoilAdd = 0 -- FOV to increase or decrease by.
SWEP.FOV_Recoil_TimeStart = 0.05 -- Peak
SWEP.FOV_Recoil_TimeEnd = 0.15 -- Until dropoff
-- https://wiki.facepunch.com/gmod/math.ease
SWEP.FOV_Recoil_FuncStart = math.ease.OutCirc -- Function to use
SWEP.FOV_Recoil_FuncEnd = math.ease.InCirc

-------------------------- SPREAD

SWEP.Spread = 0

SWEP.UsePelletSpread = false -- Multiple bullets fired at once clump up, like for a shotgun. Spread affects which direction they get fired, not their spread relative to one another.
SWEP.PelletSpread = 0.2

SWEP.PelletSpreadPattern = {} -- Use to give shotguns custom spread patterns. If Pellet Spread is off, each pellet will be subject to spread. Otherwise, the entire pattern shifts, and each pellet is randomly offset by pellet spread amount.

-- SWEP.PelletSpreadPattern = {
--     {
--         x = -1,
--         y = -1
--     },
--     {
--         x = -1,
--         y = 1
--     }
-- }

SWEP.PelletSpreadPatternOverrun = nil
-- {Angle(1, 1, 0), Angle(1, 0, 0) ..}
-- list of how far each pellet should veer
-- if only one pellet then it'll use the first index
-- if two then the first two
-- in case of overrun pellets will start looping, preferably with the second one, so use that for the loopables

SWEP.SpreadAddMove = 0 -- Applied when speed is equal to walking speed.
SWEP.SpreadAddMidAir = 0 -- Applied when not touching the ground.
SWEP.SpreadAddHipFire = 0 -- Applied when not sighted.
SWEP.SpreadAddSighted = 0 -- Applied when sighted. Can be negative.
SWEP.SpreadAddBlindFire = 0 -- Applied when blind firing.
SWEP.SpreadAddCrouch = 0 -- Applied when crouching.

SWEP.SpreadAddRecoil = 0 -- Applied per unit of recoil.

-------------------------- HANDLING

SWEP.FreeAimRadius = 10 -- In degrees, how much this gun can free aim in hip fire.
SWEP.Sway = 1 -- How much the gun sways.

SWEP.HoldBreathTime = 5 -- time that you can hold breath for
SWEP.RestoreBreathTime = 10

SWEP.FreeAimRadiusMultSights = 0.25

SWEP.SwayMultSights = 0.5

SWEP.AimDownSightsTime = 0.25 -- How long it takes to go from hip fire to aiming down sights.
SWEP.SprintToFireTime = 0.25 -- How long it takes to go from sprinting to being able to fire.

SWEP.NoSprintWhenLocked = false -- You cannot sprint while reloading with this gun

SWEP.ReloadTime = 1
SWEP.DeployTime = 1
SWEP.CycleTime = 1
SWEP.FixTime = 1
SWEP.OverheatTime = 1

SWEP.ShootWhileSprint = false

SWEP.Speed = 1

SWEP.SpeedMult = 1
SWEP.SpeedMultSights = 0.75
SWEP.SpeedMultShooting = 0.9
SWEP.SpeedMultMelee = 0.75
SWEP.SpeedMultCrouch = 1
SWEP.SpeedMultBlindFire = 1

-------------------------- MELEE

SWEP.Bash = false
SWEP.PrimaryBash = false

SWEP.BashDamage = 50
SWEP.BashLungeRange = 64
SWEP.BashRange = 64
SWEP.PreBashTime = 0.5
SWEP.PostBashTime = 0.5
SWEP.BashDecal = "ManhackCut"

SWEP.BashThirdArmAnimation = {
        rig = "models/weapons/arc9/lhik/c_thirdarm_pdw.mdl",
        sequence = {"melee1", "melee2"},
        -- sequence = "melee1",
        gun_controller_attachment = 1,
        -- offsetang = Angle(90, 180, 90),
        mult = 1,
        invisible = false,
    }

-------------------------- MALFUNCTIONS

SWEP.Overheat = false -- Weapon will jam when it overheats, playing the "overheat" animation.
SWEP.HeatPerShot = 1
SWEP.HeatCapacity = 1 -- rounds that can be fired non-stop before the gun jams, playing the "fix" animation
SWEP.HeatDissipation = 10 -- rounds' worth of heat lost per second
SWEP.HeatLockout = true -- overheating means you cannot fire until heat has been fully depleted
SWEP.HeatDelayTime = 0.5 -- Amount of time that passes before heat begins to dissipate.
SWEP.HeatFix = false -- when the "overheat" animation is played, all heat is restored.

-- If Malfunction is enabled, the gun has a random chance to be jammed
-- after the gun is jammed, it won't fire unless reload is pressed, which plays the "fix" animation
-- if no "fix" or "cycle" animations exist, the weapon will reload instead
-- When the trigger is pressed, the gun will try to play the "jamfire" animation. Otherwise, it will try "dryfire". Otherwise, it will do nothing.
SWEP.Malfunction = false
SWEP.MalfunctionJam = true -- After a malfunction happens, the gun will dryfire until reload is pressed. If unset, instead plays animation right after.  -- are you sure? doesnt seem to work
SWEP.MalfunctionNeverLastShoot = true -- Last round will never cause malfunctions (so guns with empty animations wont be fucky)
SWEP.MalfunctionCycle = false -- ManualAction = true only: Roll malfunction roullete not after shoot but before every cycle anim
SWEP.MalfunctionWait = 0 -- The amount of time to wait before playing malfunction animation (or can reload)
SWEP.MalfunctionMeanShotsToFail = 1000 -- The mean number of shots between malfunctions, will be autocalculated if nil

-------------------------- HOOKS

-- SWEP.Hook_Draw = function(self, vm) end # Called when the weapon is drawn. Call functions here to modify the viewmodel, such as drawing RT screens onto the gun.
-- SWEP.Hook_HUDPaint = function(self) end
-- SWEP.Hook_HUDPaintBackground = function(self) end
-- SWEP.Hook_RTScopeReticle = function(self, {rtsize = num, rtmat = Material})
-- SWEP.Hook_ModifyRecoilDir = function(self, dir) return dir end # direction of recoil in degrees, 0 = up
-- SWEP.HookP_ModifyFiremode = function(self, firemode) return firemode end
-- SWEP.HookC_DrawBullet = function(self, bullet) return bool end -- called when a bullet gets drawn, return true to prevent drawing bullet
-- SWEP.HookP_ModifyBullet = function(self, bullet) return end # bullet = phys bullet table, modify in place, does not accept return
-- SWEP.HookP_ModifyNewBullet = function(self, bullet) return end # bullet = phys bullet table, modify in place, does not accept return
-- SWEP.HookP_BlockFire = function(self) return block end # return true to block firing
-- SWEP.Hook_ModifyBodygroups = function(self, data) return end # data = {model = Model, elements = {"table" = true, "of" = true, "elements" = true}}
-- SWEP.HookP_ModifyBulletPoseParam = function(self, pp) return pp end
-- SWEP.HookP_ModifyFiremodePoseParam = function(self, pp) return pp end
-- SWEP.Hook_DoRT = function(self) return end
-- SWEP.Hook_Think = function(self) return end
-- SWEP.Hook_Deploy = function(self) return end
-- SWEP.Hook_Holster = function(self) return end
-- SWEP.Hook_GetShootEntData = function(self, table) return end -- Each function should add an entry to the table for shoot ents
-- SWEP.HookP_NameChange = function(self, name) return name end
-- SWEP.HookP_DescriptionChange = function(self, desc) return desc end
-- SWEP.Hook_BlockAnimation = function(self, anim) return block end -- Return true to block animation from playing.
-- SWEP.Hook_PrimaryAttack = function(self) return end -- Called when the primary attack is fired.
-- SWEP.Hook_SwitchSight = function(self, newsight) return end -- Called when a sight is switched.
-- SWEP.Hook_ToggleAtts = function(self) return end -- Called when attachments are toggled with F.

-------------------------- BLIND FIRE

SWEP.CanBlindFire = true -- This weapon is capable of blind firing.
SWEP.BlindFireLHIK = true -- Hide the left hand while blind firing forward.

SWEP.BlindFireLeft = true
SWEP.BlindFireRight = false -- This weapon can blind fire towards the right. Generally keep this off.

SWEP.BlindFireOffset = Vector(0, 0, 32) -- The amount by which to offset the blind fire muzzle.
SWEP.BlindFirePos = Vector(-6, -4, 12)
SWEP.BlindFireAng = Angle(0, 0, -45)

SWEP.BlindFireRightOffset = Vector(0, 24, 0) -- The amount by which to offset the blind fire muzzle.
SWEP.BlindFireRightPos = Vector(-12, 12, 0)
SWEP.BlindFireRightAng = Angle(-90, 0, 0)

SWEP.BlindFireLeftOffset = Vector(0, 24, 0) -- The amount by which to offset the blind fire muzzle.
SWEP.BlindFireLeftPos = Vector(12, 10, 0)
SWEP.BlindFireLeftAng = Angle(90, 0, 0)

SWEP.BlindFireBoneMods = {
    ["ValveBiped.Bip01_R_UpperArm"] = {
        ang = Angle(45, -90, 0),
        pos = Vector(0, 0, 0)
    },
    ["ValveBiped.Bip01_R_Hand"] = {
        ang = Angle(-90, 0, 0),
        pos = Vector(0, 0, 0)
    }
}
SWEP.BlindFireLeftBoneMods = {
    ["ValveBiped.Bip01_R_UpperArm"] = {
        ang = Angle(45, 0, 0),
        pos = Vector(0, 0, 0)
    },
    ["ValveBiped.Bip01_R_Hand"] = {
        ang = Angle(0, -75, 0),
        pos = Vector(0, 0, 0)
    }
}

SWEP.BlindFireRightBoneMods = {
    ["ValveBiped.Bip01_R_UpperArm"] = {
        ang = Angle(-45, 0, 0),
        pos = Vector(0, 0, 0)
    },
    ["ValveBiped.Bip01_R_Hand"] = {
        ang = Angle(0, 75, 0),
        pos = Vector(0, 0, 0)
    }
}

-------------------------- NPC

SWEP.NotForNPCs = false -- Won't be given to NPCs.
SWEP.NPCWeight = 100 -- How likely it is for an NPC to get this weapon as opposed to other weapons.

-------------------------- BIPOD

SWEP.Bipod = false -- This weapon comes with a bipod.
SWEP.RecoilMultBipod = 0.25
SWEP.SwayMultBipod = 0.25
SWEP.FreeAimRadiusMultBipod = 0

-------------------------- SOUNDS

SWEP.ShootVolume = 125
SWEP.ShootVolumeActual = 1
SWEP.ShootPitch = 100
SWEP.ShootPitchVariation = 0.05

SWEP.FirstShootSound = nil                      -- First fire
SWEP.ShootSound = ""                            -- Fire
SWEP.ShootSoundIndoor = nil                     -- Fire indoors
SWEP.ShootSoundSilenced = ""                    -- Fire silenced
SWEP.ShootSoundIndoorSilenced = nil             -- Fire indoors silenced
SWEP.FirstShootSoundSilenced = nil              -- First fire silenced
SWEP.FirstDistantShootSound = nil               -- First distant fire
SWEP.DistantShootSound = ""                     -- Distant fire
SWEP.DistantShootSoundIndoor = nil              -- Distant fire indoors
SWEP.DistantShootSoundSilenced = nil            -- Distant fire silenced
SWEP.DistantShootSoundIndoorSilenced = nil      -- Distant fire indoors silenced
SWEP.FirstDistantShootSoundSilenced = nil       -- First distant fire silenced


SWEP.ShootSoundLooping = nil
SWEP.ShootSoundLoopingSilenced = nil
SWEP.ShootSoundLoopingIndoor = nil
SWEP.ShootSoundTail = nil -- played after the loop ends
SWEP.ShootSoundTailIndoor = nil

SWEP.Silencer = false -- Silencer installed or not?

SWEP.DistantShootSound = nil

SWEP.DryFireSound = ""

SWEP.FiremodeSound = "arc9/firemode.wav"
SWEP.ToggleAttSound = "items/flashlight1.wav"

SWEP.EnterSightsSound = ""
SWEP.ExitSightsSound = ""

SWEP.EnterBipodSound = ""
SWEP.ExitBipodSound = ""

SWEP.EnterUBGLSound = ""
SWEP.ExitUBGLSound = ""

SWEP.MalfunctionSound = ""

SWEP.MeleeHitSound = "arc9/melee_hitbody.wav"
SWEP.MeleeHitWallSound = "arc9/melee_hitworld.wav"
SWEP.MeleeSwingSound = "arc9/melee_miss.wav"

SWEP.BreathInSound = "arc9/breath_inhale.wav"
SWEP.BreathOutSound = "arc9/breath_exhale.wav"
SWEP.BreathRunOutSound = "arc9/breath_runout.wav"

-------------------------- EFFECTS

SWEP.NoMuzzleEffect = false -- Disable muzzle effect entirely
SWEP.NoFlash = false -- Disable light flash

SWEP.MuzzleParticle = nil -- Used for some muzzle effects.

SWEP.MuzzleEffect = "MuzzleFlash"
SWEP.FastMuzzleEffect = nil

SWEP.AfterShotEffect = "arc9_aftershoteffect"
SWEP.AfterShotParticle = nil -- Particle to spawn after shooting

SWEP.ImpactEffect = nil
SWEP.ImpactDecal = nil

SWEP.ShellEffect = nil -- Override the ARC9 shell eject effect for your own.
SWEP.ShellEffectCount = 1

SWEP.ShellModel = "models/shells/shell_556.mdl"
SWEP.ShellMaterial = nil -- string

SWEP.ShellSmoke = true

SWEP.NoShellEject = false -- Don't eject shell on fire
SWEP.ManualActionEjectAnyway = false -- Overrides standard behaviour to eject a shell when a shot is fired and manual action is on.

SWEP.ShellScale = 1
SWEP.ShellPhysBox = Vector(0.5, 0.5, 2)

SWEP.ShellPitch = 100 -- for shell sounds
SWEP.ShellSounds = ARC9.ShellSoundsTable

SWEP.ShellCorrectPos = Vector(0, 0, 0)
SWEP.ShellCorrectAng = Angle(0, 0, 0)
SWEP.ShellVelocity = nil -- nothing for random, otherwise keep this 0 - 2
SWEP.ShellTime = 0.5 -- Extra time these shells stay on the ground for.

SWEP.IgnoreMuzzleDevice = false -- Do not use the attachment muzzle device, use QCA muzzle instead.

SWEP.MuzzleEffectQCA = 1 -- QC Attachment that controls muzzle effect.
SWEP.AfterShotQCA = nil -- QC Attachment that controls after shot particle.
SWEP.CaseEffectQCA = 2 -- QC Attachment for shell ejection.
SWEP.CamQCA = nil -- QC Attachment for camera movement.
SWEP.CamQCA_Mult = nil -- Intensity for QC camera movement.
SWEP.CamQCA_Mult_ADS = nil -- Intensity for QC camera movement in ADS.
SWEP.ProceduralViewQCA = nil -- QC Attachment for procedural camera movement. Use if you don't have a camera. Usually the muzzle.

SWEP.CamOffsetAng = Angle(0, 0, 0)

SWEP.DoFireAnimation = true

SWEP.NoViewBob = false

-------------------------- VISUALS

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
    -- [0] = "bulletchamber",
    -- [1] = "bullet1"
}
SWEP.CaseBones = {}
-- Unlike BulletBones, these bones are determined by the missing bullet amount when reloading
SWEP.StripperClipBones = {}

-- The same as the bone versions but works via bodygroups.
-- Bodygroups work the same as in attachmentelements.
-- [0] = {ind = 0, bg = 1}
SWEP.BulletBGs = {}
SWEP.CaseBGs = {}
SWEP.StripperClipBGs = {}

SWEP.HideBones = {} -- bones to hide in third person and customize menu. {"list", "of", "bones"}
SWEP.ReloadHideBoneTables = { -- works only with TPIK
    -- [1] = {"list", "of", "bones"},
    -- [2] = {"list", "of", "bones"}
}

SWEP.PoseParameters = {} -- Poseparameters to manage. ["parameter"] = starting value.
-- Use animations to switch between different pose parameters.
-- When an animation is being played that switches between pose parameters, those parameters are all set to 0 for the animation.
-- There are also different default pose parameters:
-- firemode (Changes based on Fire Mode. Don't use this if you have animated firemode switching.)
-- sights (Changes based on sight delta)
-- sprint (Changes based on sprint delta)
-- empty (Changes based on whether a bullet is loaded)
-- ammo (Changes based on the ammo in the clip)


-------------------------- CAMO SYSTEM

SWEP.CustomCamoTexture = nil
SWEP.CustomCamoScale = 1
SWEP.CustomBlendFactor = nil

-------------------------- POSITIONS

SWEP.IronSights = {
    Pos = Vector(0, 0, 0),
    Ang = Angle(0, 0, 0),
    Magnification = 1,
    AssociatedSlot = 0, -- Attachment slot to associate the sights with. Causes RT scopes to render.
    CrosshairInSights = false,
    Blur = true, -- If arc9_fx_adsblur 1 then blur gun in that ironsights. Disable if your "ironsights" are not real ironsights 
    ---- FLAT SCOPES
    -- These don't look very good; please use actual RT scopes if possible.
    FlatScope = false,
    FlatScopeOverlay = nil, -- Material()
    FlatScopeKeepVM = false,
    FlatScopeBlackBox = true,
    FlatScopeCC = nil -- Color correction table, see default.lua
}

SWEP.SightMidPoint = { -- Where the gun should be at the middle of it's irons
    Pos = Vector(-3, 15, -5),
    Ang = Angle(0, 0, -45),
}

SWEP.HasSights = true

-- Alternative "resting" position
SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

-- Position while walking/running (no sprint)
SWEP.MovingPos = nil -- Vector(0, 0, 0)
SWEP.MovingAng = nil -- Angle(0, 0, 0)

-- Position when crouching
SWEP.CrouchPos = Vector(-4, 1, -4)
SWEP.CrouchAng = Angle(0, 0, -30)

-- Position when sprinting or safe
SWEP.RestPos = Vector(0.532, -6, 0)
SWEP.RestAng = Angle(-4.633, 36.881, 0)

-- Overrides RestPos/Ang but only for sprinting
SWEP.SprintPos = nil
SWEP.SprintAng = nil
SWEP.SprintVerticalOffset = true -- Moves vm when looking up/down while sprinting (set to false if gun clips into camera)
SWEP.ReloadNoSprintPos = true -- No sprintpos during reloads

SWEP.HolsterPos = Vector(0, 0, -5)
SWEP.HolsterAng = Angle(0, -15, 25)

SWEP.MovingMidPoint = {
    Pos = Vector(0, 0, 0),
    Ang = Angle(0, 0, 0)
}

SWEP.SprintMidPoint = {
    Pos = Vector(4, 8, -4),
    Ang = Angle(0, 5, -25)
}

-- Position for customizing
SWEP.CustomizeAng = Angle(90, 0, 0)
SWEP.CustomizePos = Vector(20, 32, 4)
SWEP.CustomizeSnapshotFOV = 90
SWEP.CustomizeSnapshotPos = Vector(0, 0, 0)
SWEP.CustomizeSnapshotAng = Angle(0, 0, 0)
SWEP.CustomizeNoRotate = false

SWEP.BipodPos = Vector(0, 4, -4)
SWEP.BipodAng = Angle(0, 0, 0)

SWEP.HeightOverBore = 1

-------------------------- HoldTypes

SWEP.HoldType = "shotgun"
SWEP.HoldTypeSprint = "passive"
SWEP.HoldTypeHolstered = nil
SWEP.HoldTypeSights = "smg"
SWEP.HoldTypeCustomize = "slam"
SWEP.HoldTypeBlindfire = "pistol"
SWEP.HoldTypeNPC = nil

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.AnimReload = ACT_HL2MP_GESTURE_RELOAD_AR2 -- While in TPIK only -- Tip: if you dont want any additional anim put ACT_HL2MP_GESTURE_RELOAD_MAGIC here instead!
SWEP.NonTPIKAnimReload = ACT_HL2MP_GESTURE_RELOAD_AR2 -- Non TPIK
SWEP.AnimDraw = false
SWEP.AnimMelee = ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND

-------------------------- TTT

-- No free attachments when this gun is purchased
SWEP.TTTNoAttachmentsOnBuy = false

-- Automatically spawn in TTT
SWEP.TTTAutospawn = true

-- Specifically replace a certain weapon in TTT
SWEP.TTTWeaponType = nil

-- The chance this weapon will spawn in TTT
SWEP.TTTWeight = 100

-- Use a different ammo type in TTT
SWEP.TTTAmmoType = nil

-------------------------- ATTACHMENTS

SWEP.StandardPresets = nil -- A table of standard presets, that would be in every player preset menu, undeletable. Just put preset codes in ""
-- {
--     "[Compact]XQAA... regular preset code here",
--     "[Magpul kit]XQAA... regular preset code here",
-- }

SWEP.AttachmentBodygroups = {
    -- ["name"] = {
    --     VM = {
    --         {
    --             ind = 1,
    --             bg = 1
    --         }
    --     },
    --     WM = {
    --         {
    --             ind = 1,
    --             bg = 1
    --         }
    --     },
    -- }
}

-- Activate attachment elements by default.
SWEP.DefaultElements = {}

SWEP.AttachmentElements = {
    -- ["bg_name"] = {
    --     Bodygroups = {
    --         {1, 1}
    --     },
    --     -- Other attachment parameters work here
    -- }
}

-- Use to override attachment table entry data.
SWEP.AttachmentSlotMods = {
    -- ["name"] = {
    --     [1] = {
    --     }
    -- }
}

-- Adjust the stats of specific attachments when applied to this gun
SWEP.AttachmentTableOverrides = {
    -- ["att_name"] = {
    --     Mult_Recoil = 1
    -- }
}

-- The big one
SWEP.Attachments = {
    -- [1] = {
    --     PrintName = "",
    --     DefaultName = "No Attachment",
    --     DefaultIcon = Material(""),
    --     InstalledElements = {""}, -- list of elements to activate when something is installed here
    --     UnInstalledElements = {""},
    --     RequireElements = {}, -- {{a and b}, or {c and d and e}, or f}
    --     -- list of "strings" or {"lists", "of", "strings"}.
    --     -- one of these must all be enabled for this to be valid.
    --     ExcludeElements = {},
    --     -- same but for exclusion.
    --     RejectAttachments = { ["att_name"] = true }, -- Specifically refuse to allow certain attachments to be attached
    --     Integral = false, -- cannot be removed
    --     Category = "", -- single or {"list", "of", "values"}
    --     InstallSound = "",
    --     Bone = "",
    --     Pos = Vector(0, 0, 0),
    --     Ang = Angle(0, 0, 0),
    --     CorrectiveAng = Angle(0, 0, 0), -- sometimes, the autosolver needs a little help. Try (-1, -1, 0)
    --     Scale = 1,
    --     DuplicateModels = { -- For guns that require duplicating attachment models, e.g. akimbo or guns with 2 mags on model
    --          {
    --              Bone = "",
    --              Pos = Vector(0, 0, 0),
    --              Ang = Angle(0, 0, 0),
    --              Scale = 1,
    --          }
    --     },
    --     LaserCorrectionAngle = Angle(0, 0, 0), -- For lasers that are not perfectly aligned with the barrel
    --     Icon_Offset = Vector(0, 0, 0),
    --     KeepBaseIrons = false,
    --     ExtraSightDistance = 0,
    --     Installed = nil,
    --     MergeSlots = {}, // merge this slot with another
    --     StickerModel = "", // This is the model that will be used for the sticker
    --     SubAttachments = {
    --         {
    --             Installed = "att_with_sub_atts",
    --             SubAttachments = {
    --                 {
    --                     Installed = "another_attachment",
    --                     SubAttachments = {
    --                         {
    --                             Installed = "even_more_nesting",
    --                             SubAttachments = {}
    --                         },
    --                         {
    --                             Installed = nil,
    --                         }
    --                     }
    --                 },
    --                 {
    --                     Installed = nil
    --                 },
    --                 {
    --                     Installed = "something_or_other",
    --                     SubAttachments = {}
    --                 }
    --             }
    --         },
    --         {
    --             Installed = nil,
    --             SubAttachments = {}
    --         }
    --     }
    -- }
}

-- draw
-- ready
-- holster
-- idle_1, idle_2, idle_3...
-- fire
-- fire_1, fire_2, fire_3...
-- dryfire
-- reload
-- reload_empty
-- trigger Trigger delay
-- untrigger Let go of trigger before fire
-- reload_ubgl
-- reload_start_1, reload_start_2, reload_start_3...: For reloads that require losing the spent shells. For example removing spent shells on a revolver or double barrel shotgun.
-- reload_insert_1, reload_insert_2, reload_insert_3...: Animation that reloads multiple rounds in at once, such as a stripper clip.
-- reload_insert_bullet_1, reload_insert_bullet_2, reload_insert_bullet_3...: Animation that reloads one by one at a time, such as a revolver or double barrel shotguns.
-- reload_finish, reload_finish_1, reload_finish_2...: Animation that finishes the reload based off of how much bullets you insert in your gun. _# prefix is bullets left to full after cancel reload.
-- enter_bipod, exit_bipod
-- enter_inspect, exit_inspect, idle_inspect
-- jam
-- fix
-- bash
-- impact
-- enter_sights, exit_sights, idle_sights
-- enter_sprint, exit_sprint, idle_sprint
-- toggle (F)
-- switchsights (alt+e)

-- pinpull (for grenades)
-- throw
-- toss
-- explodeinhands

-- Suffixes (Must be in this order):
-- _iron (When sighted)
-- _sights (Alternative to _iron)
-- _blindfire_left
-- _blindfire_right
-- _blindfire
-- _bipod
-- _sprint
-- _walk
-- _empty
-- _ubgl
-- _primed

-- Not necessary; if your sequences are named the same as animations, they will be used automatically.

SWEP.Animations = {
    -- ["idle"] = {
    --     Source = "idle",
    --     Mult = 1.1,
    -- },
    -- ["draw"] = {
    --     Source = {"deploy", "deploy2"}, -- QC sequence source, can be {"table", "of", "strings"} or "string"
    --     RareSource = "magicdeploy", -- Has a small chance to play instead of normal source
    --     RareSourceChance = 0.01, -- chance that rare source will play
    --     Time = 0.5, -- overrides the duration of the sequence
    --     Mult = 1, -- multiplies time
    --     Reverse = false, -- Reverse the animation
    --     EjectAt = 0, -- Eject a shell at this time
    --     IKTimeLine = { -- t is in fraction of animation
    --         {
    --             t = 0.1,
    --             lhik = 0,
    --             rhik = 0
    --         },
    --         {
    --             t = 0.9,
    --             lhik = 1
    --             rhik = 0
    --         }
    --     },
    --     EventTable = {
    --         {
    --             t = 1, -- in seconds
    --                 s = "", -- sound to play
    --                 c = CHAN_ITEM, -- sound channel
    --                 p = 1 -- sound pitch
    --                 v = 1 -- sound playback volume
    --                 l = 75 -- sound level in db
    --             e = "", -- effect to emit
    --             att = nil, -- on attachment point X
    --             mag = 100, -- with magnitude whatever this is
    --             ind = 0, -- change bodygroup,
    --             bg = 0, -- nil to reset
    --             pp = "", -- pose parameter name
    --             ppv = 0, -- pose parameter value, set to nil to reset
    --             hide = 1, -- hide reloadhidebonetables table, 0 for none
    --             FOV = -3, -- change fov in anim, see SWEP.FOV_Recoil_x for detials
    --             FOV_Start = 0.2,
    --             FOV_End = 0.4,
    --             FOV_FuncStart = ARC9.Ease.OutCirc,
    --             FOV_FuncEnd = ARC9.Ease.InCirc,
    --         }
    --     },
    --     PoseParamChanges = { -- pose parameters to change after this animation is done.
    --         ["selector"] = 1 -- an application might be to change firemodes.
    --     }, -- relevant pose parameters will be set to default values while the animation is playing, so make sure you take that into consideration for animating.
    --     MagSwapTime = 0.5, -- in seconds, how long before the new magazine replaces the old one. For SWEP.BulletBones
    --     MinProgress = 0.9, -- seconds that must pass before the reload is considered done
    --     FireASAP = false, -- allowes to shoot right after clip anim was "done" with MinProgress
    --     RestoreAmmo = 0 -- Restores ammunition to clip
    -- }
}

SWEP.SuppressDefaultSuffixes = false -- Animations won't automatically play _iron, _empty, etc. versions of animations
SWEP.SuppressDefaultAnimations = false -- Animations won't automatically generated based on sequences defined in QC
SWEP.SuppressEmptySuffix = false -- _empty animations won't automatically trigger.
SWEP.SuppressSprintSuffix = false -- _sprint animations won't automatically trigger.

--[[
    FOV anim settings
        for use in FOV_FuncStart, FOV_FuncEnd
    ARC9.Ease.InBack
    ARC9.Ease.InBounce
    ARC9.Ease.InCirc
    ARC9.Ease.InCubic
    ARC9.Ease.InElastic
    ARC9.Ease.InExpo
    ARC9.Ease.InOutBack
    ARC9.Ease.InOutBounce
    ARC9.Ease.InOutCirc
    ARC9.Ease.InOutCubic
    ARC9.Ease.InOutElastic
    ARC9.Ease.InOutExpo
    ARC9.Ease.InOutQuad
    ARC9.Ease.InOutQuart
    ARC9.Ease.InOutQuint
    ARC9.Ease.InOutSine
    ARC9.Ease.InQuad
    ARC9.Ease.InQuart
    ARC9.Ease.InQuint
    ARC9.Ease.InSine
    ARC9.Ease.OutBack
    ARC9.Ease.OutBounce
    ARC9.Ease.OutCirc
    ARC9.Ease.OutCubic
    ARC9.Ease.OutElastic
    ARC9.Ease.OutExpo
    ARC9.Ease.OutQuad
    ARC9.Ease.OutQuart
    ARC9.Ease.OutQuint
    ARC9.Ease.OutSine
]]

SWEP.Primary.Automatic = true
SWEP.Primary.DefaultClip = -1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawCrosshair = true

SWEP.ARC9 = true

SWEP.m_bPlayPickupSound = false

SWEP.PCFs = {}

local searchdir = "weapons/arc9_base"

local function autoinclude(dir)
    local files, dirs = file.Find(searchdir .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        if filename == "shared.lua" then continue end
        local luatype = string.sub(filename, 1, 2)

        if luatype == "sv" then
            if SERVER then
                include(dir .. "/" .. filename)
            end
        elseif luatype == "cl" then
            AddCSLuaFile(dir .. "/" .. filename)
            if CLIENT then
                include(dir .. "/" .. filename)
            end
        else
            AddCSLuaFile(dir .. "/" .. filename)
            include(dir .. "/" .. filename)
        end
    end

    for _, path in pairs(dirs) do
        autoinclude(dir .. "/" .. path)
    end
end

autoinclude(searchdir)

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "RecoilAmount")
    self:NetworkVar("Float", 1, "AnimLockTime")
    self:NetworkVar("Float", 2, "NextIdle")
    self:NetworkVar("Float", 3, "LastRecoilTime")
    self:NetworkVar("Float", 4, "RecoilUp")
    self:NetworkVar("Float", 5, "RecoilSide")
    self:NetworkVar("Float", 6, "SprintAmount")
    self:NetworkVar("Float", 7, "LastMeleeTime")
    self:NetworkVar("Float", 8, "TriggerDelay")
    --self:NetworkVar("Float", 8, "PrimedAttackTime")
    --self:NetworkVar("Float", 9, "StartPrimedAttackTime")
    self:NetworkVar("Float", 10, "ReloadFinishTime")
    self:NetworkVar("Float", 11, "SightAmount")
    self:NetworkVar("Float", 12, "HeatAmount")
    self:NetworkVar("Float", 13, "BlindFireAmount")
    -- self:NetworkVar("Float", 14, "LastPressedETime")
    self:NetworkVar("Float", 14, "FinishFiremodeAnimTime")
    self:NetworkVar("Float", 15, "IKTimeLineStart")
    self:NetworkVar("Float", 16, "IKTime")
    self:NetworkVar("Float", 17, "HolsterTime")
    self:NetworkVar("Float", 18, "BlindFireCornerAmount")
    self:NetworkVar("Float", 19, "EnterBipodTime")
    self:NetworkVar("Float", 20, "Breath")
    self:NetworkVar("Float", 21, "SequenceCycle")
    self:NetworkVar("Float", 22, "SequenceSpeed")
    self:NetworkVar("Float", 23, "LastHolsterTime")
    self:NetworkVar("Float", 24, "GrenadePrimedTime")
    -- self:NetworkVar("Float", 19, "LastPressedWTime")
    -- self:NetworkVar("Float", 20, "TraversalSprintAmount")

    self:NetworkVar("Int", 0, "BurstCount")
    self:NetworkVar("Int", 1, "NthShot")
    self:NetworkVar("Int", 2, "LoadedRounds")
    self:NetworkVar("Int", 3, "Firemode")
    self:NetworkVar("Int", 4, "NthReload")
    self:NetworkVar("Int", 5, "MultiSight")
    self:NetworkVar("Int", 6, "BlindFireDirection")
    self:NetworkVar("Int", 7, "HideBoneIndex")
    self:NetworkVar("Int", 8, "SequenceIndex")
    self:NetworkVar("Int", 9, "SequenceProxy")

    self:NetworkVar("Bool", 0, "Customize")
    self:NetworkVar("Bool", 1, "Reloading")
    self:NetworkVar("Bool", 2, "EndReload")
    self:NetworkVar("Bool", 3, "Safe")
    self:NetworkVar("Bool", 4, "Jammed")
    self:NetworkVar("Bool", 5, "Ready")
    self:NetworkVar("Bool", 6, "TriggerDown")
    self:NetworkVar("Bool", 7, "NeedTriggerPress")
    self:NetworkVar("Bool", 8, "UBGL")
    self:NetworkVar("Bool", 9, "EmptyReload")
    self:NetworkVar("Bool", 10, "InSights")
    self:NetworkVar("Bool", 11, "PrimedAttack")
    self:NetworkVar("Bool", 12, "BlindFire")
    self:NetworkVar("Bool", 13, "NeedsCycle")
    self:NetworkVar("Bool", 14, "Bipod")
    self:NetworkVar("Bool", 15, "HeatLockout")
    self:NetworkVar("Bool", 16, "LastWasSprinting")
    self:NetworkVar("Bool", 17, "RequestReload")
    self:NetworkVar("Bool", 18, "InMeleeAttack")
    self:NetworkVar("Bool", 19, "OutOfBreath")
    self:NetworkVar("Bool", 20, "Inspecting")
    self:NetworkVar("Bool", 21, "AfterShot")
    self:NetworkVar("Bool", 22, "GrenadePrimed")
    self:NetworkVar("Bool", 23, "GrenadeTossing")
    self:NetworkVar("Bool", 24, "GrenadeRecovering")
    -- self:NetworkVar("Bool", 15, "TraversalSprint")

    self:NetworkVar("Angle", 0, "FreeAimAngle")
    self:NetworkVar("Angle", 1, "LastAimAngle")
    self:NetworkVar("Angle", 2, "VisualRecoilAng")
    self:NetworkVar("Angle", 3, "VisualRecoilVel")

    self:NetworkVar("Vector", 0, "VisualRecoilPos")
    self:NetworkVar("Vector", 1, "VisualRecoilPosVel")

    self:NetworkVar("String", 0, "IKAnimation")

    self:NetworkVar("Entity", 0, "Holster_Entity")
    self:NetworkVar("Entity", 1, "LungeEntity")

    self:SetVisualRecoilAng(Angle(0, 0 ,0))
    self:SetVisualRecoilVel(Angle(0, 0, 0))

    self:SetVisualRecoilPos(Vector(0, 0, 0))
    self:SetVisualRecoilPosVel(Vector(0, 0, 0))

    self:SetMultiSight(1)
    self:SetLastWasSprinting(false)
    self:SetEnterBipodTime(0)
    self:SetBreath(100)
    self:SetOutOfBreath(false)
    self:SetFiremode(1)
    self:SetAfterShot(false)
    self:SetGrenadePrimed(false)

    self:SetRecoilUp(0)
    self:SetRecoilSide(0)

    self:SetLastRecoilTime(0)

    self:SetAnimLockTime(0)
    self:SetNextPrimaryFire(0)
    self:SetNextSecondaryFire(0)
    self:SetNextIdle(0)
    self:SetRecoilAmount(0)
    self:SetLastMeleeTime(0)
    self:SetEnterBipodTime(0)
    self:SetFinishFiremodeAnimTime(0)
    self:SetReloadFinishTime(0)
    self:SetLastHolsterTime(0)
    self:SetNthReload(0)
end

function SWEP:SecondaryAttack()
    if self:GetValue("UBGL") and self:GetProcessedValue("UBGLInsteadOfSights") then
        -- self:SetUBGL(true)
        self:ToggleUBGL(true)
        self:DoPrimaryAttack()
        -- self:SetUBGL(false)
    end
end
