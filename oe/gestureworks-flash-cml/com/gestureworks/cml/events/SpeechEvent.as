package com.gestureworks.cml.events {
	import com.gestureworks.cml.accessibility.AccessibilityController;
	import flash.events.Event;
	
	public class SpeechEvent extends Event {
		/// @eventType	com.gestureworks.cml.events.SpeechEvent
		[Event(name = "SpeechEvent_Start", type = "com.gestureworks.cml.events.SpeechEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.SpeechEvent
		[Event(name = "SpeechEvent_Stop", type = "com.gestureworks.cml.events.SpeechEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.SpeechEvent
		[Event(name = "SpeechEvent_Complete", type = "com.gestureworks.cml.events.SpeechEvent")] 
		
		public static const START:String = "SpeechEvent_Start";
		public static const STOP:String = "SpeechEvent_Stop";
		public static const COMPLETE:String = "SpeechEvent_Complete";		
		
		public static var events:Vector.<String> = new <String>[START, STOP, COMPLETE];
		
		private var _userId:String;
		private var _duration:Number; 
		
		public function SpeechEvent(type:String, userId:String, duration:Number = 0.0, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);	
			this._userId = userId;
			this._duration = duration;
		} 
		
		public function get userId():String { return _userId; }
		
		public function get duration():Number { return _duration; }
		
		public override function clone():Event { 
			return new SpeechEvent(type, _userId, _duration, bubbles, cancelable); 
		} 
		
		public override function toString():String { 
			return formatToString("SpeechEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}