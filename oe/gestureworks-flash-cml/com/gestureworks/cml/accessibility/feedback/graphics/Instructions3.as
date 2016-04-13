package com.gestureworks.cml.accessibility.feedback.graphics {
	
	import com.gestureworks.cml.accessibility.AccessibilityController;
	import com.gestureworks.cml.accessibility.feedback.IFeedback;
	import com.gestureworks.cml.accessibility.PrebuiltText;
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.elements.State;
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.cml.managers.StateManager;
	import com.gestureworks.cml.utils.LanguageCode;
	import flash.display.Sprite;

	/**
	 * ...
	 * @author Ken Willes
	 */
	public final class Instructions3 extends Sprite implements IFeedback {
		
		private var _renderContext:AccessibilityController;
		private var _graphic:ThreeFingerHold;
		private var _label:Text;
		private var _prebuiltText:PrebuiltText;
		
		public function Instructions3(renderContext:AccessibilityController) {
			super();
			
			_renderContext = renderContext;
			initGraphics();	
		}
		
		private function initGraphics():void {			
			_graphic = new ThreeFingerHold();
			_graphic.visible = false;
			_graphic.x = -_graphic.width*.5;
			_graphic.y = 50;
			_renderContext.addChild(_graphic);			
		}
		
		public function start(item:String):void {
			_graphic.visible = true;
		}
		
		public function cancel():void {
			_graphic.visible = false;
		}
		
	}

}