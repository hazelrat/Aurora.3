// used to debug malf AI apc's. Maybe in the future it can be used for computers.
/obj/item/device/debugger
	name = "debugger"
	desc = "Used to debug electronic equipment."
	desc_extended = "This device can be used on a vending machine to stop it from throwing items, on the exposed positronic of an IPC to return it to normalcy after being subverted, and on a similarly subverted APC to return it to normal functionality."
	icon = 'icons/obj/hacktool.dmi'
	icon_state = "hacktool-g"
	obj_flags = OBJ_FLAG_CONDUCTABLE
	force = 11
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_range = 15
	throw_speed = 3

	matter = list(MATERIAL_PLASTIC = 50, DEFAULT_WALL_MATERIAL = 50, MATERIAL_GLASS = 20)
	origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)
