/mob/living/simple_animal/hostile/hivebot/playable
	name = "Hivebot destroyer"
	desc = "A primitive-yet-sturdy hovering robot, with some menacing looking blades jutting out from it. This one seems unusually aware of its surroundings."
	icon_state = "hivebotdestroyer"
	health = 350
	maxhealth = 350
	melee_damage_lower = 20
	melee_damage_upper = 30
	armor_penetration = 20
	attacktext = "eviscerates"
	projectiletype = null
	var/playable = TRUE
	speed = -2

/mob/living/simple_animal/hostile/hivebot/playable/Initialize(mapload)
	. = ..()
	add_language(LANGUAGE_HIVEBOT)
	var/number = rand(1000,9999)
	name = initial(name) + " ([number])"
	real_name = name
	if(playable && !ckey && !client)
		SSghostroles.add_spawn_atom("hivebotdestroyer", src)

/mob/living/simple_animal/hostile/hivebot/playable/Destroy()
	SSghostroles.remove_spawn_atom("hivebotdestroyer", src)
	return ..()

/mob/living/simple_animal/hostile/hivebot/playable/ranged
	name = "Hivebot marksman"
	desc = "A primitive-yet-sturdy hovering robot, with some menacing looking blades jutting out from it. This one seems to be carefully surveying all activity."
	icon_state = "hivebotmarksman"
	health = 250
	maxhealth = 250
	melee_damage_lower = 10
	melee_damage_upper = 20
	armor_penetration = 20
	attacktext = "stabs"
	ranged = 1
	projectiletype = /obj/projectile/bullet/pistol/medium
	speed = -3

/mob/living/simple_animal/hostile/hivebot/playable/ranged/Initialize(mapload)
	. = ..()
	add_language(LANGUAGE_HIVEBOT)
	var/number = rand(1000,9999)
	name = initial(name) + " ([number])"
	real_name = name
	if(playable && !ckey && !client)
		SSghostroles.add_spawn_atom("hivebotmarksman", src)

/mob/living/simple_animal/hostile/hivebot/playable/ranged/Destroy()
	SSghostroles.remove_spawn_atom("hivebotmarksman", src)
	return ..()

/mob/living/simple_animal/hostile/hivebot/playable/overseer
	name = "Hivebot overseer"
	desc = "A primitive-yet-sturdy hovering robot, with some menacing looking blades jutting out from it. This one seems to be buzzing with unseen activity from within."
	icon_state = "hivebotoverseer"
	health = 300
	maxhealth = 300
	melee_damage_lower = 10
	melee_damage_upper = 10
	armor_penetration = 10
	attacktext = "slashes"
	ranged = -1
	projectiletype = /obj/projectile/bullet/pistol/

/mob/living/simple_animal/hostile/hivebot/playable/overseer/Initialize(mapload)
	. = ..()
	add_language(LANGUAGE_HIVEBOT)
	var/number = rand(1000,9999)
	name = initial(name) + " ([number])"
	real_name = name
	if(playable && !ckey && !client)
		SSghostroles.add_spawn_atom("hivebotoverseer", src)

/mob/living/simple_animal/hostile/hivebot/playable/overseer/Destroy()
	SSghostroles.remove_spawn_atom("hivebotoverseer", src)
	return ..()

/mob/living/simple_animal/hostile/hivebot/playable/overseer/verb/build_bot()
	set name = "Assemble hivebot"
	set desc = "Assemble a hivebot."
	set category = "Hivebot"

	src.visible_message("\The [src] begins to construct a hivebot.", "You begin to construct a hivebot.", "You hear the sounds of fabrication...")
	if(!do_after(src, 12 SECONDS))
		return
	src.visible_message("\The [src] constructs a hivebot!", "You construct a hivebot!")
	new /mob/living/simple_animal/hostile/hivebot(get_turf(src))
