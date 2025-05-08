/**
This is intended to represent a stray nymph that has been accidentally smuggled onto the ship, such as inside a large bulk of cargo.
The player is intended to have some liberty with where their nymph came from, and what they do with them on the ship.
The spawners for the ghostrole should be placed in areas of maintenance that have vents, so the nymph doesn't end up trapped where they spawn.
 */
/datum/ghostspawner/simplemob/nymph
	short_name = "stray_nymph"
	name = "Stray Diona Nymph"
	desc = "You are a stray Diona Nymph, isolated without a gestalt. You are viewed by many cultures as a pest. Survive, or even thrive, despite your \
	challenging circumstances."
	show_on_job_select = FALSE
	tags = list("Simple Mobs")

	respawn_flag = ANIMAL

	spawn_mob = /mob/living/carbon/alien/diona

/datum/ghostspawner/simplemob/nymph/New()
	desc = "You cannot shake the feeling that you should not be here. Whether you are a nymph that split voluntarily from a larger gestalt, the survivor of some \
	terrible catastrophe, or one that has never been a constituent in a larger collective, you have found yourself in a dark, enclosed space. Seek light, and \
	seek survival. Consumption of the blood of any creatures you encounter may glean knowledge of their languages."
	..()
