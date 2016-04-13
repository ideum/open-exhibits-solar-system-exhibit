////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    gestureContinuous.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.core 
{	
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.GestureListObject;
	import com.gestureworks.objects.GestureObject;
	import com.gestureworks.objects.TransformObject;
	import com.gestureworks.objects.DimensionObject;
	import flash.geom.Point;

	public class TouchPipeline
	{
		// A collection of gestures attached to this object.
		private var touchObjectID:int;
		private var ts:Object;
		private var gO:GestureListObject;
		private var cO:ClusterObject;
		private var trO:TransformObject;
		
		private var i:uint;
		private var j:uint;
		private var gn:uint

		public function TouchPipeline(_id:int) 
		{	
			touchObjectID = _id;
			init();
		}

		public function init():void
		{	
			ts = GestureGlobals.gw_public::touchObjects[touchObjectID];
			cO = ts.cO;
			gO = ts.gO;
			trO = ts.trO;
		}
		
		public function processPipeline():void
		{
			
			gn = gO.pOList.length;
			
			//trace();
			//trace("processing pipeline--------------------------------",gn);
			
			
			for (i=0; i < gn; i++) 
				{
				var dn:uint = gO.pOList[i].dList.length;
				
					var g:GestureObject = gO.pOList[i];
					
					//g.activeEvent = true;
					
						for (j=0; j < dn; j++) 
						{
							var gDim:DimensionObject = g.dList[j];
							
							////////////////////////////////////////////////////////
							//trace("pipeline in",gO.pOList[i].dList[j].clusterDelta);
							////////////////////////////////////////////////////////
							// PULL DATA FROM CLUSTER
							gDim.gestureDelta = gDim.clusterDelta;
							
							//trace(j, gDim.gestureDelta, gDim.clusterDelta);
							
														
							//gO.pOList[i].dList[j].gestureDeltaCache = gO.pOList[i].dList[j].gestureDelta; // PRE FILTERED DELTA CACHE
							//trace("push cache front pipe")
							
							
									// turn of all filters  //------------- may also want to turn off when delta is already zero????// but may intefere with complete event
									if (ts.gestureFilters) {
									//if((ts.gestureFilters)&&(gDim.activeDim)){ // ACTIVE DIM DEPENDANCY KILLS COMPLETE LOGIC WHEN RELEASE AFTER NO MOVEMENT
									

											///////////////////////////////////////////////////////////
											// average filter
											///////////////////////////////////////////////////////////
											
											if (gDim.mean_filter)
											{
												if(!gDim.gestureDeltaArray) gDim.gestureDeltaArray = new Array();
												var hist:uint = 8;
												var ln:uint =  gDim.gestureDeltaArray.length;
												var ln0:Number = 1 / ln;
												var delta:Number = gDim.gestureDelta
												var mvar:Number = 0;
												
												gDim.gestureDeltaArray.push(delta);
												if (ln >= hist) gDim.gestureDeltaArray.shift();
												
	
												for (var p:int = 0; p < ln; p++){ mvar += gDim.gestureDeltaArray[p];}
												mvar *= ln0;
												if(mvar) gDim.gestureDelta = mvar;	
											}
											

											////////////////////////////////////////////////////////////////////////////////////////////
											// easing block
											////////////////////////////////////////////////////////////////////////////////////////////

											if ((ts.gestureReleaseInertia) && (gDim.release_inertia_filter)) {
											//trace("easing block")
												// select new gesture delta or cached delta based // based on N activity
												if (ts.tpn!=0)
												{
													//when touching calculate new deltas 
													if ((ts.tpn >= g.nMin) && (ts.tpn <= g.nMax) || (ts.tpn == g.n)) 
													{
														// fill cache with new values
														gDim.gestureDeltaCache = gDim.gestureDelta;
														//trace("push cache inertia n!=0 match");
														
														// RESTART MATCHED DORMANT TWEEN THREADS
														//if (gO.pOList[i][j].release_inertia_filter)
														//{
														gDim.release_inertiaOn = true;
														gDim.release_inertia_count = 0;
															//if (ts.traceDebugMode) trace("restart tween");
														//}
														
														// set phase 
														g.passive = false;
														g.active = true;
														//trace("touch active",i,j);
													}
													else {
														// when not meeting gesture calc conditions
														// but still touching use cached delta
														gDim.gestureDelta = gDim.gestureDeltaCache;
														//trace("pull chache inertia n==0 no match");
														
														// set phase
														g.passive = true;
														g.active = false;
														//trace("touch passive cache",i,j);
													}
												}
												else {
													// when not touching use cached delta
													gDim.gestureDelta = gDim.gestureDeltaCache;
													//trace("pull chache inertia  n==0 match");
													
													// set phase
													g.passive = true;
													g.active = false;
												}
												
												// when touching but when not matching n values // or when not touching // tween cached deltas 
												if ((ts.tpn < g.nMin)||(ts.tpn > g.nMax)||(ts.tpn == 0))
												{
													// set to passive phase
													g.passive = true;
													g.active = false;
													
													//trace("test",ts.N, i);
													// gesturetweenon no longer needed
													//if ((ts.gestureTweenOn) && (gO.pOList[i][j].release_inertiaOn) && (gO.pOList[i][j].release_inertia))
													if(gDim.release_inertiaOn)//&&(gO.pOList[i][j].release_inertia_filter)
													{
														var count:uint = gDim.release_inertia_count++;
															
															if (gDim.gestureDelta != 0)
															{
																//gO.pOList[i].dList[j].release_inertiaOn = true;
																gDim.gestureDelta *= gDim.release_inertia_factor * Math.pow(gDim.release_inertia_base, count);
															}
															
															//trace("gdelta",Math.abs(gO.pOList[i].dList[j].gestureDelta),gO.pOList[i].dList[j].delta_min);
															
															if ((count > gDim.release_inertia_Maxcount)||(Math.abs(gDim.gestureDelta) < gDim.delta_min))
															{
																gDim.release_inertiaOn = false;
																gDim.gestureDelta = 0;
																//ts.gO.pOList[i][j].gestureDeltaCache =0;
																gDim.release_inertia_count = 0;
															}
															//trace("wow")
													}
													else {
														gDim.gestureDelta = 0;
														//trace("shut down zero delta");
													}
													//trace("touch passive tween",i,j,gO.pOList[i][j].gestureDelta);
												}
											}
											
											///////////////////////////////////////////////////////////////////////////////////////////
											// MULTIPLY FILTER
											// multiplies delta by a const of proportionality
											// produces linear,quadartic,cubic or polynomial function
											///////////////////////////////////////////////////////////////////////////////////////////
											
											if (gDim.multiply_filter)
											{
												if (gDim.func) gDim.gestureDelta = functionGenerator(gDim.func, gDim.gestureDelta , gDim.func_factor);
												else gDim.gestureDelta = gDim.func_factor * gDim.gestureDelta;
											}
								
										
											///////////////////////////////////////////////////////////////////////////////////////////
											// DELTA FILTER
											// limits gesture deltas to delta min value
											// reduces the number of events and unnesesary transformations by zeroing small deltas
											//////////////////////////////////////////////////////////////////////////////////////////
											
											
											if (gDim.delta_filter)
											{
												/*
												if (Math.abs(gDim.gestureDelta) < gDim.delta_min) gDim.gestureDelta = 0;
												
												if (Math.abs(gDim.gestureDelta) > gDim.delta_max) 
												{
													if (gDim.gestureDelta < 0) gDim.gestureDelta = -gDim.delta_max;
													if (gDim.gestureDelta > 0) gDim.gestureDelta = gDim.delta_max;
												}
												*/
												
												if (!gDim.delta_directional)
												{
													if (Math.abs(gDim.gestureDelta) < Math.abs(gDim.delta_min))
													{
														if ((gDim.gestureDelta < 0 && gDim.delta_min < 0)||(gDim.gestureDelta > 0 && gDim.delta_min > 0))	gDim.gestureDelta = 0;
													}
													if (Math.abs(gDim.gestureDelta) > Math.abs(gDim.delta_max)) 
													{
														if ((gDim.gestureDelta < 0 && gDim.delta_max < 0)||(gDim.gestureDelta > 0 && gDim.delta_max > 0)) gDim.gestureDelta = gDim.delta_max;
													}
												}
												else {
													//trace(gDim.gestureDelta)
													if ((gDim.gestureDelta < 0) && (gDim.delta_min < 0) && (gDim.delta_max < 0))
													{
														if ((Math.abs(gDim.gestureDelta) > Math.abs(gDim.delta_max))||(Math.abs(gDim.gestureDelta) < Math.abs(gDim.delta_min))) gDim.gestureDelta = 0;
													}
													else {
														if ((gDim.gestureDelta > gDim.delta_max)||(gDim.gestureDelta < gDim.delta_min)) gDim.gestureDelta = 0;
													}
													//trace(gDim.gestureDelta,gDim.delta_min,gDim.delta_max)
												}
											}
											
									
											////////////////////////////////////////////////////////////////////////////////////////////
											// VALUE FILTER
											// limit gesture values 
											// allows for value bounds so that gestures mapped to known object properties can be managed
											/////////////////////////////////////////////////////////////////////////////////////////////
											
											//COULD IN THEORY WORK WITH NON NATIVE TRANSFORMS BUT FOR NOW NO
											if ((gDim.boundary_filter)&&(ts.nativeTransform))
											{	
												//trace(gDim.gestureValue,trO.obj_x,gDim.target_id) 
												
												if (Math.abs(gDim.gestureValue) < gDim.boundary_min)
												{
													if (gDim.gestureDelta < 0) gDim.gestureDelta = 0;
												}
												if (Math.abs(gDim.gestureValue) > gDim.boundary_max) 
												{
													if (gDim.gestureDelta > 0) gDim.gestureDelta = 0;
												}
											}

								////////// END MAIN FILTER BLOCK ///////////////////////////////////////////////
								}
								
								/////////////////////////////////////////////////////////////////////////////
								//fill cache
								//////////////////////////////////////////////////////////////////////////////
								// cache reset only when delta is non zero 
								// otherwise cluster delta is zerod and cache zerod before cched value is pushed into gesure event
								if ((!ts.gestureReleaseInertia) && (!gDim.release_inertia_filter)) // so that ineertia cache is not overwirtten by flick and swipe mechanism
								{
									//if (gDim.gestureDelta != 0)
									//if (gDim.clusterDelta != 0)
									//if (g.activeEvent)
									
									// ONLY FILL CACHE WITH GENERATED VALUES
									if ((ts.tpn!=0)) gDim.gestureDeltaCache = gDim.gestureDelta;//||(ts.fn!=0)
									
								}
								//trace("pipeline end", gO.pOList[i].dList[j].gestureDeltaCache)
								
								///////////////////////////////////////////////////////////////////////////////////////////////
								// END FILTER BLOCK
								///////////////////////////////////////////////////////////////////////////////////////////////
								
								// ENSURES ADDITIVE DELTAS DO NOT ACCUMILATE OUTSIDE OF EACH "FRAME"
								// 	MUST HAPPEN BEFIORE MAPPING OTHERWISE GESTURES THAT MAP DELTAS TO SAME VAR WILL BE OVERWITTEN
								if (gDim.target_id) trO[gDim.target_id] = 0;
								
								////////////////////////////////////////////////////////////////////////////////////////////////////
								// active gesture event switch
								// deactivates gesture processing on gesture object if gesture deltas are zero for each dimention
								// is overrriden when object is touched ( when cluster analysis occures
								////////////////////////////////////////////////////////////////////////////////////////////////////
								
								if (gDim.gestureDelta != 0) g.activeEvent = true;
								//else g.activeEvent = false;
								//trace("gesturedelta",g.event_type, gDim, gDim.gestureDelta,g.activeEvent )

								//////////////////////////////////////////////////////////
								//trace("pipeline out", gDim.gestureDelta);
								//////////////////////////////////////////////////////////
						}	
						
						//////////////////////////////////////////////////////////////////////////////
						//FINAL GESTURE MODAL CHECK
						//////////////////////////////////////////////////////////////////////////////
						if ((!g.active) && (!g.passive)&&(!g.activeEvent)) 
						{
							//g.dispatchEvent = false;
						}
						
					//	trace(g.active,g.passive,g.activeEvent,g.dispatchEvent, ts.tpn, ts.mpn);			
			}
			
			////////////////////////////////////////////////////////////////////////////////////////////////////
			// mapping defined native  property values
			// map gesture object into transform object
			////////////////////////////////////////////////////////////////////////////////////////////////////
			// NEEDS TO BE SPERATE FROM MAIN PROCESSING LOOPE SO THAT FLITERS CAN BE INDEPENDANTLY TURNED OFF
			
			
			/////////////////////////////////////////////////////////////////////////////////////////////////////////
			// core transform properties //default map for direct gesture manipulations
			/////////////////////////////////////////////////////////////////////////////////////////////////////////
							
						/////////////////////////////////////////////////////
						// TOUCH CLUSTER
						/////////////////////////////////////////////////////
						trO.x =	cO.x; // NEED FOR AFFINE TRANSFORM NON NATIVE
						trO.y =	cO.y; // NEED FOR AFFINE TRANSFORM NON NATIVE
						trO.z =	cO.z; // 3d--
						
						trO.width = cO.width
						trO.height = cO.height
						trO.length = cO.length//3d--
						trO.radius = cO.radius
						
						trO.scale = cO.separation
						trO.scaleX = cO.separationX
						trO.scaleY = cO.separationY
						trO.scaleZ = cO.separationZ//3d--
								
						
						trO.rotation = cO.rotation
						trO.rotationX = cO.rotationX//3d--
						trO.rotationY = cO.rotationY//3d--
						trO.rotationZ = cO.rotationZ//3d--
						trO.orientation = cO.orientation
							
						
						// TODO: Check into this, what does this mean?
						trO.localx =100//cO.x-ts.x; 
						trO.localy =100//cO.y - ts.y; 
						
						//trace("pipeline",trO.x,trO.y,trO.z);
						
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////
			// map dynamic cluster deltas results into gesture object
			////////////////////////////////////////////////////////////////////////////////////////////////////////
			if (ts.nativeTransform)
			{	
				for (i=0; i < gn; i++) 
					{
						var dn1:uint = gO.pOList[i].dList.length;
						for (j=0; j < dn1; j++) 
							{
							if (gO.pOList[i].dList[j].target_id)
								{
									// map transform limits
									if (gO.pOList[i].dList[j].target_id == "dsx") gO.pOList[i].dList[j].gestureValue = trO.obj_scaleX;
									if (gO.pOList[i].dList[j].target_id == "dsy") gO.pOList[i].dList[j].gestureValue = trO.obj_scaleY;
									if (gO.pOList[i].dList[j].target_id == "dsz") gO.pOList[i].dList[j].gestureValue = trO.obj_scaleZ;//3d--
									if (gO.pOList[i].dList[j].target_id == "dtheta") gO.pOList[i].dList[j].gestureValue = trO.obj_rotation;
									if (gO.pOList[i].dList[j].target_id == "dthetaX") gO.pOList[i].dList[j].gestureValue = trO.obj_rotationX;//3d--
									if (gO.pOList[i].dList[j].target_id == "dthetaY") gO.pOList[i].dList[j].gestureValue = trO.obj_rotationY;//3d--
									if (gO.pOList[i].dList[j].target_id == "dthetaZ") gO.pOList[i].dList[j].gestureValue = trO.obj_rotationZ;//3d--
									if (gO.pOList[i].dList[j].target_id == "dx") gO.pOList[i].dList[j].gestureValue = trO.obj_x;
									if (gO.pOList[i].dList[j].target_id == "dy") gO.pOList[i].dList[j].gestureValue = trO.obj_y;
									if (gO.pOList[i].dList[j].target_id == "dz") gO.pOList[i].dList[j].gestureValue = trO.obj_z;//3d--
									
								
									////////////////////////////////////////////////////////////////////////////////////////////////
									//NOTE: TAERGETS X,Y,Z WILL BE WRITTEN INTO DELTAS AND MAPPED INTO THE TRANSFORMATION OBJECT 
									//WHEN NATIVE IS ON. THIS WILL CAUSE MOTION TAP TO TRY AND MOVE DISPLAY OBJECTS
									////////////////////////////////////////////////////////////////////////////////////////////////
									
									// ENSURE DELTAS MAPPED TO THE SAME PROPERTY ARE ADDITIVE IN A "FRAME"
									trO[gO.pOList[i].dList[j].target_id] += gO.pOList[i].dList[j].gestureDelta;
									//if (ts.traceDebugMode) 
									//trace("gesture data from pipeline", i, j, gO.pOList[i].gesture_id,gO.pOList[i].dList[j].gestureDelta, trO[ts.gO.pOList[i].dList[j].target_id],ts.gO.pOList[i].dList[j].target_id);
													
									//trace("target_values", ts.trO[ts.gO.pOList[i].dList[j].target_id]);
									}
								}					
					}
				//trace("testing", trO.obj_rotation);	
			}
			
			
			////////////////////////////////////////
			// accumulate gesture states to set global gesture object state
			// check no gesture is tweening
			// confirm gesture states
			////////////////////////////////////////
			
			//if (gO.active)
			//{
				// close tween
				ts.gestureTweenOn = false;
				
				// check for open tween
				for (i=0; i < gn; i++) 
				{
					if (!ts.gestureTweenOn) // if desired condition not already met
					{
						var dn0:uint = gO.pOList[i].dList.length;
						for (j = 0; j < dn0; j++) if ((gO.pOList[i].dList[j].release_inertiaOn)) ts.gestureTweenOn = true;
					}
				}
				
				//NOTE WILL NEED TO MAKE GESTURE OBJECT SPECIFIC
				// global logic
				 if ((!ts.gestureTweenOn)&&(ts.gO.passive)||(!ts.gestureTweenOn)&&(gO.release)) // must force state to wait for passive phase change
				 {
					gO.active = false;
					gO.passive = false;
					gO.complete = true;
					//trace("set complete")
				}
			//}
			//trace(ts.gestureTweenOn,gO.release,ts.gO.passive)
			//////////////////////////////////////////////////////////////////////////////
			
			
			
		}
		
		private function functionGenerator(type:String,b:Number,k:Number):Number {
			
			var a:Number;
				if (type == "linear") 			a = b * k;
				else if (type == "quadratic") 	a = b * b * k; //FIX NEGATIVE
				else if (type == "cubic") 		a = b * b * b * k;
				else if (type == "exp2") 		a = Math.pow(2, k * b);
				else if (type == "exp10") 		a = Math.pow(10, k * b);
			return a
		}
	}
}