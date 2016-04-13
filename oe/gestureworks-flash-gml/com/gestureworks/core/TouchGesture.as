////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TouchSpriteGesture.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.core
{
	import com.gestureworks.managers.PoolManager;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	//import com.gestureworks.analysis.GesturePipeline;
	import com.gestureworks.analysis.TemporalMetric;
	
	import com.gestureworks.managers.TimelineHistories;
	import com.gestureworks.objects.FrameObject; 
	import com.gestureworks.objects.DimensionObject;
	
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.StrokeObject;
	import com.gestureworks.objects.GestureListObject;
	import com.gestureworks.objects.TimelineObject;
	
	public class TouchGesture extends Sprite
	{
		/**
		* @private
		*/
		//internal public
		//public var gesture_cont:GesturePipeline;
		/**
		* @private
		*/
		public var gesture_disc:TemporalMetric;
		
		/**
		* @private
		*/
		private var gn:uint;
		private var key:uint;
		private var DIM:uint; 
		private var tapOn:Boolean = false;
		
		private var timerCount:int = 0;
		
		private var ts:Object;
		private var id:uint;
		
		private var cO:ClusterObject
		private var sO:StrokeObject
		private var gO:GestureListObject;
		private var tiO:TimelineObject;
		/////////////////////////////////////////////////////////
		
		public function TouchGesture(touchObjectID:int):void
		{
			//super();
			id = touchObjectID;
			ts = GestureGlobals.gw_public::touchObjects[id];
			cO = ts.cO;
			sO = ts.sO;
			gO = ts.gO;
			tiO = ts.tiO;
			
			initGesture();
         }
		 
		// initializers   
         public function initGesture():void 
         {
			//if(traceDebugMode) trace("create touchsprite gesture");
			initGestureAnalysis();
		}
		
		/**
		* @private
		*/
		public function initGestureAnalysis():void //clusterObject:Object
		{
			//if (traceDebugMode) trace("init gesture analysis", touchObjectID);
			
			// configure gesturelist from listener attachment
			//if (hasEventListener(GWGestureEvent.DRAG)) trace("has drag listener");
			//hasEventListener(GWGestureEvent.SCALE, scaleHandeler);
			//hasEventListener(GWGestureEvent.ROTATE, rotateHandeler);
			
			// analyze for descrete gesture sequence/series
			gesture_disc = new TemporalMetric(id);
			
			
			//initTimeline(); // must init after parsing
			// analyze for gesture conflict/compliment
		}
		
		/**
		* @private
		*/
		public function initTimeline():void
		{
			gn = gO.pOList.length;
			for (key=0; key < gn; key++) 
			//for (key in gO.pOList)
			{
				
				if (!tiO.timelineOn)
				{
					if ((gO.pOList[key].gesture_type == "tap")||(gO.pOList[key].gesture_type == "double_tap")||(gO.pOList[key].gesture_type == "triple_tap")||(gO.pOList[key].gesture_type == "hold"))
					{
						tiO.timelineOn = true;
						tiO.pointEvents = true;
						tiO.gestureEvents = true; // for gesutre feedback
						tiO.timelineInit = true;
						GestureGlobals.timelineHistoryCaptureLength = 80;
						tapOn = true;
					}
					else if ((gO.pOList[key].gesture_type == "motion_tap") || (gO.pOList[key].gesture_type == "motion_hold"))
					{
						tiO.timelineOn = true;
						//tiO.pointEvents = true;
						tiO.gestureEvents = true; // for gestute feedback
						tiO.timelineInit = true;
						GestureGlobals.timelineHistoryCaptureLength = 80;
						tapOn = true;
					}
				}
				
				
				//MAKE GML PROGRAMMABLE SET GLOBAL POINT HISTORY
				if (gO.pOList[key].gesture_type == "stroke") GestureGlobals.pointHistoryCaptureLength = 150; // define in GML

				//trace("tsgesture, timelineon:",tiO.timelineOn, tiO.timelineInit);
			}	
			//trace("init timeline",tapOn,tiO.timelineOn);
		}
		
		/**
		* @private
		*/
		//////////////////////////////////////////////////////
		// currently not used
		// intended for non tap gestures that require timeline 
		// analysis like gesture sequencing
		//////////////////////////////////////////////////////
		private function updateTimelineGestureAnalysis():void
		{
			gesture_disc.findTimelineGestures();
		}
		
		/**
		* @private
		*/
		public function manageGestureEventDispatch():void 
		{
			//trace("manage dispatch-----------------------------");
			
			//////////////////////////////////////////////////////////////
			// ONLY IF GESTURE EVENTS ARE ACTIVE
			if (ts.gestureEvents)
			{
				gn = gO.pOList.length;
				
				dispatchMode();
				
					//processKineMetric(); // will move here eventually
					//processGeoMetric();
					processVectorMetric();
					processTemoralMetric();
				
				dispatchGestures();
				dispatchReset();
			}
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////
		
		/**
		* @private
		*/
		public function onTouchEnd(event:TouchEvent):void
		{
			//trace("touch end");
		}
		
		public function dispatchMode():void 
		{
			//trace("dispatch mode -- touch gesture------------------------");
		
			for (key=0; key < gn; key++) 
					{	
						var dn:uint = gO.pOList[key].dList.length;
						
						//SET CURRENT N IN GESTURE OBJECT
						gO.pOList[key].n_current = ts.tpn;//N
						
						///////////////////////////////////
						// set dispatch mode
						////////////////////////////////////
						if (gO.pOList[key].dispatch_type =="discrete")
						{
							//trace(gO.pOList[key].dispatch_mode,gO.pOList[key].dispatch_type,key)
							if (gO.pOList[key].dispatch_mode =="cluster_remove")
							{
								if ((ts.gO.release) && (!gO.pOList[key].complete)) gO.pOList[key].dispatchEvent = true;//gO.release
					
					

								////////////////////////////////////////////////////////////////////////////////////////
								// must make generic
								/////////////////////////////////////////////////////////////////////////////////////////
								
								// COPY CACHE INTO GESTURE DELTA
								if ((gO.pOList[key].gesture_type == "flick")||(gO.pOList[key].gesture_type == "swipe"))
								{	
									// PULL CACHED N VALUE
									gO.pOList[key].n_current = gO.pOList[key].n_cache;
									
									if (gO.pOList[key].activeEvent)
									{
										for (DIM=0; DIM < dn; DIM++)
										{
											gO.pOList[key].dList[DIM].gestureDelta = gO.pOList[key].dList[DIM].gestureDeltaCache;
											//trace("pull cache",gO.pOList[key].dList[DIM].gestureDeltaCache)
										}
									}
								}
								
								if (gO.pOList[key].gesture_type == "stroke")
								{
									gO.pOList[key].dispatchEvent = false;
									//gO.pOList[key].complete = true;
								}

								///////////////////////////////////////////////////////////////////////////////////////////
							}
							
							// NEEDS DEVELOPMENT
							// NEED TO ELIMINATE SLOW MOVING POINTS IN FLICK ALGORITHM
							if (gO.pOList[key].dispatch_mode =="point_remove")
							{
								//if ((!gO.release) && (cO.point_remove) && (!gO.pOList[key].complete)) gO.pOList[key].dispatchEvent = true;
								if ((ts.cO.point_remove) && (!gO.pOList[key].complete)) gO.pOList[key].dispatchEvent = true;
								//else if ((gO.release) && (cO.point_remove) && (!gO.pOList[key].complete)) gO.pOList[key].dispatchEvent = true;
								
								// just pulls from pipeline as normal as points are touching
								//trace("point remove",gO.pOList[key].dispatchEvent)
							}
							
							else if (gO.pOList[key].dispatch_mode =="batch")
							{
								// prime for dispatch
								if (!gO.pOList[key].complete) gO.pOList[key].dispatchEvent = true;
							}
							
							else if (gO.pOList[key].dispatch_mode =="")
							{
								// prime for dispatch
								if (!gO.pOList[key].complete) gO.pOList[key].dispatchEvent = true;
								//trace("nothing",gO.pOList[key].dispatchEvent)
							}
						}
						
						// continuous gesture events always dispatch each processing frame
						else if (gO.pOList[key].dispatch_type =="continuous")
						{
							// prime for dispatch
							gO.pOList[key].dispatchEvent = true;
						}
						
						
				}
		}
		
		public function processVectorMetric():void {
			
			//trace("process vector metric");
			
			var strokeCalled:Boolean = false;
			
			for (key = 0; key < gn; key++) 
			{
				//if (ts.gestureList[gO.pOList[key].gesture_id])||(ts.gestureList[gO.pOList[key].gesture_set_id])) so can validate set
				//{
					if (gO.pOList[key].gesture_type == "stroke")
						{
							if ((ts.cO.remove) && (!gO.pOList[key].complete)&&(!strokeCalled)) 
								{
								//trace("find stroke..", cO.path_data, cO.history[0].path_data);
												
								var pn:uint = sO.path_n;
								// MAKES SURE PATH IS LONG ENOUGHT TO RESAMPLE
								if (pn > 60)
								{
									ts.tc.cluster_vectormetric.normalizeSamplePath();
									ts.tc.cluster_vectormetric.findStrokeGesture();
									strokeCalled = true;
									//trace("touch gesture call stroke analysis");
								}
								//else ts.tc.cluster_vectormetric.resetPathProperties();
							}
						gO.pOList[key].complete = true;
						}
						
					if (gO.pOList[key].gesture_type == "path")
						{
							//trace("find path data");
							// path layout tool
							// resample based on number of touch object in group
							// return point list to peg objects on path
						}
				//}
			}
		}
		
		// needs to move to touchsprite cluster
		public function processTemoralMetric():void {
			
			var tapCalled:Boolean = false; // prevents multi gesture search
			var dtapCalled:Boolean = false;
			var ttapCalled:Boolean = false;
			
		//	trace("process temporalmetric");
		
		
			
			//gn = gO.pOList.length;
			for (key=0; key < gn; key++) 
			//for (key in gO.pOList)
					{
						
					//if (ts.gestureList[gO.pOList[key].gesture_id])||(ts.gestureList[gO.pOList[key].gesture_set_id]))// so can vaidate set
					if (ts.gestureList[gO.pOList[key].gesture_id])
					{
						if ((gO.pOList[key].algorithm_class == "temporalmetric") && (gO.pOList[key].algorithm_type == "discrete"))
						{	
						
								
						///////////////////////////////////////////////
						// HOLD GESTURE// type hold
						///////////////////////////////////////////////
							
						if (gO.pOList[key].gesture_type == "hold")
						{
							//trace("process hold")
							//gO.pOList[key].dispatchEvent = false;
								
								if (gO.pOList[key].algorithm == "hold")
								{	
								//trace("hold check called");
								gesture_disc.findLockedPoints(key);	
									// FOR SOME REASON 3 FINGER HOLD FIRES TWICE AS HOLD_N IS NOT ZEROED
									if (!cO.hold_n||!cO.hold_x||!cO.hold_y)	gO.pOList[key].activeEvent = false;
									else {
										gO.pOList[key].activeEvent = true;
										//gO.pOList[key].dispatchEvent = true;
										//trace("dispatch----------------------------------", gO.pOList[key].dispatchEvent);
										}
								}
						}
						///////////////////////////////////////////////	
							
							
						//trace("TEMPROAL METRIC");
						// SEARCH FOR EVENT MATCH LIST	
						
						// AVOIDS THE NEED TO HAVE MORE EVENTS AND LISTENERS IN THE DISPLAY LIST
						// DO NOT LISTEN INSTEAD LOOK FOR EVIDENCE ON TIMELINE
						
						//search for touch end events on timeline						

						if ((gO.pOList[key].match_TouchEvent == "gwTouchEnd" || gO.pOList[key].match_TouchEvent == "touchEnd")|| (gO.pOList[key].match_GestureEvent == "tap") )
						{
							if ((tiO.pointEvents) && (tiO.frame.pointEventArray))
							{
								
							// in current frame
							for (var j:int = 0; j < ts.tiO.frame.pointEventArray.length; j++) 
									{
									if (tiO.frame.pointEventArray[j].type == "gwTouchEnd" || tiO.frame.pointEventArray[j].type == "touchEnd") 
									{
										//trace("touch end")
									
										//FIND TOUCHBEGIN/TOUCHEND PAIRS
										if ((tapOn) && (!tapCalled))
										if((gO.pOList[key].gesture_type == "tap")||(gO.pOList[key].gesture_type == "double_tap")||(gO.pOList[key].gesture_type == "triple_tap")){
										{	
											//gesture_disc.findGestureTap(tiO.frame.pointEventArray[j], gO.pOList[key].gesture_id) ; // tap event pairs
											gesture_disc.findGestureTap(tiO.frame.pointEventArray[j], key) ; // tap event pairs
											tapCalled = true; // if called by another gesture using tap do not call again
											//trace("trace find tap",gO.pOList[key].gesture_id);
										}
										}
									}
									}
							}
						}
						

						if (gO.pOList[key].match_GestureEvent == "tap") 
						{
							if (tiO.history.length > 0)
							{
								if (tiO.history[0])
								{
								for (var k:int = 0; k < tiO.history[0].gestureEventArray.length; k++) 
									{
										if (tiO.history[0].gestureEventArray[k].type == "tap" ) {
											
											// FIND TAP EVENT PAIRS
											if ((gO.pOList[key].gesture_type == "double_tap") && (!dtapCalled))	
											{
												//gesture_disc.findGestureDoubleTap(tiO.history[0].gestureEventArray[k], gO.pOList[key].gesture_id);
												gesture_disc.findGestureDoubleTap(tiO.history[0].gestureEventArray[k], key);
												dtapCalled = true;
											}
											
											// FIND TAP EVENT TRIPLETS
											if ((gO.pOList[key].gesture_type == "triple_tap")&& (!ttapCalled))
											{
												//gesture_disc.findGestureTripleTap(tiO.history[0].gestureEventArray[k], gO.pOList[key].gesture_id);
												gesture_disc.findGestureTripleTap(tiO.history[0].gestureEventArray[k], key);
												ttapCalled = true;
											}
											
											//???????????????????????????????????????????
											// find hold and tap event pairs??
											//if ((gO.pOList[key].gesture_type == "hold_tap")&& (!htapCalled))
											//{
												//gesture_disc.findGestureHoldTap(tiO.history[0].gestureEventArray[k], key);
												//htapCalled = true;
											//}
										}
									}
								}
							}
						}	
						
						///////////////////////////////////////////////////////////////////////////
						// generic event pair search
						
						// IF EVENT B OCCURES
						// GO BACK AND LOOK FOR EVENT A
						//????????????????????????????????????????????????
						//if (gO.pOList[key].match_gestureEvent == "hold") 
						//{
							
						//}
						///////////////////////////////////////////////////////////////////////////	
						
						
						/////////////////////////////////////////////////////////////////////////////////////////////
						/////////////////////////////////////////////////////////////////////////////////////////////
					
						/////////////////////////////////////////////////////////////////////////////////////////////////
						// process discrete gestures batches for dispatch
						/////////////////////////////////////////////////////////////////////////////////////////////////
						if ((gO.pOList[key].dispatch_mode == "batch"))
							{
									//tap counter
									if (gO.pOList[key].gesture_type == "tap") 
									{
										//if (gO.pOList[key].timer_count > Math.ceil(gO.pOList[key].dispatch_interval * GestureWorks.application.frameRate * 0.001)) gO.pOList[key].timer_count = 0;
										if (gO.pOList[key].timer_count > gO.pOList[key].dispatch_interval ) gO.pOList[key].timer_count = 0;
										
										if (gO.pOList[key].timer_count == 0) {
											//gesture_disc.countTapEvents(gO.pOList[key].gesture_id);
											gesture_disc.countTapEvents(key);
											//trace("count tap",gO.pOList[key].timer_count);
											//trace("d mode", gO.pOList[key].dispatchEvent);
											//
											//DIPATCH EVENT LOCKES AND IS NOT ACTIVATED IN COUNT TAP EVENTS??
											//
									
										}
										gO.pOList[key].timer_count++
									}
									// double tap counter
									if (gO.pOList[key].gesture_type == "double_tap") 
									{
										//if (gO.pOList[key].timer_count > Math.ceil(gO.pOList[key].dispatch_interval * GestureWorks.application.frameRate * 0.001)) gO.pOList[key].timer_count = 0;
										if (gO.pOList[key].timer_count > gO.pOList[key].dispatch_interval) gO.pOList[key].timer_count = 0;
										
										if (gO.pOList[key].timer_count == 0) {
											//gesture_disc.countDoubleTapEvents(gO.pOList[key].gesture_id);
											gesture_disc.countDoubleTapEvents(key);
											//trace("count dtap",gO.pOList[key].timer_count);
										}
										gO.pOList[key].timer_count++
									}
													
									// triple tap counter
									if (gO.pOList[key].gesture_type == "triple_tap") 
									{
										if (gO.pOList[key].timer_count > gO.pOList[key].dispatch_interval) gO.pOList[key].timer_count = 0;
										
										if (gO.pOList[key].timer_count == 0) {
											//gesture_disc.countTripleTapEvents(gO.pOList[key].gesture_id);
											gesture_disc.countTripleTapEvents(key);
											//trace("count dtap",gO.pOList[key].timer_count);
										}
										gO.pOList[key].timer_count++
									}
									
									//trace("d mode",gO.pOList[key].dispatchEvent);
							}
							
							///////////////////////////
							// goes through current frame and dispatched current tap double tap and triple tap events direct from timeline.
							/*
							if ((gO.pOList[key].dispatch_mode == "stream"))
							{
								var gestureEventArray:Array = tiO.frame.gestureEventArray
								
								for (var p:int = 0; p < gestureEventArray.length; p++)
									{
									if((gO.pOList[key].gesture_type=="tap")||(gO.pOList[key].gesture_type=="double_tap")||(gO.pOList[key].gesture_type=="triple_tap")){
									if (gO.pOList[key].gesture_type == gestureEventArray[p].type) dispatchEvent(gestureEventArray[p]);	
									}
									}
							}
							*/
							
							
							
							
							
						}
					}
				}
				
				//traceTimeline();
		}
		
		
		
		public function dispatchReset():void 
		{
			//trace("dispatch reset ");
			//gn = gO.pOList.length;
			for (key=0; key < gn; key++) 
			//for (key in gO.pOList) 
					{	
						
					//trace("managing reset", key, gO.pOList[key].dispatch_type,gO.pOList[key].dispatch_reset,gO.pOList[key].complete);
					
					////////////////////////////
					//
					//////////////////////////////
					gO.pOList[key].n_cache = ts.tpn;
					
					
					/////////////////////////////////////////
					//RESET EVENT DISPATCH
					/////////////////////////////////////////
					// discrete dispatch gesture events
					// if descrete check for reset conditions
					if (gO.pOList[key].dispatch_type =="discrete")
					{
						
						// when cluster has been removed
						if (gO.pOList[key].dispatch_reset == "cluster_remove") 
						{
							if (ts.tpn == 0)//N
							{
								//trace("cluster remove reset")
								gO.pOList[key].complete = false;
								gO.pOList[key].activeEvent = false;
								//trace(key, "release reset ",gO.pOList[key].complete,gO.release,N )
							}
						}
						
						//when point added or removed reset
						if (gO.pOList[key].dispatch_reset == "point_change") // 
						{
							//trace("--",dN,_N, cO.point_remove,cO.point_add)
							if((cO.point_remove)||(cO.point_add)) // point change
							{
								gO.pOList[key].complete = false;
								gO.pOList[key].activeEvent = false;
							}
						}
						
						//when point added reset
						if (gO.pOList[key].dispatch_reset == "point_add") // 
						{
							//trace("--",dN,_N, cO.point_add)
							if(cO.point_add) // point change
							{
								gO.pOList[key].complete = false;
								gO.pOList[key].activeEvent = false;
							}
						}
						
						//when point removed reset
						if (ts.gO.pOList[key].dispatch_reset == "point_remove") // 
						{
							//trace("--",dN,_N, cO.point_remove)
							if(cO.point_remove) // point change
							{
								gO.pOList[key].complete = false;
								gO.pOList[key].activeEvent = false;
							}
						}
						
						// AUTO RESET DISCRETE GESTURE
						else if (ts.gO.pOList[key].dispatch_reset == "") 
						{
							//trace(key, "auto reset");
							// auto reset each frame
							gO.pOList[key].complete = false;
							gO.pOList[key].activeEvent = false;
						}	
					}
					//trace(key,gO.pOList[key].complete,gO.pOList[key].dispatchEvent,gO.pOList[key].activeEvent,gO.pOList[key] );
			}
		}
		
		/**
		* @private
		*/
		public function dispatchGestures():void 
		{	
			//if (traceDebugMode) trace("continuous gesture event dispatch");
			//trace("touch gesture dispatch--------------------------",gO.release);
			
			//traceTimeline();
			
			// start OBJECT start event gesturing
			if ((gO.start)&&(ts.gestureEventStart))
			{
				ts.dispatchEvent(new GWGestureEvent(GWGestureEvent.START, {id:gO.id}));
				//if((tiO.timelineOn)&&(ts.tiO.gestureEvents))	tiO.frame.gestureEventArray.push(new GWGestureEvent(GWGestureEvent.START, {id:gO.id,x:cO.x,y:cO.y}));
				gO.start = false;
				//trace("start fired",cO.x,cO.y);
			}
			
			//////////////////////////////////////////////
			// custom GML gesture events with active event
			//////////////////////////////////////////////
			for (key=0; key < gn; key++) 
				{	
					//trace("dispatchgesture",gO.pOList[key].activeEvent,gO.pOList[key].dispatchEvent)
					// IF GESTURE EVENT
					if ((gO.pOList[key].activeEvent) && (gO.pOList[key].dispatchEvent))	constructGestureEvents(key);
					
					
					// IF KEYBOARD EVENT
					// BUILD // CONSTRUCT KEYBOARDEVENTS()
					//dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, charCodeRef, keyCode, 10));
				}
				
			///////////////////////////////////////////////
			// RELEASE GESTURE SWITCHES OFF RELEASE STATE SO MUST PROCESS ALL RELEASE BASED GESTURES FIRST
			// gesture OBJECT release gesture
			if ((gO.release)&&(ts.gestureEventRelease))
			{
				ts.dispatchEvent(new GWGestureEvent(GWGestureEvent.RELEASE, {id:gO.id}));
				//if ((tiO.timelineOn) && (tiO.gestureEvents))	tiO.frame.gestureEventArray.push(new GWGestureEvent(GWGestureEvent.RELEASE, {id:gO.id,x:cO.x,y:cO.y}));
				gO.release = false;
				//trace("release fired",cO.x,cO.y);
			}
			
			// gesture OBJECT complete event
			if ((gO.complete)&&(ts.gestureEventComplete))
			{
				ts.dispatchEvent(new GWGestureEvent(GWGestureEvent.COMPLETE,{id:gO.id}));
				//if((tiO.timelineOn)&&(tiO.gestureEvents))	tiO.frame.gestureEventArray.push(new GWGestureEvent(GWGestureEvent.COMPLETE, {id:gO.id,x:cO.x,y:cO.y}));
				gO.complete = false;
				//trace("complete fired",cO.x,cO.y);
			}
		
			gO.start = false;
			gO.release = false;
			gO.complete = false;	
			
			// get hist, clear frame
			manageTimeline();
			//traceTimeline();
			
		}
		
		public function traceTimeline():void
		{
			var gn:int = ts.tiO.frame.gestureEventArray.length
			var tn:int = ts.tiO.frame.pointEventArray.length
			var cn:int = ts.tiO.frame.clusterEventArray.length
			
			for (var j:uint = 0; j <gn ; j++) 
			{
				trace("timeline object gesture event:", ts.tiO.frame.gestureEventArray[j].type);
			}
			for (var k:uint = 0; k <tn ; k++) 
			{
				trace("timeline object touch event:", ts.tiO.frame.pointEventArray[k].type);
			}
			//for (var j:uint = 0; j <cn ; j++) 
			//{
				//trace("timeline object cluster event:", ts.tiO.frame.clusterEventArray[j].type);
			//}
			
			//trace("timeline on?",tiO.timelineOn)
		}
									
									
		
		public function manageTimeline():void
		{
			//trace("TOUCH GESTURE timEline mgmt");
			
			// MANAGE TIMELINE
			if (tiO.timelineOn)
			{
				//if (traceDebugMode) trace("timeline frame update");
				TimelineHistories.historyQueue(ts.clusterID);	// push histories 
				
				///////////////////////////////////////////////////
				// FOR SOME REASON THIS KILLS DTAP AND TTAP
				// IT COULD BE THE RESET METHOD AND TIMING 
				///////////////////////////////////////////////////
				//tiO.frame = PoolManager.frameObject; 			
				///////////////////////////////////////////////////
				tiO.frame = new FrameObject(); //	works but expensive
				//tiO.frame.reset(); //seems to work
				
			}
			else {
				//RESET FRAME ANYWAY TP PREVENT EVENT OVERFLOW
				//TOUCH OBJECTS CAN CACHE GESTURE EVENTS (TO THE TIMELINE OBJECT) WHEN NOT USING GESTURES THAT "REQUIRE" THER TEMPORALMETRIC
				tiO.frame = PoolManager.frameObject;
			}
		}
		
		public function constructGestureEvents(key:uint):void 
		{
		
							//trace("dispatch gesture construct",key);
							//////////////////////////////
							// generic custom geture events
							//////////////////////////////
							//trace("testing all attached gestures",gO.pOList[key].activeEvent, key, gO.pOList[key].data.x, gO.pOList[key].data.y, gO.pOList[key].n);
							
							// transform center point
							//var trans_pt:Point = globalToLocal(new Point(cO.x, cO.y)); //local point
							var trans_pt:Point = ts.globalToLocal(new Point(gO.pOList[key].data.x, gO.pOList[key].data.y)); //local point
							// transform vector components
							
							//construct standard properties
							var Data:Object = new Object();
							
								// GESTURE OBJECT ID
								Data["id"] = new Object();
								Data["id"] = gO.pOList[key].gesture_id;//key;
								//Data["id"] = gO.gesture_id;//key;
								
								
								// gestureCount
								// GESTURE EVENT ID
								// gestureID =.. number of times this gesture has dispatched
								
								// MATCHING N VALUE
								Data["n"] = new Object();
								//Data["n"] = gO.pOList[key].n//N; static selection criteria/ FOR SOME REASON N IS BEING ZEROED????? IN GESTURE OBJECT
								//Data["n"] = cO.n // not great for swipe and flick as always zero
								Data["n"] = gO.pOList[key].n_current
								
								//trace("n count",cO.n,gO.pOList[key].n, gO.pOList[key].n_current)
								
								if (gO.pOList[key].event_type =="swipe") Data["n"] = gO.pOList[key].n //CHNAGED FOR SWIPE (MAY SCREW UP TAP ?? HENCE TYPE TEST)
						
								//N; static selection criteria
								
								//trace(cO.n,ts.tpn,gO.pOList[key].n_current,gO.pOList[key].n)
								
								//trace("N...",gO.pOList[key].nMax,gO.pOList[key].nMin,gO.pOList[key].n,gO.pOList[key].gesture_id);
								
								///////////////////////////////////////////
								//NEED DIFFERENT MATCH AND PROPERTY SLOTS
								///////////////////////////////////////////
								//MATCH_N // DIFFERENT FROM CURRENT N OR EVENT COUNT N OR CHACHED_N FOR FLICK OR SWIPE
								//MATCH X MIN MAX
								//MATCH Y MIN MAX
								//MATCH X VELOCITY AND ACCELERATION
								//MATCH (ZONE) CENTER POINT, START AND END POINT
								
								//MATHC ACCELEROMETER VALUE
								//MATCH POINT RADIUS
								//MATCH POINT PRESSURE
								//MATCH GESTURE EVENT LIST
								
								
								
								// location data
								Data["stageX"] = new Object();
								Data["stageX"] = gO.pOList[key].data.x//cO.x;
								
								Data["stageY"] = new Object();
								Data["stageY"] = gO.pOList[key].data.y//cO.y;

								Data["stageZ"] = new Object();
								Data["stageZ"] = gO.pOList[key].data.z//cO.y;								
								
								Data["x"] = new Object();
								Data["x"] = gO.pOList[key].data.x//cO.x;
								
								Data["y"] = new Object();
								Data["y"] = gO.pOList[key].data.y//cO.y;

								Data["z"] = new Object();//3d
								Data["z"] = gO.pOList[key].data.z//cO.y;//3d
							
								
								Data["localX"] = new Object();
								Data["localX"] = trans_pt.x;
								
								Data["localY"] = new Object();
								Data["localY"] = trans_pt.y;
								
								// default stroke data
								Data["path"] = gO.pOList[key].data.path_data;
								Data["prob"] = gO.pOList[key].data.prob;
								Data["stroke_id"] = gO.pOList[key].data.stroke_id;
								Data["x0"] = gO.pOList[key].data.x0//cO.x;
								Data["x1"] = gO.pOList[key].data.x1//cO.x;
								Data["y0"] = gO.pOList[key].data.y0//cO.x;
								Data["y1"] = gO.pOList[key].data.y1//cO.x;
								Data["width"] = gO.pOList[key].data.width//cO.x;
								Data["height"] = gO.pOList[key].data.height//cO.x;
								
								// NEED MORE DYNAMIC VARIABLES
								// GESRTURE VALUE
								// GESTURE VECTOR
								// GESTURE DIM DATA OBJECT ?? ANY NUMBER OF CUSTOM NAMED VALUES FOR EACH DIM
								
								
								// construct gesture object dependant properties
								var dn:uint = gO.pOList[key].dList.length;
								//trace("dn",dn);
								
								for (DIM=0; DIM < dn; DIM++)
								//for (DIM in gO.pOList[key].dList)
								{
									Data[gO.pOList[key].dList[DIM].property_id] = new Object();
									Data[gO.pOList[key].dList[DIM].property_id] = Number(gO.pOList[key].dList[DIM].gestureDelta);	
									//trace(gO.pOList[key].dList[DIM].gestureDeltaCache);
									
									//trace(gO.pOList[key].dList[DIM].active);
								}
							
							
							// USES THE DEFINED EVENT TYPE
							//var GWEVENT:GWGestureEvent = new GWGestureEvent(type, Data);
							var GWEVENT:GWGestureEvent = new GWGestureEvent(gO.pOList[key].event_type, Data);
							
							//trace("type-----------", gO.pOList[key].event_type, GWEVENT.type,GWEVENT.value.x,GWEVENT.value.y,GWEVENT.value.z);
							//trace(gO.pOList[key].event_type,gO.pOList[key].gesture_id)
							if ((GWEVENT.type != "motion_hold") && (GWEVENT.type != "motion_tap")) //motion_flick, motion_swipe
							{
								//trace("touch gesture", gO.pOList[key].event_type, gO.pOList[key].activeEvent, gO.pOList[key].dispatchEvent)
								//trace(gO.pOList[key].active, gO.release, gO.passive, gO.complete)

								ts.dispatchEvent(GWEVENT);
								//TODO: CHECK THAT GESTURE EVENTS WILL WRITE WHEN SET TO ON
								//if ((tiO.timelineOn) && (tiO.gestureEvents))	
								ts.tiO.frame.gestureEventArray.push(GWEVENT);
								//trace("GESTURE EVENT PUSH",tiO.timelineOn,tiO.gestureEvents,gO.pOList[key].event_type,GestureGlobals.frameID)
							}
							
							//NOTE TOUCGH GESTURE EVENTS WERE BEING REACTIVATED BY MOTION INOPUT AND INTERFERING WITH MOTION GESTURE EVENTS
							// FIX WAS TO FILTER CLUSTER PROCESSING SO THAT EVENTACTIVE STATES WERE NOT OVERWRITTEN
						
						// reset dispatch
						gO.pOList[key].dispatchEvent = false;	
						// close event for this dispatch cycle
						gO.pOList[key].activeEvent = false;
						// set gesture event phase logic
						gO.pOList[key].complete = true;
		}
		
	}
}