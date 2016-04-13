package com.gestureworks.cml.accessibility.behaviors {
	import com.gestureworks.cml.accessibility.AccessibilityController;
	import com.gestureworks.cml.accessibility.Nav;
	import com.gestureworks.cml.events.AccessibilityEvent;
	import com.gestureworks.cml.accessibility.PrebuiltText;
	import com.gestureworks.cml.utils.Log;
	
	public class Navigation implements IAccessibleBehavior {
		
		protected var context:AccessibilityController;
		public var state:int;
		
		private static const SPEAK_DESCRIPTION:int = 0;
		private static const SPEAK_NAME:int = 1;
		private static const SPEAK_CONTENT:int = 2;
		private static const BACK:int = 3;
		private static const INSTRUCTIONS_1:int = 4; 
		private static const INSTRUCTIONS_2:int = 5; 
		
		public function Navigation(context:AccessibilityController) {
			this.context = context;			
		}
		
		private function resolvePostInitState():void {
			var nav:Vector.<Nav>;
			var len:int;
			
			if (state == SPEAK_DESCRIPTION) {
				nav = context.nav.focus.navChildren;
				len = nav.length;
				context.nav.focus = nav[0];				
			} else if (state == SPEAK_NAME) {
				context.nav.focus = context.nav.context;
				context.nav.context = context.nav.context.navParent;				
			} else {
				//TODO: handle exception
			}
			state = SPEAK_CONTENT;
			context.speakAsMenuItem(context.nav.focus);
		}

		public function init():void {
			context.stop();
			if (context.nav.focus == context.nav.context) {
				state = SPEAK_DESCRIPTION;
				context.speak(context.nav.focus.descContent, true);
			} else if (context.nav.context.navParent == context.nav.focus) {
				state = SPEAK_NAME;
				context.speak(context.nav.focus.titleContent, true);
			} else {
				//TODO: handle exception
			}
		}
		
		public function next():void {
			context.stop();
			var nav:Vector.<Nav>;
			var index:int;
			if (state == SPEAK_DESCRIPTION || state == SPEAK_NAME) {
				resolvePostInitState();
			} else if (state == SPEAK_CONTENT) {
				nav = context.nav.focus.navSiblings;
				index = nav.indexOf(context.nav.focus);
				index++;
				if (index >= nav.length) {
					if (context.nav.onRoot) {
						context.speakAsMenuItem(context.nav.focus);
						context.feedback.start(AccessibilityEvent.INACCESSIBLE_ITEM);
					} else {
						context.feedback.start(AccessibilityEvent.INACCESSIBLE_ITEM);
						context.speakAsMenuItem(context.nav.focus);						
					}
				} else {
					context.nav.focus = nav[index];
					context.speakAsMenuItem(context.nav.focus);
					context.feedback.start(AccessibilityEvent.NEXT);
				}
			} else if (state == BACK) {
				//dunk sound
				context.feedback.start(AccessibilityEvent.INACCESSIBLE_ITEM);
			}
		}
		
		public function previous():void {
			context.stop();
			var nav:Vector.<Nav>;
			var index:int;
			nav = context.nav.focus.navSiblings;
			index = nav.indexOf(context.nav.focus);
			if (state == SPEAK_CONTENT) {
				index--;
				if (index < 0) {
					context.nav.focus = nav[0];
					context.feedback.start(AccessibilityEvent.INACCESSIBLE_ITEM);					
					context.speakAsMenuItem(context.nav.focus);
				} else {
					context.nav.focus = nav[index];
					context.speakAsMenuItem(context.nav.focus);
					context.feedback.start(AccessibilityEvent.PREVIOUS);
				}
			} else if (state == BACK) {
				state = SPEAK_CONTENT;
				context.nav.focus = nav[nav.length - 1];
				context.speakAsMenuItem(context.nav.focus);
				context.feedback.start(AccessibilityEvent.PREVIOUS);
			} else {
				//crap
			}
		}
		
		public function select():void {
			context.stop();
			if (state == SPEAK_CONTENT) {
				if (context.nav.focus.numChildren > 0) {
					context.feedback.start(AccessibilityEvent.SELECT);
					context.nav.context = context.nav.focus;
					init();
					//TODO: need to determine if this is a content item, right now everything is treated as a nav
				} else {
					context.feedback.start(AccessibilityEvent.INACCESSIBLE_ITEM);					
				}
			} else if (state == BACK) {
				if (context.nav.onRoot) {
					//shouldn't get here
				} else {
					context.feedback.start(AccessibilityEvent.SELECT);
					context.nav.focus = context.nav.context.navParent;
					init();
				}
			} else {
				//crap
			}
		}
		
		public function activate():void {
			// navigation can't do this so delegate
			context.behavior = context.deactivation;
			context.behavior.init();
			context.activate();
		}
		
		public function speakComplete():void {
			context.feedback.cancel();
			
			if (state == INSTRUCTIONS_1) {
				state = INSTRUCTIONS_2;
				context.speakBuiltInText(PrebuiltText.INSTRUCTIONS_1);
				context.feedback.start(PrebuiltText.INSTRUCTIONS_1);
			}else if (state == INSTRUCTIONS_2) {
				state = SPEAK_CONTENT;
				context.speakBuiltInText(PrebuiltText.INSTRUCTIONS_2);
				context.feedback.start(PrebuiltText.INSTRUCTIONS_2);				
			}else if (state == SPEAK_DESCRIPTION || state==SPEAK_NAME) {
				resolvePostInitState();
			} else if (state == SPEAK_CONTENT) {
				context.deactivation.init(); // parallel
			}
		}
		
		public function speakStop():void { 
			context.feedback.cancel();
		}
		
		public function speakStart(duration:Number = 0.0):void {
			context.deactivation.stop(); // parallel
		}
		
		public function home():void {
			if (context.nav.onRoot == false) {
				context.nav.focus = context.rootNav;
				context.nav.context = context.rootNav;
				context.feedback.start(AccessibilityEvent.SELECT);
				context.stop();
				context.speakBuiltInText(PrebuiltText.NAV_HOME);
				state = SPEAK_CONTENT;
				context.nav.focus = context.nav.focus.navChildren[0];
			} else {
				context.speakAsMenuItem(context.nav.focus);
				context.feedback.start(AccessibilityEvent.INACCESSIBLE_ITEM);
			}
		}
		
		public function help():void {
			state = INSTRUCTIONS_1;
			context.speakBuiltInText(PrebuiltText.INSTRUCTIONS_0);
			context.feedback.start(AccessibilityEvent.SELECT);
			context.feedback.start(PrebuiltText.INSTRUCTIONS_0);
		}
		
		public function back():void {
			if (context.nav.onRoot) {
				// don't go any further
				context.speakAsMenuItem(context.nav.focus);
				context.feedback.start(AccessibilityEvent.INACCESSIBLE_ITEM);
			} else if (context.nav.context) {
				context.feedback.start(AccessibilityEvent.SELECT);
				context.nav.focus = context.nav.focus.navParent;					
				init();
			}
		}
		
	}

}