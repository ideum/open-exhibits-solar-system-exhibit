////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GestureGlobals.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.core
{
	import flash.utils.Dictionary;
	import com.gestureworks.utils.TouchPointID;
	import com.gestureworks.core.gw_public;
	
	/**
	 * The GestureGlobals class is the global variables class that can be accessed from all classes within.
	 * You can acess a number of hooks for development.
	 */
	public class GestureGlobals
	{		
		/**
		 * Contains a dictionary of all touchObjects available to the framework.
		 */
		gw_public static var touchObjects:Dictionary = new Dictionary();
		/**
		 * Contains a dictionary of all touch points present to the framework.
		 */
		gw_public static var points:Dictionary = new Dictionary();
		/**
		 * Contains a dictionary of all motion points present to the framework.
		 */		
		gw_public static var motionPoints:Dictionary = new Dictionary();
		/**
		 * Contains a dictionary of all interaction points present to the framework.
		 */			
		gw_public static var interactionPoints:Dictionary = new Dictionary();
		/**
		 * Contains a dictionary of all clusters present to the framework.
		 */
		gw_public static var clusters:Dictionary = new Dictionary();
		
		/**
		 * Contains a dictionary of all gestures present to the framework.
		 */
		gw_public static var gestures:Dictionary = new Dictionary();
		/**
		 * Contains a dictionary of all transforms present to the framework.
		 */
		gw_public static var transforms:Dictionary = new Dictionary();
		/**
		 * Contains a dictionary of all timelines objects present to the framework.
		 */
		gw_public static var timelines:Dictionary = new Dictionary();
		
		
		//gw_public static var pointHistory:Dictionary = new Dictionary();		
		
		
		/**
		 * min leap x value
		 */
		gw_public static var leapMinX:Number =-220;
		gw_public static var leapMaxX:Number = 220;
		gw_public static var leapMinY:Number = 350;
		gw_public static var leapMaxY:Number = 120;
		gw_public static var leapMinZ:Number = -220;
		gw_public static var leapMaxZ:Number = 220;
		
		
		public static var motionSpriteID:int = 0;//
		
		/**
		 * frameID frame stamp relative to start of application.
		 */
		public static var frameID:int = 0;//int.MAX_VALUE
		
		/**
		 * frameID frame stamp relative to start of application.
		 */
		public static var motionFrameID:uint = 0;//int.MAX_VALUE

		/**
		 * touch frame interval, time between touch processing cycles.
		 */		
		public static var touchFrameInterval:Number = 16;//60fps
		
		/**
		 * max number of tracked touch points.
		 */		
		public static var max_point_count:int = 1000;
		
		
		/**
		 * point history capture length
		 */		
		public static var pointHistoryCaptureLength:int = 8;//int.MAX_VALUE
		
		/**
		 * cluster history capture length
		 */		
		public static var clusterHistoryCaptureLength:int = 60;//int.MAX_VALUE // SET FOR 3D LEAP MOTION ANALYSIS
		
		
		/**
		 * motion history capture length
		 */
		public static var motionHistoryCaptureLength:int =120;//int.MAX_VALUE

		
		/**
		 * transform history capture length
		 */
		public static var transformHistoryCaptureLength:int = 0;//int.MAX_VALUE
		
		/**
		 * timeline history capture length
		 */
		public static var timelineHistoryCaptureLength:int = 20;//int.MAX_VALUE
		
		
		/**
		 * current GestureWorks object count
		 */
		public static var objectCount:int;



		//  gwPointID -----------------------------------------------
		/**
		 * Returns a gwPointID.
		 */
		public static function get gwPointID():int
		{
			return TouchPointID.gwPointID;
		}
		/**
		 * Sets a gwPointID.
		 */
		gw_public static function set gwPointID(value:int):void
		{
			TouchPointID.gwPointID=value;
		}
	}
}