////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    FrameObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.events.GWClusterEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	
	public class FrameObject extends Object 
	{
		// ID
		public var id:int;
		
		///////////////////////////////////////////////
		// UPDATE TO VECTORS
		//pointEventArray
		//public var pointEventArray:Array = new Array();
		public var pointEventArray:Vector.<GWTouchEvent> = new Vector.<GWTouchEvent>;

		//clusterEventArray
		public var clusterEventArray:Vector.<GWClusterEvent> = new Vector.<GWClusterEvent>();

		//gestureEventArray
		public var gestureEventArray:Vector.<GWGestureEvent> = new Vector.<GWGestureEvent>();

		//transformEventArray
		public var transformEventArray:Vector.<GWTransformEvent> = new Vector.<GWTransformEvent>();
		//public var transformEventArray:Array = new Array();
		
		/**
		 * Resets attributes to initial values
		 */
		public function reset():void {
			id = NaN;
			pointEventArray.length = 0;			
			clusterEventArray.length = 0;			
			gestureEventArray.length = 0;	
			transformEventArray.length =0;			
		}
	}
}