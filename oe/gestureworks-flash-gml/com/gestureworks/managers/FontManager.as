////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    FontManager.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.managers
{
	import flash.text.Font;
	import fonts.OpenSansBold;
	import fonts.OpenSansItalic;
	import fonts.OpenSansRegular;
	
	public class FontManager 
	{				
		Font.registerFont(OpenSansRegular);	
		
		Font.registerFont(OpenSansItalic); 
		
		Font.registerFont(OpenSansBold); 
	}
}