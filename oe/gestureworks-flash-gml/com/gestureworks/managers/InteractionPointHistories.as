////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    ClusterHistories.as
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
	import com.gestureworks.events.GWInteractionEvent;
	import com.gestureworks.objects.InteractionPointObject;
	import flash.geom.Vector3D;
	
	
	public class InteractionPointHistories 
	{
		//////////////////////////////////////////////////////
		// based on a cluster move event
		//////////////////////////////////////////////////////
		
		public static function historyQueue(event:GWInteractionEvent):void//event:ClusterEvent
		{
			// define cluster to update
			var ipo:InteractionPointObject = GestureGlobals.gw_public::interactionPoints[event.value.interactionPointID];
			
			
			
			if (ipo) 
			{
				// push object into history vector 
				ipo.history.unshift(historyObject(ipo));
				
				// remove last object if overflows
				if (ipo.history.length-1>=GestureGlobals.motionHistoryCaptureLength)
				{
					ipo.history.pop();
				}
			}
		}
		
		
		// loads history object and returns value.
		public static function historyObject(ipo:InteractionPointObject):Object
		{
			//var FrameID:int = 0;
			
			var object:InteractionPointObject = new InteractionPointObject();
				//object = ipo;
				object.position = ipo.position;
				object.direction = ipo.direction;
				object.normal = ipo.normal;
				object.rotation = ipo.rotation;
				object.handID =  ipo.handID;
				object.type = ipo.type;
				
				// advanced ip properties
				object.flatness = ipo.flatness;
				object.orientation = ipo.orientation;
				object.splay = ipo.splay;
				object.fn = ipo.fn;
				object.fist = ipo.fist;
				
			//	trace(ipo.history.length)
				
				// ADVANCED MOTION PROEPRTIES
				if (ipo.history.length>1)
				{
					//trace(ipo.position.x,ipo.history[1].position.x,ipo.history[2].position.x)
					object.velocity = new Vector3D(ipo.position.x - ipo.history[1].position.x,ipo.position.y - ipo.history[1].position.y,ipo.position.z - ipo.history[1].position.z);
					object.acceleration = new Vector3D(ipo.velocity.x - ipo.history[1].velocity.x, ipo.velocity.y - ipo.history[1].velocity.y, ipo.velocity.z - ipo.history[1].velocity.z);
					object.jolt = new Vector3D(ipo.acceleration.x - ipo.history[1].acceleration.x,ipo.acceleration.y - ipo.history[1].acceleration.y,ipo.acceleration.z - ipo.history[1].acceleration.z);
				}
				//trace("interaction point history push")

			return object;
		}
		
	}

}