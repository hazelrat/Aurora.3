/datum/ghostspawner/human/guardian_regular
	name = "Regular of the Order"
	short_name = "guardian_regular"
	desc = ""
	tags = list("External")
	mob_name_prefix = "G-R. "

	spawnpoints = list("guardian_regular")
	max_count = 3

	outfit = /obj/outfit/admin/guardian_regular
	possible_species = list(SPECIES_HUMAN, SPECIES_HUMAN_OFFWORLD, SPECIES_IPC, SPECIES_IPC_G1, SPECIES_IPC_G2, SPECIES_IPC_XION, SPECIES_IPC_ZENGHU, SPECIES_IPC_BISHOP, SPECIES_IPC_SHELL)
	allow_appearance_change = APPEARANCE_PLASTICSURGERY

	assigned_role = "Regular of the Order"
	special_role = "Regular of the Order"
	respawn_flag = null

/obj/outfit/admin/guardian_regular
	name = "Regular of the Order"
	uniform = /obj/item/clothing/under/dressshirt/guardian
	pants = /obj/item/clothing/pants/guardian
	belt = /obj/item/storage/belt/security/full/alt/revolver
	gloves = /obj/item/clothing/gloves/force/basic
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/industrial
	id = /obj/item/card/id/generic
	accessory = /obj/item/clothing/accessory/holster/hip
	l_ear = /obj/item/radio/headset/ship
	backpack_contents = list(/obj/item/storage/box/survival = 1, /obj/item/melee/energy/sword/knife/axiom)

/obj/outfit/admin/guardian_regular/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(isoffworlder(H))
		H.equip_or_collect(new /obj/item/storage/pill_bottle/rmt, slot_in_backpack)
	if(isipc(H))
		var/obj/item/organ/internal/machine/ipc_tag/tag = H.internal_organs_by_name[BP_IPCTAG]
		if(istype(tag))
			tag.serial_number = uppertext(dd_limittext(md5(H.real_name), 12))
			tag.ownership_info = IPC_OWNERSHIP_SELF
			tag.citizenship_info = CITIZENSHIP_AXIOM

/obj/outfit/admin/guardian_regular/get_id_access()
	return list(ACCESS_ECCLESIASTICAL, ACCESS_EXTERNAL_AIRLOCKS)
