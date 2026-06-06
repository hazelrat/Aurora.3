/**
* Sends out spooky messages to all IPCs on the same z-level.
*/
/mob/living/simple_animal/hostile/hivebotbeacon/proc/send_hivebot_messages()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(isipc(H) && (AreConnectedZLevels(H.z, src.z)))
			// Only a 20% chance this goes through.
			if(prob(80))
				continue

			var/obj/item/organ/internal/machine/posibrain/posibrain = H.internal_organs_by_name[BP_BRAIN]

			// If the firewall of the positronic is active, they get the blocked messages.
			if(posibrain.firewall)
				var/chosen_index = rand(1, length(firewall_messages))
				var/chosen_message = firewall_messages[chosen_index]
				firewall_messages -= firewall_messages[chosen_index]
				to_chat(H, SPAN_MACHINE_DANGER(chosen_message))

			// Otherwise, they get the unremitting hivebot stream of conscioussness.
			else
				var/chosen_index = rand(1, length(direct_messages))
				var/chosen_message = direct_messages[chosen_index]
				firewall_messages -= direct_messages[chosen_index]
				to_chat(H, SPAN_MACHINE_VISION(chosen_message))
