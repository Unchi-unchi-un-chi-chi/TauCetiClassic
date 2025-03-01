//original code and idea from Alfie275 (luna era) and ISaidNo (goonservers) - with thanks

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Xenoarchaeological finds

/datum/find
	var/find_type = 0				//random according to the digsite type
	var/excavation_required = 0		//random 5-95%
	var/view_range = 20				//how close excavation has to come to show an overlay on the turf
	var/clearance_range = 3			//how close excavation has to come to extract the item
									//if excavation hits var/excavation_required exactly, it's contained find is extracted cleanly without the ore
	var/prob_delicate = 90			//probability it requires an active suspension field to not insta-crumble
	var/dissonance_spread = 1		//proportion of the tile that is affected by this find
									//used in conjunction with analysis machines to determine correct suspension field type

/datum/find/New(digsite, exc_req)
	excavation_required = exc_req
	find_type = get_random_find_type(digsite)
	clearance_range = rand(2,6)
	dissonance_spread = rand(1500,2500) / 100

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Strange rocks

//have all strange rocks be cleared away using welders for now
/obj/item/weapon/ore/strangerock
	name = "Strange rock"
	desc = "Seems to have some unusal strata evident throughout it."
	icon = 'icons/obj/xenoarchaeology/finds.dmi'
	icon_state = "strange"
	var/obj/item/weapon/inside
	origin_tech = "materials=5"

/obj/item/weapon/ore/strangerock/atom_init(mapload, inside_item_type = 0)
	. = ..()
	if(inside_item_type)
		new/obj/item/weapon/archaeological_find(src, inside_item_type)
		inside = locate() in contents

/*/obj/item/weapon/ore/strangerock/ex_act(var/severity)
	if(severity && prob(30))
		visible_message("The [src] crumbles away, leaving some dust and gravel behind.")*/

/obj/item/weapon/ore/strangerock/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pickaxe/brush))
		if(I.use_tool(src, user, 20, volume = 50))
			if(inside)
				inside.forceMove(get_turf(src))
				visible_message("<span class='notice'>\The [src] is brushed away revealing \the [inside].</span>")
				inside = null
			else
				visible_message("<span class='warning'>\The [src] reveals nothing!</span>")
			qdel(src)
			return

	if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		user.SetNextMove(CLICK_CD_INTERACT)
		if(WT.use_tool(src, user, 20, volume = 50))
			if(WT.isOn())
				if(WT.get_fuel() >= 4)
					if(inside)
						inside.forceMove(get_turf(src))
						user.visible_message("<span class='info'>[src] burns away revealing [inside].</span>")
					else
						user.visible_message("<span class='info'>[src] burns away into nothing.</span>")
					qdel(src)
					WT.use(4)
				else
					visible_message("<span class='info'>A few sparks fly off [src], but nothing else happens.</span>")
					WT.use(1)
		return

	if(istype(I, /obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/S = I
		S.sample_item(src, user)
		user.SetNextMove(CLICK_CD_INTERACT)
		return

	. = ..()
	if(prob(33))
		visible_message("<span class='warning'>[src] crumbles away, leaving some dust and gravel behind.</span>")
		qdel(src)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Archaeological finds

/obj/item/weapon/archaeological_find
	name = "object"
	icon = 'icons/obj/xenoarchaeology/finds.dmi'
	icon_state = "ano01"
	var/find_type = 0

/obj/item/weapon/archaeological_find/atom_init(mapload, new_item_type)
	. = ..()

	if(new_item_type)
		find_type = new_item_type
	else
		find_type = rand(1,37) // update this when you add new find types

	var/item_type = "object"
	icon_state = "unknown[rand(1,4)]"
	var/additional_desc = ""
	var/obj/item/weapon/new_item
	var/source_material = pick("cordite", "quadrinium", "steel", "titanium", "aluminium", "ferritic-alloy", "plasteel", "duranium")
	var/apply_material_decorations = 1
	var/apply_image_decorations = 0
	var/material_descriptor = ""
	var/apply_prefix = 1
	if(prob(40))
		material_descriptor = pick("rusted ", "dusty ", "archaic ", "fragile ")

	var/talkative = 0
	if(prob(5))
		talkative = 1

	//for all items here:
	//icon_state
	//item_state
	switch(find_type)
		if(1)
			item_type = "bowl"
			if(prob(50))
				new_item = new /obj/item/weapon/reagent_containers/glass/replenishing(loc)
				additional_desc = "You feel as if [src] is slowly filling up..."
			else
				new_item = new /obj/item/weapon/reagent_containers/glass/beaker(loc)
			new_item.icon = 'icons/obj/xenoarchaeology/finds.dmi'
			new_item.icon_state = "bowl"
			apply_image_decorations = 1
			if(prob(20))
				additional_desc = "There appear to be [pick("dark","faintly glowing","pungent","bright")] [pick("red","purple","green","blue")] stains inside."
		if(2)
			item_type = "urn"
			if(prob(50))
				new_item = new /obj/item/weapon/reagent_containers/glass/replenishing(loc)
				additional_desc = "You feel as if [src] is slowly filling up..."
			else
				new_item = new /obj/item/weapon/reagent_containers/glass/beaker(loc)
			new_item.icon = 'icons/obj/xenoarchaeology/finds.dmi'
			new_item.icon_state = "urn"
			apply_image_decorations = 1
			if(prob(20))
				additional_desc = "It [pick("whispers faintly","makes a quiet roaring sound","whistles softly","thrums quietly","throbs")] if you put it to your ear."
		if(3)
			item_type = "[pick("fork","spoon","knife")]"
			if(prob(25))
				new_item = new /obj/item/weapon/kitchen/utensil/fork(loc)
			else if(prob(50))
				new_item = new /obj/item/weapon/kitchenknife(loc)
			else
				new_item = new /obj/item/weapon/kitchen/utensil/spoon(loc)
			additional_desc = "[pick("It's like no [item_type] you've ever seen before",\
			"It's a mystery how anyone is supposed to eat with this",\
			"You wonder what the creator's mouth was shaped like")]."
		if(4)
			name = "statuette"
			item_type = "statuette"
			icon_state = "statuette"
			additional_desc = "It depicts a [pick("small","ferocious","wild","pleasing","hulking")] \
			[pick("alien figure","rodent-like creature","reptilian alien","primate","unidentifiable object")] \
			[pick("performing unspeakable acts","posing heroically","in a fetal position","cheering","sobbing","making a plaintive gesture","making a rude gesture")]."
			if(prob(50))
				new_item = new /obj/item/weapon/vampiric(loc)
		if(5)
			item_type = "instrument"
			icon_state = "instrument"
			if(prob(30))
				apply_image_decorations = 1
				additional_desc = "[pick("You're not sure how anyone could have played this",\
				"You wonder how many mouths the creator had",\
				"You wonder what it sounds like",\
				"You wonder what kind of music was made with it")]."
		if(6)
			item_type = "[pick("bladed knife","serrated blade","sharp cutting implement")]"
			new_item = new /obj/item/weapon/kitchenknife(loc)
			additional_desc = "[pick("It doesn't look safe.",\
			"It looks wickedly jagged",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along the edges")]."
		if(7)
			// assuming there are 10 types of coins
			var/chance = 10
			for(var/type in typesof(/obj/item/weapon/coin))
				if(prob(chance))
					new_item = new type(loc)
					break
				chance += 10

			item_type = new_item.name
			apply_prefix = 0
			apply_material_decorations = 0
			apply_image_decorations = 1
		if(8)
			item_type = "handcuffs"
			new_item = new /obj/item/weapon/handcuffs(loc)
			additional_desc = "[pick("They appear to be for securing two things together","Looks kinky","Doesn't seem like a children's toy")]."
		if(9)
			item_type = "[pick("wicked","evil","byzantine","dangerous")] looking [pick("device","contraption","thing","trap")]"
			apply_prefix = 0
			new_item = new /obj/item/weapon/legcuffs/beartrap(loc)
			additional_desc = "[pick("It looks like it could take a limb off",\
			"Could be some kind of animal trap",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along part of it")]."
		if(10)
			apply_prefix = 0
			var/pickpipboy = pick(1, 2, 3)
			switch(pickpipboy)
				if(1)
					new_item = new /obj/item/clothing/gloves/pipboy(loc)
				if(2)
					new_item = new /obj/item/clothing/gloves/pipboy/pimpboy3billion(loc)
				if(3)
					new_item = new /obj/item/clothing/gloves/pipboy/pipboy3000mark4(loc)
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(11)
			item_type = "box"
			new_item = new /obj/item/weapon/storage/box(loc)
			new_item.icon = 'icons/obj/xenoarchaeology/finds.dmi'
			new_item.icon_state = "box"
			var/obj/item/weapon/storage/box/new_box = new_item
			new_box.max_w_class = pick(1,2,2,3,3,3,4,4)
			new_box.max_storage_space = rand(new_box.max_w_class, new_box.max_w_class * 10)
			new_box.foldable = FALSE
			if(prob(30))
				apply_image_decorations = 1
		if(12)
			item_type = "[pick("cylinder","tank","chamber")]"
			if(prob(25))
				new_item = new /obj/item/weapon/tank/air(loc)
			else if(prob(50))
				new_item = new /obj/item/weapon/tank/anesthetic(loc)
			else
				new_item = new /obj/item/weapon/tank/phoron(loc)
			icon_state = pick("oxygen","oxygen_fr","oxygen_f","phoron","anesthetic")
			additional_desc = "It [pick("gloops","sloshes")] slightly when you shake it."
		if(13)
			item_type = "tool"
			if(prob(25))
				new_item = new /obj/item/weapon/wrench(loc)
			else if(prob(25))
				new_item = new /obj/item/weapon/crowbar(loc)
			else
				new_item = new /obj/item/weapon/screwdriver(loc)
			additional_desc = "[pick("It doesn't look safe.",\
			"You wonder what it was used for",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains on it")]."
		if(14)
			apply_material_decorations = 0
			var/list/possible_spawns = list()
			possible_spawns += /obj/item/stack/sheet/metal
			possible_spawns += /obj/item/stack/sheet/plasteel
			possible_spawns += /obj/item/stack/sheet/glass
			possible_spawns += /obj/item/stack/sheet/rglass
			possible_spawns += /obj/item/stack/sheet/mineral/phoron
			possible_spawns += /obj/item/stack/sheet/mineral/gold
			possible_spawns += /obj/item/stack/sheet/mineral/silver
			possible_spawns += /obj/item/stack/sheet/mineral/enruranium
			possible_spawns += /obj/item/stack/sheet/mineral/sandstone
			possible_spawns += /obj/item/stack/sheet/mineral/silver

			var/new_type = pick(possible_spawns)
			new_item = new new_type(loc, rand(5,45))
		if(15)
			if(prob(75))
				new_item = new /obj/item/weapon/pen(loc)
			else
				new_item = new /obj/item/weapon/pen/sleepypen(loc)
			if(prob(30))
				apply_image_decorations = 1
		if(16)
			apply_prefix = 0
			if(prob(25))
				item_type = "smooth green crystal"
				icon_state = "Green lump"
			else if(prob(33))
				item_type = "irregular purple crystal"
				icon_state = "Phazon"
			else if(prob(50))
				item_type = "rough red crystal"
				icon_state = "changerock"
			else
				item_type = "smooth red crystal"
				icon_state = "changerock"
			additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")

			apply_material_decorations = 0
			if(prob(10))
				apply_image_decorations = 1
			if(prob(25))
				new_item = new /obj/item/device/soulstone(loc)
				new_item.icon = 'icons/obj/xenoarchaeology/finds.dmi'
				new_item.icon_state = icon_state
		if(17)
			// cultblade
			apply_prefix = 0
			new_item = new /obj/item/weapon/melee/cultblade(loc)
			apply_material_decorations = 0
			apply_image_decorations = 0
		if(18)
			new_item = new /obj/item/device/radio/beacon(loc)
			talkative = 0
			new_item.icon_state = "unknown[rand(1,4)]"
			new_item.icon = 'icons/obj/xenoarchaeology/finds.dmi'
			new_item.desc = ""
		if(19)
			apply_prefix = 0
			new_item = new /obj/item/weapon/claymore(loc)
			new_item.force = 17
			item_type = new_item.name
		if(20)
			// arcane clothing
			apply_prefix = 0
			var/list/possible_spawns = list(/obj/item/clothing/head/culthood,
			/obj/item/clothing/head/magus,
			/obj/item/clothing/head/culthood,
			/obj/item/clothing/head/helmet/space/cult)

			var/new_type = pick(possible_spawns)
			new_item = new new_type(loc)
		if(21)
			// soulstone
			apply_prefix = 0
			new_item = new /obj/item/device/soulstone(loc)
			item_type = new_item.name
			apply_material_decorations = 0
		if(22)
			apply_prefix = 0
			new_item = new /obj/item/clothing/glasses/hud/mining/ancient(loc)
			new_item.name = pick("strange looking hud", "strange looking glasses")
			new_item.desc = "It glows faintly."
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(23)
			apply_prefix = 0
			new_item = new /obj/item/stack/rods(loc)
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(24)
			var/list/possible_spawns = typesof(/obj/item/weapon/stock_parts)
			possible_spawns -= /obj/item/weapon/stock_parts
			possible_spawns -= /obj/item/weapon/stock_parts/subspace

			var/new_type = pick(possible_spawns)
			new_item = new new_type(loc)
			item_type = new_item.name
			apply_material_decorations = 0
		if(25)
			apply_prefix = 0
			new_item = new /obj/item/weapon/katana(loc)
			new_item.force = 17
			item_type = new_item.name
		if(26)
			//energy gun
			var/spawn_type = pick(
			/obj/item/weapon/gun/energy/sniperrifle/rails,
			/obj/item/weapon/gun/tesla/rifle,
			/obj/item/weapon/gun/energy/laser/scatter/alien,
			/obj/item/weapon/gun/energy/laser/selfcharging/alien)
			if(spawn_type && spawn_type != /obj/item/weapon/gun/tesla/rifle)
				var/obj/item/weapon/gun/energy/new_gun = new spawn_type(loc)
				new_item = new_gun

				// 5% chance to explode when first fired
				// 10% chance to have an unchargeable cell
				// 15% chance to gain a random amount of starting energy, otherwise start with an empty cell
				if(prob(5))
					new_gun.power_supply.rigged = 1
				if(prob(10))
					new_gun.power_supply.maxcharge = 0
				if(prob(15))
					new_gun.power_supply.charge = rand(0, new_gun.power_supply.maxcharge)
				else
					new_gun.power_supply.charge = 0

			item_type = "gun"
		if(27)
			// revolver
			var/obj/item/weapon/gun/projectile/revolver/new_gun = new /obj/item/weapon/gun/projectile/revolver(loc)
			new_item = new_gun
			new_item.icon_state = "gun[rand(1,4)]"
			new_item.icon = 'icons/obj/xenoarchaeology/finds.dmi'

			// 66% chance to be able to reload the gun with human ammunition
			if(prob(33))
				new_gun.magazine.caliber = "999"

			// 33% chance to make the gun non-empty
			if(prob(33))
				var/num_bullets = rand(1, new_gun.magazine.max_ammo)
				new_gun.magazine.stored_ammo.len = num_bullets
			else
				new_gun.magazine.stored_ammo.len = 0

			item_type = "gun"
		if(28)
			//completely unknown alien device
			if(prob(50))
				apply_image_decorations = 0
		if(29)
			//fossil bone/skull
			//new_item = new /obj/item/weapon/fossil/base(loc)

			//the replacement item propogation isn't working, and it's messy code anyway so just do it here
			var/list/candidates = list(/obj/item/weapon/fossil/bone=9,/obj/item/weapon/fossil/skull=3,
			/obj/item/weapon/fossil/skull/horned=2)
			var/spawn_type = pickweight(candidates)
			new_item = new spawn_type(loc)

			apply_prefix = 0
			additional_desc = "A fossilised part of an alien, long dead."
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(30)
			//fossil shell
			new_item = new /obj/item/weapon/fossil/shell(loc)
			apply_prefix = 0
			additional_desc = "A fossilised, pre-Stygian alien crustacean."
			apply_image_decorations = 0
			apply_material_decorations = 0
			if(prob(10))
				apply_image_decorations = 1
		if(31)
			//fossil plant
			new_item = new /obj/item/weapon/fossil/plant(loc)
			item_type = new_item.name
			additional_desc = "A fossilised shred of alien plant matter."
			apply_image_decorations = 0
			apply_material_decorations = 0
			apply_prefix = 0
		if(32)
			//humanoid remains
			apply_prefix = 0
			item_type = "humanoid [pick("remains","skeleton")]"
			icon = 'icons/effects/blood.dmi'
			icon_state = "remains"
			additional_desc = pick("They appear almost human.",\
			"They are contorted in a most gruesome way.",\
			"They look almost peaceful.",\
			"The bones are yellowing and old, but remarkably well preserved.",\
			"The bones are scored by numerous burns and partially melted.",\
			"The are battered and broken, in some cases less than splinters are left.",\
			"The mouth is wide open in a death rictus, the victim would appear to have died screaming.")
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(33)
			//robot remains
			apply_prefix = 0
			item_type = "[pick("mechanical","robotic","cyborg")] [pick("remains","chassis","debris")]"
			icon = 'icons/mob/robots.dmi'
			icon_state = "gib[rand(1,6)]"
			additional_desc = pick("Almost mistakeable for the remains of a modern cyborg.",\
			"They are barely recognisable as anything other than a pile of waste metals.",\
			"It looks like the battered remains of an ancient robot chassis.",\
			"The chassis is rusting and old, but remarkably well preserved.",\
			"The chassis is scored by numerous burns and partially melted.",\
			"The chassis is battered and broken, in some cases only chunks of metal are left.",\
			"A pile of wires and crap metal that looks vaguely robotic.")
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(34)
			//xenos remains
			apply_prefix = 0
			item_type = "alien [pick("remains","skeleton")]"
			icon = 'icons/effects/blood.dmi'
			icon_state = "remainsxeno"
			additional_desc = pick("It looks vaguely reptilian, but with more teeth.",\
			"They are faintly unsettling.",\
			"There is a faint aura of unease about them.",\
			"The bones are yellowing and old, but remarkably well preserved.",\
			"The bones are scored by numerous burns and partially melted.",\
			"The are battered and broken, in some cases less than splinters are left.",\
			"This creature would have been twisted and monstrous when it was alive.",\
			"It doesn't look human.")
			apply_image_decorations = 0
			apply_material_decorations = 0
		if(35)
			//gas mask
			if(prob(25))
				new_item = new /obj/item/clothing/mask/gas/poltergeist(loc)
			else
				new_item = new /obj/item/clothing/mask/gas(loc)
		if(36)
			apply_prefix = 0
			item_type = "strange device"
			new_item = new /obj/item/weapon/strangetool(loc)
			additional_desc = "This device is made of metal, emits a strange purple formation of unknown origin."
			apply_image_decorations = 0
			apply_material_decorations = 0

		if(37)
			//relic water bottle
			new_item = new /obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle/relic(loc)

	var/decorations = ""
	if(apply_material_decorations)
		source_material = pick("cordite","quadrinium","steel","titanium","aluminium","ferritic-alloy","plasteel","duranium")
		desc = "A [material_descriptor ? "[material_descriptor] " : ""][item_type] made of [source_material], all craftsmanship is of [pick("the lowest","low","average","high","the highest")] quality."

		var/list/descriptors = list()
		if(prob(30))
			descriptors.Add("is encrusted with [pick("","synthetic ","multi-faceted ","uncut ","sparkling ") + pick("rubies","emeralds","diamonds","opals","lapiz lazuli")]")
		if(prob(30))
			descriptors.Add("is studded with [pick("gold","silver","aluminium","titanium")]")
		if(prob(30))
			descriptors.Add("is encircled with bands of [pick("quadrinium","cordite","ferritic-alloy","plasteel","duranium")]")
		if(prob(30))
			descriptors.Add("menaces with spikes of [pick("solid phoron","uranium","white pearl","black steel")]")
		if(descriptors.len > 0)
			decorations = "It "
			for(var/index=1, index <= descriptors.len, index++)
				if(index > 1)
					if(index == descriptors.len)
						decorations += " and "
					else
						decorations += ", "
				decorations += descriptors[index]
			decorations += "."
		if(decorations)
			desc += " " + decorations

	var/engravings = ""
	if(apply_image_decorations)
		engravings = "[pick("Engraved","Carved","Etched")] on the item is [pick("an image of","a frieze of","a depiction of")] \
		[pick("an alien humanoid","an amorphic blob","a short, hairy being","a rodent-like creature","a robot","a primate","a reptilian alien","an unidentifiable object","a statue","a starship","unusual devices","a structure")] \
		[pick("surrounded by","being held aloft by","being struck by","being examined by","communicating with")] \
		[pick("alien humanoids","amorphic blobs","short, hairy beings","rodent-like creatures","robots","primates","reptilian aliens")]"
		if(prob(50))
			engravings += ", [pick("they seem to be enjoying themselves","they seem extremely angry","they look pensive","they are making gestures of supplication","the scene is one of subtle horror","the scene conveys a sense of desperation","the scene is completely bizarre")]"
		engravings += "."

		if(desc)
			desc += " "
		desc += engravings

	if(apply_prefix)
		name = "[pick("Strange","Ancient","Alien","")] [item_type]"
	else
		name = item_type

	if(desc)
		desc += " "
	desc += additional_desc
	if(!desc)
		desc = "This item is completely [pick("alien","bizarre")]."

	//icon and icon_state should have already been set
	if(new_item)
		new_item.name = name
		new_item.desc = src.desc

		if(talkative)
			new_item.AddComponent(/datum/component/talking_atom)

		return INITIALIZE_HINT_QDEL

	else if(talkative)
		AddComponent(/datum/component/talking_atom)
