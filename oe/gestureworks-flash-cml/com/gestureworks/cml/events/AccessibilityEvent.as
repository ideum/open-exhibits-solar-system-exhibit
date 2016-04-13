package com.gestureworks.cml.events {
	import flash.events.Event;
	
	public class AccessibilityEvent extends Event {
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Next", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Previous", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Back", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Select", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Help", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Home", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Activate", type = "com.gestureworks.cml.events.AccessibilityEvent")]
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_OverlayActivated", type = "com.gestureworks.cml.events.AccessibilityEvent")]
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Deactivate", type = "com.gestureworks.cml.events.AccessibilityEvent")]
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccessibilityEvent_Release", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "InaccessibleMenu_Item", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		/// @eventType	com.gestureworks.cml.events.AccessibilityEvent
		[Event(name = "AccText_Complete", type = "com.gestureworks.cml.events.AccessibilityEvent")] 
		
		public static const NEXT:String = "AccessibilityEvent_Next";
		public static const PREVIOUS:String = "AccessibilityEvent_Previous";
		public static const BACK:String = "AccessibilityEvent_Back";
		public static const SELECT:String = "AccessibilityEvent_Select";
		public static const HELP:String = "AccessibilityEvent_Help";
		public static const HOME:String = "AccessibilityEvent_Home";
		public static const ACTIVATE:String = "AccessibilityEvent_Activate";
		public static const OVERLAY_ACTIVATED:String = "AccessibilityEvent_OverlayActivated";
		public static const DEACTIVATE:String = "AccessibilityEvent_Deativate";
		public static const ACTIVATE_RELEASE:String = "AccessibilityEvent_Release";
		public static const INACCESSIBLE_ITEM:String = "InaccessibleMenu_Item";
		
		// used for dynamic accessibility text generation
		public static const ACC_TEXT_COMPLETE:String = "AccText_Complete";
		public static const ACC_DEFAULTS_COMPLETE:String = "AccDefaults_Complete";
		
		public function AccessibilityEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event { 
			return new AccessibilityEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("AccessibilityEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}