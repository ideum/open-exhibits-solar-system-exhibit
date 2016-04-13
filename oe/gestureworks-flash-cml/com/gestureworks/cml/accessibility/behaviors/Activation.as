package com.gestureworks.cml.accessibility.behaviors {
	
	import com.gestureworks.cml.accessibility.AccessibilityController;
	import com.gestureworks.cml.accessibility.AccessibilityLayer;
	import com.gestureworks.cml.accessibility.PrebuiltText;
	import com.gestureworks.cml.events.AccessibilityEvent;
	import com.gestureworks.cml.utils.Log;
	import com.gestureworks.managers.TouchManager;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Activation implements IAccessibleBehavior {
		
		protected var context:AccessibilityController;
		public var state:int;
		
		public static const INACTIVE:int = 0;
		public static const HELP:int = 1;
		public static const SPEAK:int = 2;
		public static const ACTIVATE:int = 3;
		
		// every 500 milliseconds the hold event fires
		// at 500 milliseconds, the hold animation displays
		// after 2000 milliseconds, the SOI will activate
		private var _activationCount:uint;
		private var _activationTotal:uint;
		private var _timerDelayTime:uint;
		private var _timer:Timer;

		public function Activation(context:AccessibilityController) {
			this.context = context;
			state = INACTIVE;
			_activationCount = 0; // 500 millisecond intervals
			_activationTotal = 4; // = 2000 milliseconds
			_timerDelayTime = 1000;
			// timer used to clear out activate if it doesn't complete
			_timer = new Timer(_timerDelayTime);
			_timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			
		}
		
		public function activate():void {
			if (state == INACTIVE) {
				_activationCount++;
				if (_activationCount == _activationTotal) {
					state = HELP;
					context.isActivated = true;					
					context.speakBuiltInText(PrebuiltText.INTRO_ACTIVATION_TEXT);
					// reset timer
					_timer.reset();
					_activationCount = 0;
					context.feedback.start(AccessibilityEvent.ACTIVATE);
				} else if(_activationCount==1){
					// display feedback
					context.feedback.start(PrebuiltText.INTRO_HELPER_TEXT);
					_timer.start();
				} else if(_activationCount < _activationTotal){
					_timer.reset();
					_timer.start();
				}
			} 
			else if (context.isActivated) {
				context.behavior = context.deactivation;
				context.behavior.init();
				context.activate();
			}
		}
		
		private function onTimerEvent(e:TimerEvent):void {
			_activationCount = 0;
			_timer.reset();
			context.cancel();
		}
		
		public function speakComplete():void {
			if (state == HELP) {
				state = SPEAK;
				context.speakBuiltInText(PrebuiltText.HELP_CONTENT);
				context.feedback.start(PrebuiltText.HELP_CONTENT);
			}
			else if (state == SPEAK) {
				state = ACTIVATE;
				context.speakBuiltInText(PrebuiltText.NAV_HOME);
			} else if (state == ACTIVATE) {
				state = INACTIVE;
				context.nav.focus = context.rootNav;
				context.nav.context = context.rootNav;
				context.behavior = context.navigation;
				context.behavior.init();				
			}
		}
		
		public function init():void { }		
		
		public function next():void {
			if(context.isActivated){
				context.behavior = context.navigation;		
				context.behavior.next();
			}
		}		
		
		public function previous():void {			
			if(context.isActivated){
				context.behavior = context.navigation;		
				context.behavior.previous();			
			}
		}
		
		public function select():void {
			if(context.isActivated){
				context.behavior = context.navigation;		
				context.behavior.select();			
			}
		}		
		
		public function back():void {
			if(context.isActivated){
				context.behavior = context.navigation;		
				context.behavior.back();
			}
		}
		
		public function home():void {
			if(context.isActivated){
				context.behavior = context.navigation;		
				context.behavior.home();
			}
		}
		
		public function help():void {
			if(context.isActivated){
				context.behavior = context.navigation;		
				context.behavior.help();
			}
		}
		
		public function speakStop():void {}
		public function speakStart(duration:Number = 0.0):void {}
	}
}