		
		// character
		itemDef 
		{
			rect			330 100 220 48
			style			WINDOW_STYLE_FILLED
			border			1
			bordercolor		.6 .6 .6 .5
			forecolor		1 1 1 1
			backcolor		0 0 0 0.5
			visible			1
			decoration
		}
		itemDef
		{
			visible			1
			style			WINDOW_STYLE_FILLED 
			origin			440 135
			forecolor		1 1 1 1
			exp				text( tableLookup(CHARACTER_TABLE, 0, dvarInt("drui_character")+1, 6) )
			type			ITEM_TYPE_BUTTON 
			textfont		UI_FONT_NORMAL 
			textstyle		ITEM_TEXTSTYLE_SHADOWED 
			textalign		ITEM_ALIGN_CENTER
			textalignx		0
			textaligny		0
			textscale		0.4
			decoration
		}
		itemDef 
		{
			rect			343 100 48 48
			style			WINDOW_STYLE_SHADER
			exp				material( tableLookup(CHARACTER_TABLE, 0, dvarInt("drui_character")+1, 3) )
			border			3
			bordercolor		.4 .4 .4 .8
			forecolor		1 1 1 1
			visible			1
			decoration
		}

		// weapon
		itemDef 
		{
			rect			330 150 220 48
			style			WINDOW_STYLE_FILLED
			border			1
			bordercolor		.6 .6 .6 .5
			forecolor		1 1 1 1
			backcolor		0 0 0 0.5
			visible			1
			decoration
		}

		itemDef 
		{
			rect			335 158 64 32
			style			WINDOW_STYLE_SHADER
			exp				material( tableLookup(ITEM_TABLE, 0, dvarInt("drui_weapon")+1, 3) )
			forecolor		1 1 1 1
			visible			1
			decoration
		}

		itemDef 
		{ 
			style		WINDOW_STYLE_FILLED 
			rect		440 180 0 0 DR_BUTTON_ALIGN 
			forecolor	0.9 0.9 0.9 1.0
			exp			text( tableLookup(ITEM_TABLE, 0, dvarInt("drui_weapon")+1, 5) ) 
			type		ITEM_TYPE_BUTTON 
			textfont	UI_FONT_NORMAL 
			textstyle	ITEM_TEXTSTYLE_SHADOWED 
			textalign	ITEM_ALIGN_CENTER 
			textscale	0.4
			textalignx	0
			textaligny	0
			visible		1
			decoration
		}
		
		// knife
		itemDef 
		{
			rect			330 200 220 48
			style			WINDOW_STYLE_FILLED
			border			1
			bordercolor		.6 .6 .6 .5
			forecolor		1 1 1 1
			backcolor		0 0 0 0.5
			visible			1
			decoration
		}

		itemDef 
		{
			rect			335 200 64 48
			style			WINDOW_STYLE_SHADER
			exp				material( tableLookup(KNIFE_TABLE, 0, dvarInt("drui_knife")+1, 3) )
			forecolor		1 1 1 1
			visible			1
			decoration
		}

		itemDef 
		{ 
			style		WINDOW_STYLE_FILLED
			rect		440 230 0 0 DR_BUTTON_ALIGN
			forecolor	0.9 0.9 0.9 1.0
			exp			text( tableLookup(KNIFE_TABLE, 0, dvarInt("drui_knife")+1, 5) )
			type		ITEM_TYPE_BUTTON
			textfont	UI_FONT_NORMAL
			textstyle	ITEM_TEXTSTYLE_SHADOWED
			textalign	ITEM_ALIGN_CENTER
			textscale	0.4
			textalignx	0
			textaligny	0
			visible		1
			decoration
		}
		
		// spray
		itemDef 
		{	
			rect			486 236 64 64
			style			WINDOW_STYLE_SHADER
			exp				material( tableLookup(SPRAY_TABLE, 0, dvarInt("drui_spray")+1, 3) )
			forecolor		1 1 1 1
			visible			1
			decoration
		}

