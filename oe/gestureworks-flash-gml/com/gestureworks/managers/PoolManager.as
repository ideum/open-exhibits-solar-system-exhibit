package com.gestureworks.managers {
	
	import com.gestureworks.core.GestureGlobals;
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.FrameObject;
	
	/**
	 * Manages object pooling to recycle objects opposed to performance intensive allocation (instantiation)
	 * and deallocation (garbage collection)
	 * @author Ideum
	 */
	public class PoolManager {
		
		//cluster object pool
		private static var cOPool:Vector.<ClusterObject> = new Vector.<ClusterObject>();
		//frame object pool
		private static var framePool:Vector.<FrameObject> = new Vector.<FrameObject>();
		
		//number of registered touch objects
		private static var objCnt:int;		
		//variable to store the pool sizes
		private static var poolSize:int;
		
		/**
		 * Populate object pools based on object count
		 */
		public static function registerPools():void {
			objCnt = GestureGlobals.objectCount;
			
			updateCOPool();
			updateFramePool();
		}
		
		/**
		 * Decrease the sizes of the object pools
		 */
		public static function unregisterPools():void {
			objCnt = GestureGlobals.objectCount;
			
			updateCOPool();
			updateFramePool();
		}

		/********************ClusterObject********************/
		/**
		 * Updates the queue of the pool by shifting the top object to the bottom
		 * @return  The next object on top of the queue
		 */		
		private static function updateCOPool():void {
			poolSize = objCnt * GestureGlobals.clusterHistoryCaptureLength;
			
			for (var i:int = cOPool.length; i < poolSize; i++)
				cOPool.push(new ClusterObject());
				
			if (poolSize < cOPool.length)
				cOPool.splice(poolSize, cOPool.length-1);
		}
		
		/**
		 * Retrurn ClusterObject from pool
		 * @return the top ClusterObject
		 */
		public static function get clusterObject():ClusterObject {
			var cO:ClusterObject = cOPool.shift();
			cO.reset();
			cOPool.push(cO);			
			return cO;
		}
		
		
		/********************FrameObject********************/		
		/**
		 * Updates the queue of the pool by shifting the top object to the bottom
		 * @return  The next object on top of the queue
		 */				
		private static function updateFramePool():void {
			poolSize = objCnt * GestureGlobals.timelineHistoryCaptureLength;
			
			for (var i:int = framePool.length; i < poolSize; i++)
				framePool.push(new FrameObject());
				
			if (poolSize < framePool.length)
				framePool.splice(poolSize, framePool.length - 1);
		}
		
		/**
		 * Return FrameObject from pool
		 * @return the top FrameObject
		 */
		public static function get frameObject():FrameObject {
			var frame:FrameObject = framePool.shift();
			frame.reset();
			framePool.push(frame);			
			return frame;
		}
		
	}

}