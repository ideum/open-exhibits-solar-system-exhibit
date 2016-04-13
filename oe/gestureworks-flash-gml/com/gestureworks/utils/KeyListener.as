////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    KeyListener.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils 
{
	import flash.events.KeyboardEvent;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.gw_public;
	
	public class KeyListener 
	{
		gw_public static function initialize():void
		{
			GestureWorks.application.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			GestureWorks.application.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
		}
		
		gw_public static function deInitialize():void
		{
			GestureWorks.application.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			GestureWorks.application.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
		}
		
		private static function keyDownListener(e:KeyboardEvent):void
		{
			testForShift(e.keyCode);
		}
		
		private static function keyUpListener(e:KeyboardEvent):void
		{
			testForShift(0);
		}
		
		private static function testForShift(value:int):void
		{
			if (value==16)
			{
				GestureWorks.isShift = true;
			}
			else
			{
				GestureWorks.isShift = false;
			}
		}
		
	}
}