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
	import com.gestureworks.core.gw_public;
	import com.gestureworks.objects.PointObject;
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.StrokeObject;
	import com.gestureworks.objects.GestureListObject;;
	
	//import com.gestureworks.analysis.paths.PathProcessor;
	
	import flash.geom.Point;
	//import flash.display.Sprite;
	import flash.geom.Rectangle;

		
	public class VectorMetric
	{
		//////////////////////////////////////
		// ARITHMETIC CONSTANTS
		//////////////////////////////////////
		private static const RAD_DEG:Number = 180 / Math.PI;
		private static const DEG_RAD:Number = Math.PI / 180 ;
		
		private var touchObjectID:int;
		private var ts:Object;//private var ts:TouchSprite;
		private var cO:ClusterObject;
		private var sO:StrokeObject;
		private var gO:GestureListObject;;
		public var pointList:Vector.<PointObject>;
		
		// number in group
		//private var N:uint = 0;
		private var i:uint = 0;
		private var j:uint = 0;
		
		private var key:uint = 0;
		
		
		public static var NumPoints:int = 30//100;
		public static var SquareSize:Number = 250.0;
		public static var HalfDiagonal:Number = 0.5 * Math.sqrt(2 * SquareSize * SquareSize);
		
		public static var width:Number = 0;
		public static var height:Number = 0;
		
		//public var temp_path:Array = new Array();
		
		public function VectorMetric(_id:int) 
		{
			touchObjectID = _id;
			init();
		}
		
		public function init():void
		{
			
			ts = GestureGlobals.gw_public::touchObjects[touchObjectID]; // need to find center of object for orientation and pivot
			cO = ts.cO;
			gO = ts.gO;
			sO = ts.sO;
			
			//if (ts.traceDebugMode) 
			//trace("init cluster vectormetric");
			
			// ASSEMBLES PATH COLLECTION FROM GESTURE OBJECTS
			getPathCollection();
		}
		
		public function findPathProperties():void
		{
			//getSamplePathDims();
			getSamplePathPosition();
		}
		
		public function resetPathProperties():void 
		{
			sO.path_prob = 0;
			sO.path_x = 0;
			sO.path_y = 0;
			sO.path_x0 = 0;
			sO.path_y0 = 0;
			sO.path_x1 = 0;
			sO.path_y1 = 0;
			sO.path_n = 0;
			
			sO.path_width = 0;
			sO.path_height = 0;
			sO.path_time = 0;
			
			sO.path_data = new Array();
		}
		
		////////////////////////////////////////////////////////////
		// Methods: Private
		////////////////////////////////////////////////////////////
		
		public function getSamplePath():void 
		{
			//trace("hitory length",pointList[0].history.length)
			var path:Array = new Array();
			pointList = cO.pointArray;
			
			var pn:int = pointList[0].history.length;
			
			for (i = 0; i < pn; i++)
				{
				// MAY NEED TO CONVERT TO BACK TO SIMPLE 3D POINTS
				//trace("--",pointList[0].history[i].x, pointList[0].history[i].y)
				//path.push(new Object(pointList[0].history[i].x, pointList[0].history[i].y, pointList[0].history[i].w, pointList[0].history[i].h));
				var tpt:Object = new Object()
					tpt.x = pointList[0].history[i].x;
					tpt.y = pointList[0].history[i].y;
					tpt.w = pointList[0].history[i].w;
					tpt.h = pointList[0].history[i].h;
				path.push(tpt);
				}
			sO.path_data = path
			sO.path_n = path.length;
			//trace(cO.path_data.length,sO.path_data.length)
			
		}
		
		public function getSamplePathPosition():void 
		{
			//trace("hitory length",pointList[0].history.length)
			
			var p_x:Number = 0;
			var p_y:Number = 0;
			var p_n:int = sO.path_data.length;
			
			for (i = 0; i < p_n; i++)
				{
				p_x += sO.path_data[i].x;
				p_y += sO.path_data[i].y;
				}
			sO.path_x = p_x / p_n;
			sO.path_y = p_y / p_n;
			sO.path_n = p_n;
			
			sO.path_x0 = sO.path_data[0].x;
			sO.path_y0 = sO.path_data[0].y;
			sO.path_x1 = sO.path_data[p_n-1].x;
			sO.path_y1 = sO.path_data[p_n - 1].y;
			
			// pulled from bounding box
			sO.path_width = width;
			sO.path_height = height;
			
			//trace(sO.path_data)
			//trace("gsamp",sO.path_x0,sO.path_x1)
		}
		
		public function normalizeSamplePath():void
		{
			//trace(sO.path_data.length)
			//trace("pre norm",cO.path_data.length,cO.history[0].path_data.length);
			sO.path_data_norm = normalize(sO.path_data);
			//trace(sO.path_data_norm.length)
		}
		
		public function getPathCollection():void 
		{
			//trace("get path collection")
			var gn:uint = gO.pOList.length;
			var pathCollection:Vector.<Array> = new Vector.<Array>
			var pathMap:Array = new Array();
			
			//var key:uint = 0;
			// FOR ALL GESTURE OBJECTS ATTACHED TO TOUCH OBJECT
			for (key = 0; key < gn; key++)  { 
				
				//trace("hello",gn);
				// FIND ALL STROKE GESTURES
				if (gO.pOList[key].algorithm_class == "vectormetric")
				{
					// GET GML PATH DESCRIPTION
					var Path:Array = gO.pOList[key].gmlPath
					// NORMALIZE GML PATH
					var normPath:Array = normalize(Path)
					// PUSH INTO PATH COLLECTION LIST
					pathCollection.push(normPath);
					pathMap.push(key); // maps gesture object key to path
					//trace(gO.pOList[key].gmlPath.length, normPath.length)
				}
			}
			sO.path_collection = pathCollection;
			sO.pathmap = pathMap;
			//trace("get path list", gn);
		}
		
		public static function normalize(collection:Array):Array
		{
			//collection = PathProcessor.Resample(collection, PathProcessor.NumPoints);
			var c:Array = Resample(collection, 100);
				c = ScaleToSquare(c, SquareSize);
				c = TranslateToOrigin(c);
			//trace("c",c.length);
			return c
		}
		
		//FIND STROKE MATCH FROM LOCAL TOUCH OBJECT PATH COLLECTION
		public function findStrokeGesture():void
		{
			//trace(sO.path_data_norm.length)
			var prob_min:Number = 0.6;
			
			/////////////////////////////////////
			// FIND BEST FIT AND RETURN PATH ID
			//var rtn:Object = PathProcessor.CompareRawToNormalizedPathCollection(sO.path_data_norm, pathCollection)
			var rtn:Object = CompareRawToNormalizedPathCollection(sO.path_data_norm, sO.path_collection)
			
			if (rtn) {
				//trace(rtn.path);
				//trace(rtn.score);
				//trace(rtn.key);
			
			//trace("ref data",key, N, path_match, path);
			
				if (rtn.score>prob_min)
				{
					var key:int = sO.pathmap[rtn.key];
					//trace("key", key,rtn.score)
					sO.path_prob = rtn.score;
					
					// find path properties
					getSamplePathPosition();
					//getSamplePathDims();
					
					///////////////////////////////////////////
					// SEED DATA INTO CORROLATED GESTURE OBJECT
					// PUSH STROKE OBJECT DATA INTO GESTURE OBJECT
					//gO.pOList[key].data.path_data = sO.path_data  // neeed to push raw data into event also for debugging
					
					
					gO.pOList[key].data.path_data = sO.path_data_norm
					gO.pOList[key].data.prob = sO.path_prob;
					gO.pOList[key].data.stroke_id = sO.id;
										
					gO.pOList[key].data.x = sO.path_x; // center point
					gO.pOList[key].data.y = sO.path_y;// center point
					gO.pOList[key].data.x0 = sO.path_x0;// start point
					gO.pOList[key].data.y0 = sO.path_y0;// start point
					gO.pOList[key].data.x1 = sO.path_x1;// end point
					gO.pOList[key].data.y1 = sO.path_y1;// end point
										
					gO.pOList[key].data.n = 1//cO.n;// fingers
					gO.pOList[key].data.path_n = sO.path_n; // data points in path
					gO.pOList[key].data.width = sO.path_width; //path width
					gO.pOList[key].data.height = sO.path_height; // path height
					gO.pOList[key].data.time = sO.path_time; // path draw time
						
					////////////////////////////////////
					// TRIGGER GESTURE EVENT CONSTRUCTOR
					gO.pOList[key].activeEvent = true;
					gO.pOList[key].dispatchEvent = true;
					
					
					
				//	trace(sO.path_data_norm)
				}
			}
		}
		/////////////////////////////////////////////////////////////////////////////
		//PATH COMPARISON
		//////////////////////////////////////////////////////////////////////////////
		public static function CompareRawToNormalizedPathCollection(path:Array ,pathCollection:Vector.<Array>):Object
		{
		var b:Number = +Infinity;
		var t:int;
		var pn:uint = pathCollection.length;
		
		//trace("path comparison", pn);	
		
		for (var i:int = 0; i < pn; i++)
		{
			//var d:Number = PathDistance(path.collection, pathCollection[i].collection);
			var d:Number = PathDistance(path, pathCollection[i]);
			//trace("path diff sum",i, d);
			
			if (d < b)
			{
				b = d;
				t = i;
			}
		}
		
		if(b > 75)
		{
			return null;
		}
		
		var score:Number = 1.0 - (b / HalfDiagonal);
		//trace(score,t);
		return {path: pathCollection[t], score: score,key:t};
	}
	
	
	// Helper functions
	
	public static function Resample(points:Array, n:int):Array
	{
		//trace("sample", points.length, n);
		
		var I:int = PathLength(points) / (n - 1); // interval length
		var D:Number = 0.0;
		var newpoints:Array = new Array(points[0]);
		
		//trace(I,PathLength(points),points.length,n,n-1);
		
		if(I){ // to prevent I==0 time out crash
			for (var i:int = 1; i < points.length; i++)
			{
				var d:Number = Distance(points[i - 1], points[i]);
				if ((D + d) >= I)
				{
					var qx:Number = points[i - 1].x + ((I - D) / d) * (points[i].x - points[i - 1].x);
					var qy:Number = points[i - 1].y + ((I - D) / d) * (points[i].y - points[i - 1].y);
					var q:Point = new Point(qx, qy);
					newpoints[newpoints.length] = q; // append new point 'q'
					points.splice(i, 0, q); // insert 'q' at position i in points s.t. 'q' will be the next i
					D = 0.0;
				}
				else D += d;
			}
			// somtimes we fall a rounding-error short of adding the last point, so add it if so
			if (newpoints.length == n - 1)
			{
				newpoints[newpoints.length] = points[points.length - 1];
				//trace("true")
			}
		}
		//trace("resample",points.length, n, newpoints.length);
		
		return newpoints;
	}

	public static function ScaleToSquare(points:Array, size:Number):Array
	{
		var B:* = BoundingBox(points);
		var newpoints:Array = new Array();
		for (var i:int = 0; i < points.length; i++)
		{
			var qx:Number = points[i].x * (size / B.width);
			var qy:Number = points[i].y * (size / B.height);
			newpoints[newpoints.length] = new Point(qx, qy);
		}
		return newpoints;
	}			
	public static function TranslateToOrigin(points:Array):Array
	{
		var c:* = Centroid(points);
		var newpoints:Array = new Array();
		for (var i:int = 0; i < points.length; i++)
		{
			var qx:Number = points[i].x - c.x;
			var qy:Number = points[i].y - c.y;
			newpoints[newpoints.length] = new Point(qx, qy);
		}
		return newpoints;
	}
	
	public static function PathLength(points:Array):Number// find the total path length by adding the distance between all data points
	{
		var d:Number = 0.0;
		for (var i:int = 1; i < points.length; i++)
			d += Distance(points[i - 1], points[i]);
		return d;
	}
	
	public static function Distance(p1:Object, p2:Object):Number // finds the distance between two points
	{//CONVERTED FROM POINTS TO OBJECT
		if ((p1) && (p2))
		{
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		else return 0;
	}
	public static function Centroid(points:Array):Point
	{
		var x:Number = 0.0, y:Number = 0.0;
		for (var i:int = 0; i < points.length; i++)
		{
			x += points[i].x;
			y += points[i].y;
		}
		x /= points.length;
		y /= points.length;
		return new Point(x, y);
	}
	public static function BoundingBox(points:Array):Rectangle
	{
		var minX:Number = +Infinity, maxX:Number = -Infinity, minY:Number = +Infinity, maxY:Number = -Infinity;
		
		
		for (var i:int = 0; i < points.length; i++)
		{
			if (points[i].x < minX)
				minX = points[i].x;
			if (points[i].x > maxX)
				maxX = points[i].x;
			if (points[i].y < minY)
				minY = points[i].y;
			if (points[i].y > maxY)
				maxY = points[i].y;
		}
		
		// if maxX-minX null return 25 so straight lines on axis trnslate correctly
		width = Math.max(maxX - minX, 25);
		height = Math.max(maxY - minY, 25);
		
		return new Rectangle(minX, minY, width,height);
	}
	
	public static function PathDistance(pts1:Array, pts2:Array):Number // finds the average difference between points in both paths
	{
		var d:Number = 0.0;
		var d_b:Number = 0.0;
		var d_f:Number = 0.0;
		//trace(pts1)
		//trace(pts1.length);
		var np:uint = pts1.length
		for (var i:int = 0; i < np; i++) // assumes pts1.length == pts2.length
		{
			d_f += Distance(pts1[i], pts2[i]);
			d_b += Distance(pts1[i], pts2[(np-1)-i]);
		}
		d = Math.min(d_b, d_f)/np;
		return d ;
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
	}
}