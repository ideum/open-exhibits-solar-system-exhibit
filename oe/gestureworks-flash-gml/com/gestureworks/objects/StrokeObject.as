////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    StrokeObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	public class StrokeObject extends Object 
	{
		// ID
		public var id:int;
		
		// NUMBER OF STROKES IN STROKE OBJECT
		public var n:int = 0;
		
		public var path_collection:Vector.<Array> = new Vector.<Array>();
		
		// path_data FOR UNISTROKES
		// CONVERT TO VECTOR
		public var path_data:Array = new Array();
		
		// CONVERT TO VECTOR
		// NORMALIZED PATH DATA FOR UNISTROKES
		public var path_data_norm:Array = new Array();
		
		//////////////////////kill
		public var pathmap:Array = new Array();

		////////////////////////
		
		// PATH DATA FOR MULTISTROKES
		public var pathDataArray:Vector.<Array> = new Vector.<Array>();
		
		
		// PATH MATCH PROBABILITY 
		public var path_prob:Number = 0;
		
		// NUMBER OF POINTS LENGTH
		public var path_n:Number = 0;

		// TIME TO DRAW PATH
		public var path_time:Number = 0;

		
		// AVERAGE PATH POSITION
		public var path_x:Number = 0;

		
		public var path_y:Number = 0;

		
		// STARTING POINT
		public var path_x0:Number = 0;

		
		public var path_y0:Number = 0;

		
		// END POINT
		public var path_x1:Number = 0;

		
		public var path_y1:Number = 0;

		
		// AVERAGE PATH WIDTH
		public var path_width:Number = 0;

		
		public var path_height:Number = 0;

		//////////////////////////////////////////////
	}
}