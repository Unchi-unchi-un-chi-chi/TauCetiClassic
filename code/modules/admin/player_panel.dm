
/datum/admins/proc/player_panel_new()//The new one
	if (!usr.client.holder)
		return
	var/dat = "<html><head><title>Admin Player Panel</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,job,name,real_name,image,key,ip,antagonist,ref){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" </b></font>"

					body += "</td><td align='center'>";

					body += "<a href='?src=\ref[src];adminplayeropts="+ref+"'>PP</a> - "
					body += "<a href='?src=\ref[src];notes=show;mob="+ref+"'>N</a> - "
					body += "<a href='?_src_=vars;Vars="+ref+"'>VV</a> - "
					body += "<a href='?src=\ref[src];traitor="+ref+"'>TP</a> - "
					body += "<a href='?src=\ref[usr];priv_msg=\ref"+ref+"'>PM</a> - "
					body += "<a href='?src=\ref[src];subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='?src=\ref[src];adminplayerobservejump="+ref+"'>JMP</a><br>"
					if(antagonist > 0)
						body += "<font size='2'><a class='red' href='?src=\ref[src];check_antagonist=1'><b>Antagonist</b></a></font>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information - <a href='?src=\ref[src];check_antagonist=1'>Check antagonists</a>
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sortmobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey)

			var/color = "#e6e6e6"
			if(i%2 == 0)
				color = "#f2f2f2"
			var/is_antagonist = is_special_character(M)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(ishuman(M))
						M_job = M.job
					else if(isslime(M))
						M_job = "slime"
					else if(ismonkey(M))
						M_job = "Monkey"
					else if(isxeno(M)) //aliens
						if(isxenolarva(M))
							M_job = "Alien larva"
						else if(isfacehugger(M))
							M_job = "Alien facehugger"
						else
							M_job = "Alien"
					else
						M_job = "Carbon-based"

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = "AI"
					else if(ispAI(M))
						M_job = "pAI"
					else if(isrobot(M))
						M_job = "Cyborg"
					else
						M_job = "Silicon-based"

				else if(isanimal(M)) //simple animals
					if(iscorgi(M))
						M_job = "Corgi"
					else
						M_job = "Animal"

				else
					M_job = "Living"

			else if(isnewplayer(M))
				M_job = "New player"

			else if(isobserver(M))
				M_job = "Ghost"

			M_job = replacetext(M_job, "'", "")
			M_job = replacetext(M_job, "\"", "")
			M_job = replacetext(M_job, "\\", "")

			var/M_name = M.name
			M_name = replacetext(M_name, "'", "")
			M_name = replacetext(M_name, "\"", "")
			M_name = replacetext(M_name, "\\", "")
			var/M_rname = M.real_name
			M_rname = replacetext(M_rname, "'", "")
			M_rname = replacetext(M_rname, "\"", "")
			M_rname = replacetext(M_rname, "\\", "")

			var/M_key = M.key
			M_key = replacetext(M_key, "'", "")
			M_key = replacetext(M_key, "\"", "")
			M_key = replacetext(M_key, "\\", "")

			//output for each mob
			dat += {"

				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","--unused--","[M_key]","[M.lastKnownIP]",[is_antagonist],"\ref[M]")'
						>
						<span id='search[i]'><b>[M_name] - [M_rname] - [M_key] ([M_job])</b></span>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>

			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=players;size=600x480")

//The old one
/datum/admins/proc/player_panel_old()
	if (!usr.client.holder)
		return
	var/dat
	dat += "<table border=1 cellspacing=5><B><tr><th>Name</th><th>Real Name</th><th>Assigned Job</th><th>Key</th><th>Options</th><th>PM</th><th>Traitor?</th></tr></B>"
	//add <th>IP:</th> to this if wanting to add back in IP checking
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = sortmobs()

	for(var/mob/M in mobs)
		if(!M.ckey) continue

		dat += "<tr><td>[M.name]</td>"
		if(isAI(M))
			dat += "<td>AI</td>"
		else if(isrobot(M))
			dat += "<td>Cyborg</td>"
		else if(ishuman(M))
			dat += "<td>[M.real_name]</td>"
		else if(ispAI(M))
			dat += "<td>pAI</td>"
		else if(isnewplayer(M))
			dat += "<td>New Player</td>"
		else if(isobserver(M))
			dat += "<td>Ghost</td>"
		else if(ismonkey(M))
			dat += "<td>Monkey</td>"
		else if(isxeno(M))
			dat += "<td>Alien</td>"
		else if(istype(M, /mob/living/parasite/essence))
			dat += "<td>Changelling Essence</td>"
		else
			dat += "<td>Unknown</td>"


		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.assigned_role)
				dat += "<td>[H.mind.assigned_role]</td>"
		else
			dat += "<td>NA</td>"


		dat += {"<td>[(M.client ? "[M.client]" : "No client")]</td>
		<td align=center><A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>X</A></td>
		<td align=center><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
		"}
		switch(is_special_character(M))
			if(0)
				dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'>Traitor?</A></td>"}
			if(1)
				dat += {"<td align=center><A class='red' HREF='?src=\ref[src];traitor=\ref[M]'>Traitor?</A></td>"}
			if(2)
				dat += {"<td align=center><A class='red' HREF='?src=\ref[src];traitor=\ref[M]'><b>Traitor?</b></A></td>"}

	dat += "</table>"

	var/datum/browser/popup = new(usr, "players", "Player Menu", 640, 480)
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/check_antagonists()
	if (SSticker && SSticker.current_state >= GAME_STATE_PLAYING)
		var/dat = "<h1><B>Round Status</B></h1>"
		dat += "Current Game Mode: <B>[SSticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero("[world.time / 600 % 60]", 2)]:[add_zero("[world.time / 10 % 60]", 2)]</B><BR>"
		dat += "<B>Emergency shuttle</B><BR>"
		if (!SSshuttle.online)
			dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Shuttle</a><br>"
		else
			switch(SSshuttle.location)
				if(0)
					dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[shuttleeta2text()]</a><BR>"
					dat += "<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"
				if(1)
					dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[shuttleeta2text()]</a><BR>"
		dat += "<a href='?src=\ref[src];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		if(SSticker.mode.syndicates.len)
			dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.syndicates)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
				else
					dat += "<tr><td><i>Nuclear Operative not found!</i></td></tr>"
			dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
			for(var/obj/item/weapon/disk/nuclear/N in poi_list)
				dat += "<tr><td>[N.name], "
				var/atom/disk_loc = N.loc
				while(!istype(disk_loc, /turf))
					if(istype(disk_loc, /mob))
						var/mob/M = disk_loc
						dat += "carried by <a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> "
					if(istype(disk_loc, /obj))
						var/obj/O = disk_loc
						dat += "in \a [O.name] "
					disk_loc = disk_loc.loc
				dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
			dat += "</table>"

		if(SSticker.mode.head_revolutionaries.len || SSticker.mode.revolutionaries.len)
			dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.head_revolutionaries)
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><i>Head Revolutionary not found!</i></td></tr>"
				else
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
			for(var/datum/mind/N in SSticker.mode.revolutionaries)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
			dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
			for(var/datum/mind/N in SSticker.mode.get_living_heads())
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
					var/turf/mob_loc = get_turf_loc(M)
					dat += "<td>[mob_loc.loc]</td></tr>"
				else
					dat += "<tr><td><i>Head not found!</i></td></tr>"
			dat += "</table>"

		if(SSticker.mode.shadows.len)
			dat += "<br><table cellspacing=5><tr><td><B>Shadowlings</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.shadows)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name] ([M.ckey])</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
			dat += "<br><tr><td><B>Enthrall Progress(Must be alive):</B></td><td></td></tr>"
			var/thrall = 0
			var/mob/Count
			for(Count in alive_mob_list)
				if(is_thrall(Count))
					thrall++
			dat += "<tr><td>[thrall] of 15</td></tr>"
			dat += "<br><tr><td><B>Ascended:</B></td><td></td></tr>"
			dat += "<tr><td>[SSticker.mode.shadowling_ascended ? "Yes" : "No"]</td></tr>"
			dat += "</table>"

		if(SSticker.mode.thralls.len)
			dat += "<br><table cellspacing=5><tr><td><B>Shadowling Thralls</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.thralls)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name] ([M.ckey])</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : null]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
			dat += "</table>"

		if(SSticker.mode.abductors.len)
			dat += "<br><table cellspacing=5><tr><td><B>Abductors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/abductor in SSticker.mode.abductors)
				var/mob/M = abductor.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A HREF='?_src_=holder;traitor=\ref[M]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><i>Abductor not found!</i></td></tr>"
			dat += "</table>"

		if(SSticker.mode.infected_crew.len)
			dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
			dat += "<tr><td><i>Progress: [blobs.len]/[blobwincount]</i></td></tr>"
			for(var/datum/mind/blob in SSticker.mode.infected_crew)
				var/mob/M = blob.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><span class='red'>(DEAD)</span></b>" : ""]</td>"
					dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
				else
					dat += "<tr><td><i>Blob not found!</i></td></tr>"
		dat += "</table>"

		if(borers.len)
			dat += check_role_table("Borers", borers, src)

		if(SSticker.mode.changelings.len)
			dat += check_role_table("Changelings", SSticker.mode.changelings, src)

		if(SSticker.mode.wizards.len)
			dat += check_role_table("Wizards", SSticker.mode.wizards, src)

		if(SSticker.mode.raiders.len)
			var/datum/game_mode/heist/mode = SSticker.mode
			dat += "<br><table cellspacing=5><tr><td align=center><span class='green'><B>Heist:</span></B></td><td></td><td></td></tr>"
			if(mode.raid_objectives && mode.raid_objectives.len)
				for(var/datum/objective/heist/H in mode.raid_objectives)
					//heist_get_shuttle_price()
					dat += "<tr><td><B>[H.explanation_text]</B></td></tr>"
					//dat += "<tr><td><i>Progress: [num2text(heist_rob_total,9)]/[num2text(H.target_amount,9)]</i></td></tr>"
			dat += check_role_table("Raiders", SSticker.mode.raiders, src)

		if(SSticker.mode.ninjas.len)
			dat += check_role_table("Ninjas", SSticker.mode.ninjas, src)

		if(SSticker.mode.cult.len)
			dat += check_role_table("Cultists", SSticker.mode.cult, src, FALSE)

		if(SSticker.mode.traitors.len)
			dat += check_role_table("Traitors", SSticker.mode.traitors, src)

		if(istype(SSticker.mode, /datum/game_mode/infestation))
			var/datum/game_mode/infestation/inf = SSticker.mode
			var/data = inf.count_alien_percent()
			dat += "<br><table><tr><td><B>Статистика</B></td><td></td></tr>"
			dat += "<tr><td>Экипаж:</td><td>[data[TOTAL_HUMAN]]</td></tr>"
			dat += "<tr><td>Взрослые ксеноморфы:</td><td>[data[TOTAL_ALIEN]]</td></tr>"
			dat += "<tr><td>Процент победы:</td><td>[data[ALIEN_PERCENT]]/[WIN_PERCENT]</td></tr></table>"

		if(alien_list.len)
			for(var/key in alien_list)
				var/list/datum/mind/alien_minds = list()
				for(var/mob/living/carbon/xenomorph/A in alien_list[key])
					if(A.stat == DEAD || !A.mind)
						continue
					alien_minds += A.mind
				if(alien_minds.len)
					dat += check_role_table(key, alien_minds, src, FALSE)

		var/datum/browser/popup = new(usr, "roundstatus", "Round Status", 400, 500)
		popup.set_content(dat)
		popup.open()
	else
		alert("The game hasn't started yet!")

/proc/check_role_table(name, list/members, admins, show_objectives = TRUE)
	var/txt = "<br><table cellspacing=5><tr><td><b>[name]</b></td><td></td></tr>"
	for(var/datum/mind/M in members)
		txt += check_role_table_row(M.current, admins, show_objectives)
	txt += "</table>"
	return txt

/proc/check_role_table_row(mob/M, admins=src, show_objectives)
	if (!istype(M))
		return "<tr><td><i>Not found!</i></td></tr>"

	var/txt = {"
		<tr>
			<td>
				<a href='?src=\ref[admins];adminplayeropts=\ref[M]'>[M.real_name]</a>
				[M.client ? "" : " <i>(logged out)</i>"]
				[M.is_dead() ? " <b><span class='red'>(DEAD)</span></b>" : ""]
			</td>
			<td>
				<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>
			</td>
	"}

	if (show_objectives)
		txt += {"
			<td>
				<a href='?src=\ref[admins];traitor=\ref[M]'>Show Objective</a>
			</td>
		"}

	txt += "</tr>"
	return txt
