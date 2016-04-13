package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import flash.display.DisplayObject;
	
	/**
	 * A priority queue dynamically sorted based on object visibility and interactivity. The <code>resource</code> attribute references the highest
	 * priority resource. 
	 * @author 
	 */
	public class ResourceManager 
	{		
		private static var _instance:ResourceManager;
		private var _resources:Vector.<TouchContainer>;
		
		/**
		 * Singleton constructor
		 * @param	resources Collection of resources to populate queue
		 */
		public function ResourceManager(resources:Vector.<TouchContainer> = null) {
			if (_instance){
				throw new Error("Error: Instantiation failed: Use ResourceManager.getInstance() instead of new.");
			}
			else {
				this.resources = resources;
			}
		}
		
		/**
		 * Returns an ResourceManager instance
		 * @param	resources Collection of resources to populate queue
		 * @return
		 */
		public static function getInstance(resources:Vector.<TouchContainer> = null):ResourceManager {
			if (!_instance)
				_instance = new ResourceManager(resources);
			return _instance;
		}
		
		/**
		 * Collection of resources to populate queue
		 */
		public function get resources():Vector.<TouchContainer> { return _resources; }
		public function set resources(value:Vector.<TouchContainer>):void {
			if(value){
				_resources = value; 
				queue();
			}
		}
		
		/**
		 * The highest priority resource
		 */
		public function get resource():* { 
			return resources && resources.length ? resources[0] : null;
		}
		
		/**
		 * Initialize priority queue sort methods
		 */
		protected function queue():void {
			for each(var res:TouchContainer in resources) {
				res.notifyVisible = activation;
				res.notifyInteraction = interaction;
			}
		}
		
		/**
		 * A resource's activated state is based on when it can receive interaction points. In most cases, this capability
		 * is controlled by the object's visiblity on stage which is why, by default, this callback is registered to visibility
		 * updates. Upon activation (visible), a resource is pushed to the bottom of the queue and when deactivated (invisible), 
		 * it is moved to the top. 
		 * @param	res
		 */
		protected function activation(res:TouchContainer):void {
			res.visible ? bottom = res : top = res;
		}
		
		/**
		 * Interactivity is driven by interactive points registered with the object. When an object is currently being interacted with, 
		 * its priority decreases
		 * @param	res
		 */
		protected function interaction(res:TouchContainer):void {
			bottom = res; 
		}
		
		/**
		 * Top of queue
		 */
		public function set top(res:TouchContainer):void {
			remove(res);
			resources.unshift(res);
		}
		
		/**
		 * Bottom of queue
		 */
		public function set bottom(res:TouchContainer):void {
			remove(res);
			resources.push(res);
		}
		
		/**
		 * Remove resource from queue
		 * @param	res Resource to remove
		 */
		public function remove(res:TouchContainer):void {
			if(resources.indexOf(res) > -1){
				resources.splice(resources.indexOf(res), 1);
			}
		}
				
	}

}