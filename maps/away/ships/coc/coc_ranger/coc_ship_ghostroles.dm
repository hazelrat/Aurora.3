//rangers

/datum/ghostspawner/human/ranger
	short_name = "ranger"
	name = "Coalition Ranger"
	desc = "Crew the Ranger gunboat. Protect the interests of the Coalition of Colonies and your member-state."
	tags = list("External")

	spawnpoints = list("ranger")
	max_count = 5

	outfit = /obj/outfit/admin/ranger
	possible_species = list(SPECIES_HUMAN, SPECIES_HUMAN_OFFWORLD)
	allow_appearance_change = APPEARANCE_PLASTICSURGERY

	assigned_role = "Frontier Ranger"
	special_role = "Frontier Ranger"
	faction = "Frontier Protection Bureau"
	respawn_flag = null


/obj/outfit/admin/ranger
	name = "Coalition Ranger"

	uniform = /obj/item/clothing/under/tactical
	shoes = /obj/item/clothing/shoes/workboots/dark
	back = /obj/item/storage/backpack/satchel

	id = /obj/item/card/id/ranger_ship

	l_ear = /obj/item/device/radio/headset/ship/coalition_navy

	backpack_contents = list(/obj/item/storage/box/survival = 1)

/obj/outfit/admin/ranger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(isoffworlder(H))
		H.equip_or_collect(new /obj/item/storage/pill_bottle/rmt, slot_in_backpack)

/obj/outfit/admin/ranger/get_id_access()
	return list(ACCESS_EXTERNAL_AIRLOCKS)

/datum/ghostspawner/human/ranger/captain
	short_name = "ranger_leader"
	name = "Coalition Ranger Leader"
	desc = "Lead the Ranger gunboat. Protect the interests of the Coalition of Colonies and your member-state."

	spawnpoints = list("ranger_leader")
	max_count = 1

	outfit = /obj/outfit/admin/ranger/captain
	possible_species = list(SPECIES_HUMAN, SPECIES_HUMAN_OFFWORLD)
	allow_appearance_change = APPEARANCE_PLASTICSURGERY

	assigned_role = "Frontier Ranger Leader"
	special_role = "Frontier Ranger Leader"


/obj/outfit/admin/ranger/captain
	name = "Coalition Ranger Leader"

	accessory = /obj/item/clothing/accessory/sash/red

/obj/item/card/id/ranger_ship
	name = "ranger ship id"
	access = list(ACCESS_EXTERNAL_AIRLOCKS, ACCESS_COALITION, ACCESS_COALITION_NAVY)
