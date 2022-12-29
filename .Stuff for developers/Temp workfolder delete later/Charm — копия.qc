$modelname "items/arc9/att_charmbase_big.mdl"
$cdmaterials "models/darsu_m/arc9/"

$bodygroup "studio"
{
    studio "Charm.smd"
}

$lod 24
{
    bonetreecollapse "root"
}


$jigglebone "base"
{
	is_flexible
	{
		length 20
		tip_mass 20
		pitch_stiffness 100
		pitch_damping 2
		yaw_stiffness 100
		yaw_damping 3
		along_stiffness 100
		along_damping 0
		angle_constraint 15
	}
}
$jigglebone "ring1"
{
	is_flexible
	{
		length 20
		tip_mass 20
		pitch_stiffness 100
		pitch_damping 2
		yaw_stiffness 100
		yaw_damping 3
		along_stiffness 100
		along_damping 0
		angle_constraint 15
	}
}
$jigglebone "chain1"
{
	is_flexible
	{
		length 20
		tip_mass 20
		pitch_stiffness 100
		pitch_damping 2
		yaw_stiffness 100
		yaw_damping 3
		along_stiffness 100
		along_damping 0
		angle_constraint 15
	}
}
$jigglebone "chain3"
{
	is_flexible
	{
		length 20
		tip_mass 20
		pitch_stiffness 100
		pitch_damping 2
		yaw_stiffness 100
		yaw_damping 3
		along_stiffness 100
		along_damping 0
		angle_constraint 15
	}
}
$jigglebone "ring3"
{
	is_flexible
	{
		length 20
		tip_mass 20
		pitch_stiffness 100
		pitch_damping 2
		yaw_stiffness 100
		yaw_damping 3
		along_stiffness 100
		along_damping 0
		angle_constraint 15
	}
}

$attachment "Charm" "ring3" 0.00 0.00 0.12 rotate 0 -70 90


$sequence "idle" {
    // "anims/idleflat.smd"
    "anims/idlemassive.smd"
    fps 1
}