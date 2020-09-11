init( modVersion )
{
	mapRotations();
	setSvMapRotation();
}

mapRotations()
{
	/*	
	*	[ HELP ]
	*	Since there are limits to what a dvar can store,
	*	if we wanna have more than a certain amount of maps
	*	in sv_mapRotations, we need to make a script for them.
	*	That is what this is.
	*	
	*	I would recommend adding 6-16 maps per game["sv_mapRotations"][i]
	*/	
	
	if(isDefined(game["sv_mapRotations"]))
		return;
	
	game["sv_mapRotations"] = [];
	
	i = 0;
	game["sv_mapRotations"][i] = "map mp_deathrun_gold map mp_deathrun_skypillar map mp_deathrun_supermario map mp_deathrun_cookie map mp_deathrun_portal_v3 map mp_dr_pool map mp_dr_watercity map mp_dr_indipyramid map mp_dr_bananaphone map mp_deathrun_greenland map mp_dr_apocalypse map mp_deathrun_epicfail"; // 12 maps
	i++;
	game["sv_mapRotations"][i] = "map mp_dr_purple_world map mp_deathrun_highrise map mp_deathrun_jailhouse map mp_dr_unreal map mp_dr_disco map mp_dr_pacman map mp_deathrun_long map mp_dr_skydeath map mp_dr_snip map mp_deathrun_minecraft map mp_deathrun_mine map mp_deathrun_city"; // 12 maps
	i++;
	game["sv_mapRotations"][i] = "map mp_dr_blackandwhite map mp_deathrun_takecare map mp_deathrun_watchit_v3 map mp_deathrun_grassy map mp_deathrun_semtex map mp_deathrun_diehard map mp_deathrun_waterworld map mp_deathrun_cherry map mp_deathrun_coyote_v2 map mp_deathrun_framey_v2 map mp_deathrun_crystal maps mp_deathrun_dragonball"; // 12 maps
	i++;
	game["sv_mapRotations"][i] = "map mp_deathrun_spaceball map mp_deathrun_scoria map mp_dr_bounce map mp_dr_windwaker map mp_dr_anubis map mp_dr_harrypotter map mp_dr_gooby map mp_dr_heaven map mp_dr_imaginary map mp_dr_skypower map mp_dr_undertale map mp_dr_h2o map mp_dr_sm_world map mp_dr_vistic_castle"; // 14 maps
	i++;
}

setSvMapRotation()
{
	if(isDefined(game["sv_mapRotationSet"]))
		return;
	
	if(!isDefined(game["sv_mapRotations"]) || game["sv_mapRotations"][0] == "")
		return;
	
	x = randomIntRange(0, game["sv_mapRotations"].size);
	sv_mapRotation = game["sv_mapRotations"][x];
	
	if(sv_mapRotation == getDvar("sv_mapRotation"))
	{
		if(x + 1 <= game["sv_mapRotations"].size)
		{
			sv_mapRotation = game["sv_mapRotations"][x + 1];
		}
		else if(x - 1 >= game["sv_mapRotations"].size)
		{
			sv_mapRotation = game["sv_mapRotations"][x - 1];
		}
	}
	
	if(!isDefined(sv_mapRotation) || sv_mapRotation == "")
		sv_mapRotation = game["sv_mapRotations"][0];
	
	setDvar("sv_mapRotation", sv_mapRotation);
	game["sv_mapRotationSet"] = true;
}