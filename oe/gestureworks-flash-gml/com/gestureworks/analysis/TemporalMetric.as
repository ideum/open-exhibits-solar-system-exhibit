////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    gestureDiscrete.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.analysis 
{
	import com.gestureworks.objects.GestureObject;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	
	//import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.core.GML;
	import com.gestureworks.objects.FrameObject;
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.PointObject;
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.events.GWGestureEvent;
	
	//import com.gestureworks.analysis.paths.PathCollection;
	//import com.gestureworks.analysis.paths.PathCollectionIterator; PathCollectionIterator;
	//import com.gestureworks.analysis.paths.PathDictionary; PathDictionary;
	//import com.gestureworks.analysis.paths.PathProcessor; PathProcessor;
		
	public class TemporalMetric
	{
		private var touchObjectID:int;
		private var ts:Object;//	private var ts:TouchSprite;
		private var cO:ClusterObject;
		
		// pause time between gesture event counting cycles
		private var tap_pauseTime:int = 0;
		private var dtap_pauseTime:int = 0;
		private var ttap_pauseTime:int = 0;
		
		// sets gesture id for individual tap events
		private var tapID:int = 0;
		private var dtapID:int = 0;
		private var ttapID:int = 0;
		private var holdID:int = 0;
		
		// sets gesture id for tap clusters
		private var ntapID:int = 0;
		private var ndtapID:int = 0;
		private var nttapID:int = 0;
		
		// counts event threads on timeline of touch object
		private var tapEventCount:int = 0;
		private var dtapEventCount:int = 0;
		private var ttapEventCount:int = 0;
		
		private var DIM:uint; 
		
		public function TemporalMetric(_id:int) {
			
			touchObjectID = _id;
			init();
		}
		
		public function init():void
		{
			ts = GestureGlobals.gw_public::touchObjects[touchObjectID];
			cO = ts.cO;
			
			if (ts.traceDebugMode) trace("init gesture discrete analysis");
			//trace(GestureGlobals.touchFrameInterval)
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// HOLD GESTURE
		////////////////////////////////////////////////////////////////////////////////////////
		public function findLockedPoints(key:int):void
		{
			var g:GestureObject = ts.gO.pOList[key]; 
			// REDUNDANT AS ONLY CALLED IF MEETS N CRITERIA
			var hold_number:int = ts.N;//gO.pOList[key].n; 
			var hold_dist:int = g.point_translation_max;
			
			//POINT COUNT FILTERING
			//if (g.n && g.n != hold_number) //HOLD NUMBER IS NOT GOOD MEASURE
				//return;
			//else if (!g.n && (hold_number < g.nMin || hold_number > g.nMax))
				//return;
			
			//HOLD TIME MEASURED IN FRAMES
			var	hold_time:int = Math.ceil(g.point_event_duration_min * GestureWorks.application.frameRate * 0.001)							
			//trace("hold ",GestureGlobals.touchFrameInterval,hold_time,g.point_event_duration_min,GestureWorks.application.frameRate,t)
											
			
			var dn:uint = g.dList.length;
			var N:uint = cO.tpn//cO.n;
			var LN:uint = cO.hold_n;
			
			//clear hold position
			cO.hold_x = 0;
			cO.hold_y = 0;
			
			// NOTE SHOULD PULL HOLD X AND Y AND N FROM CLUSTER AND MAKE LOCAL TO TEMPORALMETRIC
			// WILL CLEAN OUT KINEMETRIC AND MOVE TEMPORAL DATA STRUCTS TO TEMPORAL METRIC ASSOCIATED WITH CLUSTER
			///////////////////////////////////////////////////
			// HOLD_X / HOLD_Y / HOLD_N
			// TAP_X / TAP_Y / TAP_N
			// DTAP_X / DTAP_Y / DTAP_N
			// TTAP_X / TTAP_Y / TTAP_N
			// HOLD_TAP_X / HOLD_TAP_Y / HOLD_TAP_N
			
			
				///////////////////////////////
				// check for locked points
				///////////////////////////////
				
							for (var i:int = 0; i < N; i++)
								{
								var pt:PointObject = cO.pointArray[i]
								
								//trace("hold count",i,pointList[i].holdCount, hold_time,hold_dist,hold_number);
								if ((Math.abs(pt.dx) < hold_dist) && (Math.abs(pt.dy) < hold_dist))
									{
									if (pt.holdCount < hold_time) { // non repeat
									
										pt.holdCount++;
															
										if (pt.holdCount >= hold_time) 
											{
											pt.holdLock = true; 
											cO.hold_x += pt.x;
											cO.hold_y += pt.y;
											//trace("why here")
											}	
										}
										else {
											pt.holdCount = 0; // reset count
											pt.holdLock = false; // add this feature here
											}
									}
								}
								
					///////////////////////
					// count locked points
					//////////////////////
						LN = 0;
						for (i = 0; i < N; i++)
						{
							if (pt.holdLock) LN++;
						}
					//trace("LOCKED",LN)
					//////////////////////			
							
					//trace("hold nnn", LN,hold_number,cO.hold_n, g.n,g.nMax,g.nMin);
						
						//if (LN) {
						
							//if ((LN == hold_number) || (hold_number == 0)) 
							if (LN && ((LN >= g.nMin)&&(LN <= g.nMax) || (LN == g.n))) 
								{
								
								cO.hold_x *= 1 / LN//k0;
								cO.hold_y *= 1 / LN//k0;
								cO.hold_n = LN;
							
								// hold event id
								holdID++;
								
									/////////////////////////////////////
									// push data (bypasses filtering for now)
									/////////////////////////////////////
									
									g.data.x = cO.hold_x; 
									g.data.y = cO.hold_y; 
									
									var d:Object = new Object();
										d["x"] = cO.hold_x;
										d["y"] = cO.hold_y;
										d["n"] = cO.hold_n;
									
									for (DIM = 0; DIM < dn; DIM++)	g.dList[DIM].gestureDelta = d[g.dList[DIM].property_result];
									
									//////////////////////////////////////
									
									//trace("HOLD EVENT PUSHED",cO.hold_x,cO.hold_y,cO.hold_n,LN);
									
									var hold_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.HOLD, { x:cO.hold_x, y:cO.hold_y, gestureID:holdID , id:key} );
									ts.tiO.frame.gestureEventArray.push(hold_event);
								}
							//trace("cluster",cO.hold_x,cO.hold_y,LN,N, cO.hold_n)

						else {
							cO.hold_x = 0;
							cO.hold_y = 0;
							cO.hold_n = 0;
						}
						
		}
		
		
		public function findGestureTap(event:TouchEvent, key:int ):void // each time there is a touchEnd
		{
			//if (ts.traceDebugMode) 
			//trace("find taps---------------------------------------------------------", key, ts.gO.release);
			
			// CHECK GML COMPATABILITY
			var tap_time:int = Math.ceil(ts.gO.pOList[key].point_event_duration_max * GestureWorks.application.frameRate * 0.001)	
			//var tap_time:int = Math.ceil(ts.gO.pOList[key]["tap_x"].point_event_duration_threshold / GestureGlobals.touchFrameInterval);//10
			var tap_dist:int = ts.gO.pOList[key].point_translation_max;
			
			//trace(tap_time,tap_dist);
			
			var pointEventArray:Vector.<GWTouchEvent> = ts.tiO.frame.pointEventArray
				
				for (var p:int = 0; p < pointEventArray.length; p++) 
				{
					//trace("point event array", ts.tiO.frame.pointEventArray[p].type)
					
					////////////////////////////////////////
					// check current frame first
					////////////////////////////////////////
					
					
					// match type and id
					if ((pointEventArray[p].type =="gwTouchBegin" || pointEventArray[p].type =="touchBegin")&&(pointEventArray[p].touchPointID == event.touchPointID))
						{
							var dx:Number = Math.abs(pointEventArray[p].stageX - event.stageX)
							var dy:Number = Math.abs(pointEventArray[p].stageY - event.stageY)
					
							// match dist							
							if ((dx < tap_dist) && (dy < tap_dist))
							{
								// add tap event to gesture timeline 
								// uses gwTouchEnd id and position
								//trace("Current Frame TAP", pointEventArray[p].touchPointID);
								tapID ++;
								var tap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.TAP, { x:event.stageX, y:event.stageY, localX:event.localX, localY:event.localY, gestureID:tapID , id:key} );
								ts.tiO.frame.gestureEventArray.push(tap_event);
								//trace("tap detected in frame");
								//ts.onGestureTap(tap_event);
								return; // must exit if finds as do not want to refind
							}	
						}
					else {
					////////////////////////////////////////
					//look in history
					////////////////////////////////////////
						
							for (var i:int = 0; i < tap_time; i++) // 20 fames
								{
							
								if (ts.tiO.history.length > i)
								{
								pointEventArray = ts.tiO.history[i].pointEventArray;
							
									for (var j:int = 0; j < pointEventArray.length; j++) 
									{
										if ((pointEventArray[j].type =="gwTouchBegin" || pointEventArray[j].type =="touchBegin")&&(pointEventArray[j].touchPointID == event.touchPointID))
										{
											var dx0:Number = Math.abs(pointEventArray[j].stageX - event.stageX)
											var dy0:Number = Math.abs(pointEventArray[j].stageY - event.stageY)
											
											//trace(dx0,dy0)
											
											if ((dx0 < tap_dist) && (dy0 < tap_dist))
											{
												// add tap event to gesture timeline 
												// uses gwTouchEnd id and position
												//trace("History TAP", pointEventArray[j].touchPointID);
												tapID ++;
												var tap_event0:GWGestureEvent = new GWGestureEvent(GWGestureEvent.TAP, { x:event.stageX, y:event.stageY, localX:event.localX, localY:event.localY, gestureID:tapID , id:key} );
												//if (ts.tiO.pointEvents)
												ts.tiO.frame.gestureEventArray.push(tap_event0);
												//trace("tap detected in recent history");
												//-- would normally call custom tap count function and double count checks ts.onGestureTap(tap_event0);
												
												//ts.gO.pOList[key].activeEvent = true;
												
												return; //must exit if finds, as need most recent pair
											}	
										}	
									}
								}	
								}	
						}
						/////////////////////////////////////////
				}
		}
		
		
		public function findGestureDoubleTap(event:GWGestureEvent,key:int):void
		{
			//if (ts.traceDebugMode)
			//trace("\nfind d taps---------------------------------------------------------",key);
		
				var dtap_time:int = Math.ceil(ts.gO.pOList[key].point_event_duration_max * GestureWorks.application.frameRate * 0.001)	
				//var dtap_time:int = Math.ceil(ts.gO.pOList[key]["double_tap_x"].point_interevent_duration_threshold / GestureGlobals.touchFrameInterval);//20
				var dtap_dist:int = ts.gO.pOList[key].point_translation_max;
				
				var	gestureEventArray:Vector.<GWGestureEvent> = new Vector.<GWGestureEvent>;
				
				
				
				// find tap pairs 
				// dont need current frame as never double tap in a single frame
				// LOOK IN HISTORY
				for (var i:uint = 0; i < dtap_time; i++) 
					{
					if (ts.tiO.history.length > i)
					{
					if (ts.tiO.history[i])
					{
					gestureEventArray = ts.tiO.history[i].gestureEventArray;
					
					//trace(dtap_time, dtap_dist, gestureEventArray.length);
					
							for (var j:uint = 0; j < gestureEventArray.length; j++) 
								{
								//	trace("in dtap search",gestureEventArray[j].type,i,j, event.value.gestureID, gestureEventArray[j].value.gestureID);
									if ((gestureEventArray[j].type =="tap")&&(event.value.gestureID != gestureEventArray[j].value.gestureID)&&(event.value.gestureID!=undefined)&&(gestureEventArray[j].value.gestureID!=undefined)) // so as no tto count self
									{
										var distX:Number = Math.abs(event.value.x - gestureEventArray[j].value.x);
										var distY:Number = Math.abs(event.value.y - gestureEventArray[j].value.y);
										
										if ((distX < dtap_dist) && (distY < dtap_dist)) 
										{
											//trace("hist DOUBLE TAP",distX,distY);
											var spt:Point = new Point (event.value.x, event.value.y); // stage point
											var lpt:Point = ts.globalToLocal(spt); //local point
											
											dtapID++;
											var dtap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.DOUBLE_TAP, { x:spt.x , y:spt.y, stageX:spt.x , stageY:spt.y, localX:lpt.x , localY:lpt.y, gestureID:dtapID, id:key});
											//if (ts.tiO.pointEvents) 
											ts.tiO.frame.gestureEventArray.push(dtap_event);
											//trace("double tap detected", dtap_event.type)
											return; 
										}
									}
								}
							}
						}
					}	
		}
		
		
		public function findGestureTripleTap(event:GWGestureEvent,key:int):void
		{
			//if (ts.traceDebugMode) 
			//trace("find t taps---------------------------------------------------------");
		
				var ttap_time:int = Math.ceil(ts.gO.pOList[key].point_event_duration_max * GestureWorks.application.frameRate * 0.001);	
				//var ttap_time:int = Math.ceil(ts.gO.pOList[key]["triple_tap_x"].point_interevent_duration_threshold / GestureGlobals.touchFrameInterval);//20
				var ttap_dist:int = ts.gO.pOList[key].point_translation_max;
				
				var	gestureEventArray:Vector.<GWGestureEvent> = new Vector.<GWGestureEvent>;
				
					//trace( ttap_time,ttap_dist);
				
				// find tap pairs // dont need current frame as never double tap in a single frame
				// LOOK IN HISTORY
				for (var i:uint = 0; i < ttap_time; i++) 
					{
					if (ts.tiO.history.length > i)
						{						
					if (ts.tiO.history[i])
					{
					gestureEventArray = ts.tiO.history[i].gestureEventArray;

							for (var j:uint = 0; j < gestureEventArray.length; j++) 
								{
									//trace(gestureEventArray[j].type,event.value.gestureID,gestureEventArray[j].value.gestureID);
									if ((gestureEventArray[j].type =="tap")&&(event.value.gestureID != gestureEventArray[j].value.gestureID)&&(event.value.gestureID!=undefined)&&(gestureEventArray[j].value.gestureID!=undefined))
									{
										//trace("ID", event.value.tapID, gestureEventArray[j].value.tapID)
										var dx1:Number = Math.abs(event.value.x - gestureEventArray[j].value.x);
										var dy1:Number = Math.abs(event.value.y - gestureEventArray[j].value.y);
										
										if ((dx1 < ttap_dist) && (dy1 < ttap_dist)) 
										{
											//////////////////////////////////////////////////
											//trace("T TAP Pair", dx1,dy1);
											for (var k:uint = i; k < (i+ttap_time); k++) 
												{
												//trace("nest error");
												if (ts.tiO.history.length > k)
												{
												if (ts.tiO.history[k])
												{
												var gestureEventArray2:Vector.<GWGestureEvent> = ts.tiO.history[k].gestureEventArray;
												
												//trace("ge length",gestureEventArray2.length);
												
												for (var q:uint = 0; q < gestureEventArray2.length; q++) 
												{
													if ((gestureEventArray2[q].type =="tap")&&(event.value.gestureID!=gestureEventArray2[q].value.gestureID)&&(gestureEventArray[j].value.gestureID != gestureEventArray2[q].value.gestureID))
													{
														
														//trace("ID",event.value.gestureID, gestureEventArray2[q].value.gestureID)
														
														var dx2:Number = Math.abs(event.value.x - gestureEventArray2[q].value.x);//
														var dy2:Number = Math.abs(event.value.y - gestureEventArray2[q].value.y);//
													
														if ((dx2 < ttap_dist) && (dy2 < ttap_dist)) 
														{
															//trace("TAP Triplet",dx1,dy1,dx2,dy2);
															var spt:Point = new Point (event.value.x, event.value.y); // stage point
															var lpt:Point = ts.globalToLocal(spt); //local point
															
															ttapID++;
															var ttap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.TRIPLE_TAP, { x:spt.x , y:spt.y, stageX:spt.x , stageY:spt.y, localX:lpt.x , localY:lpt.y,gestureID:ntapID, id:key});
															//if (ts.tiO.pointEvents) 
															ts.tiO.frame.gestureEventArray.push(ttap_event);
															//trace("triple tap detected");
															return; 
														}
													}
												}
												}
												}
											}
											//////////////////////////////////////////////////
										}
	
									}
								}
						}
					}
					}	
		}
		

		////////////////////////////////////////////////////////////
		// VISUAL EVENT TIMLINE WOULD HELP
		public function countTapEvents(key:uint):void // count taps each frame
		{
			//if (ts.traceDebugMode) 
			//trace("find n-taps---------------------------------------------------------",ts.gO.pOList[key].n);
			tapEventCount = 0;
			//var tap_countTime:int = Math.ceil(ts.gO.pOList[key].dispatch_interval * GestureWorks.application.frameRate * 0.001);//10
			var tap_countTime:int = ts.gO.pOList[key].dispatch_interval;//10
			
			//trace(Math.ceil(ts.gO.pOList[key].dispatch_interval * GestureWorks.application.frameRate * 0.001))
			//var buffer:int = 4;
			var tap_number:int = ts.gO.pOList[key].n;
			var tap_number_min:int = ts.gO.pOList[key].nMin;
			var tap_number_max:int = ts.gO.pOList[key].nMax;
			var tap_x_mean:Number = 0
			var tap_y_mean:Number = 0;
			
			var dn:uint = ts.gO.pOList[key].dList.length;
				
				// count in current frame
				var gestureEventArray:Vector.<GWGestureEvent> = ts.tiO.frame.gestureEventArray
					
					for (var p:uint = 0; p < gestureEventArray.length; p++) 
					{
						//trace("gesture:",gestureEventArray[p].type)
						if (gestureEventArray[j].type =="tap")
							{
								tapEventCount++;
								tap_x_mean += gestureEventArray[j].value.x;
								tap_y_mean += gestureEventArray[j].value.y;
							}
					}
				
					//count history
					for (var i:uint = 0; i < tap_countTime; i++) // 20 fames block for single tap
						{
						//trace("hist frames",ts.tiO.history.length);
						if (ts.tiO.history.length > 0) 
						{
						if (ts.tiO.history.length > i)
						{
						
						gestureEventArray = ts.tiO.history[i].gestureEventArray;
						
						//trace("finding taps",tapEventCount, gestureEventArray.length);
					
								for (var j:int = 0; j < gestureEventArray.length; j++) 
								{
									//trace("gesture:",gestureEventArray[j].type)
									if (gestureEventArray[j].type =="tap")
									{
										tapEventCount++;
										tap_x_mean += gestureEventArray[j].value.x;
										tap_y_mean += gestureEventArray[j].value.y;
									}
								}
							}
						}
					}
					
					
					
					// check totals
					
					if (tapEventCount != 0) 
					{
						//trace("tap event count", tapEventCount, tap_number)
						if ((tap_number && tapEventCount == tap_number) || (!tap_number && tapEventCount >= tap_number_min && tapEventCount <= tap_number_max)||(tap_number==0))
						{
							//trace("tap event count for last duration",tapEventCount);
							var spt:Point = new Point (tap_x_mean/tapEventCount, tap_y_mean/tapEventCount); // stage point average
							var lpt:Point = ts.globalToLocal(spt); //local point average
							ntapID++;
							
							//-var ntap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.TAP, { x:spt.x, y:spt.y,  stageX:spt.x , stageY:spt.y, localX:lpt.x , localY:lpt.y, gestureID:ntapID, n:tapEventCount , id:key} )
							//-ts.dispatchEvent(ntap_event);
							//if (ts.tiO.pointEvents)ts.tiO.frame.gestureEventArray.push(ntap_event);
							
							

							//for (DIM=0; DIM < dn; DIM++)	ts.gO.pOList[key].dList[DIM].gestureDelta = ts.cO[ts.gO.pOList[key].dList[DIM].property_var];
							
							var d:Object = new Object();
								d["x"] = spt.x;
								d["y"] = spt.y;
								d["n"] = tapEventCount;
							
							ts.gO.pOList[key].activeEvent = true;
							ts.gO.pOList[key].data.x = spt.x;
							ts.gO.pOList[key].data.y = spt.y;
							ts.gO.pOList[key].n_current = tapEventCount;
							
							for (DIM = 0; DIM < dn; DIM++)
							{
								ts.gO.pOList[key].dList[DIM].gestureDelta = d[ts.gO.pOList[key].dList[DIM].property_result];
								
								
								//if(ts.gO.pOList[key].dList[DIM].property_id =="tap_x")	ts.gO.pOList[key].dList[DIM].gestureDelta = spt.x;
								//if(ts.gO.pOList[key].dList[DIM].property_id =="tap_y")	ts.gO.pOList[key].dList[DIM].gestureDelta = spt.y;
								//if(ts.gO.pOList[key].dList[DIM].property_id =="tap_n")	ts.gO.pOList[key].dList[DIM].gestureDelta = tapEventCount;
							}
							//trace("count tap0", spt.x, spt.y, tapEventCount, ts.gO.pOList[key].activeEvent);
							
							//ts.gO.pOList[key].activeEvent = true;
						}
						//trace(tap_number,tapEventCount);
					}
					//trace("count tap",ts.gO.pOList[key].activeEvent)
		}
		
		
		public function countDoubleTapEvents(key:int):void // count taps each frame
		{
			//if (ts.traceDebugMode)
			//trace("find n-dtaps---------------------------------------------------------",ts.gO.pOList[key].n);
			
			dtapEventCount = 0;
			
			//var dtap_countTime:int = Math.ceil(ts.gO.pOList[key].dispatch_interval * GestureWorks.application.frameRate * 0.001);
			var dtap_countTime:int = ts.gO.pOList[key].dispatch_interval;
			//trace(Math.ceil(ts.gO.pOList[key].dispatch_interval * GestureWorks.application.frameRate * 0.001))
			var dtap_number:int = ts.gO.pOList[key].n;
			var dtap_number_min:int = ts.gO.pOList[key].nMin;
			var dtap_number_max:int = ts.gO.pOList[key].nMax;
			var dtap_x_mean:Number = 0
			var dtap_y_mean:Number = 0;
			var ddn:uint = ts.gO.pOList[key].dList.length;
				
				// count in current frame
				var gestureEventArray:Vector.<GWGestureEvent> = ts.tiO.frame.gestureEventArray
					
					for (var p:uint = 0; p < gestureEventArray.length; p++) 
					{
						//trace(gestureEventArray[j].type)
						if (gestureEventArray[j].type =="double_tap")
							{
								dtapEventCount++;
								dtap_x_mean += gestureEventArray[j].value.x;
								dtap_y_mean += gestureEventArray[j].value.y;
							}
					}
				
				//count history
				for (var i:uint = 0; i < dtap_countTime; i++) // 20 fames block for single tap
						{
							
						if (ts.tiO.history.length > 0)
							{
						if (ts.tiO.history[i])
						{
						//trace("finding taps",tapEventCount);
						gestureEventArray = ts.tiO.history[i].gestureEventArray;
					
								for (var j:uint = 0; j < gestureEventArray.length; j++) 
								{
									//trace("d gesture:",gestureEventArray[j].type)
									if (gestureEventArray[j].type =="double_tap")
									{
										dtapEventCount++;
										dtap_x_mean += gestureEventArray[j].value.x;
										dtap_y_mean += gestureEventArray[j].value.y;
									}
								}
							}
						}
					}
					
					
					if (dtapEventCount != 0) 
					{
						//trace("dtap event count", dtapEventCount, dtap_number)
						if((dtap_number && dtapEventCount == dtap_number) ||(!dtap_number && dtapEventCount >= dtap_number_min && dtapEventCount <= dtap_number_max)||(dtap_number==0))
						{
							//trace("double tap event count for last duration", dtapEventCount);
							var spt2:Point = new Point (dtap_x_mean/dtapEventCount, dtap_y_mean/dtapEventCount); // stage point average
							var lpt2:Point = ts.globalToLocal(spt2); //local point average
							ndtapID++;
							
							//-var ndtap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.DOUBLE_TAP, { x:spt2.x, y:spt2.y,  stageX:spt2.x , stageY:spt2.y, localX:lpt2.x , localY:lpt2.y, gestureID:ndtapID,n:dtapEventCount, id:key} )
							//-ts.dispatchEvent(ndtap_event);
							// confuses counter // need to move taps to touch event layer
							//if(ts.tiO.pointEvents)ts.tiO.frame.gestureEventArray.push(ndtap_event);
							
							
							
							// map to gesture object
							//ts.gO.pOList[key].x = spt2.x;
							//ts.gO.pOList[key].y = spt2.y;
							//ts.gO.pOList[key].n = dtapEventCount;
							
							var dd:Object = new Object();
									dd["x"] = spt2.x;
									dd["y"] = spt2.y;
									dd["n"] = dtapEventCount;
									
							// default x and y	
							ts.gO.pOList[key].activeEvent = true;
							ts.gO.pOList[key].data.x = spt2.x;
							ts.gO.pOList[key].data.y = spt2.y;
							ts.gO.pOList[key].n_current = dtapEventCount;
							
							for (DIM = 0; DIM < ddn; DIM++) {
								//ts.gO.pOList[key].dList[DIM].gestureDelta = ts.cO[ts.gO.pOList[key].dList[DIM].property_result];
								ts.gO.pOList[key].dList[DIM].gestureDelta = dd[ts.gO.pOList[key].dList[DIM].property_result];
							}
							
						}
					}
		}
		
		public function countTripleTapEvents(key:int):void // count taps each frame
		{
			//if (ts.traceDebugMode) 	trace("find n-ttaps---------------------------------------------------------",ts.gO.pOList[key].n);
			
			ttapEventCount = 0;
			var ttap_countTime:int = ts.gO.pOList[key].dispatch_interval;		//Math.ceil(ts.gO.pOList[key].dispatch_interval * GestureWorks.application.frameRate * 0.001);
			var ttap_number:int = ts.gO.pOList[key].n;
			var ttap_number_min:int = ts.gO.pOList[key].nMin;
			var ttap_number_max:int = ts.gO.pOList[key].nMax;
			var ttap_x_mean:Number = 0
			var ttap_y_mean:Number = 0;
			var tdn:uint = ts.gO.pOList[key].dList.length;
				
				// count in current frame
				var gestureEventArray:Vector.<GWGestureEvent> = ts.tiO.frame.gestureEventArray
					
					for (var p:int = 0; p < gestureEventArray.length; p++) 
					{
						//trace(gestureEventArray[j].type)
						if (gestureEventArray[j].type =="triple_tap")
							{
								ttapEventCount++;
								ttap_x_mean += gestureEventArray[j].value.x;
								ttap_y_mean += gestureEventArray[j].value.y;
							}
					}
				
				//count history
				for (var i:uint = 0; i < ttap_countTime; i++) // 20 fames block for single tap
						{
						if (ts.tiO.history.length > 0)
						{
						if (ts.tiO.history[i])
						{
						//trace("finding taps",tapEventCount);
						gestureEventArray = ts.tiO.history[i].gestureEventArray;
					
								for (var j:int = 0; j < gestureEventArray.length; j++) 
								{
									//trace("t gesture:",gestureEventArray[j].type)
									if (gestureEventArray[j].type =="triple_tap")
									{
										ttapEventCount++;
										ttap_x_mean += gestureEventArray[j].value.x;
										ttap_y_mean += gestureEventArray[j].value.y;
									}
								}
							}
						}
					}
					
					// check totals
					
					if (ttapEventCount != 0) 
					{
						//trace("ttap event count", dtapEventCount, ttap_number)
						if((ttap_number && ttapEventCount == ttap_number) ||(!ttap_number && ttapEventCount >= ttap_number_min && ttapEventCount <= ttap_number_max)||(ttap_number==0))
						{
							//trace("triple tap event count for last duration", ttapEventCount);
							var spt3:Point = new Point (ttap_x_mean/ttapEventCount, ttap_y_mean/ttapEventCount); // stage point average
							var lpt3:Point = ts.globalToLocal(spt3); //local point average
							nttapID++;
							
							
							
							//-var nttap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.TRIPLE_TAP, { x:spt3.x, y:spt3.y,  stageX:spt3.x , stageY:spt3.y, localX:lpt3.x , localY:lpt3.y, gestureID:nttapID, n:ttapEventCount, id:key} )
								//-ts.dispatchEvent(nttap_event);
								
								//if(ts.tiO.pointEvents)ts.tiO.frame.gestureEventArray.push(nttap_event);
							
							var td:Object = new Object();
									td["x"] = spt3.x;
									td["y"] = spt3.y;
									td["n"] = ttapEventCount;	
								
							// over write gesture object properties
							
							//ts.gO.pOList[key].gestureID = nttapID;
							ts.gO.pOList[key].activeEvent = true;
							ts.gO.pOList[key].data.x = spt3.x;
							ts.gO.pOList[key].data.y = spt3.y;
							ts.gO.pOList[key].n_current = ttapEventCount;
							
							for (DIM = 0; DIM < tdn; DIM++) {
								//ts.gO.pOList[key].dList[DIM].gestureDelta = ts.cO[ts.gO.pOList[key].dList[DIM].property_result];
								ts.gO.pOList[key].dList[DIM].gestureDelta = td[ts.gO.pOList[key].dList[DIM].property_result];
							}
						
					
					}
				}
				
				//trace("gesture block----------------------------------------------------------------")
		}
		
		
		public function findTimelineGestures():void
		{
		 // collects gestures fired in sequence accross the timline
		 
		 // collects gestures across the timline (sequence independant)
		 
		}
		
		
		
	}
}