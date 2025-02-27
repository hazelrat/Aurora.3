/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/structure/plasticflaps.dmi'
	icon_state = "plasticflaps_preview"
	density = FALSE
	anchored = TRUE
	pass_flags_self = PASSSTRUCTURE | PASSFLAPS
	layer = UNDERDOOR
	explosion_resistance = 5
	build_amt = 4
	color = COLOR_GRAY20 // ideally this would get_step() the material color from nearby walls but this works for now.
	atmos_canpass = CANPASS_PROC

	var/manipulating = FALSE //Prevents queueing up a ton of deconstructs
	var/list/mobs_can_pass = list(
		/mob/living/carbon/slime,
		/mob/living/simple_animal/rat,
		/mob/living/silicon/robot/drone
		)

	var/airtight = FALSE

/obj/structure/plasticflaps/Initialize()
	. = ..()
	material = SSmaterials.get_material_by_name(MATERIAL_PLASTIC)
	update_icon()

/obj/structure/plasticflaps/update_icon()
	. = ..()
	icon_state = "plasticflaps"
	var/image/plasticflaps_overlay = overlay_image(icon, "plasticflaps_overlay", null, RESET_COLOR)
	if(dir == WEST || dir == EAST)
		plasticflaps_overlay.pixel_y = -13
	AddOverlays(plasticflaps_overlay)

/obj/structure/plasticflaps/Destroy()
	ClearOverlays()
	if(airtight)
		clear_airtight()
	. = ..()

/obj/structure/plasticflaps/proc/become_airtight()
	airtight = TRUE
	var/turf/simulated/floor/T = get_turf(loc)
	if(istype(T))
		update_nearby_tiles()

/obj/structure/plasticflaps/proc/clear_airtight()
	airtight = FALSE
	var/turf/simulated/floor/T = get_turf(loc)
	if(istype(T))
		update_nearby_tiles()

/obj/structure/plasticflaps/c_airblock()
	if(airtight)
		return AIR_BLOCKED
	return FALSE

/obj/structure/plasticflaps/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASSGLASS)
		return prob(60)

	if(mover?.movement_type & PHASING)
		return TRUE

	var/obj/structure/bed/B = mover
	if (istype(mover, /obj/structure/bed) && B.buckled)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	if(istype(mover, /obj/vehicle))	//no vehicles
		return 0

	//Bots can always pass
	if(isbot(mover))
		return TRUE

	var/mob/living/M = mover
	if(istype(M))
		if(M.lying)
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(mover, mob_type))
				return ..()
		return issmall(M)

	return ..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/attackby(obj/item/attacking_item, mob/user)
	if(manipulating)	return
	if(attacking_item.iswirecutter() || attacking_item.sharp && !attacking_item.noslice)
		manipulating = TRUE
		visible_message(SPAN_NOTICE("[user] begins cutting down \the [src]."),
					SPAN_NOTICE("You begin cutting down \the [src]."))
		if(!attacking_item.use_tool(src, user, 30, volume = 50))
			manipulating = FALSE
			return
		visible_message(SPAN_NOTICE("[user] cuts down \the [src]."), SPAN_NOTICE("You cut down \the [src]."))
		dismantle()

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
	airtight = TRUE

/obj/structure/plasticflaps/mining/Initialize()
	. = ..()
	update_nearby_tiles()

//Airtight plastic flaps made for the kitchen freezer, blocks atmos but not movement
/obj/structure/plasticflaps/airtight
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
	airtight = TRUE

/obj/structure/plasticflaps/airtight/Initialize()
	. = ..()
	update_nearby_tiles()

/obj/structure/plasticflaps/airtight/CanPass(atom/A, turf/T)
	return 1//Blocks nothing except air
