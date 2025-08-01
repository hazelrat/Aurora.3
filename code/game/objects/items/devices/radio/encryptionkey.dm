/obj/item/device/encryptionkey
	name = "standard encryption key"
	desc = "An encryption key for a radio headset. Contains cypherkeys."
	icon = 'icons/obj/item/device/encryptionkey.dmi'
	icon_state = "cypherkey"
	item_state = ""
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_EARS
	var/translate_binary = FALSE
	var/translate_hivenet = FALSE
	var/syndie = FALSE // Signifies that it de-crypts Syndicate transmissions
	var/independent = FALSE // Signifies that it lets you talk on the spicy channel
	var/list/channels = list(CHANNEL_COMMON = TRUE, CHANNEL_ENTERTAINMENT = TRUE, CHANNEL_EXPED = TRUE)
	var/list/additional_channels = list()

/obj/item/device/encryptionkey/attackby(obj/item/attacking_item, mob/user)
	return

/obj/item/device/encryptionkey/ship
	var/use_common = FALSE
	channels = list()

/obj/item/device/encryptionkey/ship/Initialize()
	if(!SSatlas.current_map.use_overmap)
		return ..()

	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	var/sector_z = get_sector_z()
	var/obj/effect/overmap/visitable/V = GLOB.map_sectors["[sector_z]"]
	if(istype(V) && V.comms_support)
		var/freq_name = V.name
		if(V.freq_name)
			freq_name = V.freq_name
			name = "[V.freq_name] encryption key"
		else if(V.comms_name)
			name = "[V.comms_name] encryption key"

		channels += list(
			"[freq_name]" = TRUE,
			CHANNEL_HAILING = TRUE
		)

	if(use_common)
		channels += list(CHANNEL_COMMON = TRUE)

	return INITIALIZE_HINT_NORMAL

/obj/item/device/encryptionkey/ship/proc/get_sector_z()
	. = GET_Z(get_turf(src))

/obj/item/device/encryptionkey/ship/common
	use_common = TRUE

/obj/item/device/encryptionkey/ship/odyssey/get_sector_z()
	if(SSodyssey.scenario_zlevels && SSodyssey.scenario_zlevels.len)
		. = SSodyssey.scenario_zlevels[1]
	else // safe fallback
		. = GET_Z(get_turf(src))

/obj/item/device/encryptionkey/ship/coal_navy
	additional_channels = list(CHANNEL_COALITION_NAVY = TRUE)

/obj/item/device/encryptionkey/syndicate
	icon_state = "cypherkey"
	additional_channels = list(CHANNEL_MERCENARY = TRUE, CHANNEL_HAILING = TRUE)
	origin_tech = list(TECH_ILLEGAL = 3)
	syndie = TRUE

/obj/item/device/encryptionkey/syndicate/antagonist_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "An encryption key that allows you to intercept comms and speak on private non-standard channels. Use :t to access the private channel."

/obj/item/device/encryptionkey/raider
	icon_state = "cypherkey"
	additional_channels = list(CHANNEL_RAIDER = TRUE, CHANNEL_HAILING = TRUE)
	origin_tech = list(TECH_ILLEGAL = 2)
	syndie = TRUE

/obj/item/device/encryptionkey/burglar
	icon_state = "cypherkey"
	additional_channels = list(CHANNEL_BURGLAR = TRUE, CHANNEL_HAILING = TRUE)
	origin_tech = list(TECH_ILLEGAL = 2)
	syndie = TRUE

/obj/item/device/encryptionkey/jockey
	icon_state = "cypherkey"
	additional_channels = list(CHANNEL_JOCKEY = TRUE, CHANNEL_HAILING = TRUE)
	origin_tech = list(TECH_ILLEGAL = 2)
	syndie = TRUE

/obj/item/device/encryptionkey/ninja
	icon_state = "cypherkey"
	additional_channels = list(CHANNEL_NINJA = TRUE, CHANNEL_HAILING = TRUE)
	origin_tech = list(TECH_ILLEGAL = 3)
	syndie = TRUE

/obj/item/device/encryptionkey/bluespace
	name = "bluespace encryption key"
	desc = "A nonsensical mimicry of a standard encryption key, in the form of an elongated bluespace crystal. It seems to function."
	icon_state = "bs_cypherkey"
	additional_channels = list(CHANNEL_BLUESPACE = TRUE)
	origin_tech = list(TECH_BLUESPACE = 3)
	syndie = TRUE

/obj/item/device/encryptionkey/binary
	icon_state = "cypherkey"
	translate_binary = TRUE
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/device/encryptionkey/hivenet
	name = "hivenet encryption chip"
	desc = "It appears to be a Vaurca Hivenet encryption chip, for localized broadcasts."
	translate_hivenet = TRUE
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "neuralchip"

/obj/item/device/encryptionkey/headset_sec
	name = "security radio encryption key"
	icon_state = "sec_cypherkey"
	channels = list(CHANNEL_SECURITY = TRUE)

/obj/item/device/encryptionkey/headset_warden
	name = "warden radio encryption key"
	icon_state = "sec_cypherkey"
	channels = list(CHANNEL_SECURITY = TRUE, CHANNEL_PENAL = TRUE)

/obj/item/device/encryptionkey/headset_penal
	name = "penal radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list(CHANNEL_PENAL = TRUE)

/obj/item/device/encryptionkey/headset_eng
	name = "engineering radio encryption key"
	icon_state = "eng_cypherkey"
	channels = list(CHANNEL_ENGINEERING = TRUE)

/obj/item/device/encryptionkey/headset_rob
	name = "robotics radio encryption key"
	icon_state = "rob_cypherkey"
	channels = list(CHANNEL_ENGINEERING = TRUE, CHANNEL_SCIENCE = TRUE)

/obj/item/device/encryptionkey/headset_med
	name = "medical radio encryption key"
	icon_state = "med_cypherkey"
	channels = list(CHANNEL_MEDICAL = TRUE)

/obj/item/device/encryptionkey/headset_sci
	name = "science radio encryption key"
	icon_state = "sci_cypherkey"
	channels = list(CHANNEL_SCIENCE = TRUE)

/obj/item/device/encryptionkey/headset_xenoarch
	name = "xenoarchaeology radio encryption key"
	icon_state = "sci_cypherkey"
	channels = list(CHANNEL_SCIENCE = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/headset_medsci
	name = "medical research radio encryption key"
	icon_state = "medsci_cypherkey"
	channels = list(CHANNEL_MEDICAL = TRUE, CHANNEL_SCIENCE = TRUE)

/obj/item/device/encryptionkey/headset_com
	name = "command radio encryption key"
	icon_state = "com_cypherkey"
	channels = list(CHANNEL_COMMAND = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/heads/captain
	name = "captain's encryption key"
	icon_state = "cap_cypherkey"
	channels = list(CHANNEL_COMMAND = TRUE, CHANNEL_SECURITY = TRUE, CHANNEL_PENAL = TRUE, CHANNEL_ENGINEERING = TRUE, CHANNEL_SCIENCE = TRUE, CHANNEL_MEDICAL = TRUE, CHANNEL_SUPPLY = TRUE, CHANNEL_SERVICE = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/heads/ai_integrated
	name = "ai integrated encryption key"
	desc = "Integrated encryption key"
	icon_state = "cap_cypherkey"
	channels = list(CHANNEL_COMMAND = TRUE, CHANNEL_SECURITY = TRUE, CHANNEL_PENAL = TRUE, CHANNEL_ENGINEERING = TRUE, CHANNEL_SCIENCE = TRUE, CHANNEL_MEDICAL = TRUE, CHANNEL_SUPPLY = TRUE, CHANNEL_SERVICE = TRUE, CHANNEL_AI_PRIVATE = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/heads/rd
	name = "research director's encryption key"
	icon_state = "rd_cypherkey"
	channels = list(CHANNEL_SCIENCE = TRUE, CHANNEL_COMMAND = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/heads/hos
	name = "head of security's encryption key"
	icon_state = "hos_cypherkey"
	channels = list(CHANNEL_SECURITY = TRUE, CHANNEL_COMMAND = TRUE, CHANNEL_PENAL = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/heads/ce
	name = "chief engineer's encryption key"
	icon_state = "ce_cypherkey"
	channels = list(CHANNEL_ENGINEERING = TRUE, CHANNEL_COMMAND = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/heads/cmo
	name = "chief medical officer's encryption key"
	icon_state = "cmo_cypherkey"
	channels = list(CHANNEL_MEDICAL = TRUE, CHANNEL_COMMAND = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/heads/xo
	name = "executive officer's encryption key"
	icon_state = "hop_cypherkey"
	channels = list(CHANNEL_SERVICE = TRUE, CHANNEL_COMMAND = TRUE, CHANNEL_SECURITY = TRUE, CHANNEL_PENAL = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/headset_cargo
	name = "operations radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list(CHANNEL_SUPPLY = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/headset_operations_manager
	name = "operations manager radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list(CHANNEL_COMMAND = TRUE, CHANNEL_SUPPLY = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/headset_service
	name = "service radio encryption key"
	icon_state = "srv_cypherkey"
	channels = list(CHANNEL_SERVICE = TRUE)

/obj/item/device/encryptionkey/ert
	name = "\improper ERT radio encryption key"
	channels = list(CHANNEL_RESPONSE_TEAM = TRUE, CHANNEL_SCIENCE = TRUE, CHANNEL_COMMAND = TRUE, CHANNEL_MEDICAL = TRUE, CHANNEL_ENGINEERING = TRUE, CHANNEL_SECURITY = TRUE, CHANNEL_SUPPLY = TRUE, CHANNEL_SERVICE = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/onlyert
	name = "\improper ERT radio encryption key"
	channels = list(CHANNEL_RESPONSE_TEAM = TRUE, CHANNEL_HAILING = TRUE)

/obj/item/device/encryptionkey/rev
	name = "standard encryption key"
	desc = "An encryption key for a radio headset. Contains cypherkeys."
	additional_channels = list(CHANNEL_RAIDER = TRUE)
	origin_tech = list(TECH_ILLEGAL = 2)

/obj/item/device/encryptionkey/rev/antagonist_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "An encryption key that allows you to intercept private comms speak on private non-ship channels. Use :x to access the private channel."

/obj/item/device/encryptionkey/eng_spare
	name = "spare engineering radio encryption key"
	additional_channels = list(CHANNEL_ENGINEERING = TRUE)

/obj/item/device/encryptionkey/med_spare
	name = "spare medical radio encryption key"
	additional_channels = list(CHANNEL_MEDICAL = TRUE)

/obj/item/device/encryptionkey/sec_spare
	name = "spare security radio encryption key"
	additional_channels = list(CHANNEL_SECURITY = TRUE)

/obj/item/device/encryptionkey/sci_spare
	name = "spare science radio encryption key"
	additional_channels = list(CHANNEL_SCIENCE = TRUE)

/obj/item/device/encryptionkey/cargo_spare
	name = "spare operations radio encryption key"
	additional_channels = list(CHANNEL_SUPPLY = TRUE)

/obj/item/device/encryptionkey/service_spare
	name = "spare service radio encryption key"
	additional_channels = list(CHANNEL_SERVICE = TRUE)

// Encryption Key Pouch
/obj/item/storage/box/fancy/keypouch
	name = "encryption key pouch"
	desc = "A pouch designed to store three encryption keys."
	icon = 'icons/obj/item/device/encryptionkey.dmi'
	icon_state = "keypouch0"
	icon_type = "key"
	storage_type = "pouch"
	opened = TRUE
	closable = FALSE
	center_of_mass = list("x" = 16,"y" = 7)
	storage_slots = 3
	can_hold = list(/obj/item/device/encryptionkey)
	starts_with = null

/obj/item/storage/box/fancy/keypouch/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/box/fancy/keypouch/eng
	starts_with = list(/obj/item/device/encryptionkey/eng_spare = 3)

/obj/item/storage/box/fancy/keypouch/med
	starts_with = list(/obj/item/device/encryptionkey/med_spare = 3)

/obj/item/storage/box/fancy/keypouch/sec
	starts_with = list(/obj/item/device/encryptionkey/sec_spare = 3)

/obj/item/storage/box/fancy/keypouch/sci
	starts_with = list(/obj/item/device/encryptionkey/sci_spare = 3)

/obj/item/storage/box/fancy/keypouch/cargo
	starts_with = list(/obj/item/device/encryptionkey/cargo_spare = 3)

/obj/item/storage/box/fancy/keypouch/service
	starts_with = list(/obj/item/device/encryptionkey/service_spare = 3)
