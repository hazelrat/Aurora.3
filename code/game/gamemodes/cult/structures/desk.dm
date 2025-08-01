/obj/structure/cult/tome
	name = "arcanaeum desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"

/obj/structure/cult/tome/antagonist_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "A desk covered with the scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Most of them are beyond your current comprehension."
	. += "If you are a cultist, you could left-click on this desk with any non-unique book to turn it into a tome"

/obj/structure/cult/tome/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/book) && iscultist(user))
		var/obj/item/book/B = attacking_item
		if(!B.unique)
			var/cult_item = B.cultify()
			user.put_in_hands(cult_item)
			to_chat(user, SPAN_CULT("You pass the book over the desk. The contents within fade away and get replaced by the writings of Nar'Sie."))
		return TRUE
