////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    PropertyObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	public class DimensionObject extends Object 
	{
		// property name key
		public var id:String;
		
		// target property key
		public var target_id:String;

		// active
		public var activeDim:Boolean = true;

		// property result name
		public var property_result:String;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// VECTOR
		// property var array
		public var property_vars:Array = new Array();
	
		// property type
		public var property_type:String;
		
		// property id
		public var property_id:String;
				
		//USED IN BOUNDARY EVAL
		public var gestureValue:Number = 0;

		///////////////////////////////////////////////////////////////////////////////////////
		//CURRENT RAW CLUSTER DELTA
		public var clusterDelta:Number = 0;

		//CURRENT PROCESS DELTA
		public var processDelta:Number = 0;

		//CURRENT GESTURE DETLA
		public var gestureDelta:Number = 0;

		//LAST DELTA FOR DIM
		public var gestureDeltaCache:Number = 0;
		
		// CACHED GESTURE DELTAS
		//USED IN MEAN FILTERING
		public var gestureDeltaArray:Array = new Array();
		
		// CREATE GENERIC FILTER OBJECT
		// ADD FILTERS ON REQUEST TO KEEP LITE
		// CREATE GENERIC FILTER LIST AND ITERATE
		//////////////////////////////////////////////////////
		// multiply filter
		//////////////////////////////////////////////////////
		// constant of proportionality ---------------------
		public var multiply_filter:Boolean = false;

		// functional relationship between raw value and gesture value
		public var func:String = "linear";

		// constant of proportionality ---------------------
		public var func_factor:Number = 1;

		
		////////////////////////////////////////////////////////////////
		// delta filter
		////////////////////////////////////////////////////////////////
		// delta_threshold---------------------
		public var delta_filter:Boolean = false;
		
		// determins if delta limits are signed, to create directional delta limits--
		public var delta_directional:Boolean = false;

		// delta_max ---------------------
		public var delta_max:Number = 100;

		// delta_min ---------------------
		public var delta_min:Number = 0;

		
		/////////////////////////////////////////////////////////
		// value filter
		//////////////////////////////////////////////////////////
		// boundaryOn---------------------
		public var boundary_filter:Boolean = false;

		// boundary_max ---------------------
		public var boundary_max:Number = 100;

		// boundary_min ---------------------
		public var boundary_min:Number = 0;
		
		
		////////////////////////////////////////////////////////
		// mean filter
		////////////////////////////////////////////////////////
		// mean filter---------------------
		public var mean_filter:Boolean = false;

		// filter_factor---------------------
		public var mean_filter_frames:uint = 0;

		
		/////////////////////////////////////////////////////////
		// release inertia filter
		/////////////////////////////////////////////////////////
		// release_inertiaOn---------------------
		public var release_inertia_filter:Boolean = false;

		// release_inertia---------------------
		public var release_inertiaOn:Boolean = false;

		// r_inertia_factor---------------------
		public var release_inertia_factor:Number = 1;

		// r_inertia_base---------------------
		public var release_inertia_base:Number = 0.98;

		// r_inertia_factor count---------------------
		public var release_inertia_count:int = 0;

		// r_inertia_factor count-Max--------------------
		public var release_inertia_Maxcount:int = 60;
		
		
		/////////////////////////////////////////////////////////
		// mapped property value limits
		//////////////////////////////////////////////////////////
		// property max ----------------------
		public var property_max:Number = 0;
		// property_min ----------------------
		public var property_min:Number = 0;
	}
}