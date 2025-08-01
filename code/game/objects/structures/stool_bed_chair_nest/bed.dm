/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */

#define CACHE_TYPE_PADDING "padding"
#define CACHE_TYPE_OVER "over"
#define CACHE_TYPE_PADDING_OVER "padding_over"
#define CACHE_TYPE_ARMREST "armrest"
#define CACHE_TYPE_PADDING_ARMREST "padding_armrest"
#define CACHE_TYPE_SPECIAL "special" // Currently being used for shuttle chair special buckles.

/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon = 'icons/obj/structure/beds.dmi'
	icon_state = "bed"
	anchored = TRUE
	buckle_dir = SOUTH
	buckle_lying = 1
	build_amt = 2
	pass_flags_self = PASSTABLE
	var/material/padding_material

	var/base_icon = "bed"
	var/buckling_sound = 'sound/effects/buckle.ogg'

	var/painted_colour // Used for paint gun and preset colours. I know this name sucks.

	var/can_dismantle = TRUE
	var/can_pad = TRUE

	gfi_layer_rotation = GFI_ROTATION_DEFDIR
	var/makes_rolling_sound = FALSE
	var/held_item = null // Set to null if you don't want people to pick this up.
	slowdown = 5

	var/driving = FALSE // Shit for wheelchairs. Doesn't really get used here, but it's for code cleanliness.
	var/mob/living/pulling = null
	var/propelled = 0 // Check for fire-extinguisher-driven chairs

/obj/structure/bed/mechanics_hints()
	. = list()
	. += ..()
	. += "Click and drag yourself (or anyone) to this to buckle in."
	. += "Click on this with an empty hand to undo the buckles."
	. += "Anyone with restraints, such as handcuffs, will not be able to unbuckle themselves. They must use the Resist button, or verb, to break free of \
	the buckles instead."
	. += "To unbuckle people as a stationbound, click the bed with an empty gripper."
	if(held_item)
		. += "Click and drag this onto yourself to pick it up."

/obj/structure/bed/assembly_hints()
	. = list()
	. += ..()
	if(!padding_material)
		. += "It could be padded with <b>cloth or leather</b>."

/obj/structure/bed/disassembly_hints()
	. = list()
	. += ..()
	if(padding_material)
		. += "Its padding has visible seams that could be <b>cut</b>."
	. += "It is held together by a couple of <b>bolts</b>."

/obj/structure/bed/Initialize()
	. = ..()
	LAZYADD(can_buckle, /mob/living)

/obj/structure/bed/New(newloc, new_material = MATERIAL_STEEL, new_padding_material, new_painted_colour)
	..(newloc)
	material = SSmaterials.get_material_by_name(new_material)
	if(!istype(material))
		qdel(src)
		return
	if(new_padding_material)
		padding_material = SSmaterials.get_material_by_name(new_padding_material)
	if(new_painted_colour)
		painted_colour = new_painted_colour
	update_icon()

/obj/structure/bed/buckle(mob/living/M)
	. = ..()
	if(. && buckling_sound)
		playsound(src, buckling_sound, 20)

// Reuse the cache/code from stools, todo maybe unify.
/obj/structure/bed/update_icon()
	generate_strings()
	// Prep icon.
	icon_state = ""
	ClearOverlays()
	// Base icon.

	generate_overlay_cache(material) //Generate base icon cache
	// Padding overlay.
	if(padding_material)
		generate_overlay_cache(padding_material, CACHE_TYPE_PADDING, apply_painted_colour = TRUE)

/obj/structure/bed/proc/generate_overlay_cache(var/new_material, var/cache_type, var/cache_layer = layer, var/apply_painted_colour = FALSE) // Cache type refers to what cache we're making. Material type refers if we're taking from the padding or the chair material itself.
	var/material/overlay_material = new_material
	var/list/furniture_cache = SSicon_cache.furniture_cache
	var/cache_key = "[base_icon]-[overlay_material.name]" // Basically, generates a cache key for an overlay.
	if(cache_type)
		cache_key += "-[cache_type]"
		if(painted_colour && apply_painted_colour)
			cache_key += "-[painted_colour]"
		else if(overlay_material.icon_colour)
			cache_key += "-[overlay_material.icon_colour]"
	if(!furniture_cache[cache_key]) // Check for cache key. Generate if image does not exist yet.
		var/cache_icon_state = cache_type ? "[base_icon]_[cache_type]" : "[base_icon]" // Modularized. Just change cache_type when calling the proc if you ever wanted to add a different overlay. Not like you'd need to.
		var/image/I =  image(icon, cache_icon_state, layer = cache_layer) // Generate the icon.
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			if(painted_colour && apply_painted_colour) // apply_painted_color, when you only want the padding to be painted, NOT the chair itself.
				I.color = painted_colour
			else if(overlay_material.icon_colour) // Either that, or just fall back on the regular material color.
				I.color = overlay_material.icon_colour
		furniture_cache[cache_key] = I
	AddOverlays(furniture_cache[cache_key]) // Use image from cache key!

/obj/structure/bed/proc/generate_strings()
	if(material_alteration & MATERIAL_ALTERATION_NAME)
		name = padding_material ? "[padding_material.adjective_name] padded [material.adjective_name] [initial(name)]" : "[material.adjective_name] [initial(name)]" //this is not perfect but it will do for now.

	if(material_alteration & MATERIAL_ALTERATION_DESC)
		desc = initial(desc)
		desc += padding_material ? " It's made of [material.use_name] and covered with [padding_material.use_name][painted_colour ? ", colored in <font color='[painted_colour]'>[painted_colour]</font>" : ""]." : " It's made of [material.use_name]." //Yeah plain hex codes suck but at least it's a little funny and less of a headache for players.

/obj/structure/bed/proc/set_colour(new_colour)
	if(padding_material)
		var/last_colour = painted_colour
		painted_colour = new_colour
		return painted_colour != last_colour

/obj/structure/bed/forceMove(atom/destination)
	. = ..()
	if(buckled)
		buckled.forceMove(destination)

/obj/structure/bed/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return

/obj/structure/bed/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.iswrench())
		if(can_dismantle)
			dismantle(attacking_item, user)
	else if(istype(attacking_item,/obj/item/stack))
		if(!can_pad)
			return
		if(padding_material)
			to_chat(user, "\The [src] is already padded.")
			return
		var/obj/item/stack/C = attacking_item
		if(C.get_amount() < 1) // How??
			to_chat(user, SPAN_WARNING("You don't have enough [C]!"))
			qdel(C)
			return
		var/padding_type //This is awful but it needs to be like this until tiles are given a material var.
		if(istype(attacking_item,/obj/item/stack/tile/carpet))
			padding_type = "carpet"
		else if(istype(attacking_item,/obj/item/stack/material))
			var/obj/item/stack/material/M = attacking_item
			if(M.material && (M.material.flags & MATERIAL_PADDING))
				padding_type = "[M.material.name]"
		if(!padding_type)
			to_chat(user, "You cannot pad \the [src] with that.")
			return
		C.use(1)
		if(!istype(src.loc, /turf))
			user.drop_from_inventory(src)
			src.forceMove(get_turf(src))
		to_chat(user, "You add padding to \the [src].")
		add_padding(padding_type)
		return

	else if (attacking_item.iswirecutter())
		if(!can_pad)
			return
		if(!padding_material)
			to_chat(user, "\The [src] has no padding to remove.")
			return
		to_chat(user, "You remove the padding from \the [src].")
		playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
		painted_colour = null
		remove_padding()

	else if (attacking_item.isscrewdriver())
		if(anchored)
			anchored = FALSE
			to_chat(user, "You unfasten \the [src] from floor.")
		else
			anchored = TRUE
			to_chat(user, "You fasten \the [src] to the floor.")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

	else if(istype(attacking_item, /obj/item/grab))
		var/obj/item/grab/G = attacking_item
		var/mob/living/affecting = G.affecting
		user.visible_message(SPAN_NOTICE("[user] attempts to buckle [affecting] into \the [src]!"))
		if(do_after(user, 2 SECONDS, affecting, DO_UNIQUE))
			affecting.forceMove(loc)
			spawn(0)
				if(buckle(affecting, user))
					affecting.visible_message(\
						SPAN_DANGER("[affecting.name] is buckled to [src] by [user.name]!"),\
						SPAN_DANGER("You are buckled to [src] by [user.name]!"),\
						SPAN_NOTICE("You hear metal clanking."))
			qdel(attacking_item)

	else if(istype(attacking_item, /obj/item/gripper) && buckled)
		var/obj/item/gripper/G = attacking_item
		if(!G.wrapped)
			user_unbuckle(user)

	else if(istype(attacking_item, /obj/item/disk))
		user.drop_from_inventory(attacking_item, get_turf(src))
		attacking_item.pixel_x = 10 //make sure they reach the pillow
		attacking_item.pixel_y = -6

	else if(istype(attacking_item, /obj/item/device/paint_sprayer))
		return

	else if(!istype(attacking_item, /obj/item/bedsheet))
		..()

/obj/structure/bed/proc/remove_padding()
	if(padding_material)
		padding_material.place_sheet(get_turf(src))
		padding_material = null
	update_icon()

/obj/structure/bed/proc/add_padding(var/padding_type)
	padding_material = SSmaterials.get_material_by_name(padding_type)
	update_icon()

/obj/structure/bed/dismantle(obj/item/W, mob/user)
	user.visible_message("<b>[user]</b> begins dismantling \the [src].", SPAN_NOTICE("You begin dismantling \the [src]."))
	if(W.use_tool(src, user, 20, volume = 50))
		user.visible_message("\The [user] dismantles \the [src].", SPAN_NOTICE("You dismantle \the [src]."))
		if(padding_material)
			padding_material.place_sheet(get_turf(src))
		..()

/obj/structure/bed/Move()
	. = ..()
	if(makes_rolling_sound && has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 50, 1)
	if(buckled && !istype(src, /obj/structure/bed/roller))
		var/mob/living/occupant = buckled
		if(!driving)
			occupant.buckled_to = null
			occupant.Move(src.loc)
			occupant.buckled_to = src
			if (occupant && (src.loc != occupant.loc))
				if (propelled)
					for (var/mob/O in src.loc)
						if (O != occupant)
							Collide(O)
				else
					unbuckle()
			if (pulling && (get_dist(src, pulling) > 1))
				pulling.pulledby = null
				to_chat(pulling, SPAN_WARNING("You lost your grip!"))
				pulling = null
		else
			if (occupant && (src.loc != occupant.loc))
				src.forceMove(occupant.loc) // Failsafe to make sure the wheelchair stays beneath the occupant after driving

/obj/structure/bed/Collide(atom/A)
	. = ..()
	if(!buckled)
		return

	if(propelled || (pulling && (pulling.a_intent == I_HURT)))
		var/mob/living/occupant = unbuckle()

		if (pulling && (pulling.a_intent == I_HURT))
			occupant.throw_at(A, 3, 3, pulling)
		else if (propelled)
			occupant.throw_at(A, 3, propelled)

		var/def_zone = ran_zone()
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN)
		occupant.apply_effect(6, WEAKEN)
		occupant.apply_effect(6, STUTTER)
		occupant.apply_damage(10, DAMAGE_BRUTE, def_zone)
		playsound(src.loc, "punch", 50, 1, -1)
		if(isliving(A))
			var/mob/living/victim = A
			def_zone = ran_zone()
			victim.apply_effect(6, STUN)
			victim.apply_effect(6, WEAKEN)
			victim.apply_effect(6, STUTTER)
			victim.apply_damage(10, DAMAGE_BRUTE, def_zone)

		if(pulling)
			occupant.visible_message(SPAN_DANGER("[pulling] has thrusted \the [name] into \the [A], throwing \the [occupant] out of it!"))
			pulling.attack_log += "\[[time_stamp()]\]<span class='warning'> Crashed [occupant.name]'s ([occupant.ckey]) [name] into \a [A]</span>"
			occupant.attack_log += "\[[time_stamp()]\]<font color='orange'> Thrusted into \a [A] by [pulling.name] ([pulling.ckey]) with \the [name]</font>"
			msg_admin_attack("[pulling.name] ([pulling.ckey]) has thrusted [occupant.name]'s ([occupant.ckey]) [name] into \a [A] (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[pulling.x];Y=[pulling.y];Z=[pulling.z]'>JMP</a>)",ckey=key_name(pulling),ckey_target=key_name(occupant))
		else
			occupant.visible_message(SPAN_DANGER("[occupant] crashed into \the [A]!"))

/obj/structure/bed/psych
	name = "psychiatrist's couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	base_icon = "psychbed"

/obj/structure/bed/bunk
	icon_state = "bunkbed"
	base_icon = "bunkbed"

/obj/structure/bed/psych/New(var/newloc)
	..(newloc, MATERIAL_WOOD, MATERIAL_LEATHER)

/obj/structure/bed/padded/New(var/newloc)
	..(newloc, MATERIAL_PLASTIC, MATERIAL_CLOTH)

/obj/structure/bed/padded/bunk
	pixel_y = 16
	var/sleeby_shift = 16

/obj/structure/bed/padded/bunk/post_buckle(atom/movable/MA)
	. = ..()
	if(MA == buckled)
		if(istype(MA, /mob/living))
			var/mob/living/M = MA
			M.old_y = sleeby_shift
		buckled.pixel_y = sleeby_shift
		update_icon()
	else
		if(istype(MA, /mob/living))
			var/mob/living/M = MA
			M.old_y = 0
		MA.pixel_y = 0
		update_icon()

/obj/structure/bed/aqua
	name = "aquabed"
	icon_state = "aquabed"

/obj/structure/bed/aqua/Initialize()
	.=..()
	set_light(1,1,LIGHT_COLOR_CYAN)

/obj/structure/bed/aqua/update_icon()
	return

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "standard_down"
	item_state = "rollerbed"
	anchored = FALSE
	makes_rolling_sound = TRUE
	base_icon = "standard"
	held_item = /obj/item/roller
	var/obj/item/reagent_containers/beaker
	var/obj/item/vitals_monitor/vitals
	var/iv_attached = 0
	var/iv_stand = TRUE
	var/iv_transfer_rate = 4 //Same as max for regular IV drips
	var/has_iv_light = TRUE
	//Items that can be attached to an IV
	var/list/accepted_containers = list(
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle)
	var/patient_shift = 9 //How much are mobs moved up when they are buckled_to.
	slowdown = 0

/obj/structure/bed/roller/Initialize()
	. = ..()
	LAZYADD(can_buckle, /obj/structure/closet/body_bag)

/obj/structure/bed/roller/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(vitals)
	return ..()

/obj/structure/bed/roller/update_icon()
	ClearOverlays()
	vis_contents = list()
	if(density)
		if(anchored)
			icon_state = "[base_icon]_br"
		else
			icon_state = "[base_icon]_up"
	else
		icon_state = "[base_icon]_down"
	if(beaker)
		var/image/iv = image(icon, "iv[iv_attached]")
		var/percentage = round((beaker.reagents.total_volume / beaker.volume) * 100, 25)
		var/image/filling = image(icon, "iv_filling[percentage]")
		filling.color = beaker.reagents.get_color()
		iv.AddOverlays(filling)
		if(percentage < 25)
			iv.AddOverlays(image(icon, "light_low"))
		if(density)
			iv.pixel_y = 7
		AddOverlays(iv)
		if(has_iv_light)
			var/image/light = image(icon, "iv[iv_attached]_l")
			AddOverlays(light)
	if(vitals)
		vitals.update_monitor()
		add_vis_contents(vitals)

/obj/structure/bed/roller/attackby(obj/item/attacking_item, mob/user)
	if(iswrench(attacking_item) || istype(attacking_item, /obj/item/stack) || iswirecutter(attacking_item))
		return 1
	if(istype(attacking_item, /obj/item/vitals_monitor))
		if(vitals)
			to_chat(user, SPAN_WARNING("\The [src] already has a vitals monitor attached!"))
			return
		to_chat(user, SPAN_NOTICE("You attach \the [attacking_item] to \the [src]."))
		user.drop_from_inventory(attacking_item, src)
		vitals = attacking_item
		vitals.bed = src
		update_icon()
		return
	if(iv_stand && !beaker && is_type_in_list(attacking_item, accepted_containers))
		if(!user.unEquip(attacking_item, target = src))
			return
		to_chat(user, SPAN_NOTICE("You attach \the [attacking_item] to \the [src]."))
		beaker = attacking_item
		update_icon()
		return 1
	..()

/obj/structure/bed/roller/attack_hand(mob/living/user)
	if(beaker && !buckled)
		remove_beaker(user)
	else
		..()

/obj/structure/bed/roller/AltClick(mob/user)
	if(density && !use_check_and_message(user))
		anchored = !anchored
		user.visible_message(SPAN_NOTICE("[user] [anchored ? "locks" : "releases"] \the [src]'s brakes."))
		update_icon()

/obj/structure/bed/roller/proc/collapse()
	if(buckled)
		to_chat(usr, SPAN_WARNING("\The [buckled] is on \the [src]. Remove them first."))
		return
	usr.visible_message(SPAN_NOTICE("<b>[usr]</b> collapses \the [src]."), SPAN_NOTICE("You collapse \the [src]"))
	new held_item(get_turf(src))
	qdel(src)

/obj/structure/bed/roller/process()
	if(!iv_attached || !buckled || !beaker)
		return PROCESS_KILL

	if(SSprocessing.times_fired % 2)
		return

	if(beaker.volume > 0)
		beaker.reagents.trans_to_mob(buckled, min(iv_transfer_rate, beaker.amount_per_transfer_from_this), CHEM_BLOOD)
		update_icon()

/obj/structure/bed/roller/proc/remove_beaker(mob/user)
	to_chat(user, SPAN_NOTICE("You detach \the [beaker] from \the [src]."))
	iv_attached = FALSE
	beaker.dropInto(loc)
	beaker = null
	update_icon()

/obj/structure/bed/roller/proc/remove_vitals(mob/user)
	to_chat(user, SPAN_NOTICE("You detach \the [vitals] from \the [src]."))
	vitals.bed = null
	vitals.update_monitor()
	user.put_in_hands(vitals)
	vitals = null
	update_icon()

/obj/structure/bed/roller/proc/attach_iv(mob/living/carbon/human/target, mob/user)
	if(!beaker)
		return
	if(do_mob(user, target, 1 SECOND))
		user.visible_message(SPAN_NOTICE("<b>[user]</b> attaches [target] to the IV on \the [src]."), SPAN_NOTICE("You attach the IV to \the [target]."))
		iv_attached = TRUE
		update_icon()
		START_PROCESSING(SSprocessing, src)

/obj/structure/bed/roller/proc/detach_iv(mob/living/carbon/human/target, mob/user)
	user.visible_message(SPAN_NOTICE("<b>[user]</b> takes [target] off the IV on \the [src]."), SPAN_NOTICE("You take the IV off \the [target]."))
	iv_attached = FALSE
	update_icon()
	STOP_PROCESSING(SSprocessing, src)

/obj/structure/bed/roller/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	..()
	if(use_check(user) || !Adjacent(user))
		return
	if(!ishuman(user) && (!isrobot(user) || isDrone(user))) //Humans and borgs can collapse, but not drones
		return
	if(over == buckled && beaker)
		if(iv_attached)
			detach_iv(buckled, user)
		else
			attach_iv(buckled, user)
		return
	if(user != over && ishuman(over))
		if(user_buckle(over, user))
			attach_iv(buckled, user)
			return
	if(beaker)
		remove_beaker(user)
		return
	if(vitals)
		remove_vitals(user)
		return
	if(buckled)
		to_chat(user, SPAN_WARNING("\The [buckled] is on \the [src]. Remove them first."))
		return
	collapse()

/obj/structure/bed/roller/Move()
	. = ..()
	if(buckled)
		if(buckled.buckled_to == src)
			buckled.forceMove(src.loc)
		else
			buckled = null

/obj/structure/bed/roller/post_buckle(atom/movable/MA)
	. = ..()
	if(MA == buckled)
		if(istype(MA, /mob/living))
			var/mob/living/M = MA
			M.old_y = patient_shift
		density = TRUE
		buckled.pixel_y = patient_shift
		update_icon()
	else
		if(istype(MA, /mob/living))
			var/mob/living/M = MA
			M.old_y = 0
			if(iv_attached)
				detach_iv(M, usr)
		density = FALSE
		anchored = FALSE
		MA.pixel_y = 0
		update_icon()


/obj/structure/bed/roller/hover
	name = "medical hoverbed"
	icon_state = "hover_down"
	base_icon = "hover"
	makes_rolling_sound = FALSE
	held_item = /obj/item/roller/hover
	has_iv_light = FALSE

/obj/structure/bed/roller/hover/Initialize()
	.=..()
	set_light(2,1,LIGHT_COLOR_CYAN)

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "standard_folded"
	base_icon = "standard"
	item_state = "rbed"
	contained_sprite = TRUE
	drop_sound = 'sound/items/drop/axe.ogg'
	pickup_sound = 'sound/items/pickup/axe.ogg'
	center_of_mass = list("x" = 17,"y" = 7)
	var/origin_type = /obj/structure/bed/roller
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/roller/hover
	name = "medical hoverbed"
	desc = "A collapsed hoverbed that can be carried around."
	icon_state = "hover_folded"
	base_icon = "hover"
	item_state = "rbed_hover"
	origin_type = /obj/structure/bed/roller/hover

/obj/item/roller/attack_self(mob/user)
	..()
	deploy_roller(user, user.loc)

/obj/item/roller/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	var/turf/T = target
	if(is_type_in_list(target, list(/obj/effect, /obj/structure/lattice)))
		T = get_turf(target)
	if(istype(T))
		if(!T.density)
			deploy_roller(user, T)

/obj/item/roller/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/roller_holder))
		var/obj/item/roller_holder/RH = attacking_item
		if(!RH.held)
			to_chat(user, SPAN_NOTICE("You collect the roller bed."))
			src.forceMove(RH)
			RH.held = src
		return TRUE

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new origin_type(location)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "standard_folded"
	var/obj/item/roller/held

/obj/item/roller_holder/New()
	..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/attack_self(mob/user as mob)
	if(!held)
		to_chat(user, SPAN_NOTICE("The rack is empty."))
		return
	to_chat(user, SPAN_NOTICE("You deploy the roller bed."))
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(user.loc)
	R.add_fingerprint(user)
	qdel(held)
	held = null

/**
 * # Roller Rack
 *
 * A rack structure that can hold up to four roller bed items (Or subtypes i.e. Hoverbeds), stored in the `held` list.
 *
 * The `initial_beds` variable controls the number of beds the rack will spawn with.
*/
/obj/structure/roller_rack
	name = "roller bed rack"
	desc = "A rack for holding collapsed roller beds."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "holder"

	/**
	 * List of held roller bed items.
	 */
	var/list/obj/item/roller/held = list()

	/**
	 * The number of beds the rack spawns with
	 */
	var/initial_beds = 4

/obj/structure/roller_rack/feedback_hints(mob/user, distance, is_adjacent)
	. = list()
	. += "[initial(desc)] \nIt is holding [LAZYLEN(held)] beds."

/obj/structure/roller_rack/assembly_hints(mob/user, distance, is_adjacent)
	. = list()
	. += "It [anchored ? "is" : "could be"] anchored to the floor with a couple of <b>screws</b>."

/obj/structure/roller_rack/Initialize()
	. = ..()
	for(var/_ in 1 to initial_beds)
		var/obj/item/roller/RB = new /obj/item/roller(src)
		held += RB
	update_icon()

/obj/structure/roller_rack/Destroy()
	QDEL_LIST(held)
	return ..()

/obj/structure/roller_rack/update_icon()
	. = ..()
	ClearOverlays()
	var/beds = 0
	for(var/obj/item/roller/RB in held)
		var/image/I = overlay_image(icon, "[icon_state]_bed_[RB.base_icon]")
		I.pixel_x = (5 * beds)
		beds++
		AddOverlays(I)

/obj/structure/roller_rack/attack_hand(mob/user)
	if(!LAZYLEN(held))
		to_chat(user, SPAN_NOTICE("The rack is empty."))
		return

	var/obj/item/roller/RB = held[LAZYLEN(held)]
	user.put_in_hands(RB)
	held -= RB
	to_chat(user, SPAN_NOTICE("You retrieve \the [RB] from the rack."))
	update_icon()

/obj/structure/roller_rack/attackby(obj/item/attacking_item, mob/user)
	if(iswrench(attacking_item))
		anchored = !anchored
		to_chat(user, SPAN_NOTICE("You [anchored ? "bolt" : "unbolt"] \the [src] [anchored ? "to" : "from"] the ground."))

	if(istype(attacking_item, /obj/item/roller))
		var/obj/item/roller/RB = attacking_item

		if(LAZYLEN(held) >= 4)
			to_chat(user, SPAN_NOTICE("The rack has no space for \the [RB]"))
			return

		user.drop_from_inventory(RB, src)
		held += RB
		to_chat(user, SPAN_NOTICE("You place \the [RB] on the rack."))
		update_icon()

/obj/structure/roller_rack/two
	initial_beds = 2

/obj/structure/roller_rack/three
	initial_beds = 3
