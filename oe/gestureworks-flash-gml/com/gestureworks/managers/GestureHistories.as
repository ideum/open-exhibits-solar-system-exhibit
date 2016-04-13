////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GestureHistories.as
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
	import com.gestureworks.objects.GestureObject;
	
	public class GestureHistories 
	{		
		//////////////////////////////////////////////////////
		// based on a cluster move event
		//////////////////////////////////////////////////////
		
		public static function historyQueue(ClusterID:Object):void//event:ClusterEvent
		{
			//gets history values from history array inside cluster object
			var history:Array = GestureGlobals.gw_public::gestures[ClusterID].history;
			var gestureObject:GestureObject = GestureGlobals.gw_public::gestures[ClusterID]
		
			history.unshift(historyObject(gestureObject));
							
			if (history.length-1>=GestureGlobals.pointHistoryCaptureLength)
			{
				history.pop();
			}
		}
		
		// loads history object and returns value.
		public static function historyObject(gestureObject:Object):Object
		{
			//MUST CHNAGE TO GESTURE OBJECT 
			var object:Object = new Object();
				
				///////////////////////////////////////////////
				// core native properties absolute
				////////////////////////////////////////////////
				//object.x = gestureObject.x;
				//object.y = gestureObject.y;
				//object.width = gestureObject.width;
				//object.height = gestureObject.height;
				//object.radius = gestureObject.radius;
				//object.orientation = gestureObject.orientation;
				//object.rotation = gestureObject.rotation;
				//object.separation = gestureObject.separation;
				//object.thumbID = gestureObject.thumbID;
				//object.alpha
				
				/////////////////////////////////////////////////
				// core gesture events
				/////////////////////////////////////////////////
				//object.start = gestureObject.start;
				//object.complete = gestureObject.complete;
				//object.release = gestureObject.release;
				
				// gesture object lists
				//object.pOList = gestureObject.pOList;
				
			//trace("gesture hist",object.dx,gestureObject.dx );
			return object;
		}
		
	}

}