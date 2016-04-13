////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    MotionManager.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.managers
{
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.gw_public;
	import com.gestureworks.core.TouchMovieClip;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWInteractionEvent;
	import com.gestureworks.interfaces.ITouchObject3D;
	import com.gestureworks.managers.InteractionPointTracker;
	import com.gestureworks.objects.InteractionPointObject;
	import flash.utils.Dictionary;
	
	
		
	public class InteractionManager 
	{	
		public static var ipoints:Dictionary = new Dictionary();
		public static var touchObjects:Dictionary = new Dictionary();
		private static var gms:TouchSprite;
		private static var sw:int;
		private static var sh:int;
		
		private static var minX:Number
		private static var maxX:Number
		private static var minY:Number
		private static var maxY:Number
		private static var minZ:Number
		private static var maxZ:Number
		
		public static var hitTest3D:Function;
		
		gw_public static function initialize():void

		{
			//trace("interaction manager init");
			///////////////////////////////////////////////////////////////////////////////////////
			// ref gloabl motion point list
			ipoints = GestureGlobals.gw_public::interactionPoints;
			touchObjects = GestureGlobals.gw_public::touchObjects;
			
			// init interaction point manager
			InteractionPointTracker.initialize();
			
			gms = GestureGlobals.gw_public::touchObjects[GestureGlobals.motionSpriteID];
			
			sw = GestureWorks.application.stageWidth
			sh = GestureWorks.application.stageHeight;
			
			minX = GestureGlobals.gw_public::leapMinX;
			maxX = GestureGlobals.gw_public::leapMaxX;
			minY = GestureGlobals.gw_public::leapMinY;
			maxY = GestureGlobals.gw_public::leapMaxY;
			minZ = GestureGlobals.gw_public::leapMinZ;
			maxZ = GestureGlobals.gw_public::leapMaxZ;

			/////////////////////////////////////////////////////////////////////////////////////////
			//DRIVES UPDATES ON POINT LIFETIME
			//GestureWorks.application.addEventListener(GWInteractionEvent.INTERACTION_END, onInteractionEnd);
			//GestureWorks.application.addEventListener(GWInteractionEvent.INTERACTION_BEGIN, onInteractionBegin);
			//GestureWorks.application.addEventListener(GWInteractionEvent.INTERACTION_UPDATE, onInteractionUpdate);
		}
		
		gw_public static function deInitialize():void
		{
			//GestureWorks.application.removeEventListener(GWInteractionEvent.INTERACTION_END, onInteractionEnd);
			//GestureWorks.application.removeEventListener(GWInteractionEvent.INTERACTION_BEGIN, onInteractionBegin);
			//GestureWorks.application.removeEventListener(GWInteractionEvent.INTERACTION_UPDATE, onInteractionUpdate);
		}

		
		
		// registers touch point via touchSprite
		public static function registerInteractionPoint(ipo:InteractionPointObject):void
		{
			ipo.history.unshift(InteractionPointHistories.historyObject(ipo))
		}
		
		
		public static function onInteractionBegin(event:GWInteractionEvent):void
		{			
			//trace("interaction point begin, interactionManager",event.value.interactionPointID);
			
			//NEED IP COUNT FOR ID
			//for each(var tO:Object in touchObjects)
			//{
				// DUPE CORE IP LIST FOR NOW
				// create new interaction point clone for each interactive display object 
				var ipO:InteractionPointObject  = new InteractionPointObject();	
				
						ipO.id = gms.interactionPointCount; // NEEDED FOR THUMBID
						ipO.interactionPointID = event.value.interactionPointID;
						ipO.handID = event.value.handID;
						ipO.type = event.value.type;
						
						ipO.position = event.value.position;
						ipO.direction = event.value.direction;
						ipO.normal = event.value.normal;
						ipO.velocity = event.value.velocity;

						ipO.sphereCenter = event.value.sphereCenter;
						ipO.sphereRadius = event.value.sphereRadius;
						
						ipO.length = event.value.length;
						ipO.width = event.value.width;
						
						//ADVANCED IP PROEPRTIES
						ipO.flatness = event.value.flatness;
						ipO.orientation = event.value.orientation;
						ipO.fn = event.value.fn;
						ipO.splay = event.value.splay;
						ipO.fist = event.value.fist;
						
						ipO.phase = "begin"
						//trace(ipO.interactionPointID)
						
						
				
				
				////////////////////////////////////////////
				//ADD TO GLOBAL Interaction POINT LIST
				gms.cO.iPointArray.push(ipO);
				
				//trace("ip begin",ipO.type)
				
				///////////////////////////////////////////////////////////////////
				// ADD TO LOCAL OBJECT Interaction POINT LIST
				for each(var tO:Object in touchObjects)
				{
					if ((tO.motionClusterMode == "local_strong")&&(tO.tc.ipSupported(ipO.type)))
					{
						var xh:Number = normalize(ipO.position.x, minX, maxX) * sw;//tO.stage.stageWidth;//1920
						var yh:Number = normalize(ipO.position.y, minY, maxY) * sh;//tO.stage.stageHeight; //1080
						
						// 2D HIT TEST FOR 2D OBJECT
						if ((tO is TouchSprite)||(tO is TouchMovieClip))//ITouchObject
						{
							//trace("2d hit test");			
							if (tO.hitTestPoint(xh, yh, false)) tO.cO.iPointArray.push(ipO);
						}			
						//2D HIT TEST ON 3D OBJECT
						if (tO is ITouchObject3D) //ITouchObject //TouchObject3D
						{
							if (hitTest3D != null) {
								 //trace("3d hit test",hitTest3D(tO as ITouchObject3D, tO.view, xh, yh),tO, tO.vto,tO.name, tO.view, tO as TouchContainer3D)
								if (hitTest3D(tO as ITouchObject3D, xh, yh)==true) {
									tO.cO.iPointArray.push(ipO);								
								}
							}
							

						}
							
					}
					//else if if ((tO.motionClusterMode == "local_strong")&&(tO.tc.ipSupported(ipO.type)))
					//{
						
					//}
				}
				
				
				
				// update local touch object point count
				gms.interactionPointCount++;

				///////////////////////////////////////////////////////////////////////////
				// ASSIGN POINT OBJECT WITH GLOBAL POINT LIST DICTIONARY
				GestureGlobals.gw_public::interactionPoints[event.value.interactionPointID] = ipO;
					
				////////////////////////////////////////////////////////////////////////////
				// REGISTER TOUCH POINT WITH TOUCH MANAGER
				registerInteractionPoint(ipO);
			//}
			
			//trace("gms ipointArray length",gms.cO.iPointArray.length,ipO.position )
		}
		
		
		// stage motion end
		public static function onInteractionEnd(event:GWInteractionEvent):void
		{
			
			var iPID:int = event.value.interactionPointID;
			var ipointObject:InteractionPointObject = ipoints[iPID];
			//trace("Motion point End, motionManager", iPID)
			
			if (ipointObject)
			{
				ipointObject.phase="end"
				
					// REMOVE POINT FROM GLOBAL LIST
					gms.cO.iPointArray.splice(ipointObject.id, 1);
					
					// REMOVE FROM LOCAL OBJECTES
					for each(var tO:Object in touchObjects)
					{
						if (tO.motionClusterMode=="local_strong") tO.cO.iPointArray.splice(ipointObject.id, 1);
					}
					
					
					// REDUCE LOACAL POINT COUNT
					gms.interactionPointCount--;
					
					// UPDATE POINT ID 
					for (var i:int = 0; i < gms.cO.iPointArray.length; i++)
					{
						gms.cO.iPointArray[i].id = i;
					}
				
					// DELETE FROM GLOBAL POINT LIST
					delete ipoints[event.value.interactionPointID];
			}
			
			//trace("interaction point end",gms.interactionPointCount)
		}
		
	
		// the Stage TOUCH_MOVE event.	// DRIVES POINT PATH UPDATES
		public static function onInteractionUpdate(event:GWInteractionEvent):void
		{			
			//  CONSOLODATED UPDATE METHOD FOR POINT POSITION AND TOUCH OBJECT CALCULATIONS
			var ipO:InteractionPointObject = ipoints[event.value.interactionPointID];
			
			//trace("interaction move event, interactionsManager", event.value.interactionPointID);
			
				if (ipO)
				{	
					//mpO = event.value;
					ipO.interactionPointID  = event.value.interactionPointID;
					ipO.position = event.value.position;
					ipO.direction = event.value.direction;
					ipO.normal = event.value.normal;
					ipO.velocity = event.value.velocity;
					
					ipO.sphereRadius = event.value.sphereRadius;
					ipO.sphereCenter = event.value.sphereCenter;
					
					ipO.length = event.value.length;
					ipO.width = event.value.width;
					
					ipO.flatness = event.value.flatness;
					ipO.orientation = event.value.orientation;
					ipO.fn = event.value.fn;
					ipO.splay = event.value.splay;
					ipO.fist = event.value.fist;
					
					ipO.phase = "update"
					//mpO.handID = event.value.handID;
					//ipO.moveCount ++;
					
					//trace("gms ipointArray length",gms.cO.iPointArray.length,ipO.position )
				}
				

				// UPDATE POINT HISTORY 
				InteractionPointHistories.historyQueue(event);
		}	
	
		
		private static function normalize(value : Number, minimum : Number, maximum : Number) : Number {

                        return (value - minimum) / (maximum - minimum);
         }
		
		
		
	}
}