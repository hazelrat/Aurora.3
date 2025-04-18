/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/mineral/input
	var/obj/machinery/mineral/output
	var/amt_silver = 0 //amount of silver
	var/amt_gold = 0   //amount of gold
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_phoron = 0
	var/amt_uranium = 0
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0
	var/chosen = DEFAULT_WALL_MATERIAL //which material will be used to make coins
	var/coinsToProduce = 10

/obj/machinery/mineral/mint/Initialize()
	. = ..()
	for(var/dir in GLOB.cardinals)
		src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
		if(src.input)
			break
	for(var/dir in GLOB.cardinals)
		src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(src.output)
			break
	START_PROCESSING(SSprocessing, src)

/obj/machinery/mineral/mint/process()
	if(input)
		var/obj/item/stack/O
		O = locate(/obj/item/stack, get_turf(input))
		if(O)
			var/processed = TRUE
			switch(O.get_material_name())
				if("gold")
					amt_gold += 100 * O.get_amount()
				if("silver")
					amt_silver += 100 * O.get_amount()
				if("diamond")
					amt_diamond += 100 * O.get_amount()
				if("phoron")
					amt_phoron += 100 * O.get_amount()
				if("uranium")
					amt_uranium += 100 * O.get_amount()
				if(DEFAULT_WALL_MATERIAL)
					amt_iron += 100 * O.get_amount()
				else
					processed = FALSE
			if(processed)
				qdel(O)

/obj/machinery/mineral/mint/attack_hand(user)
	var/dat = "<b>Coin Press</b><br>"

	if(!input)
		dat += "input connection status: "
		dat += "<b><span class='warning'>NOT CONNECTED</span></b><br>"
	if(!output)
		dat += "<br>output connection status: "
		dat += "<b><span class='warning'>NOT CONNECTED</span></b><br>"

	dat += "<br><font color='#ffcc00'><b>Gold inserted: </b>[amt_gold]</font> "
	if(chosen == "gold")
		dat += "chosen"
	else
		dat += "<A href='byond://?src=[REF(src)];choose=gold'>Choose</A>"
	dat += "<br><font color='#888888'><b>Silver inserted: </b>[amt_silver]</font> "
	if(chosen == "silver")
		dat += "chosen"
	else
		dat += "<A href='byond://?src=[REF(src)];choose=silver'>Choose</A>"
	dat += "<br><font color='#555555'><b>Iron inserted: </b>[amt_iron]</font> "
	if(chosen == DEFAULT_WALL_MATERIAL)
		dat += "chosen"
	else
		dat += "<A href='byond://?src=[REF(src)];choose=metal'>Choose</A>"
	dat += "<br><font color='#8888FF'><b>Diamond inserted: </b>[amt_diamond]</font> "
	if(chosen == "diamond")
		dat += "chosen"
	else
		dat += "<A href='byond://?src=[REF(src)];choose=diamond'>Choose</A>"
	dat += "<br><font color='#FF8800'><b>Phoron inserted: </b>[amt_phoron]</font> "
	if(chosen == "phoron")
		dat += "chosen"
	else
		dat += "<A href='byond://?src=[REF(src)];choose=phoron'>Choose</A>"
	dat += "<br><font color='#008800'><b>Uranium inserted: </b>[amt_uranium]</font> "
	if(chosen == "uranium")
		dat += "chosen"
	else
		dat += "<A href='byond://?src=[REF(src)];choose=uranium'>Choose</A>"

	dat += "<br><br>Will produce [coinsToProduce] [chosen] coins if enough materials are available.<br>"
	dat += "<A href='byond://?src=[REF(src)];chooseAmt=-10'>-10</A> "
	dat += "<A href='byond://?src=[REF(src)];chooseAmt=-5'>-5</A> "
	dat += "<A href='byond://?src=[REF(src)];chooseAmt=-1'>-1</A> "
	dat += "<A href='byond://?src=[REF(src)];chooseAmt=1'>+1</A> "
	dat += "<A href='byond://?src=[REF(src)];chooseAmt=5'>+5</A> "
	dat += "<A href='byond://?src=[REF(src)];chooseAmt=10'>+10</A> "

	dat += "<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins."
	dat += "<br><A href='byond://?src=[REF(src)];makeCoins=[1]'>Make coins</A>"
	user << browse(HTML_SKELETON(dat), "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return TRUE
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(processing)
		to_chat(usr, SPAN_WARNING("The machine is busy processing."))
		return
	if(href_list["choose"])
		chosen = href_list["choose"]
	if(href_list["chooseAmt"])
		coinsToProduce = between(0, coinsToProduce + text2num(href_list["chooseAmt"]), 1000)
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		if(output)
			processing = TRUE
			icon_state = "coinpress1"
			var/obj/item/storage/bag/money/M
			switch(chosen)
				if(DEFAULT_WALL_MATERIAL)
					while(amt_iron && coinsToProduce)
						if(locate(/obj/item/storage/bag/money, get_turf(output)))
							M = locate(/obj/item/storage/bag/money, get_turf(output))
						else
							M = new/obj/item/storage/bag/money(get_turf(output))
						new /obj/item/coin/iron(M)
						amt_iron -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("gold")
					while(amt_gold && coinsToProduce)
						if(locate(/obj/item/storage/bag/money, get_turf(output)))
							M = locate(/obj/item/storage/bag/money, get_turf(output))
						else
							M = new/obj/item/storage/bag/money(get_turf(output))
						new /obj/item/coin/gold(M)
						amt_gold -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("silver")
					while(amt_silver && coinsToProduce)
						if(locate(/obj/item/storage/bag/money, get_turf(output)))
							M = locate(/obj/item/storage/bag/money, get_turf(output))
						else
							M = new/obj/item/storage/bag/money(get_turf(output))
						new /obj/item/coin/silver(M)
						amt_silver -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("diamond")
					while(amt_diamond && coinsToProduce)
						if(locate(/obj/item/storage/bag/money, get_turf(output)))
							M = locate(/obj/item/storage/bag/money, get_turf(output))
						else
							M = new/obj/item/storage/bag/money(get_turf(output))
						new /obj/item/coin/diamond(M)
						amt_diamond -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("phoron")
					while(amt_phoron && coinsToProduce)
						if(locate(/obj/item/storage/bag/money, get_turf(output)))
							M = locate(/obj/item/storage/bag/money, get_turf(output))
						else
							M = new/obj/item/storage/bag/money(get_turf(output))
						new /obj/item/coin/phoron(M)
						amt_phoron -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("uranium")
					while(amt_uranium && coinsToProduce)
						if(locate(/obj/item/storage/bag/money, get_turf(output)))
							M = locate(/obj/item/storage/bag/money, get_turf(output))
						else
							M = new /obj/item/storage/bag/money(get_turf(output))
						new /obj/item/coin/uranium(M)
						amt_uranium -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
			icon_state = "coinpress0"
			processing = FALSE
			coinsToProduce = temp_coins
	src.updateUsrDialog()
	return
