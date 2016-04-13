////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    .as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.core
{
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.interfaces.ITouchObject3D;
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.DimensionObject;
	import com.gestureworks.objects.GestureListObject;
	import com.gestureworks.objects.GestureObject;
	import com.gestureworks.objects.TransformObject;
	import flash.geom.*;
	import flash.geom.Matrix3D;
	
	public class TouchTransform
	{
		// public
		public static const RAD_DEG:Number = 180 / Math.PI;
		public static const DEG_RAD:Number = Math.PI / 180 ;
		public var affine_modifier:Matrix = new Matrix;
		public var affine_modifier3D:Matrix3D = new Matrix3D;
		
		public var parent_modifier:Matrix = new Matrix;
		public var ref_frame_angle:Number = 0; 
	
		// private //local merged display object properties
		private var t_x:Number = 0;
		private var t_y:Number =  0;
		private var t_z:Number =  0;//3d--
		
		// private	// differentials
		private var dx:Number = 0;
		private var dy:Number =  0;
		private var dz:Number =  0;//3d--
		
		private var ds:Number = 0;
		private var dsx:Number =  0;
		private var dsy:Number =  0;
		private var dsz:Number =  0;//3d--
		
		private var dtheta:Number =  0;
		private var ts:Object;
		private var trO:TransformObject;
		private var gO:GestureListObject;
		private var id:int;
		private var centerTransform:Boolean = false;
		
		// 3d
		private var dthetaX:Number =  0;//3d--
		private var dthetaY:Number =  0;//3d--
		private var dthetaZ:Number =  0;//3d--		
		private var focalLength:Number;
		private var ratio:Number;		
		
		public function TouchTransform(touchObjectID:int):void
		{
			id = touchObjectID;
			ts = GestureGlobals.gw_public::touchObjects[id];
			trO = ts.trO; //tra
			gO = ts.gO; //tra
			
			// gets transform proeprty limits form gml
			initTransform();
        }
		  
		// initializers    
        public function initTransform():void 
        {
			//if(traceDebugMode) trace("create touchsprite transform");			
			affine_modifier = new Matrix();// init display object transformation operator
			affine_modifier3D = new Matrix3D();
			
			trO.transformPointsOn = true;
			pre_InitTransformPoints();
		}
		
		public function updateTransformLimits():void 
        {		
			for each(var pO:GestureObject in gO.pOList) {
				for each(var dO:DimensionObject in pO.dList) {
					switch(dO.target_id) {
						case "dx":
							ts.minX = isNaN(dO.property_min) ? ts.minX : dO.property_min;
							ts.maxX = isNaN(dO.property_max) ? ts.maxX : dO.property_max;
							break; 
						case "dy":
							ts.minY = isNaN(dO.property_min) ? ts.minY : dO.property_min;
							ts.maxY = isNaN(dO.property_max) ? ts.maxY : dO.property_max;
							break; 
						case "dz":
							ts.minZ = isNaN(dO.property_min) ? ts.minZ : dO.property_min;
							ts.maxZ = isNaN(dO.property_max) ? ts.maxZ : dO.property_max;
							break; 
						case "dsx":
							ts.minScaleX = isNaN(dO.property_min) ? ts.minScaleX: dO.property_min;
							ts.maxScaleX = isNaN(dO.property_max) ? ts.maxScaleX : dO.property_max;
							break; 
						case "dsy":
							ts.minScaleY = isNaN(dO.property_min) ? ts.minScaleY : dO.property_min;
							ts.maxScaleY = isNaN(dO.property_max) ? ts.maxScaleY : dO.property_max;
							break; 
						case "dsz":
							ts.minScaleZ = isNaN(dO.property_min) ? ts.minScaleZ : dO.property_min;
							ts.maxScaleZ = isNaN(dO.property_max) ? ts.maxScaleZ : dO.property_max;
							break; 
						case "dtheta":
							ts.minRotation = isNaN(dO.property_min) ? ts.minRotation : dO.property_min;
							ts.maxRotation = isNaN(dO.property_max) ? ts.maxRotation : dO.property_max;
							break; 
						case "dthetaX":
							ts.minRotationX = isNaN(dO.property_min) ? ts.minRotationX : dO.property_min;
							ts.maxRotationX = isNaN(dO.property_max) ? ts.maxRotationX : dO.property_max;
							break; 
						case "dthetaY":
							ts.minRotationY = isNaN(dO.property_min) ? ts.minRotationY : dO.property_min;
							ts.maxRotationY = isNaN(dO.property_max) ? ts.maxRotationY : dO.property_max;
							break; 
						case "dthetaZ":
							ts.minRotationZ = isNaN(dO.property_min) ? ts.minRotationZ : dO.property_min;
							ts.maxRotationZ = isNaN(dO.property_max) ? ts.maxRotationZ : dO.property_max;
							break; 
						default:
							break;
					}
				}
			}						
		}

		/**
		* @private
		* update local properties
		*/		
		public function updateLocalProperties():void
		{
			//boundary check
			with (ts) {
				x = x; 
				y = y; 
				rotation = rotation;
				scaleX = scaleX;
				scaleY = scaleY;
			}
			
			ts.dx = 0;
			ts.dy = 0;
			ts.dz = 0;
			ts.dsx = 0;
			ts.dsy = 0;
			ts.dsz = 0;
			ts.dtheta = 0;
			ts.dthetaX = 0;
			ts.dthetaY = 0;
			ts.dthetaZ = 0;	
			ts.mtx = ts.transform.matrix;
			ts.mtx3D = ts.transform.matrix3D;
			
			// update transform 2d debug object properties
			if (trO.transAffinePoints)
			{
				trO.obj_x = trO.transAffinePoints[4].x//_x
				trO.obj_y = trO.transAffinePoints[4].y//_y	
			}
						
			trO.obj_scaleX = ts.scaleX;
			trO.obj_scaleY = ts.scaleY;
			trO.obj_scaleZ = ts.scaleZ;
			
			trO.obj_width = ts.width;
			trO.obj_height = ts.height;
			trO.obj_length = ts.length;
			
			trO.obj_rotation = ts.rotation;
			trO.obj_rotationX = ts.rotationX;//3d--
			trO.obj_rotationY = ts.rotationY;//3d--
			trO.obj_rotationZ = ts.rotationZ;//3d-
		}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// managers
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	* @private
	*/
	public function updateTransformation():void 
	{
		transformManager();
	}
	/**
	* @private
	*/
	public function transformManager():void 
	{
		//if (traceDebugMode) trace("touch object transform");
			
		//TODO: MERGE "applyaffineTransform" and "applyNativeTransform()"
		// set logic internally to the transform based on ts type
		
			//////////////////////////////////////////////////////////////////////
			// ACTIVE INTERACTION POINT TRANSFORM
			//////////////////////////////////////////////////////////////////////
			if ((ts.N != 0)||(ts.cO.fn!=0))//
				{
					if (!trO.init_center_point) initTransformPoints();
					
					// AFFINE BY DEFAULT
					centerTransform = false;
					
					// AFFINE CAN BE OVERRIDEN ON TS
					if (!ts.affineTransform) centerTransform = true; // 
					
					// ALL GESTURE LISTENER DRIVEN TS PROPERTY CHNAGES NEED "applyAffineTransform" TO INHERIT $ PROPERTY CHNAGES
					// OTHERWISE WHEN IN NATIVE MODE (not gesture event driven) "applyNativeTransform()" will be used
					if (!ts.nativeTransform){
						if (ts.affineTransform) applyAffineTransform();
					}
					else applyNativeTransform();
					
					ts.transformComplete = false;
					ts.transformStart = true;
					if (ts.transformEvents) manageTransformEventDispatch();
					//if (ts.traceDebugMode)trace("update", ts.touchObjectID)
				}
				////////////////////////////////////////////////////////////////////////
				// RELEASE INTERTIA TRANSFORM
				///////////////////////////////////////////////////////////////////////
				else if ((ts.N == 0)&&(ts.cO.fn == 0) && (ts.gestureTweenOn) && (ts.gestureReleaseInertia)) //||
				{
					// ALWAYS SET TO TRUE FOR RELEASED TS OBJECTS
					// ENABLES RELEASED OBJECTS TO ROTATE ABOUT CENTER OF MASS
					centerTransform = true; 
					
					//ALL GESTURE LISTENER DRIVEN TS PROPERTY CHNAGES NEED "applyAffineTransform" TO INHERIT $ PROPERTY CHNAGES
					//OTHERWISE WHEN IN NATIVE MODE (not gesture event driven) "applyNativeTransform()" will be used
					if (!ts.nativeTransform){
						if (ts.affineTransform) applyAffineTransform();
					}
					else applyNativeTransform();
					
					ts.transformComplete = false;
					ts.transformStart = false;
					if (ts.transformEvents) manageTransformEventDispatch();
					//if (ts.traceDebugMode)trace("inertia", ts.touchObjectID)
				}
				//////////////////////////////////////////////////////////////////////////
				// TRANSFORM TERMINATION
				/////////////////////////////////////////////////////////////////////////
				else if ((ts.N == 0)&&(ts.cO.fn == 0) && (!ts.gestureTweenOn)&&(!ts.transformComplete)) //||
				{
					ts.transformComplete = true;
					ts.transformStart = false;
					if (ts.transformEvents) manageTransformEventDispatch();
					//if (ts.traceDebugMode)trace("none", ts.touchObjectID)
				}
				
			
	}
		
	////////////////////////////////////////////////////////////////////////////////
	// transforms properties using native gml values
	////////////////////////////////////////////////////////////////////////////////
	/**
	* @private
	*/
	private function applyNativeTransform():void
		{
				if ((ts.parent) && (ts.transformGestureVectors))
				{
				//trace("native parent")
				//ts.transform.matrix = ts.mtx; // put for testing
				
				// gives root cocatenated transform of parent space
				parent_modifier.copyFrom(ts.parent.transform.concatenatedMatrix);
				parent_modifier.invert();

				var angle:Number = -(Math.atan(parent_modifier.c / parent_modifier.a))//Math.acos(parent_modifier.a)
				//var angle:Number = -calcAngle(parent_modifier.a , parent_modifier.c) * DEG_RAD;
				
				ref_frame_angle = angle;
				var scalex:Number = parent_modifier.a / Math.cos(angle);
				var scaley:Number =  scalex;//parent_modifier.a / Math.cos(angle);
				var scalez:Number =  scalex;//parent_modifier.a / Math.cos(angle);
				
				//TRANSFORM CENTER POINT OF TRANSFORMATION
				var pt:Point
				if (!centerTransform) pt = parent_modifier.transformPoint(new Point(trO.x, trO.y));
				else pt = new Point( trO.transAffinePoints[4].x,trO.transAffinePoints[4].y);
				
				// TRANSFORM TRANSFORMATION VECTOR
				var vector_mod:Matrix = new Matrix ();
					vector_mod.rotate(angle);
					vector_mod.scale(scalex ,scaley);
				var tpt:Point = vector_mod.transformPoint(new Point(trO.dx, trO.dy));
				//trace(ag,parent_modifier.a,parent_modifier.b,parent_modifier.c,parent_modifier.d, vdr)
				
				// translate center of transformation
					t_x =  pt.x;
					t_y =  pt.y;
					//t_z =  pt.z;
				// rotate translation vector
					dx =  tpt.x;
					dy =  tpt.y;
					//dz =  tpt.z;
				}
				
				else {	
					//trace("native")
						// do not pre transform // super override method
						if (centerTransform) {
							t_x = trO.transAffinePoints[4].x
							t_y = trO.transAffinePoints[4].y
						}
						else {
						t_x = trO.x;
						t_y = trO.y;
						t_z = trO.z;
						}
						dx = trO.dx;
						dy = trO.dy;
						dz = trO.dz;
				}
				
				///////////////////////////////////////////////////////////////////////////////////
				// lock properties from transform
				if (ts.x_lock) { dx = 0 };
				if (ts.y_lock) { dy = 0 };
				
				// leave scalar values untouched
				dsx =  trO.dsx;
				dsy =  trO.dsy;
				dsz =  trO.dsz;
				
				// 3D matrix uses degrees
				dtheta = trO.dtheta;
				dthetaX = trO.dthetaX; 
				dthetaY = trO.dthetaY;
				dthetaZ = trO.dthetaZ;	
				
				//native transform boundaries
				if ((ts.scaleX+dsx < ts.minScaleX) || (ts.scaleX+dsx > ts.maxScaleX)) dsx = 0;
				if ((ts.scaleY+dsy < ts.minScaleY) || (ts.scaleY+dsy > ts.maxScaleY)) dsy = 0;
				if ((ts.rotation+dtheta < ts.minRotation) || (ts.rotation+dtheta > ts.maxRotation)) dtheta = 0;
					
				////////////////////////////////////////////////////
				// check for away 3D 
				if (ts is ITouchObject3D) 
				{
					var d:Number = ts.distance;
					
					if (ts.centerTransform) {
						trO.x = ts.x;
						trO.y = ts.y;
						trO.z = ts.z;
					}
					
					// modify transform
					affine_modifier3D.copyFrom(ts.transform.matrix3D);
						affine_modifier3D.appendTranslation( -trO.x + dx, -trO.y + dy, -trO.z + dz);	
						affine_modifier3D.appendRotation(dthetaX, new Vector3D(affine_modifier3D.rawData[0], affine_modifier3D.rawData[1], affine_modifier3D.rawData[2]));
						affine_modifier3D.appendRotation(dthetaY, new Vector3D(affine_modifier3D.rawData[4], affine_modifier3D.rawData[5], affine_modifier3D.rawData[6]));
						affine_modifier3D.appendRotation(dthetaZ, new Vector3D(affine_modifier3D.rawData[8], affine_modifier3D.rawData[9], affine_modifier3D.rawData[10]));								
						affine_modifier3D.appendScale(1 + dsx, 1 + dsy, 1 + dsz); 
						affine_modifier3D.appendTranslation( trO.x, trO.y, trO.z);						
					ts.transform.matrix3D = affine_modifier3D;	
					
				}
				////////////////////////////////////////////////////
				// flash 2.5D only
				else if (ts.transform.matrix3D)// check for 3D matrix,
				{							
					// get the projection offset created by the z-position	
					if (ts.transform.perspectiveProjection) // ts can define location projection
						focalLength = ts.transform.perspectiveProjection.focalLength;
					else // use global projection from root
						focalLength = ts.root.transform.perspectiveProjection.focalLength;
					ratio = focalLength / (focalLength + ts.z);
					
					affine_modifier3D.copyFrom(ts.transform.matrix3D);
						affine_modifier3D.appendTranslation(-t_x, -t_y, 0);
						affine_modifier3D.appendRotation(dtheta, Vector3D.Z_AXIS); 	
						affine_modifier3D.appendScale(1 + dsx, 1 + dsy, 1); 		
						affine_modifier3D.appendTranslation(t_x + dx/ratio, t_y + dy/ratio, 0);
					ts.transform.matrix3D = affine_modifier3D;		
				}
				
				////////////////////////////////////////////////////////////////////////////////
				// default to 2D (uses mapped 3d to 2d input)
				else {
					// 2D matrix uses radians
					dtheta *= DEG_RAD;
					affine_modifier = ts.transform.matrix;
						affine_modifier.translate(-t_x+dx,-t_y+dy);
						affine_modifier.rotate(dtheta);
						affine_modifier.scale(1 + dsx, 1 + dsy);
						affine_modifier.translate(t_x, t_y);
					ts.transform.matrix = affine_modifier
					transformAffineDebugPoints();

				}
							
				updateLocalProperties();
				
				if (ts.vto)
					ts.updateVTO();			
		}
		
		
		/////////////////////////////////////////////////////////////////////////
		// affine transform properties 
		///////////////////////////////////////////////////////////////////////// 
		public function applyAffineTransform():void
			{
				// FOR NOW 2D display OBJECTS ONLY
				if((ts is TouchSprite)||(ts is TouchMovieClip)){
				///////////////////////////////////////////////////////////////////////////////////
				if ((ts.parent)&&(ts.transformGestureVectors))
				{
					//trace("transform parent")

					// REPLACES $ METHODS ALLOWS FOR AFFINE TRANSFROMS FOR NON NATIVE METHODS(GESTURE EVENT DRIVEN PROPERTY UPDATE)
					if (ts.transform.matrix3D) {} //ts.transform.matrix3D = ts.mtx3D; //FIX inherited 3d transform
					else ts.transform.matrix = ts.mtx;
					
					
					// pre transfrom to compensate for parent transforms
					//parent_modifier = ts.parent.transform.concatenatedMatrix.clone();//test
					parent_modifier.copyFrom(ts.parent.transform.concatenatedMatrix);
					parent_modifier.invert();
					
					var angle:Number = -(Math.atan(parent_modifier.c / parent_modifier.a))//Math.acos(parent_modifier.a)
					//var angle:Number = calcAngle(parent_modifier.a , parent_modifier.c) * DEG_RAD;
					
					
					ref_frame_angle = angle;
					var scalex:Number = parent_modifier.a / Math.cos(angle);
					var scaley:Number = scalex//parent_modifier.a / Math.cos(angle);
					
					// TRANSFORM AFFINE POINT
					var pt:Point;
					if (!centerTransform) pt = parent_modifier.transformPoint(new Point(trO.x, trO.y));
					else pt = new Point( trO.transAffinePoints[4].x,trO.transAffinePoints[4].y);
					
					// TRANSFORM VECTOR
					var r_mod:Matrix = new Matrix ();
						r_mod.rotate(angle);
						r_mod.scale(scalex ,scaley);
					var tpt:Point = r_mod.transformPoint(new Point(ts.dx, ts.dy));
				
						// translate center of transformation
						t_x =  pt.x;
						t_y =  pt.y;
						// rotate translation vector
						dx =   tpt.x;
						dy =   tpt.y;
				}
				else {	
					//trace("transform")
						// do not pre transform // super override method
						if (centerTransform) {
							t_x = trO.transAffinePoints[4].x
							t_y = trO.transAffinePoints[4].y
						}
						else {
							t_x = trO.x;
							t_y = trO.y;
						}
						dx = ts.dx;
						dy = ts.dy;
				}
								
				//////////////////////////////////////////////////
				// property transform lock
				if (ts.x_lock) { dx = 0 };
				if (ts.y_lock) { dy = 0 };
				
				///////////////////////////////////////////////////
				// leave scalar values untouched
				dsx = ts.dsx;
				dsy = ts.dsy;
				dsz = ts.dsz;
				dtheta = ts.dtheta * DEG_RAD;
				
				///////////////////////////////////////////////////
				//affine transform boundaries
				if ((ts.x+dx < ts.minX) || (ts.x+dx > ts.maxX)) dx = 0;
				if ((ts.y+dy < ts.minY) || (ts.y+dy > ts.maxY)) dy = 0;					
				if ((ts.z+dz < ts.minZ) || (ts.z+dz > ts.maxZ)) dz = 0;					
				if ((ts.scaleX+dsx < ts.minScaleX) || (ts.scaleX+dsx > ts.maxScaleX)) dsx = 0;
				if ((ts.scaleY+dsy < ts.minScaleY) || (ts.scaleY+dsy > ts.maxScaleY)) dsy = 0;
				if ((ts.scaleZ+dsz < ts.minScaleZ) || (ts.scaleZ+dsz > ts.maxScaleZ)) dsz = 0;
				if ((ts.rotation+dtheta < ts.minRotation) || (ts.rotation+dtheta > ts.maxRotation)) dtheta = 0;
				if ((ts.rotationX+dthetaX < ts.minRotationX) || (ts.rotationX+dthetaX > ts.maxRotationX)) dthetaX = 0;
				if ((ts.rotationY+dthetaY < ts.minRotationY) || (ts.rotationY+dthetaY > ts.maxRotationY)) dthetaY = 0;
				if ((ts.rotationZ+dthetaZ < ts.minRotationZ) || (ts.rotationZ+dthetaZ > ts.maxRotationZ)) dthetaZ = 0;				
				
				//////////////////////////////////////////////////////
				// 3d affine transform here
				
				//if (ts.transform3d) {
					// TODO: 3D affine transformations
				//}
				
				
				////////////////////////////////////////////////////
				// flash 2.5D only
				// HAVING 3D MATRIX PASS THROUGH ENABLES ROTATEXYZ TO PASS THROUGH
				if (ts.transform.matrix3D)// check for 3D matrix,
				{							
					// get the projection offset created by the z-position	
					if (ts.transform.perspectiveProjection) // ts can define location projection
						focalLength = ts.transform.perspectiveProjection.focalLength;
					else // use global projection from root
						focalLength = ts.root.transform.perspectiveProjection.focalLength;
					ratio = focalLength / (focalLength + ts.z);
					
					affine_modifier3D.copyFrom(ts.transform.matrix3D);
						affine_modifier3D.appendTranslation(-t_x, -t_y, 0);
						affine_modifier3D.appendRotation(dtheta, Vector3D.Z_AXIS); 	
						affine_modifier3D.appendScale(1 + dsx, 1 + dsy, 1); 		
						affine_modifier3D.appendTranslation(t_x + dx/ratio, t_y + dy/ratio, 0);
					ts.transform.matrix3D = affine_modifier3D;		
				}

				//////////////////////////////////////////////////////
				// 2d display object only
				else
				{
					//dtheta *= DEG_RAD; // new 
					affine_modifier = ts.transform.matrix;
					//affine_modifier = ts.transform.matrix3D;
						affine_modifier.translate( - t_x, - t_y);
						affine_modifier.rotate(dtheta);
						affine_modifier.scale(1 + dsx, 1 + dsy);	
						affine_modifier.translate( dx + t_x, dy + t_y);
					ts.transform.matrix =  affine_modifier
					transformAffineDebugPoints();
				}

				updateLocalProperties();
				
				if (ts.vto) ts.updateVTO();	
			}
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////
		//
		/////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		* @private
		*/
		private function pre_InitTransformPoints():void
		{
			var points:Array = new Array();
				points[0] = new Point(0, 0);
				points[1] = new Point(0, 0);
				points[2] = new Point(0, 0);
				points[3] = new Point(0, 0);
				points[4] = new Point(0, 0);
				
			trO.affinePoints = points;	
			trO.transAffinePoints = points;
		}
		/**
		* @private
		*/
		private function initTransformPoints():void
		{
			if (trO.transformPointsOn)
				{	
				// takes the pre-transformed inial properties of the display object and seeds the debug points//317 ,241//250, 190
				//if(traceDebugMode)trace("init center point", this.width,this.height);
				
				// check for 3D transform flag
				if (ts.transform3d) 
				{
					// is this neccesary in 3D
				}
				
				// check for 3D matrix, flash 3D
				else if (ts.transform.matrix3D) 
				{
					// is this neccesary in 3D
				}
				
				// default to 2D
				else {
					var mem_modifier:Matrix = ts.transform.matrix;
					var _modifier:Matrix = ts.transform.matrix;
						_modifier.rotate(-ts.rotation* DEG_RAD);
						_modifier.scale(1 / ts.scaleX, 1 / ts.scaleY);	
					ts.transform.matrix = _modifier
				
					trO.pre_init_width = ts.width;
					trO.pre_init_height = ts.height;
					
					// revert back
					ts.transform.matrix = mem_modifier;
					
					// create original point net
					var affine_points:Array = new Array();
						affine_points[0] = new Point(0, 0);
						affine_points[1] = new Point( trO.pre_init_width, trO.pre_init_height);
						affine_points[2] = new Point(trO.pre_init_width, 0);
						affine_points[3] = new Point(0,trO.pre_init_height);
						affine_points[4] = new Point( trO.pre_init_width / 2, trO.pre_init_height / 2); //center point
					trO.affinePoints = affine_points;
					trO.init_center_point = true;
				}
				

				
			}
		}
		
		private var modifier:Matrix = new Matrix();
		/**
		* @private
		*/
		private function transformAffineDebugPoints():void 
		{			
			if (trO.transformPointsOn)
				{	
				// get parent transforms
				modifier.copyFrom(ts.transform.concatenatedMatrix); 
					
				// transform point net
				var trans_affine_points:Array = new Array();
					trans_affine_points[0] =  modifier.transformPoint(trO.affinePoints[0]);
					trans_affine_points[1] =  modifier.transformPoint(trO.affinePoints[1]);
					trans_affine_points[2] =  modifier.transformPoint(trO.affinePoints[2]);
					trans_affine_points[3] =  modifier.transformPoint(trO.affinePoints[3]);
					trans_affine_points[4] =  modifier.transformPoint(trO.affinePoints[4]); // trans formed center point
				trO.transAffinePoints = trans_affine_points;
				}
		}
		
		/**
		* @private
		*/
		private function manageTransformEventDispatch():void 
		{
			//if(traceDebugMode) trace("transform event dispatch");
		
				if ((ts.transformStart) && (ts.transformEventStart)) {
					ts.dispatchEvent(new GWTransformEvent(GWTransformEvent.T_START,id));
					if((ts.tiO)&&(ts.tiO.timelineOn)&&(ts.tiO.transformEvents)) ts.tiO.frame.transformEventArray.push(new GWTransformEvent(GWTransformEvent.T_START,id));
				}
				if ((ts.transformComplete) && (ts.transformEventComplete))  {
					ts.dispatchEvent(new GWTransformEvent(GWTransformEvent.T_COMPLETE,id));
					if((ts.tiO)&&(ts.tiO.timelineOn)&&(ts.tiO.transformEvents)) ts.tiO.frame.transformEventArray.push(new GWTransformEvent(GWTransformEvent.T_COMPLETE,id));
				}
				
				if ((dx != 0) || (dy != 0) || (dsx != 0) || (dsy != 0) || (dtheta != 0)) {
					ts.dispatchEvent(new GWTransformEvent(GWTransformEvent.T_TRANSFORM, { dx:dx, dy:dy, dsx: dsx, dsy:dsy, dtheta:dtheta } ));
					if((ts.tiO)&&(ts.tiO.timelineOn)&&(ts.tiO.transformEvents)) ts.tiO.frame.transformEventArray.push(new GWTransformEvent(GWTransformEvent.T_TRANSFORM, { dsx:dx, dy:dy, dsx: dsx, dsy:dsy, dtheta:dtheta }));
				}
				if ((dx != 0) || (dy != 0)) {
					ts.dispatchEvent(new GWTransformEvent(GWTransformEvent.T_TRANSLATE, { dx:dx, dy:dy } ));
					if((ts.tiO)&&(ts.tiO.timelineOn)&&(ts.tiO.transformEvents)) ts.tiO.frame.transformEventArray.push(new GWTransformEvent(GWTransformEvent.T_TRANSLATE, { dx:dx, dy:dy } ));
				}
				if (dtheta != 0) {
					ts.dispatchEvent(new GWTransformEvent(GWTransformEvent.T_ROTATE, { dtheta:dtheta } ));
					if((ts.tiO)&&(ts.tiO.timelineOn)&&(ts.tiO.transformEvents)) ts.tiO.frame.transformEventArray.push(new GWTransformEvent(GWTransformEvent.T_ROTATE, { dtheta:dtheta } ));
				}
				if ((dsx != 0) || (dsy != 0)) {
					ts.dispatchEvent(new GWTransformEvent(GWTransformEvent.T_SCALE, { dsx: dsx, dsy:dsy } ));
					if((ts.tiO)&&(ts.tiO.timelineOn)&&(ts.tiO.transformEvents)) ts.tiO.frame.transformEventArray.push(new GWTransformEvent(GWTransformEvent.T_SCALE, { dsx: dsx, dsy:dsy } ));
				}
		}
		
		private static function calcAngle(adjacent:Number, opposite:Number):Number
			{
				if (adjacent == 0) return opposite < 0 ? 270 : 90 ;
				if (opposite == 0) return adjacent < 0 ? 180 : 0 ;
				
				if(opposite > 0) return adjacent > 0 ? 360 + Math.atan(opposite / adjacent) * RAD_DEG : 180 - Math.atan(opposite / -adjacent) * RAD_DEG ;
				else return adjacent > 0 ? 360 - Math.atan( -opposite / adjacent) * RAD_DEG : 180 + Math.atan( opposite / adjacent) * RAD_DEG ;
				
				//if(opposite > 0) return adjacent > 0 ? Math.atan(opposite / adjacent) * RAD_DEG : 180 - Math.atan(opposite / -adjacent) * RAD_DEG ;
				//else return adjacent > 0 ? 360 - Math.atan( -opposite / adjacent) * RAD_DEG : Math.atan( opposite / adjacent) * RAD_DEG ;
				
				return 0;
		}
	}
}