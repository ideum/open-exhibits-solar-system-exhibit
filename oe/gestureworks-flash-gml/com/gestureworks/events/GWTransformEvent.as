////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GWTransformEvent.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.events
{
	import flash.events.Event;
	import com.gestureworks.core.GestureGlobals;

	public class GWTransformEvent extends Event
	{
		public var value:Object;

		public static var T_TRANSLATE:String = "t translate";
		public static var T_ROTATE:String = "t rotate";
		public static var T_SCALE:String = "t scale";
		public static var T_TRANSFORM:String = "t transform";
		public static var T_RESIZE:String = "t resize";
		
		public static var T_COMPLETE:String = "t complete";
		public static var T_START:String = "t start";
		
		//public static var T_ROTATE_X:String = "t 3d rotate x";
		//public static var T_ROTATE_Y:String = "t 3d rotate y";
		//public static var T_ROTATE_Z:String = "t 3d rotate z";
		
		

		public function GWTransformEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);

			value=data;
		}

		override public function clone():Event
		{
			return new GWTransformEvent(type, value, bubbles, cancelable);
		}

	}
}