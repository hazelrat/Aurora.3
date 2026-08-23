/obj/effect/overmap/visitable/ship/landable/ecclesiastical
	name = "Ecclesiastical Shuttle"
	class = "EAV"
	desc = "MUST FILL IN"
	shuttle = "EAV Shuttle"
	icon_state = "shuttle"
	moving_state = "shuttle_moving"
	designer = "Lodge of Temple Architect, Ecclesiastical Authority of Axiom"
	sizeclass = "Pitswine-class passenger craft"
	shiptype = "Short-distance passenger transportation"
	colors = list("#aaafd4", "#78adf8")
	max_speed = 1/(3 SECONDS)
	burn_delay = 2 SECONDS
	vessel_mass = 3000
	fore_dir = NORTH
	vessel_size = SHIP_SIZE_TINY

/obj/effect/overmap/visitable/ship/landable/ecclesiastical/New()
	designation = "[pick("")]"
	..()

/obj/structure/machinery/computer/shuttle_control/explore/terminal/ecclesiastical
	name = "shuttle control console"
	shuttle_tag = "EAV Shuttle"
	req_access = list(ACCESS_ECCLESIASTICAL)
// --------

// Controls docking behaviour
/datum/shuttle/autodock/overmap/ecclesiastical
	name = "EAV Shuttle"
	move_time = 20
	shuttle_area = list(/area/shuttle/ecclesiastical)
	current_location = "nav_hangar_eav"
	landmark_transition = "nav_transit_eav_shuttle"
	dock_target = "eav_shuttle"
	range = 1
	fuel_consumption = 2
	logging_home_tag = "nav_hangar_eav"
	defer_initialisation = TRUE
// --------

// Hangar marker
/obj/effect/shuttle_landmark/ecclesiastical/hangar
	name = "Shuttle Port"
	landmark_tag = "nav_hangar_eav"
	docking_controller = "eav_shuttle_dock"
	base_area = /area/ecclesiastical_corvette/exterior
	base_turf = /turf/space
	movable_flags = MOVABLE_FLAG_EFFECTMOVE
// --------

// Transit landmark
/obj/effect/shuttle_landmark/ecclesiastical/transit
	name = "In transit"
	landmark_tag = "nav_transit_eav_shuttle"
	base_turf = /turf/space/transit/north
// --------

// Shuttle docking port
/obj/effect/map_effect/marker/airlock/docking/ecclesiastical/shuttle_port
	name = "Shuttle Dock"
	landmark_tag = "nav_hangar_eav"
	master_tag = "eav_shuttle_dock"
// --------

// Shuttle airlock
/obj/effect/map_effect/marker/airlock/shuttle/ecclesiastical
	name = "eav_shuttle"
	master_tag = "eav_shuttle"
	shuttle_tag = "EAV Shuttle"
	cycle_to_external_air = TRUE
// --------
