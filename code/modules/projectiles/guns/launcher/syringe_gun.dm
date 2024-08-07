/obj/item/syringe_cartridge
	name = "syringe gun cartridge"
	desc = "An impact-triggered compressed gas cartridge that can be fitted to a syringe for rapid injection."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "syringe-cartridge"
	var/icon_flight = "syringe-cartridge-flight" //so it doesn't look so weird when shot
	matter = list(DEFAULT_WALL_MATERIAL = 125, MATERIAL_GLASS = 375)
	obj_flags = OBJ_FLAG_CONDUCTABLE
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 3
	force = 3
	w_class = WEIGHT_CLASS_TINY
	var/obj/item/reagent_containers/syringe/syringe

/obj/item/syringe_cartridge/update_icon()
	if(syringe)
		icon_state = "syringe-cartridge-loaded"
	else
		icon_state = "syringe-cartridge"

/obj/item/syringe_cartridge/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/reagent_containers/syringe))
		syringe = attacking_item
		to_chat(user, SPAN_NOTICE("You carefully insert [syringe] into [src]."))
		user.remove_from_mob(syringe)
		syringe.forceMove(src)
		sharp = 1
		name = "syringe dart"
		update_icon()

/obj/item/syringe_cartridge/attack_self(mob/user)
	if(syringe)
		to_chat(user, SPAN_NOTICE("You remove [syringe] from [src]."))
		user.put_in_hands(syringe)
		syringe = null
		sharp = initial(sharp)
		name = initial(name)
		update_icon()

/obj/item/syringe_cartridge/proc/prime()
	//the icon state will revert back when update_icon() is called from throw_impact()
	icon_state = icon_flight
	underlays.Cut()

/obj/item/syringe_cartridge/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..() //handles embedding for us. Should have a decent chance if thrown fast enough
	if(syringe)
		//check speed to see if we hit hard enough to trigger the rapid injection
		//incidentally, this means syringe_cartridges can be used with the pneumatic launcher
		if(throwingdatum.speed >= 10 && isliving(hit_atom))
			var/mob/living/L = hit_atom
			//unfortuately we don't know where the dart will actually hit, since that's done by the parent.
			if(L.can_inject() && syringe.reagents)
				var/singleton/reagent/reagent_log = syringe.reagents.get_reagents()
				syringe.reagents.trans_to_mob(L, 15, CHEM_BLOOD)
				admin_inject_log(throwing?.thrower?.resolve(), L, src, reagent_log, syringe.reagents.get_temperature(), 15, violent=1)

		syringe.break_syringe(iscarbon(hit_atom)? hit_atom : null)
		syringe.update_icon()

	icon_state = initial(icon_state) //reset icon state
	update_icon()

/obj/item/gun/launcher/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/guns/syringegun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	force = 16
	matter = list(DEFAULT_WALL_MATERIAL = 2000)
	slot_flags = SLOT_BELT

	fire_sound = 'sound/weapons/click.ogg'
	fire_sound_text = "a metallic thunk"
	recoil = 0
	release_force = 10
	throw_distance = 10

	needspin = FALSE

	var/list/darts = list()
	var/max_darts = 1
	var/obj/item/syringe_cartridge/next

/obj/item/gun/launcher/syringe/consume_next_projectile()
	if(next)
		next.prime()
		return next
	return null

/obj/item/gun/launcher/syringe/handle_post_fire()
	..()
	darts -= next
	next = null

/obj/item/gun/launcher/syringe/unique_action(mob/living/user)
	if(next)
		user.visible_message("[user] unlatches and carefully relaxes the bolt on [src].", SPAN_WARNING("You unlatch and carefully relax the bolt on [src], unloading the spring."))
		playsound(src.loc, 'sound/weapons/blade_close.ogg', 50, 1)
		next = null
	else if(darts.len)
		playsound(src.loc, 'sound/weapons/blade_open.ogg', 50, 1)
		user.visible_message("[user] draws back the bolt on [src], clicking it into place.", SPAN_WARNING("You draw back the bolt on the [src], loading the spring!"))
		next = darts[1]
	add_fingerprint(user)

/obj/item/gun/launcher/syringe/attack_hand(mob/living/user as mob)
	if(user.get_inactive_hand() == src)
		if(!darts.len)
			to_chat(user, SPAN_WARNING("[src] is empty."))
			return
		if(next)
			to_chat(user, SPAN_WARNING("[src]'s cover is locked shut."))
			return
		var/obj/item/syringe_cartridge/C = darts[1]
		darts -= C
		user.put_in_hands(C)
		user.visible_message("[user] removes \a [C] from [src].", SPAN_NOTICE("You remove \a [C] from [src]."))
	else
		..()

/obj/item/gun/launcher/syringe/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/syringe_cartridge))
		var/obj/item/syringe_cartridge/C = attacking_item
		if(darts.len >= max_darts)
			to_chat(user, SPAN_WARNING("[src] is full!"))
			return
		user.remove_from_mob(C)
		C.forceMove(src)
		darts += C //add to the end
		user.visible_message("[user] inserts \a [C] into [src].", SPAN_NOTICE("You insert \a [C] into [src]."))
	else
		..()

/obj/item/gun/launcher/syringe/rapid
	name = "syringe gun revolver"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to five syringes. The spring still needs to be drawn between shots."
	icon = 'icons/obj/guns/syringegun.dmi'
	icon_state = "rapidsyringegun"
	item_state = "rapidsyringegun"
	max_darts = 5
