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
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.ipClusterObject;
	
	public class ClusterHistories 
	{
		//////////////////////////////////////////////////////
		// based on a cluster move event
		//////////////////////////////////////////////////////
		
		public static function historyQueue(ClusterID:Object):void//event:ClusterEvent
		{
			var clusterObject:ClusterObject = GestureGlobals.gw_public::clusters[ClusterID]
			var history:Vector.<ClusterObject> = clusterObject.history;
			
			history.unshift(historyObject(clusterObject));
			
			if (history.length-1>=GestureGlobals.clusterHistoryCaptureLength)
			{
				history.pop();
			}
		}
		
		// loads history object and returns value.
		public static function historyObject(clusterObject:ClusterObject):Object
		{
			var object:ClusterObject = PoolManager.clusterObject;
				
				// native properties
				object.n = clusterObject.n;
				object.fn = clusterObject.fn;//- total motion finger number
				object.ipn = clusterObject.ipn;
				
				object.x = clusterObject.x;
				object.y = clusterObject.y;
				object.z = clusterObject.z; //-
				
				object.width = clusterObject.width;
				object.height = clusterObject.height;
				object.length = clusterObject.length;//-
				
				object.radius = clusterObject.radius;
				object.orientation = clusterObject.orientation;
				
				object.rotation = clusterObject.rotation;
				object.separation = clusterObject.separation;
				
				object.thumbID = clusterObject.thumbID; //for 2D HAND
				//object.handednes = clusterObject.handednes; //for 2D HAND
				//object.pivot_dtheta = clusterObject.pivot_dtheta; 
		
				// first order primary deltas
				object.dx = clusterObject.dx;
				object.dy = clusterObject.dy;
				object.dz = clusterObject.dz; //3d
				
				object.ds = clusterObject.ds;
				//object.d3ds = clusterObject.d3ds; //3d chang in sep
				object.dsx = clusterObject.dsx;
				object.dsy = clusterObject.dsy;
				object.dsz = clusterObject.dsz; //-3d
				
				object.dtheta = clusterObject.dtheta;
				object.dthetaX = clusterObject.dthetaX;
				object.dthetaY = clusterObject.dthetaY;
				object.dthetaZ = clusterObject.dthetaZ;
				
				// second order primary deltas
				object.ddx = clusterObject.ddx;
				object.ddy = clusterObject.ddy;
				object.ddz = clusterObject.ddz;//-3d
				
				// core cluster events
				//object.add = clusterObject.add;
				//object.remove = clusterObject.remove;
				//object.point_add = clusterObject.point_add;
				//object.point_remove = clusterObject.point_remove;
				//object.translate = clusterObject.translate;
				//object.rotate = clusterObject.rotate;
				//object.separate = clusterObject.separate;
				//object.resize = clusterObject.resize;
				//object.acclerate = clusterObject.acclerate;
				//object.jolt = clusterObject.jolt;
				//object.split= clusterObject.split;
				//object.merge = clusterObject.merge;
				
				// STANDARD CLUSTER CALCS
				object.orient_dx = clusterObject.orient_dx;
				object.orient_dy = clusterObject.orient_dy;
				//object.orient_dz = clusterObject.orient_dz; // 
				
				// STROKE DATA
				//object.path_data = clusterObject.path_data;
				
				//trace(object.path_data)
				//trace(clusterObject.pointArray[0].x)
				
				//object.handList = clusterObject.handList; 
				//MOTION FRAME DATA
				//object.motionArray = clusterObject.motionArray;
				
				//interaction DATA///////////////////////////////////////////
				object.iPointArray = clusterObject.iPointArray;
				object.iPointArray2D = clusterObject.iPointArray2D;
				
				// aggregate values
				//objec.velocity = clusterObject.velocity;
				//objec.acceleration = clusterObject.acceleration;
				//object.jolt = clusterObject.jolt;
				
				
				var sipn:int = clusterObject.subClusterArray.length
				//trace("hist", sipn);
				
				for (var i:uint = 0; i < sipn; i++) 
						{
					
					object.subClusterArray[i] = new ipClusterObject()//clusterObject.finger_cO;
				
					object.subClusterArray[i].ipn = clusterObject.subClusterArray[i].ipn;
					object.subClusterArray[i].ipnk = clusterObject.subClusterArray[i].ipnk;
					object.subClusterArray[i].ipnk0 = clusterObject.subClusterArray[i].ipnk0;
					object.subClusterArray[i].dipn = clusterObject.subClusterArray[i].dipn;
					
					object.subClusterArray[i].x = clusterObject.subClusterArray[i].x;
					object.subClusterArray[i].y = clusterObject.subClusterArray[i].y;
					object.subClusterArray[i].z = clusterObject.subClusterArray[i].z;
					
					object.subClusterArray[i].radius = clusterObject.subClusterArray[i].radius;
					object.subClusterArray[i].width = clusterObject.subClusterArray[i].width;
					object.subClusterArray[i].height = clusterObject.subClusterArray[i].height;
					object.subClusterArray[i].length = clusterObject.subClusterArray[i].length;
					
					object.subClusterArray[i].rotation = clusterObject.subClusterArray[i].rotation;
					object.subClusterArray[i].rotationX = clusterObject.subClusterArray[i].rotationX;
					object.subClusterArray[i].rotationY = clusterObject.subClusterArray[i].rotationY;
					object.subClusterArray[i].rotationZ = clusterObject.subClusterArray[i].rotationZ;
					
					object.subClusterArray[i].separation = clusterObject.subClusterArray[i].separation;
					object.subClusterArray[i].separationX = clusterObject.subClusterArray[i].separationX;
					object.subClusterArray[i].separationY = clusterObject.subClusterArray[i].separationY;
					object.subClusterArray[i].separationZ = clusterObject.subClusterArray[i].separationZ;
					
					
					object.subClusterArray[i].dx = clusterObject.subClusterArray[i].dx;
					object.subClusterArray[i].dy = clusterObject.subClusterArray[i].dy;
					object.subClusterArray[i].dz = clusterObject.subClusterArray[i].dz;
					
					object.subClusterArray[i].ds = clusterObject.subClusterArray[i].ds;
					object.subClusterArray[i].dsx = clusterObject.subClusterArray[i].dsx;
					object.subClusterArray[i].dsy = clusterObject.subClusterArray[i].dsy;
					object.subClusterArray[i].dsz = clusterObject.subClusterArray[i].dsz;
					
					object.subClusterArray[i].dtheta = clusterObject.subClusterArray[i].dtheta;
					object.subClusterArray[i].dthetaX = clusterObject.subClusterArray[i].dthetaX;
					object.subClusterArray[i].dthetaY = clusterObject.subClusterArray[i].dthetaY;
					object.subClusterArray[i].dthetaZ = clusterObject.subClusterArray[i].dthetaZ;
					
					// aggregate values
					object.subClusterArray[i].velocity = clusterObject.subClusterArray[i].velocity;
					object.subClusterArray[i].acceleration = clusterObject.subClusterArray[i].acceleration;
					object.subClusterArray[i].jolt = clusterObject.subClusterArray[i].jolt;
					
					object.subClusterArray[i].rotationList = clusterObject.subClusterArray[i].rotationList;
					
				}
				
				//SENSOR ACCELEROMETER DATA
				//object.sensorArray = clusterObject.sensorArray;
				
				
				
				//Gesture Points DATA simple timeline
				object.gPointArray = clusterObject.gPointArray;
				
				//trace("cluster history push")

			return object;
		}
		
	}

}