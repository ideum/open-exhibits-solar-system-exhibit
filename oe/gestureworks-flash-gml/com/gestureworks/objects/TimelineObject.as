////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TimelineObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	import com.gestureworks.objects.FrameObject;
	
	public class TimelineObject extends Object 
	{
		// ID
		public var id:int;
		
		//
		public var timelineOn:Boolean = false;

		//
		public var timelineInit:Boolean = false;
		
		//INIT EVENT TYPES //////////////////////////////////////////////////////////////
		// add touch point events
		public var pointEvents:Boolean = false;

		// add touch cluster events
		public var clusterEvents:Boolean = false;

		// add touch point events
		public var gestureEvents:Boolean = false;

		// add touch transform events
		public var transformEvents:Boolean = false;
		
		//frame object
		private var _frame:FrameObject = new FrameObject();
		public function get frame():FrameObject { return _frame; }
		public function set frame(value:FrameObject):void {
			_frame = value;
		}

		// NEEEDS TO BE VECTOR
		// timeline history
		//public var history:Array = new Array();
		public var history:Vector.<FrameObject> = new Vector.<FrameObject>();

	}
}