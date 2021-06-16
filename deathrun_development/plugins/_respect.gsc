init()
{
	level.finishPosition = [];
	level.arrayPos =[];

	level.playerEnterNum = 0;

	level.inRoomPlugin = false;

	level.disableRoomPlugin = false;

	thread watchEndTrig();

	level.orderHud = addHud(level, -60, -25, 0.8, "left", "top", 1.7);
	//level.orderHud setText("^4>>^:[Placement Order:]^4<<");
	level.queueHud = addHud(level, -50, 0, 0.8, "left", "top", 1.5);
	level.queueHud.color = (1,1,1);
	level.queueHud1 = addHud(level, -50, 18.5, 0.8, "left", "top", 1.5);
	level.queueHud1.color = (1,1,1);
	level.var = 0;
}

//check player is till alive while in a room
onRoomDeath()
{
	while( isAlive( self ) && isDefined( self ) )
		wait 0.1;
	level.playerEnterNum++;
	level.inRoomPlugin = false;
	upDateQueueHud();
}

//while player is in queue check they are still alive
onQueueDeath()
{
	self endon("romm_enter_plugin");

	//save there id so if they disconnect we can still use it
	id = self.guid;

	while( isAlive( self ) && isDefined( self ) )
		wait 0.1;

	//find players position in queue array and remove it
	for(i = level.playerEnterNum; i<level.finishPosition.size; i++)
	{
		if(level.finishPosition[i].guid == id)
		{
			level.finishPosition = removeFromArray(level.finishPosition, i);
			upDateQueueHud();
			return;
		}
	}
	upDateQueueHud();
}

removeFromArray(b, num)
{
	temp = [];
	for(i=0; i<b.size; i++)
	{
		if(i != num)
			temp[temp.size] = b[i];
	}
	return temp;
}

watchEndTrig()
{
	//level endon("round_ended");
	
	level.endmaptriggerplugin = getEntArray( "endmap_trig", "targetname" );

	if( !level.endmaptriggerplugin.size || level.endmaptriggerplugin.size > 1 )
		level.endmaptriggerplugin = map_scripts\_spawnable_triggers::getTrigArray( "endmap_trig", "targetname" );
	if( !level.endmaptriggerplugin.size || level.endmaptriggerplugin.size > 1 )
		return;
		
    level.endmaptriggerplugin = level.endmaptriggerplugin[0];
		
    while(1)
    {
    	found = false;

		
    	level.endmaptriggerplugin waittill("trigger", player);
		level.var++;
		//level.orderHud setText("^5Queue : "); /temp q
		level.orderHud setText("^4>>^:[Placement Order:]^4<<");
		if(level.finishPosition[level.playerEnterNum].guid != player.guid || level.inRoomPlugin)
    	{
        player IPrintLnBold("^1Wait your turn");
        //player setOrigin(level.endmaptriggerplugin.origin);
        player setOrigin((level.endmaptriggerplugin.origin[0],level.endmaptriggerplugin.origin[1]-150,level.endmaptriggerplugin.origin[2]+20));
        
        	//return false;
    	}	
    	//check if player already has place in queue
    	for(i = level.playerEnterNum; i<level.finishPosition.size; i++)
    	{
    		if(level.finishPosition[i].guid == player.guid)
    			found = true;
    	}

    	//if they do dont add them to it again
    	if(found)
    		continue;

    	//no ghosts in queue
		if(isDefined(player.ghost) && player.ghost)
	    {
	        player Suicide();
	        continue;
	    }

	    //no acti in queue
	    if( player.pers["team"] == "axis" )
	    	continue;

	    //add player to queue
	    level.finishPosition[level.finishPosition.size] = player;

		level.arrayPos[level.var] = player;
	    // player IPrintLnBold("Queue Postion " + level.var);
	    // IPrintLnBold("^1"+player.name+"^7 finished the Map [^1"+level.finishPosition.size+"^7]");
	    if(player.pers["team"] == "allies" && player.sessionstate == "playing")
	    	player thread get_place_reward(level.arrayPos.size);
	    
	    player thread onQueueDeath();

	    upDateQueueHud();
	}
}

get_place_reward(place)
{
	switch(place)
	{
		case 1:
			self braxi\_rank::giverankxp(undefined,1000);
			IPrintLnBold("^:[ 1# Place ]^7 ^3Rewarded ^4 " + self.name );
			self braxi\_mod::giveLife();
			break;
		case 2:
			IPrintLnBold("^5[ 2# Place ^5]^7 ^3Rewarded^4 [" + self.name + "]" );
			self braxi\_mod::giveLife();
			self braxi\_rank::giverankxp(undefined,750);
			break;
		case 3:
			IPrintLnBold("^5[ 3# Place ^5]^7 ^3Rewarded^4 [" + self.name + "]" );
			self braxi\_mod::giveLife();
			self braxi\_rank::giverankxp(undefined,500);
			break;
		case 4:
			IPrintLnBold("^5[ 4# Place ^5]^4 [" + self.name + "]" );
			self braxi\_rank::giverankxp(undefined,350);
			break;
		case 5:
			IPrintLnBold("^5[ 5# Place ^5]^4 [" + self.name + "]" );
			self braxi\_rank::giverankxp(undefined,300);
			break;
		case 6:
			IPrintLnBold("^5[ 6# Place ^5]^4 [" + self.name + "]" );
			self braxi\_rank::giverankxp(undefined,250);
			break;
		case 7:
			IPrintLnBold("^5[ 7# Place ^5]^4 [" + self.name + "]" );
			self braxi\_rank::giverankxp(undefined,200);
			break;
		case 8:
			IPrintLnBold("^5[ 8# Place ^5]^4 [" + self.name + "]" );
			self braxi\_rank::giverankxp(undefined,150);
			break;
		case 9:
			IPrintLnBold("^5[ 9# Place ^5]^4 [" + self.name + "]" );
			self braxi\_rank::giverankxp(undefined,100);
			break;
		case 10:
			IPrintLnBold("^5[ 10# Place ^5]^4 [" + self.name + "]");
			self braxi\_rank::giverankxp(undefined,75);
			break;
	}
}

//called from map gsc
roomCheck(player)
{
	//no ghosts in room
	if(isDefined(player.ghost) && player.ghost)
    {
        player Suicide();
        return false;
    }

    if(player.pers["team"] == "axis")
    	return false;

    if(level.disableRoomPlugin)
    	return true;

    //check player entering with next in queue id
    if(level.finishPosition[level.playerEnterNum].guid != player.guid || level.inRoomPlugin)
    {
        player IPrintLnBold("^1Wait your turn");

        if(!isDefined(level.respect_noretp))
        {
        	if(!isDefined(level.respect_tp_pos))
        		player setOrigin(level.endmaptriggerplugin.origin);
        	else
        		player setOrigin(level.respect_tp_pos);
        }
        
        return false;
    }
    
    player notify("romm_enter_plugin");
    level.inRoomPlugin = true;
    player thread plugins\_respect::onRoomDeath();
    upDateQueueHud();
    return true;
}

//queue hud
upDateQueueHud()
{
	string = "^6^:[Who Enter?]^7 >> ";
	for(i=level.playerEnterNum; i<level.finishPosition.size; i++)
	{
		if(i >= 0 && i <= 1)
			string += level.finishPosition[i].name+"\n                                         ";
	}
	level.queueHud1 SetText("^6^:[Who Is Next?]^7 >> ");
	level.queueHud SetText(string);
	childToks = strtok(string, " ");
	if(!isDefined(childToks[4]))
		level.queueHud1 SetText("^6^:[Who Is Next?]^7 >> ...");
}

addHud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.horzAlign = alignX;
    hud.vertAlign = alignY;
	hud.fontScale = fontScale;
	return hud;
}