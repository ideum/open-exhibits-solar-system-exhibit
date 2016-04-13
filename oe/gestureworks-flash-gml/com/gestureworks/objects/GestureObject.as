////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GesturePropertyObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	
	public class GestureObject extends Object 
	{
		// gesture id
		public var gesture_id:String;
		
		// gesture xml block
		public var gesture_xml:XML;
		
		// SHOULD MOVE TO GESTURE EVENT OBJECT
		// activeEvent
		public var activeEvent:Boolean = false;

		// dispatchEvent
		public var dispatchEvent:Boolean = false;
		
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// MOVE TO MATHING CRITERIA SUBOBJECT
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		// gesture type
		public var gesture_type:String;

		
		// algorithm id
		public var algorithm:String;

		// algorithm type
		public var algorithm_type:String;

		// algorithm class
		public var algorithm_class:String;

		
		// n_current---------------------
		public var n_current:int = 0;

		// n_cache---------------------
		public var n_cache:int = 0;

		
		
		//////////////////////////////////////
		// global gesture matching criteria
		//////////////////////////////////////
		
		// n---------------------
		public var n:int = 0;

		// nMax---------------------
		public var nMax:int = 100;

		// nMin---------------------
		public var nMin:int = 0;
		
		// CLUSTER TYPE---------------------
		public var cluster_type:String = "";

		// CLUSTER INPUT TYPE---------------------
		public var cluster_input_type:String = "";
		
		////////////////////////////////////////
		// generic hand properties
		////////////////////////////////////////
		
		// hand total number---------------------
		public var hn:int = 0;

		// finger total number---------------------
		public var fn:int = 0;
		
		// hand finger number---------fingers per hand (config diff)
		public var h_fn:int = 0;
		
		// hand type ---------------------
		public var h_type:String = "";
		
		// hand orinetation ---------------------
		public var h_orientation:String = "";
		
		// hand splay ---------------------
		public var h_splay:Number = 0;
		public var h_splay_min:Number = 0;
		public var h_splay_max:Number = 0;
		
		// hand flatness ---------------------
		public var h_flatness:Number = 0;
		public var h_flatness_min:Number = 0;
		public var h_flatness_max:Number = 0;
		
		//hand radius -----------------------
		public var h_radius:Number = 0;
		public var h_radius_min:Number = 0;
		public var h_radius_max:Number = 0;
		
		////////////////////////////////////////
		//EXPLICIT HAND CONFIG
		///////////////////////////////////////
		// left hand explicit config ---------------------
		//public var lh_config:Object;
		
		// right hand explicit config ---------------------
		//public var rh_config:Object;
		

		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//UPDATE TO LIMITS OBJECT PUSH TO CLUSTER OBJECT
		////////////////////////////////////////////////////////
		// general cluster thresholds
		///////////////////////////////////////////////////////
		//
		public var cluster_translation_min:Number = 0;

		//
		public var cluster_translation_max:Number = 0;

		//
		public var cluster_separation_min:Number = 0;

		//
		public var cluster_separation_max:Number = 0;

		//
		public var cluster_rotation_min:Number = 0;

		//
		public var cluster_rotation_max:Number = 0;

		//
		public var cluster_acceleration_min:Number = 0;

		//
		public var cluster_acceleration_max:Number = 0;

		//
		public var cluster_event_duration_min:Number = 0;

		//
		public var cluster_event_duration_max:Number = 0;

		//
		public var cluster_interevent_duration_min:Number = 0;

		//
		public var cluster_interevent_duration_max:Number = 0;

		
		////////////////////////////////////////////////////////
		// general POINT thresholds
		///////////////////////////////////////////////////////
		public var point_translation_min:Number = 0;

		//
		public var point_translation_max:Number = 0;

		//
		public var point_acceleration_min:Number = 0;

		//
		public var point_acceleration_max:Number = 0;

		//
		public var point_event_duration_min:Number = 0;

		//
		public var point_event_duration_max:Number = 0;

		//
		public var point_interevent_duration_min:Number = 0;

		//
		public var point_interevent_duration_max:Number = 0;

		// ACCEL POINT THRESHOLDS..
		// MOTION POINT THRESHOLDS...
		
		// REMOVE
		////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////
		// gesture object vector
		public var clusterVector:Vector //=  new Vector.<Number>();

		//
		public var processVector:Vector //= new Vector.<Number>();;

		//
		public var gestureVector:Vector //= new Vector.<Number>();;
		
		
		// path-match---------------
		public var gmlPath:Array = new Array();

		// match event
		public var match_TouchEvent:String;

		// match event
		public var match_GestureEvent:String;

		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// end match criteria
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		

		
		// SHOULD MOVE TO GESTURE EVENT OBJECT
		////////////////////////////////////////////////////////////////////////////////////
		// GESTURE EVENT SETTINGS
		////////////////////////////////////////////////////////////////////////////////////
		// event type
		public var event_type:String;

		// event dipatch type
		public var dispatch_type:String;

		// event dipatch mode
		public var dispatch_mode:String;

		//event displatch trigger
		public var dispatch_reset:String;

		// event dipatch interval
		public var dispatch_interval:int;

		// timer_count
		public var timer_count:int = 0;
		
		
		// SHOULD MOVE TO GESTURE EVENT OBJECT
		//public var event_phase:uint = 0;
		///////////////////////////////////////////////////
		// GESTURE EVENT PHASE LOGIC 
		// 0 null
		// 1 start 
		// 2 active 
		// 3 release
		// 4 passive
		// 5 complete
		///////////////////////////////////////////////////
		// start
		public var start:Boolean = false;

		// active
		public var active:Boolean = false;

		// release
		public var release:Boolean = false;

		// passive
		public var passive:Boolean = false;

		// complete
		public var complete:Boolean = false;

		
		// SHOULD MOVE TO GESTURE EVENT OBJECT
		////////////////////////////////////////////////////////////////////////////
		// data object
		public var data:Object = new Object();

		// DIMENSION LIST
		public var dList:Vector.<DimensionObject> = new Vector.<DimensionObject>();
	
		
	}
}