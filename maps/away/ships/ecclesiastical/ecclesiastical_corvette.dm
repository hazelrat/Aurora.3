/datum/map_template/ruin/away_site/tcaf_corvette
	name = "Republic Astroforce Patrol Vessel"
	description = "A patrol vessel of the Republic of Biesel's Republic Astroforce."

	prefix = "ships/ecclesiastical"
	suffix = "ecclesiastical_corvette.dmm"

	// Tentatively very limited, must check with other lore teams for any increased scope.
	sectors = list(SECTOR_ARUSHA)
	spawn_weight = 1

	ship_cost = 1
	id = "ecclesiastical_corvette"
	// shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/tcaf_shuttle, /datum/shuttle/autodock/multi/lift/tcaf)

	unit_test_groups = list(3)

/obj/structure/machinery/computer/terminal/loreconsole/ecclesiastical_motivation
	name = "liturgical console"
	entries = list(
		new/datum/lore_console_entry(
			"\[RE: Receiving dock malfunction\]", {"
	<hr>
	Automated systems no longer works reliably, as the recent incident pointed out.
	<br><br>
	Until further notice excercise extreme causion whenever the shipment arrives. For now you'll have to manually cycle air in and out
	through the air alarm console. Make SURE to not cause a decompression once the shipment undocks.
	Management doesn't want to hear such re-occurrances.
	<br><br>
	This is now a two person job, one remains inside the operator room to open the gates, other will be outside to drain the air.
	"})
	)
