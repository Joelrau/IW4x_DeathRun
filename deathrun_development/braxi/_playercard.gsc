/*

///////////////////////////////////////////////////////////////
////|         |///|        |///|       |/\  \/////  ///|  |////
////|  |////  |///|  |//|  |///|  |/|  |//\  \///  ////|__|////
////|  |////  |///|  |//|  |///|  |/|  |///\  \/  /////////////
////|          |//|  |//|  |///|       |////\    //////|  |////
////|  |////|  |//|         |//|  |/|  |/////    \/////|  |////
////|  |////|  |//|  |///|  |//|  |/|  |////  /\  \////|  |////
////|  |////|  |//|  | //|  |//|  |/|  |///  ///\  \///|  |////
////|__________|//|__|///|__|//|__|/|__|//__/////\__\//|__|////
///////////////////////////////////////////////////////////////

 ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗
██╔═══██╗██║   ██║██╔══██╗██║ ██╔╝
██║   ██║██║   ██║███████║█████╔╝ 
██║▄▄ ██║██║   ██║██╔══██║██╔═██╗ 
╚██████╔╝╚██████╔╝██║  ██║██║  ██╗
 ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
	
	Original mod by: BraXi;
	Edited mod by: quaK;
	
*/

init()
{
	precacheShader( "black" );
	while( 1 )
	{
		level waittill( "player_killed", victim, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon );
		
		if( !isDefined( attacker ) || attacker == victim || !isPlayer( attacker ) )
			continue;
			
		if( level.dvar["playerCardsMW2"] == 1 )
		{
			// MW2 PLAYERCARD
			attacker SetCardDisplaySlot( victim, 8 );
			attacker openMenu( "youkilled_card_display" );

			victim SetCardDisplaySlot( attacker, 7 );
			victim openMenu( "killedby_card_display" );
			
			return;
		}
		
		// BRAXI PLAYERCARD
		thread showPlayerCard( attacker, victim );
	}
}

showPlayerCard( attacker, victim )
{
	if( !level.dvar["playerCards"] || attacker == victim || !isPlayer( attacker ) )
		return;

	level notify( "new emblem" );	// one instance at a time
	level endon( "new emblem" );

	destroyPlayerCard();
	
	logo1 = ( "spray" + attacker braxi\_stats::getStats("dr_spray") + "_menu" );
	logo2 = ( "spray" + victim braxi\_stats::getStats("dr_spray") + "_menu" );

	level.playerCard[0] = newHudElem( level );
	level.playerCard[0].x = 170;
	level.playerCard[0].y = 350;
	level.playerCard[0].alpha = 0;
	level.playerCard[0] setShader( "black", 300, 64 );
	level.playerCard[0].sort = 990;

	//logos
	level.playerCard[1] = braxi\_mod::addTextHud( level, 0, 350, 0, "left", "top", 1.8 ); 
	level.playerCard[1] setShader( logo1, 64, 64 );
	level.playerCard[1].sort = 998;
	
	level.playerCard[2] = braxi\_mod::addTextHud( level, 640, 350, 0, "left", "top", 1.8 ); 
	level.playerCard[2] setShader( logo2, 64, 64 );
	level.playerCard[2].sort = 998;
	
	level.playerCard[3] = braxi\_mod::addTextHud( level, 320, 370, 0, "center", "top", 1.8 ); 
	level.playerCard[3] setText( attacker.name + " killed " + victim.name );
	level.playerCard[3].sort = 999;
	level.playerCard[3].color = level.color_cool_green;
	level.playerCard[3].glowColor = level.color_cool_green_glow;
	level.playerCard[3] SetPulseFX( 30, 100000, 700 );
	level.playerCard[3].glowAlpha = 0.8;

	// === animation === //

	level.playerCard[1] moveOverTime( 0.44 );
	level.playerCard[1].x = 170;
	level.playerCard[2] moveOverTime( 0.44 );
	level.playerCard[2].x = 170+300-64;

	for( i = 0; i < level.playerCard.size; i++ )
	{
		level.playerCard[i] fadeOverTime( 0.3 );

		if( i == 0 ) //hack
			level.playerCard[i].alpha = 0.5;
		else
			level.playerCard[i].alpha = 1.0;
	}
	

	wait 2.0;

	for( i = 0; i < level.playerCard.size; i++ )
	{
		level.playerCard[i] fadeOverTime( 0.8 );
		level.playerCard[i].alpha = 0;
	}
	wait 0.8;
	
	destroyPlayerCard();
}


destroyPlayerCard()
{
	if( !isDefined( level.playerCard ) || !level.playerCard.size )
		return;

	for( i = 0; i < level.playerCard.size; i++ )
		level.playerCard[i] destroy();
	level.playerCard = [];
}