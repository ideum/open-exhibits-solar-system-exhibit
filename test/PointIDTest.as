package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	/**
	 * ...
	 * @author Ideum
	 */
	public class PointIDTest extends Sprite
	{
		
		public function PointIDTest() 
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchDown);
			stage.addEventListener(TouchEvent.TOUCH_END, touchUp);
		}
		
		private function touchDown(e:TouchEvent):void {
			trace("down", e.touchPointID);
		}
		
		private function touchUp(e:TouchEvent):void {
			trace("up",e.touchPointID);
		}
		
	}

}