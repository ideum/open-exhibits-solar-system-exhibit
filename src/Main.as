package 
{
	import com.gestureworks.cml.components.SlideshowViewer;
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
			gml = "library/gml/solar_gestures.gml"; 
			
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
			//this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			var viewers:LinkedMap = CMLObjectList.instance.getClass(SlideshowViewer);
			while (viewers.hasNext()) {
				var viewer:SlideshowViewer = viewers.currentValue as SlideshowViewer;
				viewer.addEventListener(StateEvent.CHANGE, popUpPlacementHandler);
				viewers.next();
			}
			
		}
		
		
		// handle all frame even
		/*
		private function enterFrameHandler(event:Event):void {
			var viewers:LinkedMap = CMLObjectList.instance.getClass(SlideshowViewer);
			while (viewers.hasNext()) {
				var viewer:SlideshowViewer = viewers.currentValue as SlideshowViewer;
				
				// force scale constraints
				if (viewer.scaleX < .5) {
					viewer.scaleX = .5;
					viewer.scaleY = .5;
				} else if (viewer.scaleX > 2) {
					viewer.scaleX = 2;
					viewer.scaleY = 2;
				}
				
				viewers.next();
			}
		}
		*/
		
		private function popUpPlacementHandler(event:StateEvent):void {
			
			// always open close to center but offset based on hotspot location
			if (event.property == "hotspot") {
				var viewer:SlideshowViewer = document.getElementById(event.target.id) as SlideshowViewer;
				viewer.x = (DefaultStage.instance.stage.stageWidth *.5 - viewer.x)*.1 + DefaultStage.instance.stage.stageWidth*.5;
				viewer.y = (DefaultStage.instance.stage.stageHeight *.5 - viewer.y)*.1 + DefaultStage.instance.stage.stageHeight*.2;
			}
			
		}

	}
}
