package com.gestureworks.cml.accessibility.feedback {
	import com.gestureworks.cml.accessibility.feedback.sounds.Sounds;
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.accessibility.AccessibilityController;
	import com.gestureworks.cml.accessibility.feedback.graphics.Graphics;
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author Ken Willes
	 */
	public class Feedback implements IFeedback {
		
		/**
		 * Feedback types
		 */
		private var _graphicalFeedback:Graphics;
		private var _sonicFeedback:Sounds;
		protected var _context:AccessibilityController;
		
		/**
		 * isGraphicsOn enables/disables graphic feedback
		 */
		private var _isGraphicsOn:Boolean;
		public function get isGraphicsOn():Boolean { return _isGraphicsOn; }
		public function set isGraphicsOn(value:Boolean):void {
			if (value && !_graphicalFeedback) {
				_graphicalFeedback = new Graphics(_context);
			} else if(_graphicalFeedback) {
				_graphicalFeedback.cancel();
			}
			_isGraphicsOn = value;
		}
		
		/**
		 * isSoundOn enables/disables sonic feedback
		 */
		private var _isSoundOn:Boolean;
		public function get isSoundOn():Boolean { return _isSoundOn; }		
		public function set isSoundOn(value:Boolean):void {
			if (value == true && _sonicFeedback == null) {
				_sonicFeedback = new Sounds();
			} else {
				_sonicFeedback.cancel();
			}
			_isSoundOn = value;
		}
		
		/**
		 * TODO: isHapticsOn
		 */
		private var _isHapticsOn:Boolean;
		public function get isHapticsOn():Boolean { return _isHapticsOn; }
		public function set isHapticsOn(value:Boolean):void {
			_isHapticsOn = value;
		}
			
		/**
		 * Active feedback type 
		 */
		protected var _selection:String;
		public function get selection():String { return _selection; }		
		public function set selection(item:String):void { _selection = item; }	
		
		/**
		 * Feedback constructor
		 * @param	context:Accessibility
		 * @param	isGraphicsOn = true
		 * @param	isSoundOn = true
		 * @param	isHapticsOn = false
		 */
		public function Feedback(context:AccessibilityController, isGraphicsOn:Boolean = false, isSoundOn:Boolean = true, isHapticsOn:Boolean = false) {
			this._context = context;
			this.isGraphicsOn = isGraphicsOn;
			this.isSoundOn = isSoundOn;
			this.isHapticsOn = isHapticsOn;
		}
		
		public function start(item:String):void {
			selection = item;
			// pass through to individual feedback delegate types:
			if(isGraphicsOn) { _graphicalFeedback.start(selection); }
			if (isSoundOn) { _sonicFeedback.start(selection); }
			if (isHapticsOn) {  }
		}
		
		public function cancel():void {
			// pass through to individual feedback delegate types:
			if(isGraphicsOn) { _graphicalFeedback.cancel(); }
			if (isSoundOn) { _sonicFeedback.cancel(); }
			if (isHapticsOn) {  }
		}
		

	}
	
}