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
	
	public class InteractionPointObject extends Object 
	{	
		// ID
		public var id:int;
		
		// interactionPointID
		public var interactionPointID:int;
		
		// interaction point type // tool/pen/brush/ pin/pinch/hook/trigger/
		public var type:String = new String();
		
		// handID // parent hand ID (if type finger)
		public var handID:int = 0;
		
		//finger number on hand config that created ip
		public var fn:int = 0;
		
		// hand orientation // up/down
		public var orientation:String = new String("undefined");
		
		//flatness
		public var flatness:Number = 0;
		
		//splay
		public var splay:Number = 0;
		
		// interaction point phase //
		public var phase:String = new String();
		
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
		
		//fist state for palm ip
		public var fist:Boolean = false;
		
		//rotation/////////////////////////////////////////////x,y,x
		public var rotation:Matrix = new Matrix ();
		
		//palm radius
		public var sphereRadius:Number = 0;
		
		// sphere center
		public var sphereCenter:Vector3D = new Vector3D ();
		
		//min length of this motion point for sesioon
		public var min_length:Number = 100000000;

		//max length of this motion for session
		public var max_length:Number = 0;

		//extension percentage based on max and min length for session
		public var extension:Number = 0;
		
		///////////////////////////////////////////////////////////////////
		// history/////////////////////////////////////////////////////////
		public var history:Vector.<InteractionPointObject> = new Vector.<InteractionPointObject>();
	}
}