/obj/item/reagent_containers/toothpaste
	name = "tube of toothpaste"
	desc = "A simple tube full of toothpaste."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "toothpaste"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	possible_transfer_amounts = null
	amount_per_transfer_from_this = 5
	volume = 20
	reagents_to_add = list(/singleton/reagent/drink/toothpaste = 20)

/obj/item/reagent_containers/toothpaste/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/toothpaste/update_icon()
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
		if(0 to 9)			icon_state = "toothpaste_empty"
		if(10 to 50) 		icon_state = "toothpaste_half"
		if(51 to INFINITY)	icon_state = "toothpaste"

/obj/item/reagent_containers/toothpaste/attack_self(mob/user as mob)
	return

/obj/item/reagent_containers/toothbrush
	name = "toothbrush"
	desc = "An essential tool in dental hygiene."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "toothbrush_b"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	possible_transfer_amounts = null
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/reagent_containers/toothbrush/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/toothbrush/update_icon()
	ClearOverlays()

	if(reagents.has_reagent(/singleton/reagent/drink/toothpaste))
		AddOverlays("toothpaste_overlay")

/obj/item/reagent_containers/toothbrush/attack_self(mob/user as mob)
	if(!reagents.total_volume)
		to_chat(user, SPAN_WARNING("The [initial(name)] is dry!"))
	else
		playsound(loc, 'sound/effects/toothbrush.ogg', 15, 1)
		if(do_after(user, 30))
			user.visible_message(
			SPAN_NOTICE("\The [user] brushes [user.get_pronoun("his")] teeth with \the [src]"),
			SPAN_NOTICE("You brush your teeth with \the [src]."))
			reagents.trans_to_mob(user, amount_per_transfer_from_this, CHEM_BREATHE)
			update_icon()
	return

/obj/item/reagent_containers/toothbrush/feed_sound(var/mob/user)
	return

/obj/item/reagent_containers/toothbrush/proc/remove_contents(mob/user, atom/trans_dest = null)
	if(!trans_dest && !user.loc)
		return

/obj/item/reagent_containers/toothbrush/attack(mob/living/target_mob, mob/living/user, target_zone)
	if(isliving(target_mob))
		var/mob/living/M = target_mob
		if(ishuman(M))
			if(!reagents.total_volume)
				to_chat(user, SPAN_WARNING("The [initial(name)] is dry!"))
			else if(reagents.total_volume)
				if(user.zone_sel.selecting == BP_MOUTH && !(M.wear_mask && M.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT))
					user.do_attack_animation(src)
					user.visible_message(SPAN_WARNING("[user] is trying to brush \the [target_mob]'s teeth \the [src]!"))
					playsound(loc, 'sound/effects/toothbrush.ogg', 15, 1)
					if(do_after(user, 30))
						user.visible_message(SPAN_WARNING("[user] has brushed \the [target_mob]'s teeth with \the [src]!"))

						reagents.trans_to_mob(target_mob, amount_per_transfer_from_this, CHEM_BREATHE)
						update_icon()
				else
					wipe_down(target_mob, user)
			return

	return ..()

/obj/item/reagent_containers/toothbrush/afterattack(atom/A as obj|turf|area, mob/user as mob, proximity)
	if(!proximity)
		return

	if(istype(A, /obj/structure/reagent_dispensers) || istype(A, /obj/structure/mopbucket) || istype(A, /obj/item/reagent_containers/glass))
		if(!REAGENTS_FREE_SPACE(reagents))
			return

		if(A.reagents && A.reagents.trans_to_obj(src, reagents.maximum_volume))
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			user.visible_message(SPAN_NOTICE("\The [user] soaks [src] using [A]."),
									SPAN_NOTICE("You soak [src] using [A]."))

			update_icon()
		return

	if(istype(A) && (src in user))
		if(A.is_open_container() && !(A in user))
			remove_contents(user, A)
		else if(!ismob(A)) //mobs are handled in attack()
			wipe_down(A, user)
		return

/obj/item/reagent_containers/toothbrush/proc/wipe_down(atom/A, mob/user)
	if(!reagents.total_volume)
		to_chat(user, SPAN_WARNING("The [initial(name)] is dry!"))
	else
		user.visible_message("\The [user] starts to brush down [A] with [src]!")
		playsound(loc, 'sound/effects/mop.ogg', 25, 1)
		update_icon()
		if(do_after(user, 120))
			user.visible_message("\The [user] finishes brushing off \the [A]!")
			reagents.splash(A, 5)
			A.clean_blood()

/obj/item/reagent_containers/toothbrush/green
	icon_state = "toothbrush_g"

/obj/item/reagent_containers/toothbrush/red
	icon_state = "toothbrush_r"
