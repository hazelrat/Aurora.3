/mob/living/simple_animal/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 100
	health_prefix = "wraith"
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashed"
	organ_names = list("core", "right arm", "left arm")
	speed = -3
	environment_smash = TRUE
	attack_sound = 'sound/weapons/rapidslice.ogg'
	construct_spells = list(/spell/targeted/ethereal_jaunt/shift)
<<<<<<< Updated upstream
=======
	construct_armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_MINOR,
		laser = ARMOR_LASER_MINOR,
		bomb = ARMOR_BOMB_PADDED
	)
>>>>>>> Stashed changes

	flying = TRUE
