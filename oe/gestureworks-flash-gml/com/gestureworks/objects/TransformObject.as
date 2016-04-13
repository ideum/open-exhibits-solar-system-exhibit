////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TransformObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
	
	public class TransformObject extends Object 
	{
		// ID
		public var id:int;
		
		// x---------------------
		public var x:Number = 0; 
		
		// y---------------------
		public var y:Number = 0;

		// z---------------------
		public var z:Number = 0;

		// localx---------------------
		public var localx:Number = 0;

		// localy---------------------
		public var localy:Number = 0;

		// localz---------------------3d//
		public var localz:Number = 0;

		
		// radius---------------------
		public var radius:Number = 0;

		// width----------------------
		public var width:Number = 0;

		// height---------------------
		public var height:Number = 0;

		// length---------------------3d//
		public var length:Number = 0;

		
		// scale------------------
		public var scale:Number = 0;

		// scaleX------------------
		public var scaleX:Number = 0;

		// scaleY------------------
		public var scaleY:Number = 0;

		// scaleZ------------------3d//
		public var scaleZ:Number = 0;

		
		// rotation---------------------
		public var rotation:Number = 0;

		// orientation---------------------
		public var orientation:Number = 0;

		// alpha---------------------
		public var alpha:Number = 0;

		
		// rotation3D---------------------3d//
		public var rotationX:Number = 0;

		//
		public var rotationY:Number = 0;

		//
		public var rotationZ:Number = 0;

		
		/////////////////////////////////////////////////
		// object properties
		/////////////////////////////////////////////////
		// x---------------------
		public var obj_x:Number = 0;

		// y---------------------
		public var obj_y:Number = 0;

		// z---------------------3d//
		public var obj_z:Number = 0;

		
		// width----------------------
		public var obj_width:Number = 0;

		// height---------------------
		public var obj_height:Number = 0;

		// length---------------------3d//
		public var obj_length:Number = 0;

		
		// scaleX------------------
		public var obj_scaleX:Number = 0;

		// scaleY------------------
		public var obj_scaleY:Number = 0;

		// scaleZ------------------3d//
		public var obj_scaleZ:Number = 0;

		
		// rotation---------------------
		public var obj_rotation:Number = 0;

		// rotationX---------------------
		public var obj_rotationX:Number = 0;

		// rotationY---------------------
		public var obj_rotationY:Number = 0;

		// rotationZ---------------------
		public var obj_rotationZ:Number = 0;

		
		/////////////////////////////////////////////////
		// velocities
		/////////////////////////////////////////////////
		// dx---------------------
		public var dx:Number = 0;

		// dy---------------------
		public var dy:Number = 0;

		// dz---------------------3d//
		public var dz:Number = 0;

		// dw---------------------
		public var dw:Number = 0;

		// dh---------------------
		public var dh:Number = 0;

		//SEPARATION
		// ds---------------------
		public var ds:Number = 0;

		// dsx---------------------
		public var dsx:Number = 0;

		// dsy---------------------
		public var dsy:Number = 0;

		// dsz---------------------3d//
		public var dsz:Number = 0;

		//ROTATION
		// dtheta ------------------
		public var dtheta:Number = 0;

		// dthetaX ------------------
		public var dthetaX:Number = 0;

		// dthetaY ------------------
		public var dthetaY:Number = 0;

		// dthetaZ ------------------3d//
		public var dthetaZ:Number = 0;

		// dalpha ------------------
		public var dalpha:Number = 0;


		///////////////////////////////////////////////
		// pre_init_height ------------------
		public var pre_init_height:Number = 0;

		// pre_init_width ------------------
		public var pre_init_width:Number = 0;

		// transformPointOn ------------------
		public var init_center_point:Boolean = false;

		// transformPointOn ------------------
		public var transformPointsOn:Boolean = false;

		// debug points 
		public var affinePoints:Array;

		// transformed debug points 
		public var transAffinePoints:Array;
		
		
		// SHOULD BE VECTOR
		// transform history
		public var history:Array = new Array();

	}
}