////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    ArrangePoints.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils 
{
	import flash.events.TouchEvent;
	
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.gw_public;
		
	public class ArrangePoints 
	{
		
		public static function arrangePointArray(event:TouchEvent):void
		{
			var pointObject:Object = GestureGlobals.gw_public::points[event.touchPointID];
			
			//trace("arrange function splice delete",pointObject.id,event.touchPointID,pointObject.object);
			
			pointObject.object.pointArray.splice(pointObject.id, 1);
			pointObject.object.pointCount--;

			for (var i:int = 0; i < pointObject.object.pointArray.length; i++)
			{
				pointObject.object.pointArray[i].id = i;
				
				// not sure if use
				//GestureGlobals.gw_public::points[pointObject.object.pointArray[i].touchPointID].id=i;
			}
		}
		
	}
}