////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GWClusterEvent.as
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

	public class GWClusterEvent extends Event
	{
		public var value:Object;
		//public var data:Object;
		
		public static var C_ADD:String = "c_add";
		public static var C_REMOVE:String = "c_remove";
		public static var C_POINT_ADD:String = "c_point_add";
		public static var C_POINT_REMOVE:String = "c_point_remove";
		
		public static var C_TRANSLATE:String = "c_translate";
		public static var C_ROTATE:String = "c_rotate";
		public static var C_SEPARATE:String = "c_separate";
		public static var C_RESIZE:String = "c_resize";
		
		public static var C_ACCELERATE:String = "c_accelerate";
		//public static var C_JOLT:String = "c_jolt";
		//public static var C_SPLIT:String = "c_split";
		//public static var C_MERGE:String = "c_merge";
	
		

		public function GWClusterEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			value = data;
		}

		override public function clone():Event
		{
			return new GWClusterEvent(type, value, bubbles, cancelable); // add data object
		}

	}
}