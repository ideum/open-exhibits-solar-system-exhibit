////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GWInteractionEvent.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.events
{
	import com.gestureworks.core.GestureWorks;
	import flash.events.Event;
	import flash.utils.Dictionary;


	public class GWInteractionEvent extends Event
	{
		public var value:Object;
		public static const INTERACTION_BEGIN : String = "gwInteractionBegin";
		public static const INTERACTION_END : String = "gwInteractionEnd"
		public static const INTERACTION_UPDATE : String = "gwInteractionUpdate"
	
		public function GWInteractionEvent(type:String, data:Object, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			value = data;
		}
		
		override public function clone():Event
		{
			return new GWInteractionEvent(type, bubbles, cancelable);
		}

	}
}