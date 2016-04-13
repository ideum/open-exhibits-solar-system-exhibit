package com.gestureworks.cml.accessibility 
{
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	/**
	 * ...
	 * @author Ideum
	 */
	public class GestureNavMap extends Proxy
	{		
		private var keyToVal:Dictionary;		//internal key to value map
		private var valToKey:Dictionary;        //internal value to key map
		private var keys:Vector.<String>;       //key vector
		private var size:int;                  //number of entries
		
		/**
		 * Creates a new default gesture-to-navigation mapping. The map links actual accessibility function names to GML-defined gesture ids. 
		 * To secure required functionality, the data structure only pemits the reassignment of gestures to navigation actions but it cannot 
		 * be externally modified with custom insertions (key entries not defined in @see NavAction) or deletions. The map is also bi-directional
		 * allowing the retreival of both value by key and key by value. 
		 */
		public function GestureNavMap() {
			
			//default navigation to gesture mapping
			keyToVal = new Dictionary(true);
			keyToVal[NavAction.ACTIVATE] = "acc-3-finger-hold";
			keyToVal[NavAction.PREVIOUS] = "acc-1-finger-swipe-right";
			keyToVal[NavAction.NEXT] = "acc-1-finger-swipe-left";
			keyToVal[NavAction.SELECT] = "acc-1-finger-tap";			
			keyToVal[NavAction.BACK] = "acc-1-finger-double-tap";
			keyToVal[NavAction.HELP] = "acc-2-finger-hold";
			keyToVal[NavAction.HOME] = "acc-2-finger-tap"; 
			
			keys = new Vector.<String>();		//key names	
			valToKey = new Dictionary(true);	//inverse map for bi-directional access
			for (var key:String in keyToVal) {
				keys.push(key);
				valToKey[keyToVal[key]] = key; 
			}
			
			size = keys.length; 			   //set map size
		}
		
		/**
		 * Return value by key or key by value
		 * @param	name  
		 * @return
		 */
		override flash_proxy function getProperty(name:*):* {			
			if (keyToVal.hasOwnProperty(name)) {
				return keyToVal[name];
			}
			return valToKey[name];
		}
		
		/**
		 * Add key/value entry
		 * @param	name
		 * @param	value
		 */
		override flash_proxy function setProperty(name:*, value:*):void {
			if(keyToVal.hasOwnProperty(name)){
				keyToVal[name] = value;
				valToKey[value] = name; 
			}
		}
		
		/**
		 * Prevent extenal deletion
		 * @param	name
		 * @return
		 */
		override flash_proxy function deleteProperty(name:*):Boolean {
			return false; 
		}
		
		/**
		 * Returns whether key is in map
		 * @param	name
		 * @return
		 */
		override flash_proxy function hasProperty(name:*):Boolean {
			return name in keyToVal || name in valToKey;
		}	
		
		/**
		 * Return iterator index
		 * @param	index
		 * @return
		 */
		override flash_proxy function nextNameIndex(index:int):int {
			return index < size ? index + 1 : 0;
		}
		
		/**
		 * Name at iterator
		 * @param	index
		 * @return
		 */
		override flash_proxy function nextName(index:int):String {
			return keys[index - 1];
		}
		
		/**
		 * Value at iterator
		 * @param	index
		 * @return
		 */
		override flash_proxy function nextValue(index:int):* {
			return keyToVal[keys[index - 1]];
		}
		
		/**
		 * Replaces existing key/value pairs with entries defined in the delimited string. Non-existing keys in the 
		 * mapping paramter will be ignored. 
		 * @param	mapping  Delimited string to update mapping entries with the following syntax: "key1:value1,key2:value2,..."
		 */
		public function update(mapping:String):void {
			if (mapping) {				
				//parse map update
				var entries:Array = mapping.split(",");
				for each(var entry:String in entries) {
					var pair:Array = entry.split(":");
					this[pair[0]] = pair[1];
				}				
			}
		}
		
		/**
		 * Converts map to formatted string representation (e.g. key1:value1, key2:value2, ...)
		 * @return
		 */
		public function toString():String {
			var str:String = "";
			for (var key:String in keyToVal) {
				str += key + ":" + keyToVal[key] + ",";
			}
			str = str.substring(0, str.length-1);
			return str;
		}
		
	}

}