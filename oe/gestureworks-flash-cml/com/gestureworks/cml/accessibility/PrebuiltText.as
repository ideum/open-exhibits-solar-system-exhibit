package com.gestureworks.cml.accessibility {
	
	public class PrebuiltText {
		
		//ISO 639-2
		public static const ENG:String = "eng";
		public static const FRE:String = "fre";
		public static const DUT:String = "dut";
		public static const GER:String = "ger";
		public static const SPA:String = "spa";
		public static const ITA:String = "ita";
		public static const POR:String = "por";
		public static const ZHO:String = "zho";
		public static const RUS:String = "rus";
		
		public static const INTRO_HELPER_TEXT:String = "access_starting_0"; 
		public static const INTRO_ACTIVATION_TEXT:String = "access_starting_1"; 
		public static const HELP_CONTENT:String = "access_inactive"; 
		public static const INSTRUCTIONS_0:String = "instructions_0"; 
		public static const INSTRUCTIONS_1:String = "instructions_1";
		public static const INSTRUCTIONS_2:String = "instructions_2"; 
		public static const INSTRUCTIONS_3:String = "instructions_3"; 
		public static const OUTRO_DEACTIVATING:String = "access_inactive_1"; 
		public static const OUTRO_DEACTIVATED:String = "access_disabled"; 
		public static const NAV_BACK:String = "back";
		public static const NAV_HOME:String = "nav_home";
		
		public static const LANGUAGES:Array = [ENG];
		
		private var xml:XMLList;
		private var items:Object;
		private var _language:String;
		
		public function PrebuiltText(xml:XML=null) {
			if (!xml) {
				xml = DEFAULT_XML;
			}
			this.xml = xml.children();
			_language = LANGUAGES[0];
			items = { };
			init();
		}
		
		private function init():void {
			for (var item:String in xml) {
				initItem(xml[item]);
			}
		}
		
		private function initItem(item:XML):void {
			var obj:Object = { };
			var i:int;
			var len:int = LANGUAGES.length;
			var key:String;
			for (i = 0; i < len; i++) {
				key = LANGUAGES[i];
				if (item.child("title").length()>0) {
					//TODO: handle special case to avoid data loss.
					obj[key] = item.child("title").child(key).toString();
				} else {
					obj[key] = item.child("description").child(key).toString();
				}
			}
			items[item.attribute("id")] = obj;
		}
		
		public function get language():String { return _language; }		
		public function set language(value:String):void {
			_language = value;
		}
		
		public function valueOf(key:String):String {
			return items[key][_language];
		}
		
		private static const DEFAULT_XML:XML =
		<accessibility>
			<Item id="nav_home">
				<title>
					<eng>Home Menu</eng>
				</title>
			</Item>
			
			<Item id="access_starting_0">
				<description>
						<eng>Continue holding &#13;to start accessibility.</eng>
				</description>
			</Item>
			
			<Item id="access_starting_1">
				<description>
						<eng>Accessibility layer enabled. Use touch gestures to interact.</eng>
				</description>
			</Item>
			
			<Item id="access_inactive">
				<description>
						<eng>At any time you may hold two fingers down for help. </eng>
				</description>
			</Item>
			
			<Item id="instructions_0">
				<description>
						<eng>Swipe left or right for menu items.</eng>
				</description>
			</Item>			
			
			<Item id="instructions_1">
				<description>
					<eng>Single tap to select or double tap to go back.</eng>
				</description>
			</Item>
			
			<Item id="instructions_2">
				<description>
						<eng>Tap with two fingers to return home.</eng>
				</description>
			</Item>
			
			<Item id="instructions_3">
				<description>
						<eng>Exit audio by holding 3 fingers down for 2 seconds.</eng>
				</description>
			</Item>
			
			<Item id="access_inactive_1">
				<description>
						<eng>Auto shutdown of accessibility layer in 3, 2, 1.</eng>
				</description>
			</Item>
			
			<Item id="access_disabled">
				<description>
						<eng>Accessibility layer disabled.</eng>						
				</description>
			</Item>						
			
		</accessibility>;
	}
}