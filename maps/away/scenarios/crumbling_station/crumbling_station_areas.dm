/area/crumbling_station
	name = "Commercial Waypoint"
	requires_power = TRUE
	dynamic_lighting = TRUE
	no_light_control = FALSE
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_INDESTRUCTIBLE_TURFS //| AREA_FLAG_IS_BACKGROUND (must check what this does)
	holomap_color = "#2c301f"
	area_blurb = "The air reeks of damp stagnancy and something faintly like a distant rot. The noises of small mechanical faults emanate from every direction - the hissing of pressurised air most of them all - and scuttering can be heard in the walls. This place is old, and the years have not been kind to it."

// For the asteroid bits.
/area/crumbling_station/asteroid
	name = "Asteroid Interior"
	icon_state = "exterior"
	requires_power = FALSE
	holomap_color = "#1c1c1c"

// Docking.
/area/crumbling_station/docking
	icon_state = "dk_yellow"

/area/crumbling_station/docking/docking_ports
	name = "Docking Ports"

/area/crumbling_station/docking/checkpoint
	name = "Security Checkpoint"

/area/crumbling_station/docking/docking_approach
	name = "Docking Foyer"

// Service.
/area/crumbling_station/service
	icon_state = "green"

/area/crumbling_station/service/dining
	name = "Mess Hall"

/area/crumbling_station/service/kitchen
	name = "Kitchen"

/area/crumbling_station/service/smoking
	name = "Service Smoking Room"

/area/crumbling_station/service/freezer
	name = "Freezer"

/area/crumbling_station/service/custodial
	name = "Custodial Closet"

/area/crumbling_station/service/washroom
	name = "Crewman's Washroom"

/area/crumbling_station/service/hydro
	name = "Hydroponics Bay"

/area/crumbling_station/service/hydro_secure
	name = "Secure Specimens"

/area/crumbling_station/service/shop
	name = "Station Commissary"

// Public areas and crew quarters.
/area/crumbling_station/civilian
	icon_state = "yellow"

/area/crumbling_station/civilian/hallway_central
	name = "Primary Central Hallway"

/area/crumbling_station/civilian/hallway_east
	name = "Habitation Block Hallway"

/area/crumbling_station/civilian/hallway_west
	name = "Critical Services Hallway"

/area/crumbling_station/civilian/quarters_1
	name = "Private Habitation Unit #1"

/area/crumbling_station/civilian/quarters_2
	name = "Private Habitation Unit #2"

/area/crumbling_station/civilian/quarters_3
	name = "Private Habitation Unit #3"

/area/crumbling_station/civilian/quarters_4
	name = "Private Habitation Unit #4"

/area/crumbling_station/civilian/quarters_5
	name = "Private Habitation Unit #5"

/area/crumbling_station/civilian/quarters_6
	name = "Private Habitation Unit #6"

/area/crumbling_station/civilian/quarters_7
	name = "Private Habitation Unit #7"

