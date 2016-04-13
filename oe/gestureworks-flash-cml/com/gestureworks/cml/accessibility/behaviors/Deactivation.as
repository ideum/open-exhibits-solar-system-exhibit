package com.gestureworks.cml.accessibility.behaviors {
	import com.gestureworks.cml.accessibility.AccessibilityController;
	import com.gestureworks.cml.accessibility.PrebuiltText;
	import com.gestureworks.cml.events.AccessibilityEvent;
	import com.gestureworks.managers.TouchManager;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Deactivation implements IAccessibleBehavior {
		
		protected var context:AccessibilityController;
		public var state:int;
		
		public static const DelayIncrement:int = 10000;
		public static const DelayMaximum:int = 6000;
		
		private static const DELAY_GLOBAL:int = 2000;
		private static const DELAY_EXIT_HELP:int = 10000;
		private static const DELAY_EXIT_FIN:int = 2000; //23000; 
		
		//states
		private static const RESET:int = 0;
		private static const CONTROL:int = 1;
		private static const GLOBAL:int = 2;
		private static const EXIT_HELP:int = 3;
		private static const EXIT_TIMEOUT_FINISH:int = 4;
		private static const END:int = 5;
		private static const END_FINISH:int = 6;
		
		private var _delay:int;
		private var _timer:Timer;
		
		// every 500 milliseconds the hold event fires
		// at 500 milliseconds, the hold animation displays
		// after 2000 milliseconds, the SOI will deactivate
		private var _deactivationCount:uint;
		private var _deactivationTotal:uint;
		private var _timerDelayTime:uint;
		private var _timerDeactivateDelay:Timer;
		
		private var _timerDeactivateDelayAuto:Timer;
		
		public function Deactivation(context:AccessibilityController) {
			
			this.context = context;
			
			state = RESET;
			_delay = 0;
			_timer = new Timer(DelayIncrement);
			_timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			
			_deactivationCount = 0; // 500 millisecond intervals
			_deactivationTotal = 4; // = 2000 milliseconds
			_timerDelayTime = 1000;
			
			// timer used to clear out activate if it doesn't complete
			_timerDeactivateDelay = new Timer(_timerDelayTime);
			_timerDeactivateDelay.addEventListener(TimerEvent.TIMER, onTimerDeactivateDelay);
			
			// timer used to auto shutdown
			_timerDeactivateDelayAuto = new Timer(_timerDelayTime, _deactivationTotal+1);
			_timerDeactivateDelayAuto.addEventListener(TimerEvent.TIMER, onTimerDeactivateDelayAuto);
			
		}
		
		private function onTimerEvent(e:TimerEvent):void {
			timer.stop();
			if (state == RESET) {
				state = GLOBAL;
				context.behavior = this;
				context.speakBuiltInText(PrebuiltText.HELP_CONTENT);
				context.feedback.start(PrebuiltText.HELP_CONTENT);
			} else if (state == CONTROL) {
				state = GLOBAL;
				context.speakBuiltInText(PrebuiltText.INSTRUCTIONS_0);
				context.feedback.start(PrebuiltText.INSTRUCTIONS_0);
			} else if (state == GLOBAL) {
				state = EXIT_HELP;
				context.speakBuiltInText(PrebuiltText.INSTRUCTIONS_3);
				context.feedback.start(PrebuiltText.INSTRUCTIONS_3);
			} else if (state == EXIT_HELP) {
				state = EXIT_TIMEOUT_FINISH;
				context.speakBuiltInText(PrebuiltText.OUTRO_DEACTIVATING);
			}
		}
		
		private function onTimerDeactivateDelay(e:TimerEvent):void {
			_deactivationCount = 0;
			_timerDeactivateDelay.reset();
			context.feedback.cancel();
			this.stop();
			this.init();
		}
		
		private function onTimerDeactivateDelayAuto(e:TimerEvent):void {
			activate();
		}
		
		public function init():void {
			_timer.start();
		}
		
		public function next():void {
			this.stop();
			context.behavior = context.navigation;
			context.behavior.next();
		}
		
		public function previous():void {
			this.stop();
			context.behavior = context.navigation;
			context.behavior.previous();
		}
		
		public function select():void {
			this.stop();
			context.behavior = context.navigation;
			context.behavior.select();
		}
		
		public function back():void { 
			this.stop()
			context.behavior = context.navigation;
			context.behavior.back();
		}
		
		public function home():void { 
			this.stop()
			context.behavior = context.navigation;			
			context.behavior.home();
		}

		public function help():void { 
			this.stop()
			context.behavior = context.navigation;
			context.behavior.help();
		}				
		
		// this is what is called after timeouts
		public function activate():void {						
			if(state==END) {
				if (_deactivationCount == _deactivationTotal) {
					state = END_FINISH;
					resetEnd();
				} else if(_deactivationCount==1){
					// display feedback
					context.feedback.start(PrebuiltText.OUTRO_DEACTIVATING);
					_timerDeactivateDelay.start();
				} else if (_deactivationCount < _deactivationTotal) {
					_timerDeactivateDelay.reset();
					_timerDeactivateDelay.start();
				}
				
			} else if(state != END) {
				state = END;
				//context.speech.stop();
				
			}  
			
			_deactivationCount++;
			
		}
		
		public function speakComplete():void {						
			switch(state) {
				case CONTROL:
					timer.reset();
					timer.delay = DELAY_GLOBAL;
					timer.start();
					context.feedback.cancel();				
					break; 
				case GLOBAL:
					timer.reset();
					timer.delay = DELAY_EXIT_HELP;
					timer.start();
					context.feedback.cancel();				
					break; 
				case EXIT_HELP:
					timer.reset();
					timer.delay = DELAY_EXIT_FIN;
					timer.start();
					context.feedback.cancel();				
					break;
				case EXIT_TIMEOUT_FINISH:
					_timerDeactivateDelayAuto.start();				
					break;
				case END:
					break;
				case END_FINISH:
					context.behavior = context.activation;
					context.isActivated = false; 
					state = RESET;
					break;
				default:
					trace("complete", state);
					break; 
			}
		}
		
		public function speakStop():void {}
		public function speakStart(duration:Number = 0.0):void {}
		
		public function stop():void {
			
			state = RESET;
			
			_delay = Math.min(DelayMaximum, Math.max(DelayIncrement, _delay + DelayIncrement));
			timer.delay = _delay;
			timer.reset();
			
			_deactivationCount = 0;
			_timerDeactivateDelay.reset();
			_timerDeactivateDelayAuto.reset();
			
			//context.feedback.cancel();
		}
		
		private function resetEnd():void {
			stop();
			context.visible = false;
			TouchManager.forceRelease(context);
			context.speakBuiltInText(PrebuiltText.OUTRO_DEACTIVATED);
			context.feedback.start(AccessibilityEvent.DEACTIVATE);
			context.feedback.cancel(); // this is needed one more time			
			state = END_FINISH;
		}
		
		public function get delay():int { return _delay; }	
		
		public function get timer():Timer { return _timer; }
		
	}
}