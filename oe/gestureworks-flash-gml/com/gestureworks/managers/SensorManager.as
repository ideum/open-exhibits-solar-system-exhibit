////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TouchManager.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.managers
{
	import flash.sensors.Accelerometer;
	import flash.utils.Dictionary;
	import flash.events.TouchEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.system.System;
	
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.GestureWorksCore;
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.core.GML;
	
	import com.gestureworks.utils.ArrangePoints;
	import com.gestureworks.managers.PointHistories;
	import com.gestureworks.events.GWEvent;
	
	import com.gestureworks.objects.PointObject;
	import com.gestureworks.objects.TouchObject;
	import com.gestureworks.managers.PointHistories;
	import com.gestureworks.utils.Simulator;
	
	// accelerometer
	import flash.events.AccelerometerEvent;
    import flash.sensors.Accelerometer;
	
	import com.gestureworks.core.TouchSprite;
	
	public class SensorManager
	{	
		public static var act:Accelerometer; 
		public static var ms:TouchSprite;
		
		// initializes touchManager
		gw_public static function initialize():void
		{	
			
			if (Accelerometer.isSupported)
            {
				trace("sensor manager init")
				act = new Accelerometer();
				act.addEventListener(AccelerometerEvent.UPDATE, accUpdateHandler);
				
				// create gloabal motion sprite
				ms = new TouchSprite();
			
			}
		}
		
		public static function accUpdateHandler(event:AccelerometerEvent):void
        {
			//trace("pushing accel data")
			
			var act_vector:Vector.<Number> = new Vector.<Number>
				act_vector[0] = event.timestamp;
				act_vector[1] = event.accelerationX;
				act_vector[2] = event.accelerationY;
				act_vector[3] = event.accelerationZ;
				
			//push sensor data to cluster object
			ms.cO.sensorArray = act_vector	
			// update cluster analysis
			//ms.updateSensorClusterAnalysis()
        }
		
	}
}