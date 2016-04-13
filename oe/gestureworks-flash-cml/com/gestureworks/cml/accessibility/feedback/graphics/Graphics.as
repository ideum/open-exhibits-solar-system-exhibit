package com.gestureworks.cml.accessibility.feedback.graphics {

	import com.gestureworks.cml.accessibility.AccessibilityController;
	import com.gestureworks.cml.accessibility.feedback.IFeedback;
	import com.gestureworks.cml.accessibility.PrebuiltText;
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.events.AccessibilityEvent;
	import flash.display.Stage;

	/**
	 * ...
	 * @author Ken Willes
	 */
	public class Graphics implements IFeedback {
		
		private var context:Container;
		private var _graphics:Array;
		private var _lastEvent:String;
		private var _stage:Stage;
		
		private var _isTTSActive:Boolean;
		public function get isTTSActive():Boolean { return _isTTSActive; }		
		public function set isTTSActive(value:Boolean):void {
			_isTTSActive = value;
		}
		
		/**
		 * Graphics controller to display feedback
		 * @param	stage
		 */
		public function Graphics(context:AccessibilityController) {
			
			_graphics = new Array();
			_graphics.push( { graphic: new Activate(context), event: PrebuiltText.INTRO_HELPER_TEXT } );
			//_graphics.push( { graphic: new Deactivate(context), event: PrebuiltText.OUTRO_DEACTIVATING } );
			_graphics.push( { graphic: new Help(context), event: PrebuiltText.HELP_CONTENT } );
			_graphics.push( { graphic: new Instruction0(context), event: PrebuiltText.INSTRUCTIONS_0 } );
			_graphics.push( { graphic: new Instructions1(context), event: PrebuiltText.INSTRUCTIONS_1 } );
			_graphics.push( { graphic: new Instructions2(context), event: PrebuiltText.INSTRUCTIONS_2 } );
			_graphics.push( { graphic: new Instructions3(context), event: PrebuiltText.INSTRUCTIONS_3 } );
			
			_isTTSActive = false;			
		}
		
			
		public function start(item:String):void {
			
			this.cancel(); // only one graphic showing at a time
			
			for each (var i:Object in _graphics) {
				if (i.event == item) { 
					i.graphic.start(item);
					break;
				}
			}
			
			_lastEvent = item;			
			
			if (_lastEvent == AccessibilityEvent.ACTIVATE) {
				isTTSActive = true;
			} else if (_lastEvent == AccessibilityEvent.DEACTIVATE) {
				isTTSActive = false;
			}
		}
		
		public function cancel():void {			
			for each (var i:Object in _graphics) {
				i.graphic.cancel();
			}					
		}
		
		

	}
	
}