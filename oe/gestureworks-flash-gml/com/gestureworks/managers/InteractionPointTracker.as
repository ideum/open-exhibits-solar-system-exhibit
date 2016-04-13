package com.gestureworks.managers 
{
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWInteractionEvent;
	import com.gestureworks.objects.MotionPointObject;
	import com.gestureworks.objects.InteractionPointObject;
	
	import com.gestureworks.core.GestureWorksCore;
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.gw_public;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	
	/**
	 * @author
	 */
	public class InteractionPointTracker
	{				
		private static var activePoints:Vector.<InteractionPointObject>;
		public static var framePoints:Vector.<InteractionPointObject>;
		private static var temp_framePoints:Vector.<InteractionPointObject>;
		
		private static var ap:InteractionPointObject;
		private static var fp:InteractionPointObject;
		private static var _ID:uint = 0;
		
		private static var d2:Number = 30;//40
		private static var d1:Number = 0;
		private static var debug:Boolean = false;
		
		public static function initialize():void
		{
			activePoints = new Vector.<InteractionPointObject>;
			framePoints = new Vector.<InteractionPointObject>;
			temp_framePoints = new Vector.<InteractionPointObject>;
			//trace("i manager init");
		}
		
		
		public static function clearFrame():void 
		{
			framePoints = new Vector.<InteractionPointObject>();
		}
		
		public static function getFramePoints():void 
		{
			temp_framePoints = framePoints;
		}
		
		
		/**
		 * Process points
		 * @param event
		 */
		public static function getActivePoints():void 
		{
			// copy active list
			getFramePoints();
			
			//refresh frame ready to fill
			clearFrame();

			
				//trace("active points",activePoints.length,temp_framePoints.length, framePoints.length, activePoints.length);

				//////////////////////////////////////////////////////////////////////
				// REMOVE from ap if not in fp
				// WILL REMOVE ALL IF NO POINTS IN FRAME
				for each(ap in activePoints) 
				{
					var found:Boolean = false;
					
						for each(fp in temp_framePoints)
						{
							var dist:Number = Math.abs(Vector3D.distance(ap.position, fp.position));
							if ((ap.type == fp.type)&&(dist < d2)) found = true;
						}
						
						if (!found) 
						{
							activePoints.splice(activePoints.indexOf(ap), 1);
							InteractionManager.onInteractionEnd(new GWInteractionEvent(GWInteractionEvent.INTERACTION_END, ap, true, false)); //push update event
							if(debug) trace("an!=0 REMOVED:", ap.id, ap.interactionPointID, ap.type, ap.position);
						}
				}
					//////////////////////////////////////////////////////////////////
					// UPDATE ap if in fp
					for each(ap in activePoints)
						{
						for each(fp in temp_framePoints)
							{
							if (ap.type == fp.type)
							{
							var dist0:Number = Math.abs(Vector3D.distance(ap.position, fp.position));
							//trace("dist",dist,ap.type,fp.type)
							
							if (dist0 < d2)  ////update
								{
									ap.position = fp.position;
									ap.direction = fp.direction;
									ap.normal = fp.normal;
									
									// advanced ip features
									ap.fist = fp.fist;
									ap.splay = fp.splay;
									ap.orientation = fp.orientation;
									ap.sphereRadius = fp.sphereRadius;
									ap.flatness = fp.flatness;
									ap.fn = fp.fn;
									
									ap.handID = fp.handID;
									ap.type = fp.type;
									
									temp_framePoints.splice(temp_framePoints.indexOf(fp), 1);
										
									InteractionManager.onInteractionUpdate(new GWInteractionEvent(GWInteractionEvent.INTERACTION_UPDATE, ap, true, false)); //push update event
									if(debug) trace("UPDATE:",ap.id, ap.interactionPointID,ap.type, ap.position, dist0);	
								}
							}
						}	
					}
					
					///////////////////////////////////////////////////////////////////
					// ADD NEW POINTS TO ACTIVE will add (WHEN an!=0)
					for each(fp in temp_framePoints)
					{
						_ID++;
						fp.interactionPointID = _ID;
						activePoints.push(fp);
						InteractionManager.onInteractionBegin(new GWInteractionEvent(GWInteractionEvent.INTERACTION_BEGIN, fp, true, false)); // push begin event
						//if (debug) trace("an!=0 ADDED:", fp.id, fp.interactionPointID, fp.type, fp.position);
					}
					
					/*
					// check for duplicates (paulis exclusion principle)
					for (var i:int = 0; i < activePoints.length; i++)
					{
						for (var j:int = 0; j < activePoints.length; j++)
						{
							if ((i != j) && (activePoints[i].position == activePoints[j].position) && (activePoints[i].type == activePoints[j].type)) 
							{
								trace("duplicate");
							}
						}
					}
					*/
					
		}

			
		/**
		 * Hit test
		 * @param	point
		 * @return
		*/ 
		private function getTopDisplayObjectUnderPoint(point:Point):DisplayObject 
		{
			var targets:Array = new Array() //=  stage.getObjectsUnderPoint(point);
			var item:DisplayObject //= (targets.length > 0) ? targets[targets.length - 1] : stage;
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
			
			
			
					
			
	}
}