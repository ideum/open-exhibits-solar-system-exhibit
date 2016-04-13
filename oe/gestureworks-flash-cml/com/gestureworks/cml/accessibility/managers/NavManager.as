package com.gestureworks.cml.accessibility.managers {
	import com.gestureworks.analysis.VectorMetric;
	import com.gestureworks.cml.accessibility.Nav;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	public class NavManager extends EventDispatcher {
		private var _root:Nav;
		private var _context:Nav;
		private var _focus:Nav;
		
		public function NavManager(root:Nav) {
			super();
			_root = root;
		}
		
		public function init():void {
			reset();
		}
		
		public function reset():void {
			_context = null;
			focus = _root;
		}
		
		public function next():Boolean {
			var list:Vector.<Nav> = focus.navSiblings;
			var index:int = list.indexOf(focus);
			index++;
			if (index < list.length) {
				focus = list[index];
				return true;
			}
			return false;
		}
		
		public function prev():Boolean {
			var list:Vector.<Nav> = focus.navSiblings;
			var index:int = list.indexOf(focus);
			index--;
			if (index>=0) {
				focus = list[index];
				return true;
			}
			return false;
		}
		
		public function into():Boolean {
			var list:Vector.<Nav> = _context.navChildren;
			if (list.length > 0) {
				focus = list[0];
				return true;
			}
			return false;
		}
		
		public function outOf():Boolean {
			if (_context != root) {
				_focus = _context;
				context = context.navParent;
			}
			return false;
		}
		
		public function switchFocusAndSelection():void {
			var t:Nav = _focus;
			_focus = _context;
			context = t;
		}
		
		public function selectCurrentFocus():void {
			focus = _context;
		}
		
		public function get onRoot():Boolean {
			return focus == root;
		}
		
		public function get focus():Nav {
			return _focus;
		}
		
		public function set focus(value:Nav):void {
			if (_focus != value) {
				_focus = value;
			}
		}
		
		public function get context():Nav {
			return _context;
		}
		
		public function set context(value:Nav):void {
			if (_context != value) {
				_context = value;
			}
		}
		
		public function get root():Nav {
			return _root;
		}
	}
	
}