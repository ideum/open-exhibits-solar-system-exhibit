package com.gestureworks.managers 
{
	import com.gestureworks.core.GestureWorks;
	import com.leapmotion.leap.events.LeapEvent;
	import com.leapmotion.leap.LeapMotion;
	import com.leapmotion.leap.Pointable;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author
	 */
	public class LeapManager extends Sprite
	{
		public var leap:LeapMotion;		
		protected var debug:Boolean = false;
		
		public function LeapManager() {	
			
			leap = new LeapMotion(); 
			leap.controller.addEventListener( LeapEvent.LEAPMOTION_INIT, onInit );
			leap.controller.addEventListener( LeapEvent.LEAPMOTION_CONNECTED, onConnect );
			leap.controller.addEventListener( LeapEvent.LEAPMOTION_DISCONNECTED, onDisconnect );
			leap.controller.addEventListener( LeapEvent.LEAPMOTION_EXIT, onExit );
			leap.controller.addEventListener( LeapEvent.LEAPMOTION_FRAME, onFrame );
		}
		
		public function onInit( event:LeapEvent ):void
		{ 
			if (debug)
				trace("Leap Initialized");
		}

		public function onConnect( event:LeapEvent ):void
		{
			if(debug)
				trace( "Leap Connected" );				
			GestureWorks.application.stage.addChild(this);				
		}

		public function onDisconnect( event:LeapEvent ):void
		{
			if(debug)
				trace( "Leap Disconnected" );
			GestureWorks.application.stage.removeChild(this);								
		}

		public function onExit( event:LeapEvent ):void
		{
			if(debug)
				trace( "Leap Exited" );
		}		

		protected function onFrame(event:LeapEvent):void
		{			
			dispatchEvent(new LeapEvent(event.type, event.frame));
			
			if(debug)
				trace("leap frame event");
		}	
		
		/**
		 * Linearly maps an incoming value from one range to another
		 * @param	num Incoming value to be mapped
		 * @param	min1 Incoming minimum range value
		 * @param	max1 Incoming maximum range value
		 * @param	min2 Outgoing minimum range value
		 * @param	max2 Outgoing maximum range value
		 * @param	round Whether the returned value is rounded to nearest integer
		 * @param	constrainMin Whether the returned value is constrained to the minumim value
		 * @param	constrainMax Whether the returned value is constrained to the maximum value
		 * @return	Mapped value
		 */
		public static function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number
		{
			if (constrainMin && num < min1) return min2;
			if (constrainMax && num > max1) return max2;
		 
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
			if (round) return Math.round(num2);
			return num2;
		}
		
		public function dispose():void {
			leap.controller.removeEventListener( LeapEvent.LEAPMOTION_INIT, onInit );
			leap.controller.removeEventListener( LeapEvent.LEAPMOTION_CONNECTED, onConnect );
			leap.controller.removeEventListener( LeapEvent.LEAPMOTION_DISCONNECTED, onDisconnect );
			leap.controller.removeEventListener( LeapEvent.LEAPMOTION_EXIT, onExit );
			leap.controller.removeEventListener( LeapEvent.LEAPMOTION_FRAME, onFrame );	
		}
		
	}

}