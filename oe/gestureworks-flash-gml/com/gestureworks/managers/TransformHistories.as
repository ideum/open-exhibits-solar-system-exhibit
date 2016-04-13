////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TransformHistories.as
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
	import com.gestureworks.objects.TransformObject;
	
	public class TransformHistories 
	{
		//////////////////////////////////////////////////////
		// based on a cluster move event
		//////////////////////////////////////////////////////
		
		public static function historyQueue(ClusterID:Object):void//event:ClusterEvent
		{
			var history:Array = GestureGlobals.gw_public::transforms[ClusterID].history;
			var transformObject:TransformObject = GestureGlobals.gw_public::transforms[ClusterID]
		
			history.unshift(historyObject(transformObject));
			
			if (history.length-1>=GestureGlobals.transformHistoryCaptureLength)
			{
				history.pop();
			}
		}
		
		// loads history object and returns value.
		public static function historyObject(transformObject:Object):Object
		{
			var object:Object = new Object();
				
				// native properties
				object.x = transformObject.x;
				object.y = transformObject.y;
				object.w = transformObject.width;
				object.h = transformObject.height;
				object.rotation = transformObject.rotation;
				object.scaleX = transformObject.scaleX;
				object.scaleY = transformObject.scaleY;
				
				// first order primary deltas
				object.dx = transformObject.dx;
				object.dy = transformObject.dy;
				object.ds = transformObject.ds;
				object.dsx = transformObject.dsx;
				object.dsy = transformObject.dsy;
				object.dtheta = transformObject.dtheta;
				
				//core cluster events
				//object.start = transformObject.start;
				//object.complete = transformObject.complete;
				//object.transform = transformObject.transform;
				//object.translate = transformObject.translate;
				//object.rotate = transformObject.rotate;
				//object.scale = transformObject.separate;

			return object;
		}
		
	}

}