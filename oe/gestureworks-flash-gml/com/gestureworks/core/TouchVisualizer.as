////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TouchSpriteDebugDisplay.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.core
{
	import flash.events.Event;
	import flash.display.Sprite;
	
	import com.gestureworks.analysis.PointVisualizer;
	import com.gestureworks.analysis.ClusterVisualizer;
	import com.gestureworks.analysis.GestureVisualizer;
	
	import com.gestureworks.managers.ClusterHistories;
	import com.gestureworks.managers.TransformHistories;

	public class TouchVisualizer
	{
		/**
		* @private
		*/
		public var ts:*;//TouchSprite;
		/**
		* @private
		*/
		private var id:uint
		/**
		* displays touch cluster and gesture visulizations on the touchSprite.
		*/
		public var debug_display:Sprite;
		/**
		* @private
		*/
		public var point:PointVisualizer;
		/**
		* @private
		*/
		public var cluster:ClusterVisualizer;
		/**
		* @private
		*/
		public var gesture:GestureVisualizer;
		/**
		* @private
		*/
		private var viewAlwaysOn:Boolean = false;
		/**
		* @private
		*/
		private var _pointDisplay:Boolean = true;
		/**
		* activates point visualization methods.
		*/
		public function get pointDisplay():Boolean { return _pointDisplay; }
		public function set pointDisplay(value:Boolean):void{_pointDisplay = value;}
		/**
		* @private
		*/
		private var _clusterDisplay:Boolean = true;
		/**
		* activates cluster visualization methods.
		*/
		public function get clusterDisplay():Boolean { return _clusterDisplay; }
		public function set clusterDisplay(value:Boolean):void { _clusterDisplay = value; }
		/**
		* @private
		*/
		private var _gestureDisplay:Boolean = true;
		/**
		* activates gesture visualization methods.
		*/
		public function get gestureDisplay():Boolean { return _gestureDisplay; }
		public function set gestureDisplay(value:Boolean):void{_gestureDisplay = value;}

		
		public function TouchVisualizer(touchObjectID:int):void
		{
			id = touchObjectID;
        }
		  
		private var _activated:Boolean = false;
		/**
		 * Lazy activation
		 */
		private function get activated():Boolean { return _activated; }
		private function set activated(a:Boolean):void {
			if (!_activated && a) {
				_activated = true;
			}
		}		
		  
		// initializers    
        public function initDebug():void 
        {
			if (!activated) {
				activated = true;
				
				if (GestureGlobals.gw_public::touchObjects[id])
					ts = GestureGlobals.gw_public::touchObjects[id];			
				//trace("create touchsprite debug display")

				debug_display = new Sprite();
				//initDebugVars();
				initDebugDisplay();
				
				if (ts.stage) addtostage();
				else ts.addEventListener(Event.ADDED_TO_STAGE, addtostage);
			}
		}
		
		 public function addtostage(e:Event = null):void 
        {
			//trace("added to stage debug")
			ts.stage.addChild(debug_display);
		}
		
		public function initDebugVars():void
		{
			//if (traceDebugMode) 
			//trace("init debug cml vars");
			//trace(_pointData,_panelData,_touchObjectData)
			
			//ts.debugDisplay = true;
			//viewAlwaysOn = true;
			//pointDisplay = true;
			//clusterDisplay = true;
			//gestureDisplay = true;
		
		
		/*
		if (CML.Objects != null) 
		{
			ts.cml = new XMLList(CML.Objects)
			var numLayers:int = ts.cml.DebugKit.DebugLayer.length()
				
				ts.debugDisplay = ts.cml.DebugKit.attribute("displayOn") == "true" ?true:false;
				viewAlwaysOn = ts.cml.DebugKit.attribute("displayAlwaysOn") == "true" ?true:false;
			
			for (var i:int = 0; i < numLayers; i++) {
				var type:String = ts.cml.DebugKit.DebugLayer[i].attribute("type")
			
				if (type == "point") pointDisplay = true//ts.cml.DebugKit.DebugLayer[i].attribute("displayOn") == "true" ?true:false;
				if (type == "cluster") clusterDisplay = true//ts.cml.DebugKit.DebugLayer[i].attribute("displayOn") == "true" ?true:false;
				if (type == "gesture") gestureDisplay = true//ts.cml.DebugKit.DebugLayer[i].attribute("displayOn")== "true" ?true:false;
			}
		}
		*/
		
	}
	public function initDebugDisplay():void 
	{
		//if (traceDebugMode) trace("init debug display",touchObjectID);
					
			if (ts.debugDisplay)
			{		
					/////////////////////////////////////////////////////////////////
					// point display
					/////////////////////////////////////////////////////////////////
					if (pointDisplay) 
					{
						point = new PointVisualizer(id);
							point.init();
						debug_display.addChild(point);
					}
					
					////////////////////////////////////////////////////////////////////
					// cluster display
					////////////////////////////////////////////////////////////////////
					if (clusterDisplay) 
					{	
						cluster = new ClusterVisualizer(id);
							cluster.init();
						debug_display.addChild(cluster);
						
						// NOTE ADD CLUSTER VECTORS
					}
					
					////////////////////////////////////////////////////////////////////////
					//  gesture touch object display
					////////////////////////////////////////////////////////////////////////
					if (gestureDisplay)
					{	
						gesture = new GestureVisualizer(id);
							gesture.init();
						debug_display.addChild(gesture);
					}
			}
	}
			
	/**
	* @private
	*/
	public function drawDebugDisplay():void
	{
		//trace("trying to draw display",ts.debugDisplay,debug_display);
		if ((ts.debugDisplay)&&(debug_display))
			{
			// touch points or interaction points
			// REMOVE MPN WHEN TESTING COMPLETE
			if ((ts.N)||(ts.mpn)||(ts.ipn))//ts.cO.sn //ts.cO.fn
			{
				if ((pointDisplay)&&(point)) 		point.draw();
				if ((clusterDisplay)&&(cluster))	cluster.draw();
				if ((gestureDisplay)&&(gesture)) 	gesture.draw();
				
			}
		}
	}
	/**
	* @private
	*/
	public function clearDebugDisplay():void
	{
		//if(traceDebugMode) trace("trying to clear debug display",touchObjectID)
		if ((ts.debugDisplay)&&(debug_display))
		{
			if (point) 	point.clear();
			if (cluster) cluster.clear();
			if (gesture) gesture.clear();
		}
	}
	/**
	* @private
	*/
	public function updateDebugDisplay():void
	{
		if (debug_display)
			{
			clearDebugDisplay();
			drawDebugDisplay();
			}
	}
	//////////////////////////////////////////////////////////////////////////////////////////	
	
	}
}