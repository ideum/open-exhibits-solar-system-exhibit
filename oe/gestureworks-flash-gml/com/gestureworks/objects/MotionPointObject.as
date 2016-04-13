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
	//import flash.display.DisplayObject;
	//import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	
	public class MotionPointObject extends Object 
	{	
		// ID
		public var id:int;
		
		// motionPointID
		public var motionPointID:int;
		
		// motion point type // finger, tool, palm
		public var type:String = new String();
		
		//fingertype thumb, index, middle,....
		public var fingertype:String = new String();
		
		// frameID
		public var frameID:int;
		
		// motionID
		public var motionFrameID:int;
		
		// move count 
		// number move updates for point in frame
		public var moveCount:int =0;
		
		// handID // parent hand ID (if type finger)
		public var handID:int = 0;
		
		//TEMP//////////////////////////////////////////
		// pairArray 
		public var pairArray:Array = new Array();
			
		
		// nnID // parent hand ID (if type finger)
		public var nnID:int = 0;
		
		// nndID // parent hand ID (if type finger)
		public var nndID:int = 0;
		
		// nndaID // parent hand ID (if type finger)
		public var nndaID:int = 0;
		
		// nndaID // parent hand ID (if type finger)
		public var nnpaID:int = 0;
		
		// nnID // parent hand ID (if type finger)
		public var nnprobID:int = 0;
		
		///////////////////////////////////////////////
			
		
		// handID // parent hand ID (if type finger)
		public var pairedPointID:int = 0;
		
		
		//position/////////////////////////////////////////////x,y,x
		public var position:Vector3D = new Vector3D ();
		
		//direction////////////////////////
		public var direction:Vector3D = new Vector3D ();
		
		//normal/////////////////////////
		public var normal:Vector3D = new Vector3D ();
		
		//rotation/////////////////////////////////////////////x,y,x
		public var rotation:Matrix = new Matrix ();
		
		//palm plane position/////////////////////////////////////////////x,y,x
		public var palmplane_position:Vector3D = new Vector3D ();
		
		/*
		//size///////////////////////////////////////////w,h,l
		public var size:Vector3D = new Vector3D ();
		*/
		
		//width
		public var width:Number = 0;

		//length
		public var length:Number = 0;

		//min length of this motion point for sesioon
		public var min_length:Number = 100000000;

		//max length of this motion for session
		public var max_length:Number = 0;

		//extension percentage based on max and min length for session
		public var extension:Number = 0;
		
		
		//favdist
		public var favdist:Number = 0;

		
		//normalized_favdist
		public var normalized_favdist:Number = 0;

		
		//palmAngle
		public var palmAngle:Number = 0;

		
		//normalized_width based on other fingers in local hand
		public var normalized_width:Number = 0;

		//normalized_length based on other fingers in local hand
		public var normalized_length:Number = 0;
		
		public var normalized_max_length:Number = 0;

		//normalized_dAngle based on other fingers in local hand
		public var normalized_palmAngle:Number = 0;
		
		
		// hand structure probs
		public var thumb_prob:Number = 0;

		// hand structure probs
		public var mean_thumb_prob:Number = 0;

		
		// could move in size??
		//palm radius
		public var sphereRadius:Number = 0;
		
		// sphere center
		public var sphereCenter:Vector3D = new Vector3D ();
		
		
		//velocity//////////////////////////////////////////// //dx,dy,dz
		public var velocity:Vector3D = new Vector3D ();
		
		//frameVelocity//////////////////////////////////////////// //DX,DX,DY
		public var frameVelocity:Vector3D = new Vector3D ();
		

		///////////////////////////////////////////////////////////////////
		// history/////////////////////////////////////////////////////////
		public var history:Vector.<MotionPointObject> = new Vector.<MotionPointObject>();
	}
}