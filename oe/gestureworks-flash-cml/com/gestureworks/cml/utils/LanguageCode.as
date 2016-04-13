package com.gestureworks.cml.utils {
	import flash.utils.Dictionary;
	
	public class LanguageCode {
		public static const English:LanguageCode = new LanguageCode("English", "en", "eng");
		public static const French:LanguageCode = new LanguageCode("French",  "fr", "fre");
		public static const Dutch:LanguageCode = new LanguageCode("Dutch", "nl", "dut");
		public static const German:LanguageCode = new LanguageCode("German", "de", "ger");
		public static const Spanish:LanguageCode = new LanguageCode("Spanish", "es", "spa");
		public static const Italian:LanguageCode = new LanguageCode("Italian", "it", "ita");
		public static const Portuguese:LanguageCode = new LanguageCode("Portuguese", "pt", "por");
		public static const Chinese:LanguageCode = new LanguageCode("Chinese", "zh", "zho");
		public static const Russian:LanguageCode = new LanguageCode("Russian", "ru", "rus");
		
		public static const Languages:Array = [
			English, French, Dutch, German, Spanish, Italian, Portuguese, Chinese, Russian
		];
		
		private static var isInit:Boolean = false;
		private static var to1:Object = { }
		private static var to2:Object = { }
		
		
		private static function init():void {
			if (!isInit) {
				isInit = true;
				var code:LanguageCode;
				for (var i:int = 0; i < Languages.length; i++) {
					code = Languages[i];
					to1[code.iso2] = code.iso1;
					to2[code.iso1] = code.iso2;
				}
			}
		}
		
		public static function ToISO639_1(chars:String):String {
			if (!isInit) {
				init();
			}
			return to1[chars];
		}
		
		public static function ToISO639_2(chars:String):String {
			if (!isInit) {
				init();
			}
			return to2[chars];
		}
		
		private var _name:String;
		private var _iso1:String;
		private var _iso2:String;
		
		public function LanguageCode(name:String, iso1:String, iso2:String) {
			_name = name;
			_iso1 = iso1;
			_iso2 = iso2;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get iso1():String {
			return _iso1;
		}
		
		public function get iso2():String {
			return _iso2;
		}
		
	}
}