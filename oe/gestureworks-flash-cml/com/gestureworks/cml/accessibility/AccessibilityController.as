package com.gestureworks.cml.accessibility {

	import com.gestureworks.cml.accessibility.behaviors.Activation;
	import com.gestureworks.cml.accessibility.behaviors.Deactivation;
	import com.gestureworks.cml.accessibility.behaviors.IAccessibleBehavior;
	import com.gestureworks.cml.accessibility.behaviors.Navigation;
	import com.gestureworks.cml.accessibility.feedback.Feedback;
	import com.gestureworks.cml.accessibility.feedback.IFeedback;
	import com.gestureworks.cml.accessibility.managers.NavManager;
	import com.gestureworks.cml.elements.State;
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.AccessibilityEvent;
	import com.gestureworks.cml.managers.StateManager;
	import com.gestureworks.cml.utils.LanguageCode;
	import com.gestureworks.cml.utils.SSMLObject;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.managers.TouchManager;
	import com.gestureworks.objects.GestureObject;
	import com.gestureworks.objects.PointObject;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	
	public final class AccessibilityController extends TouchContainer implements IAccessibleBehavior {
		
		//state vars
		public var activation:Activation;
		public var navigation:Navigation;
		public var deactivation:Deactivation;
		private var _isActivated:Boolean = false;				
		private var _behavior:IAccessibleBehavior;
		private var _feedback:IFeedback;
		private var multiuser:Boolean; 
		
		//navigation vars
		public var rootNav:Nav;
		public var nav:NavManager;
		
		//speech vars
		public var speechProperties:SSMLObject;
		public var prebuiltText:PrebuiltText;
		public var rate:Number = 1; 
		public var pointPanning:String;		
		
		//utility vars
		private var gestureMap:GestureNavMap;
		private var fastTap:Boolean = true; 
		private var _stage:Stage;
		
		//textual feedback vars
		private var distance:Number;
		private var duration:Number; 
		private var text:Text; 
		private var tMask:Sprite; 
		private var tween:TweenLite;
		
		//contoller location
		private var invocationPoint:Point = new Point();
		
		/**
		 * Accessiblity contructor
		 * @param	rootNav  root Nav object
		 * @param	gestureMap  gesture-to-navigation mapping
		 */
		public function AccessibilityController(id:String, rootNav:Nav, gestureMap:GestureNavMap, multiuser:Boolean = false, sphereRadius:Number = 250, rate:Number = 1.5, pointPanning:String = null, fastTap:Boolean = true, tapDuration:Number = 10) {
			
			super();
			this.id = id; 
			this.rootNav = rootNav;
			this.rate = rate;
			this.gestureMap = gestureMap;
			this.pointPanning = pointPanning;
			this.fastTap = fastTap;
			this.multiuser = multiuser;
			visible = false; 
			
			initSpeech();
			initNav();
			initUserInput();
			initializeTextualFeedback();
			
			//optimized tap recognition
			if (fastTap) {
				new TapEvaluator(this, onNavigation, tapDuration);
			}
			
			//accessiblity gesture area
			graphics.beginFill(0xffffff, 0.8);					
			if (multiuser) {  
				width = sphereRadius * 2; 
				height = width;
				graphics.drawCircle(0,0, sphereRadius);				
			}
			else {
				width = GestureWorks.application.stageWidth;
				height = GestureWorks.application.stageHeight;
				graphics.drawRect( -width / 2, -height / 2, width, height);
				invocationPoint.x = width / 2;
				invocationPoint.y = height / 2;
			}
			
			activation = new Activation(this);
			navigation = new Navigation(this);
			deactivation = new Deactivation(this);
			feedback = new Feedback(this, true);
			behavior = activation;
			nativeTransform = false; 			
		}
		
		/**
		 * Invoke controller from layer
		 * @param	activationPoints
		 */
		public function invoke(activationPoints:Vector.<PointObject> = null):void {
			alpha = 0;
			visible = true; 
			TouchManager.transferPoints(AccessibilityLayer.getInstance(), this);
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function set visible(value:Boolean):void {
			if (!value) {
				TouchManager.forceRelease(this);
			}
			super.visible = value;
		}
		
		/**
		 * Activated state
		 */
		public function get isActivated():Boolean { return _isActivated; }
		public function set isActivated(value:Boolean):void {
			_isActivated = value;	
			
			alpha = value ? 1 : 0;
			
			if (value) {
				TouchManager.forceRelease(this);
				x = invocationPoint.x;
				y = invocationPoint.y;
			}else {
				activation.state = Activation.INACTIVE;
			}
			
			setAudioPan();
		}
		
		/**
		 * Set speech properties
		 */
		private function initSpeech():void {
			
			prebuiltText = new PrebuiltText();
			speechProperties = new SSMLObject("", rate, "en", 100, int(id));
			
			//register language states
			for (var j:int = 0; j < LanguageCode.Languages.length; j++) {
				var state:State = new State();
				state["stateId"] = LanguageCode.Languages[j].iso2;
				state["language"] = LanguageCode.Languages[j].iso1;
				StateManager.registerObject(speechProperties, state);
			}
			
		}
		
		/**
		 * Initialize navigation manager
		 */
		private function initNav():void {
			nav = new NavManager(rootNav);
			nav.init();
		}
		
		/**
		 * Register navigation gestures
		 */
		private function initUserInput():void {	
			
			//assign gesture list
			var gList:Object = new Object();
			for each(var gid:String in gestureMap) {
				gList[gid] = true; 
			}
			gestureList = gList; 
			
			//register navigation controller
			var gestures:Vector.<GestureObject> = gO.pOList;
			for each(var gesture:GestureObject in gestures) {
				if (!fastTap) {
					addEventListener(gesture.event_type, onNavigation);
				}
				else if (gesture.event_type.search("tap") == -1) {
					addEventListener(gesture.event_type, onNavigation);
				}
			}			
		}
		
		/**
		 * Setup textual feedback for speach visualization
		 */
		private function initializeTextualFeedback():void {
			tMask = new Sprite();
			tMask.graphics.beginFill(0xFFFF00, .6);
			tMask.graphics.drawRect(0, 0, 375, 150);
			tMask.x = -tMask.width / 2; 
			tMask.y = -125;
			addChild(tMask);
			
			text = new Text();
			text.textAlign = "center";
			text.font = "OpenSansBold";
			text.fontSize = 20;
			text.width = tMask.width; 	
			text.wordWrap = true; 
			text.autosize = true; 
			text.x = tMask.x;
			text.y = tMask.y + 25;						
			text.toBitmap = true; 			
			addChild(text);			
			
			text.mask = tMask; 			
		}
		
		/**
		 * Update speech display
		 * @param	value
		 */
		private function updateText(value:String):void {
			if (text && value) {
				if(tween){
					tween.kill();
				}
				text.y = tMask.y + 25;
				text.str = value;
				distance = (text.textHeight + 4 - tMask.height) + (text.y - tMask.y);					
			}
		}
		
		/**
		 * Invokes appropriate navigation function
		 * @param	e
		 */
		private function onNavigation(e:GWGestureEvent):void {			
			var type:String = e.value.id as String;
			
			//remove hold points
			if (type == "acc-2-finger-hold") {
				TouchManager.forceRelease(TouchSprite(e.target));
			}
			else if (multiuser && type == "acc-3-finger-hold") {
				invocationPoint.x = e.value.stageX; 
				invocationPoint.y = e.value.stageY; 
			}
			//call corresponding navigation action
			if (type) {
				var f:Function = this[gestureMap[type]] as Function;
				f.call();
			}			
		}
		
		/**
		 * Set location based audio panning
		 */
		private function setAudioPan():void {
			if (isActivated && pointPanning) {
				
				var pan:Number;
				//horiztonal split
				if (pointPanning == "H") {  
					pan = x < stage.stageWidth / 2 ? 1 : -1;
				}
				//vertical split
				else {
					pan = y < stage.stageHeight / 2 ? 1 : -1;
				}
				
				speechProperties.pan = pan;
			}
		}
		
		/**
		 * Converts the inputted value to a SSML encoded object using the prosody and language properties from the speechProperties field and speaks it.
		 * @param  value String to be spoken.
		 * @param  preempt Flag to interrupt and clear current speech queue 
		 */
		public function speak(value:String, preempt:Boolean = false):void {			
			updateText(value);			
			var content:SSMLObject = speechProperties.clone();
			content.preempt = preempt;
			content.content = SSMLObject.stringToParagraph(value);			
			AccessibilityLayer.getInstance().speak(content.encode());
		}
		
		/**
		 * Takes a Nav instance and speaks it as a menu item. Certain behaviors utilize this to voice lists of information.
		 * Note: The titleContent property is used as the content provider for this method.
		 * @param  navItem
		 */
		public function speakAsMenuItem(navItem:Nav):void {
			var sib:Vector.<Nav> = navItem.navSiblings;
			var len:int = sib.length;
			var index:int = sib.indexOf(navItem);
			if (sib.length <= 1) {
				speak(navItem.titleContent, true);
			} else {
				speak(navItem.titleContent + ", " + (index + 1) + " of " + len + ".", true);
			}
		}
		
		/**
		 * Retrieves the language specific token text based on the key and speaks the phrase.
		 * @param  key String referencing the content to be spoken
		 */
		public function speakBuiltInText(key:String):void {
			prebuiltText.language = LanguageCode.ToISO639_2(speechProperties.language);
			speak(prebuiltText.valueOf(key), true);
		}
		
		/**
		 * Stops speech of current controller
		 */
		public function stop():void {
			AccessibilityLayer.getInstance().speech.stop();
		}	
		
		/**
		 * Cancel activiation
		 */
		public function cancel():void {
			visible = false;
			feedback.cancel();
		}
		
		public function next():void {
			behavior.next();
			dispatchEvent(new AccessibilityEvent(AccessibilityEvent.NEXT));
		}
		
		public function previous():void {
			behavior.previous();
			dispatchEvent(new AccessibilityEvent(AccessibilityEvent.PREVIOUS));			
		}
		
		public function select():void {
			behavior.select();
			dispatchEvent(new AccessibilityEvent(AccessibilityEvent.SELECT));
		}
		
		public function back():void {
			behavior.back();
			dispatchEvent(new AccessibilityEvent(AccessibilityEvent.BACK));			
		}
		
		public function home():void {
			behavior.home();
			dispatchEvent(new AccessibilityEvent(AccessibilityEvent.HOME));			
		}
		
		public function help():void {
			behavior.help();
			dispatchEvent(new AccessibilityEvent(AccessibilityEvent.HELP));			
		}
		
		public function activate():void {
			behavior.activate();
			dispatchEvent(new AccessibilityEvent(AccessibilityEvent.ACTIVATE));			
		}
		
		public function speakComplete():void {
			behavior.speakComplete();
		}
		
		public function speakStop():void {
			behavior.speakStop();
		}
		
		public function speakStart(duration:Number = 0.0):void {
			if (distance > 0) {
				tween = TweenLite.to(text, duration - 3, { y: text.y - distance, ease:Linear.easeNone } );
			}
			behavior.speakStart();
		}
		
		public function get behavior():IAccessibleBehavior { return _behavior; }		
		public function set behavior(value:IAccessibleBehavior):void {
			if (value == this) {
				return;
			}
			_behavior = value;
		}
		
		public function get feedback():IFeedback { return _feedback; }		
		public function set feedback(value:IFeedback):void {
			_feedback = value;
		}					
	}
}