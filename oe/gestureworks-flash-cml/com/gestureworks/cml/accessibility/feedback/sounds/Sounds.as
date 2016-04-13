package com.gestureworks.cml.accessibility.feedback.sounds {

	import com.gestureworks.cml.accessibility.feedback.IFeedback;
	import com.gestureworks.cml.accessibility.PrebuiltText;
	import com.gestureworks.cml.events.AccessibilityEvent;
	
	/**
	 * ...
	 * @author Ken Willes
	 */
	public class Sounds implements IFeedback {

		//Sound delegates
		private var _sounds:Array; 
		private var _lastEvent:String;
		
		public function Sounds() {
			
			_sounds = new Array();
			
			_sounds.push( { sound:new Activate(), event:PrebuiltText.INTRO_HELPER_TEXT } );
			_sounds.push( { sound:new Deactivate(), event:PrebuiltText.OUTRO_DEACTIVATING } );
			_sounds.push( { sound:new InaccessibleMenuItem(), event:AccessibilityEvent.INACCESSIBLE_ITEM } );
			_sounds.push( { sound:new TriggerMenu(), event:AccessibilityEvent.SELECT } );
			_sounds.push( { sound:new Swipe(), event:AccessibilityEvent.NEXT } );
			_sounds.push( { sound:new Swipe(), event:AccessibilityEvent.PREVIOUS} );
			
			_lastEvent = "";
			
		}
		
		/**
		 * Play sounds that match the event type
		 * @param	item
		 */
		public function start(item:String):void {
			
			for each (var i:Object in _sounds) {
				if (i.event == item) { 
					i.sound.start(item);
					//break;
				}
			}
			
			_lastEvent = item;
			
		}
		
		/**
		 * Only cancel certain sounds. Most of the sounds are really short anyways. Will need to mitigate this later on.
		 * Everytime speech ends, this method gets called from Accessibility.as
		 */
		public function cancel():void {
			
			for each (var i:Object in _sounds) {
				if (i.event == PrebuiltText.INTRO_HELPER_TEXT || i.event == PrebuiltText.OUTRO_DEACTIVATING) { 
					i.sound.cancel();
					//break;
				}
			}
			
		}
		
	}
	
}