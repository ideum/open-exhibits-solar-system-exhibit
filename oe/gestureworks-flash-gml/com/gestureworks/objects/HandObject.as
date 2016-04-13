////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    HandObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	import flash.geom.Vector3D;
	import com.gestureworks.objects.MotionPointObject;
	
	public class HandObject extends Object 
	{	
		// ID
		public var id:int;
		
		// motionPointID
		public var handID:int;
		
		// hand type // left / right
		public var type:String = new String("undefined");
		
		// hand orientation // up/down
		public var orientation:String = new String("undefined");
		
		//flatness
		public var flatness:Number = 0;
		
		//splay
		public var splay:Number = 0;
		
		/////////////////////////////////////////////////////////////////////////////////////////
		
		// fingerArray 
		public var fingerList:Vector.<MotionPointObject> = new Vector.<MotionPointObject>();
		
		// thumb
		public var thumb:MotionPointObject = new MotionPointObject();
		
		// palm
		public var palm:MotionPointObject = new MotionPointObject();
		
		////////////////////////////////////////////////////////////////////////////////////////////
		
		//position/////////////////////////////////////////////x,y,x
		public var position:Vector3D = new Vector3D ();
		
		//direction////////////////////////
		public var direction:Vector3D = new Vector3D ();
		
		//normal/////////////////////////
		public var normal:Vector3D = new Vector3D ();
		
		//width
		public var width:Number = 0;
		
		//length
		public var length:Number = 0;
		
		// could move in size??
		//palm radius
		public var sphereRadius:Number = 0;
		
		// sphere center
		public var sphereCenter:Vector3D = new Vector3D ();
		
		//velocity//////////////////////////////////////////// //dx,dy,dz
		public var velocity:Vector3D = new Vector3D ();
		
		//frameVelocity//////////////////////////////////////////// //DX,DX,DY
		public var frameVelocity:Vector3D = new Vector3D ();
		
		
		//finger average position//////////////////////////////////////////// //dx,dy,dz
		public var fingerAveragePosition:Vector3D = new Vector3D ();
		
		//finger average position//////////////////////////////////////////// //dx,dy,dz
		public var projectedFingerAveragePosition:Vector3D = new Vector3D ();
		
		//pure finger average position//////////////////////////////////////////// //dx,dy,dz
		public var pureFingerAveragePosition:Vector3D = new Vector3D ();
		
		//pair table/////////////////////////////////////////////x,y,x
		public var pair_table:Array = new Array();
	}
}