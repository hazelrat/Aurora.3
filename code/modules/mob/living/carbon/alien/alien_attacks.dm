//There has to be a better way to define this shit. ~ Z
//can't equip anything
/mob/living/carbon/alien/attack_ui(slot_id)
	return

/mob/living/carbon/alien/attack_hand(mob/living/carbon/M as mob)

	..()

	switch(M.a_intent)

		if (I_HELP)
			help_shake_act(M)

		if (I_GRAB)
			if (M == src)
				return
			var/obj/item/grab/G = new /obj/item/grab(M, M, src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.affecting = src
			G.synch()

			LAssailant = WEAKREF(M)

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(SPAN_WARNING("[M] has grabbed [src] passively!"), 1)

		else
			var/damage = rand(1, 9)
			if (prob(90))
				if ((M.mutations & HULK))
					damage += 5
					spawn(0)
						Paralyse(1)
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(loc, /singleton/sound_category/punch_sound, 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(SPAN_DANGER("[M] has punched [src]!"), 1)
				if (damage > 4.9)
					Weaken(rand(10,15))
					for(var/mob/O in viewers(M, null))
						if ((O.client && !( O.blinded )))
							O.show_message(SPAN_DANGER("[M] has weakened [src]!"), 1,
											SPAN_WARNING(" You hear someone fall."), 2)

				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, /singleton/sound_category/punchmiss_sound, 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(SPAN_DANGER("[M] has attempted to punch [src]!"), 1)
	return
