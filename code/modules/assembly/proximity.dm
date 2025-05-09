/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	drop_sound = 'sound/items/drop/component.ogg'
	pickup_sound = 'sound/items/pickup/component.ogg'
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(DEFAULT_WALL_MATERIAL = 800, MATERIAL_GLASS = 200)
	movable_flags = MOVABLE_FLAG_PROXMOVE
	wires = WIRE_PULSE_ASSEMBLY

	secured = FALSE

	var/scanning = FALSE
	var/timing = FALSE
	var/time = 10
	var/range = 2

/obj/item/device/assembly/prox_sensor/activate()
	. = ..()
	if(!.)
		return 0//Cooldown check
	timing = !timing
	update_icon()
	return FALSE

/obj/item/device/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSprocessing, src)
	else
		scanning = FALSE
		timing = FALSE
		STOP_PROCESSING(SSprocessing, src)
	update_icon()
	return secured

/obj/item/device/assembly/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if(!istype(AM))
		LOG_DEBUG("DEBUG: HasProximity called with [AM] on [src] ([usr]).")
		return
	if(istype(AM, /obj/effect/beam))
		return
	if(AM.move_speed < 12)
		sense()

/obj/item/device/assembly/prox_sensor/proc/sense()
	var/turf/mainloc = get_turf(src)
	if((!holder && !secured) || !scanning || cooldown)
		return FALSE
	pulse(FALSE)
	if(!holder)
		mainloc.audible_message("[icon2html(src, viewers(get_turf(src)))] *beep* *beep*", "*beep* *beep*")
	cooldown = 2
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 1 SECOND)

/obj/item/device/assembly/prox_sensor/process()
	if(scanning)
		var/turf/mainloc = get_turf(src)
		for(var/mob/living/A in range(range, mainloc))
			if(A.move_speed < 12)
				sense()

	if(timing)
		if(time >= 0)
			time--
		if(time <= 0)
			timing = FALSE
			toggle_scan()
			time = 10

/obj/item/device/assembly/prox_sensor/dropped()
	. = ..()
	spawn(0)
		sense()

/obj/item/device/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	update_icon()
	return

/obj/item/device/assembly/prox_sensor/update_icon()
	ClearOverlays()
	attached_overlays = list()
	if(timing)
		AddOverlays("prox_timing")
		attached_overlays += "prox_timing"
	if(scanning)
		AddOverlays("prox_scanning")
		attached_overlays += "prox_scanning"
	if(holder)
		holder.update_icon()
		if(istype(holder.loc, /obj/item/grenade/chem_grenade))
			var/obj/item/grenade/chem_grenade/grenade = holder.loc
			grenade.primed(scanning)

/obj/item/device/assembly/prox_sensor/Move()
	. = ..()
	sense()

/obj/item/device/assembly/prox_sensor/interact(mob/user)
	if(!secured)
		to_chat(user, SPAN_WARNING("\The [src] is unsecured!"))
		return FALSE

	ui_interact(user)

/obj/item/device/assembly/prox_sensor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Proximity", "Proximity Sensor", 450, 360)
		ui.open()

/obj/item/device/assembly/prox_sensor/ui_data(mob/user)
	var/list/data = list()

	data["timeractive"] = timing
	data["time"] = time
	data["scanning"] = scanning
	data["range"] = range

	return data

/obj/item/device/assembly/prox_sensor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("scanning")
			toggle_scan()
			. = TRUE

		if("time")
			timing = !timing
			update_icon()
			. = TRUE

		if("tp")
			var/tp = text2num(params["tp"])
			time = clamp(tp, 1, 600)
			. = TRUE

		if("range")
			var/r = text2num(params["range"])
			range = clamp(r, 1, 5)
			. = TRUE

