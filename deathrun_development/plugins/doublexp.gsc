init( modVersion )
{
	if(!isDefined(getDvar("scr_xpscale_original")) || getDvarInt("scr_xpscale_original") == 0)
		setDvar("scr_xpscale_original", getDvarInt("scr_xpscale"));
	level.originalXpScale = getDvarInt("scr_xpscale_original");
	level.requiredPlayerAmount = 5;

	level thread doubleXpHud();
	level thread monitorPlayers();
	
	level waittill("intermission");
	level thread deleteDoubleXpHud();
}

monitorPlayers()
{
	for(;;)
	{
		level.currentPlayerAmount = braxi\_common::getAllPlayers().size;
		level checkDoubleXP();
		level updateDoubleXpHud();
		wait 1;
	}
}

checkDoubleXP()
{
	if(level.currentPlayerAmount >= level.requiredPlayerAmount)
	{
		setDvar("scr_xpscale", level.originalXpScale * 2);
		level.doublexp = true;
	}
	else
	{
		setDvar("scr_xpscale", level.originalXpScale);
		level.doublexp = false;
	}
}

doubleXpHud()
{
	xAlign = "center";
	yAlign = "bottom";
	xOffset = 0;
	yOffset = 0;
	level.doublexphud = newHudElem();
	level.doublexphud.alignX = xAlign;
	level.doublexphud.alignY = yAlign;
	level.doublexphud.horzAlign = xAlign;
	level.doublexphud.vertAlign = yAlign;
	level.doublexphud.x = xOffset;
	level.doublexphud.y = yOffset;
	level.doublexphud.fontscale = 1.4;
	level.doublexphud.alpha = 1;
	level.doublexphud.color = (1,1,1);
    level.doublexphud.glowalpha = 1;
    level.doublexphud.glowcolor = (1,1,1);
	level.doublexphud.foreground = true;
	level.doublexphud.archived = false;
	level.doublexphud.hidewheninmenu = true;
	level.doublexphud setText("^7Double XP: ?/?");
}

updateDoubleXpHud()
{
	if(!isDefined(level.doublexphud))
		return;
	
	if(isDefined(level.freeRun) && level.freeRun)
		level.doublexphud setText("");
	else if(level.doublexp == true)
	{
		level.doublexphud setText("^7Double XP: ^2activated!^7");
		level.doublexphud.glowcolor = (0,1,0);
	}
	else
	{
		level.doublexphud setText("^7Double XP: ^1" + level.currentPlayerAmount + "/" + level.requiredPlayerAmount + "^7");
		level.doublexphud.glowcolor = (1,0,0);
	}
}

deleteDoubleXpHud()
{
	if(isDefined(level.doublexphud))
		level.doublexphud destroy();
}