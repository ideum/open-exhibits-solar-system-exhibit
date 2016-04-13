////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GWTouchEvent.as
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


	public class GWMotionEvent extends Event
	{
		public var value:Object;
		public static const MOTION_BEGIN : String = "gwMotionBegin";
		public static const MOTION_END : String = "gwMotionEnd"
		public static const MOTION_MOVE : String = "gwMotionMove"
	
		public function GWMotionEvent(type:String, data:Object, bubbles:Boolean = true, cancelable:Boolean = false)//, touchPointID:int = 0, isPrimaryTouchPoint:Boolean = false, localX:Number = NaN, localY:Number = NaN, sizeX:Number = NaN, sizeY:Number = NaN, pressure:Number = NaN, relatedObject:InteractiveObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, commandKey:Boolean = false, controlKey:Boolean = false)
		{
			super(type, bubbles, cancelable);
			value = data;
		}
		
		override public function clone():Event
		{
			return new GWMotionEvent(type, bubbles, cancelable);
		}

	}
}