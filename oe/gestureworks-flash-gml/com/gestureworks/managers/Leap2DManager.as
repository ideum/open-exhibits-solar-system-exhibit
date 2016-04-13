package com.gestureworks.managers 
{

	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.interfaces.ITouchObject;
	import com.leapmotion.leap.events.LeapEvent;
	import com.leapmotion.leap.Pointable;
	import com.leapmotion.leap.Vector3;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.*;
	
	/**
	 * @author
	 */
	public class Leap2DManager extends LeapManager
	{				
		private var activePoints:Array;		
		
		private var _minX:Number = -180;
		private var _maxX:Number = 180;
		
		private var _minY:Number = 75;
		private var _maxY:Number = 270;
		
		private var _minZ:Number = -110;
		private var _maxZ:Number = 200;
		
		private var _pressureThreshold:Number = 1;
		
		private var _overlays:Vector.<ITouchObject> = new Vector.<ITouchObject>();		
		
		/**
		 * The Leap2DManager constructor allows arguments for screen and leap device calibration settings. The settings will map x and y Leap coordinate ranges to screen 
		 * coordinates and the Leap z range to pressure. The calibration is only valid as long as the relative position of the Leap device and the monitor remain constant. 
		 * @param	minX minimum Leap X coordinate
		 * @param	maxX maximum Leap X coordinate
		 * @param	minY minimum Leap Y coordinate
		 * @param	maxY maximum Leap Y coordinate
		 * @param	minZ minimum Leap Z coordinate
		 * @param	maxZ maximum Leap Z coordinate
		 */
		public function Leap2DManager(minX:Number=0, maxX:Number=0, minY:Number=0, maxY:Number=0, minZ:Number=0, maxZ:Number=0) 
		{
			super();
			activePoints = new Array();
			//only allow leap touch
			//WILL NEED TO COMMENT OUT
			//GestureWorks.supportsTouch = false;

			
			if (minX) this.minX = minX;
			if (maxX) this.maxX = maxX;
			if (minY) this.minY = minY;
			if (maxY) this.maxY = maxY;
			if (minZ) this.minZ = minZ;
			if (maxZ) this.maxZ = maxZ;
		}
		
		/**
		 * Process points
		 * @param	event
		 */
		override protected function onFrame(event:LeapEvent):void 
		{
			if (!stage) return;
			super.onFrame(event);
			
			//store frame's point ids
			var pids:Array = new Array();
			for each(var pointable:Pointable in event.frame.pointables){
				pids.push(pointable.id);
			}
				
			//point removal
			var temp:Array = activePoints;  //prevent concurrent mods
			for each(var aid:Number in activePoints) {
				if (pids.indexOf(aid) == -1) {
					temp.splice(temp.indexOf(aid), 1);
					TouchManager.onTouchUp(new GWTouchEvent(null,GWTouchEvent.TOUCH_END, true, false, aid, false));
					if(debug)
						trace("REMOVED:", aid, event.frame.pointable(aid));					
				}
			}
			activePoints = temp;

			//point addition and update
			for each(var pid:Number in pids) {
				var tip:Vector3 = event.frame.pointable(pid).tipPosition;
				var point:Point = new Point();
					point.x = map(tip.x, minX, maxX, 0, stage.stageWidth);
					point.y = map(tip.y, minY, maxY, stage.stageHeight, 0);
				var pressure:Number = map(tip.z, minZ, maxZ, 0, 1);
				
				if (debug)
					trace("tip z:", tip.z, pressure);

				if (activePoints.indexOf(pid) == -1) {								
					
					var ev:GWTouchEvent;
					//hit test
					var obj:* = getTopDisplayObjectUnderPoint(point);
					
					if ((obj || overlays.length) && pressure <= pressureThreshold) {
						activePoints.push(pid);	
						ev = new GWTouchEvent(null, GWTouchEvent.TOUCH_BEGIN, true, false, pid, false, point.x, point.y);
							ev.stageX = point.x;
							ev.stageY = point.y;
							ev.pressure = pressure;
							ev.source = getDefinitionByName(getQualifiedClassName(this)) as Class;
							
							if (obj) {
								ev.target = obj;
								TouchManager.onTouchDown(ev);
							}
							
							//global overlays
							if (overlays.length) {
								TouchManager.processOverlays(ev, overlays);
							}
					}
					
					if(debug)
						trace("ADDED:", pid, event.frame.pointable(pid));	
				}
				else {
					if (activePoints.indexOf(pid) != -1 && pressure > pressureThreshold){
						activePoints.splice(activePoints.indexOf(pid), 1);
						ev = new GWTouchEvent(null, GWTouchEvent.TOUCH_END, true, false, pid, false);
						TouchManager.onTouchUp(ev);
						
						if (overlays.length) {
							TouchManager.processOverlays(ev, overlays);
						}						
						
						if (debug)
							trace("REMOVED:", pid, event.frame.pointable(pid));					
					}
					else{
						ev = new GWTouchEvent(null, GWTouchEvent.TOUCH_MOVE, true, false, pid, false, point.x, point.y);
							ev.stageX = point.x;
							ev.stageY = point.y;
							ev.pressure = pressure;
						TouchManager.onTouchMove(ev);
												
						if (overlays.length) {
							TouchManager.processOverlays(ev, overlays);
						}												
						
						if(debug)
							trace("UPDATE:", pid, event.frame.pointable(pid));							
					}
				}
			}
		}

		/**
		 * Hit test
		 * @param	point
		 * @return
		*/ 
		private function getTopDisplayObjectUnderPoint(point:Point):DisplayObject {
			var targets:Array =  stage.getObjectsUnderPoint(point);
			var item:DisplayObject = (targets.length > 0) ? targets[targets.length - 1] : stage;
			item = resolveTarget(item);
									
			return item;
		}	
		
		/**
		 * Determines the hit target based on mouseChildren settings of the ancestors
		 * @param	target
		 * @return
		 */
		private function resolveTarget(target:DisplayObject):DisplayObject {
			var ancestors:Array = targetAncestors(target, new Array(target));			
			var trueTarget:DisplayObject = target;
			
			for each(var t:DisplayObject in ancestors) {
				if (t is DisplayObjectContainer && !DisplayObjectContainer(t).mouseChildren)
				{
					trueTarget = t;
					break;
				}
			}
			
			return trueTarget;
		}
				
		/**
		 * Returns a list of the supplied target's ancestors sorted from highest to lowest
		 * @param	target
		 * @param	ancestors
		 * @return
		 */
		private function targetAncestors(target:DisplayObject, ancestors:Array = null):Array {
			
			if (!ancestors)
				ancestors = new Array();
				
			if (!target.parent || target.parent == target.root)
				return ancestors;
			else {
				ancestors.unshift(target.parent);
				ancestors = targetAncestors(target.parent, ancestors);
			}
			
			return ancestors;
		}
		
		/**
		 * The lowest x of the Leap x-coordinate range
		 * @default -180
		 */
		public function get minX():Number { return _minX; }
		public function set minX(x:Number):void {
			_minX = x;
		}
		
		/**
		 * The highest x of the Leap x-coordinate range
		 * @default 180
		 */
		public function get maxX():Number { return _maxX; }
		public function set maxX(x:Number):void {
			_maxX = x;
		}
		
		/**
		 * The lowest y of the Leap y-coordinate range
		 * @default 75
		 */
		public function get minY():Number { return _minY; }
		public function set minY(y:Number):void {
			_minY = y;
		}
		
		/**
		 * The highest y of the Leap y-coordinate range
		 * @default 270
		 */
		public function get maxY():Number { return _maxY; }
		public function set maxY(x:Number):void {
			_maxY = x;
		}
		
		/**
		 * The lowest z of the Leap z-coordinate range. Mapped to touch pressure. 
		 * @default -110
		 */
		public function get minZ():Number { return _minZ; }
		public function set minZ(z:Number):void {
			_minZ = z;
		}
		
		/**
		 * The highest z of the Leap z-coordinate range. Mapped to touch pressure. 
		 * @default 200
		 */
		public function get maxZ():Number { return _maxZ; }
		public function set maxZ(z:Number):void {
			_maxZ = z;
		}	
		
		/**
		 * Defines a point registration threshold, based on pressure(Z coordinate), providing the control to decrease
		 * the entry point of the device's interactive field. 
		 * @default 1
		 */
		public function get pressureThreshold():Number { return _pressureThreshold; }
		public function set pressureThreshold(p:Number):void {
			_pressureThreshold = p;
		}
		
		/**
		 * Registers global overlays to receive point data
		 */
		public function get overlays():Vector.<ITouchObject> { return _overlays; }
		public function set overlays(o:Vector.<ITouchObject>):void {
			_overlays = o;
		}
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			activePoints = null;
		}
	}

}