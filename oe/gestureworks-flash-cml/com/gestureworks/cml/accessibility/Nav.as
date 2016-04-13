package com.gestureworks.cml.accessibility {
	
	import com.gestureworks.cml.accessibility.ErrorResponse;
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.interfaces.ISpeech;
	import com.gestureworks.cml.utils.document;
	import com.gestureworks.cml.utils.Log;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	public class Nav extends TouchContainer { 
		
		private var _title:String;
		private var _desc:String;
		
		public function Nav(title:String = "", desc:String = "") {
			super();
			_title = title;
			_desc = desc;
		}
		
		public function get navParent():Nav {
			for (var i:DisplayObjectContainer = this; i.parent != null; i = i.parent) {
				if (i.parent is Nav) {
					return i.parent as Nav;
				}
			}
			return null;
		}
		
		public function get navChildren():Vector.<Nav> {
			var children:Vector.<Nav> = new Vector.<Nav>();
			var iLen:int = numChildren;
			var child:DisplayObject;
			for (var i:int = 0; i < iLen; i++) {
				child = getChildAt(i);
				if (child is Nav) {
					children.push(child as Nav);
				}
			}
			return children;
		}
		
		public function get numNavChildren():int {
			var count:int = 0;
			var iLen:int = numChildren;
			var child:DisplayObject;
			for (var i:int = 0; i < iLen; i++) {
				child = getChildAt(i);
				if (child is Nav) {
					count++;
				}
			}
			return count;
		}
		
		/**
		 * includes this Nav object
		 */
		public function get navSiblings():Vector.<Nav> {
			var sib:Vector.<Nav> = new Vector.<Nav>();
			var i:int;
			var iLen:int = parent.numChildren;
			var child:DisplayObject
			for (i = 0; i < iLen; i++) {
				child = parent.getChildAt(i);
				if (child is Nav) {
					sib.push(child as Nav);
				}
			}
			return sib;
		}
		
		public function get numNavSiblings():int {
			var count:int = 0;
			var iLen:int = parent.numChildren;
			var child:DisplayObject;
			for (var i:int = 0; i < iLen; i++) {
				child = parent.getChildAt(i);
				if (child is Nav) {
					count++;
				}
			}
			return count;
		}
		
		public function get isLastNavChild():Boolean {
			var navSib:Vector.<Nav> = navSiblings;
			if (navSib.length == 1) {
				return true;
			} else if (navSib[navSib.length - 1] == this) {
				return true;
			}
			return false;
		}
		
		public function get isOnlyNavChild():Boolean {
			return (numNavSiblings == 1);
		}
		
		//short 'preview' text
		public function get titleContent():String {
			
			var provider:ISpeech = document.getElementById(_title);
			if (provider == null) {
				provider = new ErrorResponse();
				Log.message.out("Could not getElementById( "+_title+" ) from titleContent in Nav.as", Log.ERROR);
			}
			return provider.speechContent;
			
		}
		
		//full in-depth text
		public function get descContent():String {
			
			var provider:ISpeech = document.getElementById(_desc);
			if (provider == null) {
				provider = new ErrorResponse();
				Log.message.out("Could not getElementById( "+_desc+" ) from descContent in Nav.as", Log.ERROR);
			}
			return provider.speechContent;
			
		}
		
		public function get title():String { return _title; }		
		public function set title(value:String):void {
			_title = value;
		}
		
		public function get desc():String { return _desc; }	
		public function set desc(value:String):void {
			_desc = value;
		}		
	}
}
