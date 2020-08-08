//
// Plugin name: Roll The Dice
// Author: quaK
//

#include braxi\_common;
#include braxi\_dvar;
#include maps\mp\gametypes\_hud_util;

init()
{
	addDvar( "pi_rtd_enable", "plugin_rtd_enable", 1, 0, 1, "int" ); 				// 1 == enable 0 == disable
	addDvar( "pi_rtd_hudmsgs", "plugin_rtd_hudmessages", 1, 0, 1, "int" ); 			// 1 == HUD, 0 == iPrintLnBold
	
	if( level.dvar["pi_rtd_enable"] == 0 )
		return;
	
	level.rtd_weapon = "rtd_mp";
	
	precacheItem(level.rtd_weapon);
	
	precacheWeapons();
	
	thread onPlayerSpawn();
}

onPlayerSpawn()
{
	while(1)
	{
		level waittill("jumper", player);
		player thread rtd_init();
	}
}

onFreeRun( weapon )
{
	self endon("rtd_pressed");
	level waittill("round_freerun");
	self giveWeapon( weapon );
}

rtd_init()
{
	self endon("disconnect");
	self endon("death");
	
	/*if( level.freeRun )
		return;*/	
	
	if( isDefined(self.rtd_rolled) && self.rtd_rolled == true || self.pers["team"] != "allies" )
		return;
	
	weapon = level.rtd_weapon;
	//self SetOffhandPrimaryClass( "other" );
	self setActionSlot( 4, "weapon", weapon );
	self giveWeapon( weapon );
	self thread onFreeRun( weapon );
	
	while( game["state"] != "playing" )
		wait .1;
	
	while( self getCurrentWeapon() != weapon )
	{
		wait 0.5;
		continue;
	}
	wait 0.5;
	
	if( self hasWeapon( weapon ) == false )
		return;
	
	currentweapon = self getCurrentWeapon();
	
	if( currentweapon == weapon || currentweapon == "none" )
		currentweapon = self getWeaponsListPrimaries()[0];
	
	self switchToWeapon( weapon );
	//wait 1.5;
	self takeWeapon( weapon );
	self switchToWeapon( currentweapon );
	
	self thread rtd();
}

rtd()
{
	self endon("disconnect");
	self endon("death");
	
	if( self.sessionstate != "playing" )
		return;
	
	msg = "^2>>^6Roll The Dice Activated^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread oben(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
	
	wait 4;
	
	if( self.pers["team"] == "axis" )
	{
		msg = "^2>>^6No Roll The Dice for the activator!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		return;
	}
	if( self.pers["team"] == "allies" )
	{
		if( level.trapsDisabled )
		{
			msg = "^2>>^6No Roll The Dice on a free run!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
			return;
		}
		if( !isDefined( self.rtd_rolled ) || self.rtd_rolled == false )
		{
			self thread activated();
			self.rtd_rolled = true;
			return;
		}
		else if( isDefined( self.rtd_rolled ) && self.rtd_rolled == true )
		{
			msg = "^2>>^6You have already Rolled The Dice!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
			return;
		}
	}
}

activated()
{
	r = randomIntRange(0,3);
	
	if( r == 0 )
		self randomWeapon();
	else if( r == 1 )
		self randomPerk();
	else if( r == 2 )
		self randomStuff();
	else
		self iPrintLnBold("Rtd fuk'd");
}

randomWeapon()
{
	weapons = getWeapons();
	r = randomIntRange(0, weapons.size);
	weapon = weapons[r];
	
	temp_weaponName = strTok(weapon, "_");
	if(temp_weaponName.size == 3)
		temp_weaponName = temp_weaponName[0] + " " + temp_weaponName[1];
	else
		temp_weaponName = temp_weaponName[0];
	
	//temp_weaponName = braxi\_common::toUpper(temp_weaponName);
		
	weaponName = temp_weaponName;
	
	self giveWeapon( weapon );
	self giveMaxAmmo( weapon );
	self switchToWeapon( weapon );
	
	msg = "^2>>^6You got weapon ^1 " + weaponName + "^6!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
}

randomPerk()
{
	perks = getPerks();
	r = randomIntRange(0, perks.size);
	perk = perks[r];
	
	perkStuff = strTok(perk, ":");
	
	perkName = perkStuff[0];
	perkAblilities = [];
	for(i=1;i<perkStuff.size;i++)
		perkAblilities[perkAblilities.size] = perkStuff[i];
	
	for(i=0;i<perkAblilities.size;i++)
		self maps\mp\perks\_perks::givePerk(perkAblilities[i]);
	
	self openMenu("perk_display");
	msg = "^2>>^6You got perk ^1 " + perkName + "^6!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
}

randomStuff()
{
	r = randomIntRange(0,9);
	
	switch( r )
	{
		case 0:
			// Extra Life
			self thread braxi\_mod::giveLife();
			msg = "^2>>^6You got an extra ^2life^6!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
		case 1:
			// WTF
			self thread wtf();
			msg = "^2>>^6You got ^1WTF?!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
		case 2:
			// Jetpack
			self thread jetpack();
			msg = "^2>>^6You got a ^3Jetpack^6!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
		case 3:
			// Frozen
			self thread freeze();
			msg = "^2>>^6You got ^4Frozen^6!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
		case 4:
			// Nuke Bullets
			self thread ExplosiveBullets( 3 );
			msg = "^2>>^6You got 3 ^1Explosive ^6Bullets!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
		case 5:
			// Clone
			self thread Clone();
			msg = "^2>>^6You got ^3Clones^6!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
		case 6:
			// Double Health
			self thread Health();
			msg = "^2>>^6You got ^3Double ^2Health^6!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
		case 7:
			//XP
			self thread randomXP();
		break;
		default:
			// Nothing
			msg = "^2>>^6You got... Nothing!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
		break;
	}
}

randomXP()
{
	prizes = getXpPrizes();
	r = randomIntRange(0, prizes.size);
	prize = int(prizes[r]);
	
	self braxi\_rank::giveRankXp("", prize);
	
	msg = "^2>>^6You got ^1 " + prize + "^6 XP!^2<<"; if( level.dvar["pi_rtd_hudmsgs"] ) self thread unten2(msg,(0.0, 0, 1.0)); else iPrintLnBold(msg);
}

getPerks()
{
if(!isDefined(level.rtd_perks))
{
raw_perks = 
"Sleight of Hand Pro:specialty_fastreload:specialty_quickdraw,Stopping Power Pro:specialty_bulletdamage:specialty_armorpiercing,Steady Aim Pro:specialty_bulletaccuracy:specialty_holdbreath,Ninja Pro:specialty_heartbreaker:specialty_quieter";

perks = strTok(raw_perks, ",");
level.rtd_perks = perks;
}
return level.rtd_perks;
}

getXpPrizes()
{
if(!isDefined(level.rtd_xpPrizes))
{
raw_prizes =
"500,1000,2000,4000,8000";
prizes = strTok(raw_prizes, ",");
level.rtd_xpPrizes = prizes;
}
return level.rtd_xpPrizes;
}

getWeapons()
{
if(!isDefined(level.rtd_weapons))
{
raw_weapons = "beretta_mp,beretta_silencer_mp,beretta_tactical_mp,usp_mp,usp_silencer_mp,usp_tactical_mp,deserteagle_mp,deserteagle_tactical_mp,deserteaglegold_mp,coltanaconda_mp,coltanaconda_tactical_mp,glock_mp,glock_silencer_mp,beretta393_mp,beretta393_silencer_mp,mp5k_mp,mp5k_silencer_mp,pp2000_mp,uzi_mp,p90_mp,kriss_mp,ump45_mp,tmp_mp,ak47_mp,m16_mp,m4_mp,fn2000_mp,masada_mp,famas_mp,fal_mp,scar_mp,tavor_mp,barrett_mp,wa2000_mp,m21_mp,cheytac_mp,ranger_mp,model1887_mp,striker_mp,aa12_mp,m1014_mp,spas12_mp,rpd_mp,sa80_mp,mg4_mp,m240_mp,aug_mp";
weapons = strTok(raw_weapons, ",");
level.rtd_weapons = weapons;
}
return level.rtd_weapons;
}

precacheWeapons()
{
	weapons = getWeapons();
	for(i = 0; i < weapons.size; i++)
	{
		precacheItem(weapons[i]);
	}
}

//HUD

oben(text1,glowColor)
{
	self notify("newoben");
	self endon("newoben");
	self endon("disconnect");
	
	if(isDefined(self.oben))
		self.oben destroy();
	
	self.oben = createText("default",2,"","",-200,-70,1,10,text1);
	self.oben.glowAlpha = 1;
	self.oben.glowColor = glowColor;
	//self.oben setPulseFX(20,4900,1500);
	self.oben hudmove(7,1600);
	wait 8;
	self.oben destroy();
}

unten(text2,glowColor)
{
	self notify("newunten");
	self endon("newunten");
	self endon("disconnect");
	
	if(isDefined(self.unten))
		self.unten destroy();
	
	self.unten = createText("default",2,"","",1200,-50,1,10,text2);
	self.unten.alignX = "right";
	self.unten.glowAlpha = 1;
	self.unten.glowColor = glowColor;
	//self.unten setPulseFX(140,4900,1500);
	self.unten hudmove(6,-1700);
	wait 7;
	self.unten destroy();
}

unten2(text2,glowColor)
{
	self notify("newunten2");
	self endon("newunten2");
	self endon("disconnect");
	
	if(isDefined(self.unten2))
		self.unten2 destroy();
	
	self.unten2 = self createText("default",2,"","",1000,-50,1,10,text2);
	self.unten2.alignX = "center";
	self.unten2.glowAlpha = 1;
	self.unten2.glowColor = glowColor;
	self.unten2 setPulseFX(50,4900,600);
	self.unten2 hudmove(4,-1600);
	wait 5;
	self.unten2 destroy();
}

hudmove(time,x,y)
{
	self moveOverTime(time);
	
	self.x += x;
	self.y += y;
}

createText(font,fontscale,align,relative,x,y,alpha  ,sort,text)
{
	self.hudText = self createFontString(font,fontscale);
	self.hudText setPoint(align,relative,x,y);
	self.hudText.alpha = alpha;
	self.hudText.sort = sort;
	self.hudText setText(text);
	return self.hudText;
}

// STUFF

wtf()
{
	self endon( "disconnect" );
	self endon( "death" );

	self playSound( level.sounds["sfx"]["wtf"] );
	
	wait 0.8;

	if( !self isActuallyAlive() )
		return;

	playFx( level.fx["bombexplosion"], self.origin );
	//self doDamage( self, self, self.health+1, 0, "MOD_EXPLOSIVE", "none", self.origin, self.origin, "none" );
	self suicide();
}

jetpack()
{
self endon("death");
jetpackAmount = 40;
self.jetpack=jetpackAmount;
JETPACKBACK = createPrimaryProgressBar( -275 );
JETPACKBACK.bar.x = 40;
JETPACKBACK.x = 100;
JETPACKTXT = createPrimaryProgressBarText( -275 );
JETPACKTXT.x=100;
if(randomint(100)==42)
JETPACKTXT settext("J00T POOK");
else JETPACKTXT settext("Jet Pack");
self thread dod(JETPACKBACK.bar,JETPACKBACK,JETPACKTXT, true);
self attach("projectile_hellfire_missile","tag_stowed_back");
while(self.jetpack>0)
{
if(self usebuttonpressed())
{
self playsound("melee_knife_hit_watermelon");
self setstance("crouch");
//foreach(fx in level.fx)
//playfx(fx,self gettagorigin("j_spine4"));
earthquake(.15,.2,self gettagorigin("j_spine4"),50);
self.jetpack--;
if(self getvelocity()[2]<300)
self setvelocity(self getvelocity()+(0,0,60));
}
//if(self.jetpack<80 &&!self usebuttonpressed())
//self.jetpack++;
JETPACKBACK updateBar(self.jetpack/jetpackAmount);
JETPACKBACK.bar.color=(1,self.jetpack/jetpackAmount,self.jetpack/jetpackAmount);
wait .05;
}
self thread dod(JETPACKBACK.bar,JETPACKBACK,JETPACKTXT);
}
dod(a,b,c, waittill_bool)
{
if(isDefined(waittill_bool) && waittill_bool == true)
self waittill("death");
if(isDefined(a)) a destroy();
if(isDefined(b)) b destroy();
if(isDefined(c)) c destroy();
}

freeze()
{
self endon("death");
self endon("disconnect");
self iPrintLnBold("^1You are frozen for 10sec!");
self freezeControls(true);
wait(10);
self iPrintLnBold("^1You can move now!");
self freezeControls(false); 
}

ExplosiveBullets( amount )
{
	self endon("death");
	self endon("explblt_stop");
	
	if(!isDefined(level.explblt))
		level.explblt = loadFX("props/barrelExp");
	
	weapon = "spas12_mp";
	self giveWeapon( weapon );
	self switchToWeapon( weapon );
	
	self thread ExplosiveBulletsStop( weapon );

	while ( amount > 0 )
	{
		self waittill("weapon_fired");
		if( self getCurrentWeapon() != "spas12_mp" )
			continue;
		
		my = self getTagOrigin("j_head");
		trace = bulletTrace(my, my + anglesToForward(self getPlayerAngles())*100000,true,self)["position"];

		obj = spawn("script_model", trace);
		obj setModel("tag_origin");
		obj playSound("artillery_impact");
		playFX( level.explblt,obj.origin );
		radiusDamage( obj.origin, 100, 150, 75, self );
		earthquake( 1, 1, obj.origin, 100 );

		obj delete();
		
		amount--;
		
		wait 0.5;
	}
	self takeWeapon( weapon );
	weapons = self getWeaponsListPrimaries();
	self switchToWeapon(weapons[0]);
	
	self notify("explblt_stop");
}

ExplosiveBulletsStop( weapon )
{
	self endon("death");
	self endon("disconnect");
	
	while( self hasWeapon( weapon ) )
		wait .1;
	
	self notify("explblt_stop");
}

Clone()
{	
	self endon("death");
	level endon( "endround" );
	
	while( self.sessionstate == "playing")
	{
		if(self getStance() == "stand" && isDefined( self.clon ))
		{
			for(j=0;j<8;j++)
			{
				if(isDefined( self.clon[j] ))
					self.clon[j] hide();
			}
				
			self notify("newclone");
		}
		else
		{
			self notify("newclone");
			self thread hideClone();

			while(self getStance() != "stand")
				wait .05;
		}
		wait .05;
	}
}
hideClone()
{
	self endon("disconenct");
	self endon("newclone");
	level endon( "endround" );
	self.clon = [];
	
	for(k=0;k<8;k++)
		self.clon[k] = self clonePlayer(10);
				
	while( self.sessionstate == "playing" )
	{
		if(isDefined(self.clon[0]))
		{
			self.clon[0].origin = self.origin + (0, 60, 0);
			self.clon[1].origin = self.origin + (-41.5, 41.5, 0);
			self.clon[2].origin = self.origin + (-60, 0, 0);
			self.clon[3].origin = self.origin + (-41.5, -41.5, 0);
			self.clon[4].origin = self.origin + (0, -60, 0);
			self.clon[5].origin = self.origin + (41.5, -41.5, 0);
			self.clon[6].origin = self.origin + (60, 0, 0);
			self.clon[7].origin = self.origin + (41.5, 41.5, 0);
			
			for(j=0;j<8;j++)
				self.clon[j].angles = self.angles;
		}
		wait .05;
	}
	
	for(i=0;i<8;i++)
	{
		if(isDefined(self.clon[i]))
			self.clon[i] delete();
	}
}

Health()
{
self.maxhealth = 200;
self.health = self.maxhealth;
}
