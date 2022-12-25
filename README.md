
# ARC9

### A successor to the ArcCW base that focuses on stability and ease of use.

ARC9 is so called for being the ninth public Arctic base. It is designed to be a long-term sustainable successor to ArcCW.

## FAQ

### Why should I use this over ArcCW?
It's far better designed, better networked, and in the long run, will be more sustainable. It is easier to develop for, easier to use, has more features, and is more comfortable to use in multiplayer.

### Why ARC9? Where's ARC 2 - 8? Why not just ArcCW 2?
Because "CW 2" is a substring of "ArcCW 2" and I don't want people to think it has anything to do with CW 2.0. Just ask the creator of TeamDeathMatch Cars. ARC1-8 are my other bases. In order: ASTW, ASTW2, ACT3, ArcVR, ArcCW, TacInt, Neotokyo, TacRP.

### Are ArcCW 1 weapons compatible with this?
No, they aren't, and without some effort, automatic porting isn't going to be possible. However, manual porting should be doable, and will be a lot easier than creating a new weapon from scratch.

### How can I start developing?
Read weapons/arc9_base/shared.lua, arc9/common/attachments/default.lua, and this file.

### How do I make underbarrel grenade launchers and other secondary fire modes?
Making underbarrel grenade launchers is simple! If using integrated animations, you MUST set the animation entry "reload_ubgl" (Plus, most likely, any animationtranslate suffixes you're using to make the rest of the animations work). Other than this, all you need to do is add ATT.UBGL = true - or SWEP.UBGL - and then override the appropriate weapon stats with the UBGL condition. For instance, use ShootEntUBGL to set the gun to fire a different projectile while a UBGL is active.

If you are using a separate UBGL model, you can use IKAnimationProxy in order to make them play animations. See default.lua for more information.

You can ONLY have one UBGL active at any one time. Set up your weapons to accept only one UBGL; otherwise, weird things will probably happen.

### What's the best way to have a weapon with two modes?
There are three main ways to do this: As a firemode, as a UBGL, and as an attachment.

Firemodes are the easiest by far to set up, and have the benefit that you can cycle through more than 2 modes if you need.

UBGLs provides the greatest versatility, including allowing your alternate mode to use a different ammo type. This is the best mode for underbarrel launchers, shotguns, etc.

Attachments that change the way your weapon works are like firemodes, but it's possible to control the use of them through the attachment inventory system, they're attached via the customization menu, and you can combine different attachments together.

You could also opt to combine these methods together - it's common for an attachment to grant a UBGL weapon. You could use firemodes to grant the player multiple UBGLs to switch between. Or you could have an attachment that adds firemodes.

**New features include:**
 - Overhauled standardized recoil mechanics
 - Magazine dropping
 - Attachments on top of attachments
 - Free aim
 - Free sway
 - Reworked standardized weapon stat handling
 - Integrated leaning system with autolean 
 - Looping sounds
 - Reworked LHIK system
 - LHIK supports right hands too (RHIK)
 - Snazzy new UI
 - Better standard weapon ecosystem
 - Third Person IK animations
 - New and improved Modifier system
 - New RT scopes
 - Dynamic camo support
 - CS:GO-like sticker system
 - Controller support
 - Dynamic selecticon, preset and kill icon generation
 - Exportable and easy to share presets

### New Recoil

Weapons can be set with a Recoil Seed, unique to that gun, or a lookup table of recoil values. This gives them a recoil pattern which is consistent and predictible every time you shoot.

Weapons also have an amount of random recoil, which is added onto the predictible recoil. Random recoil cannot be predicted, meaning the pattern will vary a little bit every time.

Visual recoil has been totally reworked from the ground up using springs, which look much better than the previous system.

### Supply Limit

The main way to get ammunition is through using Supply Crates or Supply Pickups. These will only resupply you up to your supply limit multiplied by your current magazine capacity worth of ammo. Some attachments will increase your Supply Limit while others will decrease it.

### Subslots

Now, attachments can add new slots, which more attachments can be placed onto. Due to internal structure features of ArcCW, this was completely impossible previously.

### Free Aim and Free Sway

While hip-firing, your weapon's point of aim will sway around the screen. This means no more perfect center-screen hip shooting. This is another mechanic that can be used to balance attachments and weapons.

### New Stat Handling

Each stat is handled more automatically than ever. Each stat has a "Base", such as Speed or ReloadTime or Sway. To create a new modifier to it, we add "Mult", e.g. SpeedMult. To make it conditional, we can then add a condition onto it, e.g. SpeedMultSights. This will make adding new conditions easier than ever, as it only needs to be modified in one place - the condition handler.

Each condition is handled individually according to the specific condition. For instance, the MidAir condition is binary - so modifiers with this condition are applied only if the player is in mind-air. However, the Sighted condition will interpolate between 0 and 1 multiplied by the total multiplier. So if the player is 50% aimed down their sights, and they have an attachment with SpreadMultSighted of 2, their spread will be multiplied by 1.5x. Mults are multiplied together before this happens - if the player has two attachments, one with SpreadMultSighted of 2 and one with 3, ARC9 will only save "6" and thus if the player is halfway sighted, their spread is multiplied by 3.

Modifier classes are Override, Mult, Add, and Hook, processed in that order, as in ArcCW.

Override and Hook modifiers also support _Priority values being assigned to the same attachment or the base weapon for greater control over the order in which they are run. For instance. SpreadOverrideSighted_Priority = 2 on an attachment will cause that attachment's SpreadOverrideSighted to take precedence over all SpreadOverrideSighted values without a priority set or with priority less than 2. Unset priority counts as 1.

Examples:

SpeedMult
AimDownSightTimeHook
AimDownSightOverrideCrouch

ArcCW: Mult_SpeedMult
ARC9: SpeedMult

ArcCW: Override_Firemodes
ARC9: FiremodesOverride

Hooks make a return outside of stat modifications. Hooks (Like "HookT_MinimapPing") are now separated into different types based on how they accept return data. Hooks that do not have a type ("Hook_Whatever") do not accept any return data and are only present for signalling. Both Hooks and Overrides accept \_Priority, just like in ArcCW. Higher priority will be run with precedence. For instance, Hook_RecoilSeed_Priority = 3 means that attachment's Hook_RecoilSeed will be run before any other hook that belongs to an attachment with Hook_RecoilSeed_Priority = 2.

The base weapon is also considered.

HookT: Table hooks. Return a {table} of values. Every hook's returned values are gathered into one big table for later use. Every returned value is used.
HookA: Accumulator hooks. Return an Angle, Vector, or Number - the resulting value is made up of all of these values added together.
HookP: Pipeline hooks. Accept previously returned data, return new data. Each function modifies the data given. Return nil to make no change. Used for things like animation translate.
HookC: Check hooks. Return false to prevent something from happening.

Hooks run in an order that can be compared as such:
1. If A's \[Hook_*\]_Priority value is higher than B (Unspecified is treated as 1) then run it first.
2. If A belongs to a top level slot with lower value than B, run it first.
3. If A and B belong to the same top level slot, the one with the lowest depth will be run first.
4. If A and B have the same depth, the one that belongs to the lowest level sub-slot will be run first.

This is, essentially, a breadth-first tree unwrap which treats each top level slot as its own tree and processes them in numerical order.

### RHIK

RHIK is a successor to LHIK. Now, RHIK supports multiple targets, using the RHIK stack. Whenever we request an animation to be played, we put it on top of the stack. Giving priority to the top animation, we blend it seamlessly with every other animation in the stack, giving us the ability to play multiple RHIK animations in quick succession to different targets with maximum smoothness.

RHIK is also able to accept an attachment that moves the base weapon, allowing for more fluid animations as opposed to the procedural system of ArcCW.

Some applications of this include the new built-in system for toggleable hybrid optics, underbarrel grenade launchers, and grip options with different poses.

### New UI

A new heads-up display with cooler design.

### New Weapon Ecosystem

Designed from the ground up to be extensible and standardized, so that creators can work together better. New slots better represent what they are meant to accomplish.

### Pose Parameter Handler

Allows animations to alter pose param values and keep them there. Several other weapon statistics are also directly tied to pose parameters, allowing for greater animation-based control.

## How To Contribute

Whenever you add a feature, please document any additional parameters or variables you've added in shared.lua if they're applicable to the base weapon or default.lua if they're mainly to do with attachments. Please make sure to place your parameter under the appropriate section.

SWEP and ATT variables should be in CamelCase, as is the Gmod standard. ARC9.ENUMs should be all upper case, as is the Gmod standard. Prefer descriptive variables when possible. Adhere to the Nomenclature guide.

**Nomenclature:**
Only terminology that may cause confusion is laid out. Any terms that are standard to the community or engine are assumed to be used the same way.
 - Sequence: A Source animation on a gun's viewmodel.
 - Animation Table: A table for defining custom sequence data.
 - Attachment: A thing that goes on your gun.
 - QC Attachment: Attachment point that follows a bone used by Source engine, defined in .qc files.
 - Slot: Something you can put an attachment on.
 - Spread: The amount that a bullet can deviate from the aim point, in 1/10ths of a full circle.
 - Chamber: An area in a firearm that holds a round before it is fired, separate from the magazine. Only some guns have a chamber in this sense of the word. Allows guns to "+1". Revolvers and open bolt guns lack this ability and cannot chamber.
 - Clip: The same thing as a magazine.
 - Stripper Clip: An item that holds rounds that can be used to quickly refill a magazine. NOT the same thing as just a "clip".
 - VM: ViewModel.
 - WM: WorldModel.
 - BG: Bodygroup.
 - PP: Pose Parameter. A .qc defined blend ratio between different animation sequences.

 ## List of Conditions
Use these in attachment stats, e.g. AimDownSightsTimeMultCrouch to multiply ADS time when crouching.

 - **NPC**: Enabled when the owner is an NPC.
 - **True**: Enabled when TrueNames is active.
 - **Silenced**: Enabled when a silencer is installed.
 - **UBGL**: Enabled when an underbarrel weapon is active.
 - **MidAir**: Enabled when in mid-air.
 - **Crouch**: Enabled when crouching.
 - **FirstShot**: Enabled on the first shot.
 - **Empty**: Enabled on the last shot of a magazine.
 - **EvenShot**: Enabled on even shots.
 - **OddShot**: Enabled on odd shots.
 - **EvenReload**: Enabled on even reloads.
 - **OddReload**: Enabled on odd reloads.
 - **BlindFire**: Enabled while blind firing.
 - **Sights**: Enabled when sighted. Scales.
 - **HipFire**: Enabled when not sighted. Scales.
 - **Hot**: Enabled with overheat amount, like with Sights. Scales.
 - **Shooting**: Enabled when constantly shooting.
 - **Recoil**: Scales with bursts. Unique in that it multiplies with recoil amount.
 - **Move**: Enabled when moving.

 ## Tips for Developers
 - If you want to increase recoil without making view shoot to the top, try increasing RecoilPatternDrift.
 - Be creative; stat modifiers can be inserted in more places than you might think.
 - Use PrintName for a game's version of a weapon name and TrueName for its real life name.
 - Unlike ArcCW, trivia table keys and values are arbitrary. Go wild!
 - The same goes for the credits table.
