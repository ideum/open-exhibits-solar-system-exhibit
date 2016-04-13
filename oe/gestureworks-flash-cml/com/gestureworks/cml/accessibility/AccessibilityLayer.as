package com.gestureworks.cml.accessibility {
	
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.SpeechEvent;
	import com.gestureworks.cml.managers.ResourceManager;
	import com.gestureworks.cml.managers.SpeechManager;
	import com.gestureworks.cml.utils.document;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.managers.TouchManager;
	import com.gestureworks.objects.GestureObject;
	import com.gestureworks.objects.PointObject;
	import flash.utils.Dictionary;
	
	public class AccessibilityLayer extends TouchContainer {
		
		private var gestureNavMapping:GestureNavMap;       	//gesture to navigation mapping
		private var pool:ResourceManager;       			//pool of accessiblity instances
		private var lookUp:Dictionary;                      //accessibility controller lookup table
		private static var instance:AccessibilityLayer;     //instance reference		
		
		private var _userCount:int = 1; 
		private var _rootNav:Nav;
		
		/**
		 * SpeechManager reference
		 */
		public var speech:SpeechManager;	
		
		/**
		 * Multiuser mode sphere of influence radius.
		 * @default 250
		 */
		public var sphereRadius:Number = 250;
		
		/**
		 * Enables location based audio panning in multiuser mode. The accepted values are either "H" or "V" indicating the horiztonal
		 * or vertical position of the controller to evaluate in the stero pan calculation. For horiztonal evaluations, the stage width
		 * is split in half and all controllers on the left side are assigned a pan value of -1 (left channel) and all controllers on the
		 * right are assigned a pan value of 1 (right channel). For vertical evaluations, the pan mapping is switched from top (left channel)
		 * to bottom (right channel). If not assigned to a valid orientation, the audio pan defaults to 0 (balanced) for all controllers. 
		 * @default H 
		 */
		public var pointPanning:String = "H";
		
		/**
		 * Speaking rate
		 * @default 1.5
		 */
		public var rate:Number = 1.5; 
		
		/**
		 * Enables optimized and explicit tap gesture recognition for default tap gestures (one_finger_tap, two_finger_tap, one_finger_double_tap) opposed 
		 * to the standard temporalmetric of the gesture engine. 
		 * @default true
		 */
		public var fastTap:Boolean = true; 
		
		/**
		 * Maximum time(ms) between corresponding entry points and exit points of tap gestures for fastTap evaluations. 
		 * @default 10
		 */
		public var tapDuration:Number = 10;
		
		/**
		 * Singleton constructor
		 */
		public function AccessibilityLayer() {		
			
			if (instance){
				throw new Error("Error: Instantiation failed: Use Accessibility.getInstance() instead of new.");
			}
			
			instance = this; 
			mouseChildren = false; 
			gestureNavMapping = new GestureNavMap();	
			speech = new SpeechManager();
			lookUp = new Dictionary();
		}
		
		/**
		 * Returns an AccessibilityLayer instance
		 * @return
		 */
		public static function getInstance():AccessibilityLayer {
			if (!instance)
				instance = new AccessibilityLayer();
			return instance;
		}		
			
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
						
			//generate instances
			var instances:Vector.<TouchContainer> = new Vector.<TouchContainer>();
			var acc:AccessibilityController;
			for (var i:int = 0; i < userCount; i++) {
				acc = new AccessibilityController(String(i), rootNav, gestureNavMapping, multiuser, sphereRadius, rate, pointPanning, fastTap, tapDuration);
				lookUp[acc.id] = acc; 
				parent.addChildAt(acc, parent.numChildren -1);
				instances.push(acc);				
			}
			
			//populate pool
			pool = ResourceManager.getInstance(instances);
			
			//setup speech manager
			initSpeech();			
			
			//setup gesture input
			initUserInput();
		}
		
		/**
		 * Root <code>Nav</code> object of the accessiblity navigation hierarchy 
		 */
		public function get rootNav():* { return _rootNav; }
		public function set rootNav(value:*):void {
			if (value is XML || value is String) {
				value = document.getElementById(value);
			}
			if (value is Nav) {
				_rootNav = value; 
			}
		}
		
		/**
		 * The nuumber of audio accessiblity instances to preload. A count of 1 declares single user mode which, on activation, will occupy the 
		 * entire screen space for accessiblity gestures and prevent all interaction with the underlying application. A count of 2 or greater 
		 * (multiuser mode) will restrict the accessiblilty control areas to personal "spheres" of influence allowing simultaneous interaction
		 * with the application and accessiblity controls. 
		 * @default 1
		 */		
		public function get userCount():int { return _userCount; }
		public function set userCount(value:int):void {
			if (value > 0) {
				_userCount = value; 
			}
		}		
		
		/**
		 * Initialize accessibility activation overlay
		 */
		private function initUserInput():void {
			
			//register layer with touch manager
			TouchManager.overlays.push(this);  
			
			//layer receives activation and deactivation gestures
			var layerGestures:Object = new Object();
			layerGestures[gestureNavMapping[NavAction.ACTIVATE]] = true; 
			gestureList = layerGestures;
			
			//register activation gesture event
			var gestures:Vector.<GestureObject> = gO.pOList;
			var handler:String; 
			for each(var gesture:GestureObject in gestures) {
				handler = gestureNavMapping[gesture.gesture_id];
				addEventListener(gesture.event_type, this[handler]);
			}
		}	
		
		/**
		 * Updated gesture to navigation mapping entries defined in the provided delimited string. The string should be formatted as follows:
		 * "key1:value1,key2:value2,...". If a default key does not exist, the entry will be ignored. See the <code>NavActions</code> for a 
		 * list of the required key names. 
		 * @see NavActions
		 */
		public function get gestureNavigation():String { return gestureNavMapping.toString() }
		public function set gestureNavigation(value:String):void {
			gestureNavMapping.update(value);
		}
		
		/**
		 * Multiuser mode
		 */
		public function get multiuser():Boolean { return userCount > 1; }
		
		/**
		 * Activate next available (inactive) accessibility controller
		 * @param	e
		 */
		private function activate(e:GWGestureEvent):void {
			if(originator(e)){
				var acc:AccessibilityController = pool.resource;
				if (!acc.isActivated) {
					acc.invoke();
				}
			}
		}
		
		/**
		 * Determines if activation gesture belongs to accessiblity layer or a controller
		 * @param	e
		 */
		private function originator(e:GWGestureEvent):Boolean {
			for each(var point:PointObject in TouchContainer(e.target).pointArray) {
				if (point.originator is AccessibilityController) {
					return false; 
				}
			}
			return true; 
		}
		
		/**
		 * Set speech properties
		 */
		private function initSpeech():void {			
			//add speech handlers
			var speechEvents:Vector.<String> = SpeechEvent.events;
			for each(var event:String in speechEvents) {
				speech.addEventListener(event, onSpeechEvent);
			}						
		}	
		
		/**
		 * Targets appropriate controller and invokes appropriate speech operation
		 * @param	e
		 */
		private function onSpeechEvent(e:SpeechEvent):void {
			var acc:AccessibilityController = lookUp[e.userId];
			switch(e.type) {
				case SpeechEvent.START:
					acc.speakStart(e.duration);
					break;
				case SpeechEvent.STOP:
					acc.speakStop();
					break;
				case SpeechEvent.COMPLETE:
					acc.speakComplete();
					break;
				default:
					break;
			}
		}
		
		/**
		 * Translate provided text to speech audio
		 * @param	content
		 */
		public function speak(content:String):void {
			speech.speak(content);
		}
	}	
}