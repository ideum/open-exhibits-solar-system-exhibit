////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    TouchSprite.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.core
{
	
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchCluster;
	import com.gestureworks.core.TouchGesture;
	import com.gestureworks.core.TouchPipeline;
	import com.gestureworks.core.TouchTransform;
	import com.gestureworks.core.TouchVisualizer;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.interfaces.ITouchObject;
	import com.gestureworks.managers.ObjectManager;
	import com.gestureworks.managers.TouchManager;
	import com.gestureworks.objects.ClusterObject;
	import com.gestureworks.objects.DimensionObject;
	import com.gestureworks.objects.GestureListObject;
	import com.gestureworks.objects.PointObject;
	import com.gestureworks.objects.StrokeObject;
	import com.gestureworks.objects.TimelineObject;
	import com.gestureworks.objects.TransformObject;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.utils.Dictionary;
	
	
	
	//import com.gestureworks.objects.PointPairObject;
	
	
	
	/**
	 * The TouchSprite class is the base class for all touch and gestures enabled
	 * Sprites that require additional display list management. 
	 * 
	 * <pre>
	 * 		<b>Properties</b>
	 * 		mouseChildren="false"
	 *		touchChildren="false"
	 *		targetParent = "false"
	 *		nativeTransform = "false"
	 *		affineTransform = "false"
	 *		gestureEvents = "true"
	 *		clusterEvents = "false"
	 *		transformEvents = "false"
	 * </pre>
	 */
	
	public class TouchSprite extends Sprite implements ITouchObject
	{
		/**
		 * @private
		 */
		public var gml:XMLList;		
		public static var GESTRELIST_UPDATE:String = "gestureList update";
		
		//tracks event listeners
		private var _eventListeners:Array = [];
		private var gwTouchListeners:Dictionary = new Dictionary();

		public function TouchSprite(_vto:Object=null):void
		{
			super();
			mouseChildren = false; 
			debugDisplay = false;
			vto = _vto;
        }
		
		private var _active:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get active():Boolean { return _active; }
		public function set active(a:Boolean):void {
			if (!_active && a) {
				_active = true;
				TouchManager.preinitBase(this);
			}
		}
		
		private var _localModes:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get localModes():Boolean { return _localModes; }
		public function set localModes(l:Boolean):void {
			if (_localModes == l) return;
			_localModes = l;
			updateListeners();
		}
		
		private var _nativeTouch:Boolean = false;
		/**
		 * @inheritDoc
		 */		
		public function get nativeTouch():Boolean { return _nativeTouch && GestureWorks.activeNativeTouch; }
		public function set nativeTouch(n:Boolean):void {
			if (_nativeTouch == n) return;
			_nativeTouch = n;
			updateListeners();
		}
		
		private var _simulator:Boolean = false;
		/**
		 * @inheritDoc
		 */		
		public function get simulator():Boolean { return _simulator && GestureWorks.activeSim; }
		public function set simulator(s:Boolean):void {
			if (_simulator == s) return;
			_simulator = s;
			updateListeners();	
		}
		
		private var _tuio:Boolean = false;
		/**
		 * @inheritDoc
		 */		
		public function get tuio():Boolean { return _tuio && GestureWorks.activeTUIO; }
		public function set tuio(t:Boolean):void {
			if (_tuio == t) return;
			_tuio = t;
			updateListeners();
		}				
		
		private var _leap2D:Boolean = false;
		/**
		 * @inheritDoc
		 */		
		public function get leap2D():Boolean { return _leap2D && GestureWorks.activeMotion; }
		public function set leap2D(l:Boolean):void {
			if (_leap2D == l) return;
			_leap2D = l;
			updateListeners();
		}			
		
		/**
		 * @inheritDoc
		 */
		public function updateListeners():void {			
			for (var type:String in gwTouchListeners) {
				for each(var l:* in gwTouchListeners[type]) {
					if(l.type)
						removeEventListener(l.type, l.listener);
					else{
						removeEventListener(type, l.listener);
						addEventListener(type, l.listener);
					}
				}
			}
		}
	
		private var _touchObjectID:int = 0; // read only
		/**
		 * @inheritDoc
		 */
		public function get touchObjectID():int { return _touchObjectID; }
		public function set touchObjectID(id:int):void { _touchObjectID = id; }
		
		private var _pointArray:Vector.<PointObject> = new Vector.<PointObject>(); // read only
		/**
		 * @inheritDoc
		 */
		public function get pointArray():Vector.<PointObject> { return _pointArray; }
		public function set pointArray(pa:Vector.<PointObject>):void { _pointArray = pa; }
		
		private var _N:int = 0; 
		/**
		 * @inheritDoc
		 */
		public function get N():int { return _N; }
		public function set N(n:int):void { _N = n; }
		
		private var _tpn:int = 0; 
		/**
		 * @inheritDoc
		 */
		public function get tpn():int { return _tpn; }
		public function set tpn(n:int):void { _tpn = n; }
		
		private var _ipn:int = 0; 
		/**
		 * @inheritDoc
		 */
		public function get ipn():int { return _ipn; }
		public function set ipn(n:int):void { _ipn = n; }
		
		private var _mpn:int = 0; 
		/**
		 * @inheritDoc
		 */
		public function get mpn():int { return _mpn; }
		public function set mpn(n:int):void { _mpn = n; }
				
		private var _dN:Number = 0; 
		/**
		 * @inheritDoc
		 */
		public function get dN():Number { return _dN; }
		public function set dN(n:Number):void { _dN = n; }
		
		private var _cO:ClusterObject; 
		/**
		 * @inheritDoc
		 */
		public function get cO():ClusterObject { return _cO; }
		public function set cO(obj:ClusterObject):void { _cO = obj; }
				
		private var _sO:StrokeObject;
		/**
		 * @inheritDoc
		 */
		public function get sO():StrokeObject { return _sO; }
		public function set sO(obj:StrokeObject):void { _sO = obj; }
		
		private var _gO:GestureListObject;
		/**
		 * @inheritDoc
		 */
		public function get gO():GestureListObject { return _gO; }
		public function set gO(obj:GestureListObject):void { _gO = obj; }
		
		private var _tiO:TimelineObject;
		/**
		 * @inheritDoc
		 */
		public function get tiO():TimelineObject { return _tiO; }
		public function set tiO(obj:TimelineObject):void { _tiO = obj; }	
		
		private var _trO:TransformObject;
		/**
		 * @inheritDoc
		 */
		public function get trO():TransformObject { return _trO; }
		public function set trO(obj:TransformObject):void { _trO = obj; }		
		
		private var _tc:TouchCluster;
		/**
		 * @inheritDoc
		 */
		public function get tc():TouchCluster { return _tc; }
		public function set tc(obj:TouchCluster):void { _tc = obj; }
		
		private var _tp:TouchPipeline;
		/**
		 * @inheritDoc
		 */
		public function get tp():TouchPipeline { return _tp; }
		public function set tp(obj:TouchPipeline):void { _tp = obj; }
		
		private var _tg:TouchGesture;
		/**
		 * @inheritDoc
		 */
		public function get tg():TouchGesture { return _tg; }
		public function set tg(obj:TouchGesture):void { _tg = obj; }
		
		private var _tt:TouchTransform;
		/**
		 * @inheritDoc
		 */
		public function get tt():TouchTransform { return _tt; }
		public function set tt(obj:TouchTransform):void { _tt = obj; }	
				
		private var _visualizer:TouchVisualizer;		
		/**
		 * @inheritDoc
		 */
		public function get visualizer():TouchVisualizer { return _visualizer; }
		public function set visualizer(obj:TouchVisualizer):void { _visualizer = obj; }		
		
		private var _traceDebugMode:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get traceDebugMode():Boolean{return _traceDebugMode;}
		public function set traceDebugMode(value:Boolean):void {	_traceDebugMode = value; }
		
		/**
		 * For each point registration, reorder the object's index to the top of its parent's display list.
		 */
		public var topOnPoint:Boolean;
		
		/**
		 * @inheritDoc
		 */
		private var _totalPointCount:int;
		public function get totalPointCount():int { return _totalPointCount; }
		public function set totalPointCount(value:int):void { 
			if (parent && parent is ITouchObject) {
				ITouchObject(parent).totalPointCount += value > _totalPointCount ? value -_totalPointCount : -(_totalPointCount - value);
			}
			if (topOnPoint && value > _totalPointCount) {
				parent.addChildAt(this, parent.numChildren - 1);
			}
			_totalPointCount = value; 			
		}
		
		private var _pointCount:int;
		/**
		 * @inheritDoc
		 */
		public function get pointCount():int{return _pointCount;}
		public function set pointCount(value:int):void { _pointCount = value; }
		
		private var _motionPointCount:int;
		/**
		 * @inheritDoc
		 */
		public function get motionPointCount():int{return _motionPointCount;}
		public function set motionPointCount(value:int):void {	_motionPointCount = value; }
		
		private var _interactionPointCount:int;
		/**
		 * @inheritDoc
		 */
		public function get interactionPointCount():int{return _interactionPointCount;}
		public function set interactionPointCount(value:int):void{	_interactionPointCount=value;}
		
		private var _clusterID:int;
		/**
		 * @inheritDoc
		 */
		public function get clusterID():int{return _clusterID;}
		public function set clusterID(value:int):void {	_clusterID = value; }
		
		private var _gestureList:Object = new Object();
		/**
		 * @inheritDoc
		 */
		public function get gestureList():Object{ return _gestureList;}
		public function set gestureList(value:Object):void
		{
			var empty:Boolean = true;
			for (var n:* in value) { empty = false; break; }			
			if (empty) return;
			
			active = true;
			_gestureList = value;
			
			//for (var i:String in gestureList) 
			//{
				//gestureList[i] = gestureList[i].toString() == "true" ?true:false;
				//if (traceDebugMode) trace("setting gestureList:", gestureList[i]);
			//}
			
			/////////////////////////////////////////////////////////////////////
			// Convert GML into Property Objects That describe how to match,analyze, 
			// process and map point/clusterobject properties
			/////////////////////////////////////////////////////////////////////
			TouchManager.callLocalGestureParser(this);
			
			
			//////////////////////////////////////////////////////////////////////////
			// makes sure that if gesture list changes timeline gesture int is reset
			/////////////////////////////////////////////////////////////////////////
			dispatchEvent(new GWGestureEvent(GWGestureEvent.GESTURELIST_UPDATE, false));
		}
		
		private var _touchChildren:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get touchChildren():Boolean{return _touchChildren;}
		public function set touchChildren(value:Boolean):void
		{
			_touchChildren = value;
			mouseChildren = value;
		}
		
		private var _clusterBubbling:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get clusterBubbling():Boolean{return _clusterBubbling;}
		public function set clusterBubbling(value:Boolean):void
		{
			_clusterBubbling = value;
		}
		
		private var _targetParent:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get targetParent():Boolean{return _targetParent;}
		public function set targetParent(value:Boolean):void
		{
			_targetParent = value;
		}
		
		private var _targetList:Array = [];
		/**
		 * @inheritDoc
		 */
		public function get targetList():*{return _targetList;}
		public function set targetList(value:*):void
		{	
			_targetList = value;
		}

		private var _vto:Object;
		/**
		 * @inheritDoc
		 */
		public function get vto():Object{return _vto;}
		public function set vto(value:Object):void
		{
			if (_vto && !value) {
				_vto = value;
				transform.matrix = transform.matrix;
				TouchManager.deregisterVTO(this);
			}
			else if (value && "transform" in value && value.transform is Transform) {
				_vto = value;
				transform.matrix = _vto.transform.matrix;
				TouchManager.registerVTO(this);
			}
			else {
				_vto = value;
				TouchManager.registerVTO(this);
			}
		}
		
		private var _clusterEvents:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get clusterEvents():Boolean{return _clusterEvents;}
		public function set clusterEvents(value:Boolean):void {	_clusterEvents = value; }
		
		
		private var _deltaFilterOn:Boolean = false
		/**
		 * @inheritDoc
		 */
		public function get deltaFilterOn():Boolean{return _deltaFilterOn;}
		public function set deltaFilterOn(value:Boolean):void{	_deltaFilterOn=value;}
		
		private var _gestureTouchInertia:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get gestureTouchInertia():Boolean{return _gestureTouchInertia;}
		public function set gestureTouchInertia(value:Boolean):void
		{
			_gestureTouchInertia = value;
			_deltaFilterOn=value;
		}
		
		/**
		 * 
		 */
		public function updateClusterAnalysis():void
		{
			if(tc) tc.updateClusterAnalysis();
		}
		
		/**
		 * 
		 */
		//public function updateMotionClusterAnalysis():void
		//{
			//if(tc) tc.updateMotionClusterAnalysis();
		//}
		
		/**
		 * 
		 */
		//public function updateSensorClusterAnalysis():void
		//{
			//if(tc) tc.updateSensorClusterAnalysis();
		//}
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//gesture settings
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private var _gestureEventStart:Boolean = true;
		/**
		 * @inheritDoc 
		 */
		public function get gestureEventStart():Boolean{return _gestureEventStart;}
		public function set gestureEventStart(value:Boolean):void{	_gestureEventStart=value;}
		
		private var _gestureEventComplete:Boolean = true;
		/**
		 * @inheritDoc 
		 */
		public function get gestureEventComplete():Boolean{return _gestureEventComplete;}
		public function set gestureEventComplete(value:Boolean):void{	_gestureEventComplete=value;}
		
		private var _gestureEventRelease:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get gestureEventRelease():Boolean{return _gestureEventRelease;}
		public function set gestureEventRelease(value:Boolean):void{_gestureEventRelease = value;}
		
		// NOW SET TO TRUE BY DEFAULT
		// TURN OFF TO OPTOMIZE WHEN USING NATIVE
		// TODO, AUTO ON WHEN ATTATCH LISTENERS
		private var _gestureEvents:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get gestureEvents():Boolean{return _gestureEvents;}
		public function set gestureEvents(value:Boolean):void {	_gestureEvents = value; }	
		
		private var _gestureReleaseInertia:Boolean = false;	// gesture release inertia switch
		/**
		 * @inheritDoc 
		 */
		public function get gestureReleaseInertia():Boolean{return _gestureReleaseInertia;}
		public function set gestureReleaseInertia(value:Boolean):void {	_gestureReleaseInertia = value; }
		/**
		 * @inheritDoc 
		 */		
		public function get releaseInertia():Boolean{return _gestureReleaseInertia;}
		public function set releaseInertia(value:Boolean):void {	_gestureReleaseInertia = value; }				
		/**
		 * @inheritDoc
		 */
		public function stopInertia():void {
			for each(var dim:DimensionObject in gO.pOList[0].dList) {
				dim.gestureDeltaCache = 0; 
			}
		}
		
		private var _gestureTweenOn:Boolean = false;
		public function get gestureTweenOn():Boolean { return _gestureTweenOn; }
		public function set gestureTweenOn(value:Boolean):void { _gestureTweenOn = value; }
		
		public function updateGesturePipeline():void
		{
			if (tp) tp.processPipeline();
			if (tg) tg.manageGestureEventDispatch();
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		// TRANSFORMS
		///////////////////////////////////////////////////////////////////////////////////
		
		private var _nestedTransform:Boolean = false;
		public function get nestedTransform():Boolean { return _nestedTransform} 
		public function set nestedTransform(value:Boolean):void{	_nestedTransform = value}

		private var _transformEvents:Boolean = false;
		/**
		 * @inheritDoc 
		 */
		public function get transformEvents():Boolean{return _transformEvents;}
		public function set transformEvents(value:Boolean):void{	_transformEvents=value;}
	
		private var _transformComplete:Boolean = false;
		public function get transformComplete():Boolean { return _transformComplete; }
		public function set transformComplete(value:Boolean):void{	_transformComplete=value;}

		private var _transformStart:Boolean = false;
		public function get transformStart():Boolean { return _transformStart; }
		public function set transformStart(value:Boolean):void{	_transformStart=value;}

		private var _transformEventStart:Boolean = true;
		public function get transformEventStart():Boolean{return _transformEventStart;}
		public function set transformEventStart(value:Boolean):void{_transformEventStart=value;}

		private var _transformEventComplete:Boolean = true;
		public function get transformEventComplete():Boolean{return _transformEventComplete;}
		public function set transformEventComplete(value:Boolean):void {_transformEventComplete = value; }
		
		private var _touchEnabled:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get touchEnabled():Boolean { return _touchEnabled; }
		public function set touchEnabled(t:Boolean):void {
			if (_touchEnabled == t) return;			
			_touchEnabled = t;
			
			var eCnt:int = _eventListeners.length;
			var e:*;
			for(var i:int = eCnt-1; i >= 0; i--) {
				e = _eventListeners[i];
				if (GWTouchEvent.isType(e.type) || GWGestureEvent.isType(e.type)) {
					if (_touchEnabled) {
						addGWTouch(e.type, e.listener, e.capture);
						super.addEventListener(e.type, e.listener, e.capture);
					}
					else {
						removeGWTouch(e.type);
						super.removeEventListener(e.type, e.listener, e.capture);
					}
				}
			}
		}	
		
		private var _motionEnabled:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get motionEnabled():Boolean { return _motionEnabled; }
		public function set motionEnabled(value:Boolean):void {	_motionEnabled = value;}
		
		private var _sensorEnabled:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get sensorEnabled():Boolean { return _sensorEnabled; }
		public function set sesnorEnabled(value:Boolean):void {	_sensorEnabled = value;}
		
		
		private var _nativeTransform:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get nativeTransform():Boolean{return _nativeTransform;}
		public function set nativeTransform(value:Boolean):void {_nativeTransform = value; }						

		// default true so that all nested gestures are correct unless speciFied
		private var _transformGestureVectors:Boolean = true;
		/**
		 * @inheritDoc 
		 */
		public function get transformGestureVectors():Boolean{return _transformGestureVectors;}
		public function set transformGestureVectors(value:Boolean):void{	_transformGestureVectors=value;}
		
		//11/11/2013 TRUE BY DEFAULT AS MAJORITY OF TRANSFORMS ARE AFFINE
		private var _affineTransform:Boolean = true; 
		/**
		 * @inheritDoc
		 */
		public function get affineTransform():Boolean{return _affineTransform;}
		public function set affineTransform(value:Boolean):void{_affineTransform = value;}		
		
		private var _x_lock:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get x_lock():Boolean {return _x_lock;}	
		public function set x_lock(value:Boolean):void { _x_lock = value; }
		
		private var _y_lock:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get y_lock():Boolean {return _y_lock;}	
		public function set y_lock(value:Boolean):void { _y_lock = value; }	
		
		
		/////////////////////////////////////////////////////////////
		// transform boundaries
		/////////////////////////////////////////////////////////////	
		
		//translation
		private var _minX:Number;
		/**
		 * @inheritDoc
		 */
		public function get minX():Number { return _minX; }
		public function set minX(value:Number):void {
			_minX = value;
		}
		
		private var _maxX:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxX():Number { return _maxX; }
		public function set maxX(value:Number):void {
			_maxX = value;
		}
		
		private var _minY:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minY():Number { return _minY; }
		public function set minY(value:Number):void {
			_minY = value;
		}
		
		private var _maxY:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxY():Number { return _maxY; }
		public function set maxY(value:Number):void {
			_maxY = value;
		}		
		
		private var _minZ:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minZ():Number { return _minZ; }
		public function set minZ(value:Number):void {
			_minZ = value;
		}		
	
		private var _maxZ:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxZ():Number { return _maxZ; }
		public function set maxZ(value:Number):void {
			_maxZ = value;
		}
		
		//scale
		private var _minScale:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minScale():Number { return _minScale; }
		public function set minScale(value:Number):void {
			_minScale = value;
			minScaleX = value;
			minScaleY = value;
		}
		
		private var _maxScale:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxScale():Number { return _maxScale; }
		public function set maxScale(value:Number):void {
			_maxScale = value;
			maxScaleX = value; 
			maxScaleY = value;
		}		
		
		private var _minScaleX:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minScaleX():Number { return _minScaleX; }
		public function set minScaleX(value:Number):void {
			_minScaleX = value;
		}
		
		private var _maxScaleX:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxScaleX():Number { return _maxScaleX; }
		public function set maxScaleX(value:Number):void {
			_maxScaleX = value;
		}			
		
		private var _minScaleY:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minScaleY():Number { return _minScaleY; }
		public function set minScaleY(value:Number):void {
			_minScaleY = value;
		}	
		
		private var _maxScaleY:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxScaleY():Number { return _maxScaleY; }
		public function set maxScaleY(value:Number):void {
			_maxScaleY = value;
		}			
		
		private var _minScaleZ:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minScaleZ():Number { return _minScaleZ; }
		public function set minScaleZ(value:Number):void {
			_minScaleZ = value;
		}		
		
		private var _maxScaleZ:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxScaleZ():Number { return _maxScaleZ; }
		public function set maxScaleZ(value:Number):void {
			_maxScaleZ = value;
		}		
		
		//rotation
		private var _minRotation:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minRotation():Number { return _minRotation; }
		public function set minRotation(value:Number):void {
			_minRotation = value;
			minRotationX = value;
			minRotationY = value;
		}		
		
		private var _maxRotation:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxRotation():Number { return _maxRotation; }
		public function set maxRotation(value:Number):void {
			_maxRotation = value;
			maxRotationX = value;
			maxRotationY = value;
		}	
		
		private var _minRotationX:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minRotationX():Number { return _minRotationX; }
		public function set minRotationX(value:Number):void {
			_minRotationX = value;
		}		
		
		private var _maxRotationX:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxRotationX():Number { return _maxRotationX; }
		public function set maxRotationX(value:Number):void {
			_maxRotationX = value;
		}
		
		private var _minRotationY:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minRotationY():Number { return _minRotationY; }
		public function set minRotationY(value:Number):void {
			_minRotationY = value;
		}		
		
		private var _maxRotationY:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxRotationY():Number { return _maxRotationY; }
		public function set maxRotationY(value:Number):void {
			_maxRotationY = value;
		}
		
		private var _minRotationZ:Number;
		/**
		 * @inheritDoc
		 */		
		public function get minRotationZ():Number { return _minRotationZ; }
		public function set minRotationZ(value:Number):void {
			_minRotationZ = value;
		}		
		
		private var _maxRotationZ:Number;
		/**
		 * @inheritDoc
		 */		
		public function get maxRotationZ():Number { return _maxRotationZ; }
		public function set maxRotationZ(value:Number):void {
			_maxRotationZ = value;
		}
		
		private var _length:Number;
		/**
		 * @inheritDoc
		 */		
		public function get length():Number { return _length; }
		public function set length(value:Number):void {
			_length = value;
		}
			
		private var _view:DisplayObjectContainer;
		/**
		 * @inheritDoc
		 */		
		public function get view():DisplayObjectContainer { return _view; }
		public function set view(value:DisplayObjectContainer):void {
			_view = value;
		}
		
		/////////////////////////////////////////////////////////////
		//affine transformation deltas 
		/////////////////////////////////////////////////////////////		
		/**
		 * @private
		 */
		public var dx:Number = 0;
		/**
		 * @private
		 */
		public var dy:Number = 0;
		/**
		 * @private
		 */
		public var dz:Number = 0;
		/**
		 * @private
		 */
		public var dtheta:Number = 0;
		/**
		 * @private
		 */
		public var dthetaX:Number = 0;
		/**
		 * @private
		 */
		public var dthetaY:Number = 0;
		/**
		 * @private
		 */
		public var dthetaZ:Number = 0;
		/**
		 * @private
		 */
		public var dsx:Number = 0;
		/**
		 * @private
		 */
		public var dsy:Number = 0;
		/**
		 * @private
		 */
		public var dsz:Number = 0;
		/**
		 * For non-native affine tranformations, used to cache previous transform in order to revert modifications made through direct transformation settings
		 * (i.e. x,y,rotation,etc.) allowing the TouchTransform to apply all gesture tranformations
		 * @private
		 */
		public var mtx:Matrix;
		/**
		 * For non-native affine tranformations3D, used to cache previous transform in order to revert modifications made through direct transformation settings
		 * (i.e. x,y,rotation,etc.) allowing the TouchTransform to apply all gesture tranformations
		 * @private
		 */
		public var mtx3D:Matrix3D;
		
		
		/////////////////////////////////////////////////////////////
		//transform methods
		/////////////////////////////////////////////////////////////
		
		/**
		 * @inheritDoc
		 */
		override public function set x(value:Number):void {	
			value = value < minX ? minX : value > maxX ? maxX : value;
			dx = value - super.x;
			super.x = value;
		}		
		
		/**
		 * @inheritDoc
		 */
		override public function set y(value:Number):void {
			value = value < minY ? minY : value > maxY ? maxY : value;
			dy = value - super.y;
			super.y = value;
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function set z(value:Number):void {
			value = value < minZ ? minZ : value > maxZ ? maxZ : value;
			dz = value - super.z;
			super.z = value;
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function set rotation(value:Number):void {
			value = value < minRotation ? minRotation : value > maxRotation ? maxRotation : value;
			dtheta = value - super.rotation;
			super.rotation = value;
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function set rotationX(value:Number):void {
			value = value < minRotationX ? minRotationX : value > maxRotationX ? maxRotationX : value;
			dthetaX = value - super.rotationX;
			super.rotationX = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set rotationY(value:Number):void {
			value = value < minRotationY ? minRotationY : value > maxRotationY ? maxRotationY : value;
			dthetaY = value - super.rotationY;
			super.rotationY = value;
		}
			
		/**
		 * @inheritDoc
		 */
		override public function set rotationZ(value:Number):void {
			value = value < minRotationZ ? minRotationZ : value > maxRotationZ ? maxRotationZ : value;
			dthetaZ = value - super.rotationZ;
			super.rotationZ = value;
		}

		/**
		 * @inheritDoc
		 */
		override public function set scaleX(value:Number):void {
			value = value < minScaleX ? minScaleX : value > maxScaleX ? maxScaleX : value;
			dsx = value - super.scaleX;
			super.scaleX = value;
		}			
		
		/**
		 * @inheritDoc
		 */
		override public function set scaleY(value:Number):void {
			value = value < minScaleY ? minScaleY : value > maxScaleY ? maxScaleY : value;
			dsy = value - super.scaleY;
			super.scaleY = value;
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function set scaleZ(value:Number):void {
			value = value < minScaleZ ? minScaleZ : value > maxScaleZ ? maxScaleZ : value;
			dsz = value - super.scaleZ;
			super.scaleZ = value;
		}
		
		private var _scale:Number = 1;
		/**
		 * @inheritDoc
		 */	
		public function get scale():Number{return _scale;}
		public function set scale(value:Number):void
		{
			_scale = value;
			scaleX = _scale;
			scaleY = _scale;
		}					
		
		// affine transform point  
		public function get transformPoint():Point { return new Point(trO?trO.x:0, trO?trO.y:0);} 
		public function set transformPoint(pt:Point):void
		{
			if (!tt) return;
			var tpt:Point = tt.affine_modifier.transformPoint(pt);
			trO.x = tpt.x;
			trO.y = tpt.y;
		}		
		
		/**
		 * @inheritDoc
		 */
		public function updateTransformation():void 
		{
			if(tt){
				tt.transformManager();
				tt.updateLocalProperties();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function updateVTO():void 
		{
			if (vto)
				vto.transform = transform;
		}		
		
		/**
		 * @inheritDoc
		 */
		public function updateDebugDisplay():void
		{
			if(visualizer) visualizer.updateDebugDisplay()
		}
			
		private var _debugDisplay:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get debugDisplay():Boolean { return _debugDisplay;}	
		public function set debugDisplay(value:Boolean):void {
			if (debugDisplay == value) return;
						
			_debugDisplay = value;
			if(visualizer)
				visualizer.initDebug();
		}
		
		private var _gestureFilters:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get gestureFilters():Boolean {return _gestureFilters;}	
		public function set gestureFilters(value:Boolean):void{	_gestureFilters = value;}
		
		// BROADCASTING TEST
		//private var _broadcastTarget:Boolean = false;
		///**
		 //* @inheritDoc
		 //*/
		//public function get broadcastTarget():Boolean {return _broadcastTarget;}	
		//public function set broadcastTarget(value:Boolean):void{	_broadcastTarget = value;}
		
		
		// TRANSFORM 3D
		private var _motionClusterMode:String = "global";
		/**
		 * @inheritDoc
		 */
		public function get motionClusterMode():String {return _motionClusterMode;}	
		public function set motionClusterMode(value:String):void {	_motionClusterMode = value; }
		
		
		// TRANSFORM 3D
		private var _transform3d:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get transform3d():Boolean {return _transform3d;}	
		public function set transform3d(value:Boolean):void {	_transform3d = value; }
		
		//DEFINES TOUCH MODE // ENABLED WHEN TOUCHING 3D OBJECTS AND USING NATIVE TRANSFORMS
		private var _touch3d:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get touch3d():Boolean {return _touch3d;}	
		public function set touch3d(value:Boolean):void{ _touch3d = value;}		
		
		private var _registerPoints:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get registerPoints():Boolean { return _registerPoints} 
		public function set registerPoints(value:Boolean):void{	_registerPoints = value}		
		
		private var _away3d:Boolean = false;
		/**
		 * @inheritDoc
		 */	
		public function get away3d():Boolean {return _away3d;}	
		public function set away3d(value:Boolean):void { _away3d = value; }
		
		/**
		 * @inheritDoc
		 */
		public function get eventListeners():Array { return _eventListeners; }		
		
		/**
		 * Registers event listeners. 
		 * @param	type
		 * @param	listener
		 * @param	useCapture
		 * @param	priority
		 * @param	useWeakReference
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{			
			addGWTouch(type, listener, useCapture, priority, useWeakReference);
			
			//prevent duplicate events
			if(searchEvent(type, listener, useCapture) < 0)
				_eventListeners.push( { type:type, listener:listener, capture:useCapture } );
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * Processes GWTouchEvents by evaluating which types of touch events (TUIO, native touch, and mouse) are active then registers
		 * and dispatches appropriate events.
		 * @param	type
		 * @param	listener
		 * @param	useCapture
		 * @param	priority = 0
		 * @param	useWeakReference
		 */
		private function addGWTouch(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (GWTouchEvent.isType(type))
			{	
				//prevent duplicate registration
				if (searchEvent(type, listener, useCapture) > -1) 
					return;
					
				var listeners:Array = [];
				for each(var gwt:String in GWTouchEvent.eventTypes(type,this)) {
					function gwl(e:*):void {
						dispatchEvent(new GWTouchEvent(e, e.type, e.bubbles, true));
					}
					super.addEventListener(gwt, gwl, useCapture, priority, useWeakReference);
					listeners.push( { type:gwt, listener:gwl } );
				}
				
				listeners.push( { listener:listener } );
				gwTouchListeners[type] = listeners;				
			}			
		}
		
		/**
		 * Unregisters event listeners. 
		 * @param	type
		 * @param	listener
		 * @param	useCapture
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			if (!super.hasEventListener(type))
				return;
				
			removeGWTouch(type);
			
			//update event registration array	
			var i:int = searchEvent(type, listener, useCapture);
			if(i >= 0)
				_eventListeners.splice(i, 1);
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Manages removal of GWTouchEvents and associated input (TUIO, native touch, and mouse) events.
		 * @param	type GWTouchEvent type
		 */
		private function removeGWTouch(type:String):void {
			if (GWTouchEvent.isType(type)) {
				for each(var l:* in gwTouchListeners[type]) {
					if (l.type)
						super.removeEventListener(l.type, l.listener);
				}
				delete gwTouchListeners[type];
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAllListeners():void {
			var eCnt:int = _eventListeners ? _eventListeners.length : 0;
			var e:*;
			for(var i:int = eCnt-1; i >= 0; i--) {
				e = _eventListeners[i];
				removeEventListener(e.type, e.listener, e.capture);
			}
			_eventListeners = null;
		}
		
		/**
		 * Search registerd events for provided event
		 * @param	type Event type
		 * @param	listener Listener function
		 * @param	useCapture Capture flag
		 * @return The index of the event in the registration list, or -1 if not registered
		 */
		private function searchEvent(type:String, listener:Function, useCapture:Boolean = false):int {
			for (var i:int = 0; i < _eventListeners.length; i++) {
				var el:* = _eventListeners[i];
				if (el.type == type && el.listener == listener && el.capture == useCapture) {
					return i;
				}
			}			
			return -1;
		}
		
		/**
		 * Overrides dispatch event to deconlfict duplicate device input 
		 * @param	event
		 * @return
		 */
		override public function dispatchEvent(event:Event):Boolean 
		{
			if (event is GWTouchEvent && duplicateDeviceInput(GWTouchEvent(event)))
				return false;
			return super.dispatchEvent(event);
		}		
		
		private static var input1:GWTouchEvent;
		/**
		 * Prioritizes native touch input over mouse input from the touch screen. Processing
		 * both inputs from the same device produces undesired results. Assumes touch events
		 * will precede mouse events.
		 * @param	event
		 * @return
		 */
		private static function duplicateDeviceInput(event:GWTouchEvent):Boolean {
			if (input1 && input1.source != event.source && (event.time - input1.time < 200))
				return true;
			input1 = event;
			return false;
		}	
		
		/**
		 * Marks object for disposal and lets TouchManager handle call to prevent concurrent modification
		 * errors on frame processes
		 */
		public var disposal:Boolean = false;
		
		/**
		 * Calls the dispose method for each child, then removes all children, unregisters all events, and
		 * removes from global lists. This is the root destructor intended to be called by overriding dispose functions. 
		 */		
		public function dispose():void {
			
			if (!disposal) {
				disposal = true;
				return; 
			}
			
			//remove all children
			for (var i:int = numChildren - 1; i >= 0; i--)
			{
				var child:Object = getChildAt(i);
				if (child.hasOwnProperty("dispose"))
					child["dispose"]();
				removeChildAt(i);
			}	
			
			//unregister events
			removeAllListeners();
			
			//remove from master list
			ObjectManager.unRegisterTouchObject(this);
			
			gml = null;
			gwTouchListeners = null;
			pointArray = null;
			_cO = null;
			_sO = null;
			_tiO = null;
			_trO = null;
			_tc = null;
			_tp = null;
			_tg = null;
			_tt = null;
			_visualizer = null; 
			_gestureList = null;
			_vto = null;
			_view = null;
			transformPoint = null;
		}
		
	}
}