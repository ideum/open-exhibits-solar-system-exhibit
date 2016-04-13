////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    clusterKinemetric.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.analysis 
{
	/**
 * @private
 */
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.interfaces.ITouchObject;
	import com.gestureworks.interfaces.ITouchObject3D;
	import com.gestureworks.objects.PointObject;
	import com.gestureworks.objects.MotionPointObject;
	import com.gestureworks.objects.InteractionPointObject;
	import com.gestureworks.objects.GesturePointObject;
	
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.ipClusterObject;
	import com.gestureworks.managers.PointPairHistories;
	import com.gestureworks.managers.InteractionPointTracker;
	
	//import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	
	import com.gestureworks.core.TouchSprite; 
	import com.gestureworks.core.TouchMovieClip; 
	
	import flash.geom.Vector3D;
	import flash.geom.Utils3D;
	import flash.geom.Point;
	import flash.utils.*;
		
	public class KineMetric
	{
		//////////////////////////////////////
		// ARITHMETIC CONSTANTS
		//////////////////////////////////////
		private static const RAD_DEG:Number = 180 / Math.PI;
		private static const DEG_RAD:Number = Math.PI / 180 ;
		
		private var touchObjectID:int;
		private var ts:Object;//private var ts:TouchSprite;
		private var cO:ClusterObject;
		private var mcO:ipClusterObject = new ipClusterObject(); 	//MOTION SUPER
		private var tcO:ipClusterObject = new ipClusterObject(); 	//TOUCH SUPER
		//private var scO:ipClusterObject = new ipClusterObject(); 	//SENSOR SUPER
		
		private var i:uint = 0;
		private var j:uint = 0;
		
		///////////////////////////////////////////////////////////
		//SUPER CLUSTER POINT TOTALS
		public var N:uint = 0;
		private var N1:uint = 0;
		private var k0:Number  = 0;
		private var k1:Number  = 0;
		
		////////////////////////////////////////////////////////////
		// TOUCH POINT TOTALS
		public var tpn:uint = 0;
						//public var LN:uint = 0; //locked touch points
		private var tpn1:uint = 0;
		private var tpnk0:Number  = 0;
		private var tpnk1:Number  = 0;
		private var mc:uint = 0; //MOVE COUNT
		
		private var rk:Number = 0.4; // rotation const
		private var sck:Number = 0.0044;// separate base scale const
		private var pvk:Number = 0.00004;//pivot base const
		
		///////////////////////////////////////////////////////
		// INTERACTION POINT TOTALS
		private var ipn:uint = 0;
		private var dipn:int = 0;
		private var ipnk:Number = 0;
		private var ipnk0:Number = 0;
		
		//TAP COUNTS TO BE MOVED
		private var mxTapID:uint = 0;
		private var myTapID:uint = 0;
		private var mzTapID:uint = 0;
		
		private var mHoldID:uint = 0;
		
		private var gms:ITouchObject;
		private var sw:int
		private var sh:int
		
		//hand config object
		private var handConfig:Object = new Object();
		
		// min max leap raw values
		// NOTE MOTION POINT SENSITIVITY TO PINCH/TRIGGER/ CONSTS AS SHOULD BE RELATIVE??????
		// AND HIT TEST
		private var minX:Number //=-220//180 
		private var maxX:Number //=220//180
		private var minY:Number //=350//270 
		private var maxY:Number //=120//50//-75
		private var minZ:Number //=350//270 
		private var maxZ:Number //=120//50//-75
		
		public static var hitTest3D:Function;	
		
		public function KineMetric(_id:int) 
		{
			//trace("KineMetric::constructor");
			
			touchObjectID = _id;
			init();
		}
		
		public function init():void
		{
			//trace("KineMetric::init");
			
			ts = GestureGlobals.gw_public::touchObjects[touchObjectID]; // need to find center of object for orientation and pivot
			cO = ts.cO; // super cluster
			
			tcO = cO.tcO; //parent touch cluster
			mcO = cO.mcO; // parent motion cluster
			//scO = ts.scO; // parent sensor cluster
			
			
			gms = GestureGlobals.gw_public::touchObjects[GestureGlobals.motionSpriteID];
			sw = GestureWorks.application.stageWidth
			sh = GestureWorks.application.stageHeight;
			
			
			minX = GestureGlobals.gw_public::leapMinX;
			maxX = GestureGlobals.gw_public::leapMaxX;
			minY = GestureGlobals.gw_public::leapMinY;
			maxY = GestureGlobals.gw_public::leapMaxY;
			minZ = GestureGlobals.gw_public::leapMinZ;
			maxZ = GestureGlobals.gw_public::leapMaxZ;
			
			// CREATE INTERACTION POINT SUBCLUSTERS
			if (ts.motionEnabled)initSubClusters();
			
			if (ts.traceDebugMode) trace("init cluster kinemetric");
		}
		
		public function initSubClusters():void
		{
			//trace("init sublucster")
			
			// TODO: MOVE TO CLUSTER MANAGER NOT "TOUCHCLUSTER"
				// init MOTION SKELETAL subclusters
				cO.subClusterArray[0] = new ipClusterObject();// finger
				cO.subClusterArray[0].type = "finger";		
				cO.subClusterArray[1] = new ipClusterObject();// palm
				cO.subClusterArray[1].type = "palm";	
				cO.subClusterArray[2] = new ipClusterObject();// thumb
				cO.subClusterArray[2].type = "thumb";		
				cO.subClusterArray[3] = new ipClusterObject();// finger avergae
				cO.subClusterArray[3].type = "finger_average";
				cO.subClusterArray[4] = new ipClusterObject(); //finger and thumb
				cO.subClusterArray[4].type = "digit";
				// INIT MOTION VIRTUAL SUBCLUSTERS
				cO.subClusterArray[5] = new ipClusterObject(); // trigger
				cO.subClusterArray[5].type = "trigger";		
				cO.subClusterArray[6] = new ipClusterObject(); // pinch
				cO.subClusterArray[6].type = "pinch";
				cO.subClusterArray[7] = new ipClusterObject(); // hook
				cO.subClusterArray[7].type = "hook";
				cO.subClusterArray[8] = new ipClusterObject(); //frame
				cO.subClusterArray[8].type = "frame";
				cO.subClusterArray[9] = new ipClusterObject(); //fist
				cO.subClusterArray[9].type = "fist";
				
				
				//cO.subClusterArray[9] = new ipClusterObject(); // push
				//cO.subClusterArray[9].type = "push";
				//cO.subClusterArray[10] = new ipClusterObject(); //region
				//cO.subClusterArray[10].type = "region";
				//OBJECT TRACKING 
				//cO.subClusterArray[11] = new ipClusterObject(); //tool
				//cO.subClusterArray[11].type = "tool";
				
				////////////////////////////////////////////////////////////
				//
		}
		
		public function initTouchSubClusters():void
		{
			//TOUCH SUBCLUSTERS
			//cO.subClusterArray[11] = new ipClusterObject(); //touch pen
			//cO.subClusterArray[11].type = "pen";
			//cO.subClusterArray[11] = new ipClusterObject(); //fiducial patterns
			//cO.subClusterArray[11].type = "fiducial";// "tag" //"object"
			//cO.subClusterArray[11] = new ipClusterObject(); //hold touch points
			//cO.subClusterArray[11].type = "hold";
			//cO.subClusterArray[11] = new ipClusterObject(); //dynamic touch points
			//cO.subClusterArray[11].type = "dynamic";
			//cO.subClusterArray[11] = new ipClusterObject(); //touch point chord patterns
			//cO.subClusterArray[11].type = "chord"; //passes chrod prob
			
		}
		
		public function initSensorSubClusters():void
		{
			//SENSOR SUBCLUSTERS
			// accelerometer
			// myo
			// watch
			// wii remote
		}
		
		
		public function findRootClusterConstants():void
		{
			//trace("KineMetric::findRootClusterConstants");
			
				//if (ts.traceDebugMode) trace("find cluster..............................",N);
				
				///////////////////////////////////////////////
				// get number of touch points in cluster
				N = ts.cO.tpn + ts.cO.ipn;
				cO.n = N;
				
				if (N) 
				{
					N1 = N - 1;
					k0 = 1 / N;
					k1 = 1 / N1;
					if (N == 0) N1 = 0;
				}
		}
		
		public function resetRootCluster():void 
		{
			//trace("KineMetric::resetRootCluster");
			
			cO.x = 0;
			cO.y = 0;
			cO.z = 0;//-3D
			cO.width = 0;
			cO.height = 0;
			cO.length = 0;//-3D
			cO.radius = 0;
			
			//cO.separation
			cO.separationX = 0;
			cO.separationY = 0;
			cO.separationZ = 0;//-3D
			
			cO.rotation = 0;
			cO.rotationX = 0;//-3D
			cO.rotationY = 0;//-3D
			cO.rotationZ = 0;//-3D
			
			cO.orientation =  0;
			//cO.thumbID = 0;
			//cO.hand_normal = 0;
			//cO.hand_radius = 0;
			
			cO.mx = 0;
			cO.my = 0;
			cO.mz = 0;//-
			
			//////////////////////////////////
			////////////////////////////////////
			cO.orient_dx = 0;
			cO.orient_dy = 0;
			cO.orient_dz = 0;//-3D
			cO.pivot_dtheta = 0;
		
			/////////////////////////
			// first diff
			/////////////////////////
			cO.dtheta = 0;
			cO.dthetaX = 0;
			cO.dthetaY = 0;
			cO.dthetaZ = 0;
			cO.dtheta = 0;
			cO.dx = 0;
			cO.dy = 0;
			cO.dz = 0;//-3D
			cO.ds = 0;
			cO.dsx = 0;
			cO.dsy = 0;
			cO.dsz = 0;//-
			cO.etm_dx = 0;
			cO.etm_dy = 0;
			cO.etm_dz = 0;//-3D
			
			////////////////////////
			// second diff
			////////////////////////
			cO.ddx = 0;
			cO.ddy = 0;
			cO.ddz = 0;//-
			
			cO.etm_ddx = 0;
			cO.etm_ddy = 0;
			cO.etm_ddz = 0;//-3D
			
			////////////////////////////
			// sub cluster analysis
			// NEED TO MOVE INTO IPOINTARRAY
			////////////////////////////
			cO.hold_x = 0;
			cO.hold_y = 0;
			cO.hold_z = 0;//-3D
			cO.hold_n = 0;
			
			//accelerometer
			//SENSOR
			//cO.ax =0
			//cO.ay =0
			//cO.az =0
			//cO.atheta =0
			//cO.dax =0
			//cO.day =0
			//cO.daz =0
			//cO.datheta =0
			
			cO.gPointArray = new Vector.<GesturePointObject>;
		}
		
		public function resetMotionCluster():void 
		{
			//trace("KineMetric::resetMotionCluster");
			
			mcO.x = 0;
			mcO.y = 0;
			mcO.z = 0;//-3D
			
			mcO.width = 0;
			mcO.height = 0;
			mcO.length = 0;//-3D
			mcO.radius = 0;
			
			//cO.separation
			mcO.separationX = 0;
			mcO.separationY = 0;
			mcO.separationZ = 0;//-3D
			
			mcO.rotation = 0;
			mcO.rotationX = 0;//-3D
			mcO.rotationY = 0;//-3D
			mcO.rotationZ = 0;//-3D
			mcO.orientation =  0;

			/////////////////////////
			// first diff
			/////////////////////////
			mcO.dtheta = 0;
			mcO.dthetaX = 0;
			mcO.dthetaY = 0;
			mcO.dthetaZ = 0;
			mcO.dtheta = 0;
			mcO.dx = 0;
			mcO.dy = 0;
			mcO.dz = 0;//-3D
			mcO.ds = 0;
			mcO.dsx = 0;
			mcO.dsy = 0;
			mcO.dsz = 0;//-
		}
		
		
		//NEEDS WORK
		public function findRootInstDimention():void
		{
			//trace("KineMetric::findRootInstDimention");
			
			
			///////////////////////////////////////////////////////////////////////////////////////////////////////////
			// multi modal cluster width, height and radius // OPERATION
			///////////////////////////////////////////////////////////////////////////////////////////////////////////
			
					cO.x = 0; 
					cO.y = 0;
					cO.z = 0;
					
					cO.radius = 0;
					cO.width = 0;
					cO.height = 0;
					cO.length = 0;
					
					cO.mmPointArray.length = 0;
					for (var p:uint = 0; p < ipn; p++) cO.mmPointArray.push(cO.iPointArray[p]);
					for (var q:uint = 0; q < tpn; q++) cO.mmPointArray.push(cO.pointArray[q]);
					
					
					if (N == 1)
					{
						var pt0:* = cO.mmPointArray[0];
						
						if (pt0 is InteractionPointObject)
						{
							cO.x = pt0.position.x;
							cO.y = pt0.position.y;
							cO.z = pt0.position.z;
						}
						else {
							cO.x = pt0.x;
							cO.y = pt0.y;
							cO.z = pt0.z;
						}
						
						cO.radius = 15;
						cO.width = 30;
						cO.height = 30;
						cO.length = 30;
					}
					
					else if (N > 1)
						{	
						for (i = 0; i < N; i++)
						{
						var pt:* = cO.mmPointArray[i];
						
						if (pt is PointObject)
						{
							cO.x += pt.x;
							cO.y += pt.y;
							cO.z += pt.z;
						}
						else 
						{
							cO.x += pt.position.x;
							cO.y += pt.position.y;
							cO.z += pt.position.z;
						}
						
							for (var j1:uint = 0; j1 < N; j1++)
							{
							var pt2:* = cO.mmPointArray[j1];
								
								if ((i != j1) && (pt) && (pt2))
									{
									var dx:Number;
									var dy:Number;
									var dz:Number;
									
									//trace(pt,pt2)
									
										if (pt is PointObject)
										{
											if (pt2 is PointObject)
											{
												dx = pt.x - pt2.x;
												dy = pt.y - pt2.y;
												dz = pt.z - pt2.z;
											}
											else 
											{
												dx = pt.x - pt2.position.x;
												dy = pt.y - pt2.position.y;
												dz = pt.z - pt2.position.z;
											}
										}
										
										else
										{
											if (pt2 is PointObject)
											{
												dx = pt.position.x - pt2.x;
												dy = pt.position.y - pt2.y;
												dz = pt.position.z - pt2.z;
											}
											else {
												dx = pt.position.x - pt2.position.x;
												dy = pt.position.y - pt2.position.y;
												dz = pt.position.z - pt2.position.z;
											}
										}
										
										var abs_dx:Number = Math.abs(dx);
										var abs_dy:Number = Math.abs(dy);
										var abs_dz:Number = Math.abs(dz);
										
										// MAX SEPERATION BETWEEN A PAIR OF POINTS IN THE CLUSTER
										if (abs_dx > cO.width) cO.width = abs_dx;
										if (abs_dy > cO.height) cO.height = abs_dy;
										if (abs_dz > cO.length) cO.length = abs_dz;
									}
							}
						}
						
						cO.radius = 0.5*Math.sqrt(cO.width * cO.width + cO.height * cO.height + cO.length * cO.length);//
						//divide by subcluster ip number sipnk 
							
						cO.x *= k0;
						cO.y *= k0; 
						cO.z *= k0;
					}
					
				//trace("kinemetric inst dims", cO.x,cO.y, cO.z, cO.width, cO.height,cO.length, cO.radius);
		}
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		// TOUCH CLUSTER ANALYSIS
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function findTouchClusterConstants():void
		{
			//trace("KineMetric::findTouchClusterConstants");

				//if (ts.traceDebugMode) trace("find cluster..............................",N);
				
				///////////////////////////////////////////////
				// get number of touch points in cluster
				//tpn = ts.cO.tcO.pointArray.length;
				tpn = ts.cO.pointArray.length;
				
				ts.tpn = tpn;
				ts.cO.tpn = tpn;
				ts.cO.tcO.tpn = tpn;
				
				//TODO: NEED TO FIX lock number
				//LN = ts.tcO.hold_n // will need to move to interaction point structure or temporal metric mgmt
				
				// derived point totals
				if (tpn) 
				{
					tpn1 = tpn - 1;
					tpnk0 = 1 / tpn;
					tpnk1 = 1 / tpn1;
					if (tpn == 0) tpnk1 = 0;
					//pointList = cO.pointArray; // copy most recent point array data
					mc = cO.pointArray[0].moveCount; // get sample move count value
				}
		}
		
		
		
		public function resetTouchCluster():void 
		{
			//trace("KineMetric::resetTouchCluster");

			tcO.x = 0;
			tcO.y = 0;
			tcO.z = 0;//-3D
			tcO.width = 0;
			tcO.height = 0;
			tcO.length = 0;//-3D
			tcO.radius = 0;
			
			//cO.separation
			tcO.separationX = 0;
			tcO.separationY = 0;
			tcO.separationZ = 0;//-3D
			
			tcO.rotation = 0;
			tcO.rotationX = 0;//-3D
			tcO.rotationY = 0;//-3D
			tcO.rotationZ = 0;//-3D
			
			tcO.orientation =  0;
			//cO.thumbID = 0;
			//cO.hand_normal = 0;
			//cO.hand_radius = 0;
			
			tcO.mx = 0;
			tcO.my = 0;
			tcO.mz = 0;//-
			
			//////////////////////////////////
			////////////////////////////////////
			tcO.orient_dx = 0;
			tcO.orient_dy = 0;
			cO.orient_dz = 0;//-3D
			tcO.pivot_dtheta = 0;
		
			/////////////////////////
			// first diff
			/////////////////////////
			tcO.dtheta = 0;
			tcO.dthetaX = 0;
			tcO.dthetaY = 0;
			tcO.dthetaZ = 0;
			tcO.dx = 0;
			tcO.dy = 0;
			tcO.dz = 0;//-3D
			tcO.ds = 0;
			tcO.dsx = 0;
			tcO.dsy = 0;
			tcO.dsz = 0;//-
			tcO.etm_dx = 0;
			tcO.etm_dy = 0;
			tcO.etm_dz = 0;//-3D
			
			////////////////////////
			// second diff
			////////////////////////
			tcO.ddx = 0;
			tcO.ddy = 0;
			tcO.ddz = 0;//-
			
			tcO.etm_ddx = 0;
			tcO.etm_ddy = 0;
			tcO.etm_ddz = 0;//-3D
			
			////////////////////////////
			// sub cluster analysis
			// NEED TO MOVE INTO IPOINTARRAY
			////////////////////////////
			tcO.hold_x = 0;
			tcO.hold_y = 0;
			tcO.hold_z = 0;//-3D
			tcO.hold_n = 0;
		}
		
		
		public function findTouchInstDimention():void
		{
			//trace("KineMetric::findTouchInstDimention");

			
			///////////////////////////////////////////////////////////////////////////////////////////////////////////
			// cluster width, height and radius // OPERATION
			///////////////////////////////////////////////////////////////////////////////////////////////////////////
			// basic cluster property values 
			// uses the current position of the points in the cluster to find the spread of the cluster and its current dims
					
					tcO.x = 0; 
					tcO.y = 0;
					tcO.z = 0;
					tcO.radius = 0;
					tcO.width = 0;
					tcO.height = 0;
					tcO.length = 0;
					
					tcO.separationX = 0;
					tcO.separationY = 0;
					tcO.separationZ = 0;
					tcO.rotation = 0;
					tcO.dtheta = 0;
					tcO.dthetaX = 0;
					tcO.dthetaY = 0;
					tcO.dthetaZ = 0;
					tcO.mx = 0;
					tcO.my = 0;
					tcO.mz = 0;
					
					
					
					if (tpn == 1)
					{
						tcO.x = cO.pointArray[0].x;
						tcO.y = cO.pointArray[0].y;
						tcO.z = cO.pointArray[0].z;
						tcO.mx = cO.pointArray[0].x;
						tcO.my = cO.pointArray[0].y;
						tcO.mz = cO.pointArray[0].z;
					}
					
					else if (tpn > 1)
						{	
						for (i = 1; i < tpn; i++)
						{
							for (var j1:uint = 0; j1 < tpn; j1++)
							{
								if ((i != j1) && (cO.pointArray[i]) && (cO.pointArray[j1]))//&&(!pointList[i].holdLock)&&(!pointList[j1].holdLock))//edit
									{
										//trace("dim",N);
										var dx:Number = cO.pointArray[i].x - cO.pointArray[j1].x;
										var dy:Number = cO.pointArray[i].y - cO.pointArray[j1].y;
										var dz:Number = cO.pointArray[i].z - cO.pointArray[j1].z;
										var ds:Number  = Math.sqrt(dx * dx + dy * dy + dz * dz);
											
										// diameter, radius of group
										if (ds > tcO.radius)
										{
											tcO.radius = ds *0.5;
										}
										// width of group
										var abs_dx:Number = Math.abs(dx);
										if (abs_dx > tcO.width)
										{
											tcO.width = abs_dx;
											tcO.x = cO.pointArray[i].x -(dx*0.5);
										}
										// height of group
										var abs_dy:Number = Math.abs(dy);
										if (abs_dy > tcO.height)
										{
											tcO.height = abs_dy;
											tcO.y = cO.pointArray[i].y -(dy* 0.5);
										} 
										// length of group
										var abs_dz:Number = Math.abs(dz);
										if (abs_dz > tcO.length)
										{
											tcO.length = abs_dz;
											tcO.z = cO.pointArray[i].z -(dz* 0.5);
										} 										
										// NOTE NEED TO FIX AS CO.X CAN BE SAME AS CO.MX
										
										
										// mean point position
										tcO.mx += cO.pointArray[i].x;
										tcO.my += cO.pointArray[i].y;
										tcO.mz += cO.pointArray[i].z;
									}
							}
							
							
							// inst separation and rotation
							if ((cO.pointArray[0]) && (cO.pointArray[i]))//&&(!pointList[i].holdLock)&&(!pointList[j1].holdLock)) //edit
							{
								var dxs:Number = cO.pointArray[0].x - cO.pointArray[i].x;
								var dys:Number = cO.pointArray[0].y - cO.pointArray[i].y;
								var dzs:Number = cO.pointArray[0].z - cO.pointArray[i].z;
								//var ds:Number  = Math.sqrt(dx * dx + dy * dy);

								// separation of group
								tcO.separationX += Math.abs(dxs);
								tcO.separationY += Math.abs(dys);
								tcO.separationZ += Math.abs(dzs);
								
								
								// rotation of group
								//tcO.rotation += (calcAngle(dxs, dys)) //|| 0 // TODO: ADD 3D 
								//tcO.dthetaX = tcO.rotation; //|| 0 // TODO: ADD 3D


								//tcO.dtheta += dtheta;
								tcO.dthetaX += calcAngle(dys, dzs);
								tcO.dthetaY += calcAngle(dxs, dzs);
								tcO.dthetaZ += calcAngle(dxs, dys);
								
								tcO.rotation = tcO.dthetaZ;								
								//tcO.dtheta = tcO.dthetaX + tcO.dthetaY + tcO.dthetaZ;																

							}
						}
						/*
						//c_s *= k0;
						c_sx *= k0;
						c_sy *= k0;
						c_theta *= k0;
						c_emx *= k0;
						c_emy *= k0;
						*/
						tcO.separationX *= tpnk0;
						tcO.separationY *= tpnk0;
						tcO.separationZ *= tpnk0;
						tcO.rotation *= tpnk0;
						tcO.dthetaX *= tpnk0;
						tcO.dthetaY *= tpnk0;
						tcO.dthetaZ *= tpnk0;
						tcO.mx *= tpnk0;
						tcO.my *= tpnk0;
						tcO.mz *= tpnk0;
					}
					
				//trace("kinemetric inst dims", cO.x,cO.y);
		}
		
		
		public function findSimpleMeanInstTransformation():void
		{
			//trace("KineMetric::findSimpleMeanInstTransformation");
			
			
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// cluster tranformation // OPERATION
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			if (tpn == 1) 
			{
				// DO NOT SET OTHER DELTAS TO ZERO IN OPERATOR
				tcO.dx = cO.pointArray[0].DX;
				tcO.dy = cO.pointArray[0].DY;
				tcO.dz = cO.pointArray[0].DZ;
				//trace("cluster- porcessing", c_dx,c_dy);
			}
			else if (tpn > 1)
				{
					for (i = 0; i < tpn; i++) 
						{	
							// translate	
							tcO.dx += cO.pointArray[i].DX;
							tcO.dy += cO.pointArray[i].DY;
							tcO.dz += cO.pointArray[i].DZ;
						}
						//var theta0:Number = calcAngle(sx, sy);
						//var theta1:Number = calcAngle(sx_mc, sy_mc); // could eliminate in point pair

						tcO.dx *= tpnk0;
						tcO.dy *= tpnk0;
						tcO.dz *= tpnk0;
								
						if (tcO.history[1])
								{
									//////////////////////////////////////////////////////////
									// CHANGE IN SEPARATION
									if ((tcO.history[1].radius != 0) && (tcO.rotation != 0)) 
									{
										tcO.ds = (tcO.radius - tcO.history[1].radius) * sck;
									}
									//trace(cO.radius, cO.history[mc].radius);
									
									//////////////////////////////////////////////////////////
									// CHANGE IN ROTATION
									if ((tcO.history[1].rotation != 0) && (tcO.rotation != 0)) 
									{
										if (Math.abs(tcO.rotation - tcO.history[1].rotation) > 90) tcO.dtheta = 0
										else tcO.dtheta = (tcO.rotation - tcO.history[1].rotation);	
									}
									//trace(cO.rotation, cO.history[1].rotation, cO.dtheta);
								}
				}
		}
		
		public function findMeanInstTransformation():void
		{
			
			//trace("KineMetric::findMeanInstTransformation");

			// these values required reset for manipulate
			tcO.dthetaX = 0;
			tcO.dthetaY = 0;
			tcO.dthetaZ = 0;
			tcO.dtheta = 0;
			
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// cluster tranformation // OPERATION
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			if (tpn == 1) 
			{
				// DO NOT SET OTHER DELTAS TO ZERO IN OPERATOR
				tcO.dx = cO.pointArray[0].DX;
				tcO.dy = cO.pointArray[0].DY;
				tcO.dz = cO.pointArray[0].DZ;
				//trace("cluster- porcessing", c_dx,c_dy);
			}
				else if (tpn > 1)
							{
							//cO.ds = 0;	
							//cO.dsx = 0;	
							//cO.dsy = 0;	
							
							var sx:Number = 0;
							var sy:Number = 0;
							var sz:Number = 0;
							var sx_mc:Number = 0;
							var sy_mc:Number = 0;
							var sz_mc:Number = 0;
						//	var ds:Number = 0;
								
						
								for (i = 0; i < tpn; i++) 
								{	
									/////////////////////////////////////////////
									// translate
									tcO.dx += cO.pointArray[i].DX;
									tcO.dy += cO.pointArray[i].DY;
									tcO.dz += cO.pointArray[i].DZ;

									if ((tpn > i + 1) && (cO.pointArray[0].history.length > mc) && (cO.pointArray[i + 1].history.length > mc))
										{
										////////////////////////////////////////
										// scale 
										sx += cO.pointArray[0].x - cO.pointArray[i + 1].x;
										sy += cO.pointArray[0].y - cO.pointArray[i + 1].y;
										sz += cO.pointArray[0].z - cO.pointArray[i + 1].z;
										sx_mc += cO.pointArray[0].history[mc].x - cO.pointArray[i + 1].history[mc].x;// could eliminate in point pair
										sy_mc += cO.pointArray[0].history[mc].y - cO.pointArray[i + 1].history[mc].y;// could eliminate in point pair
										sz_mc += cO.pointArray[0].history[mc].z - cO.pointArray[i + 1].history[mc].z;// could eliminate in point pair
										
										////////////////////////////////////////////
										// rotate
										//var dtheta:Number = 0;
										var dthetax:Number = 0;
										var dthetay:Number = 0;
										var dthetaz:Number = 0;
										
										//var theta0:Number = calcAngle(sx, sy);
										//var theta1:Number = calcAngle(sx_mc, sy_mc); // could eliminate in point pair
										var theta0x:Number = calcAngle(sy, sz);
										var theta1x:Number = calcAngle(sy_mc, sz_mc);
										var theta0y:Number = calcAngle(sx, sz);
										var theta1y:Number = calcAngle(sx_mc, sz_mc); 
										var theta0z:Number = calcAngle(sx, sy);
										var theta1z:Number = calcAngle(sx_mc, sy_mc); 
										
										//if ((theta0 != 0) && (theta1 != 0)) 
											//{
											//if (Math.abs(theta0 - theta1) > 180) dtheta = 0
											//else dtheta = (theta0 - theta1);
											//}
										//else dtheta = 0;
												
										if ((theta0x != 0) && (theta1x != 0)) 
											{
											if (Math.abs(theta0x - theta1x) > 180) dthetax = 0
											else dthetax = (theta0x - theta1x);
											}
										else dthetax = 0;
												
										if ((theta0y != 0) && (theta1y != 0)) 
											{
											if (Math.abs(theta0y - theta1y) > 180) dthetay = 0
											else dthetay = (theta0y - theta1y);
											}
										else dthetay = 0;
		
										if ((theta0z != 0) && (theta1z != 0)) 
											{
											if (Math.abs(theta0z - theta1z) > 180) dthetaz = 0
											else dthetaz = (theta0z - theta1z);
											}
										else dthetaz = 0;
		
										//tcO.dtheta += dtheta;
										tcO.dthetaX += dthetax;
										tcO.dthetaY += dthetay;
										tcO.dthetaZ += dthetaz;
										tcO.dtheta = tcO.dthetaX + tcO.dthetaY + tcO.dthetaZ;

										}	
								}
								
								// FIND C_DSX AND C_DSY AGGREGATE THEN AS A LAST STEP FIND THE SQUARE OF THE DISTANCE BETWEEN TO GET C_DS
								//c_ds = Math.sqrt(c_dsx*c_dsx + c_dsy*c_dsy)
								
								tcO.dx *= tpnk0;
								tcO.dy *= tpnk0;
								tcO.dz *= tpnk0;
								
								//tcO.dtheta *= tpnk1;
								tcO.dthetaX *= tpnk1;
								tcO.dthetaY *= tpnk1;
								tcO.dthetaZ *= tpnk1;
								tcO.dtheta = tcO.dthetaX + tcO.dthetaY + tcO.dthetaZ;
								
								
								tcO.ds = (Math.sqrt(sx * sx + sy * sy + sz * sz) - Math.sqrt(sx_mc * sx_mc  + sy_mc * sy_mc + sz_mc * sz_mc)) * tpnk1 * sck;

			}
		//trace("transfromation",tcO.dx,tcO.dy, tcO.ds,tcO.dtheta)
		}
		
		public function findMeanInstTranslation():void
		{
			//trace("KineMetric::findMeanInstTranslation");

			
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// cluster translation // OPERATION
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// translation values 
					// finds how far the cluster has moved between the current frame and a frame in history
						tcO.dx = 0;
						tcO.dy = 0;
						tcO.dz = 0;
					
					if (tpn == 1) 
						{
							if (cO.pointArray[0])
								{
								tcO.dx = cO.pointArray[0].DX;
								tcO.dy = cO.pointArray[0].DY;
								tcO.dz = cO.pointArray[0].DZ;
								}
						}
					else if (tpn > 1)
					{
						for (i = 0; i < tpn; i++) 
						{
								if (cO.pointArray[i])//&&(!pointList[i].holdLock))// edit
								{
									// SIMPLIFIED DELTa
									tcO.dx += cO.pointArray[i].DX;
									tcO.dy += cO.pointArray[i].DY;
									tcO.dz += cO.pointArray[i].DZ;
								}	
						}
						tcO.dx *= tpnk0;
						tcO.dy *= tpnk0;
						tcO.dz *= tpnk0;
					}
					//	trace("drag calc kine",c_dx,c_dy);
		}
		
		public function findSimpleMeanInstSeparation():void
		{
			//trace("KineMetric::findSimpleMeanInstSeparation");

			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// cluster separation //OPERATION
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			// finds the change in the separation of the cluster between the current frame and a previous frame in history
			tcO.ds = 0;
			tcO.dsx = 0;
			tcO.dsy = 0;
			tcO.dsz = 0;
					
					if (tpn > 1)
					{	
						if (tcO.history[1])
						{
							if (tcO.history[1].radius != 0) tcO.ds = (tcO.radius - tcO.history[1].radius) * sck;
							if (tcO.history[1].width != 0) tcO.dsx = (tcO.width - tcO.history[1].width) * sck;
							if (tcO.history[1].height != 0) tcO.dsy = (tcO.height - tcO.history[1].height) * sck;
							if (tcO.history[1].length != 0) tcO.dsz = (tcO.length - tcO.history[1].length) * sck;
						} 
					}
		}
		
		public function findMeanInstSeparation():void
		{
			//trace("KineMetric::findMeanInstSeparation");

			
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// cluster separation //OPERATION
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// finds the change in the separation of the cluster between the current frame and a previous frame in history
					tcO.ds = 0;
					tcO.dsx = 0;
					tcO.dsy = 0;
					tcO.dsz = 0;
					
					if (tpn > 1)
					{	
						var sx:Number = 0;
						var sy:Number = 0;
						var sz:Number = 0;
						var sx_mc:Number = 0;
						var sy_mc:Number = 0;
						var sz_mc:Number = 0;
						
						for (i = 0; i < tpn; i++) 
						{
							//if ((N > i + 1) && (pointList[0].history[mc]) && (pointList[i + 1].history[mc]))
							if ((tpn>i+1)&&(cO.pointArray[0].history.length>mc) && (cO.pointArray[i + 1].history.length>mc))
							{		
								sx = Math.abs(cO.pointArray[0].x - cO.pointArray[i + 1].x);
								sy = Math.abs(cO.pointArray[0].y - cO.pointArray[i + 1].y);
								sz = Math.abs(cO.pointArray[0].z - cO.pointArray[i + 1].z);
								sx_mc = Math.abs(cO.pointArray[0].history[mc].x - cO.pointArray[i + 1].history[mc].x);
								sy_mc = Math.abs(cO.pointArray[0].history[mc].y - cO.pointArray[i + 1].history[mc].y);
								sz_mc = Math.abs(cO.pointArray[0].history[mc].z - cO.pointArray[i + 1].history[mc].z);
								
								//c_ds += (Math.sqrt((pointList[0].history[0].x - pointList[i + 1].history[0].x) * (pointList[0].history[0].x - pointList[i + 1].history[0].x) + (pointList[0].history[0].y - pointList[i + 1].history[0].y) * (pointList[0].history[0].y - pointList[i + 1].history[0].y)) - Math.sqrt((pointList[0].history[mc].x - pointList[i + 1].history[mc].x) * (pointList[0].history[mc].x - pointList[i + 1].history[mc].x) + (pointList[0].history[mc].y - pointList[i + 1].history[mc].y) * (pointList[0].history[mc].y - pointList[i + 1].history[mc].y)))
								tcO.ds += (Math.sqrt(sx * sx + sy * sy + sz * sz) - Math.sqrt(sx_mc * sx_mc + sy_mc * sy_mc + sz_mc * sz_mc));
								tcO.dsx += (sx - sx_mc)//Math.sqrt(sx * sx - sx_mc * sx_mc);
								tcO.dsy += (sy - sy_mc)//Math.sqrt(sy * sy - sy_mc * sy_mc);
								tcO.dsz += (sz - sz_mc)//Math.sqrt(sz * sz - sz_mc * sz_mc);
							}
						}
					
					//c_dsx = (sx - sx_mc)*k1;
					//c_dsy = (sy - sy_mc)*k1;	
						
					//c_ds *= k1;	
					tcO.ds *= tpnk1 * sck;//(Math.sqrt(sx * sx + sy * sy) - Math.sqrt(sx_mc * sx_mc + sy_mc * sy_mc))*k1 * sck;
					tcO.dsx *= tpnk1 * sck; //(sx - sx_mc)*k1 * sck;//(Math.sqrt((sx * sx) - (sx_mc * sx_mc)))*k1 * sck;//cO.ds;
					tcO.dsy *= tpnk1 * sck; //(sy - sy_mc)*k1 * sck;//(Math.sqrt((sy * sy) - (sy_mc * sy_mc)))*k1 * sck;//cO.ds;
					tcO.dsz *= tpnk1 * sck; //(sy - sy_mc)*k1 * sck;//(Math.sqrt((sy * sy) - (sy_mc * sy_mc)))*k1 * sck;//cO.ds;
					//trace("mean inst separation");
					}
					
					
		}	
		
		public function findSimpleMeanInstRotation():void
		{
			//trace("KineMetric::findSimpleMeanInstRotation");			
			
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// cluster roation // OPERATION
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// finds the change in the rotation of the cluster between the current frame and a previous frame in history
			tcO.dtheta = 0;
						
			if(tpn>1)
				{	
				if (tcO.history[1])
					{
						if (tcO.history[1].rotation!=0) tcO.dtheta =(tcO.rotation - tcO.history[1].rotation)	 
					}					
				}
			//trace(cO.dtheta);
		}
		
		public function findMeanInstRotation():void
		{
			//trace("KineMetric::findMeanInstRotation");						
			
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// cluster roation // OPERATION
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// finds the change in the rotation of the cluster between the current frame and a previous frame in history

						tcO.dtheta = 0;
						tcO.dthetaX = 0;
						tcO.dthetaY = 0;
						tcO.dthetaZ = 0;
						
						if(tpn>1)
						{
						for (i = 0; i < tpn; i++) 
						{
								if ((tpn > i + 1)&&(cO.pointArray[0].history.length>mc) && (cO.pointArray[i + 1].history.length>mc))
								{		
									// SIMPLIFIED DELTA 
									var dtheta:Number = 0;
									var dthetaX:Number = 0;
									var dthetaY:Number = 0;
									var dthetaZ:Number = 0;

									var theta0:Number = calcAngle((cO.pointArray[0].x - cO.pointArray[i+1].x), (cO.pointArray[0].y - cO.pointArray[i+1].y));									
									var theta1:Number = calcAngle((cO.pointArray[0].history[mc].x - cO.pointArray[i+1].history[mc].x), (cO.pointArray[0].history[mc].y - cO.pointArray[i+1].history[mc].y));
								
									var theta0x:Number = calcAngle((cO.pointArray[0].y - cO.pointArray[i+1].y), (cO.pointArray[0].z - cO.pointArray[i+1].z));
									var theta1x:Number = calcAngle((cO.pointArray[0].history[mc].y - cO.pointArray[i + 1].history[mc].y), (cO.pointArray[0].history[mc].z - cO.pointArray[i + 1].history[mc].z));
									
									var theta0y:Number = -calcAngle((cO.pointArray[0].x - cO.pointArray[i+1].x), (cO.pointArray[0].z - cO.pointArray[i+1].z));
									var theta1y:Number = -calcAngle((cO.pointArray[0].history[mc].x - cO.pointArray[i+1].history[mc].x), (cO.pointArray[0].history[mc].z - cO.pointArray[i+1].history[mc].z));

									var theta0z:Number = calcAngle((cO.pointArray[0].x - cO.pointArray[i+1].x), (cO.pointArray[0].y - cO.pointArray[i+1].y));
									var theta1z:Number = calcAngle((cO.pointArray[0].history[mc].x - cO.pointArray[i+1].history[mc].x), (cO.pointArray[0].history[mc].y - cO.pointArray[i+1].history[mc].y));									
									
									if ((theta0 != 0) && (theta1 != 0)) 
										{
										if (Math.abs(theta0 - theta1) > 180) dtheta = 0
										else dtheta = (theta0 - theta1);
										}
									else dtheta = 0;
									if ((theta0x != 0) && (theta1x != 0)) 
										{
										if (Math.abs(theta0x - theta1x) > 180) dthetaX = 0
										else dthetaX = (theta0x - theta1x);
										}
									else dthetaX = 0;
									if ((theta0y != 0) && (theta1y != 0)) 
										{
										if (Math.abs(theta0y - theta1y) > 180) dthetaY = 0
										else dthetaY = (theta0y - theta1y);
										}
									else dthetaY = 0;	
									if ((theta0z != 0) && (theta1z != 0)) 
										{
										if (Math.abs(theta0z - theta1z) > 180) dthetaZ = 0
										else dthetaZ = (theta0z - theta1z);
										}
									else dthetaZ = 0;										
									tcO.dtheta += dtheta;
									tcO.dthetaX += dthetaX;
									tcO.dthetaY += dthetaY;
									tcO.dthetaZ += dthetaZ;									
								}
						}
						tcO.dtheta *= tpnk1;
						tcO.dthetaX *= tpnk1;
						tcO.dthetaY *= tpnk1;
						tcO.dthetaZ *= tpnk1;						
						//tcO.dtheta = tcO.dthetaX + tcO.dthetaY + tcO.dthetaZ;
						}
						//trace(cO.dtheta);
		}
		
		public function findMeanInstAcceleration():void
		{
			//trace("KineMetric::findMeanInstAcceleration");									
			
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// cluster acceleration x y // OPERATION
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////

						tcO.ddx = 0;
						tcO.ddy = 0;
						tcO.ddz = 0;
						
						for (i = 0; i < tpn; i++) 
						{
							if (cO.pointArray[i].history[1])//&&(!pointList[i].holdLock))//edit
							{
								// SIMPLIFIED DELTAS
								// second diff of x anf y wrt t
								tcO.ddx += cO.pointArray[i].dx - cO.pointArray[i].history[1].dx;
								tcO.ddy += cO.pointArray[i].dy - cO.pointArray[i].history[1].dy;
								tcO.ddz += cO.pointArray[i].dz - cO.pointArray[i].history[1].dz;
							}
						}
						tcO.ddx *= tpnk0;
						tcO.ddy *= tpnk0;
						tcO.ddz *= tpnk0;
					
					/////////////////////////////////////////////////////////////////////////////////////	
		}
		
		public function findMeanTemporalVelocity():void
		{
			//trace("KineMetric::findMeanTemporalVelocity");	
			
		/////////////////////// mean velocity of cluster // OPERATION ////////////////////////////////////////
			tcO.etm_dx = 0;
			tcO.etm_dy = 0;
			tcO.etm_dz = 0;
			
			var t:Number = 2;
			var t0:Number = 1 /t;
					
			for (i = 0; i < tpn; i++) 
				{
					if(cO.pointArray[i].history.length>t)
					{
					for (j = 0; j < t; j++) 
						{
						tcO.etm_dx += cO.pointArray[i].history[j].dx;
						tcO.etm_dy += cO.pointArray[i].history[j].dy;
						tcO.etm_dz += cO.pointArray[i].history[j].dz;
						}
					}
			}
			//cO.etm_dx *= k0 * t0;
			//cO.etm_dy *= k0 * t0;

		} 
		
		public function findMeanTemporalAcceleration():void
		{
			//trace("KineMetric::findMeanTemporalAcceleration");	
			
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// cluster acceleration x y // OPERATION
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////
			tcO.etm_ddx = 0;
			tcO.etm_ddy = 0;
			tcO.etm_ddz = 0;
			
			
				
			var t:Number = 2;
			var t0:Number = 1 /t;
						
				for (i = 0; i < tpn; i++) 
					{
					if(cO.pointArray[i].history.length>t)
						{
							// SIMPLIFIED DELTAS
							// second diff of x anf y wrt t
							for (j = 0; j < t; j++) 
							{
								tcO.etm_ddx += cO.pointArray[i].history[j + 1].dx - cO.pointArray[i].history[j].dx;
								tcO.etm_ddy += cO.pointArray[i].history[j + 1].dy -cO.pointArray[i].history[j].dy;
								tcO.etm_ddz += cO.pointArray[i].history[j + 1].dz -cO.pointArray[i].history[j].dz;
								//cO.etm_ddx += pointList[i].history[0].dx - pointList[i].history[1].dx;
								//cO.etm_ddy += pointList[i].history[0].dy - pointList[i].history[1].dy;
							}
						}
					}
					//trace(k0, t0);
			//cO.etm_ddx *= k0 * t0;
			//cO.etm_ddy *= k0 * t0;
		}
		
		public function findInstOrientation():void 
		{
				//trace("KineMetric::findInstOrientation");			
			
				var handArray:Array = new Array();
				var maxDist:Number = 0;
				var maxAngle:Number = 0;
				var dist:Number = 0;
				var angle:Number = 180;
				
				tcO.orient_dx = 0;
				tcO.orient_dy = 0;	
						
							for (i = 0; i < tpn; i++) 
								{
									if (cO.pointArray[i].history[0])
									//if(pointList.length>i)
									{
										handArray[i] = new Array();
										handArray[i].id = cO.pointArray[i].id; // set point id
										handArray[i].touchPointID = cO.pointArray[i].touchPointID; // set point id
									
										// find distance between center of cluster and finger tip
										var dxe:Number = (cO.pointArray[i].history[0].x - cO.x);
										var dye:Number = (cO.pointArray[i].history[0].y - cO.y);
										
										// find diatance between mean center of cluster and finger tip
										var dxf:Number = (cO.pointArray[i].history[0].x - cO.mx);
										var dyf:Number = (cO.pointArray[i].history[0].y - cO.my);
										var ds1:Number = Math.sqrt(dxf * dxf + dyf * dyf)
										
										handArray[i].dist = ds1; // set distance from mean
										handArray[i].angle = 180; // init angle between vectors to radial center

										for (var q:int = 0; q < tpn; q++) 
										{
											if ((i != q)&&(cO.pointArray[q].history[0]))
												{
												var dxq:Number = (cO.pointArray[q].history[0].x - tcO.x);
												var dyq:Number = (cO.pointArray[q].history[0].y - tcO.y);
												angle = dotProduct(dxe, dye, dxq, dyq)*RAD_DEG;
												
												if (angle < handArray[i].angle) handArray[i].angle = angle;
												}
										}
									//trace("finger", handArray[i].id, handArray[i].dist, handArray[i].angle) // point list
									
									// find max angle
									if (maxAngle < handArray[i].angle) 		maxAngle = handArray[i].angle;
									// find min dist
									if (maxDist < handArray[i].dist) 	maxDist = handArray[i].dist;
								}
							}
							
							
							// calculate thumb probaility value
							for (i = 0; i < tpn; i++) 
								{
									handArray[i].prob = (handArray[i].angle/maxAngle + handArray[i].dist/maxDist)*0.5
								}
							handArray.sortOn("prob",Array.DESCENDING);
							
							///////////////////////////////////////////////////
							//NOW CORRECT UNIQUE ID
							tcO.thumbID = handArray[0].touchPointID;
							//tcO.thumbID = handArray[0].id;
							
							// BUT NEED TO FIX
							// RIGHT HAND RETURNS PINKY AS THUMB AS ANGLE INCORRECTLY CALCUKATED
							// NEED TO ALSO DETERMIN LEFT HAND AND RIGHT HAND
							//trace("hand angle",handArray[0].angle)
							
							//trace("ID", tcO.thumbID,handArray[0].id, handArray[0].touchPointID)
						
							// calc orientation vector // FIND ORIENTATION USING CLUSTER RADIAL CENTER
							for (i = 0; i < tpn; i++) 
								{
									if (cO.pointArray[i].id != handArray[0].id) 
									{	
										tcO.orient_dx += (cO.pointArray[i].history[0].x - tcO.x);
										tcO.orient_dy += (cO.pointArray[i].history[0].y - tcO.y);
									}
								}
							tcO.orient_dx *= tpnk1;
							tcO.orient_dy *= tpnk1;	
							
							
						
		}
		
		public function findInstPivot():void
		{
			//trace("KineMetric::findInstPivot");			
			
			
			
			
			
			
					//if (tpn == 1)
					if(tpn)
					{
						var x_c:Number = 0
						var y_c:Number = 0
						
						var dxh:Number = 0
						var dyh:Number = 0
						var dxi:Number = 0;
						var dyi:Number = 0;
						var pdist:Number = 0;
						var t0:Number = 0;
						var t1:Number = 0;
						var theta_diff:Number = 0
			
						tcO.pivot_dtheta = 0
					
						// CENTER OF DISPLAY OBJECT
						if (ts.trO.transAffinePoints) 
						{
							//trace("test", tO.transAffinePoints[4])
							x_c = ts.trO.transAffinePoints[4].x
							y_c = ts.trO.transAffinePoints[4].y
						}
						
								if (cO.pointArray.length==1)
								{
								if(cO.pointArray[0].history.length > 1 ) {
								//if (cO.pointArray[0].history.length>1) 
									
									// find touch point translation vector
									dxh = cO.pointArray[0].history[1].x - x_c;
									dyh = cO.pointArray[0].history[1].y - y_c;
											
									// find vector that connects the center of the object and the touch point
									dxi = cO.pointArray[0].x - x_c;
									dyi = cO.pointArray[0].y - y_c;
									pdist = Math.sqrt(dxi * dxi + dyi * dyi);
											
									t0 = calcAngle(dxh, dyh);
									t1 = calcAngle(dxi, dyi);
									if (t1 > 360) t1 = t1 - 360;
									if (t0 > 360) t0 = t0 - 360;
									
									theta_diff = t1 - t0
									
									if (theta_diff>300) theta_diff = theta_diff -360; //trace("Flicker +ve")
									if (theta_diff<-300) theta_diff = 360 + theta_diff; //trace("Flicker -ve");
									
									
									//pivot thresholds
									//if (Math.abs(theta_diff) > pivot_threshold)
									//{	
										// weighted effect
										tcO.pivot_dtheta = theta_diff*Math.pow(pdist, 2)*pvk;
										tcO.x = cO.pointArray[0].x;
										tcO.y = cO.pointArray[0].y;
									//}
									//else cO.pivot_dtheta = 0; 
									}
								}

								if (cO.pointArray.length>1) 
									{		
									//trace("hist",cO.pointArray[0].history.length,cO.pointArray[1].history.length)
									var cx1:Number = 0;
									var cy1:Number = 0;
									var cx0:Number = 0;
									var cy0:Number = 0;
									
										for (i = 0; i < cO.pointArray.length; i++) 
										{
											if (cO.pointArray[i].history.length > 1)
											{
												//trace("pivot")
												cx1 += cO.pointArray[i].history[1].x; 
												cy1 += cO.pointArray[i].history[1].y; 
												cx0 += cO.pointArray[i].history[0].x; 
												cy0 += cO.pointArray[i].history[0].y;
											}
										}
										
									cx1 *= tpnk0;
									cy1 *= tpnk0; 
									cx0 *= tpnk0; 
									cy0 *= tpnk0;	
									
									//trace(tpn, tpnk0,cx1,cy1,cx0,cy0)
									
									// find touch point translation vector
									dxh = cx1 - x_c;
									dyh = cy1 - y_c;
											
									// find vector that connects the center of the object and the touch point
									dxi = cx0 - x_c;
									dyi = cy0 - y_c;
									pdist = Math.sqrt(dxi * dxi + dyi * dyi);
											
									t0 = calcAngle(dxh, dyh);
									t1 = calcAngle(dxi, dyi);
									if (t1 > 360) t1 = t1 - 360;
									if (t0 > 360) t0 = t0 - 360;
									
									theta_diff = t1 - t0
									
									if (theta_diff>300) theta_diff = theta_diff -360; //trace("Flicker +ve")
									if (theta_diff<-300) theta_diff = 360 + theta_diff; //trace("Flicker -ve");
									
									
									//pivot thresholds
									//if (Math.abs(theta_diff) > pivot_threshold)
									//{	
										// weighted effect
										tcO.pivot_dtheta = theta_diff*Math.pow(pdist, 2)*pvk;
										tcO.x = cx0;
										tcO.y = cy0;
									//}
									//else cO.pivot_dtheta = 0; 
								}	
								
			}
		} 
		
		

		///////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////
		// sensor IP analysis
		///////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////
		public function resetSensorCluster():void { }
		public function resetSensorClusterConsts():void{}
		public function findSensorClusterDimensions():void{}
		public function findSensorVelocity():void{}
		public function findSensorJolt():void
		{
			//trace("accelerometer kinemetric");
			
			var snr:Vector.<Number> = cO.sensorArray;
			
			//trace("timestamp", snr[0]);
			/*	
            trace("ax", event.accelerationX);
            trace("ay", event.accelerationY);
			trace("az", event.accelerationZ);
			trace("timestamp", event.timestamp);
			*/
		}
		
		public function findSensorSubClusters():void{}
		public function weaveSensorCluster():void{}
		
		////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////
		
		public function initFilterIPCluster():void
			{
				///////////////////////////////////////////////////////
				//palm ip config
				handConfig.palm = new Object();
				handConfig.palm.fist = false; // hand open closed state
				handConfig.palm.orientation = undefined; //up/down
				handConfig.palm.type = undefined; // left right
				handConfig.palm.fn = undefined;//digits on the hand
				handConfig.palm.flatness_min = undefined; //degree of flatness of fingers relative to plane of palm
				handConfig.palm.flatness_max = undefined; //degree of flatness of fingers relative to plane of palm
				handConfig.palm.splay_min = undefined; // finger separation
				handConfig.palm.splay_max = undefined; // finger separation
				
				//fist ip config
				handConfig.fist = new Object();
				handConfig.fist.fist = true; // hand open closed state
				handConfig.fist.orientation = undefined; //up/down
				handConfig.fist.type = undefined; // left right
				handConfig.fist.fn = undefined;//digits on the hand
				handConfig.fist.flatness_min = undefined; //degree of flatness of fingers relative to plane of palm
				handConfig.fist.flatness_max = undefined; //degree of flatness of fingers relative to plane of palm
				handConfig.fist.splay_min = undefined; // finger separation
				handConfig.fist.splay_max = undefined; // finger separation
				
				//pinch config
				handConfig.pinch = new Object();
				handConfig.pinch.distance_max = undefined;
				handConfig.pinch.fn = undefined;
			
				//trigger config
				handConfig.trigger = new Object();
				handConfig.trigger.extension_min
				handConfig.trigger.fn = undefined;
			
			
			}
		
		
		
		public function filterIPCluster():void
			{
				// TODO: PULL FROM LOCAL GESTURE LIST
				//OBJECT LEVEL GML DEFINED IP FILTERING
				
				
				
				
				
				if (ts.cO.iPointArray)
					{
					//var temp_iPointArray = new Vector.<InteractionPointObject>();
						//temp_iPointArray = ts.cO.iPointArray;
						
						//ts.cO.iPointArray.length = 0;
						
					for (i = 0; i < ts.cO.iPointArray.length; i++)
							{
								var ipt:InteractionPointObject = ts.cO.iPointArray[i];
								////////////////////////////////////////////////////////////////////
								//check exists and check if ip type supported on display object
								//trace("supported", ipt.type,ts.tc.ipSupported(ipt.type));
								if (ipt)
								{
									
									if((ipt.type=="palm")&&(handConfig.palm))
									{
										//trace("fist filter ip", ipt.fist, ts.cO.iPointArray[i].fist);
										// NOTE CAN ONLY SPLICE AN IP ONCE
										if (handConfig.palm.fist != undefined) if (ipt.fist != handConfig.palm.fist) 
										{
										trace("remove")
										ts.cO.iPointArray.splice(ipt.id, 1);
										}
										//if (handConfig.palm.orientation != undefined) if (ipt.orientation != handConfig.palm.orientation) ts.cO.iPointArray.splice(ipt.id, 1);
										//if (handConfig.palm.fn != undefined) if (ipt.fn != handConfig.palm.fn) ts.cO.iPointArray.splice(ipt.id, 1);
										//if (handconfig.palm.fist != undefined) if (ipt.fist!=handconfig.palm.fist) ts.cO.iPointArray.splice(ipt.id, 1);
									}
							}
						}
					
					
					
					
					
				}
			}
		
		
		public function hitTestCluster():void
			{
				//ONLY DOES HIT TEST IF MOTION POINTS EXIST
				if ((gms))//&&(ts.mpn)
				{
					//trace("hit test ip cluster",gms.cO.iPointArray.length,ts.motionClusterMode,ts)
					
				if ((ts.motionClusterMode == "global")||(ts.motionClusterMode == "local_weak"))
					{
					ts.cO.iPointArray = new Vector.<InteractionPointObject>();
					
					for (i = 0; i < gms.cO.iPointArray.length; i++)
							{
								var ipt:InteractionPointObject = gms.cO.iPointArray[i];
								////////////////////////////////////////////////////////////////////
								//check exists and check if ip type supported on display object
								//trace("supported", ipt.type,ts.tc.ipSupported(ipt.type));
								if ((ipt)&&(ts.tc.ipSupported(ipt.type)))
								{
									//trace(ts,gms);
									var xh:Number = normalize(ipt.position.x, minX, maxX) *sw;//1920
									var yh:Number = normalize(ipt.position.y, minY, maxY) * sh//ts.stage.stageHeight//1080;// ;
									//trace("ht",ts.motionClusterMode)

									if (ts.motionClusterMode == "local_weak")
									{
										if ((ts is TouchSprite)||(ts is TouchMovieClip))
										{
											//trace("2d hit test");
											if (ts.hitTestPoint(xh, yh, false)) cO.iPointArray.push(ipt);
										}
										if (ts is ITouchObject3D)//TouchObject3D
										{
											//trace("3d hit test", ts.vto, ts.vto.parent, ts.vto.parent.scene, ts.view, TouchManager3D.hitTest3D(ts as TouchObject3D,ts.view, xh, yh));
											//trace("3d hit test", TouchManager3D.hitTest3D(ts as TouchObject3D, ipt.position.x, ipt.position.y));
											
											if (hitTest3D != null) {
												if (hitTest3D(ts as ITouchObject3D, xh, yh)) cO.iPointArray.push(ipt);
											}
											//if(TouchManager3D.hitTest3D(ts as TouchObject3D,ts.view, ipt.position.x, ipt.position.y))cO.iPointArray.push(ipt);
										}
									}
									else if (ts.motionClusterMode == "global") 
									{
										cO.iPointArray.push(ipt);
									}
									//trace("phase",ipt.phase)
									//cO.iPointArray.push(ipt);/////////////////////////////////////////////////
								}
								
								//if(ipt.type=="palm")trace("fist hit test", ipt.fist)
							}
					}
					
					// FOR LOCAL STRONG SEE INTERACTION POINT MANAGER
					if (ts.motionClusterMode == "local_strong") {
						if (ts.cO.iPointArray.length)
						{
						//trace("strong length", ts.cO.iPointArray.length);
						for (i = 0; i < ts.cO.iPointArray.length; i++)
							{
								//trace(ts.cO.iPointArray[i].interactionPointID,ts.cO.iPointArray[i].phase);
								if(ts.cO.iPointArray[i].phase=="end") ts.cO.iPointArray.splice(i, 1);
									//trace("no exist")
								//}
							}
						}
					}
					
					
					
				}
			}
			
		///////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////
		// 3d IP motion analysis
		///////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////
		public function mapCluster3Dto2D():void
			{
				//trace("map cluster data 3d to 2d",cO.motionArray.length,cO.iPointArray.length)
				
				// CLEARS OUT LOCAL POINT ARRAYS
				cO.motionArray2D = new Vector.<MotionPointObject>();
				cO.iPointArray2D = new Vector.<InteractionPointObject>();
				
				
				// NORMALIZE MOTION POINT DATA TO 2D
				for (i = 0; i < cO.motionArray.length; i++) 
						{
							var pt:MotionPointObject = cO.motionArray[i];
							var pt2d:MotionPointObject = new MotionPointObject();
							
							//pt2d.motionPointID = pt.motionPointID;
							
							pt2d.position.x = normalize(pt.position.x, minX, maxX) * sw//1920;//stage.stageWidth;
							pt2d.position.y = normalize(pt.position.y, minY, maxY) * sh//1080;// stage.stageHeight;
							pt2d.position.z = pt.position.z
							
							//normalized vector
							pt2d.direction.x = -pt.direction.x;
							pt2d.direction.y = pt.direction.y;
							pt2d.direction.z = pt.direction.z;
							
							//normalized vector
							pt2d.normal.x = -pt.normal.x;
							pt2d.normal.y = pt.normal.y;
							pt2d.normal.z = pt.normal.z;
							
							pt2d.type = pt.type;
							pt2d.fingertype = pt.fingertype;
							//pt2d.history = pt.history;
							
						cO.motionArray2D.push(pt2d);
						}
						
						
				// NORMALIZE INTERACTION POINT DATA TO 2D	
				for (i = 0; i < cO.iPointArray.length; i++)
						{
							var ipt:InteractionPointObject = cO.iPointArray[i];
							
							if (ipt)
							{
								var ipt2d:InteractionPointObject = new InteractionPointObject();
								
								// stores root ip id
								//trace("interaction point id",ipt.interactionPointID, ipt.type)
								//ipt2d.id = ipt.interactionPointID;
								
								ipt2d.position.x = normalize(ipt.position.x, minX, maxX) * sw//1920;//stage.stageWidth;
								ipt2d.position.y = normalize(ipt.position.y, minY, maxY) * sh//1080;// stage.stageHeight;
								ipt2d.position.z = ipt.position.z
								
								//normalized vector
								ipt2d.direction.x = -ipt.direction.x;
								ipt2d.direction.y = ipt.direction.y;
								ipt2d.direction.z = ipt.direction.z;
								
								//normalized vector
								ipt2d.normal.x = -ipt.normal.x;
								ipt2d.normal.y = ipt.normal.y;
								ipt2d.normal.z = ipt.normal.z;
								
								ipt2d.type = ipt.type;
								ipt2d.history = ipt.history;
								
								// pass ip properties
								ipt2d.fist = ipt.fist;
								
								
							cO.iPointArray2D.push(ipt2d);
							
							//if(ipt2d.type=="palm")trace("fist 3d to 2d", ipt.fist)
							}
						}
		}
	
	    public function getSubClusters():void
			{
			//trace("get sub clusters")
			var temp_ipointArray:Vector.<InteractionPointObject>;
				
			if (!ts.transform3d) temp_ipointArray = cO.iPointArray2D;
			else temp_ipointArray = cO.iPointArray;
			
				//zero subcluster data //////////////////////////////
				for (j = 0; j < cO.subClusterArray.length; j++) 
				{
					cO.subClusterArray[j].iPointArray.length=0;
				}
			
				//update subcluster point arrays //////////////////////////////
				for (i = 0; i < temp_ipointArray.length; i++) 
				{
					var ipt:InteractionPointObject = temp_ipointArray[i];
						
					for (j = 0; j < cO.subClusterArray.length; j++) 
					{
						if (ipt.type==cO.subClusterArray[j].type) cO.subClusterArray[j].iPointArray.push(ipt);
					}
						//trace(ipt.type)
					//if(ipt.type=="fist")trace("fist subcluster", ipt.fist)
				}
	}
		
		
		
		// GET IP CLUSTER CONSTS
		public function find3DGlobalIPConstants():void//type:String
		{
			// GET INTERACTION POINT NUMBER
			ipn = cO.iPointArray.length;
			ts.ipn = ipn;
			ts.cO.ipn = ipn;
			ts.cO.mcO.ipn = ipn;
			
			//CHANGE IN INTERACTION POINT NUMBER
			if (cO.history.length>3) dipn = mcO.ipn - cO.history[1].ipn;
			else dipn = 1;
			cO.dipn = dipn;

			// GET IP BASED CONSTANTS
			if (ipn == 1) ipnk = 1;
			else ipnk = 1 / ipn;
			
			if (ipn == 1) ipnk0 = 1;
			else ipnk0 = 1 / (ipn - 1);
			
			//trace("dipn",cO.dipn, cO.ipnk, cO.ipnk0);
		}
		
		public function find3DIPConstants(index:int):void//type:String
		{
			var sdipn:int = 0;
			var sipn:int = 0;
			var sipnk:Number = 0;
			var sipnk0:Number = 0;
			
			
			// GET INTERACTION POINT NUMBER
			cO.subClusterArray[index].ipn = cO.subClusterArray[index].iPointArray.length;
			sipn = cO.subClusterArray[index].ipn;
			
			//CHANGE IN INTERACTION POINT NUMBER
			if (cO.history.length>3) sdipn = sipn - cO.history[1].subClusterArray[index].ipn;
			else sdipn = 1;
			
			// GET IP BASED CONSTANTS
			if (sipn == 1) sipnk = 1;
			else sipnk = 1 / sipn;
			
			if (sipn == 1) sipnk0 = 1;
			else sipnk0 = 1 / (sipn - 1);
			
			cO.subClusterArray[index].ipn = sipn;
			cO.subClusterArray[index].dipn = sdipn;
			cO.subClusterArray[index].ipnk = sipnk;
			cO.subClusterArray[index].ipnk0 = sipnk0;
		
			//trace("const ipn",cO.subClusterArray[index].type,cO.subClusterArray[index].ipn,cO.subClusterArray[index].dipn, cO.subClusterArray[index].ipnk, cO.subClusterArray[index].ipnk0);
		}
		
	
		
		// IP CLUSTER DIMENSIONS
		public function find3DIPDimension(index:int):void
		{
			// GET TYPED SUB CLUSTER from cluster matrix //////////////////////////
			var sub_cO:ipClusterObject = cO.subClusterArray[index];

			// GET TRANSFORMED INTERACTION POINT LIST
			var ptArray:Vector.<InteractionPointObject> = sub_cO.iPointArray;
			
			var sipn:int = sub_cO.ipn
			var sipnk:Number = sub_cO.ipnk;
			var sipnk0:Number = sub_cO.ipnk0

			sub_cO.x = 0;
			sub_cO.y = 0;
			sub_cO.z = 0;
			
			sub_cO.radius = 0
			sub_cO.width = 0;
			sub_cO.height = 0;
			sub_cO.length = 0;
			
			sub_cO.separationX = 1;
			sub_cO.separationY = 1;
			sub_cO.separationZ = 1;
			
			// rotation of group
			sub_cO.rotation = 0
			sub_cO.rotationX = 0; 
			sub_cO.rotationY = 0; 
			sub_cO.rotationZ = 0;
			
			
			//trace("dim",sipn)
			
			//APPLY DIMENTIONAL ANALYSIS
			if ((sipn!=0))
			{
			//trace("sub dims",sipn)
					//if (sipn > 1)
					//{
						for (i = 0; i < sipn; i++) 
								{
									//trace("add points")
									var ipt:InteractionPointObject = ptArray[i];
									var pt:InteractionPointObject = ptArray[0];
									
									sub_cO.x += ipt.position.x;
									sub_cO.y += ipt.position.y;
									sub_cO.z += ipt.position.z;
									
									/* //ONLY FOR ONE HAND
									if (pt.type == "palm")
									{
										cO.rotationX = RAD_DEG * Math.asin(pt.normal.x);
										cO.rotationY = RAD_DEG * Math.asin(pt.normal.y);
										cO.rotationZ = RAD_DEG * Math.asin(pt.normal.z);
									}*/
									
									//SIZE WIDTH HIEGHT DEPTH
									for (var q:uint = 0; q < i+1; q++) 
									{
									 if (i != q) 
									 { 
										var dx:Number = ipt.position.x - ptArray[q].position.x
										var dy:Number = ipt.position.y - ptArray[q].position.y
										var dz:Number = ipt.position.z - ptArray[q].position.z
										
										var abs_dx:Number = Math.abs(dx);
										var abs_dy:Number = Math.abs(dy);
										var abs_dz:Number = Math.abs(dz);
										
										// MAX SEPERATION BETWEEN A PAIR OF POINTS IN THE CLUSTER
										if (abs_dx > sub_cO.width) sub_cO.width = abs_dx;
										if (abs_dy > sub_cO.height) sub_cO.height = abs_dy;
										if (abs_dz > sub_cO.length) sub_cO.length = abs_dz;
									 }
									}
								 
								 
								 if ((pt) && (ipt))//&&(!pointList[i].holdLock)&&(!pointList[j1].holdLock)) //edit
									{
										var dxs:Number = pt.position.x - ipt.position.x;
										var dys:Number = pt.position.y - ipt.position.y;
										var dzs:Number = pt.position.z - ipt.position.z;

										// separation of group
										sub_cO.separationX += Math.abs(dxs);
										sub_cO.separationY += Math.abs(dys);
										sub_cO.separationZ += Math.abs(dzs);
										
										// rotation of group
										//sub_cO.rotation += (calcAngle(dxs, dys)) //|| 0
										//sub_cO.rotationX += (calcAngle(dys, dzs)); 
										//sub_cO.rotationY += (calcAngle(dzs, dxs)); 
										//sub_cO.rotationZ += (calcAngle(dxs, dys));
										
										sub_cO.rotation = 0;
										sub_cO.rotationX = 0; 
										sub_cO.rotationY = 0; 
										sub_cO.rotationZ = 0;
									}
							}
							// divide by subcluster pair count sipnk0 
							sub_cO.separationX *= sipnk0;
							sub_cO.separationY *= sipnk0;
							sub_cO.separationZ *= sipnk0;
							
							
							sub_cO.radius = 0.5*Math.sqrt(sub_cO.width * sub_cO.width + sub_cO.height * sub_cO.height + sub_cO.length * sub_cO.length);//
							//divide by subcluster ip number sipnk 
							
							sub_cO.x *= sipnk;
							sub_cO.y *= sipnk; 
							sub_cO.z *= sipnk;
							
							//trace("sub cluster properties",sipnk)
							//trace("dim",sub_cO.ipn,sub_cO.ipnk,sub_cO.ipnk0, sub_cO.x,sub_cO.y,sub_cO.z)
							
							sub_cO.rotationList = new Vector.<Vector3D>
							
							for (i = 0; i < sipn; i++) 
								{
									//trace("add points")
									ipt = ptArray[i];
							
									if (ipt)
									{
										var dxc:Number = sub_cO.x - ipt.position.x;
										var dyc:Number = sub_cO.y - ipt.position.y;
										var dzc:Number = sub_cO.z - ipt.position.z;
										
										var tz:Number = (dyc / dxc); //yes
										var ty:Number = -(dzc / dxc);// reversed
										var tx:Number = -(dyc / dzc); // reversed
										
										var rx:Number = Math.atan(tx) * RAD_DEG;
										var ry:Number = Math.atan(ty) * RAD_DEG;
										var rz:Number = Math.atan(tz) * RAD_DEG;
										
										
										var rot:Vector3D = new Vector3D();
											rot.x = (isNaN(rx)) ? 0 : rx;
											rot.y = (isNaN(ry)) ? 0 : ry;
											rot.z = (isNaN(rz)) ? 0 : rz;
										sub_cO.rotationList.push(rot);
										
										
										//sub_cO.rotation += Math.atan(tz) * RAD_DEG;
										//sub_cO.rotationX += Math.atan(tx) * RAD_DEG; 
										//sub_cO.rotationY += Math.atan(ty) * RAD_DEG; 
										//sub_cO.rotationZ += Math.atan(tz) * RAD_DEG;
										
										//sub_cO.rotation += Math.atan2(dyc , dxc) * RAD_DEG;
										//sub_cO.rotationX += Math.atan2(dyc , dzc) * RAD_DEG; 
										//sub_cO.rotationY += Math.atan2(dyc , dzc) * RAD_DEG; 
										//sub_cO.rotationZ += Math.atan2(dyc , dxc) * RAD_DEG;
										
										//sub_cO.rotation += calcAngle(dyc , dxc);
										//sub_cO.rotationX += calcAngle(dyc , dzc); 
										//sub_cO.rotationY += calcAngle(dyc , dzc); 
										//sub_cO.rotationZ += calcAngle(dyc , dxc);
										
										//sub_cO.rotation += calcAngle2(dyc , dxc);
										//sub_cO.rotationX += calcAngle2(dyc , dzc); 
										//sub_cO.rotationY += calcAngle2(dyc , dzc); 
										//sub_cO.rotationZ += calcAngle2(dyc , dxc);
										
										//sub_cO.rotation += calcAngle3(dyc , dxc);
										//sub_cO.rotationX += calcAngle3(dyc , dzc); 
										//sub_cO.rotationY += calcAngle3(dyc , dzc); 
										//sub_cO.rotationZ += calcAngle3(dyc , dxc);
										
										//trace("----",i, rx, ry, rz);
									}
								}
								
								// divide by subcluster pair count sipnk0 
								sub_cO.rotation *= sipnk0;
								sub_cO.rotationX *= sipnk0;
								sub_cO.rotationY *= sipnk0;
								sub_cO.rotationZ *= sipnk0;
					//}
					/*
					else if (sipn == 1) 
					{
						sub_cO.x = ptArray[0].position.x;
						sub_cO.y = ptArray[0].position.y;
						sub_cO.z = ptArray[0].position.z;
						
						sub_cO.width = 15;
						sub_cO.height = 15;
						sub_cO.length = 15;
						sub_cO.radius = 50;
						
						sub_cO.separationX = 1;
						sub_cO.separationY = 1;
						sub_cO.separationZ = 1;
						
						// ONLY FOR ONE HAND
						if (ptArray[0].type == "palm")
						{
							sub_cO.rotationX = -RAD_DEG * Math.asin(ptArray[0].normal.z);
							sub_cO.rotationY = RAD_DEG * Math.asin(ptArray[0].direction.x); // otherwise zero?
							sub_cO.rotationZ = RAD_DEG * Math.asin(ptArray[0].normal.x);
							sub_cO.rotation = sub_cO.rotationZ;
							//trace("palm direction", ptArray[0].direction.x, ptArray[0].direction.y, ptArray[0].direction.z);
							//trace("palm norm", ptArray[0].normal.x,ptArray[0].normal.y,ptArray[0].normal.z);
							//trace("palm rotate",sub_cO.rotationX,sub_cO.rotationY,sub_cO.rotationZ,sub_cO.rotation );
						}
						else 
						{
							sub_cO.rotationX = 0;
							sub_cO.rotationY = 0;
							sub_cO.rotationZ = 0;
							sub_cO.rotation = 0;
						}
						
						//sub_cO.rotationList = new Vector.<Vector3D>
						//sub_cO.rotationList.push(new Vector3D(0,0 ,0));
						
						//trace("dim",sub_cO.ipn, sub_cO.x,sub_cO.y,sub_cO.z)
						
						trace("ip cluster dims",sub_cO.ipn,sub_cO.x,sub_cO.y,sub_cO.z,ptArray[0].position.x,ptArray[0].position.y,ptArray[0].position.z, sub_cO.iPointArray[0].position.x,sub_cO.iPointArray[0].id);
					}
					*/
					
				//trace("sub dims",sub_cO.width,sub_cO.height,sub_cO.length,"motion",mcO.width,mcO.height,mcO.length,"root",cO.width,cO.height,cO.length)
				//trace(sub_cO.rotationZ,sub_cO.rotation, sipn)
			}
			//trace("get ip dims");
				
		}
		
		// TAP POINTS
		public function find3DIPTapPoints(index:int):void
		{
			//trace("---------------------tap kinemetric");
			// LOOK FOR 
				//VELOCITY SIGN CHANGE
				//ACCLERATION SIGN CHANGE 
				//JOLT MAGNITUDE MIN

			var hist:int = 10;//15
			var tapThreshold:Number = 10; // SMALLER MAKES EASIER//15
			
			// GET SUBCLUSTER OBJECT
			var sub_cO:ipClusterObject = cO.subClusterArray[index];
			
			//GET TRANSFORMED IP ARRAY
			var ptArray:Vector.<InteractionPointObject> = cO.subClusterArray[index].iPointArray;
			
			// GET CONSTS
			var sipn:uint = sub_cO.ipn;
			var sipnk:Number = sub_cO.ipnk;
			//var dipn:int = sub_cO.dipn;
			
			var gpt:GesturePointObject = new GesturePointObject();
			var gpt0:GesturePointObject = new GesturePointObject();
			var gpt1:GesturePointObject = new GesturePointObject();
			
			//trace("tap testing--", sipn);
	
			for (i = 0; i < sipn; i++) 
					{	
					var pt:InteractionPointObject = ptArray[i];

					if (pt)
						{
							//trace("tap hist check",pt.history.length)
							if (pt.history.length > hist)
							{
								//trace("jolt:",cO.iPointArray[0].history[1].jolt.x,cO.iPointArray[0].history[1].jolt.y,cO.iPointArray[0].history[1].jolt.z);
								if (Math.abs(pt.history[1].jolt.y) > tapThreshold) 
								{
									// CHECK PAST MAKE SURE HAVE NOT SET STATE FOR 10 FRAMES
									//STOP AMBULANCE CHASERS //start after hist 1
									var test:Boolean = true;
									
									for (var h:uint = 2; h < hist; h++) 
										{	
											if (Math.abs(pt.history[h].jolt.y) > tapThreshold) test = false;
										}
									if (test) 
									{
										// WILL KILL FOR GESTURE EVENT
										gpt = new GesturePointObject();
											gpt.position = pt.position;
											gpt.jolt = pt.history[0].jolt;
											gpt.type = "y tap";
											//gpt.ipn = sipn;
											
										//trace("kinemetric 3d y tap-----scan clean", pt.jolt.y, pt.history[0].jolt.y, pt.history[1].jolt.y, pt.interactionPointID, pt.id);
										cO.gPointArray.push(gpt);
									}
								}
								
								if (Math.abs(pt.history[1].jolt.x) > tapThreshold) 
								{
									// CHECK PAST MAKE SURE HAVE NOT SET STATE FOR 10 FRAMES
									//STOP AMBULANCE CHASERS //start after hist 1
									var test0:Boolean = true;
									
									for (var h0:uint = 2; h0 < hist; h0++) 
										{	
											if (Math.abs(pt.history[h0].jolt.x) > tapThreshold) test = false;
										}
									if (test0) {
										
										gpt0 = new GesturePointObject();
											gpt0.position = pt.position;
											gpt0.jolt = pt.history[0].jolt;
											gpt0.type = "x tap";

										//trace("kinemetric 3d x tap-----scan clean", pt.history[0].jolt.x, pt.interactionPointID, pt.id)
										cO.gPointArray.push(gpt0);
									}
									//trace("x tap test")
								}
								
								if (Math.abs(pt.history[1].jolt.z) > tapThreshold) 
								{
									var test1:Boolean = true;
									
									for (var h1:uint = 2; h1 < hist; h1++) 
										{	
											if (Math.abs(pt.history[h1].jolt.z) > tapThreshold) test = false;
										}
									if (test0) {
											gpt1 = new GesturePointObject();
												gpt1.position = pt.position;
												gpt1.jolt = pt.history[0].jolt;
												gpt1.type = "z tap";
										
										//trace("kinemetric 3d z tap-----scan clean", pt.history[0].jolt.z, pt.interactionPointID, pt.id);
										cO.gPointArray.push(gpt1);
									}
									//trace("z tap test")
								}
								
							}
						}
					}
					
					// TODO: MOVE TO TEMPORAL METRIC
					// MOVE GESTURE POINT LIST TO TIMELINE GESTURE POINT LAYER (SIMPLIFIY CLUSTER HISTORIES)
					//////////////////////////////////////////////////////////////
					// check if gppoint is cleared for sufficient time
					var tap_period:int = 30// 120;
					var ytap_clear:Boolean = true;
					var xtap_clear:Boolean = true;
					var ztap_clear:Boolean = true;
					//trace("3d motion hold gesture events qualifier",gpn,ts.cO.history.length)
					
					
					if (ts.cO.history.length >= tap_period)
					{
						for (var h3:uint = 0; h3 < tap_period; h3++) 
						{
							//trace("hist",h)
							if (this.cO.history[h3])
							{
							var gpn:uint = this.cO.history[h3].gPointArray.length
							
							//trace("3d motion gesture events visualizer", gpn)
						
								//gesture points
								for (var i:int = 0; i < gpn; i++) 
								{	
									if (cO.history[h3].gPointArray[i].type == "y tap") ytap_clear = false;
									if (cO.history[h3].gPointArray[i].type == "x tap") xtap_clear = false;
									if (cO.history[h3].gPointArray[i].type == "z tap") ztap_clear = false;
								}
							}
						}
					}
					
					//////////////////////////////////////////////////////////////////////////////////
					// SIMPLE TAP DISPLATCH CONTROL // USES SIMPLE PAUSE TIME
					//////////////////////////////////////////////////////////////////////////////////
					if ((ytap_clear)&&(gpt.type == "y tap"))
					{
						//trace("------------ytap--CLEAR");
						myTapID++;
						var myTap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.MOTION_YTAP, {x:gpt.position.x , y:gpt.position.y, z:gpt.position.z, n:sipn, gestureID:myTapID});
						ts.dispatchEvent(myTap_event);
						ytap_clear = false;
						ts.tiO.frame.gestureEventArray.push(myTap_event);
					}
					if ((xtap_clear)&&(gpt0.type == "x tap"))
					{
						//trace("------------xtap--CLEAR");
						mxTapID++;
						var mxTap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.MOTION_XTAP, {x:gpt0.position.x , y:gpt0.position.y, z:gpt0.position.z, n:sipn, gestureID:mxTapID});
						ts.dispatchEvent(mxTap_event);
						xtap_clear = false;
						ts.tiO.frame.gestureEventArray.push(mxTap_event);
					}
					if ((ztap_clear)&&(gpt1.type == "z tap"))
					{
						//trace("----------ztap----CLEAR");
						mzTapID++;
						var mzTap_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.MOTION_ZTAP, {x:gpt1.position.x , y:gpt1.position.y, z:gpt1.position.z, n:sipn, gestureID:mzTapID});
						ts.dispatchEvent(mzTap_event);
						ztap_clear = false;
						ts.tiO.frame.gestureEventArray.push(mzTap_event);
					}
					/////////////////////////////////////////////////////////////////////////////////////
		}
		
		//HOLD POINTS
		public function find3DIPHoldPoints(index:int):void
		{
			//trace("-----------------------hold kinemetric");
			// GET SUBCLUSTER OBJECT
			var sub_cO:ipClusterObject = cO.subClusterArray[index];
			
			//GET TRANSFORMED IP ARRAY
			var ptArray:Vector.<InteractionPointObject> = cO.subClusterArray[index].iPointArray;
			
			// GET CONSTS
			var sipn:uint = sub_cO.ipn;
			
			//HOLD 
				// SCAN HIST 20
				// LOW VELOCITY
				// LOWER ACCEL
			
			var hist:int = 20;
			var holdThreshold:Number = 3; 
			var gpt3:GesturePointObject = new GesturePointObject();
			
			//trace("--");

			for (i = 0; i < sipn; i++) 
					{	
					var pt:InteractionPointObject = ptArray[i];

						if ((pt)&&(pt.history.length > hist))
							{
							if ((pt.history[hist].velocity.length < holdThreshold) && (pt.history[hist].acceleration.length < (holdThreshold*0.1-0.1))) 
								{
									gpt3 = new GesturePointObject();
										gpt3.position = pt.history[hist].position;// PREVENTS HOLD DRIFT
										gpt3.type = "hold";
										
									cO.gPointArray.push(gpt3);
									
									//trace("kinemetric 3d hold...", pt.interactionPointID, pt.id);
								}
								//trace("v: ",v,"a: ",a)
							}
					}
					
					
			//TODO: MOVE TO TEMPROAL METRIC 
			// MOVE GESTURE POINT LIST OBJECY INTO TIMELINE OBJECT LAYER (SIMPLIFY CLUSTER HISTORIES)
			//IMPLEMENT SCANNING OF GESTURELIST FOR RECENT HOLD EVENTS FROM SAME AREA
			// LIMIT EVENTS CREATE MANDITORY PAUSE BETWEEN HOLD EVENT CHIPRS
			// ADD OPTION TO REQUIRE MOVEMENT THEN REHOLD TO ALLOW NEXT CHRIP
			
			
			
			var hold_period:int = 45//120//45// 120;
			var hold_clear:Boolean = true;
			//trace("3d motion hold gesture events qualifier",gpn,ts.cO.history.length)
			
			
			if (ts.cO.history.length >= hold_period)
			{
				for (var h:int = 0; h < hold_period; h++) 
				{
					//trace("hist",h)
					if (this.cO.history[h])
					{
					var gpn:uint = this.cO.history[h].gPointArray.length
					
					//trace("3d motion gesture events visualizer", gpn)
				
						//gesture points
						for (var i:int = 0; i < gpn; i++) 
						{	
							// SIDE TAP // YELLOW
							if (cO.history[h].gPointArray[i].type == "hold") hold_clear = false;
							//trace("not clear",cO.history[h].gPointArray[i].type);
						}
					}
					//else hold_clear = false;
				}
			}
			//else hold_clear = false;
			
			// NO HIT TEST HERE AS HANDLED AT LOWER LEVEL
			// IP MUST MATCH VIA HITTEST BEFORE HERE
			if (hold_clear)
			{
				//trace(gpt)
				if (gpt3.type == "hold")
					{
						//trace("--------------CLEAR",gpt3.type);
						mHoldID++;
						
						var mHold_event:GWGestureEvent = new GWGestureEvent(GWGestureEvent.MOTION_HOLD, {x:gpt3.position.x , y:gpt3.position.y, z:gpt3.position.z, n:sipn, gestureID:mHoldID});
						ts.dispatchEvent(mHold_event);
						
						hold_clear = false;
						ts.tiO.frame.gestureEventArray.push(mHold_event);
					}
			}	
			
			
		}
		
		
		// 3D MANIPULATE GENERIC 
		public function find3DIPTransformation(index:int):void////type:String
		{			
			//trace("motion transform kinemetric", cO.iPointArray.length, ipn,cO.ipn);
			var hist:int = 1; //CREATES DELAY 
			var hk:Number = 1 / hist;
		
			// GET SUBCLUSTER OBJECT
			var sub_cO:ipClusterObject = cO.subClusterArray[index];
			
			//GET TRANSFORMED IP ARRAY
			var ptArray:Vector.<InteractionPointObject> = cO.subClusterArray[index].iPointArray;
			
			// GET CONSTS
			var sipn:uint = sub_cO.ipn;
			var sipnk:Number = sub_cO.ipnk;
			var dipn:int = sub_cO.dipn;
			
			//trace("ip dim",sipn);
			
			// reset deltas
			sub_cO.dx = 0;
			sub_cO.dy = 0;
			sub_cO.dz = 0;	
				
			sub_cO.dtheta = 0;
			sub_cO.dthetaX = 0;
			sub_cO.dthetaY = 0;
			sub_cO.dthetaZ = 0;
									
			sub_cO.ds = 0;
			sub_cO.dsx = 0;
			sub_cO.dsy = 0;
			sub_cO.dsz = 0;
			
			//if(cO.history.length>8)trace("waht",sipn,cO.dipn,cO.history[hist].subClusterArray[index])
			
			var delta_ipn:int = 0;
			
			if ((cO.history.length > 3)&&(sub_cO.ipn!=0)) {//hist
				
				for (i = 0; i < 3; i++) 
				{	
					delta_ipn += Math.abs(cO.history[i].subClusterArray[index].dipn);
					//trace("---", sub_cO.dipn, cO.history[1].subClusterArray[index].dipn, cO.history[2].subClusterArray[index].dipn,cO.history[3].subClusterArray[index].dipn, cO.history[4].subClusterArray[index].dipn, "tot",delta_ipn)
				}
			} 
			else delta_ipn = 1;
			

			// dipn ==0 when no changes in inpn between frames
			if ((sipn!= 0)&&(cO.history[hist].subClusterArray[index])&&(dipn==0))	{		
				
					//trace("t",ptArray[0].position.x,ptArray[0].history.length, cO.iPointArray2D[0].history.length,cO.iPointArray[0].history.length );
					var c_0:ipClusterObject = cO.history[0].subClusterArray[index];//finger_cO
					var c_1:ipClusterObject = cO.history[hist].subClusterArray[index];//finger_cO
						
					//trace("hist x---------------------------------------------",cO.subClusterArray[index].x,cO.history[0].subClusterArray[index].x, cO.history[6].subClusterArray[index].x)
					
							//trace("hist x",cO.finger_cO.x,cO.history[0].finger_cO.x, cO.history[6].finger_cO.x)
							//trace("hist rot",cO.finger_cO.rotation,cO.history[0].finger_cO.rotation, cO.history[2].finger_cO.rotation)
								
							//////////////////////////////////////////////////////////
							//CHANGE IN CLUSTER POSITION
							if ((c_1.x!= 0) && (c_0.x != 0)) 	sub_cO.dx = (c_0.x - c_1.x)*hk;
							if ((c_1.y != 0) && (c_0.y != 0)) 	sub_cO.dy = (c_0.y - c_1.y)*hk;
							if ((c_1.z != 0) && (c_0.z != 0)) 	sub_cO.dz = (c_0.z - c_1.z)*hk;
							//trace(cO.dx,cO.dy,cO.dz);
								
						
						if (sipn == 1)
							{
								// ROTATE //////////////////////////////////////////////////////////////////
								if (ptArray[0].type == "palm")
								{
									if ((c_1.rotation != 0) && (c_0.rotation != 0)) 	sub_cO.dtheta = (c_0.rotation- c_1.rotation) * hk;
									if ((c_1.rotationX != 0) && (c_0.rotationX != 0))	sub_cO.dthetaX = (c_0.rotationX- c_1.rotationX) * hk;
									if ((c_1.rotationY != 0) && (c_0.rotationY != 0))	sub_cO.dthetaY = (c_0.rotationY- c_1.rotationY) * hk;
									if ((c_1.rotationZ != 0) && (c_0.rotationZ != 0))	sub_cO.dthetaZ = (c_0.rotationZ - c_1.rotationZ) * hk;
								}
								else {
									sub_cO.dtheta = 0;
									sub_cO.dthetaX = 0;
									sub_cO.dthetaY = 0;
									sub_cO.dthetaZ = 0;
								}
								//trace(cO.dthetaX,pt.normal.x,pt.history[hist].normal.x);
							}
							
							else if (sipn > 1)
							{
								//////////////////////////////////////////////////////////
								// CHANGE IN SEPARATION
								if ((c_1.radius != 0) && (c_0.radius != 0)) 			sub_cO.ds = (c_0.radius - c_1.radius) * sck*hk;
								if ((c_1.separationX != 0) && (c_0.separationX != 0)) 	sub_cO.dsx = (c_0.separationX - c_1.separationX) * sck*hk;
								if ((c_1.separationY != 0) && (c_0.separationY != 0)) 	sub_cO.dsy = (c_0.separationY - c_1.separationY) * sck*hk;
								if ((c_1.separationZ != 0) && (c_0.separationZ != 0)) 	sub_cO.dsz = (c_0.separationZ - c_1.separationZ) * sck*hk;
								//trace("radius",c_0.radius, c_1.radius);
								
								if(delta_ipn==0) // ROTATION IS MOST SENSITIVE TO DELTA_IPN 
								{
									//////////////////////////////////////////////////////////
									// CHANGE IN ROTATION
									//if ((c_1.rotation != 0) && (c_0.rotation != 0))		sub_cO.dtheta = (c_0.rotation- c_1.rotation) * hk;
									//if ((c_1.rotationX != 0) && (c_0.rotationX != 0)) 	sub_cO.dthetaX = (c_0.rotationX- c_1.rotationX) * hk;
									//if ((c_1.rotationY != 0) && (c_0.rotationY != 0))	sub_cO.dthetaY = (c_0.rotationY- c_1.rotationY) * hk;
									//if ((c_1.rotationZ != 0) && (c_0.rotationZ != 0))	sub_cO.dthetaZ = (c_0.rotationZ - c_1.rotationZ) * hk;
									//trace("roation",c_0.rotation, c_1.rotation, c_0.dtheta);
									
									
									var c_0n:int = c_0.rotationList.length;
									var c_1n:int = c_1.rotationList.length;
									
									if (c_1n == c_0n)
									{
										for (var k:uint = 0; k <c_0n; k++) 
										{	
											if (c_0.rotationList[k] && c_1.rotationList[k]) 
											{
												if ((c_1.rotationList[k].x != 0) && (c_0.rotationList[k].x != 0)) sub_cO.dthetaX += (c_0.rotationList[k].x - c_1.rotationList[k].x) * hk * sipnk;
												if ((c_1.rotationList[k].y != 0) && (c_0.rotationList[k].y != 0)) sub_cO.dthetaY += (c_0.rotationList[k].y - c_1.rotationList[k].y) * hk* sipnk;
												if ((c_1.rotationList[k].z != 0) && (c_0.rotationList[k].z != 0)) sub_cO.dthetaZ += (c_0.rotationList[k].z - c_1.rotationList[k].z) * hk * sipnk;
												if ((c_1.rotationList[k].z != 0) && (c_0.rotationList[k].z != 0)) sub_cO.dtheta +=  (c_0.rotationList[k].z - c_1.rotationList[k].z) * hk * sipnk;
												
												//trace("rot",k,sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,sub_cO.dtheta)
											}
										}
									}
									//trace("rot",sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,sub_cO.dtheta)
									
								}
							}
							
							
									//NEED LIMITS FOR CLUSTER N CHANGE
									
									//LIMIT TRANLATE
									var trans_max_delta:Number = 100;
									
									//trace("pos--------------------------------------------------",sub_cO.dx, sub_cO.dy, sub_cO.dz,dipn);
									
									if (Math.abs(sub_cO.dx) > trans_max_delta) 
									{
										if (sub_cO.dx < 0) sub_cO.dx = -trans_max_delta;
										if (sub_cO.dx > 0) sub_cO.dx = trans_max_delta;
									}
									if (Math.abs(sub_cO.dy) > trans_max_delta) 
									{
										if (sub_cO.dy < 0) sub_cO.dy = -trans_max_delta;
										if (sub_cO.dy > 0) sub_cO.dy = trans_max_delta;
									}
									if (Math.abs(sub_cO.dz) > trans_max_delta) 
									{
										if (sub_cO.dz < 0) sub_cO.dz = -trans_max_delta;
										if (sub_cO.dz > 0) sub_cO.dz = trans_max_delta;
									}
									
									
									//LMIT SCALE
									var sc_max_delta:Number = 0.02 // spikes upto 0.148, 0.08
									
									//trace("scale",sub_cO.ds,sub_cO.dsx,sub_cO.dsy,sub_cO.dsz)
									
									if (Math.abs(sub_cO.ds) > sc_max_delta)
									{
										if (sub_cO.ds < 0) sub_cO.ds = -sc_max_delta;
										if (sub_cO.ds > 0) sub_cO.ds = sc_max_delta;
									}
									if (Math.abs(sub_cO.dsx) > sc_max_delta)
									{
										if (sub_cO.dsx < 0) sub_cO.dsx= -sc_max_delta;
										if (sub_cO.dsx > 0) sub_cO.dsx = sc_max_delta;
									}
									if (Math.abs(sub_cO.dsy) > sc_max_delta)
									{
										if (sub_cO.dsy < 0) sub_cO.dsy = -sc_max_delta;
										if (sub_cO.dsy > 0) sub_cO.dsy = sc_max_delta;
									}
									if (Math.abs(sub_cO.dsz) > sc_max_delta)
									{
										if (sub_cO.dsz < 0) sub_cO.dsz = -sc_max_delta;
										if (sub_cO.dsz > 0) sub_cO.dsz = sc_max_delta;
									}
									
									//trace(sub_cO.dsx,sub_cO.dsy)
									
									// LIMIT ROTATE
									var rot_max_delta:Number = 20//20//45
									
									//trace("rot",sub_cO.dtheta,sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,dipn,delta_ipn)
									
									if (Math.abs(sub_cO.dtheta) > rot_max_delta)
									{
										if (sub_cO.dtheta < 0) sub_cO.dtheta = -rot_max_delta;
										if (sub_cO.dtheta > 0) sub_cO.dtheta = rot_max_delta;
										if ( isNaN(sub_cO.dtheta)) sub_cO.dtheta = 0;
									}
									if (Math.abs(sub_cO.dthetaX) > rot_max_delta)
									{
										if (sub_cO.dthetaX < 0) sub_cO.dthetaX = -rot_max_delta;
										if (sub_cO.dthetaX > 0) sub_cO.dthetaX = rot_max_delta;
										if ( isNaN(sub_cO.dthetaX)) sub_cO.dthetaX = 0;
									}
									if (Math.abs(sub_cO.dthetaY) > rot_max_delta)
									{
										if (sub_cO.dthetaY < 0) sub_cO.dthetaY = -rot_max_delta;
										if (sub_cO.dthetaY > 0) sub_cO.dthetaY = rot_max_delta;
										if ( isNaN(sub_cO.dthetaY)) sub_cO.dthetaY = 0;
									}
									if (Math.abs(sub_cO.dthetaZ) > rot_max_delta)
									{
										if (sub_cO.dthetaZ < 0) sub_cO.dthetaZ = -rot_max_delta;
										if (sub_cO.dthetaZ > 0) sub_cO.dthetaZ = rot_max_delta;
										if ( isNaN(sub_cO.dthetaZ)) sub_cO.dthetaZ = 0;
									}
									//trace("get diff");	
									//trace("lim rot",sub_cO.dtheta,sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,dipn,delta_ipn)
									
			}
			
		}
		
		// 3D MANIPULATE GENERIC 
		public function find3DIPRotation(index:int):void////type:String
		{
			//trace("motion rotation kinemetric", cO.iPointArray.length, ipn,cO.ipn);
			var hist:int = 1; //CREATES DELAY 
			var hk:Number = 1 / hist;
		
			// GET SUBCLUSTER OBJECT
			var sub_cO:ipClusterObject = cO.subClusterArray[index];
			
			//GET TRANSFORMED IP ARRAY
			var ptArray:Vector.<InteractionPointObject> = cO.subClusterArray[index].iPointArray;
			
			// GET CONSTS
			var sipn:uint = sub_cO.ipn;
			var sipnk:Number = sub_cO.ipnk;
			var dipn:int = sub_cO.dipn;
			
			//trace("ip dim",sipn);
			
			// reset deltas
			sub_cO.dtheta = 0;
			sub_cO.dthetaX = 0;
			sub_cO.dthetaY = 0;
			sub_cO.dthetaZ = 0;
			
			//if(cO.history.length>8)trace("waht",sipn,cO.dipn,cO.history[hist].subClusterArray[index])
			
			var delta_ipn:int = 0;
			
			if ((cO.history.length > 3)&&(sub_cO.ipn!=0)) {//hist
				
				for (i = 0; i < 3; i++) 
				{	
					delta_ipn += Math.abs(cO.history[i].subClusterArray[index].dipn);
					//trace("---", sub_cO.dipn, cO.history[1].subClusterArray[index].dipn, cO.history[2].subClusterArray[index].dipn,cO.history[3].subClusterArray[index].dipn, cO.history[4].subClusterArray[index].dipn, "tot",delta_ipn)
				}
			} 
			else delta_ipn = 1;
			
			
			
			// dipn ==0 when no changes in inpn between frames
			if ((sipn!= 0)&&(cO.history[hist].subClusterArray[index])&&(dipn==0))//
				{		
					
					//trace("t",ptArray[0].position.x,ptArray[0].history.length, cO.iPointArray2D[0].history.length,cO.iPointArray[0].history.length );
					var c_0:ipClusterObject = cO.history[0].subClusterArray[index];//finger_cO
					var c_1:ipClusterObject = cO.history[hist].subClusterArray[index];//finger_cO	
						
						if (sipn == 1)
							{
								// ROTATE //////////////////////////////////////////////////////////////////
								if (ptArray[0].type == "palm")
								{
									if ((c_1.rotation != 0) && (c_0.rotation != 0)) 	sub_cO.dtheta = (c_0.rotation- c_1.rotation) * hk;
									if ((c_1.rotationX != 0) && (c_0.rotationX != 0))	sub_cO.dthetaX = (c_0.rotationX- c_1.rotationX) * hk;
									if ((c_1.rotationY != 0) && (c_0.rotationY != 0))	sub_cO.dthetaY = (c_0.rotationY- c_1.rotationY) * hk;
									if ((c_1.rotationZ != 0) && (c_0.rotationZ != 0))	sub_cO.dthetaZ = (c_0.rotationZ - c_1.rotationZ) * hk;
								}
								else {
									sub_cO.dtheta = 0;
									sub_cO.dthetaX = 0;
									sub_cO.dthetaY = 0;
									sub_cO.dthetaZ = 0;
								}
								//trace(cO.dthetaX,pt.normal.x,pt.history[hist].normal.x);
							}
							
						else if (sipn > 1)
							{
								if(delta_ipn==0) // ROTATION IS MOST SENSITIVE TO DELTA_IPN 
								{
									var c_0n:int = c_0.rotationList.length;
									var c_1n:int = c_1.rotationList.length;
									
									if (c_1n == c_0n)
									{
										for (var k:uint = 0; k <c_0n; k++) 
										{	
											if (c_0.rotationList[k] && c_1.rotationList[k]) 
											{
												if ((c_1.rotationList[k].x != 0) && (c_0.rotationList[k].x != 0)) sub_cO.dthetaX += (c_0.rotationList[k].x - c_1.rotationList[k].x) * hk * sipnk;
												if ((c_1.rotationList[k].y != 0) && (c_0.rotationList[k].y != 0)) sub_cO.dthetaY += (c_0.rotationList[k].y - c_1.rotationList[k].y) * hk* sipnk;
												if ((c_1.rotationList[k].z != 0) && (c_0.rotationList[k].z != 0)) sub_cO.dthetaZ += (c_0.rotationList[k].z - c_1.rotationList[k].z) * hk * sipnk;
												if ((c_1.rotationList[k].z != 0) && (c_0.rotationList[k].z != 0)) sub_cO.dtheta +=  (c_0.rotationList[k].z - c_1.rotationList[k].z) * hk * sipnk;
												
												//trace("rot",k,sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,sub_cO.dtheta)
											}
										}
									}
									//trace("rot",sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,sub_cO.dtheta)
									
								}
							}

								// LIMIT ROTATE
								var rot_max_delta:Number = 20//20//45
									
									//trace("rot",sub_cO.dtheta,sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,dipn,delta_ipn)
									
									if (Math.abs(sub_cO.dtheta) > rot_max_delta)
									{
										if (sub_cO.dtheta < 0) sub_cO.dtheta = -rot_max_delta;
										if (sub_cO.dtheta > 0) sub_cO.dtheta = rot_max_delta;
										if ( isNaN(sub_cO.dtheta)) sub_cO.dtheta = 0;
									}
									if (Math.abs(sub_cO.dthetaX) > rot_max_delta)
									{
										if (sub_cO.dthetaX < 0) sub_cO.dthetaX = -rot_max_delta;
										if (sub_cO.dthetaX > 0) sub_cO.dthetaX = rot_max_delta;
										if ( isNaN(sub_cO.dthetaX)) sub_cO.dthetaX = 0;
									}
									if (Math.abs(sub_cO.dthetaY) > rot_max_delta)
									{
										if (sub_cO.dthetaY < 0) sub_cO.dthetaY = -rot_max_delta;
										if (sub_cO.dthetaY > 0) sub_cO.dthetaY = rot_max_delta;
										if ( isNaN(sub_cO.dthetaY)) sub_cO.dthetaY = 0;
									}
									if (Math.abs(sub_cO.dthetaZ) > rot_max_delta)
									{
										if (sub_cO.dthetaZ < 0) sub_cO.dthetaZ = -rot_max_delta;
										if (sub_cO.dthetaZ > 0) sub_cO.dthetaZ = rot_max_delta;
										if ( isNaN(sub_cO.dthetaZ)) sub_cO.dthetaZ = 0;
									}
									//trace("get diff");	
									//trace("lim rot",sub_cO.dtheta,sub_cO.dthetaX,sub_cO.dthetaY,sub_cO.dthetaZ,dipn,delta_ipn)
			}
		}
		
		// 3D MANIPULATE GENERIC 
		public function find3DIPSeparation(index:int):void
		{
			//trace("motion transform kinemetric", cO.iPointArray.length, ipn,cO.ipn);
			var hist:int = 1; //CREATES DELAY 
			var hk:Number = 1 / hist;
		
			// GET SUBCLUSTER OBJECT
			var sub_cO:ipClusterObject = cO.subClusterArray[index];
			
			//GET TRANSFORMED IP ARRAY
			var ptArray:Vector.<InteractionPointObject> = cO.subClusterArray[index].iPointArray;
			
			// GET CONSTS
			var sipn:uint = sub_cO.ipn;
			var sipnk:Number = sub_cO.ipnk;
			var dipn:int = sub_cO.dipn;
			
			// reset deltas						
			sub_cO.ds = 0;
			sub_cO.dsx = 0;
			sub_cO.dsy = 0;
			sub_cO.dsz = 0;
			

			// dipn ==0 when no changes in inpn between frames
			if ((sipn!= 0)&&(cO.history[hist].subClusterArray[index])&&(dipn==0))//
				{		
					
					//trace("t",ptArray[0].position.x,ptArray[0].history.length, cO.iPointArray2D[0].history.length,cO.iPointArray[0].history.length );
					var c_0:ipClusterObject = cO.history[0].subClusterArray[index];//finger_cO
					var c_1:ipClusterObject = cO.history[hist].subClusterArray[index];//finger_cO
							
							if (sipn > 1)
							{
								//////////////////////////////////////////////////////////
								// CHANGE IN SEPARATION
								if ((c_1.radius != 0) && (c_0.radius != 0)) 			sub_cO.ds = (c_0.radius - c_1.radius) * sck*hk;
								if ((c_1.separationX != 0) && (c_0.separationX != 0)) 	sub_cO.dsx = (c_0.separationX - c_1.separationX) * sck*hk;
								if ((c_1.separationY != 0) && (c_0.separationY != 0)) 	sub_cO.dsy = (c_0.separationY - c_1.separationY) * sck*hk;
								if ((c_1.separationZ != 0) && (c_0.separationZ != 0)) 	sub_cO.dsz = (c_0.separationZ - c_1.separationZ) * sck*hk;
								//trace("radius",c_0.radius, c_1.radius);
							}

									//LMIT SCALE
									var sc_max_delta:Number = 0.02 // spikes upto 0.148, 0.08
									
									//trace("scale",sub_cO.ds,sub_cO.dsx,sub_cO.dsy,sub_cO.dsz)
									
									if (Math.abs(sub_cO.ds) > sc_max_delta)
									{
										if (sub_cO.ds < 0) sub_cO.ds = -sc_max_delta;
										if (sub_cO.ds > 0) sub_cO.ds = sc_max_delta;
									}
									if (Math.abs(sub_cO.dsx) > sc_max_delta)
									{
										if (sub_cO.dsx < 0) sub_cO.dsx= -sc_max_delta;
										if (sub_cO.dsx > 0) sub_cO.dsx = sc_max_delta;
									}
									if (Math.abs(sub_cO.dsy) > sc_max_delta)
									{
										if (sub_cO.dsy < 0) sub_cO.dsy = -sc_max_delta;
										if (sub_cO.dsy > 0) sub_cO.dsy = sc_max_delta;
									}
									if (Math.abs(sub_cO.dsz) > sc_max_delta)
									{
										if (sub_cO.dsz < 0) sub_cO.dsz = -sc_max_delta;
										if (sub_cO.dsz > 0) sub_cO.dsz = sc_max_delta;
									}
									
									//trace(sub_cO.dsx,sub_cO.dsy)
			}
		}
		
		
		public function find3DIPTranslation(index:int):void//type:String
		{
			//trace("-------------------------motion translate kinemetric", cO.iPointArray.length, ipn,cO.ipn);
			var hist:int = 1;
			var hk:Number = 1 / hist;
			
			// Get subcluster
			var sub_cO:ipClusterObject = cO.subClusterArray[index];

			//GET TRANSFORMED IP ARRAY
			var ptArray:Vector.<InteractionPointObject> = sub_cO.iPointArray;
			
			var sipn:uint = sub_cO.ipn;
			var sdipn:uint = sub_cO.dipn;
			
			// reset deltas
			sub_cO.dx = 0;
			sub_cO.dy = 0;
			sub_cO.dz = 0;
				
			// dipn ==0 when no changes in inpn between frames
			if ((sipn!= 0)&&(cO.history[hist].subClusterArray[index])&&(cO.dipn==0))//
				{
					//trace("t",ptArray[0].position.x,ptArray[0].history.length, cO.iPointArray2D[0].history.length,cO.iPointArray[0].history.length );
					var c_0:ipClusterObject = cO.history[0].subClusterArray[index];
					var c_1:ipClusterObject = cO.history[hist].subClusterArray[index];
						
							//trace("hist x",cO.finger_cO.x,cO.history[0].finger_cO.x, cO.history[6].finger_cO.x)
							//trace("hist rot",cO.finger_cO.rotation,cO.history[0].finger_cO.rotation, cO.history[2].finger_cO.rotation)
								
							//////////////////////////////////////////////////////////
							//CHANGE IN CLUSTER POSITION
							if ((c_1.x!= 0) && (c_0.x != 0)) 	sub_cO.dx = (c_0.x - c_1.x)*hk;
							if ((c_1.y != 0) && (c_0.y != 0)) 	sub_cO.dy = (c_0.y - c_1.y)*hk;
							if ((c_1.z != 0) && (c_0.z != 0)) 	sub_cO.dz = (c_0.z - c_1.z)*hk;
							//trace(cO.dx,cO.dy,cO.dz);
								
							//NEED LIMITS FOR CLUSTER N CHANGE
							//LIMIT TRANLATE
							var trans_max_delta:Number = 30;
									
							if (Math.abs(sub_cO.dx) > trans_max_delta) 
							{
								if (sub_cO.dx < 0) sub_cO.dx = -trans_max_delta;
								if (sub_cO.dx > 0) sub_cO.dx = trans_max_delta;
							}
							if (Math.abs(sub_cO.dy) > trans_max_delta) 
							{
								if (sub_cO.dy < 0) sub_cO.dy = -trans_max_delta;
								if (sub_cO.dy > 0) sub_cO.dy = trans_max_delta;
							}
							if (Math.abs(sub_cO.dz) > trans_max_delta) 
							{
								if (sub_cO.dz < 0) sub_cO.dz = -trans_max_delta;
								if (sub_cO.dz > 0) sub_cO.dz = trans_max_delta;
							}
							//trace("get diff");	
			}
			//trace("motion translate kinemetric",sub_cO.dx,sub_cO.dy,sub_cO.dz);
		}
		
		public function find3DIPAcceleration(index:int):void//type:String
		{
			//trace("motion transform kinemetric", cO.iPointArray.length, ipn,cO.ipn);
			var hist:int = 8;
			var hk:Number = 1 / hist;
			
			// Get subcluster
			var sub_cO:ipClusterObject = cO.subClusterArray[index];

			//GET TRANSFORMED IP ARRAY
			var ptArray:Vector.<InteractionPointObject> = sub_cO.iPointArray;
			
			var sipn:uint = sub_cO.ipn;
			var sdipn:uint = sub_cO.dipn;
			var sipnk:* = sub_cO.ipnk;
			
			// reset deltas
			sub_cO.dx = 0;
			sub_cO.dy = 0;
			sub_cO.dz = 0;
				
			// dipn ==0 when no changes in inpn between frames
			if ((sipn!= 0)&&(cO.history[hist].subClusterArray[index])&&(sdipn==0))//
				{
					//trace("t",ptArray[0].position.x,ptArray[0].history.length, cO.iPointArray2D[0].history.length,cO.iPointArray[0].history.length );
					//var c_0:ipClusterObject = cO.history[0].sub_cO;
					//var c_1:ipClusterObject = cO.history[hist].sub_cO;
						
							//trace("hist x",cO.finger_cO.x,cO.history[0].finger_cO.x, cO.history[6].finger_cO.x)
							//trace("hist rot",cO.finger_cO.rotation,cO.history[0].finger_cO.rotation, cO.history[2].finger_cO.rotation)
							
							
							//////////////////////////////////////////////////////////
							//CLUSTER MOTION
							for (i = 0; i < sipn; i++) 
							{	
								//AGREGATE VELOCITY
								sub_cO.velocity.x += sub_cO.iPointArray[i].velocity.x;
								sub_cO.velocity.y += sub_cO.iPointArray[i].velocity.y;
								sub_cO.velocity.z += sub_cO.iPointArray[i].velocity.z;
									
								//AGREGATE ACCELERATION
								sub_cO.acceleration.x += sub_cO.iPointArray[i].acceleration.x;
								sub_cO.acceleration.y += sub_cO.iPointArray[i].acceleration.y;
								sub_cO.acceleration.z += sub_cO.iPointArray[i].acceleration.z;
								
								//AGREGATE JOLT
								sub_cO.jolt.x += sub_cO.iPointArray[i].jolt.x;
								sub_cO.jolt.y += sub_cO.iPointArray[i].jolt.y;
								sub_cO.jolt.z += sub_cO.iPointArray[i].jolt.z;
							}
							
							
							//AGREGATE VELOCITY
							sub_cO.velocity.x *= sipnk;
							sub_cO.velocity.y *= sipnk;
							sub_cO.velocity.z *= sipnk;
									
							//AGREGATE ACCELERATION
							sub_cO.acceleration.x *= sipnk;
							sub_cO.acceleration.y *= sipnk;
							sub_cO.acceleration.z *= sipnk;
								
							//AGREGATE JOLT
							sub_cO.jolt.x *= sipnk;
							sub_cO.jolt.y *= sipnk;
							sub_cO.jolt.z *= sipnk;
							
							//trace(sub_cO.velocity,sub_cO.acceleration,sub_cO.jolt);
			}
		}
		
		
		public function Weave3DIPClusterData():void
		{
			var asc:int = 0;
			var asck:Number = 0;
			
			//BLEND INTO SINGLE CLUSTER
			/////////////////////////////////////////////////////////////////////////////////////////
			// loop for all sub clusters/////////////////////////////////////////////////////////////
			
			
			
			for (i = 0; i < cO.subClusterArray.length; i++) 
				{		
					// GET CLUSTER ANALYSIS FROM EACH SUBCLUSTER
					var sub_cO:ipClusterObject = cO.subClusterArray[i];

						// each dimension / property must be merged independently
						if (sub_cO.ipn>0)
						{
							asc++;
							//trace("weave ipcos",sub_cO.ipn, sub_cO.type);
							
							// recalculate cluster center
							// average over all ip subcluster subclusters 
							// MAY NEED TO GIVE EQUAL WEIGHT TO ALL INTERACTION POINTS
							// CURRENTLY CENTER OF 4 FINGER SUBCLUSTER IS SAME WEIGHT AS 1 PINCH POINT WHICH PUSHED AVERAGE CENTER CLOSER TO PINCH POINT
							
							mcO.x += sub_cO.x  
							mcO.y += sub_cO.y
							mcO.z += sub_cO.z
							
							
							// recalculate based on ip subcluster totals
							mcO.width = sub_cO.width; // get max
							mcO.height = sub_cO.height;// get max
							mcO.length = sub_cO.length;// get max
							mcO.radius = sub_cO.radius;// get max
										
							// recalculate based on ip subcluster totals
							mcO.separation = sub_cO.separation;// get max
							mcO.separationX = sub_cO.separationX;// get max
							mcO.separationY = sub_cO.separationY;// get max
							mcO.separationZ = sub_cO.separationZ;// get max
									
							// recalculate based on ip subcluster totals
							mcO.rotation = sub_cO.rotation;// get max
							mcO.rotationX = sub_cO.rotationX;// get max
							mcO.rotationY = sub_cO.rotationY;// get max
							mcO.rotationZ = sub_cO.rotationZ;// get max
							
							
							// map non zero deltas // accumulate 
							// perhaps find average 
							mcO.dx += sub_cO.dx;
							mcO.dy += sub_cO.dy;
							mcO.dz += sub_cO.dz;	
								
							mcO.dtheta += sub_cO.dtheta;
							mcO.dthetaX += sub_cO.dthetaX;
							mcO.dthetaY += sub_cO.dthetaY;
							mcO.dthetaZ += sub_cO.dthetaZ;
													
							mcO.ds += sub_cO.ds; // must not be affected by cluster chnage in radius
							mcO.dsx += sub_cO.dsx;
							mcO.dsy += sub_cO.dsy;
							mcO.dsz += sub_cO.dsz;
							///////////////////////////////////////////////////////////////////////////////////////
							///////////////////////////////////////////////////////////////////////////////////////
							
							//trace("sub",sub_cO.dx, sub_cO.dy)
						}
				}
				
				asck = 1 / asc;
				if (asc == 0) asck = 1; //DERR // need 1 or kills multi modal
				
				//trace("weave weight", asck,asc)
				
				// AVERAGE CLUSTER POSITION
				mcO.x *= asck;  
				mcO.y *= asck;
				mcO.z *= asck;
				
				
				//trace("motion",mcO.dx,mcO.dy)
				//trace("motion subclusterto motion prime",mcO.x,mcO.y,mcO.z, mcO.dx,mcO.dy,mcO.dz)
		}
		
		public function WeaveMotionClusterData():void
		{
			//BLEND INTO ROOT CLUSTER
			
			/*
			var motion_weave_list:Object = new Object();
						motion_weave_list["dx"] = 0;
						motion_weave_list["dy"] = 0;
						motion_weave_list["dz"] = 0;
			
			
			//clear weave counts
			for each (key in cO)
			{
				motion_weave_list[key] = 0;
			}
			
			// perform weave counts
			for each (key in motion_weave_list)
			{
				if (mcO[key]!=0) motion_weave_list[key] += 1;
			}
			*/
			
					// each dimension / property must be merged independently
						if (mcO.ipn>0)
						{

							// recalculate cluster center
							// average over all ip subcluster subclusters 
							cO.x = mcO.x;
							cO.y = mcO.y;
							cO.z = mcO.z;
							
							cO.width = mcO.width;
							cO.height = mcO.height; 
							cO.length = mcO.length; 
							cO.radius = mcO.radius; 
							
							// map non zero deltas // accumulate 
							// perhaps find average 
							cO.dx += mcO.dx;
							cO.dy += mcO.dy;
							cO.dz += mcO.dz;	
								
							cO.dtheta += mcO.dtheta;//
							cO.dthetaX += mcO.dthetaX;
							cO.dthetaY += mcO.dthetaY;
							cO.dthetaZ += mcO.dthetaZ;
													
							cO.ds += mcO.ds; //must not be affected by cluster change in radius
							cO.dsx += mcO.dsx;//
							cO.dsy += mcO.dsy;//
							cO.dsz += mcO.dsz;//
							///////////////////////////////////////////////////////////////////////////////////////
							///////////////////////////////////////////////////////////////////////////////////////
							
							//trace("weave motion",cO.x,cO.y,cO.z, cO.width,cO.height)
							
						}
				//trace("motion prime to core cluster", mcO.x,mcO.y,mcO.z,cO.dx,cO.dy)
		}
		
		public function WeaveTouchClusterData():void
		{
						// each dimension / property must be merged independently
						if (tcO.tpn>0)
						{
							// recalculate cluster center
							// average over all ip subcluster subclusters 
							cO.x = tcO.x  
							cO.y = tcO.y
							cO.z = tcO.z
							
							cO.width = tcO.width;
							cO.height = tcO.height;
							cO.radius = tcO.radius;  
							
							cO.thumbID = tcO.thumbID;
							cO.handednes = tcO.handednes;
							cO.orient_dx = tcO.orient_dx; 
							cO.orient_dy = tcO.orient_dy; 
							cO.pivot_dtheta = tcO.pivot_dtheta; 
							
							
							///////////////////////////////////////////////////////////////////
							// map non zero deltas // accumulate 
							// perhaps find average 
							cO.dx += tcO.dx;
							cO.dy += tcO.dy;
							cO.dz += tcO.dz;	
								
							cO.dtheta += tcO.dtheta;
							cO.dthetaX += tcO.dthetaX;
							cO.dthetaY += tcO.dthetaY;
							cO.dthetaZ += tcO.dthetaZ;
													
							cO.ds += tcO.ds; // must not be affected by cluster change in radius
							cO.dsx += tcO.dsx;
							cO.dsy += tcO.dsy;
							cO.dsz += tcO.dsz;
							///////////////////////////////////////////////////////////////////////////////////////
							///////////////////////////////////////////////////////////////////////////////////////
						//trace("weave touch",cO.x,cO.y,cO.z, cO.width,cO.height)
						}
					//trace("touch prime to core cluster", mcO.x,mcO.y,mcO.z,cO.dx,cO.dy)
				
		}
		
			
		////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////
		// helper functions
		////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////
		
		/////////////////////////////////////////////////////////////////////////////////////////
		// FINDS THE ANGLE BETWEEN TWO VECTORS 
		/////////////////////////////////////////////////////////////////////////////////////////
		
		private static function dotProduct(x0:Number, y0:Number,x1:Number, y1:Number):Number
			{	
				if ((x0!=0)&&(y0!=0)&&(x1!=0)&&(y1!=0)) return Math.acos((x0 * x1 + y0 * y1) / (Math.sqrt(x1 * x1 + y1 * y1) * Math.sqrt(x0 * x0 + y0 * y0)));
				else return 0;
				
				
		}	
			
		/////////////////////////////////////////////////////////////////////////////////////////
		// tan function with adjustments for angle wrapping
		/////////////////////////////////////////////////////////////////////////////////////////
		// NOTE NEED TO CLEAN LOGIC TO PREVENT ROTATIONS ABOVE 360 AND PREVENT ANY NEGATIVE ROTATIONS
		
		private static function calcAngle(adjacent:Number, opposite:Number):Number
			{
				if (adjacent == 0) return opposite < 0 ? 270 : 90 ;
				if (opposite == 0) return adjacent < 0 ? 180 : 0 ;
				
				if (opposite > 0) 
				{
					return adjacent > 0 ? 360 + Math.atan(opposite / adjacent) * RAD_DEG : 180 - Math.atan(opposite / -adjacent) * RAD_DEG ;
				}
				else {
					return adjacent > 0 ? 360 - Math.atan( -opposite / adjacent) * RAD_DEG : 180 + Math.atan( opposite / adjacent) * RAD_DEG ;
				}
				
				return 0;
		}
		
		private static function calcAngle2(opposite:Number, adjacent:Number):Number
		{
			if (adjacent > 0) return (180 + Math.atan(opposite / adjacent) * RAD_DEG);
			if ((adjacent >= 0) && (opposite < 0)) return (360 + Math.atan( opposite / adjacent) * RAD_DEG);
			else return (Math.atan( opposite / adjacent) * RAD_DEG);	
		}
		
		private static function calcAngle3(y:Number, x:Number):Number
		{
			var theta_rad:Number  = Math.atan2( y , x)
			return (theta_rad/Math.PI*180) + (theta_rad > 0 ? 0 : 360);	
		}
		
		
		private static function normalize(value : Number, minimum : Number, maximum : Number) : Number {

                        return (value - minimum) / (maximum - minimum);
         }

        private static function limit(value : Number, min : Number, max : Number) : Number {
                        return Math.min(Math.max(min, value), max);
        }
	}
}