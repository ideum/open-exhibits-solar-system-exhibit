////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    CMLEvent.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.events
{
	import flash.events.Event;

	public class CMLEvent extends Event
	{		
		public static var COMPLETE:String = "complete";
		public static var CHANGE:String = "change";
		
		public var id:String;
		
		public function CMLEvent(type:String, _id:String=null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			id = _id;
		}

		override public function clone():Event
		{
			return new CMLEvent(type, id, bubbles, cancelable);
		}
	}
}