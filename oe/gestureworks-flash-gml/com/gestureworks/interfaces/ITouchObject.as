package com.gestureworks.interfaces 
{
	import com.gestureworks.core.*;	
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.GestureListObject;
	import com.gestureworks.objects.PointObject;
	import com.gestureworks.objects.StrokeObject;
	import com.gestureworks.objects.TimelineObject;
	import com.gestureworks.objects.TransformObject;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	/**
	 * Implements touch object base classes (TouchSprite and TouchMovieClip)
	 * @author 
	 */
	public interface ITouchObject extends IEventDispatcher
	{
		
		/////////////////////////////////////////////////////////////
		////////////////////PROPERTIES
		/////////////////////////////////////////////////////////////
		
		/**
		 * Lazy gesture activation (objects will not be registered until gestureList assignment).
		 * @default false
		 */
		function get active():Boolean;
		function set active(a:Boolean):void; 
		
		/**
		 * Flag indicating the application of local modes over the global settings. By default, all objects are enabled for input
		 * processing based on the application level mode settings (i.e. nativeTouch, simulator, tuio, etc.). This flag allows the 
		 * inclusion/exclusion of specific input interaction according to local overrides. Note that the corresponding global setting
		 * must be enabled in order to locally enable the input. 
		 * @default false
		 */
		function get localModes():Boolean;
		function set localModes(l:Boolean):void;
			
		/**
		 * Local override to enable/disable native touch input.
		 * @see localModes
		 * @default false
		 */
		function get nativeTouch():Boolean;
		function set nativeTouch(n:Boolean):void;

		/**
		 * Local override to enable/disable mouse input.
		 * @see localModes
		 * @default false
		 */
		function get simulator():Boolean;
		function set simulator(s:Boolean):void;
		
		/**
		 * Local override to enable/disable tuio input.
		 * @see localModes
		 * @default false
		 */
		function get tuio():Boolean;
		function set tuio(t:Boolean):void;
		
		/**
		 * Local override to enable/disable leap2D input.
		 * @see localModes
		 * @default false
		 */
		function get leap2D():Boolean;
		function set leap2D(l:Boolean):void;		
		
		/**
		 * Unique id of the touch object
		 */
		function get touchObjectID():int;
		function set touchObjectID(id:int):void;

		/**
		 * @private
		 */
		function get pointArray():Vector.<PointObject>;
		function set pointArray(pa:Vector.<PointObject>):void;

		/**
		 * Number of points in the super cluster
		 * @private
		 */
		function get N():int;
		function set N(n:int):void;
		
		/**
		 * Number of touch points in the parent cluster
		 * @private
		 */
		function get tpn():int;
		function set tpn(n:int):void;
		
		/**
		 * Number of motion points in the parent cluster
		 * @private
		 */
		function get ipn():int;
		function set ipn(n:int):void;
		
		/**
		 * @private 
		 */
		function get dN():Number;
		function set dN(n:Number):void;
		
		/**
		 * @private
		 */
		function get cO():ClusterObject;
		function set cO(obj:ClusterObject):void;		
		
		/**
		 * @private
		 */
		function get sO():StrokeObject;
		function set sO(obj:StrokeObject):void;
		
		/**
		 * @private
		 */
		function get gO():GestureListObject;
		function set gO(obj:GestureListObject):void;	
		
		/**
		 * @private
		 */
		function get tiO():TimelineObject;
		function set tiO(obj:TimelineObject):void;
		
		/**
		 * @private
		 */
		function get trO():TransformObject;
		function set trO(obj:TransformObject):void;
		/**
		 * @private
		 */
		function get tc():TouchCluster;
		function set tc(obj:TouchCluster):void;
		
		/**
		 * @private
		 */
		function get tp():TouchPipeline;
		function set tp(obj:TouchPipeline):void;		
		
		/**
		 * @private
		 */
		function get tg():TouchGesture;
		function set tg(obj:TouchGesture):void;		
		
		/**
		 * @private
		 */
		function get tt():TouchTransform;
		function set tt(obj:TouchTransform):void;		
		
		/**
		 * @private
		 */
		function get visualizer():TouchVisualizer; 
		function set visualizer(obj:TouchVisualizer):void;				
		
		/**
		 * Debug trace statements
		 * @default false
		 */
		function get traceDebugMode():Boolean;
		function set traceDebugMode(value:Boolean):void;
		
		/**
		 * Total number of points registered with object and/or child objects regardless of gesture activation state 
		 */
		function get totalPointCount():int;
		function set totalPointCount(value:int):void;
		
		/**
		 * Number of points being processed for gesture-active objects
		 */
		function get pointCount():int;
		function set pointCount(value:int):void;
		
		/**
		 * 
		 */
		function get motionPointCount():int;
		function set motionPointCount(value:int):void;
		
		/**
		 * 
		 */
		function get interactionPointCount():int;
		function set interactionPointCount(value:int):void;
		
		/**
		 * 
		 */
		function get clusterID():int;
		function set clusterID(value:int):void;
		
		/**
		 * 
		 */
		function get gestureList():Object;
		function set gestureList(value:Object):void;
		
		/**
		 * Allows touch events to be passed down to child display object. Has the same function as MouseChildren.
		 * @default false
		 */
		function get touchChildren():Boolean;
		function set touchChildren(value:Boolean):void;
		
		/**
		 * Allows touch points from a childclusters to copy into container touch objects in the local parent child display list stack. This allows the for the concept of parallel
		 * clustering of touch point. Where a single touch point can simultaniuosly be a member of multiple touch point clusters. This allows multiple gestures to be dispatched 
		 * from multiple touch objects from a set of touch points.
		 * @default false
		 */
		function get clusterBubbling():Boolean;
		function set clusterBubbling(value:Boolean):void;
		
		/**
		 * Allows touch and gesture events to explicitly target the parent touch object
		 * @default false
		 */
		function get targetParent():Boolean;
		function set targetParent(value:Boolean):void;
		
		/**
		 * Allows touch and gesture events to explicitly target a group of defined touch objects which can be outside of the local parent child display list stack
		 */
		//function get targetList():*;
		//function set targetList(value:*):void;	
		
		/**
		 * Virtual transform object (non-TouchSprite) to transfer the transformations to
		 */		
		function get vto():Object;
		function set vto(value:Object):void;		
		
		/**
		 * Determines whether clusterEvents are processed and dispatched on the touchSprite.
		 * @default false
		 */
		function get clusterEvents():Boolean;
		function set clusterEvents(value:Boolean):void;
		
		/**
		 * Determines whether filtering is applied to the delta values.
		 * @default false
		 */
		function get deltaFilterOn():Boolean;
		function set deltaFilterOn(value:Boolean):void;
		
		/**
		 * Determines whether touch inertia is processed on the touchSprite.
		 * @default false
		 */
		function get gestureTouchInertia():Boolean;
		function set gestureTouchInertia(value:Boolean):void;
		
		/**
		 * Indicates whether any gestureEvents have been started on the touchSprite.
		 * @default true
		 */
		function get gestureEventStart():Boolean;
		function set gestureEventStart(value:Boolean):void;
		
		/**
		 * Indicates weather all gestureEvents have been completed on the touchSprite.
		 * @default true
		 */
		function get gestureEventComplete():Boolean;
		function set gestureEventComplete(value:Boolean):void;

		/**
		 * Indicates whether all touch points have been released on the touchSprite.
		 * @default true
		 */
		function get gestureEventRelease():Boolean;
		function set gestureEventRelease(value:Boolean):void;
		
		/**
		 * Determines whether gestureEvents are processed and dispatched on the touchSprite.
		 * @default true
		 */
		function get gestureEvents():Boolean;
		function set gestureEvents(value:Boolean):void;
		
		/**
		 * Determines whether release inertia is applied on the touchSprite.
		 * Same as releaseInertia()
		 * @default false
		 */
		function get gestureReleaseInertia():Boolean;
		function set gestureReleaseInertia(value:Boolean):void;
		
		/**
		 * Determines whether release inertia is applied on the touchSprite.
		 * Same as gestureReleaseInertia()
		 * @default false
		 */
		function get releaseInertia():Boolean;
		function set releaseInertia(value:Boolean):void;
		
		/**
		 * Clears inertial delta cache
		 */
		function stopInertia():void; 
		
		/**
		 * @default false
		 */
		function get gestureTweenOn():Boolean;
		function set gestureTweenOn(value:Boolean):void;
		
		/**
		 * @default false
		 */
		function get nestedTransform():Boolean;
		function set nestedTransform(value:Boolean):void;

		/**
		 * Determines whether transformEvents are processed and dispatched on the touchSprite.
		 * @default false
		 */
		function get transformEvents():Boolean;
		function set transformEvents(value:Boolean):void;
	
		/**
		 * @default false
		 */
		function get transformComplete():Boolean;
		function set transformComplete(value:Boolean):void;

		/**
		 * @default false
		 */
		function get transformStart():Boolean;
		function set transformStart(value:Boolean):void;

		/**
		 * @default true
		 */
		function get transformEventStart():Boolean;
		function set transformEventStart(value:Boolean):void;

		/**
		 * @default true
		 */
		function get transformEventComplete():Boolean;
		function set transformEventComplete(value:Boolean):void;
		
		/**
		 * Enables/Disables all GWTouchEvent and GWGestureEvent listeners
		 * @default true
		 */
		function get touchEnabled():Boolean;
		function set touchEnabled(t:Boolean):void;
			
		/**
		 * Determines whether transformations are handled internally (natively) on the touchSprite.
		 * @default false
		 */
		function get nativeTransform():Boolean;
		function set nativeTransform(value:Boolean):void;
		
		/**
		 * Determines whether transformations are handled internally (natively) on the touchSprite.
		 * @default true
		 */
		function get transformGestureVectors():Boolean;
		function set transformGestureVectors(value:Boolean):void;
		
		/**
		 * Determines whether gesture event driven transformations are affine on the touchSprite.
		 * @default false
		 */
		function get affineTransform():Boolean;
		function set affineTransform(value:Boolean):void;
		
		/**
		 * @default false
		 */
		function get x_lock():Boolean;
		function set x_lock(value:Boolean):void;
		
		/**
		 * @default false
		 */
		function get y_lock():Boolean;
		function set y_lock(value:Boolean):void;
		
		
		/////////////////////////////////////////////////////////////
		// transform boundaries
		/////////////////////////////////////////////////////////////
		
		/**
		 * Minimum x translation
		 */
		function get minX():Number;
		function set minX(value:Number):void;
		
		/**
		 * Maximum x translation
		 */
		function get maxX():Number;
		function set maxX(value:Number):void;
		
		/**
		 * Minimum y translation
		 */
		function get minY():Number;
		function set minY(value:Number):void;
		
		/**
		 * Maximum y translation
		 */
		function get maxY():Number;
		function set maxY(value:Number):void;
		
		/**
		 * Minimum z translation
		 */
		function get minZ():Number;
		function set minZ(value:Number):void;
	
		/**
		 * Maximum z translation
		 */
		function get maxZ():Number;
		function set maxZ(value:Number):void;
		
		/**
		 * Minimum scale. Applies setting to both minimum x and y scales.
		 * @see minScaleX
		 * @see minScaleY
		 */
		function get minScale():Number;
		function set minScale(value:Number):void;
		
		/**
		 * Maximum scale. Applies settings to both maximum x and y scales.
		 * @see maxScaleX
		 * @see maxScaleY
		 */
		function get maxScale():Number;
		function set maxScale(value:Number):void; 
		
		/**
		 * Minimum x scale
		 */
		function get minScaleX():Number;
		function set minScaleX(value:Number):void;
		
		/**
		 * Maximum x scale
		 */
		function get maxScaleX():Number;
		function set maxScaleX(value:Number):void;
		
		/**
		 * Minimum y scale
		 */
		function get minScaleY():Number;
		function set minScaleY(value:Number):void;
		
		/**
		 * Maximum y scale
		 */
		function get maxScaleY():Number;
		function set maxScaleY(value:Number):void;
		
		/**
		 * Minimum z scale
		 */
		function get minScaleZ():Number;
		function set minScaleZ(value:Number):void;
		
		/**
		 * Maximum z scale
		 */
		function get maxScaleZ():Number;
		function set maxScaleZ(value:Number):void;
		
		/**
		 * Minimum rotation in degrees. Applies setting to both minimum x and y rotations.
		 * @see minRotationX
		 * @see minRotationY
		 */
		function get minRotation():Number;
		function set minRotation(value:Number):void;
		
		/**
		 * Maximum rotation in degrees. Applies setting to both maximum x and y rotations.
		 * @see maxRotationX
		 * @see maxRotationY
		 */
		function get maxRotation():Number;
		function set maxRotation(value:Number):void;
		
		/**
		 * Minimum x rotation
		 */
		function get minRotationX():Number;
		function set minRotationX(value:Number):void;
		
		/**
		 * Maximum x rotation
		 */
		function get maxRotationX():Number; 
		function set maxRotationX(value:Number):void;
		
		/**
		 * Minimum y rotation
		 */
		function get minRotationY():Number;
		function set minRotationY(value:Number):void;
		
		/**
		 * Maximum y rotation
		 */
		function get maxRotationY():Number;
		function set maxRotationY(value:Number):void;
		
		/**
		 * Minimum z rotation
		 */
		function get minRotationZ():Number;
		function set minRotationZ(value:Number):void;
		
		/**
		 * Maximum z rotation
		 */
		function get maxRotationZ():Number;
		function set maxRotationZ(value:Number):void;
		
		/**
		 * Scales the transformation. Applies setting to both x and y scales.
		 * @default 1
		 */
		function get scale():Number;
		function set scale(value:Number):void;
			
		/**
		 * Enables/Disables touch visualizer
		 * @default false
		 */
		function get debugDisplay():Boolean;
		function set debugDisplay(value:Boolean):void;
		
		/**
		 * @default true
		 */
		function get gestureFilters():Boolean;
		function set gestureFilters(value:Boolean):void;
		
		///**
		 //* @default false
		 //*/
		//function get broadcastTarget():Boolean;
		//function set broadcastTarget(value:Boolean):void;
		
		/**
		 * @default false
		 */
		function get transform3d():Boolean;
		function set transform3d(value:Boolean):void;
		
		/**
		 * @default false
		 */
		//function get motion3d():Boolean;
		//function set motion3d(value:Boolean):void;
		
		/**
 		 * Determines if the touch points are registered to the TouchManager. One can override this behaivor by setting the value to false. This is useful when creating custom 
		 * TouchSprite extensions and external framework bindings.
		 * @default true
		 */
		function get registerPoints():Boolean;
		function set registerPoints(value:Boolean):void;
		
		/**
  		 * Sets whether this is representing an Away3D object.
		 * @default true
		 */
		function get away3d():Boolean;
		function set away3d(value:Boolean):void;
		
		/**
		 * Returns an array registered events
		 */
		function get eventListeners():Array;	
		
		function get parent(): DisplayObjectContainer;
		
		/**
  		 * length of object
		 * @default true
		 */
		function get length():Number;
		function set length(value:Number):void;
		
		/**
  		 * view container used for Away3D
		 */
		function get view():DisplayObjectContainer;
		function set view(value:DisplayObjectContainer):void;		
		
		/////////////////////////////////////////////////////////////
		////////////////////FUNCTIONS
		/////////////////////////////////////////////////////////////	
		
		/**
		 * @private
		 */
		function updateTransformation():void;
		
		/**
		 * @private
		 */
		function updateDebugDisplay():void;
		
		/**
		 * Unregisters all event listeners
		 */
		function removeAllListeners():void;
		
		/**
		 * Re-registers event listeners with updated mode settings
		 */
		function updateListeners():void;
		
		/**
		 * Updates target's transform
		 */
		function updateVTO():void;		
		
	}
}