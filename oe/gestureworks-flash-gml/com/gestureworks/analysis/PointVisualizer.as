////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    DebugClusterPoints.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.analysis
{
	
	import com.gestureworks.core.GestureWorks;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import flash.geom.Vector3D;
	import flash.text.*;
	
	import com.gestureworks.managers.MotionPointHistories;
	import com.gestureworks.core.CML;
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.gw_public;
	
	import com.gestureworks.objects.MotionPointObject;
	import com.gestureworks.objects.PointObject;
	import com.gestureworks.objects.ClusterObject;
	
	import com.gestureworks.utils.AddSimpleText;
	


	public class PointVisualizer extends Sprite//Shape//Container
	{
		private static var cml:XMLList;
		public var style:Object; // public allows override of cml values
		private var id:Number = 0;
		
		private var cO:ClusterObject;
		private var ts:Object;
		private var tpn:uint = 0;
		private var mpn:uint = 0;
		private var mptext_array:Array = new Array();
		private var tptext_array:Array = new Array();
		private var i:int
		private var hist:int = 0;
		
		private var _minX:Number = -180;
		private var _maxX:Number = 180;
		
		private var _minY:Number = 75;
		private var _maxY:Number = 270;
		
		private var _minZ:Number = -110;
		private var _maxZ:Number = 200;
		private var trails:Array = [];
		
		public var maxTrails:int = 50;
		public var maxPoints:int = 10;
	
		
		public function PointVisualizer(ID:Number)
		{			
			//trace("points visualizer");	
			id = ID;
			ts = GestureGlobals.gw_public::touchObjects[id];
			cO = ts.cO;
			hist = 8;
			
			
			// set default style 
			style = new Object;
				//points
				style.stroke_thickness = 10;
				//style.stroke_color = 0xFFAE1F;
				//style.stroke_color = 0x107591;
				//style.stroke_color = 0x9BD6EA;
				style.stroke_color = 0xAADDFF;
				style.stroke_alpha = 0.9;
				//style.fill_color = 0xFFAE1F;
				//style.fill_color = 0x107591;
				//style.fill_color = 0x9BD6EA;
				style.fill_color = 0xAADDFF;
				style.fill_alpha = 0.6;
				style.radius = 20;
				style.height = 20;
				style.width = 20;
				style.shape = "circle-fill";
				style.trail_shape = "curve";
				style.motion_text_color = 0x777777;
				style.touch_text_color = 0x000000;
				
		}
		
		public function init():void
		{
			var i:int = 0;
			mptext_array[i];		
			tptext_array = [];
			trails = [];
			
			// create text fields
			for (i = 0; i < maxPoints; i++) 
			{
				mptext_array[i] = new AddSimpleText(500, 100, "left", style.motion_text_color, 12, "left");
					mptext_array[i].visible = false;
					mptext_array[i].mouseEnabled = false;
				tptext_array[i] = new AddSimpleText(200, 100, "left", style.touch_text_color, 12, "left");
					tptext_array[i].visible = false;
					tptext_array[i].mouseEnabled = false;
				addChild(tptext_array[i]);
				addChild(mptext_array[i]);
			}
			
			
			// FIXME: lazy instantiate trails
			for (i = 0; i < maxPoints; i++) { 
				
				trails.push(new Array());
				
				for (var j:int = 0; j < maxTrails; j++) {
					var s:Sprite = new Sprite;
					s.graphics.lineStyle(style.stroke_thickness, style.stroke_color, style.stroke_alpha);							
					s.graphics.beginFill(style.fill_color, style.fill_alpha);
					s.graphics.drawCircle(style.radius+7, style.radius+7, style.radius);
					s.graphics.endFill();		
					//var b:Bitmap = toBitmap(s);
					trails[i].push(s);					
				}
			}
			GestureWorks.application.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function toBitmap(obj:DisplayObject, smoothing:Boolean=true):Bitmap 
		{
			var m:Matrix = new Matrix();
			
			var bmd:BitmapData = new BitmapData(obj.width, obj.height, true, 0x00000000);
			bmd.draw(DisplayObject(obj), m);
			
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = smoothing;
			
			return bitmap;
		}
		
		public function draw():void
		{
			// update data
			//N = cO.pointArray.length;
			tpn = cO.tpn;
			mpn = cO.motionArray2D.length;// only shows when 2d visualizer working  //mpn = cO.mpn;
			
			
			
			// clear graphics
			graphics.clear();
			
			
			// draw
			if (ts.touchEnabled)	draw_touchPoints();
			if (ts.motionEnabled)	draw_motionPoints();
			//if (ts._sensorEnabled)	draw_sensorPoints();
		}
		
		
		////////////////////////////////////////////////////////////
		// touch points
		////////////////////////////////////////////////////////////
		public function draw_touchPoints():void
		{
			// clear text
			for (i = 0; i < maxPoints; i++) tptext_array[i].visible = false;
			
				var n:int = (tpn <= maxPoints) ? tpn : maxPoints;
			
				for (i = 0; i < n; i++) 
				{
					var pt:PointObject = cO.pointArray[i]
					///////////////////////////////////////////////////////////////////
					// Point positons and shapes
					///////////////////////////////////////////////////////////////////
					
					var x:Number = pt.x;
					var y:Number = pt.y;
					
					if (_drawText)
					{
						///////////////////////////////////////////////////////////////////
						//
						///////////////////////////////////////////////////////////////////
						
						tptext_array[i].textCont = "ID: " + String(pt.id); //+ "    id" + String(pt.touchPointID);
						tptext_array[i].x = x - tptext_array[i].width / 2;
						tptext_array[i].y = y - 55;
						tptext_array[i].visible = true;
						tptext_array[i].textColor = style.touch_text_color;
					}
					
					if (_drawShape)
					{
						//////////////////////////////////////////////////////////////////////
						// shape outlines
						//////////////////////////////////////////////////////////////////////
						
						if (style.shape == "square") {
							//trace("square");
								graphics.lineStyle(style.stroke_thickness, style.stroke_color, style.stroke_alpha);
								graphics.drawRect(x-style.width,y-style.width,2*style.width, 2*style.width);
						}
						else if (style.shape == "ring") {
							//trace("ring");
								graphics.lineStyle(style.stroke_thickness, style.stroke_color, style.stroke_alpha);
								graphics.drawCircle(x, y, style.radius);
						}
						else if (style.shape == "cross") {
							//trace("cross");
								graphics.lineStyle(style.stroke_thickness, style.stroke_color, style.stroke_alpha);
								graphics.moveTo (x - style.radius, y);
								graphics.lineTo (x + style.radius , y);
								graphics.moveTo (x, y - style.radius);
								graphics.lineTo (x, y + style.radius);
						}
						else if (style.shape == "triangle") {
							//trace("triangle");
								graphics.lineStyle(style.stroke_thickness, style.stroke_color, style.stroke_alpha);
								graphics.moveTo (x - style.radius, y -style.radius);
								graphics.lineTo (x, style.pointList[i].y + style.radius);
								graphics.lineTo (x + style.radius, y - style.radius);
								graphics.lineTo (x - style.radius, y -style.radius);
							
						}
						//////////////////////////////////////////////////////////////////
						// filled shapes
						//////////////////////////////////////////////////////////////////
						
						else if (style.shape == "circle-fill") {
							//trace("circle draw");
								graphics.lineStyle(style.stroke_thickness, style.stroke_color, style.stroke_alpha);							
								graphics.beginFill(style.fill_color, style.fill_alpha);
								graphics.drawCircle(x, y, style.radius);
								graphics.endFill();
						}
						else if (style.shape == "triangle-fill") {
							//trace("triangle fill");
								graphics.beginFill(style.fill_color, style.fill_alpha);
								graphics.moveTo (x - style.width, y -style.width);
								graphics.lineTo (x, y + style.width);
								graphics.lineTo (x + style.width, y - style.width);
								graphics.lineTo (x - style.width, y -style.width);
								graphics.endFill();
						
						}
						else if (style.shape == "square-fill") {
							//trace("square");
								graphics.beginFill(style.color, style.fill_alpha);
								graphics.drawRect(x - style.width, y - style.width, 2 * style.width, 2 * style.width);
								graphics.endFill();
						}
					
					}
					/////////////////////////////////////////////////////////////////
					// point vectors
					/////////////////////////////////////////////////////////////////
					
					if (_drawVector)
					{
						//define vector point style
						//graphics.lineStyle(style.v_stroke,style.color,style.alpha);
						hist  = pt.history.length - 1;
						if (hist < 0) hist = 0;
						var alpha:Number = 0;
						var k:int = 0;
						
							if (style.trail_shape == "line") {
								
										alpha = 0.08*(hist-j)
										graphics.lineStyle(style.stroke_thickness, style.stroke_color, alpha);
										graphics.moveTo(pt.history[0].x, pt.history[0].y);
										graphics.lineTo(pt.history[hist].x,pt.history[hist].y);
									
							}
							else if (style.trail_shape == "curve") {
								
								for (var j:int = 0; j < hist; j++) 
								{
									if (j + 1 <= hist) {
										alpha = 0.08 * (hist - j)
										graphics.lineStyle(style.stroke_thickness, style.stroke_color, alpha);
										graphics.moveTo(pt.history[j].x, pt.history[j].y);
										graphics.lineTo(pt.history[j + 1].x, pt.history[j + 1].y);
									}
								}
							}
							else if (style.trail_shape == "ring") {
									
								for (k=0; k < hist; k++) 
								{
									alpha = 0.08 * (hist - j)
									graphics.lineStyle(style.stroke_thickness, style.stroke_color,alpha);
									graphics.drawCircle(pt.history[j].x, pt.history[j].y, style.radius);									
								}
							}
							else if (style.trail_shape == "curve") {
									
								for (k=0; k < hist; k++) 
								{
									alpha = 0.08 * (hist - j)
									graphics.lineStyle(style.stroke_thickness, style.stroke_color,alpha);
									graphics.drawCircle(pt.history[j].x, pt.history[j].y, style.radius);									
								}
							}	
							else if (style.trail_shape == "circle-fill") {
									
								var num:int = (hist <= maxTrails) ? hist : maxTrails;
								
								for (k=0; k < num; k++) 
								{										
									trails[i][k].x = pt.history[k].x - style.radius+3; 
									trails[i][k].y = pt.history[k].y - style.radius+3;
									trails[i][k].alpha = 1;
									if (parent) {
										parent.addChild(trails[i][k]);	
										parent.addChildAt(this, parent.numChildren - 1);		
									}
								}
							}								
						}
						///////////////////////////////////////////////////////////////////////
						
					}
		}		
			
		private function onEnterFrame(e:Event):void
		{
			for (var i:int = 0; i < trails.length; i++) {
				for (var j:int = 0; j < trails[i].length; j++) {
					trails[i][j].alpha -=  0.8;

					if (trails[i][j].alpha <= 0) {
						if (trails[i][j].parent)
							trails[i][j].parent.removeChild(trails[i][j]);
					}
				}	
			}
		}
				
		
		
		/////////////////////////////////////////////////////////////////////
		// motion points
		///////////////////////////////////////////////////////////////////
		
		private function draw_motionPoints():void
		{
					// clear text
					if (_drawText)	for (i = 0; i < maxPoints; i++) mptext_array[i].visible = false;
				
					//trace("mpn",mpn)
						
					// Calculate the hand's average finger tip position
					for (i = 0; i < mpn; i++) 
								{
								var mp:MotionPointObject = cO.motionArray2D[i];
									
									if (mp.type == "finger")
									{
										var zm:Number = mp.position.z * 0.2;
										var wm:Number = (mp.width) *10;
										//trace("length", finger.length);
										//trace("width", finger.width);

											if (_drawShape)
											{
												if (mp.fingertype == "thumb") 
												{
													//  draw finger point 
													graphics.lineStyle(4, 0xFF0000, style.stroke_alpha);
													graphics.drawCircle(mp.position.x ,mp.position.y, style.radius + 20 + zm);	
													
													graphics.beginFill(0xFF0000, style.fill_alpha);
													graphics.drawCircle(mp.position.x, mp.position.y, style.radius);
													graphics.endFill();
												}
												
												else
												{
													//  draw finger point 
													graphics.lineStyle(4, 0x6AE370, style.stroke_alpha);
													graphics.drawCircle(mp.position.x ,mp.position.y, style.radius + 20 + zm);	
													graphics.beginFill(0x6AE370, style.fill_alpha);
													graphics.drawCircle(mp.position.x, mp.position.y, style.radius);
													graphics.endFill();
												}
											}
											
											/*
											if (_drawText)
											{
												//drawPoints ID of point
												mptext_array[i].x = mp.position.x + 50;
												mptext_array[i].y = mp.position.y - 50;
												mptext_array[i].visible = true;
												mptext_array[i].textCont = String(mp.fingertype) + ": ID:" + String(mp.motionPointID) + "\n"
																		+ "Thumb prob: " + (Math.round(1 * mp.thumb_prob)) +  "\n" 
																		+ "N length: " + (Math.round(100 * mp.normalized_length)) * 0.01 + " length: " + (Math.round(mp.length)) + "\n"
																		+ "N palm angle: " + (Math.round(100 * mp.normalized_palmAngle)) * 0.01 + " palm angle: " + (Math.round(100 * mp.palmAngle)) * 0.01 +"\n"
																		+ "max_length: " + Math.round(mp.max_length) + " min_length: "+ Math.round(mp.min_length) + " length: "+ Math.round(mp.length) + " Extension: " + mp.extension + "%"; 
																		//" width: "+ Math.round(100*mp.width)*0.01 +
											}	*/
									}
									
									
									if (mp.type == "palm")
									{
										////////////////////////////////////////////////////
										//// draw hand data
										////////////////////////////////////////////////////
										if (_drawShape)
											{
												// palm center
												graphics.lineStyle(2, 0xFFFFFF, style.stroke_alpha);
												graphics.drawCircle(mp.position.x, mp.position.y, style.radius+10+ mp.position.z * 0.2);
												graphics.beginFill(0xFFFFFF, style.fill_alpha);
												graphics.drawCircle(mp.position.x, mp.position.y, style.radius-10);
												graphics.endFill();
												
												//normal
												graphics.lineStyle(2, 0xFF0000, style.stroke_alpha);
												graphics.moveTo(mp.position.x,mp.position.y);
												graphics.lineTo(mp.position.x + 50*mp.normal.x, mp.position.y + 50*mp.normal.y);
											}
											
											/*
											if (_drawText)
											{
												//drawPoints ID of point
												mptext_array[i].textCont = "Palm: " + "ID" + String(mp.motionPointID) + "    id" + String(mp.id);
												mptext_array[i].x = mp.position.x;
												mptext_array[i].y = mp.position.y - 50;
												mptext_array[i].visible = true;
											}*/
									}
								}
					
		}

		
		
		////////////////////////////////////////////////////////////////
		// sensor points // eye tracking / accelerometer / myo
		////////////////////////////////////////////////////////////////
		private function draw_sensorPoints():void
			{
			// draw virtual accelerometer point
			
				// draw shape
				// draw vector
				
				// triangle ???
				// square ?? 
				// cross ??
			}

	
		public function clear():void
		{
			//trace("trying to clear");
			graphics.clear();
		
			//text clear
			for (i = 0; i < tptext_array.length; i++){
				tptext_array[i].visible = false;
			}
			for (i = 0; i < mptext_array.length; i++){
				mptext_array[i].visible = false;
			}			
		}
	
	
		public static function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number
		{
			if (constrainMin && num < min1) return min2;
			if (constrainMax && num > max1) return max2;
		 
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
			if (round) return Math.round(num2);
			return num2;
		}	
		
		private function normalize(value : Number, minimum : Number, maximum : Number) : Number 
		{
            return (value - minimum) / (maximum - minimum);
        }
		
	

	private var _drawShape:Boolean = true;
	/**
	* activates gesture point shape visualization methods.
	*/
	public function get drawShape():Boolean { return _drawShape; }
	public function set drawShape(value:Boolean):void { _drawShape = value; }
	

	private var _drawVector:Boolean = false;
	/**
	* activates gesture point shape visualization methods.
	*/
	public function get drawVector():Boolean { return _drawVector; }
	public function set drawVector(value:Boolean):void { _drawVector = value; }
	

	private var _drawText:Boolean = true;
	/**
	* activates gesture point shape visualization methods.
	*/
	public function get drawText():Boolean { return _drawText; }
	public function set drawText(value:Boolean):void{_drawText = value;}


}
}