/datum/map_template/ruin/away_site/ecclesiastical_corvette
	name = "Ecclesiastical Corvette"
	description = "A patrol vessel of the Ecclesiastical Authority of Axiom."

	prefix = "ships/ecclesiastical/"
	suffix = "ecclesiastical_corvette.dmm"

	// Tentatively very limited, must check with other lore teams for any increased scope.
	sectors = list(ALL_POSSIBLE_SECTORS)
	template_flags = TEMPLATE_FLAG_SPAWN_GUARANTEED
	spawn_weight = 1

	ship_cost = 1
	id = "ecclesiastical_corvette"
	// shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/tcaf_shuttle, /datum/shuttle/autodock/multi/lift/tcaf)

	unit_test_groups = list(3)

/obj/effect/overmap/visitable/ship/ecclesiastical_corvette
	name = "Ecclesiastical Corvette"
	class = "EAV" // Ecclesiastical Authority Vessel
	desc = "The Corkfell-class Corvette - categorised internally as a Light Frigate - is the sole \
		vessel constructed wholly in the shipyards of Axiom by the Lodge of Temple Architect. \
		Unlike the Providence-class, which usually lacks warp or bluespace drives, the Corkfell-class \
		posseses a powerful warp drive resourced by Axiom's abundant Helium-3 reserves; it is usually \
		dispatched to dispose of some threat to the church, or in collection of a relic sacred to the \
		Trinary Perfection."
	icon_state = "himeo_patrol"
	moving_state = "himeo_patrol_moving"
	colors = list("#c83232", "#ce4d4d")
	max_speed = 1/(2 SECONDS)
	burn_delay = 1 SECONDS
	vessel_mass = 5000
	fore_dir = SOUTH
	vessel_size = SHIP_SIZE_SMALL
	designer = "Lodge of Temple Architect, Ecclesiastical Authority of Axiom"
	volume = "62 meters length, 29 meters beam/width, 12 meters vertical height"
	drive = "Moderately Powerful Warp Drive"
	weapons = "Dual ballistic gunnery pods."
	sizeclass = "Corkfell-class corvette"
	shiptype = "Military reconnaissance and retrieval of sacred relics"
	initial_restricted_waypoints = list(
		"TCAF Gunship" = list("nav_hangar_tcaf")
	)

	initial_generic_waypoints = list(
		"tcaf_corvette_nav1",
		"tcaf_corvette_nav2",
		"tcaf_corvette_nav3",
		"tcaf_corvette_nav4",
		"tcaf_corvette_starboard_dock",
		"tcaf_corvette_port_dock",
		"tcaf_corvette_aft_dock",
		"tcaf_corvette_fore_dock"
	)

	invisible_until_ghostrole_spawn = TRUE

/obj/effect/overmap/visitable/ship/ecclesiastical_corvette/New()
	designation = "[pick("Will of Flock", "Clarifying Ascension", "Our Lady Corkfell", "Saintsvessel",
	"Against the Evil Night", "Ecclesiarch's Hand", "Shadow of the Apotheosis", "Truthful Oration",
	"Pursuit of Paradise", "Flare of Eternity", "Forward Forever", "Holy Sacrament", "Far From Home",
	"War Continues On", "Singular Conviction", "Eye of Axiom")]"
	..()

/obj/structure/machinery/computer/terminal/loreconsole/ecclesiastical_motivation
	name = "liturgical console"
	looping_sound = FALSE
	entries = list(
		new/datum/lore_console_entry(
			"\[RE: Receiving dock malfunction\]", {"Religion!"})
	)
