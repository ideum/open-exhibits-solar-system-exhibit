////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GWTouchEvent.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.events
{
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.interfaces.ITouchObject;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.utils.MousePoint;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.utils.*;
	import org.tuio.TuioTouchEvent;

	public class GWTouchEvent extends TouchEvent
	{		
		private var sourceEvent:Event;
		
		public static const TOUCH_BEGIN : String = "gwTouchBegin";
		public static const TOUCH_END : String = "gwTouchEnd"
		public static const TOUCH_MOVE : String = "gwTouchMove"
		public static const TOUCH_OUT : String = "gwTouchOut"
		public static const TOUCH_OVER : String = "gwTouchOver"
		public static const TOUCH_ROLL_OUT : String = "gwTouchRollOut"
		public static const TOUCH_ROLL_OVER : String = "gwTouchRollOver"
		public static const TOUCH_TAP : String = "gwTouchTap";
		
		private static var TOUCH_TYPE_MAP: Dictionary = new Dictionary(); 
		
 		TOUCH_TYPE_MAP[TouchEvent] = new Dictionary();
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_BEGIN] = TOUCH_BEGIN;		
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_END] = TOUCH_END;		
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_MOVE] = TOUCH_MOVE;		
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_OUT] = TOUCH_OUT;		
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_OVER] = TOUCH_OVER;		
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_ROLL_OUT] = TOUCH_ROLL_OUT;		
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_ROLL_OVER] = TOUCH_ROLL_OVER;		
 		TOUCH_TYPE_MAP[TouchEvent][TouchEvent.TOUCH_TAP] = TOUCH_TAP;		
 		
 		TOUCH_TYPE_MAP[TuioTouchEvent] = new Dictionary();
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.TOUCH_DOWN] = TOUCH_BEGIN;		
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.TOUCH_UP] = TOUCH_END;		
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.TOUCH_MOVE] = TOUCH_MOVE;		
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.TOUCH_OUT] = TOUCH_OUT;		
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.TOUCH_OVER] = TOUCH_OVER;		
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.ROLL_OUT] = TOUCH_ROLL_OUT;		
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.ROLL_OVER] = TOUCH_ROLL_OVER;		
 		TOUCH_TYPE_MAP[TuioTouchEvent][TuioTouchEvent.TAP] = TOUCH_TAP;		
 		
 		TOUCH_TYPE_MAP[MouseEvent] = new Dictionary();
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.MOUSE_DOWN] = TOUCH_BEGIN;		
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.MOUSE_UP] = TOUCH_END;		
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.MOUSE_MOVE] = TOUCH_MOVE;		
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.MOUSE_OUT] = TOUCH_OUT;		
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.MOUSE_OVER] = TOUCH_OVER;		
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.ROLL_OUT] = TOUCH_ROLL_OUT;		
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.ROLL_OVER] = TOUCH_ROLL_OVER;								
 		TOUCH_TYPE_MAP[MouseEvent][MouseEvent.CLICK] = TOUCH_TAP;								
		
		/**
		 * Serves as an encompassing touch event for all input types as well as a utility for converting different input events. The <code>GWTouchEvent</code> can 
		 * be used as a proxy for the TouchEvent instances to bypass read-only accessor permissions (e.g. stageX and stageY). 
		 * @param	event  the event to convert 
		 * @param	type  the input event type to be evaluated and converted to a GWTouchEvent 
		 * @param	bubbles  
		 * @param	cancelable
		 * @param	touchPointID
		 * @param	isPrimaryTouchPoint
		 * @param	localX
		 * @param	localY
		 * @param	sizeX
		 * @param	sizeY
		 * @param	pressure
		 * @param	relatedObject
		 * @param	ctrlKey
		 * @param	altKey
		 * @param	shiftKey
		 */
		public function GWTouchEvent(event:Event = null, type:String = "touchBegin", bubbles:Boolean=true, cancelable:Boolean=false, touchPointID:int=0, isPrimaryTouchPoint:Boolean=false, localX:Number=NaN, localY:Number=NaN, sizeX:Number=NaN, sizeY:Number=NaN, pressure:Number=NaN, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false)
		{
			super(resolveType(type), bubbles, cancelable, touchPointID, isPrimaryTouchPoint, localX, localY, sizeX, sizeY, pressure, relatedObject, ctrlKey, altKey, shiftKey);
			if(event)
				importEvent(event);
			_time = getTimer();
		}
		
		private var _bubbles:Boolean;
		public function set bubbles(v:Boolean):void { _bubbles = bubbles; }
		override public function get bubbles():Boolean { return _bubbles; }
		
		private var _cancelable:Boolean;
		public function set cancelable(v:Boolean):void { _cancelable = v; }
		override public function get cancelable():Boolean { return _cancelable; }
		
		private var _currentTarget:Object;
		public function set currentTarget(v:Object):void { _currentTarget = v; }
		override public function get currentTarget():Object { return _currentTarget; }
		
		private var _eventPhase:uint;
		public function set eventPhase(v:uint):void { _eventPhase = v; }
		override public function get eventPhase():uint { return _eventPhase; }
		
		private var _target:Object;
		public function set target(v:Object):void { _target = v; }
		override public function get target():Object { return _target; }
		
		private var _originator:Object;
		public function get originator():Object { return _originator; }
		
		private var _type:String;
		public function set type(v:String):void { _type = v; }
		override public function get type():String { return _type; }
			
		private var _stageX:Number=0;
		public function set stageX(v:Number):void { _stageX = v;}
		override public function get stageX():Number { return _stageX; }
		
		private var _stageY:Number=0;
		public function set stageY(v:Number):void { _stageY = v;}
		override public function get stageY():Number { return _stageY; }
		
		private var _stageZ:Number=0;
		public function set stageZ(v:Number):void { _stageZ = v;}
		public function get stageZ():Number { return _stageZ; }				
		
		private var _source:Class;
		/**
		 * The derrived event type
		 */
		public function set source(v:Class):void { _source = v; }
		public function get source():Class { return _source; }		
		
		private var _time:Number;
		/**
		 * Time of instantiation
		 * _time is initialized on object creation, no need for a set.
		 */
		public function get time():Number { return _time;}

		private var _view:DisplayObjectContainer;
		/**
		 * The main view or display object in which the touch event took place. 
		 * Used for Away3D compatibility. 
		 */
		public function set view(v:DisplayObjectContainer):void { _view = v;}
		public function get view():DisplayObjectContainer { return _view; }			
		
		override public function clone():Event
		{
			return new GWTouchEvent(sourceEvent, type, bubbles, cancelable, touchPointID, isPrimaryTouchPoint, localX, localY, sizeX, sizeY, pressure, relatedObject, ctrlKey, altKey, shiftKey);
		}
		
		/**
		 * Converts the event to a GWTouchEvent by synchronizing the properties
		 * @param	event
		 */
		private function importEvent(event:Event):void
		{ 
			sourceEvent = event;
			_originator = event.target;
			source = getDefinitionByName(getQualifiedClassName(event)) as Class;
			var sourceInfo:XML = describeType(event);
			var prop:XML;
			var propName:String;
			var eventType:Class = Class(getDefinitionByName(getQualifiedClassName(event)));
			
			if (eventType == MouseEvent)
				touchPointID = MousePoint.getID();
			else if (eventType == TuioTouchEvent)
				touchPointID = TuioTouchEvent(event).tuioContainer.sessionID;

			for each(prop in sourceInfo.accessor) {
				propName = String(prop.@name);
				
				if (this.hasOwnProperty(propName))
				{
					if (propName == "type") { 
						this[propName] = TOUCH_TYPE_MAP[eventType][event[propName]];						
					}
					else
						this[propName] = event[propName];
				}
			}	
		}
		
		/**
		 * Translate touch type to GWTouchEvent type. 
		 * @param	type  TUIO, native touch, mouse, or GWTouchEvent
		 * @return
		 */
		private function resolveType(type:String):String
		{
			var key:Class = hasKey(TOUCH_TYPE_MAP[TuioTouchEvent], type) ? TuioTouchEvent : hasKey(TOUCH_TYPE_MAP[TouchEvent], type) ? TouchEvent : hasKey(TOUCH_TYPE_MAP[MouseEvent], type) ? MouseEvent : null;
			var resolvedType:String = key && hasKey(TOUCH_TYPE_MAP[key], type) ? TOUCH_TYPE_MAP[key][type]: type;
			this.type = resolvedType;
			_source = key;
			return resolvedType;
		}
		
		/**
		 * Translate GWTouchEvent to appropriate touch type.
		 * @param	type  The type to translate to input types
		 * @param   target The target to check for local overrides
		 * @return An array of activated input types
		 */
		public static function eventTypes(type:String, target:ITouchObject = null):Array
		{
			var types:Array = [];
			var active:Boolean;
			
			active = target && target.localModes ? target.tuio : GestureWorks.activeTUIO;
			if (active)
				types.push(correspondingType(TuioTouchEvent, type));
				
			active = target && target.localModes ? target.nativeTouch: GestureWorks.activeNativeTouch;				
			if (active)
				types.push(correspondingType(TouchEvent, type));
				
			active = target && target.localModes ? target.simulator : GestureWorks.activeSim;				
			if (active)
				types.push(correspondingType(MouseEvent, type));
				
			return types;
		}		
		
		/**
		 * Determines if the provided type is a GWTouchEvent type
		 * @param	type
		 * @return
		 */
		public static function isType(type:String):Boolean {
			var prop:XML;
			for each(prop in describeType(GWTouchEvent).constant) {
				if (GWTouchEvent[prop.@name] == type)
					return true;
			}
			return false;
		}
		
		/**
		 * Determines if a dictionary contains the provided key 
		 * @param	dict The dictionary to search
		 * @param	check The key to search for 
		 */
		private static function hasKey(dict:Dictionary, check:String):Boolean {
			var key:String;
			for (key in dict) {
				if (check == key)
					return true;
			}
			return false;
		}
		
		/**
		 * Retrieves the input(Touch, Tuio, or Mouse) event type corresponding to the GWTouchEvent type
		 * @param	inputEvent Input event (TuioTouchEvent, TouchEvent, or MouseEvent)
		 * @param	gwType The GWTouchEvent type to match 
		 * @return  The corresponding event type
		 */
		private static function correspondingType(inputEvent:Class, gwType:String):String {
			var inputType:String;
			for (inputType in TOUCH_TYPE_MAP[inputEvent]) {
				if (gwType == TOUCH_TYPE_MAP[inputEvent][inputType])
					return inputType;
			}
			return null;
		}
		
	}
}