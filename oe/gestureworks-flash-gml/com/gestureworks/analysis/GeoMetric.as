////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2013 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GeoMetric.as
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
	import flash.geom.Vector3D;
	import flash.geom.Utils3D;
	import flash.geom.Point;
	
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.gw_public;
	
	import com.gestureworks.objects.HandObject;
	import com.gestureworks.objects.PointObject;
	import com.gestureworks.objects.MotionPointObject;
	import com.gestureworks.objects.InteractionPointObject;
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.managers.InteractionPointTracker;
		
	public class GeoMetric
	{
		//////////////////////////////////////
		// ARITHMETIC CONSTANTS
		//////////////////////////////////////
		private static const RAD_DEG:Number = 180 / Math.PI;
		private static const DEG_RAD:Number = Math.PI / 180 ;
		
		private var touchObjectID:int;
		private var ts:Object;//private var ts:TouchSprite;
		private var cO:ClusterObject;
		private var i:uint = 0;
		private var j:uint = 0;
		
		private var mpn:uint = 0;
		
		public function GeoMetric(_id:int) 
		{
			touchObjectID = _id;
			init();
		}
		
		public function init():void
		{
			ts = GestureGlobals.gw_public::touchObjects[touchObjectID]; // need to find center of object for orientation and pivot
			cO = ts.cO; // get motion data
		
			if (ts.traceDebugMode) trace("init cluster geometric");
		}
		
		
		public function resetGeoCluster():void
		{
			//////////////////////////////////////
			// SUBCLUSTER STRUCTURE
			// CAN BE USED FOR BI-MANUAL GESTURES
			// CAN BE USED FOR CONCURRENT GESTURE PAIRS
			/////////////////////////////////////
		}

		
		public function findMotionClusterConstants():void
		{
			mpn = cO.motionArray.length;
			
			ts.mpn = mpn;
			ts.cO.mpn = mpn;
			ts.cO.mcO.mpn = mpn;
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////
		// 3d config analysis
		///////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////
		
		// clear derived point and cluster motion data
		public function clearHandData():void
		{
			for (i = 0; i < mpn; i++)//mpn
				{	
					if (cO.motionArray[i]){
						if (cO.motionArray[i].type == "finger")
						{	
							// reset thum alloc// move to cluster
							cO.motionArray[i].fingertype = "finger";	 
							
							// reset thumb probs // move to cluster
							cO.motionArray[i].thumb_prob = 0;
							cO.motionArray[i].mean_thumb_prob = 0
							// normalized data
							cO.motionArray[i].normalized_length = 0;
							cO.motionArray[i].normalized_palmAngle = 0;
							cO.motionArray[i].normalized_favdist = 0;
						}
						
						if (cO.motionArray[i].type == "palm")
						{	
							// reset thum alloc// move to cluster
							cO.motionArray[i].fingertype = null;	 
							
							// reset thumb probs // move to cluster
							cO.motionArray[i].thumb_prob = 0;
							cO.motionArray[i].mean_thumb_prob = 0
							// normalized data
							cO.motionArray[i].normalized_length = 0;
							cO.motionArray[i].normalized_palmAngle = 0;
							cO.motionArray[i].normalized_favdist = 0;
						}
					}
				}
				
				// reset hands
				cO.handList.length = 0;
				cO.hn = 0;
				cO.fn = 0;
		}
		
		
		// get noamlized finger length and palm angle
		public function createHand():void 
		{
			//trace("create hand")
			if (mpn !=0) // no points no hand
			{
				for (i = 0; i < mpn; i++)//mpn
					{
					//////////////////////////////////////////////////////
					/// create hand
						if (cO.motionArray[i].type == "palm") 
						{
						var hand:HandObject = new HandObject();	
							hand.position = cO.motionArray[i].position //palmID
							hand.direction = cO.motionArray[i].direction
							hand.normal = cO.motionArray[i].normal
							hand.handID = cO.motionArray[i].handID;
							hand.palm = cO.motionArray[i]; // link palm point
		
						cO.handList.push(hand);
						//trace("p",cO.motionArray[i].handID)
						}
				
					}
					///////////////////////////////////////////////
					// GET HAND NUM TOTAL
					cO.hn = cO.handList.length;
					
					///////////////////////////////////////////////
					// PUSH FINGERS
					var fn:int = 0;
					
					for (j = 0; j < cO.hn; j++)
					{
						
						for (i = 0; i <mpn; i++)//mpn
								{	
									var mp:MotionPointObject = cO.motionArray[i];
									//trace(cO.handList[j].handID ,cO.motionArray[i].handID)
									if ((mp.type == "finger")&&(cO.handList[j].handID == mp.handID))
									{
										// push fingers into finger list
										cO.handList[j].fingerList.push(mp);
									}
									
									if ((mp.type == "tool")&&(cO.handList[j].handID == mp.handID))
									{
										// push tool into interaction point list
										var tpt:InteractionPointObject = new InteractionPointObject();
											tpt.position = mp.position;
											tpt.direction = mp.direction;
											tpt.length = mp.length;
											tpt.handID = mp.handID;
											tpt.type = "tool";
																			
										//add to pinch point list
										InteractionPointTracker.framePoints.push(tpt)
										
										//trace("tool..........................................");
									}
									
								}
						//BUILD FINGER NUM TOTAL
						fn += cO.handList[j].fingerList.length;
					}
					/////////////////////////////////////////////
					//GET FINGER NUM TOTAL
					cO.fn = fn;
			}
		}
		
		public function findFingerAverage():void 
		{

				//////////////////////////////////////////////////////////////////////////////
				// GET FAV 
				for (j = 0; j < cO.hn; j++)
				{
					var fav_pt:Vector3D = new Vector3D();
					var pfav_pt:Vector3D = new Vector3D();
					var hfn:int = cO.handList[j].fingerList.length;
					var hfnk:Number = 0;
					
					if (hfn) hfnk = 1 / hfn;
					
					for (i = 0; i < hfn; i++)
							{	
									var fpt:MotionPointObject = cO.handList[j].fingerList[i];

									// finger average point (fingers + thumb)
									fav_pt.x += fpt.position.x;
									fav_pt.y += fpt.position.y;
									fav_pt.z += fpt.position.z;
	
									if (cO.motionArray[i].fingertype == "finger") // add other finger types
									{
										// finger average point
										pfav_pt.x += fpt.position.x;
										pfav_pt.y += fpt.position.y;
										pfav_pt.z += fpt.position.z;
									}
							}
							fav_pt.x *= hfnk;
							fav_pt.y *= hfnk;
							fav_pt.z *= hfnk;
							
							pfav_pt.x *= hfnk-1;
							pfav_pt.y *= hfnk-1;
							pfav_pt.z *= hfnk - 1;
							
							// TEST
							///////////////////////////////////////////////////////////////////////
							// CALCUALTE DIRECTION OF HAND
							//var direction:Vector3D = fav_pt.subtract(cO.handList[j].palm.position);
							//cO.handList[j].palm.direction = direction;
							//////////////////////////////////////////////////////////////////////
							
							//////////////////////////////////////////////////////////////////////////////////////////////////
							// push fav point to hand object
							cO.handList[j].fingerAveragePosition = fav_pt;
							cO.handList[j].pureFingerAveragePosition = pfav_pt;
								
							///////////////////////////////////////////////////////////////////////////////////////////////////			
							// GET HAND ORIENTATION
							var v:Vector3D = cO.handList[j].fingerAveragePosition.subtract(cO.handList[j].palm.position)
							var orienAngle:Number = v.dotProduct(cO.handList[j].palm.normal);// Vector3D.angleBetween(v0, v1);
							
							if (orienAngle > 0) {
								cO.handList[j].orientation = "down";
							}
							else if (orienAngle < 0) {
								cO.handList[j].orientation = "up";
							}
							//else cO.handList[j].orientation = "udefined";
							//trace(orienAngle,cO.handList[j].orientation);
							
							///////////////////////////////////////////////////////////////////////////////////////////////////
							// GET HANDEDNESS
							// LEFT OR RIGHT
							
							
							
							
				}
				//trace("hand pos",cO.hand.position)
		}

		
		public function findHandRadius():void 
		{

			for (j = 0; j < cO.hn; j++)
				{
					//trace("number finger",fn,fnk,fav_pt.x,fav_pt.y,fav_pt.z)
					var favlength:Number = 100//100;
					var palmratio:Number = 1.4;
							
					var hfn:int = cO.handList[j].fingerList.length;
					var hfnk:Number = 0;
					if (hfn) hfnk = 1 / hfn;
					
						for (i = 0; i < hfn; i++)
								{
								cO.handList[j].fingerList[i].favdist = Vector3D.distance(cO.handList[j].fingerList[i].position, cO.handList[j].fingerAveragePosition);
								// find average max length
								favlength += cO.handList[j].fingerList[i].max_length; //??????
								//trace("favdist",cO.motionArray[i].favdist,cO.motionArray[i].fingertype, min_favdist, max_favdist )	
								}
					favlength = hfnk*favlength	
					
					// AVERAGE HAND RADIUS
					cO.handList[j].sphereRadius = favlength * palmratio;	
					//cO.handList[j].sphereRadius = favdist * palmratio;	
					//trace("rad",cO.handList[j].sphereRadius)
				}
		}
		
		
		
		// get nomalized finger length and palm angle
		// splay and flatness
		public function normalizeFingerSize():void 
		{
			var min_max_length:Number;
			var max_max_length:Number;
			var min_length:Number;
			var max_length:Number;
			//var min_width:Number
			//var max_width:Number
			var min_palmAngle:Number
			var max_palmAngle:Number
			var min_favdist:Number;
			var max_favdist:Number;
			
			
			for (j = 0; j < cO.hn; j++)
			{
				
			min_max_length = 0;
			max_max_length = 0;
			min_length = 0;
			max_length = 0;
			// min_width
			// max_width
			min_palmAngle = 0
			max_palmAngle = 0
			min_favdist = 0;
			max_favdist = 0;
				
			var hfn:uint = cO.handList[j].fingerList.length;
			var palm_mpoint:MotionPointObject = cO.handList[j].palm; // NEED TO SIMPLIFY		
			
			
			var normal:Vector3D = palm_mpoint.normal;
			var p_pos:Vector3D = palm_mpoint.position;
			var fav_pos:Vector3D = cO.handList[j].fingerAveragePosition;
			var fvp_mp:Vector3D = fav_pos.subtract(p_pos);
			
			var dist:Number = (fvp_mp.x * normal.x) + (fvp_mp.y * normal.y) + (fvp_mp.z * normal.z);
			var palm_plane_favpoint:Vector3D = new Vector3D((fav_pos.x - dist * normal.x), (fav_pos.y -dist*normal.y), (fav_pos.z - dist*normal.z));
							
			///////////////////////////////////////////////////
			// set plam plane fav projection point
			cO.handList[j].projectedFingerAveragePosition = palm_plane_favpoint;
			
			
			// get values
			for (i = 0; i < hfn; i++)
				{	
					var fpt:MotionPointObject = cO.handList[j].fingerList[i];
						
							
							var f_pos:Vector3D = fpt.position;
							
							var vp_mp:Vector3D = f_pos.subtract(p_pos);

							var dist1:Number = (vp_mp.x * normal.x) + (vp_mp.y * normal.y) + (vp_mp.z * normal.z);
							var palm_plane_point:Vector3D = new Vector3D((f_pos.x - dist1 * normal.x), (f_pos.y -dist1*normal.y), (f_pos.z - dist1*normal.z));
							
							fpt.palmplane_position = palm_plane_point
							//trace("projected point in palm plane",palm_plane_point)
				
							var ppp_dir:Vector3D = palm_plane_point.subtract(p_pos);
							
							// set palm angle of point
							fpt.palmAngle =  Vector3D.angleBetween(ppp_dir, palm_mpoint.direction);
							//palmAngle = Math.abs(Vector3D.angleBetween(cO.motionArray[i].direction, palm_mpoint.direction));

							// calc proper length
							fpt.length = Vector3D.distance(p_pos, f_pos);
							
							// FIND EXTENSION MEASURE
							var palm_finger_vector:Vector3D = fpt.position.subtract(palm_mpoint.position);
							var angle_diff:Number = Vector3D.angleBetween(fpt.direction, palm_finger_vector);
							// normalize
							fpt.extension = normalize(angle_diff, 0, Math.PI*0.5);
				}
						
				
				for (i = 0; i < hfn; i++)
				{
					var fpt0:MotionPointObject = cO.handList[j].fingerList[i];
					
						//max length max and min
						var value_max_length:Number = fpt0.max_length;
						if (value_max_length > max_max_length) max_max_length = value_max_length;
						if ((value_max_length < min_max_length)&&(value_max_length!=0)) min_max_length = value_max_length;
						
						// length max and min
						var value_length:Number = fpt0.length;
						if (value_length > max_length) max_length = value_length;
						if ((value_length < min_length)&&(value_length!=0)) min_length = value_length;
						
						// palm angle max and min
						var value_palm:Number = fpt0.palmAngle;
						if (value_palm > max_palmAngle) max_palmAngle = value_palm;
						if ((value_palm < min_palmAngle)&&(value_palm!=0)) min_palmAngle = value_palm;

						//finge raverage distance max and min
						var value:Number = fpt0.favdist;
						if (value > max_favdist) max_favdist = value;
						if ((value < min_favdist)&&(value!=0)) min_favdist = value;
				}
				
				var avg_palm_angle:Number = 0;
				
				
				//normalized values and update
				for (i = 0; i < hfn; i++)
					{
						var fpt1:MotionPointObject = cO.handList[j].fingerList[i];
						
						fpt1.normalized_max_length = normalize(fpt1.max_length, min_max_length, max_max_length);
						fpt1.normalized_length = normalize(fpt1.length, min_length, max_length);
						//cO.motionArray[i].normalized_width = normalize(cO.motionArray[i].width, min_width, max_width);
						fpt1.normalized_palmAngle = normalize(fpt1.palmAngle, min_palmAngle, max_palmAngle);
						fpt1.normalized_favdist = normalize(fpt1.favdist, min_favdist, max_favdist);
						
						
						//AVERGE PALM ANGLE
						avg_palm_angle += fpt1.normalized_palmAngle;
					}
					
					
					///////////////////////////////////////////////////////////////////////////////////////////////
					// FIND HAND FLATNESS MEASURE
					// DIST BETWEEN FAV POINT AND PROJECTED FAV POINT IN PLANE
					var pfav_fav_dist:Number = Vector3D.distance(palm_plane_favpoint,fav_pos)
					cO.handList[j].flatness = normalize(pfav_fav_dist, 0, 30);
					//trace("flatness", cO.handList[j].flatness);
					
					////////////////////////////////////////////////////////////////////////////////////////////////
					// FIND HAND SPLAY MEASURE
					//avg_palm_angle = avg_palm_angle / hfn;
					
					var splay_d:Number = 0;
					
					// MUST MAKE DISTANCE PAIR LIST
					for (var i:int = 0; i < hfn; i++)
					{
					for (var q:int = 0; q < i+1; q++)
					{
						if (i!=q)
						{
							var dist0:Number = Vector3D.distance(cO.handList[j].fingerList[i].position,cO.handList[j].fingerList[q].position);
							splay_d += dist0;
						}
						
					}
					}
					
					splay_d = 2 * splay_d / (hfn * (hfn - 1));
					cO.handList[j].splay = normalize(splay_d, 30, 120);
					//trace("splay", cO.handList[j].splay);
					
			}
		}
		
		
		// find thumb .. generate pair data
		public function findThumb():void
		{
		
		for (j = 0; j < cO.hn; j++)
				{
	
			cO.handList[j].pair_table = new Array();
			
			var hfn:int = cO.handList[j].fingerList.length;
			
			var fpt:MotionPointObject //= cO.handList[j].fingerList[i];
			var palm_mpoint:MotionPointObject

						///////////////////////////////////////////////////////////////////////////////////
						// MOD THUMB PROB WITH FINGER LENGTH AND WIDTH
						
							// get largest thumb prob
							var thumb_list:Array = new Array()
							
							for (i = 0; i < hfn; i++)
								{
									fpt = cO.handList[j].fingerList[i];
									
									//ALL
									fpt.thumb_prob += 2*(1- fpt.normalized_length)
									fpt.thumb_prob += 5*(fpt.normalized_favdist) //WORKS VERY WELL ON OWN
									fpt.thumb_prob += 2*(fpt.normalized_palmAngle)

									thumb_list[i] = fpt.thumb_prob;
								}	
							
						///////////////////////////////////////////////////////////////////////////////////
						// SET FINGER TO THUMB BASED ON HIGHEST PROB
						var max_tp:Number = Math.max.apply(null, thumb_list);
						var max_index:int = thumb_list.indexOf(max_tp);
						
						if ((max_index != -1) && ( cO.handList[j].fingerList[max_index]) && (cO.handList[j].fingerList[max_index].type == "finger")) 
						{
							
							// 
							//var v = cO.handList[j].projectedFingerAveragePosition.subtract(cO.handList[j].palm.position)
							var v:Vector3D = cO.handList[j].palm.direction;
							var v1:Vector3D = cO.handList[j].fingerList[max_index].palmplane_position.subtract(cO.handList[j].palm.position)
							
							var angle:Number = Vector3D.angleBetween(v, v1)
							var length:int = cO.handList[j].fingerList[max_index].length;
							var favdist:Number = cO.handList[j].fingerList[max_index].favdist;
							
							
								// QUICK EFFECTIVE METRIC/////////////////////////////////////////////
								var ratio:Number = (1.1*length) / (favdist + 50 * angle)
								//////////////////////////////////////////////////////////
							
							
								//trace(ratio);
								if (hfn == 5)
								{
								if ((ratio < 0.8))//0.56
								{
									// SET THUMB TYPE
									cO.handList[j].fingerList[max_index].fingertype = "thumb";	
								
									// SET THUMB IN HAND OBJECT
									cO.handList[j].thumb = cO.handList[j].fingerList[max_index];
									//trace("assign thumb", hfn);
								}
								else {
									cO.handList[j].fingerList[max_index].fingertype = "finger";
									cO.handList[j].thumb = null//cO.handList[j].fingerList[max_index];//null
									//trace("fail", hfn,cO.handList[j].fingerList[max_index].position);
								}
								}
								if (hfn == 4)
								{
								if ((ratio < 0.70))
								{
									// SET THUMB TYPE
									cO.handList[j].fingerList[max_index].fingertype = "thumb";	
								
									// SET THUMB IN HAND OBJECT
									cO.handList[j].thumb = cO.handList[j].fingerList[max_index];
									//trace("assign thumb", hfn);
								}
								else {
									cO.handList[j].fingerList[max_index].fingertype = "finger";
									cO.handList[j].thumb = null//cO.handList[j].fingerList[max_index];//null
									//trace("fail", hfn,cO.handList[j].fingerList[max_index].position);
								}
								}
								if (hfn == 3)
								{
								if (ratio < 1.2)
								{
									// SET THUMB TYPE
									cO.handList[j].fingerList[max_index].fingertype = "thumb";	
								
									// SET THUMB IN HAND OBJECT
									cO.handList[j].thumb = cO.handList[j].fingerList[max_index];
									//trace("assign thumb", hfn);
								}
								else {
									cO.handList[j].fingerList[max_index].fingertype = "finger";
									cO.handList[j].thumb = null//cO.handList[j].fingerList[max_index];//null
									//trace("fail", hfn,cO.handList[j].fingerList[max_index].position);
								}
								}
								
								
								if (hfn == 2) 
								{
									if (ratio < 2.1)
									{
									cO.handList[j].fingerList[max_index].fingertype = "thumb";
									cO.handList[j].thumb = cO.handList[j].fingerList[max_index];
									}
									
									else {
									cO.handList[j].fingerList[max_index].fingertype = "finger";
									cO.handList[j].thumb = null;
									}
								}
							//}
						}
						
						if (hfn == 1)
						{
							// RATIO BREAKS APPART AS LENGTH AND FAV DIST NO LONGER RELEVANT
							// ANGLE IS ONLY REMAINING METRIC
							var v0:Vector3D = cO.handList[j].palm.direction
							var v10:Vector3D = cO.handList[j].fingerList[0].palmplane_position.subtract(cO.handList[j].palm.position)
							var angle0:Number = Vector3D.angleBetween(v0, v10)
							//trace("one", angle)
							if (angle0 > 0.2)
							{
								//trace("one")
								cO.handList[j].fingerList[0].fingertype = "thumb";
								cO.handList[j].thumb = cO.handList[j].fingerList[0];
							}
								
							}
						
						// note sorting point list at this pahse doesnt seem to have any issues??
						// probably because there are no transformations yet
						
						/*
						thumb_list.sortOn("thumb_prob",Array.DESCENDING);
						
						
						/// find min 
						if (thumb_list[fn - 1]) {
							//min_dist = thumb_list[n - 1]
							//trace("min", thumb_list[fn - 1].thumb_prob, thumb_list[fn - 1].motionPointID);
							if((thumb_list[fn-1].type == "finger")) thumb_list[fn-1].fingertype = "middle";
						}
						
						// find max
						if (thumb_list[1]) {
							//max_dist = thumb_list[0];
							//trace("pinky", thumb_list[0].thumb_prob, thumb_list[1].motionPointID);
							if((thumb_list[0].type == "finger")) thumb_list[1].fingertype = "pinky";
						}
						
						// find max
						if (thumb_list[0]) {
							//max_dist = thumb_list[0];
							//trace("max", thumb_list[0].thumb_prob, thumb_list[0].motionPointID);
							if((thumb_list[0].type == "finger")) thumb_list[0].fingertype = "thumb";
						}
						*/	
						
						
						
						
						
						
						////////////////////////////////////////////////////////////////////////////////
						// GET HANDEDNESS
						if (cO.handList[j].thumb)
						{
							var palmcross:Vector3D = cO.handList[j].palm.normal.crossProduct(cO.handList[j].palm.direction);
							var thumbVector:Vector3D = cO.handList[j].thumb.position.subtract(cO.handList[j].palm.position);
							var angle1:Number = palmcross.dotProduct(thumbVector)
							
							if(angle1){
								if (angle1 < 0) cO.handList[j].type = "left";
								if (angle1 > 0) cO.handList[j].type = "right";
							}
							//else if (angle1 ==NaN) cO.handList[j].type = "undefined";
							
							//trace(angle, cO.handList[j].type)
						}
						
				}		
							
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Find Interactive Pinch Points //PINCH IP
		public function find3DPinchPoints():void
		{
			//trace("finding pinch points, geometric",cO.hn);
			
			var pinchThreshold:Number = 40 * 50//60; //GML CONFIG 
			var distThreshold:Number = 50//60; //GML CONFIG 
			
			var min_pprob:Number;
			var best_dist:Number;
			var best_pt1:MotionPointObject;
			var best_pt2:MotionPointObject;
			var palm:MotionPointObject;
			
				// FIND SMALLEST ANGLE DIFF TO PALM NORMAL && SMALLEST DIST BETWEEN
				// NEED POINT VELOCITY CHECK TO REMOVE BEDAXZZLE TRIGGER
					// CLOSEST TO PALM POINT -AMBIQUOUS
					// CLOSTEST TO FAV CREATES 2 FINGER ERROR
					// THUMB REQUOREMENT NEEDS FULL TESTING
				// PRESENT SINGLE PINCH POINT ALWAYS
			
			for (var j:int = 0; j < cO.hn; j++)
				{	
					
				//////////////////////////////////////////////////////////////////////////////////////////////////////////////	
				min_pprob = 20000;
				best_dist = 0;
				best_pt1 = new MotionPointObject()
				best_pt2 = new MotionPointObject();
				palm = cO.handList[j].palm;
				
				// GET LOCAL LIST OF CLOSE FINGER TIPS
				// gererate pair distances
				var fn:int = cO.handList[j].fingerList.length;
				
				for (var i:int = 0; i < fn; i++)
					{
					for (var q:int = 0; q < i+1; q++)
					{
						if ((i!=q))
						{
							var pt1:MotionPointObject = cO.handList[j].fingerList[i];
							var pt2:MotionPointObject = cO.handList[j].fingerList[q];
							var pt1_direction:Vector3D = pt1.position.subtract(palm.position);
							var pinch_dist:Number = Vector3D.distance(pt1.position,pt2.position);
							var pinchPalmAngle:Number = Vector3D.angleBetween(pt1_direction, palm.normal);
							
							var pinch_prob:Number = pinch_dist * 60 * pinchPalmAngle; //MAY NEED TO INCREASE TO 60 SEE RATIO
							
							if ((pinch_prob < min_pprob) && (pinch_prob != 0)) {
								min_pprob = pinch_prob;
								best_dist = pinch_dist;
								best_pt1 = pt1;
								best_pt2 = pt2;
								
								//trace("ppa",pinchPalmAngle, "dist",pinch_dist, "prob",pinch_prob, min_pprob, pt1.position,pt2.position);
							}
							//trace("pair",i,q)
						}
						
					}
				}
				
				// NEEDS FIX WHEN TRANSSITIONING BETWEEN STATES
				// PINKY TRIGGER (NEED WIDTH FOR BETTER THUMB)
				
				/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				//trace("prob",min_pprob);

				// find midpoint between fingertips
					if ((best_pt1) && (best_pt2)&& (min_pprob != 0))
					{	
						// STRONG PINCH
						if ((fn == 2) && (best_dist<distThreshold)) 
						{
						var pmp:InteractionPointObject = new InteractionPointObject();
							pmp.position.x = best_pt1.position.x - (best_pt1.position.x - best_pt2.position.x) * 0.5;
							pmp.position.y = best_pt1.position.y - (best_pt1.position.y - best_pt2.position.y) * 0.5;
							pmp.position.z = best_pt1.position.z - (best_pt1.position.z - best_pt2.position.z) * 0.5;
							//pmp.handID = cO.hand.handID;
							pmp.type = "pinch";
															
						//add to pinch point list
						InteractionPointTracker.framePoints.push(pmp)
						//trace("2 pinch push", best_dist)	
						}
						
						 //WEAK PINCH
						else if (min_pprob < pinchThreshold)
						{
						var pmp0:InteractionPointObject = new InteractionPointObject();
							pmp0.position.x = best_pt1.position.x - (best_pt1.position.x - best_pt2.position.x) * 0.5;
							pmp0.position.y = best_pt1.position.y - (best_pt1.position.y - best_pt2.position.y) * 0.5;
							pmp0.position.z = best_pt1.position.z - (best_pt1.position.z - best_pt2.position.z) * 0.5;
							//pmp.handID = cO.hand.handID;
							pmp0.type = "pinch";
															
						//add to pinch point list
						InteractionPointTracker.framePoints.push(pmp0)
						//trace("n pinch push", pinchThreshold)
						}
					}
					
					
			}
		
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Find Interactive Hook Points 
		public function find3DHookPoints():void
		{
			// hooked fingers
			var hookThreshold:Number = 0.46; // GML ADJUST
			
			for (var j:int = 0; j < cO.hn; j++)
				{	
				var hfn:int = cO.handList[j].fingerList.length;
				
				for (i = 0; i < hfn; i++)
				{
					var hp:MotionPointObject = cO.handList[j].fingerList[i];
					//trace("hook extension",hp.extension)
						
					if (hp.fingertype == "finger")
					{
						if(hp.extension > hookThreshold)
							{	
							var pmp:InteractionPointObject = new InteractionPointObject();
								pmp.handID = hp.handID;
								pmp.position = hp.position;
								pmp.direction = hp.direction;
								//pmp.length = cO.motionArray[i].length;
								//pmp.extension = hp.extension;
								pmp.type = "hook";
								
							// push to interactive point list
							InteractionPointTracker.framePoints.push(pmp)
							}
					}
					// FAULT IN SKELETON 
					// AS KNUCKELE NOT KNOWN WELL THUMB APPEARS FLEXED WHEN NOT ACTUALLY 
					// SO ADJUST THRESHOLD
					if (hp.fingertype == "thumb")
					{
						if(hp.extension > hookThreshold + 0.2)
							{	
							var pmp0:InteractionPointObject = new InteractionPointObject();
								pmp0.handID = hp.handID;
								pmp0.position = hp.position;
								pmp0.direction = hp.direction;
								//pmp.length = cO.motionArray[i].length;
								//pmp.extension = hp.extension;
								pmp0.type = "hook";
								
							// push to interactive point list
							InteractionPointTracker.framePoints.push(pmp0)
							}
					}	
				}
			}
			
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Find Interactive Push/Pin Point (z-axis)
		public function find3DPushPoints():void
		{
			// must add other planes (orthogonal)
			// must add plane bounds (x and y for z)
			var z_wall:int = 50;
			
			for (var j:int = 0; j < cO.hn; j++)
				{	
				var hfn:int = cO.handList[j].fingerList.length;
					
					for (var i:int = 0; i < hfn; i++)
					{
						var pp:MotionPointObject = cO.handList[j].fingerList[i];
						
							//trace("pos",cO.motionArray[i].position)
							if (pp.position.x > z_wall) //side
							//if (pp.position.y > z_wall) //bottom
							//if (cO.motionArray[i].position.z > z_wall) //front
								{
								var pmp:InteractionPointObject = new InteractionPointObject();
									pmp.position = pp.position;
									pmp.direction = pp.direction;
									pmp.length = pp.length;
									pmp.type = "push";

								// push to interactive point list
								InteractionPointTracker.framePoints.push(pmp)
								}
					}
				}
				
		}
		
		////////////////////////////////////////////////////////////////////////
		// Find Interactive Trigger Points
		public function find3DTriggerPoints():void
		{	
			// FIND THUMB 
				// THUMB CHECK EXTENSION
					// CHECK POINT ANGLE AND VECTOR ANGLE
					// CHECK FOR PARALLEL DIRECTION 
				// GET PURE FINGER AV
				// GET PURE FINGER DIRECTION AX
				// PUSH TARGET POINT
				// PUSH TRIGGER STATE BASED ON THUMB STATE
				
			var triggerThreshold:Number = 0.6; // bigger threahold than hook // GML ADJUST
			
				for (var j:int = 0; j < cO.hn; j++)
				{	
				var hfn:int = cO.handList[j].fingerList.length;
				var hfnk:Number = 0;
				var thumb:MotionPointObject = cO.handList[j].thumb;	
				
					//trace(thumb.extension)
					if (thumb)
					{
						// ADDED ONLY ONE FINGER CONDITION
						if ((thumb.extension > triggerThreshold)&&(cO.handList[j].fingerList.length>=1)) //1 rad 90 deg ish
							{
							var	t_pt:InteractionPointObject = new InteractionPointObject();
							
							for (i = 0; i < hfn; i++)
							{
								if (cO.handList[j].fingerList[i].fingertype == "finger")
								{
								var pt:MotionPointObject = cO.handList[j].fingerList[i];
				
									// finger average point
									t_pt.position.x += pt.position.x;
									t_pt.position.y += pt.position.y;
									t_pt.position.z += pt.position.z;
										
									t_pt.direction.x += pt.direction.x;
									t_pt.direction.y += pt.direction.y;
									t_pt.direction.z += pt.direction.z;
								}
							}
							
							if (hfn >1) hfnk = 1 / (hfn-1);
							
							t_pt.position.x *= hfnk;
							t_pt.position.y *= hfnk;
							t_pt.position.z *= hfnk;
							
							t_pt.direction.x *= hfnk;
							t_pt.direction.y *= hfnk;
							t_pt.direction.z *= hfnk;
							//t_pt.handID = cO.hand.handID;		
							
							t_pt.fn = cO.handList[j].fingerList.length
							t_pt.type = "trigger";
							
							// push when triggered
							InteractionPointTracker.framePoints.push(t_pt);
							}
					}		
			}
		}
		
		////////////////////////////////////////////////////////////////////////
		// Find Interactive Region Points (3d volume)
		public function find3DRegionPoints():void
		{
			var x_min:Number; 
			var x_max:Number;
			var y_min:Number; 
			var y_max:Number;
			var z_min:Number; 
			var z_max:Number;
			
			for (var j:int = 0; j < cO.hn; j++)
				{	
				x_min = 0; 
				x_max = 300;
				y_min = 0; 
				y_max = 300;
				z_min = 0; 
				z_max = 300;	

				var hfn:int = cO.handList[j].fingerList.length;
			
					for (i = 0; i < hfn; i++)
						{
						var pt:MotionPointObject = cO.handList[j].fingerList[i];	
						
						if ((x_min < pt.position.x < x_max) && (y_min < pt.position.y < y_max) && (z_min < pt.position.z < z_max))
							{
								// create region point
								var tp:InteractionPointObject = new InteractionPointObject();
									tp.position = cO.motionArray[i].position;
									tp.direction = cO.motionArray[i].direction;
									tp.length = cO.motionArray[i].length;
									//tp.handID = cO.motionArray[i].handID;
									tp.type = "region";
						
									//cO.iPointArray.push(tp); // test
								InteractionPointTracker.framePoints.push(tp)
							}
						}
				}
		}	
		
		/////////////////////////////////////////////////////////////////////////
		// Find Interactive Frame Points
		public function find3DFramePoints():void
		{
			// fn == 3;
			// CHECK EXTENSION
				// ADD TO LIST
				// WHEN 2 POINTS 
				// CHECK ANGLE BETWEEN
				// CREATE 4 CORNER POINTS
			// PUSH FRAME POINTS
			
			var minAngle:Number = 0.9; // GML CONFIG
			var maxAngle:Number = Math.PI / 2; //GML CONFIG
			var minExtension:Number = 0.55;
			
			for (var j:int = 0; j < cO.hn; j++)
				{	
				var pointlist:Vector.<MotionPointObject>
				var hfn:int = cO.handList[j].fingerList.length;
			
				pointlist = new Vector.<MotionPointObject>
				
				if (hfn == 2)
				{
						/// find extended fingers
						for (var i:int = 0; i < hfn; i++)
						{
							var pt:MotionPointObject = cO.handList[j].fingerList[i];
							if ((pt.type == "finger") && (pt.extension < minExtension)) pointlist.push(pt);
							//trace(pt.extension)
						}
						//trace(pointlist.length)
						
						if (pointlist.length == 2) 
						{
							var palm_finger_vectorA:Vector3D = pointlist[0].position.subtract(cO.handList[j].position);
							var palm_finger_vectorB:Vector3D = pointlist[1].position.subtract(cO.handList[j].position);
							var angle_diff:Number = Vector3D.angleBetween(palm_finger_vectorA, palm_finger_vectorB);
							//trace("diff", angle_diff);
							
							if ((angle_diff > minAngle)&&(angle_diff < maxAngle))
							{
							
								// create complimentary frame points
								var fav:Vector3D = cO.handList[j].fingerAveragePosition;
								var palm_fav_vector:Vector3D = fav.subtract(cO.handList[j].position);
								var cpt:Vector3D = fav.add(palm_fav_vector);
								
								var cff_pt:InteractionPointObject = new InteractionPointObject();
										cff_pt.position = cpt;
										//cff_pt.direction = palm.direction;
										//t_pt.normal = cO.hand.normal;
										cff_pt.handID = cO.handList[j].handID;
										cff_pt.type = "frame";
										
									InteractionPointTracker.framePoints.push(cff_pt)
								
								// palm point // create interactions points
								var ff_pt:InteractionPointObject = new InteractionPointObject();
										ff_pt.position = cO.handList[j].position;
										//ff_pt.direction = palm.direction;
										//t_pt.normal = cO.hand.normal;
										//ff_pt.handID = cO.handList[j].handID;
										ff_pt.type = "frame";
										
								InteractionPointTracker.framePoints.push(ff_pt)
								//trace("push frame point");
									
								for (var q:int = 0; q < pointlist.length; q++)
								{
									// create interactions points
									var ff_pt0:InteractionPointObject = new InteractionPointObject();
										ff_pt0.position = pointlist[q].position;
										//ff_pt.direction =pointlist[j].direction;
										//t_pt.normal = cO.hand.normal;
										//ff_pt.handID = cO.handList[j].handID;
										ff_pt0.type = "frame";
										
									InteractionPointTracker.framePoints.push(ff_pt0)
									//trace("push frame point");
								}

									
							}
						}
						
				}	
			}						
		}
		
		
		/////////////////////////////////////////////////////////////////////////
		// Collect Interactive FingerTip Points
		public function find3DFingerPoints():void
		{
			
			for (var j:int = 0; j < cO.hn; j++)
				{	
				var hfn:int = cO.handList[j].fingerList.length;
			
				for (var i:int = 0; i < hfn; i++)
						{
							var fpt:MotionPointObject = cO.handList[j].fingerList[i];
							/// get fingers
							if (fpt.fingertype == "finger")
							{
								var f_pt:InteractionPointObject = new InteractionPointObject();
										f_pt.position = fpt.position;
										f_pt.direction = fpt.direction;
										//f_pt.handID = cO.hand.handID;
										f_pt.type = "finger";
										
									InteractionPointTracker.framePoints.push(f_pt)
							}
									
							//if (fpt.fingertype == "finger") f_pt.type = "finger";
							//if (fpt.fingertype == "index") f_pt.type = "index";
							//if (fpt.fingertype == "middle") f_pt.type = "middle";
							//if (fpt.fingertype == "ring") f_pt.type = "ring";
							//if (fpt.fingertype == "pinky") f_pt.type = "pinky";
							//if ((fpt.fingertype == "finger") || (fpt.fingertype == "index") || (fpt.fingertype == "middle") || (fpt.fingertype == "ring") || (fpt.fingertype == "pinky")) InteractionPointTracker.framePoints.push(f_pt)
						}
				}
		}
		
		/////////////////////////////////////////////////////////////////////////
		// Collect Interactive Thumb Points
		public function find3DThumbPoints():void
		{
			for (var j:int = 0; j < cO.hn; j++)
				{	
					var hfn:int = cO.handList[j].fingerList.length;
					//var v0:Vector3D = new Vector3D(0,0,0)
					//get thumb points
					if ((hfn>0)&&(cO.handList[j].thumb!=null)&&(cO.handList[j].thumb.fingertype=="thumb")) 
					{
						var tpt:MotionPointObject = cO.handList[j].thumb;
						
						var t_pt:InteractionPointObject = new InteractionPointObject();
							t_pt.position = tpt.position;
							t_pt.direction = tpt.direction;
							//t_pt.handID = cO.hand.handID;
							t_pt.type = "thumb";
									
						InteractionPointTracker.framePoints.push(t_pt)
						//trace("push thumb point");
					}
				}
		}
		
		/////////////////////////////////////////////////////////////////////////
		// Collect Interactive Thumb Points
		public function find3DFingerAndThumbPoints():void
		{
			for (var j:int = 0; j < cO.hn; j++)
				{	
					var hfn:int = cO.handList[j].fingerList.length;
					
					for (var i:int = 0; i < hfn; i++)
						{
						var dpt:MotionPointObject = cO.handList[j].fingerList[i];
					
							if((dpt)&&(dpt.fingertype=="thumb")||(dpt.fingertype == "finger")) 
							{
							var d_pt:InteractionPointObject = new InteractionPointObject();
								d_pt.position = dpt.position;
								d_pt.direction = dpt.direction;
								//t_pt.handID = cO.hand.handID;
								d_pt.type = "digit";
										
							InteractionPointTracker.framePoints.push(d_pt)
							}
						}
				}
		}
		
		/////////////////////////////////////////////////////////////////////////
		// Collect Interactive FingerAverage Points
		public function find3DFingerAveragePoints():void 
		{
			
				for (j = 0; j < cO.hn; j++)
				{
					var favpt:Vector3D = cO.handList[j].fingerAveragePosition;
					
					if ((favpt.x != 0) && (favpt.y != 0) && (favpt.z != 0))
					{
						// FAV POINT NEEDS DIRECTION AND NORMAL
						var fv_pt:InteractionPointObject = new InteractionPointObject();
							fv_pt.position = cO.handList[j].fingerAveragePosition;
							fv_pt.handID = cO.handList[j].handID;
							fv_pt.type = "finger_average";

						InteractionPointTracker.framePoints.push(fv_pt)	
					}
				}
		}
		
		/////////////////////////////////////////////////////////////////////////
		// Collect Interactive Palm Points
		public function find3DPalmPoints():void 
		{
			var hn:int = cO.handList.length;
			var flatness:Number = 0.4;
			var orientation:String;
			var handednes:String;
			
			// PALM IP MAY BE CREATED BASED ON FLATNESS , ORIENTATION AND HANDEDNESS CRITERIA
			// IN THE SAME WAY AS PINCH, HOOK, TRIGGER MAY BE CREATED BASED ON SEPERATION AND EXTENSION CRITERIA
			
				for (j = 0; j < cO.hn; j++)
				{
						var palm_pt:InteractionPointObject = new InteractionPointObject();
						
						////////////////////////////////////////////////////////////////
						// CREAT PALM POINT
						////////////////////////////////////////////////////////////////
						
							palm_pt.position = cO.handList[j].palm.position;
							palm_pt.direction = cO.handList[j].palm.direction;
							palm_pt.normal = cO.handList[j].palm.normal;
							palm_pt.rotation = cO.handList[j].palm.rotation;
							palm_pt.handID = cO.handList[j].palm.handID;
							
							palm_pt.fn = cO.handList[j].fingerList.length;
							
							palm_pt.flatness = cO.handList[j].flatness;
							palm_pt.orientation = cO.handList[j].orientation;
							//palm_pt.type  = cO.handList[j].type 
							palm_pt.sphereRadius  = cO.handList[j].sphereRadius  
							palm_pt.type = "palm";	
							
							//trace("fist: geometric", palm_pt.fist, cO.handList[j].orientation, cO.handList[j].flatness, cO.handList[j].splay, cO.handList[j].type);
							
						InteractionPointTracker.framePoints.push(palm_pt)
				}
		}
		
		public function find3DFistPoints():void 
		{
			var hn:int = cO.handList.length;
			var flatness:Number = 0.4;
			var orientation:String;
			var handednes:String;
			
			//trace("find fist points");
			
			// PALM IP MAY BE CREATED BASED ON FLATNESS , ORIENTATION AND HANDEDNESS CRITERIA
			// IN THE SAME WAY AS PINCH, HOOK, TRIGGER MAY BE CREATED BASED ON SEPERATION AND EXTENSION CRITERIA
			
				for (j = 0; j < cO.hn; j++)
				{	
						var fist_pt:InteractionPointObject = new InteractionPointObject();
						
							// TEST FOR OPENESS
							//
							if (cO.handList[j].fingerList.length == 0) 
							{
								if (cO.handList[j].flatness<10) fist_pt.fist = true;
								//trace("fist: 0",cO.handList[j].sphereRadius,cO.handList[j].palm.sphereRadius,cO.handList[j].flatness);
								
							}
							// STRONG TRACKING ERROR 2 FINGERS
							else if (cO.handList[j].fingerList.length == 2)
							{
								if ((cO.handList[j].fingerList[0].length < 80) && (cO.handList[j].fingerList[1].length < 80))
								{
								//if ((cO.handList[j].flatness<0.2)&&(cO.handList[j].palm.sphereRadius<70)){
									fist_pt.fist = true;
								}
								//trace("2 fist: ",palm_pt.fist,cO.handList[j].fingerAveragePosition,cO.handList[j].fingerList[0].length,cO.handList[j].fingerList[1].length);
							}
							// WEAK TRACKING ERROR 1 FINGER
							else if (cO.handList[j].fingerList.length == 1)
							{
								if (cO.handList[j].fingerList[0].length<90){
								//if ((cO.handList[j].flatness<0.4)&&(cO.handList[j].palm.sphereRadius<60)){
									fist_pt.fist = true;
								}
								//trace("1 fist: ",palm_pt.fist,cO.handList[j].fingerList.length,cO.handList[j].palm.sphereRadius,cO.handList[j].flatness,cO.handList[j].fingerAveragePosition,cO.handList[j].fingerList[0].length);
							}
							else {
								fist_pt.fist = false;
							}
							//trace("fist: ", palm_pt.fist);
							///////////////////////////////////////////////////
							//OVERIDE FLATNESS AND HAND ORIENTATION
							///////////////////////////////////////////////////
							if (fist_pt.fist) 
							{
								cO.handList[j].orientation = "unknown";
								cO.handList[j].flatness = 0;
								cO.handList[j].splay = 0;
								cO.handList[j].type = "unknown";
								//cO.handList[j].fist = true;
								
								
								////////////////////////////////////////////////////////////////
								// CREAT FIST POINT
								////////////////////////////////////////////////////////////////
						
								fist_pt.position = cO.handList[j].palm.position;
								fist_pt.direction = cO.handList[j].palm.direction;
								fist_pt.normal = cO.handList[j].palm.normal;
								fist_pt.rotation = cO.handList[j].palm.rotation;
								fist_pt.handID = cO.handList[j].palm.handID;
								
								fist_pt.fn = cO.handList[j].fingerList.length;
								
								fist_pt.flatness = cO.handList[j].flatness;
								fist_pt.orientation = cO.handList[j].orientation;
								//palm_pt.type  = cO.handList[j].type 
								fist_pt.sphereRadius  = cO.handList[j].sphereRadius  
								fist_pt.type = "fist";	
							
								//trace("fist: geometric");
							
								InteractionPointTracker.framePoints.push(fist_pt)
							}
				}
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//Collect Interactive Tool Points 
		public function find3DToolPoints():void
		{
			// hooked fingers
			//var hook_extension:Number = 30;
			
			/*
			for (var j:int = 0; j < hn; j++)
				{	
				var hfn:int = cO.handList[j].fingerList.length;
			
				for (i = 0; i < hfn; i++)
				{
					
					if (cO.motionArray[i].type == "tool")
						{	
							//trace("tool");
							//var pmp:MotionPointObject = new MotionPointObject();
							var pmp:InteractionPointObject = new InteractionPointObject();
								pmp.handID = cO.handList[j].fingerList[i].handID;
								pmp.position = cO.handList[j].fingerList[i].position;
								pmp.direction = cO.handList[j].fingerList[i].direction;
								pmp.length = cO.handList[j].fingerList[i].length;
								pmp.type = "tool";

								// push to interactive point list	
								InteractionPointTracker.framePoints.push(pmp)
						}
					}
				}*/
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////
		// helper functions
		////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////
		
		private static function normalize(value : Number, minimum : Number, maximum : Number) : Number {

                        return (value - minimum) / (maximum - minimum);
        }

        private static function limit(value : Number, min : Number, max : Number) : Number {
                        return Math.min(Math.max(min, value), max);
        }
	}
}