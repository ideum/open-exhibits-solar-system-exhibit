package 
{
	import acc.*;
	import com.gestureworks.cml.accessibility.*;
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.managers.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	
	/**
	 * OE Solar System Exhibit
	 * @author Ideum
	 */
	[SWF(width = "1920", height = "1080", backgroundColor = "0x000000", frameRate = "30")]

	public class Main extends GestureWorks
	{
		
		public function Main():void 
		{
			super();
			cml = "library/cml/solar_application.cml";
			gml="library/gml/solar_gestures.gml"

			CMLParser.debug = false;			
			CMLParser.addEventListener(CMLParser.COMPLETE, cmlInit);
		}
		
		override protected function gestureworksInit():void
 		{
			trace("gestureWorksInit()");				
		}
		
		private function cmlInit(event:Event):void
		{	
			trace("cmlInit()");
			CMLParser.removeEventListener(CMLParser.COMPLETE, cmlInit);
			//var accessibility:AccessibilityManager = new AccessibilityManager("accessibility-nav");
		}		

	}
}
