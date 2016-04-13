package com.gestureworks.cml.accessibility.feedback.graphics {

	import acc.ThreeFingerHold;
	import com.gestureworks.cml.accessibility.AccessibilityController;
	import com.gestureworks.cml.accessibility.feedback.IFeedback;
	import com.gestureworks.cml.accessibility.PrebuiltText;
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.elements.State;
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.cml.managers.StateManager;
	import com.gestureworks.cml.utils.LanguageCode;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Ken Willes
	 */
	public final class Deactivate extends MovieClip implements IFeedback {
		
		private var _renderContext:AccessibilityController;
		private var _graphicLoader:MovieClip;
		private var _graphicHold:ThreeFingerHold;
		private var _label:Text;
		private var _prebuiltText:PrebuiltText; 
		
		public function Deactivate(renderContext:AccessibilityController) {
			super();
			
			_renderContext = renderContext;
			initGraphics();
			initLanguageStates();

		}
		
		private function initGraphics():void {
			
			_graphicLoader = new MovieClip();
			_graphicLoader.visible = false;
			_graphicLoader.x = (_renderContext.width * 0.5) - (_graphicLoader.width * 0.5);
			_graphicLoader.y = (_renderContext.height * 0.5) - (_graphicLoader.height * 0.5);
			
			_graphicHold = new ThreeFingerHold();
			_graphicHold.visible = true;
			_graphicHold.x = _graphicHold.width * -0.5;
			_graphicHold.y = (_graphicLoader.height * 0.5) - (_graphicHold.height * 0.5);
			_graphicLoader.addChild(_graphicHold);
			
			_label = new Text();
			_label.font = "OpenSansRegular";
			_label.fontSize = 18;	
			_label.color = 0x000000;
			_label.textAlign = "center";
			_label.text = "";
			_label.width = _renderContext.width * .5;
			_label.x = _label.width * -0.5;
			_label.y = _label.height + 20;
			_label.color = 0xFFFFFF;
			//_label.background = true;
			//_label.backgroundColor = 0xff0000;
			_graphicLoader.addChild(_label);
			
			_renderContext.addChild(_graphicLoader);
		}
		
		private function initLanguageStates():void {
			_prebuiltText = new PrebuiltText();
			_label.text = _prebuiltText.valueOf(PrebuiltText.INSTRUCTIONS_3); // get english default text
			// label states
			for (var j:int = 0; j < LanguageCode.Languages.length; j++) {
				var state:State = new State(); 
				state["stateId"] = LanguageCode.Languages[j].iso2; 
				_prebuiltText.language = LanguageCode.Languages[j].iso2
				state["text"] = _prebuiltText.valueOf(PrebuiltText.INSTRUCTIONS_3);
				StateManager.registerObject(_label, state); 
			}
		}
		
		/* INTERFACE com.gestureworks.cml.accessibility.feedback.IFeedback */
		public function start(item:String):void {
			_graphicLoader.visible = true;
			//_graphicLoader.animateForSeconds(1.20, true);
		}
		
		public function cancel():void {
			_graphicLoader.visible = false;
			//_graphicLoader.reset();
		}
		
	}

}