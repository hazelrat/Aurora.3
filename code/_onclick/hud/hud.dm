/*
	The global hud:
	Uses the same visual objects for all players.
*/
GLOBAL_DATUM_INIT(global_hud, /datum/global_hud, new)
GLOBAL_LIST(global_huds)

/datum/hud/var/atom/movable/screen/grab_intent
/datum/hud/var/atom/movable/screen/hurt_intent
/datum/hud/var/atom/movable/screen/disarm_intent
/datum/hud/var/atom/movable/screen/help_intent

/datum/global_hud
	var/atom/movable/screen/vr_control
	var/atom/movable/screen/druggy
	var/atom/movable/screen/blurry
	var/list/vimpaired
	var/list/darkMask
	var/atom/movable/screen/nvg
	var/atom/movable/screen/thermal
	var/atom/movable/screen/meson
	var/atom/movable/screen/science

/datum/global_hud/proc/setup_overlay(var/icon_state, var/color)
	var/atom/movable/screen/screen = new /atom/movable/screen()
	screen.alpha = 25 // Adjust this if you want goggle overlays to be thinner or thicker.
	screen.screen_loc = "SOUTHWEST to NORTHEAST" // Will tile up to the whole screen, scaling beyond 15x15 if needed.
	screen.icon = 'icons/obj/hud_tiled.dmi'
	screen.icon_state = icon_state
	screen.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen.color = color

	return screen

/datum/global_hud/New()
	//420erryday psychedellic colours screen overlay for when you are high
	druggy = new /atom/movable/screen()
	druggy.screen_loc = ui_entire_screen
	druggy.icon_state = "druggy"
	druggy.layer = IMPAIRED_LAYER
	druggy.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	druggy.alpha = 127
	druggy.blend_mode = BLEND_MULTIPLY

	//that white blurry effect you get when you eyes are damaged
	blurry = new /atom/movable/screen()
	blurry.screen_loc = ui_entire_screen
	blurry.icon_state = "blurry"
	blurry.layer = IMPAIRED_LAYER
	blurry.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blurry.alpha = 100

	vr_control = new /atom/movable/screen()
	vr_control.icon = 'icons/mob/screen/full.dmi'
	vr_control.icon_state = "vr_control"
	vr_control.screen_loc = "1,1"
	vr_control.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vr_control.alpha = 120

	nvg = setup_overlay("scanline", "#06ff00")
	thermal = setup_overlay("scanline", "#ff0000")
	meson = setup_overlay("scanline", "#9fd800")
	science = setup_overlay("scanline", "#d600d6")

	var/atom/movable/screen/O
	var/i
	//that nasty looking dither you  get when you're short-sighted
	vimpaired = newlist(/atom/movable/screen,/atom/movable/screen,/atom/movable/screen,/atom/movable/screen)
	O = vimpaired[1]
	O.screen_loc = "1,1 to 5,15"
	O = vimpaired[2]
	O.screen_loc = "5,1 to 10,5"
	O = vimpaired[3]
	O.screen_loc = "6,11 to 10,15"
	O = vimpaired[4]
	O.screen_loc = "11,1 to 15,15"

	//welding mask overlay black/dither
	darkMask = newlist(/atom/movable/screen, /atom/movable/screen, /atom/movable/screen, /atom/movable/screen, /atom/movable/screen, /atom/movable/screen, /atom/movable/screen, /atom/movable/screen)
	O = darkMask[1]
	O.screen_loc = "WEST+2,SOUTH+2 to WEST+4,NORTH-2"
	O = darkMask[2]
	O.screen_loc = "WEST+4,SOUTH+2 to EAST-5,SOUTH+4"
	O = darkMask[3]
	O.screen_loc = "WEST+5,NORTH-4 to EAST-5,NORTH-2"
	O = darkMask[4]
	O.screen_loc = "EAST-4,SOUTH+2 to EAST-2,NORTH-2"
	O = darkMask[5]
	O.screen_loc = "WEST,SOUTH to EAST,SOUTH+1"
	O = darkMask[6]
	O.screen_loc = "WEST,SOUTH+2 to WEST+1,NORTH"
	O = darkMask[7]
	O.screen_loc = "EAST-1,SOUTH+2 to EAST,NORTH"
	O = darkMask[8]
	O.screen_loc = "WEST+2,NORTH-1 to EAST-2,NORTH"

	for(i = 1, i <= 4, i++)
		O = vimpaired[i]
		O.icon_state = "dither50"
		O.layer = IMPAIRED_LAYER
		O.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

		O = darkMask[i]
		O.icon_state = "dither50"
		O.layer = IMPAIRED_LAYER
		O.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	for(i = 5, i <= 8, i++)
		O = darkMask[i]
		O.icon_state = "black"
		O.layer = IMPAIRED_LAYER
		O.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	///The mob that possesses the HUD
	var/mob/mymob

	///Boolean, if the HUD is shown, used for the HUD toggle (F12)
	var/hud_shown = TRUE

	///Boolean, if the inventory is shows
	var/inventory_shown = TRUE

	///Boolean, if the intent icons are shown
	var/show_intent_icons = FALSE

	///Boolean, this is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)
	var/hotkey_ui_hidden = FALSE

	///Boolean, if the action buttons are hidden
	var/action_buttons_hidden = FALSE

	var/atom/movable/screen/blobpwrdisplay
	var/atom/movable/screen/blobhealthdisplay
	var/atom/movable/screen/r_hand_hud_object
	var/atom/movable/screen/l_hand_hud_object
	var/atom/movable/screen/action_intent
	var/atom/movable/screen/movement_intent/move_intent

	var/list/adding
	var/list/other
	var/list/atom/movable/screen/hotkeybuttons

	var/atom/movable/screen/movable/action_button/hide_toggle/hide_actions_toggle

/datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	..()

/datum/hud/Destroy()
	grab_intent = null
	hurt_intent = null
	disarm_intent = null
	help_intent = null
	blobpwrdisplay = null
	blobhealthdisplay = null
	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null
	adding = null
	other = null
	hotkeybuttons = null
//	item_action_list = null // ?
	mymob = null

	. = ..()

/datum/hud/proc/hidden_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(inventory_shown && hud_shown)
				switch(hud_data["slot"])
					if(slot_head)
						if(H.head)
							H.head.screen_loc =	hud_data["loc"]
					if(slot_shoes)
						if(H.shoes)
							H.shoes.screen_loc = hud_data["loc"]
					if(slot_l_ear)
						if(H.l_ear)
							H.l_ear.screen_loc = hud_data["loc"]
					if(slot_r_ear)
						if(H.r_ear)
							H.r_ear.screen_loc = hud_data["loc"]
					if(slot_gloves)
						if(H.gloves)
							H.gloves.screen_loc = hud_data["loc"]
					if(slot_glasses)
						if(H.glasses)
							H.glasses.screen_loc = hud_data["loc"]
					if(slot_w_uniform)
						if(H.w_uniform)
							H.w_uniform.screen_loc = hud_data["loc"]
					if(slot_wear_suit)
						if(H.wear_suit)
							H.wear_suit.screen_loc = hud_data["loc"]
					if(slot_wear_mask)
						if(H.wear_mask)
							H.wear_mask.screen_loc = hud_data["loc"]
					if(slot_wrists)
						if(H.wrists)
							H.wrists.screen_loc = hud_data["loc"]
					if(slot_pants)
						if(H.pants)
							H.pants.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_head)
						if(H.head)
							H.head.screen_loc =	null
					if(slot_shoes)
						if(H.shoes)
							H.shoes.screen_loc = null
					if(slot_l_ear)
						if(H.l_ear)
							H.l_ear.screen_loc = null
					if(slot_r_ear)
						if(H.r_ear)
							H.r_ear.screen_loc = null
					if(slot_gloves)
						if(H.gloves)
							H.gloves.screen_loc = null
					if(slot_glasses)
						if(H.glasses)
							H.glasses.screen_loc = null
					if(slot_w_uniform)
						if(H.w_uniform)
							H.w_uniform.screen_loc = null
					if(slot_wear_suit)
						if(H.wear_suit)
							H.wear_suit.screen_loc = null
					if(slot_wear_mask)
						if(H.wear_mask)
							H.wear_mask.screen_loc = null
					if(slot_wrists)
						if(H.wrists)
							H.wrists.screen_loc = null
					if(slot_pants)
						if(H.pants)
							H.pants.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(hud_shown)
				switch(hud_data["slot"])
					if(slot_s_store)
						if(H.s_store)
							H.s_store.screen_loc = hud_data["loc"]
					if(slot_wear_id)
						if(H.wear_id)
							H.wear_id.screen_loc = hud_data["loc"]
					if(slot_belt)
						if(H.belt)
							H.belt.screen_loc = hud_data["loc"]
					if(slot_back)
						if(H.back)
							H.back.screen_loc = hud_data["loc"]
					if(slot_l_store)
						if(H.l_store)
							H.l_store.screen_loc = hud_data["loc"]
					if(slot_r_store)
						if(H.r_store)
							H.r_store.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_s_store)
						if(H.s_store)
							H.s_store.screen_loc = null
					if(slot_wear_id)
						if(H.wear_id)
							H.wear_id.screen_loc = null
					if(slot_belt)
						if(H.belt)
							H.belt.screen_loc =    null
					if(slot_back)
						if(H.back)
							H.back.screen_loc =    null
					if(slot_l_store)
						if(H.l_store)
							H.l_store.screen_loc = null
					if(slot_r_store)
						if(H.r_store)
							H.r_store.screen_loc = null


/**
 * Instantiate an HUD to the current mob that own is
 */
/datum/hud/proc/instantiate()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)

	if(!ismob(mymob))
		stack_trace("HUD instantiation called on an HUD without a mob!")
		return FALSE

	if(!(mymob.client))
		return FALSE

	var/ui_style = ui_style2icon(mymob.client.prefs.UI_style)
	var/ui_color = mymob.client.prefs.UI_style_color
	var/ui_alpha = mymob.client.prefs.UI_style_alpha

	mymob.instantiate_hud(src, ui_style, ui_color, ui_alpha)

/mob/proc/instantiate_hud(datum/hud/HUD, ui_style, ui_color, ui_alpha)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(FALSE)

	return

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12(var/full = 0 as null)
	set name = "F12"
	set hidden = 1

	if(!hud_used)
		to_chat(usr, SPAN_WARNING("This mob type does not use a HUD."))
		return

	if(!ishuman(src))
		to_chat(usr, SPAN_WARNING("Inventory hiding is currently only supported for human mobs."))
		return

	if(!client)
		return

	if(client.view != world.view)
		return

	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(src.hud_used.adding)
			src.client.screen -= src.hud_used.adding
		if(src.hud_used.other)
			src.client.screen -= src.hud_used.other
		if(src.hud_used.hotkeybuttons)
			src.client.screen -= src.hud_used.hotkeybuttons

		//Due to some poor coding some things need special treatment:
		//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
		if(!full)
			src.client.screen += src.hud_used.l_hand_hud_object	//we want the hands to be visible
			src.client.screen += src.hud_used.r_hand_hud_object	//we want the hands to be visible
			src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
			src.hud_used.action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.
		else
			src.client.screen -= src.healths
			src.client.screen -= src.internals
			src.client.screen -= src.gun_setting_icon

		//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
		src.client.screen -= src.zone_sel	//zone_sel is a mob variable for some reason.

	else
		hud_used.hud_shown = 1
		if(src.hud_used.adding)
			src.client.screen += src.hud_used.adding
		if(src.hud_used.other && src.hud_used.inventory_shown)
			src.client.screen += src.hud_used.other
		if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
			src.client.screen += src.hud_used.hotkeybuttons
		if(src.healths)
			src.client.screen |= src.healths
		if(src.internals)
			src.client.screen |= src.internals
		if(src.gun_setting_icon)
			src.client.screen |= src.gun_setting_icon

		src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
		src.client.screen += src.zone_sel				//This one is a special snowflake

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons()

//Similar to button_pressed_F12() but keeps zone_sel, gun_setting_icon, and healths.
/mob/proc/toggle_zoom_hud()
	if(!hud_used)
		return
	if(!ishuman(src))
		return
	if(!client)
		return
	if(client.view != world.view)
		return

	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(src.hud_used.adding)
			src.client.screen -= src.hud_used.adding
		if(src.hud_used.other)
			src.client.screen -= src.hud_used.other
		if(src.hud_used.hotkeybuttons)
			src.client.screen -= src.hud_used.hotkeybuttons
		src.client.screen -= src.internals
		src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
	else
		hud_used.hud_shown = 1
		if(src.hud_used.adding)
			src.client.screen += src.hud_used.adding
		if(src.hud_used.other && src.hud_used.inventory_shown)
			src.client.screen += src.hud_used.other
		if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
			src.client.screen += src.hud_used.hotkeybuttons
		if(src.internals)
			src.client.screen |= src.internals
		src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons()

/mob/proc/add_click_catcher()
	client.screen |= GLOB.click_catchers

/mob/abstract/new_player/add_click_catcher()
	return
