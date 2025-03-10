/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar electrical generator."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	anchored = 1
	density = 1
	use_power = POWER_USE_OFF
	idle_power_usage = 0
	active_power_usage = 0
	var/id = 0
	var/health = 10
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH // actual dir
	var/ndir = SOUTH // target dir
	var/turn_angle = 0
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/solar/drain_power()
	return -1

/obj/machinery/power/solar/Initialize(mapload, var/obj/item/solar_assembly/S)
	. = ..()
	Make(S)
	connect_to_network()

/obj/machinery/power/solar/Destroy()
	unset_control() //remove from control computer
	return ..()

//set the control of the panel to a given computer if closer than SOLAR_MAX_DIST
/obj/machinery/power/solar/proc/set_control(var/obj/machinery/power/solar_control/SC)
	if(SC && (get_dist(src, SC) > SOLAR_MAX_DIST))
		return 0
	control = SC
	START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
	return 1

//set the control of the panel to null and removes it from the control list of the previous control computer if needed
/obj/machinery/power/solar/proc/unset_control()
	if(control)
		control.connected_panels.Remove(src)
	control = null
	STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)

/obj/machinery/power/solar/proc/Make(var/obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/material/glass
		S.anchored = 1
	S.forceMove(src)
	if(S.glass_type == /obj/item/stack/material/glass/reinforced) //if the panel is in reinforced glass
		health *= 2 								 //this need to be placed here, because panels already on the map don't have an assembly linked to
	update_icon()



/obj/machinery/power/solar/attackby(obj/item/attacking_item, mob/user)

	if(attacking_item.iscrowbar())
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		user.visible_message(SPAN_NOTICE("[user] begins to take the glass off the solar panel."))
		if(attacking_item.use_tool(src, user, 50, volume = 50))
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.forceMove(src.loc)
				S.give_glass()
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message(SPAN_NOTICE("[user] takes the glass off the solar panel."))
			qdel(src)
		return
	else if (attacking_item)
		src.add_fingerprint(user)
		src.health -= attacking_item.force
		src.healthcheck()
	..()


/obj/machinery/power/solar/proc/healthcheck()
	if (src.health <= 0)
		if(!(stat & BROKEN))
			broken()
		else
			new /obj/item/material/shard(src.loc)
			new /obj/item/material/shard(src.loc)
			qdel(src)
			return
	return


/obj/machinery/power/solar/update_icon()
	..()
	ClearOverlays()
	if(stat & BROKEN)
		AddOverlays("solar_panel-b")
	else
		AddOverlays("solar_panel")
		set_angle(adir)
	return

//calculates the fraction of the sunlight that the panel receives
/obj/machinery/power/solar/proc/update_solar_exposure()
	if(!SSsun)
		return
	if(obscured)
		sunfrac = 0
		return

	//find the smaller angle between the direction the panel is facing and the direction of the sun (the sign is not important here)
	var/p_angle = min(abs(adir - SSsun.angle), 360 - abs(adir - SSsun.angle))

	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2
	//isn't the power received from the incoming light proportionnal to cos(p_angle) (Lambert's cosine law) rather than cos(p_angle)^2 ?

/obj/machinery/power/solar/process()
	if(stat & BROKEN || !control || !SSsun)
		return PROCESS_KILL

	if(powernet && powernet == control.powernet)
		if(obscured) //get no light from the sun, so don't generate power
			return
		var/sgen = SOLARGENRATE * sunfrac
		add_avail(sgen)
		control.gen += sgen
	else //if we're no longer on the same powernet, remove from control computer
		unset_control()

/obj/machinery/power/solar/proc/broken()
	stat |= BROKEN
	unset_control()
	update_icon()
	return


/obj/machinery/power/solar/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(15))
				new /obj/item/material/shard( src.loc )
			qdel(src)
			return

		if(2.0)
			if (prob(25))
				new /obj/item/material/shard( src.loc )
				qdel(src)
				return

			if (prob(50))
				broken()

		if(3.0)
			if (prob(25))
				broken()
	return


/obj/machinery/power/solar/fake/Initialize(mapload, var/obj/item/solar_assembly/S)
	. = ..(mapload, S, 0)

/obj/machinery/power/solar/fake/process()
	return PROCESS_KILL

//trace towards sun to see if we're in shadow
/obj/machinery/power/solar/proc/occlusion()

	var/ax = x		// start at the solar panel
	var/ay = y
	var/turf/T = null

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += SSsun.dx	// do step
		ay += SSsun.dy

		T = locate( round(ax,0.5),round(ay,0.5),z)

		if(!T || T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.opacity)			// if we hit a solid turf, panel is obscured
			obscured = 1
			return

	obscured = 0		// if hit the edge or stepped 20 times, not obscured
	update_solar_exposure()


//
// Solar Assembly - For construction of solar arrays.
//

/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker"
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	item_state = "electropack"
	w_class = WEIGHT_CLASS_BULKY // Pretty big!
	anchored = 0
	var/tracker = 0
	var/glass_type = null

/obj/item/solar_assembly/attack_hand(var/mob/user)
	if(!anchored && isturf(loc)) // You can't pick it up
		..()

// Give back the glass type we were supplied with
/obj/item/solar_assembly/proc/give_glass()
	if(glass_type)
		var/obj/item/stack/material/S = new glass_type(src.loc)
		S.amount = 2
		glass_type = null


/obj/item/solar_assembly/attackby(obj/item/attacking_item, mob/user)

	if(!anchored && isturf(loc))
		if(attacking_item.iswrench())
			anchored = 1
			user.visible_message(SPAN_NOTICE("[user] wrenches the solar assembly into place."))
			attacking_item.play_tool_sound(get_turf(src), 75)
			return 1
	else
		if(attacking_item.iswrench())
			anchored = 0
			user.visible_message(SPAN_NOTICE("[user] unwrenches the solar assembly from it's place."))
			attacking_item.play_tool_sound(get_turf(src), 75)
			return 1

		if(istype(attacking_item, /obj/item/stack/material) && (attacking_item.get_material_name() == "glass" || attacking_item.get_material_name() == MATERIAL_GLASS_REINFORCED))
			var/obj/item/stack/material/S = attacking_item
			if(S.use(2))
				glass_type = attacking_item.type
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				user.visible_message(SPAN_NOTICE("[user] places the glass on the solar assembly."))
				if(tracker)
					new /obj/machinery/power/tracker(get_turf(src), src)
				else
					new /obj/machinery/power/solar(get_turf(src), src)
			else
				to_chat(user, SPAN_WARNING("You need two sheets of glass to put them into a solar panel."))
				return
			return 1

	if(!tracker)
		if(istype(attacking_item, /obj/item/tracker_electronics))
			tracker = 1
			user.drop_from_inventory(attacking_item, get_turf(src))
			qdel(attacking_item)
			user.visible_message(SPAN_NOTICE("[user] inserts the electronics into the solar assembly."))
			return 1
	else
		if(attacking_item.iscrowbar())
			new /obj/item/tracker_electronics(src.loc)
			tracker = 0
			user.visible_message(SPAN_NOTICE("[user] takes out the electronics from the solar assembly."))
			return 1
	..()

//
// Solar Control Computer
//

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/machinery/modular_console.dmi'
	icon_state = "computer"
	light_color = LIGHT_COLOR_YELLOW
	anchored = 1
	density = 1
	use_power = POWER_USE_IDLE
	idle_power_usage = 250
	var/id = 0
	var/cdir = 0
	var/targetdir = 0		// target angle in manual tracking (since it updates every game minute)
	var/gen = 0
	var/lastgen = 0
	var/track = 0			// 0= off  1=timed  2=auto (tracker)
	var/trackrate = 600		// 300-900 seconds
	var/nexttime = 0		// time for a panel to rotate of 1° in manual tracking
	var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

/obj/machinery/power/solar_control/drain_power()
	return -1

/obj/machinery/power/solar_control/Destroy()
	for(var/obj/machinery/power/solar/M in connected_panels)
		M.unset_control()
	if(connected_tracker)
		connected_tracker.unset_control()
	return ..()

/obj/machinery/power/solar_control/disconnect_from_network()
	..()
	SSsun.solars -= src

/obj/machinery/power/solar_control/connect_to_network()
	var/to_return = ..()
	if(powernet) //if connected and not already in solar_list...
		SSsun.solars |= src //... add it
	return to_return

//search for unconnected panels and trackers in the computer powernet and connect them
/obj/machinery/power/solar_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/M in powernet.nodes)
			if(istype(M, /obj/machinery/power/solar))
				var/obj/machinery/power/solar/S = M
				if(!S.control) //i.e unconnected
					S.set_control(src)
					connected_panels |= S
			else if(istype(M, /obj/machinery/power/tracker))
				if(!connected_tracker) //if there's already a tracker connected to the computer don't add another
					var/obj/machinery/power/tracker/T = M
					if(!T.control) //i.e unconnected
						connected_tracker = T
						T.set_control(src)

//called by the sun controller, update the facing angle (either manually or via tracking) and rotates the panels accordingly
/obj/machinery/power/solar_control/proc/update()
	if(stat & (NOPOWER | BROKEN))
		return

	switch(track)
		if(1)
			if(trackrate) //we're manual tracking. If we set a rotation speed...
				cdir = targetdir //...the current direction is the targetted one (and rotates panels to it)
		if(2) // auto-tracking
			if(connected_tracker)
				connected_tracker.modify_angle(SSsun.angle)

	set_panels(cdir)
	updateDialog()


/obj/machinery/power/solar_control/Initialize()
	. = ..()
	if(!connect_to_network()) return
	set_panels(cdir)

/obj/machinery/power/solar_control/attack_hand(mob/user)
	if(!..())
		interact(user)

/obj/machinery/power/solar_control/interact(mob/user)

	var/t = "<B><span class='highlight'>Generated power</span></B> : [round(lastgen)] W<BR>"
	t += "<B><span class='highlight'>Star Orientation</span></B>: [SSsun.angle]&deg ([angle2text(SSsun.angle)])<BR>"
	t += "<B><span class='highlight'>Array Orientation</span></B>: [rate_control(src,"cdir","[cdir]&deg",1,15)] ([angle2text(cdir)])<BR>"
	t += "<B><span class='highlight'>Tracking:</span></B><div class='statusDisplay'>"
	switch(track)
		if(0)
			t += "<span class='linkOn'>Off</span> <A href='byond://?src=[REF(src)];track=1'>Timed</A> <A href='byond://?src=[REF(src)];track=2'>Auto</A><BR>"
		if(1)
			t += "<A href='byond://?src=[REF(src)];track=0'>Off</A> <span class='linkOn'>Timed</span> <A href='byond://?src=[REF(src)];track=2'>Auto</A><BR>"
		if(2)
			t += "<A href='byond://?src=[REF(src)];track=0'>Off</A> <A href='byond://?src=[REF(src)];track=1'>Timed</A> <span class='linkOn'>Auto</span><BR>"

	t += "Tracking Rate: [rate_control(src,"tdir","[trackrate] deg/h ([trackrate<0 ? "CCW" : "CW"])",1,30,180)]</div><BR>"

	t += "<B><span class='highlight'>Connected devices:</span></B><div class='statusDisplay'>"

	t += "<A href='byond://?src=[REF(src)];search_connected=1'>Search for devices</A><BR>"
	t += "Solar panels : [connected_panels.len] connected<BR>"
	t += "Solar tracker : [connected_tracker ? SPAN_GOOD("Found") : SPAN_BAD("Not found")]</div><BR>"

	t += "<A href='byond://?src=[REF(src)];close=1'>Close</A>"

	var/datum/browser/popup = new(user, "solar", name)
	popup.set_content(t)
	popup.open()

	return

/obj/machinery/power/solar_control/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.isscrewdriver())
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 2 SECONDS, src, DO_REPAIR_CONSTRUCT))
			if (src.stat & BROKEN)
				to_chat(user, SPAN_NOTICE("The broken glass falls out."))
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				new /obj/item/material/shard( src.loc )
				var/obj/item/circuitboard/solar_control/M = new /obj/item/circuitboard/solar_control( A )
				for (var/obj/C in src)
					C.forceMove(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				to_chat(user, SPAN_NOTICE("You disconnect the monitor."))
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/circuitboard/solar_control/M = new /obj/item/circuitboard/solar_control( A )
				for (var/obj/C in src)
					C.forceMove(src.loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/power/solar_control/process()
	lastgen = gen
	gen = 0

	if(stat & (NOPOWER | BROKEN))
		return

	if(connected_tracker) //NOTE : handled here so that we don't add trackers to the processing list
		if(connected_tracker.powernet != powernet)
			connected_tracker.unset_control()

	if(track==1 && trackrate) //manual tracking and set a rotation speed
		if(nexttime <= world.time) //every time we need to increase/decrease the angle by 1°...
			targetdir = (targetdir + trackrate/abs(trackrate) + 360) % 360 	//... do it
			nexttime += 36000/abs(trackrate) //reset the counter for the next 1°

	updateDialog()

/obj/machinery/power/solar_control/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=solcon")
		usr.unset_machine()
		return 0
	if(href_list["close"] )
		usr << browse(null, "window=solcon")
		usr.unset_machine()
		return 0

	if(href_list["rate control"])
		if(href_list["cdir"])
			src.cdir = dd_range(0,359,(360+src.cdir+text2num(href_list["cdir"]))%360)
			src.targetdir = src.cdir
			if(track == 2) //manual update, so losing auto-tracking
				track = 0
			spawn(1)
				set_panels(cdir)
		if(href_list["tdir"])
			src.trackrate = dd_range(-7200,7200,src.trackrate+text2num(href_list["tdir"]))
			if(src.trackrate) nexttime = world.time + 36000/abs(trackrate)

	if(href_list["track"])
		track = text2num(href_list["track"])
		if(track == 2)
			if(connected_tracker)
				connected_tracker.modify_angle(SSsun.angle)
				set_panels(cdir)
		else if (track == 1) //begin manual tracking
			src.targetdir = src.cdir
			if(src.trackrate) nexttime = world.time + 36000/abs(trackrate)
			set_panels(targetdir)

	if(href_list["search_connected"])
		src.search_for_connected()
		if(connected_tracker && track == 2)
			connected_tracker.modify_angle(SSsun.angle)
		src.set_panels(cdir)

	interact(usr)
	return 1

//rotates the panel to the passed angle
/obj/machinery/power/solar_control/proc/set_panels(var/cdir)

	for(var/obj/machinery/power/solar/S in connected_panels)
		S.adir = cdir //instantly rotates the panel
		S.occlusion()//and
		S.update_icon() //update it

	update_icon()


/obj/machinery/power/solar_control/power_change()
	..()
	update_icon()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(2, 1.3, light_color)


/obj/machinery/power/solar_control/proc/broken()
	stat |= BROKEN
	update_icon()


/obj/machinery/power/solar_control/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				broken()
		if(3.0)
			if (prob(25))
				broken()
	return

// Used for mapping in solar array which automatically starts itself (telecomms, for example)
/obj/machinery/power/solar_control/autostart
	track = 2 // Auto tracking mode

/obj/machinery/power/solar_control/autostart/Initialize()
	. = ..()
	power_change()
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(do_solars)), 1800)

/obj/machinery/power/solar_control/autostart/proc/do_solars()
	search_for_connected()
	if(connected_tracker && track == 2)
		connected_tracker.modify_angle(SSsun.angle)
	set_panels(cdir)

/obj/machinery/power/solar_control/update_icon()
	ClearOverlays()
	if(stat & NOPOWER)
		set_light(0)
		return
	else
		set_light(2, 1.3, light_color)

	icon_state = initial(icon_state)

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		var/mutable_appearance/image_overlay = overlay_image(src.icon, "broken")
		AddOverlays(image_overlay)
		AddOverlays("red_key")
	else
		var/mutable_appearance/image_overlay = overlay_image(src.icon, "solar")
		AddOverlays(image_overlay)
		AddOverlays("yellow_key")

//
// MISC
//

/obj/item/paper/solar
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	info = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuel or phoron! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, reinforced or regular glass will do, will finish the construction of your solar panel. It is that easy!</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"

/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null) //How not to name vars
	var/href = "<A href='byond://?src=[REF(S)];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate
