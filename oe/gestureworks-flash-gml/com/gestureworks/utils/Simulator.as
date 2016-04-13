////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    Simulator.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils 
{
	import com.gestureworks.core.*;
	import com.gestureworks.managers.*;
	
	public class Simulator 
	{		
		gw_public static function initialize():void
		{	
			MouseManager.gw_public::initialize();		
			KeyListener.gw_public::initialize();		
		}
		
		gw_public static function deInitialize():void 
		{
			MouseManager.gw_public::deInitialize();
			KeyListener.gw_public::deInitialize();
		}
	}
}