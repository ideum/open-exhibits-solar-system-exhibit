////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    PointObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	import com.gestureworks.interfaces.ITouchObject;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.TouchEvent;
	
	public class PointObject extends Object 
	{	
		// ID
		public var id:int;

		// touchPointID
		public var touchPointID:Number;

		
		/////////////////////////////////////////////
		// x
		public var x:Number=0;

		// y
		public var y:Number=0;

		// Z //-3d
		public var z:Number = 0;

		
		// width
		public var w:Number=0;

		// height
		public var h:Number=0;

		//////////////////////////////////////////////
		
		// dx
		public var dx:Number=0;

		// dy
		public var dy:Number=0;

		
		// dz
		public var dz:Number = 0;

		                                                                                                                                                                                                  
		// DX
		public var DX:Number=0;

		// DY
		public var DY:Number=0;

		// DZ
		public var DZ:Number=0;		
		
		// frameID
		public var frameID:int;

		
		// move count
		// number move updates for point in frame
		public var moveCount:int=0;
	
		
		//////////////////////////////////////////////////
		// MAY NEED TO MOVE TO CLUSTER
		/////////////////////////////////////////////////
		// hold monitor 
		public var holdMonitorOn:Boolean=false;

		// hold count
		// number frames passed hold test
		public var holdCount:int;

		// hold lock 
		public var holdLock:Boolean=false;

		
		
		
		// MAY NEED REMOVE
		// event
		public var event:TouchEvent;

		
		///////////////////////////////////////////////////
		// DIRECT REFERENCE TO THE TOUCH OBJECT THAT "OWNS" THE TOUCH POINT
		// primary touch object (should be target)
		//////////////////////////////////////////////////
		// object
		public var object:ITouchObject;

		/**
		 * Object that triggered touch event
		 */
		public var originator:ITouchObject;
		
		///////////////////////////////////////////////////////
		// list of objects that are given copy of touch point
		// touch object in nested stack or in cluster broadcast
		///////////////////////////////////////////////////////
		
		//  objectList
		// UPDATE TO VECTOR
		public var objectList:Array = [];
		
		// UPDATE TO VECTOR
		public var clusterList:Array = [];
		
		
		// history
		public var history:Vector.<PointObject> = new Vector.<PointObject>();

		
	}
}