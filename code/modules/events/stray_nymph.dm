/datum/event/stray_nymph
	no_fake = 1
	var/datum/ghostspawner/simplemob/nymph/spawner

/datum/event/stray_nymph/setup()
	spawner = SSghostroles.get_spawner("nymph")

/datum/event/stray_nymph/start()
	..()

	if(istype(spawner))
		spawner.enable()
