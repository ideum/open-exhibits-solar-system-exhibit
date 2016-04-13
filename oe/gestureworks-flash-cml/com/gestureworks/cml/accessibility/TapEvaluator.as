package  com.gestureworks.cml.accessibility
{
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.interfaces.ITouchObject;
	import com.gestureworks.objects.GestureObject;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * Provides optimal tap evaluation, based on event time stamps, as a faster alternative to the default frame history approach
	 * of the gesture pipeline. In addition to faster tap recognition, the utility also deconflicts between tap gesture permutations
	 * (currently one_finger_tap, one_finger_double_tap, and two_finger tap). 
	 * @author Ideum
	 */
	public class TapEvaluator 
	{	
		private var entryPoints:Vector.<GWTouchEvent> = new Vector.<GWTouchEvent>();		//entry point vector 
		private var exitPoints:Vector.<GWTouchEvent> = new Vector.<GWTouchEvent>();			//exit point vector	
		private var callback:Function;														//tap event callback
		private var evalTimer:Timer; 														//tap evaluation timer
		private var duration:Number;														//current time between corresponding touch entry and exit events		
		private var tapDuration:Number; 													//maximum time between corresponding touch entry and exit events
		
		/**
		 * Register object for optimal tap evaluation. TODO - Collect and apply tap gesture properties from objects' correpsonding GestureObject(s)
		 * @param	obj  Touch object to register
		 * @param   callback  Function fired on tap event
		 */		
		public function TapEvaluator(obj:ITouchObject, callback:Function, tapDuration:Number = 10):void {
			//register touch event handlers
			this.callback = callback;
			this.tapDuration = tapDuration;
			obj.addEventListener(GWTouchEvent.TOUCH_BEGIN, touchDown);			
			obj.addEventListener(GWTouchEvent.TOUCH_END, touchUp);	
			
			//intialize timer
			var evalTime:Number = tapDuration < 200 ? 200 : tapDuration + 100;
			evalTimer = new Timer(evalTime);
			evalTimer.addEventListener(TimerEvent.TIMER, tapCriteria);			
		}
		
		/**
		 * Track entry point properties and initialize tap evaluations
		 * @param	e
		 */
		private function touchDown(e:GWTouchEvent):void {
			entryPoints.push(e);
			if (!evalTimer.running) {
				evalTimer.start();
			}
		}
		
		/**
		 * Track exit point properties
		 * @param	e
		 */
		private function touchUp(e:GWTouchEvent):void {			
			if (!entryPoints.length) { //sync points
				exitPoints.length = 0;
			}
			else {
				exitPoints.push(e);
			}
		}
		
		/**
		 * Analyze tracked points for matching tap criteria
		 * @param	e
		 */
		private function tapCriteria(e:TimerEvent):void {
			if (oneFingerDoubleTap) {
				callback.call(null, new GWGestureEvent("double_tap", { id:"acc-1-finger-double-tap" } ));
			}
			else if (twoFingerTap) {
				callback.call(null, new GWGestureEvent("tap", { id:"acc-2-finger-tap" } ));
			}
			else if (oneFingerTap) {
				callback.call(null, new GWGestureEvent("tap", { id:"acc-1-finger-tap" } ));
			}
			
			reset();
		}
		
		/**
		 * One finger tap criteria
		 */
		private function get oneFingerTap():Boolean {
			if (exitPoints.length == 1) {									
				return validDuration(0, tapDuration);
			}
			return false; 
		}
		
		/**
		 * Two finger tap criteria
		 */
		private function get twoFingerTap():Boolean {
			if (exitPoints.length == 2) {
				return validDuration(0, tapDuration*10) && validDuration(1, tapDuration*10);
			}
			return false; 
		}		
		
		/**
		 * One finger double tap criteria
		 */
		private function get oneFingerDoubleTap():Boolean { 
			if (exitPoints.length == 2) {
				return distance(exitPoints[0], exitPoints[1]) <= 20;
			}
			return false; 
		}		
		 
		/**
		 * Point duration is greater than 0 and less than provided max
		 * @param	index Point index
		 * @param	max Max duration 
		 * @return
		 */
		private function validDuration(index:int, max:Number):Boolean {
			duration = exitPoints[index].time - entryPoints[index].time;
			return duration >= 0 && duration <= max; 
		}	
		
		/**
		 * Translation between point entry and exit is within max distance
		 * @param	index Point index
		 * @param	max Max distance
		 * @return
		 */
		private function validTranslation(index:int, max:Number):Boolean {
			return distance(entryPoints[index], exitPoints[index]) <= max;
		}
		
		/**
		 * Returns distance between touch events
		 * @param	e1
		 * @param	e2
		 * @return
		 */
		private function distance(e1:GWTouchEvent, e2:GWTouchEvent):Number {
			return Math.sqrt(Math.pow(e2.localX - e1.localX, 2) + Math.pow(e2.localY - e1.localY, 2));
		}
		
		/**
		 * Resets evaluation timer and clears points
		 */
		public function reset():void {
			evalTimer.reset();
			entryPoints.length = 0;
			exitPoints.length = 0;
		}
	}

}