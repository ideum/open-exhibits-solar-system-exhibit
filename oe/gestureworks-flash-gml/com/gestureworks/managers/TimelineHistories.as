////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TimelineHistories.as
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
	 * @author Paul Lacey
	 */
	
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.objects.TimelineObject;
	import com.gestureworks.objects.FrameObject;
	
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.events.GWClusterEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	
	public class TimelineHistories 
	{
		//////////////////////////////////////////////////////
		// based on a cluster move event
		//////////////////////////////////////////////////////
		
		public static function historyQueue(ClusterID:Object):void//event:ClusterEvent
		{
			//trace("capturing timline histories");
			
			var tiO:TimelineObject = GestureGlobals.gw_public::timelines[ClusterID];
			var history:Vector.<FrameObject> = tiO.history;
			
			history.unshift(historyObject(tiO.frame));
			//history.unshift(tiO.frame); //??
			
			
			
			if (history.length-1>=GestureGlobals.timelineHistoryCaptureLength)
			{
				history.pop();
			}
		}
		
		// loads history object and returns value.
		public static function historyObject(frame:FrameObject):Object
		{
			//trace("in hist");
			var object:FrameObject = PoolManager.frameObject;
			//var object:FrameObject = new FrameObject;
				
				var ten:int = frame.pointEventArray.length
				var gen:int = frame.gestureEventArray.length
				//trace("arrays", ten,gen);
				//object.pointEventArray = frame.pointEventArray;
				//object.gestureEventArray = frame.gestureEventArray;
				
				
				object.pointEventArray = new Vector.<GWTouchEvent>;
				object.gestureEventArray = new Vector.<GWGestureEvent>();
				
				for (var i:uint = 0; i < ten; i++) 
				{
					object.pointEventArray[i] = frame.pointEventArray[i];
				}
				
				for (var j:uint = 0; j < gen; j++) 
				{
					object.gestureEventArray[j] = frame.gestureEventArray[j];
				}
				
				
			return object;
		}
		
	}

}