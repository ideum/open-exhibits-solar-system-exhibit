////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    MouseManager.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.managers
{
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.interfaces.ITouchObject;
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.managers.TouchManager;
	import com.gestureworks.utils.SimulatorGraphic;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	
	public class MouseManager
	{
		private static var currentMousePoint:int;
		private static var mousePointX:Number = 0;
		private static var mousePointY:Number = 0;
		private static var hold:Boolean;
		private static var allowMouseStartDrag:Boolean = false;
		private static var circleGraphics:Array = [];
		private static var _overlays:Vector.<ITouchObject> = new Vector.<ITouchObject>();	
		
		/**
		 * Sets the simulator graphic color.
		 * @default 0xFFAE1F
		 */
		public static var graphicColor:uint = 0xFFAE1F;
		
		/**
		 * Sets the simulator graphic alpha.
		 * @default 1.0
		 */
		public static var graphicAlpha:Number = 1;
		
		/**
		 * Sets the simulator graphic radius
		 * @default 15
		 */
		public static var graphicRadius:Number = 15;
				
		
		// initialization method, call through to TouchManager
		gw_public static function initialize():void
		{	
			GestureWorks.application.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			GestureWorks.application.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			TouchManager.gw_public::initialize();
		}
		
		gw_public static function deInitialize():void
		{
			GestureWorks.application.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			GestureWorks.application.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			GestureWorks.application.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, mouseFrameHandler);
			for (var i:int = circleGraphics.length - 1; i >= 0; i--)
				removeSimulatorPoint(circleGraphics[i]);
			circleGraphics = [];
		}
		
		private static function onMouseDown(e:MouseEvent):void 
		{	
			GestureWorks.application.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, mouseFrameHandler);							
			
			var event:GWTouchEvent = new GWTouchEvent(e);						
			if (TouchManager.validTarget(event)) {				
				TouchManager.onTouchDown(event);			
				currentMousePoint = event.touchPointID;
				mousePointX = event.stageX;
				mousePointY = event.stageY;		
			}
			if (overlays.length) {
				currentMousePoint = event.touchPointID;
				mousePointX = event.stageX;
				mousePointY = event.stageY;
				TouchManager.processOverlays(event, overlays);
			}
		}
		
		private static function onMouseUp(e:MouseEvent):void
		{
			if (hold)
			{
				if (GestureWorks.isShift) 
				{
					if (e.target.toString() == "[object SimulatorGraphic]")
						removeSimulatorPoint(e.target as SimulatorGraphic);
				}
				else
				{
					if (allowMouseStartDrag)
					{
						if (e.target.toString() == "[object SimulatorGraphic]")
						{
							e.target.stopDrag();
							GestureWorks.application.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						}
					}
				}				
				hold = false;
				return;
			}
			
			GestureWorks.application.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, mouseFrameHandler);
			
			if (GestureWorks.isShift)
			{
				var circleGraphic:SimulatorGraphic = new SimulatorGraphic(graphicColor, graphicRadius, graphicAlpha);
					circleGraphic.x = mousePointX;
					circleGraphic.y = mousePointY;
					circleGraphic.id = currentMousePoint
					circleGraphic.addEventListener(MouseEvent.MOUSE_DOWN, simulatorGraphicPoint);
				circleGraphics.push(circleGraphic);
				GestureWorks.application.addChild(circleGraphic);
				
				return;
			}
			
			var event:GWTouchEvent = new GWTouchEvent(e);
			event.touchPointID = currentMousePoint;
			TouchManager.onTouchUp(event);
			
			if (overlays.length) {
				TouchManager.processOverlays(event, overlays);
			}
		}
		
		private static function removeSimulatorPoint(simPoint:SimulatorGraphic):void {
			GestureWorks.application.removeChild(simPoint as DisplayObject);
			circleGraphics.splice(circleGraphics.indexOf(simPoint), 1);
			var eventHere:GWTouchEvent = new GWTouchEvent(null, GWTouchEvent.TOUCH_MOVE, true, false, simPoint.id, false);
			eventHere.stageX = mousePointX;
			eventHere.stageY = mousePointY;
			TouchManager.onTouchUp(eventHere);			
		}
		
		private static function simulatorGraphicPoint(event:MouseEvent):void
		{
			hold = true;
			if (!allowMouseStartDrag) return;
			
			event.target.startDrag();
			GestureWorks.application.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private static function onMouseMove(e:MouseEvent):void
		{
			if (GestureWorks.isShift) return;
			mousePointX = e.stageX;
			mousePointY = e.stageY;
		}
		
		private static function mouseFrameHandler(e:Event):void
		{
			var event:GWTouchEvent = new GWTouchEvent(null, GWTouchEvent.TOUCH_MOVE, true, false, currentMousePoint, false);			
			event.stageX = mousePointX;
			event.stageY = mousePointY;
			TouchManager.onTouchMove(event);
			
			if (overlays.length) {
				TouchManager.processOverlays(event, overlays);
			}
		}
		
		/**
		 * Registers global overlays to receive point data for mouse input
		 */
		public static function get overlays():Vector.<ITouchObject> { return _overlays; }
		public static function set overlays(o:Vector.<ITouchObject>):void {
			_overlays = o;
		}	
	}
}