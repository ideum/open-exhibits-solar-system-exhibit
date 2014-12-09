package 
{	
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.managers.TouchManager;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	/**
	 * OE Solar System Exhibit
	 * @author Ideum
	 */
	[SWF(width = "1920", height = "1080", backgroundColor = "0xFFFFFF", frameRate = "30")]

	public class GestureTest extends GestureWorks
	{		
		public function GestureTest():void 
		{
			super();
			fullscreen = true; 
			gml = "library/gml/solar_gestures.gml";
		}
		
		override protected function gestureworksInit():void
 		{
			var ts:TouchSprite = new TouchSprite();
			ts.graphics.beginFill(0xFF0000);
			ts.graphics.drawCircle(250, 250, 250);
			ts.x = stage.stageWidth / 2 - 250;
			ts.y = stage.stageHeight / 2 - 250;
			addChild(ts);
					
			//ts.gestureList = {"acc-1-finger-swipe-left":true,"acc-1-finger-swipe-right":true, "acc-1-finger-tap":true, "acc-1-finger-double-tap":true, "acc-h-stroke":true, "acc-2-finger-swipe":true, "acc-2-finger-hold":true };
			ts.gestureList = { "acc-1-finger-tap":true };
			//ts.addEventListener(GWGestureEvent.SWIPE, onGesture);
			ts.addEventListener(GWGestureEvent.TAP, onGesture);
			//ts.addEventListener(GWGestureEvent.DOUBLE_TAP, onGesture);		
			//ts.addEventListener(GWGestureEvent.STROKE_LETTER, onGesture);
			//ts.addEventListener(GWGestureEvent.HOLD, onGesture);
		}				
		
		private function onGesture(e:GWGestureEvent):void {
			trace(e.value.id, e.value.n);
			if (e.type == "hold") {
				TouchManager.forceRelease(TouchSprite(e.target));
			}
			if (e.type == "tap") {
				trace(e.value.tap_n);
			}
		}
	}
}
