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
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	
	public class GesturePointObject extends Object 
	{	
		// ID
		public var id:int;
		
		// gesturePointID
		public var gesturePointID:int;
		
		// gesture point type /tap
		public var type:String = new String();
		
		//position/////////////////////////////////////////////x,y,x
		public var position:Vector3D = new Vector3D ();
		
		//direction////////////////////////
		public var direction:Vector3D = new Vector3D ();
		
		//normal/////////////////////////
		public var normal:Vector3D = new Vector3D ();
		
		//velocity//////////////////////////////////////////////dx,dy,dz
		public var velocity:Vector3D = new Vector3D ();
		
		//accleration//////////////////////////////////////////////ddx,ddy,ddz
		public var acceleration:Vector3D = new Vector3D ();
		
		//jolt//////////////////////////////////////////////ddx,ddy,ddz
		public var jolt:Vector3D = new Vector3D ();

		//width
		public var width:Number = 0;

		//length
		public var length:Number = 0;
		
		//rotation/////////////////////////////////////////////x,y,x
		public var rotation:Matrix = new Matrix ();
	}
}