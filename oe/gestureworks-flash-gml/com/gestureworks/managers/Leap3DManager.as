package com.gestureworks.managers 
{
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWMotionEvent;
	import com.gestureworks.objects.MotionPointObject;
	import flash.geom.Vector3D;
	import flash.geom.Matrix;
	
	import com.leapmotion.leap.events.LeapEvent;
	import com.leapmotion.leap.Pointable;
	import com.leapmotion.leap.Vector3;
	import com.leapmotion.leap.Hand;
	
	import flash.display.DisplayObject;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	/**
	 * @author
	 */
	public class Leap3DManager extends LeapManager
	{				
		private var activePoints:Array;
		
		///////////////////////////////////////
		// USED TO FIT 3D VIEW 
		///////////////////////////////////////
		private var _minX:Number = -200;
		private var _maxX:Number = 200;
		
		private var _minY:Number = -100;
		private var _maxY:Number = 100;
		
		private var _minZ:Number = -200;
		private var _maxZ:Number = 200;
		
		
		
		///////////////////////////////////////
		// INTERNAL CAP RAW LEAP DEVICE VALUES
		//////////////////////////////////////
		private var lminX:Number = -300;
		private var lmaxX:Number = 275;
		
		private var lminY:Number = 40;
		private var lmaxY:Number = 400;
		
		private var lminZ:Number = -200;
		private var lmaxZ:Number = 200;
		
		
		
		//private var motionPointID:int = 0;
		
		public function Leap3DManager(minX:Number=0, maxX:Number=0, minY:Number=0, maxY:Number=0, minZ:Number=0, maxZ:Number=0) 
		{
			super();
			activePoints = new Array();
			
			//if(debug)
				//trace("leap 3d manager init");
				
				
			//if (minX) this.minX = minX;
			//if (maxX) this.maxX = maxX;
			//if (minY) this.minY = minY;
			//if (maxY) this.maxY = maxY;
			//if (minZ) this.minZ = minZ;
			//if (maxZ) this.maxZ = maxZ;	
				
		}
		
		/**
		 * Process points
		 * @param	event
		 */
		override protected function onFrame(event:LeapEvent):void 
		{
			super.onFrame(event);
			
			//store frame's point ids
			var pids:Array = new Array();
			
			//CREATE HANDS THEN... FINGERS AND TOOLS
			
			//store hand ids
			for each(var hand:Hand in event.frame.hands){
				if(hand) pids.push(hand.id);//if(hand.isValid)
				//trace("handid", hand.id);
			}
			// store poitnables ids
			// is valid does not seem to be effective here
			for each(var pointable:Pointable in event.frame.pointables){
				if (pointable){
					if (pointable.hand) pids.push(pointable.id);
					//trace("pointid", pointable.id);
				}
			}
			
			
			
			//trace("pids",pids.length,"active points", activePoints.length)
			
			//point removal
			var temp:Array = activePoints;  //prevent concurrent mods
			for each(var aid:Number in activePoints) {
				
				if (pids.indexOf(aid) == -1) {
					
					temp.splice(temp.indexOf(aid), 1);
					
					var mp:MotionPointObject = new MotionPointObject();
						//mp.type = "motion";
						mp.motionPointID = aid;
						
						//determin type
						if (event.frame.pointable(aid).isTool) mp.type = "tool";
						if (event.frame.pointable(aid).isFinger) mp.type = "finger";
						else mp.type = "palm";
						//else (mp.type = "unknown")
						
						//trace("mp type",mp.type);
						
						/////////////////////////////////////////
						//create palm point
						if (mp.type == "palm") 
						{
							for (var i:int = 0; i < event.frame.hands.length; i++) 
							{
								if (aid == event.frame.hands[i].id) 
								{
									mp.handID = event.frame.hand[i].id;
									
									//var xp0:Number = normalize( event.frame.hands[i].palmPosition.x, minX, maxX)*1000;
									//var yp0:Number = normalize(event.frame.hands[i].palmPosition.y, minY, maxY)*1000;
									//var zp0:Number = normalize( -1*event.frame.hands[i].palmPosition.z, minZ, maxZ)*1000;

									//var xp0:Number = map(event.frame.hands[i].palmPosition.x, lminX, lmaxX, minX, maxX);
									//var yp0:Number = map(event.frame.hands[i].palmPosition.y, lminY, lmaxY, minY, maxY);
									//var zp0:Number = map(-1*event.frame.hands[i].palmPosition.z, lminZ, lmaxZ, minZ, maxZ);
									
									mp.position = new Vector3D( event.frame.hands[i].palmPosition.x, event.frame.hands[i].palmPosition.y, event.frame.hands[i].palmPosition.z * -1);
									//mp.position = new Vector3D(xp0,yp0,zp0);
									mp.direction = new Vector3D(event.frame.hands[i].direction.x, event.frame.hands[i].direction.y, event.frame.hands[i].direction.z*-1);
									mp.normal = new Vector3D(event.frame.hands[i].palmNormal.x, event.frame.hands[i].palmNormal.y, event.frame.hands[i].palmNormal.z*-1);
									mp.velocity = new Vector3D(event.frame.hands[i].palmVelocity.x, event.frame.hands[i].palmVelocity.y, event.frame.hands[i].palmVelocity.z*-1);
									
									mp.sphereCenter = new Vector3D(event.frame.hands[i].sphereCenter.x, event.frame.hands[i].sphereCenter.y, event.frame.hands[i].sphereCenter.z*-1);
									mp.sphereRadius = event.frame.hands[i].sphereRadius
									
									// cutom leap matrix
									//mp.rotation = event.frame.hands[i].rotation;
								}
							}
						}
						//////////////////////////////////////////
						//create finger or tool type
						if ((mp.type == "finger") || (mp.type == "tool"))
						{
							if (event.frame.pointable(aid).hand) {
								mp.handID = event.frame.pointable(aid).hand.id
								//trace("point hand id",mp.handID);
							}
							
							//var x0:Number = normalize( event.frame.pointable(aid).tipPosition.x, minX, maxX)*1000;
							//var y0:Number = normalize( event.frame.pointable(aid).tipPosition.y, minY, maxY)*1000;
							//var z0:Number = normalize( -1*event.frame.pointable(aid).tipPosition.z, minZ, maxZ)*1000;
							
							//var x0:Number = map( event.frame.pointable(aid).tipPosition.x, lminX, lmaxX, minX, maxX);
							//var y0:Number = map(event.frame.pointable(aid).tipPosition.y, lminY, lmaxY, minY, maxY);
							//var z0:Number = map(-1*event.frame.pointable(aid).tipPosition.z, lminZ, lmaxZ, minZ, maxZ);

							mp.position = new Vector3D(event.frame.pointable(aid).tipPosition.x, mp.position.y = event.frame.pointable(aid).tipPosition.y, mp.position.z = event.frame.pointable(aid).tipPosition.z*-1);
							//mp.position = new Vector3D(x0,y0,z0);
							mp.direction = new Vector3D(event.frame.pointable(aid).direction.x, event.frame.pointable(aid).direction.y, event.frame.pointable(aid).direction.z*-1);
							mp.velocity = new Vector3D(event.frame.pointable(aid).tipVelocity.x, event.frame.pointable(aid).tipVelocity.y, event.frame.pointable(aid).tipVelocity.z*-1);
							
							//size
							//mp.width = event.frame.pointable(aid).width;
							//mp.length = event.frame.pointable(aid).length;
						}
						
						
						
						
					MotionManager.onMotionEnd(new GWMotionEvent(GWMotionEvent.MOTION_END,mp, true,false));
					if(debug)
						trace("REMOVED:",mp.id, mp.motionPointID, aid, event.frame.pointable(aid));					
				}
			}
			activePoints = temp;

			//point addition and update
			for each(var pid:Number in pids) {
				
				var tip:Vector3 = event.frame.pointable(pid).tipPosition;
				
				mp = new MotionPointObject();
					mp.motionPointID = pid;
					
					if (event.frame.pointable(pid).isTool) {
						mp.type = "tool";
						//trace("leap 3d tracker mp type",mp.type);
					}
					if (event.frame.pointable(pid).isFinger) mp.type = "finger";
					else mp.type = "palm";
					
					
					// create palm point
					if (mp.type == "palm") 
					{
							for (var k:int = 0; k < event.frame.hands.length; k++) 
							{
								if (pid == event.frame.hands[k].id) 
								{
								mp.handID = event.frame.hands[k].id;
								
								//var xp:Number = normalize( event.frame.hands[k].palmPosition.x, minX, maxX)*1000;
								//var yp:Number = normalize(event.frame.hands[k].palmPosition.y, minY, maxY)*1000;
								//var zp:Number = normalize( -1*event.frame.hands[k].palmPosition.z, minZ, maxZ)*1000;
								
								//var xp:Number = map(event.frame.hands[k].palmPosition.x, lminX, lmaxX, minX, maxX);
								//var yp:Number = map(event.frame.hands[k].palmPosition.y, lminY, lmaxY, minY, maxY);
								//var zp:Number = map(-1*event.frame.hands[k].palmPosition.z, lminZ, lmaxZ, minZ, maxZ);

								
								mp.position = new Vector3D( event.frame.hands[k].palmPosition.x, event.frame.hands[k].palmPosition.y, event.frame.hands[k].palmPosition.z * -1);
								//mp.position = new Vector3D( xp,yp,xp);
								mp.direction = new Vector3D(event.frame.hands[k].direction.x, event.frame.hands[k].direction.y, event.frame.hands[k].direction.z*-1);
								mp.normal = new Vector3D(event.frame.hands[k].palmNormal.x, event.frame.hands[k].palmNormal.y, event.frame.hands[k].palmNormal.z*-1);
								mp.velocity = new Vector3D(event.frame.hands[k].palmVelocity.x, event.frame.hands[k].palmVelocity.y, event.frame.hands[k].palmVelocity.z*-1);
			
								mp.sphereCenter = new Vector3D(event.frame.hands[k].sphereCenter.x, event.frame.hands[k].sphereCenter.y, event.frame.hands[k].sphereCenter.z*-1);
								mp.sphereRadius = event.frame.hands[k].sphereRadius;
								
								// custom leap matrix
								//mp.rotation = event.frame.hands[k].rotation;
								}
							}
					}
					
					
					// create finger or tool point
					if ((mp.type == "finger") || (mp.type == "tool"))
					{
						if (event.frame.pointable(pid).hand) {
							mp.handID = event.frame.pointable(pid).hand.id
							//trace("point hand id",mp.handID);
						}
						//trace(event.frame.pointable(pid).tipPosition.z)
						//var x:Number = normalize( event.frame.pointable(pid).tipPosition.x, minX, maxX)*1000;
						//var y:Number = normalize( event.frame.pointable(pid).tipPosition.y, minY, maxY)*1000;
						//var z:Number = normalize( -1*event.frame.pointable(pid).tipPosition.z, minZ, maxZ)*1000;
						
						//var x:Number = map(event.frame.pointable(pid).tipPosition.x, lminX, lmaxX, minX, maxX);
						//var y:Number = map(event.frame.pointable(pid).tipPosition.y, lminY, lmaxY, minY, maxY);
						//var z:Number = map(-1*event.frame.pointable(pid).tipPosition.z, lminZ, lmaxZ, minZ, maxZ);

						
						mp.position = new Vector3D( event.frame.pointable(pid).tipPosition.x, event.frame.pointable(pid).tipPosition.y, event.frame.pointable(pid).tipPosition.z*-1);
						//mp.position = new Vector3D(x,y,z);
						mp.direction = new Vector3D(event.frame.pointable(pid).direction.x, event.frame.pointable(pid).direction.y, event.frame.pointable(pid).direction.z*-1);
						mp.velocity = new Vector3D(event.frame.pointable(pid).tipVelocity.x, event.frame.pointable(pid).tipVelocity.y, event.frame.pointable(pid).tipVelocity.z*-1);

						//mp.width = event.frame.pointable(pid).width;
						//mp.length = event.frame.pointable(pid).length;
						
						//trace("width",mp.width,mp.length);
					}
					

					//trace("type manager", mp.type);
					

				if (activePoints.indexOf(pid) == -1) 
				{
					activePoints.push(pid);	
					MotionManager.onMotionBegin(new GWMotionEvent(GWMotionEvent.MOTION_BEGIN, mp, true, false));
						
					if(debug)
						trace("ADDED:",mp.id, mp.motionPointID, pid, event.frame.pointable(pid));	
				}
				else {
					MotionManager.onMotionMove(new GWMotionEvent(GWMotionEvent.MOTION_MOVE,mp, true, false));
					if(debug)
						trace("UPDATE:",mp.id, mp.motionPointID, pid);	
				}
			}	
			
			//trace("leap 3d motion frame processing");
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
		public function set maxY(y:Number):void {
			_maxY = y;
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
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			activePoints = null;
		}
		
		private static function normalize(value : Number, minimum : Number, maximum : Number) : Number {

                        return (value - minimum) / (maximum - minimum);
        }
		
		public static function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number
		{
			if (constrainMin && num < min1) return min2;
			if (constrainMax && num > max1) return max2;
		 
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
			if (round) return Math.round(num2);
			return num2;
		}
		
	}

}