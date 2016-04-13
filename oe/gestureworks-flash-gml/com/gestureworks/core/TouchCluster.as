////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TouchSpriteCluster.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.core
{
	import com.gestureworks.events.GWClusterEvent;
	import com.gestureworks.analysis.KineMetric;
	import com.gestureworks.analysis.VectorMetric;
	import com.gestureworks.analysis.GeoMetric;
	import com.gestureworks.objects.GestureObject;
	
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.ipClusterObject;
	import com.gestureworks.objects.GestureListObject;
	import com.gestureworks.objects.TimelineObject;
	import com.gestureworks.objects.DimensionObject;
	
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
		
	/**
	* @private
	*/
	public class TouchCluster
	{
		/**
		* @private
		*/
		private var cluster_kinemetric:KineMetric;
		public var cluster_vectormetric:VectorMetric;
		private var cluster_geometric:GeoMetric;
		
		/**
		* @private
		*/
		private var kinemetricsOn:Boolean = true;
		private var vectormetricsOn:Boolean = true;
		private var geometricsOn:Boolean = true;
		
		private var gn:uint;
		private var key:uint;
		private var dn:uint 
		private var DIM:uint; 
		private var ts:Object;
		private var id:int;
		
		private var gO:GestureListObject;
		private var cO:ClusterObject
		private var tcO:ipClusterObject
		private var mcO:ipClusterObject
		//private var scO:ipClusterObject
		
		private var tiO:TimelineObject
		
		public var core:Boolean;
		public var core_init:Boolean= false;
		
		////////////////////////////////////////
		// define subcluster queries
		public var fingerPoints:Boolean = false; 
		public var thumbPoints:Boolean = false; 
		public var palmPoints:Boolean = false; 
		public var fingerAveragePoints:Boolean = false; 
		public var fingerAndThumbPoints:Boolean = false;
		public var pinchPoints:Boolean = false; 
		public var triggerPoints:Boolean = false; 
		public var pushPoints:Boolean = false; 
		public var hookPoints:Boolean = false; 
		public var framePoints:Boolean = false; 
		public var fistPoints:Boolean = false; 
		
		//private var motionSprite:Object;
		
		public static var touchObjects:Dictionary = new Dictionary();
		
		public function TouchCluster(touchObjectID:int):void
		{
			
			id = touchObjectID;
			ts = GestureGlobals.gw_public::touchObjects[id];
			//motionSprite = GestureGlobals.gw_public::touchObjects[GestureGlobals.motionSpriteID];
			touchObjects = GestureGlobals.gw_public::touchObjects;
			
			gO = ts.gO;
			cO = ts.cO;
				tcO = cO.tcO;
				mcO = cO.mcO;
				//scO = cO.scO;
			
			tiO = ts.tiO;
			
			initCluster();
          }
		  
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// initializers
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /**
		 * @private
		 */
        private function initCluster():void 
        {	
				initClusterVars();
				initClusterAnalysis();
				initClusterAnalysisConfig();
		}
		/**
		 * @private
		 */
		private function initClusterVars():void 
		{
				// set constructor logic 
				kinemetricsOn = true;
				vectormetricsOn = true;	
				geometricsOn = true;	
		}
		/**
		 * @private
		 */
		private function initClusterAnalysis():void
		{
			//trace("init cluster analysis", touchSprite_id);
							
				// analyzes and characterizes multi-point motion
				if (kinemetricsOn) cluster_kinemetric = new KineMetric(id);

				// analyzes and characterizes multi-point paths to match against established strokes
				if (vectormetricsOn) cluster_vectormetric = new VectorMetric(id);
					
				// characterizes advanced relative geometry of a cluster
				if (geometricsOn)cluster_geometric = new GeoMetric(id);
		}
		/**
		 * @private
		 */
		// internal public
		public function initClusterAnalysisConfig():void
			{
				// called once gml is parsed and gesture objects created
				// analyzes and characterizes multi-point motion
				if (kinemetricsOn)		cluster_kinemetric.init();
				if (vectormetricsOn)	cluster_vectormetric.init();
				if (geometricsOn)		cluster_geometric.init();
				
		}
		/**
		 * @private
		 */
		// internal public
		public function updateClusterCount():void 
		{
			//trace("update cluster count");
			
			// geometric on
			cluster_geometric.findMotionClusterConstants();  // get mpn
			
			
			// get point count
			cluster_kinemetric.findTouchClusterConstants(); // get tpn
			cluster_kinemetric.find3DGlobalIPConstants();  	// get ipn
			cluster_kinemetric.findRootClusterConstants(); 	// get n
			
			//trace("update ts count", ts.N, ts.tpn, ts.ipn)
			//trace("update co count", ts.cO.n, ts.cO.tpn, ts.cO.ipn);
			//trace("update tco count",ts.cO.tcO.tpn, ts.cO.tcO.ipn);
			//trace("update mco count",ts.cO.mcO.tpn, ts.cO.mcO.ipn);
			//trace("");
			
			// dN MUST MOVE TO CLUSTER
			ts.dN = cO.n - ts.N; 
			ts.N = cO.n;
			//trace(ts.dN)

			// CLUSTER OBJECT UPDATE
			// reset cluster states
			cO.point_remove = false;
			cO.point_add = false;
			cO.remove = false; 
			cO.add = false;
			
			
				if (ts.dN < 0) 
				{
					cO.point_remove = true;
					//cO.point_add = false;
					
					if (ts.N == 0) 
					{
						cO.remove = true; 
						//cO.add = false;
					}
				}
				else if (ts.dN > 0) 
				{
					//cO.point_remove = false;
					cO.point_add = true;
					
					if (ts.N != 0)
					{
					//cO.remove = false; 
					cO.add = true; 
					}
				}
			
			if (ts.dN != 0)
			{
				if (ts.clusterEvents) manageClusterEventDispatch();
			}
			//trace(_dN, _N, cO.point_remove,cO.point_add,cO.remove,cO.add)
			
			
			
			///////////////////////////////////////////////////
			// move to pipeline
			///////////////////////////////////////////////////
			// GESTURE OBJECT UPDATE
			if (ts.dN > 0) ts.gO.start = true;
			
			if (ts.N != 0) 
			{
				gO.active = true;
				gO.complete = false;
				gO.release = false;
			}
			else {
				if (ts.dN < 0) 
				{
					gO.release = true;
					gO.passive = true;
				}
			}
			/*
			if (ts.dN > 0) ts.gO.start = true;
			
			if (ts.N != 0) 
			{
				gO.active = true;
				gO.complete = false;
				gO.release = false;
			}
			else {
				if (ts.dN < 0) 
				{
					gO.release = true;
					gO.passive = true;
				}
			}*/
			///////////////////////////////////////////////////
		}
		
		/**
		 * @private
		 */
		// internal public
		public function updateClusterAnalysis():void
			{
				//trace("update cluster analysis")
				
				// NEED TO MOVE INTO METRIC
				updateClusterCount();
				gn = gO.pOList.length;
				
				cluster_kinemetric.resetRootCluster();
				cluster_kinemetric.resetMotionCluster();
				cluster_kinemetric.resetTouchCluster();
				
				//cluster_kinemetric.findRootInstDimention();
				
				//CLEARS DELTAS STORED IN GESTURE OBJECT
				//SO THAT VALUES DO NOT PERSIST BEYOND RELEASE (NOT TRUE FOR GESTURE DELTA)
				// CLEARS PRIME CLUSTER PRIME MODAL CLUSTERS AND ALL SUBCLUSTERS
				clearGestureObjectClusterDeltas();
				
				// must preceed kinemetrics
				if (geometricsOn)
				{	
					//TODO: GEOMRETRIC 2D (TRIANGLE TEST)
					//if (ts.touchEnabled) getGeoMetrics2D(); 
					if (ts.motionEnabled) getGeoMetrics3D();
				}
				if (kinemetricsOn) 
				{	
					if (ts.touchEnabled) getKineMetrics();
					if (ts.motionEnabled) getKineMetrics3D();
				}
				
				if (vectormetricsOn) 
				{
					if (ts.touchEnabled) getVectorMetrics();
					//TODO: 3D VECTOR METRICS
					//if (ts.motion_input) getVectorMetrics3D();
				}
				
				//cluster_kinemetric.findRootInstDimention();
				
				//trace("hand pos",cO.hand.position)
				
				if ((ts.clusterEvents) && (ts.N)) manageClusterPropertyEventDispatch();
				
				//getGesturePoints();
				
				
				//trace(ts.cO.motionArray.length);
				//trace(ts.cO.iPointArray.length);
				//trace(ts.cO.iPointArray2D.length);
				
		}
		
		////////////////////////////////////////
		//1 DEFINE A SET OF INTERACTION POINTS
		//2 MATCH TO INTERACTION POINT HAND CONFIG (GEOMETRIC)
		//3 HIT TEST QUALIFIED TO TARGET
		//4 ANALYZE RELATIVE INTERACTION POINT CHANGES AND PROPERTIES 
		//5 MATCH MOTION (KINEMETRIC)
		//6 PUSH GESTURE POINT
		//7 PROCESS GESTURE POINT FILTERS 
			//APPLY CLUSTER DELTA LIMITS
		//8 APPLY INTERNAL NATIVE TRANSFORMS 
			//APPLY TRANSFROM LIMITS
		//9 CREATE GESTURE POINT AND ADD TO DISPLAY OBJECT GESTURE POINT LIST
		//10 TEST GESTURE PERIOD PRIORITY AND EXCLUSIVITY
			// TEST SEQUENCE MATCH (HOLD AND MANIPULETE gESTURE POINTS EXIST)
		//11 BUILD GESTURE EVENT OBJECT
		//12 BUILD GESTURE DATA STRCUTURE
		//13 ADD GESTURE EVENT TO TIMELINE
		//14 DISPTACH GESTURE EVENT FROM DISPLAY OBJECT (TODO: REGISTER GESTURE EVENT GLOABLLY)
			// SINGULAR EVENT (GWGestureEvent.HOLD_MANIPULATE......)
		////////////////////////////////////////
			
		//E.G BIMANUAL HOLD & MANIPULATE [CONCURRENT] (NOT HOLD + MANIPULATE [SEQUENCIAL])
			//FIND HOLD POINT LIST
			//FIND MANIP POINT LIST 
			//FIND AVERAGE HOLD POINT XY FIND HOLD TIME
			//FIND DRAG,SCALE,ROTATE
			//UPDATE PARENT CLUSTER WITH DELTAS FROM IP SUBCLUSTERS
			//UPDATE GESTURE PIPELINE
			//UPDATE TRANSFROMS ON DISPLAY OBJECT
			//DISPLATCH SINGLE EVENT
			
		///////////////////////////////////////////////////////////////////////////////
		// NOTE CONTEXT DRIVEN TOUCH POINT EXCLUSION COULD BE DRIVEN BY GESTURE POINTS
		// HOLD POINTS EXCLUDED FROM MANIPULATION CLUSTER BASED ON INIT GESTURE MATCH
		// SEQUENCE DRIVEN TOUCH IPS
		// SUB TOUCH CLUSTERING FOR COMPOUND AND SEQUENCE GESTURES
		// LOCAL MOTION QUALIFIED TOUCH SUBCLUSTERING
		// BASIC KINEMETRIC DRIVEN IP CREATION AND SUBCLUSTERING
		// THEN KINEMETRIC APPLIED TO IP CLUSTERS 
		//////////////////////////////////////////////////////////////////////////////
		// WOULD ALSO ALLOW FOR (FIDUCIAL + TOUCH) OR (PEN + TOUCH) GESTURES 
		//AS EACH WOULD BE IN DIFFERENT LOCAL SUBCLUSTER
		
		public function ipSupported(type:String):Boolean
		{
			var result:Boolean = false;
			
							if ((type == "finger")&&(fingerPoints)) 						result = true; 
							if ((type == "thumb")&&(thumbPoints))							result = true; 
							if ((type == "palm")&&(palmPoints)) 							result = true; 
							if ((type == "finger_average") && (fingerAveragePoints)) 	 	result = true; 
							if ((type == "digit") &&(fingerAndThumbPoints))					result = true; 										 
							if ((type == "pinch")&&(pinchPoints)) 							result = true; 			 
							if ((type == "trigger")&&(triggerPoints ))						result = true; 		
							if ((type == "push")&&(pushPoints)) 							result = true; 			 
							if ((type == "hook")&&(hookPoints)) 							result = true; 			 
							if ((type == "frame") && (framePoints)) 						result = true; 
							if ((type == "fist") && (fistPoints)) 							result = true; 
							
			return result		
		} 
		
			public function initGeoMetric2D():void
		{
			// look at global gesture list and check what fiducials are required
			// activate gloabl touch geometric 2d anlysis
		}
		
		//ESTABLISHES GLOABL IP SUPPORT
		// SEE TOUCH MANAGER
		public function initGeoMetric3D():void
		{
			//trace("set geometric init",core);
			if ((core)&&(!core_init)){
			
			var key:int;
			// for each touchsprite/motionsprite
			// go through gesture list on initialization
			// look for motion gestures that need specific sub cluster types
			// swithed on
			// note global gesture list need that represents a compiled list of gestures from all objects??
			
			for each(var tO:Object in touchObjects)
			{
			// numbers of gestures on this object
			var gn:int = tO.gO.pOList.length;
				//trace("gesture number",tO,gn, tO.gO,tO.gO.pOList,tO.gO.pOList.length)
			for (key = 0; key < gn; key++) 
			//for (key in gO.pOList) //if(gO.pOList[key] is GesturePropertyObject)
			{
				/////////////////////////////////////////////////////////
				// 
				// if gesture object is active in gesture list
				//if (tO.gestureList[tO.gO.pOList[key].gesture_id])
				//{
					var g:GestureObject = tO.gO.pOList[key];
				
					//trace("matching gesture cluster input type",key, g.gesture_xml, g.gesture_id, g.gesture_type ,g.cluster_type,g.cluster_input_type)
						/////////////////////////////////////////////////////
						// ESTABLISH GLOBAL VIRTUAL INTERACTION POINTS SEEDS
						////////////////////////////////////////////////////
					if (g.cluster_input_type == "motion")
						{		
						//g.cluster_type = "all"	
							
						// FUNDAMENTAL INTERACTION POINTS
							if ((g.cluster_type == "finger")||(g.cluster_type == "all")) 			fingerPoints = true; 
							if ((g.cluster_type == "thumb")||(g.cluster_type == "all")) 			thumbPoints = true; 
							if ((g.cluster_type == "palm")||(g.cluster_type == "all")) 				palmPoints = true; 
							if ((g.cluster_type == "finger_average") || (g.cluster_type == "all")) 	fingerAveragePoints = true; 
							if (g.cluster_type == "digit") 											fingerAndThumbPoints = true; 
							
						//CONFIGURATION BASED INTERACTION POINTS
							if ((g.cluster_type == "pinch")||(g.cluster_type == "all")) 			pinchPoints = true; 
							if ((g.cluster_type == "trigger")||(g.cluster_type == "all"))			triggerPoints = true; 
							if ((g.cluster_type == "push")||(g.cluster_type == "all")) 				pushPoints = true; 
							if ((g.cluster_type == "hook")||(g.cluster_type == "all")) 				hookPoints = true; 
							if ((g.cluster_type == "frame") || (g.cluster_type == "all")) 			framePoints = true; 
							if ((g.cluster_type == "fist") || (g.cluster_type == "all")) 			fistPoints = true; 

						// LATER
							//---cluster_geometric.find3DToolPoints();
							//---cluster_geometric.find3DRegionPoints();
							//---cluster_geometric.find3dTipTapPoints();
						}
					//}
				
			}
				
			}
			//DIDNT REALLY NEED AS FRAME DRIVEN
			core_init = true;
			}
		}
		
		
		// ESTABLISHES LOCAL IP SUPPORT TO ALLOW IN LOCAL IP LIST
		public function initIPSupport():void
		{
			if (!core) 
			{
			var gn:int = gO.pOList.length;
			
			//trace("hello", gn)
			for (key = 0; key < gn; key++) 
			//for (key in gO.pOList) //if(gO.pOList[key] is GesturePropertyObject)
			{
				// if gesture object is active in gesture list
				if (ts.gestureList[gO.pOList[key].gesture_id])
				{
					var g:GestureObject = gO.pOList[key];
				
					//trace("matching gesture cluster input type",key, g.gesture_xml, g.gesture_id, g.gesture_type ,g.cluster_type,g.cluster_input_type)
						/////////////////////////////////////////////////////
						// ESTABLISH GLOBAL VIRTUAL INTERACTION POINTS SEEDS
						////////////////////////////////////////////////////
					if (g.cluster_input_type == "motion")
						{		
						//g.cluster_type = "all"	
						
						
						// FUNDAMENTAL INTERACTION POINTS
							if ((g.cluster_type == "finger")||(g.cluster_type == "all")) 			fingerPoints = true; 
							if ((g.cluster_type == "thumb")||(g.cluster_type == "all")) 			thumbPoints = true; 
							if ((g.cluster_type == "palm")||(g.cluster_type == "all")) 				palmPoints = true; 
							if ((g.cluster_type == "finger_average") || (g.cluster_type == "all")) 	fingerAveragePoints = true; 
							if (g.cluster_type == "digit") 											fingerAndThumbPoints = true; 
							
						//CONFIGURATION BASED INTERACTION POINTS
							if ((g.cluster_type == "pinch")||(g.cluster_type == "all")) 			pinchPoints = true; 
							if ((g.cluster_type == "trigger")||(g.cluster_type == "all"))			triggerPoints = true; 
							if ((g.cluster_type == "push")||(g.cluster_type == "all")) 				pushPoints = true; 
							if ((g.cluster_type == "hook")||(g.cluster_type == "all")) 				hookPoints = true; 
							if ((g.cluster_type == "frame") || (g.cluster_type == "all")) 			framePoints = true; 
							if ((g.cluster_type == "fist") || (g.cluster_type == "all")) 			fistPoints = true; 

						// LATER
							//---cluster_geometric.find3DToolPoints();
							//---cluster_geometric.find3DRegionPoints();
							//---cluster_geometric.find3dTipTapPoints();
						}
				}
				
			}
				
			}
			
		}
		
		
		
		public function initIPFilters():void
		{
			cluster_kinemetric.initFilterIPCluster();
		}
		
		public function getVectorMetrics():void 
		{
			// for unistroke only
			if (cO.tpn == 1) // CHNAGE TO tpn
			{
				cluster_vectormetric.resetPathProperties(); // reset stroke data object
				cluster_vectormetric.getSamplePath(); // collect sample path
			}
			
			// multistroke next
		}
		
		
		public function getSkeletalMetrics3D():void 
		{
			//trace("get skeletal geometric");
			
			if (core)
			{
				//trace("get core geometrics")
				
				//////////////////////////////////////////////////////
				// RESET CLUSTER
				//////////////////////////////////////////////////////
				//cluster_geometric.resetGeoCluster();
				
				
				// NEEDS TO UPDATE HERE TO STAY CURRENT
				// NEED TO FIND OUT WHY ??
				cluster_geometric.findMotionClusterConstants()
				
				/////////////////////////////////////////////////////
				//BUILD SKELETAL MODEL FROM RAW MOTION POINTS
				/////////////////////////////////////////////////////
				
				// BASIC HAND
					cluster_geometric.clearHandData();	
					cluster_geometric.createHand(); // palm points // finger list palm ip 
				// SKELETAL DETAIL
					cluster_geometric.findFingerAverage();// finger average point// up down 
					cluster_geometric.normalizeFingerSize(); // norm lengths (palm distances)
					cluster_geometric.findHandRadius(); // favdist 
					cluster_geometric.findThumb(); // thumb // left// right
				// ADVANCED SKELETON
					//--cluster_geometric.findFingers(); // uniquely identify fingers
					//--cluster_geometric.findJoints(); // finger joints //knuckle / wrist
				////////////////////////////////////////////////
			}
		}
		
		public function getGeoMetrics3D():void 
		{
			//TODO:  SET TO BE AWARE OF NUMBER OF FINGERS ASOCOCIATED WITH CONFIG
			// SET TO BE AWARE OF REQUIRED HAND SETTINGS FLATNESS AND ORIENTATION
			
			if (core)
			{
			//trace("get core geometrics", core);
			
			//FOR EACH GESTURE ON TS
			//var gn:int = ts.gO.pOList.length;
			//trace("hello", gn)
			
			//for (key = 0; key < gn; key++) 
			//{
			//var g:GestureObject = gO.pOList[key];

				//if (g.cluster_input_type == "motion")
				//{
				// FOR EACH HAND
				//for (var j:int = 0; j < cO.hn; j++)
					//{	
					// IF H_FN AND FLATNESS AND ORINETATION MATCH
					//trace(g.h_fn,g.h_flatness)
					
					//if ((cO.handList[j].fingerList.length == g.h_fn)&&(cO.handList[j].flatness == g.h_flatness))
						//{
						if (fingerPoints)			cluster_geometric.find3DFingerPoints(); 
						if (thumbPoints)			cluster_geometric.find3DThumbPoints(); 
						if (palmPoints)				cluster_geometric.find3DPalmPoints(); 
						if (fingerAveragePoints)	cluster_geometric.find3DFingerAveragePoints(); 
						if (fingerAndThumbPoints)	cluster_geometric.find3DFingerAndThumbPoints(); 
									
						//CONFIGURATION BASED INTERACTION POINTS
						if (pinchPoints)			cluster_geometric.find3DPinchPoints(); 
						if (triggerPoints)			cluster_geometric.find3DTriggerPoints(); 
						if (pushPoints)				cluster_geometric.find3DPushPoints(); 
						if (hookPoints)				cluster_geometric.find3DHookPoints(); 
						if (framePoints)			cluster_geometric.find3DFramePoints(); 
						if (fistPoints)			cluster_geometric.find3DFistPoints(); 
						
						// LATER
							//---cluster_geometric.find3DToolPoints();
							//---cluster_geometric.find3DRegionPoints();
							//---cluster_geometric.find3dTipTapPoints();
						//}
					//}
				//}
			//}
			}
		}
		
		public function clearGestureObjectClusterDeltas():void
		{
			gn = gO.pOList.length;
			
			for (key = 0; key < gn; key++) 
			{
				// if gesture object is active in gesture list
				if (ts.gestureList[gO.pOList[key].gesture_id])
				{
					// set dim length
					dn = gO.pOList[key].dList.length;	
					//////////////////////////////////////////////////////////////////////
					// zero cluster deltas
					for (DIM=0; DIM < dn; DIM++) gO.pOList[key].dList[DIM].clusterDelta = 0;	
				}
			}
		}
		
		public function getKineMetrics():void 
		{		
	
			gn = gO.pOList.length;
			
			cluster_kinemetric.resetTouchCluster();
			cluster_kinemetric.findTouchInstDimention();
			
			//trace("-touch cluster -----------------------------",gn);
			
			for (key = 0; key < gn; key++) 
			//for (key in gO.pOList) //if(gO.pOList[key] is GesturePropertyObject)
			{
				
				// if gesture object is active in gesture list
				// FILTER BY INPUT TYPE
				
				//NOTE TOUCGH GESTURE EVENTS WERE BEING REACTIVATED BY MOTION INOPUT AND INTERFERING WITH MOTION GESTURE EVENTS
				// FIX WAS TO FILTER CLUSTER PROCESSING SO THAT EVENTACTIVE STATES WERE NOT OVERWRITTEN
				// NEED TO UPDATE TOUCH GESTURES AND TYPE THEM (TOUCH, MOTION, MOTION & TOUCH, SENSOR, SENSOR & TOUCH, SENSOR & MOTION...)	
				/// need to test more
				
				if ((ts.gestureList[gO.pOList[key].gesture_id])&&((gO.pOList[key].cluster_input_type=="")||(gO.pOList[key].cluster_input_type=="touch")))//(gO.pOList[key].cluster_input_type!="motion"
				{
				
					// set dim length
					dn = gO.pOList[key].dList.length;

					var g:GestureObject = gO.pOList[key];
					
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// PROCESSING TOUCH KINEMETRICS
					// TOUCH POINTS
					///////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
					if (ts.tpn != 0) // check kinemetric and if continuous analyze
					{		
						// check point number requirements
						if((ts.tpn >= g.nMin)&&(ts.tpn <= g.nMax)||(ts.tpn == g.n))
						{
							//trace("call cluster calc",ts.N);
							
							if (g.algorithm_class == "kinemetric")
							{
									// activate all by default
									//g.activeEvent = true; // NOOOOO OTHERWISE WILL FIRE EVEN WHEN DELTA IS ZERO
									
									//trace("kinemetric algorithm",gO.pOList[key].algorithm);
									
									// BASIC DRAG/SCALE/ROTATE CONTROL // ALGORITHM // type manipulate
									if (g.algorithm == "manipulate") 	cluster_kinemetric.findMeanInstTransformation();
																		//cluster_kinemetric.findSimpleMeanInstTransformation();
									
										// BASIC DRAG CONTROL // ALGORITHM // type drag
										if (g.algorithm == "drag")			cluster_kinemetric.findMeanInstTranslation();
										//if (g.algorithm == "translate")			cluster_kinemetric.findMeanInstTranslation();

										// BASIC SCALE CONTROL // ALGORITHM // type scale
										if (g.algorithm == "scale")		cluster_kinemetric.findMeanInstSeparation();
																		//cluster_kinemetric.findSimpleMeanInstSeparation();
									
										// BASIC ROTATE CONTROL // ALGORITHM // type rotate
										if (g.algorithm == "rotate")		cluster_kinemetric.findMeanInstRotation();
																			//cluster_kinemetric.findSimpleMeanInstRotation();
									
									
									// BASIC ORIENTATION CONTROL // ALGORITHM
									if (g.algorithm == "orient")		cluster_kinemetric.findInstOrientation();

									// BASIC PIVOT CONTROL // ALGORITHM
									if (g.algorithm == "pivot")		cluster_kinemetric.findInstPivot();
									
									///////////////////////////////////////////////////////////////////////////////////////
									// CLUSTER PROEPRTY LIMIT CONTROLLED DELTAS
									
									// BASIC SCROLL CONTROL // ALGORITHM
									// CONTINUOUS// MIN TRANSLATION IN X AND Y// VELOCITY MUST BE ABOVE MIN VALUE
									// RETURN AVERAGE ENSABLE TEMPORAL VELOCITY 
									if (g.algorithm == "scroll")	cluster_kinemetric.findMeanTemporalVelocity(); // ensamble temporal mean velocity

									// BASIC TILT CONTROL // ALGORITHM
									// CONTINUOUS// LOOK FOR SEPARATION OF CLUSTER IN X AND Y DIRECTION//SEPARATION MUST BE ABOVE MIN VALUE// LOCKED INTO 3 POINT EXCLUSIVE ACTIVATION
									// RETURN DX AND DY
									if (g.algorithm == "tilt")	cluster_kinemetric.findMeanInstSeparation();
									
									// BASIC FLICK CONTROL // ALGORITHM
									// SHOULD BE DISCRETE ON RELEASE // IF BETWEEN ACCEL THREHOLD RETURN GESTURE
									if ((g.algorithm == "flick")||(g.algorithm == "swipe"))
									{
										cluster_kinemetric.findMeanTemporalVelocity(); // ensamble temporal mean velocity
										cluster_kinemetric.findMeanTemporalAcceleration(); //ensamble temporal mean acceleration
									}
									

									///////////////////////////////////////////////////////////////////////////////////
									// LIMIT DELTA BY CLUSTER VALUES
									/////////////////////////////////////////////////////////////////////////////////////
								
										g.activeEvent = false;
									
										for (DIM = 0; DIM < dn; DIM++) 
										{
											var gdim:DimensionObject = g.dList[DIM];
												gdim.activeDim = true; // ACTIVATE DIM
											var res:String = gdim.property_result
											
											
											////////////////////////////////////////////////////
											// CHECK FOR CLUSTER PROEPERTY VALUE LIMITS IF EXIST
											////////////////////////////////////////////////////
											
											// WHEN PROPERTY LIMITS ESTABLISHED
											// ONLY USES ONE VAR PER PROPERTY BUT COULD BE EXTENDED
											// STILL NEED TO MAP RETURN TO RESULT
											if (gdim.property_vars[0])
											{
												//trace("tcO property ",gdim.property_vars[0],gdim.property_vars[0]["var"]);
												//TODO: FIX VARAIBLES BLOCK
												var num:Number = Math.abs(tcO[gdim.property_vars[0]["var"]]);
												var dim_var:Number = 0;
													
												// when max and min
												if ((gdim.property_vars[0]["min"] != null) && (gdim.property_vars[0]["max"] != null))
												{
													if ((num >= gdim.property_vars[0]["min"])&&(num <= gdim.property_vars[0]["max"]))	gdim.clusterDelta = cO[res];//dim_var = num;
													else gdim.clusterDelta = 0;//dim_var = 0;
												}
												// when min
												else if(gdim.property_vars[0]["min"] != null) 
												{	
													if (num >= gdim.property_vars[0]["min"])	{
														gdim.clusterDelta = tcO[res];//dim_var = num;
														//trace("MIN",num)
													}
													else gdim.clusterDelta = 0//dim_var = 0;
												}
												// when max 
												else if (gdim.property_vars[0]["max"] != null) 
												{	
													//if (num <= gdim.property_vars[0]["max"])	gdim.clusterDelta = cO[res];//dim_var = num;
													//else gdim.clusterDelta = 0;//dim_var = 0;
												}
												// when no limits
												else 
													gdim.clusterDelta = tcO[res];//dim_var = num;
											}
											
											//WHEN THERE ARE NO LIMITS IMPOSED
											else gdim.clusterDelta = tcO[res];//rtn_dim = 1;
											
											/////////////////////////////////////////////////////////////
											//GREAT FOR FINDING CLUSTER PROPERTIES
											//trace(res,tcO[res])
											/////////////////////////////////////////////////////////////
											

											//CLOSE DIM IF NO VALUE
											if (gdim.clusterDelta == 0) gdim.activeDim = false;
											//trace("GESTURE OBJECT", res, cO[res], gdim.clusterDelta);
											
											// CLOSE GESTURE OBJECT IF ALL DIMS INACTIVE
											//if (gdim.activeDim) g.activeEvent = true;
											if (gdim.gestureDelta != 0) g.activeEvent = true;
											
											//trace("TOUCH GESTURE OBJECT", res, tcO[res], gdim.clusterDelta, g.activeEvent,gdim.activeDim);
										}


										g.data.x = tcO.x;
										g.data.y = tcO.y;
										g.data.z = tcO.z;
										//g.data.n = g.n//ts.tpn;
										
										//trace("cluster data for gesture n",ts.tpn);
										//////////////////////////////////////////////////////////////////
										//////////////////////////////////////////////////////////////////
										
										//if ((g.activeEvent) && (g.dispatchEvent))
										//trace("CLUSTER OBJECT","dx",cO["dx"],"dy",cO["dx"], "etm_dx",cO["etm_dx"],"etm_dy", cO["etm_dy"],"ddx", cO["etm_ddx"],"ddy", cO["etm_ddy"])
							}
							///////////////////////////////////////////////////
						}
				}
				/////////////////////////////////////////////////////////////////////////////////////////////////////////////
				// END TOUCH POINT KINEMETRIC PROCESSING
				//////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				//else {
					//trace("processing algorithm when NOT touching");
				//}

				}
			}
			
			//	WEAVE TOUCH DATA INTO ROOT SUPER CLUSTER
			cluster_kinemetric.WeaveTouchClusterData();
		}

		public function getKineMetrics3D():void 
		{		
			
			if (!core)
			{
			///////////////////////////////////////////////////////////////////
			// MUST PRECEED IP TRANSFORMATION 
			///////////////////////////////////////////////////////////////////
			
				// PERFORM HIT TEST ON COLLECTED POINTS
				// PULLS FROM GLOABL GMS SOURCES IN A VARIETY OF WAYS TO CREATE ROOT IP CLUSTER
				cluster_kinemetric.hitTestCluster();
				
				// FILTER BY ROOT IP CLUSTER BY GML DEFINED IP CONDITIONS
				//cluster_kinemetric.filterIPCluster(); //SEE TOUCCH MANAGE TO FILTER FOR LOCAL_STRONG
				
				// FOR NATIVE MAPPING AND GESTURE OBJECT DATA STRUCTURE SIMPLIFICATION
				// MAY NEED TO ALWAYS BE ON FOR STAGE OBJECTS
				//if (!ts.transform3d) 
				cluster_kinemetric.mapCluster3Dto2D();
				
				// GET IP SUBCLUSTERS // PUSH TO SUBCLUSTER MATRIX
				cluster_kinemetric.getSubClusters();
				////////////////////////////////////////////////////////////////////
				
				// FOR EACH SUBCLUSTER IN MATRIX ////////////////////////////////////
				for (var j:uint = 0; j < cO.subClusterArray.length; j++) 
				{	
					// FIND CLUSTER DIMS
					cluster_kinemetric.find3DIPConstants(j);
					cluster_kinemetric.find3DIPDimension(j);
				}
					
			//////////////////////////////////////////////////////

			//trace("3d kinmetrics-------------------------");
			
			gn = gO.pOList.length;
			
			//trace("-touch cluster -----------------------------",gn);
			
			for (key = 0; key < gn; key++) 
			//for (key in gO.pOList) //if(gO.pOList[key] is GesturePropertyObject)
			{
				
				// if gesture object is active in gesture list
				// FILTER BY INPUT TYPE
				if ((ts.gestureList[gO.pOList[key].gesture_id])&&(gO.pOList[key].cluster_input_type=="motion"))
				{
				
					// set dim length
					dn = gO.pOList[key].dList.length;
					
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// PROCESSING INTERACTION POINT KINEMETRICS
					// INTERACTION POINTS FROM // MOTION POINTS
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
					// processing algorithms when in motion
					if(ts.cO.ipn!=0){	//&&(sub_cO_n==gn))	// check kinemetric and if continuous analyze
					
					
						////////////////////////////////////////////////
						// SKELETON MATCH
						// TODO: CREAT EXPLICIT SKELETON CONFIG MATCH 
						// PARALLEL TO IMPLICIT CONFIG MATCH
						/////////////////////////////////////////////////
						
						// MATCH NUMBER OF HANDS
								// 0 ANY
								// 1
								// 2
								// MATCH HANDEDNESS 
									// LEFT
									// RIGHT
								// MATCH HAND ORIENTATION
									// UP
									// DOWN
							// MATCH NUMBER OF THUMBS PER HAND
								//0 ANY
								//1
								//2 NONE??
							// MATCH NUMBER OF FINGERS PER HAND
								//5/4/3/2/1 DIGITS
								//4/3/2/1 PURE FINGER
				
						//////////////////////////////////////////////////
						// IMPLICIT SKELETON CONFIG MATCH 
						// FROM INTERACTION POINT TYPE DEFINITION
						//////////////////////////////////////////////////
						
							// DONT PROCESS KINEMTRIC IF WRONG SETTING ON IP POINT
							// MUST HAVE CORRECT NUMBER OF FINGERS ON HAND (1 FUBGER TRIGGER VS TWI FINGER TRIGGER)
							// MUST HAVE CORRECT FLATNESS (OPEN PALM VS CLOSED PALM)
							// CURRENTLY IS HARD CODED INTO THE PALM AND TRIGGER IP CREATION
						
						var g:GestureObject = gO.pOList[key];
						var c_type:String = g.cluster_type;
						var b:int = 0;
						
						//TODO: CREATE SIMPLFIED DATA STRUCTURE FOR EASY REF
						////////////////////////////////////
						// skeleton ips (directly derived)
						if (c_type == "finger") b = 0;
						if (c_type == "palm") b = 1;
						if (c_type == "thumb") b = 2;
						if (c_type == "finger_average") b = 3;
						if (c_type == "digit") b = 4;
						/////////////////////////////////////
						//virtual ips (indirectly derived)
						if (c_type == "trigger") b = 5;
						if (c_type == "pinch") b = 6;
						if (c_type == "hook") b = 7;
						if (c_type == "frame") b = 8;
						if (c_type == "fist") b = 9;
						//if (c_type == "push") b = 10;
						//if (c_type == "region") b = 11;
						/////////////////////////////////////
						// OBJECTS IPS
						//if (c_type == "tool") b = 12;
						
						//trace(c_type)
					
						//var sub_cO_n:int =  ts.cO.subClusterArray[b].iPointArray.length;
						var sub_cO_n:int =  ts.cO.subClusterArray[b].ipn;

						//trace(sub_cO_n,cluster_n)

						// check point number requirements
						if((sub_cO_n >= g.nMin)&&(sub_cO_n<= g.nMax)||(sub_cO_n == g.n))
						{
							//trace("call motion cluster calc",ts.cO.fn,g.algorithm);
							
							//trace();
							
							
							
							///////////////////////////////////////////////
							// MOTION MATCH
							///////////////////////////////////////////////
							
							// activate all by default
							g.activeEvent = true;
							
							if (g.algorithm_class == "3d_kinemetric")
							{
									// BASIC 3D DRAG/SCALE/ROTATE CONTROL // ALGORITHM // type manipulate
									if ((g.algorithm == "3d_manipulate") || (g.algorithm == "3d_transform")) cluster_kinemetric.find3DIPTransformation(b); 
									
									// BASIC 3D DRAG // ALGORITHM // type drag
									if (g.algorithm == "3d_translate") 	cluster_kinemetric.find3DIPTranslation(b);
									
									// GENERIC 3D ROTATE
									if (g.algorithm == "3d_rotate") 	cluster_kinemetric.find3DIPRotation(b);
									
									//GENERIC 3D DCALE
									if (g.algorithm == "3d_separate") 	cluster_kinemetric.find3DIPSeparation(b);
									
									// GENERIC TAP 
									if (g.algorithm == "3d_tap") 	cluster_kinemetric.find3DIPTapPoints(b);
									
									// GENERIC HOLD 
									if (g.algorithm == "3d_hold") 	cluster_kinemetric.find3DIPHoldPoints(b);
									
									///////////////////////////////////////////////////////////////////////////////////
									// LIMIT DELTA BY CLUSTER VALUES
									/////////////////////////////////////////////////////////////////////////////////////
									g.activeEvent = false; // deactivate by default then reactivate based on value
									
									//NEED TO PULL FROM RELVANT SUBCLUSTER
									
										for (DIM = 0; DIM < dn; DIM++) 
										{
										var	gdim:DimensionObject = g.dList[DIM];
												gdim.activeDim = true; // ACTIVATE DIM
										var	res:String = gdim.property_result
										
											//WHEN THERE ARE NO LIMITS IMPOSED
											gdim.clusterDelta = cO.subClusterArray[b][res];

											//CLOSE DIM IF NO VALUE
											if (gdim.clusterDelta == 0) gdim.activeDim = false;

											// CLOSE GESTURE OBJECT IF ALL DIMS INACTIVE
											if (gdim.activeDim) g.activeEvent = true;
											
											//trace("GESTURE MOTION OBJECT", res, cO.subClusterArray[b][res], gdim.clusterDelta, g.activeEvent,gdim.activeDim);
										}
										
										//trace("sub_cluster data", g.activeEvent, g.dispatchEvent, cO.subClusterArray[b].dx,cO.subClusterArray[b].ipn,cO.hn, cO.fn );
										
										//NEED TO PULL FROM RELVANT GESTURE OBJECT//SUBCLUSTER OBJECT
										g.data.x = cO.subClusterArray[b].x; 		// gesture position
										g.data.y = cO.subClusterArray[b].y; 		// gesture position
										g.data.z = cO.subClusterArray[b].z; 		// gesture position
										g.data.hn = cO.hn;							// current hand number
										g.data.fn = cO.fn; 							// current finger total
										g.data.ipn = cO.subClusterArray[b].ipn; 	// current ip total
										//MAY EXTEND TO NEW ARCHITECTURE
										//g.data.gp = cO.gesturePoint;					// gesture point created from kinemetric3d analysis
										
										//TODO:
										// ADD TRANSFORMED POINT LOCALTION DATA 2D AND 3D LOCAL
										// ADD TRANSFORMED DELTA DATA FOR NESTED GESTURE EVENTS
										//////////////////////////////////////////////////////////////////
										//////////////////////////////////////////////////////////////////
										
										//if ((g.activeEvent) && (g.dispatchEvent))
										//trace("CLUSTER OBJECT","dx",cO["dx"],"dy",cO["dx"], "etm_dx",cO["etm_dx"],"etm_dy", cO["etm_dy"],"ddx", cO["etm_ddx"],"ddy", cO["etm_ddy"])
						}	
							///////////////////////////////////////////////////
						}
				}
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////
				// END IP KIMETRIC PROCESSING
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////
				}
			}
			////////////////////////////////////////////////////////
			// DEFAULT STATIC WEAVING 
			// NO MODAL HERACY FOR WEIGHTED BLENDING OF DELTAS
			cluster_kinemetric.Weave3DIPClusterData();
			cluster_kinemetric.WeaveMotionClusterData();
			}
		}
		
		
		//TODO: KILL GESTUREPOINT AND USE GESTURE EVENT INSTEAD
		// MULL OVER IMPLICATIONS TO VIRTUAL 3D INTERACTIVE SPACE
		/*
		public function getGesturePoints():void 
		{		
		//	trace("-----")
				for (var i:int = 0; i < cO.gPointArray.length; i++) 
					{
					trace(cO.gPointArray[i].type,cO.gPointArray[i].position);// cO.gPointArray[i].n
					}
		}*/
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		private function manageClusterEventDispatch():void 
		{	
				// point added to cluster
				if (cO.point_add)
				{
						ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_POINT_ADD, {n:cO.n, id:"bob"}));
						if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_POINT_ADD, {n:cO.n}));
						cO.point_add = false;
				}
				// point removed cluster
				if (ts.cO.point_remove) 
				{
						ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_POINT_REMOVE, {n:cO.n}));
						if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_POINT_REMOVE, {n:cO.n}));
						ts.cO.point_remove = false;
				}
				// cluster add
				if (ts.cO.remove)
				{
						ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_REMOVE, {id:cO.id}));
						if((tiO.timelineOn)&&(tiO.clusterEvents))ts.tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_REMOVE,  {id:cO.id}));
						ts.cO.remove = false;
				}
				// cluster remove
				if (ts.cO.add) 
				{
						ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_ADD, {id:cO.id}));
						if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_ADD,  {id:cO.id}));
						cO.add = false;
				}	
		}
		
		/**
		 * @private
		 */
		private function manageClusterPropertyEventDispatch():void 
		{
				// cluster translate
				if ((cO.dx!=0)||(cO.dy!=0)) 
				{
					ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_TRANSLATE, { dx:cO.dx, dy:cO.dy, n:cO.n }));
					if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_TRANSLATE, { dx:cO.dx, dy:cO.dy, n:cO.n }));
				}
				// cluster rotate
				if (cO.dtheta!=0)
				{
					ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_ROTATE, {dtheta:cO.dtheta, n:cO.n }));
					if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_ROTATE, {dtheta:cO.dtheta, n:cO.n}));
				}
				//cluster separate
				if ((cO.dsx!=0)||(cO.dsy!=0)) 
				{
					ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_SEPARATE, { dsx:cO.dsx, dsy: cO.dsy, n:cO.n }));
					if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_SEPARATE,{ dsx:cO.dsx, dsy:cO.dsy, n:cO.n }));
				}
				// cluster resize
				if ((cO.dw!=0)||(cO.dh!=0)) 
				{
					ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_RESIZE, { dw:cO.dw, dh:cO.dh, n:cO.n }));
					if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_RESIZE, { dw:cO.dw, dh:cO.dh, n:cO.n }));
				}
				/////////////////////////////////////////////////////////////////////////////
				// cluster accelerate
				if ((cO.ddx!=0)||(cO.ddy!=0))
				{
					ts.dispatchEvent(new GWClusterEvent(GWClusterEvent.C_ACCELERATE, { ddx:cO.ddx, ddy:cO.ddy, n:cO.n }));
					if((tiO.timelineOn)&&(tiO.clusterEvents)) tiO.frame.clusterEventArray.push(new GWClusterEvent(GWClusterEvent.C_ACCELERATE, { ddx:cO.ddx, ddy:cO.ddy, n:cO.n }));
				}
		}	
	}
}