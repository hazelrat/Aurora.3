/datum/map_template/ruin/away_site/crumbling_station
	name = "Commercial Waypoint Installation"
	description = "A space station crumbling to disrepair."
	prefix = "scenarios/cryo_outpost/"
	suffix = "cryo_outpost.dmm"
	sectors = list(ALL_POSSIBLE_SECTORS)
	spawn_weight = 1
	spawn_cost = 1
	id = "cryo_outpost"
	unit_test_groups = list(3)

/singleton/submap_archetype/cryo_outpost
	map = "Commercial Waypoint Installation"
	descriptor = "A space station crumbling to disrepair."
