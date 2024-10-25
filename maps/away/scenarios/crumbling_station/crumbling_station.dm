/datum/map_template/ruin/away_site/crumbling_station
	name = "Commercial Waypoint Installation"
	description = "A space station crumbling to disrepair."
	prefix = "scenarios/crumbling_station/"
	suffix = "crumbling_station.dmm"
	sectors = list(ALL_POSSIBLE_SECTORS)
	spawn_weight = 1
	spawn_cost = 1
	id = "crumbling_station"
	unit_test_groups = list(3)

/singleton/submap_archetype/cryo_outpost
	map = "Commercial Waypoint Installation"
	descriptor = "A space station crumbling to disrepair."

/obj/effect/overmap/visitable/sector/crumbling_station
	name = "Commercial Installation #3-29ND"
	desc = "A space station crumbling to disrepair."
	icon = 'icons/obj/overmap/overmap_stationary.dmi'
	icon_state = "outpost"
	color = "#34423a"
