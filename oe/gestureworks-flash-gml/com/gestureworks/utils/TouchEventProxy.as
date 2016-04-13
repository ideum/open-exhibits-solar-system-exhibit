package com.gestureworks.utils
{
	//import com.gestureworks.interfaces.ITouchObject;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.TouchEvent;
	import flash.utils.*;
	/**
	 * ...
	 * @author 
	 */
	public class TouchEventProxy
	{
		public var controlKey:Boolean;
		
		public var type:String;
		public var bubbles:Boolean;
		public var cancelable:Boolean;
		public var touchPointID:int;
		public var isPrimaryTouchPoint:Boolean;
		public var localX:Number;
		public var localY:Number;
		public var isRelatedObjectInaccessible:Boolean;
		public var sizeX:Number;
		public var sizeY:Number;
		public var pressure:Number;

		public var stageX:int;
		public var stageY:int;
		public var time:uint;
		public var timestamp:Number;
		public var dtime:Number = 0;
		public var frame:int = 1;
		
		public function TouchEventProxy (e:TouchEvent=null) {
				
			if (!e) return;
			
			this.type = e.type;
			this.bubbles = e.bubbles;
			this.cancelable = e.cancelable;
			this.touchPointID = e.touchPointID;
			this.isPrimaryTouchPoint = e.isPrimaryTouchPoint;
			this.localX = e.localX;
			this.localY = e.localY;
			this.sizeX = e.sizeX;
			this.sizeY = e.sizeY;
			this.pressure = e.pressure;
			this.stageX = e.stageX;
			this.stageY = e.stageY;
				
			//var now:Date = new Date();
			//this.timestamp = now.valueOf();
		}
			
		public function asTouchEvent():TouchEvent {
			return new TouchEvent(this.type, this.bubbles, this.cancelable, this.touchPointID, this.isPrimaryTouchPoint, 
			this.localX, this.localY, this.sizeX, this.sizeY);
		}
		
		public function asGWTouchEvent():GWTouchEvent {
			return new GWTouchEvent();
		}
			
	}

}