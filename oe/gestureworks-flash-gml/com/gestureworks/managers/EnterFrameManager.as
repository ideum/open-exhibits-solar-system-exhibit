////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    EnterFrameManager.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.managers 
{
	/**
	 * ...
	 * @author  
	 */
	
	import flash.events.Event;
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.GestureGlobals;
	
	
	public class EnterFrameManager 
	{		
		gw_public static function initialize():void
		{
			GestureWorks.application.addEventListener(Event.ENTER_FRAME, enterframeHandler);
		}
		
		public static function close():void
		{
			GestureWorks.application.removeEventListener(Event.ENTER_FRAME, enterframeHandler);
		}
		
		private static var prevTime:Number = 0;
		
		private static function enterframeHandler(event:Event):void
		{						
			GestureWorks.application.dispatchEvent(new GWEvent(GWEvent.ENTER_FRAME));
			
			//GestureGlobals.frameID +=1;
		}
		
	}
}