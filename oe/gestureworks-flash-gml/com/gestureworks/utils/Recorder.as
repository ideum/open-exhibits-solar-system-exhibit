package com.gestureworks.utils
{
	import com.gestureworks.events.*;
	import com.gestureworks.managers.*;
	import flash.display.Stage;
	import flash.events.*;
	import flash.display.*;
	import flash.utils.*;
	import flash.geom.Point;
	import flash.net.*;
	/**
	 * ...
	 * @author ...
	 */
	public class Recorder extends Sprite
	{
		private var _drawingOn:Boolean = true;
		/**
		 * Draw circles of touch input
		 */
		public function get drawingOn():Boolean {
			return _drawingOn;
		}
		
		public function set drawingOn(value:Boolean):void {
			_drawingOn = value;
		}
		
		private var _drawOnReplay:Boolean = true;
		/**
		 * Draw circles of touch input on replay. Ignored if drawingOn is false.
		 */
		public function get drawOnReplay():Boolean {
			return _drawOnReplay;
		}
		
		public function set drawOnReplay(value:Boolean):void {
			_drawOnReplay = value;
		}
		
		private var _stopRecordingOnTouchUp:Boolean = false;
		/**
		 * Decides to stop recording on touch up events, instead of waiting for stop key. 
		 * If true recording simple touch events is easier but multiple point event recording
		 * is difficult.
		 */
		public function get stopRecordingOnTouchUp():Boolean {
			return _stopRecordingOnTouchUp;
		}
		
		public function set stopRecordingOnTouchUp(value:Boolean):void {
			_stopRecordingOnTouchUp = value;
		}
		
		private var _showDebugOutput:Boolean = true;
		/**
		 * Determines to show text on the stage with help info and output text.
		 * Must be set before the call listenToStage
		 */
		public function get showDebugOutput():Boolean 
		{
			return _showDebugOutput;
		}
		
		public function set showDebugOutput(value:Boolean):void 
		{
			_showDebugOutput = value;
		}
		
		public var isReplaying:Boolean = false;
		
		private var debug:Boolean = false;
		
		private var touchBeginTime:Number;
		
		public var isRecording:Boolean = false;
		
		private var stopRecordingSet:Boolean = false;
		
		private var paused:Boolean = false;
		
		private var touchEvents:Array = new Array();
		
		private var frameIndex:uint;
		
		private var replayIndex:uint;
		
		private var canRecord:Boolean = false;
		
		private var _frameEvents:Array = new Array();
		
		public function get frameEvents():Array { return _frameEvents; }
		
		public function updateFrameEvents(frameEvents:Array):void {
			
			displayText = "Updating frame events " + frameEvents.length;
			
			_frameEvents = frameEvents;
		}
		
		private var fileReader:InputFileReader;
		
		private var debugDisplay:InputTestDisplay = null;
		
		public function set displayText(value:String):void {
			if (debugDisplay) {
				debugDisplay.DisplayText = value;
			}
		}
		
		public function Recorder() {
			fileReader = new InputFileReader(this);
			
			registerClassAlias("TouchEventProxy", TouchEventProxy); 
		}
		
		/**
		 * The stage to listen to events from
		 */ 
		public function listenToStage(stage:Stage):void {
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouch);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if(showDebugOutput) {
				debugDisplay = new InputTestDisplay();
				stage.addChild(debugDisplay);
			}
		}
		
		private function onTouch(touchEvent:TouchEvent):void {
			
			if (isReplaying) {
				return;
			}
			
			var proxy:TouchEventProxy = new TouchEventProxy(touchEvent);
			
			switch (proxy.type) {
				
				case TouchEvent.TOUCH_BEGIN:
					 if(!isRecording && canRecord) {
						 startRecording();
					 }
					 break;			
					
				case TouchEvent.TOUCH_END:
					
					if(debug) {
						trace("sequence duration", getTimer() - touchBeginTime);
					}	
					break;
			}
			
			if (isRecording){
				touchEvents.push(proxy);
			
				if (drawingOn) {
					drawCircle(proxy);
				}
			}
			
			if (proxy.type == TouchEvent.TOUCH_END &&
				stopRecordingOnTouchUp) {
					markToStopRecording();
			}
		}
		
		private function onEnterFrame(event:Event):void {
			
			if (isReplaying && frameEvents.length == 0) {
				stopReplaying();
				return;
			}
			
			if(!isReplaying) {
				grabFrameEvents();
			}
			
			if (isReplaying && !paused) {
				replayFrame();
				
				frameIndex++;
			}
			else if(isRecording){
				frameIndex++;
			}
			
			if (stopRecordingSet) {
				stopRecording();
			}
		}
		
		private function grabFrameEvents():void {
			if (isReplaying) {
				return;
			}
			
			if (isRecording) {
				
				if (touchEvents.length == 0) {
					frameEvents.push(new Array());
					return;
				}
				
				for (var i:int = 0; i < touchEvents.length; i++) {
					touchEvents[i].frame = frameIndex;
				}
				
				frameEvents.push(touchEvents);			
				touchEvents = [];
			}
		}
		
		public function startReplaying():void {
			if (isReplaying) {
				return; 
			}
			
			if(isRecording) {
				stopRecording();
			}
			
			displayText = "Replay started";
			
			isReplaying = true;
			paused = false;
			frameIndex = 0;
			replayIndex = 0;
			clearCanvas();
		}
		
		public function stopReplaying():void {
			
			displayText = "Replay stopped";
			
			isReplaying = false;
			paused = false;
			touchEvents = [];
		}
		
		public function togglePause():void {
			
			if (!isReplaying) {
				return;
			}
			
			paused = !paused;
			
			if (paused) {
				displayText = "Paused";
			}
			else {
				displayText = "Replaying";
			}
		}
		
		private function startRecording():void {
			
			touchBeginTime = getTimer();
			clearAll();
			isRecording = true;
			
			displayText = "Recording...";
		}
		
		private function markToStopRecording():void {
			
			if (!isRecording) {
				return;
			}
			
			stopRecordingSet = true;
		}
		
		public function stopRecording():void {
			isRecording = false;
			stopRecordingSet = false;
			displayText = "Recording stopped";
		}
		
		private function replayFrame():void {
			
			// stop replay
			if (replayIndex >= frameEvents.length) {
				stopReplaying();
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			if (frameEvents[replayIndex].length == 0) {
				replayIndex++;
				return;
			}
			if (frameEvents[replayIndex].length > 0 &&  
				frameEvents[replayIndex][0].frame == frameIndex) {
				
				touchEvents = frameEvents[replayIndex];
				for (var i:int = 0; i < touchEvents.length; i++) {
					
					var proxy:TouchEventProxy = touchEvents[i];
					
					var event:GWTouchEvent = proxy.asTouchEvent();
					
					event.target = HitTestHelper.getTopDisplayObjectUnderPoint(this, stage, new Point(event.stageX, event.stageY));
					event.currentTarget = event.target;
					
					switch (proxy.type){
						case TouchEvent.TOUCH_BEGIN:
							touchBeginTime = getTimer();
							event.target.dispatchEvent(event);
							TouchManager.onTouchDown(event);
							break;
						case TouchEvent.TOUCH_MOVE:
							event.target.dispatchEvent(event);
							TouchManager.onTouchMove(event);
							break;
						case TouchEvent.TOUCH_END:
							
							if(debug) {
								trace("replay sequence duration", getTimer() - touchBeginTime);
							}
							
							event.target.dispatchEvent(event);
							TouchManager.onTouchUp(event);
							break;
					}
					
					if (drawingOn) {
						drawCircle(proxy);
					}
				}
				replayIndex++;
			}
		}
		
		public function drawCircle(e:TouchEventProxy):void {
			
			if (isReplaying && !drawOnReplay) {
				return;
			}
			
			const radius:int = 10;
			
			switch (e.type) {
				case "touchBegin" : 
					graphics.beginFill(isReplaying ? 0x000000 : 0x33ff66);
					graphics.drawCircle(e.stageX, e.stageY, radius);
					graphics.endFill();
					break;
					
				case "touchMove" :
					graphics.beginFill(isReplaying ? 0x999999 : 0x6666ff);
					graphics.drawCircle(e.stageX,  e.stageY, radius);
					graphics.endFill();		
				break;
				
				case "touchEnd" : 
					graphics.beginFill(isReplaying ? 0xdddddd : 0xff6666);
					graphics.drawCircle(e.stageX, e.stageY, radius);
					graphics.endFill();
					break;
					
				default:
					break;
			}
		}
		
		public function clearCanvas():void {
			graphics.clear();
		}
		
		public function clearAll():void {
			_frameEvents = [];
			frameIndex = 0;
			replayIndex = 0;
			graphics.clear();
		}
		
		public function loadBinaryFile(byteArray:ByteArray):void {
			
			displayText = "Loading binary file";
			
			fileReader.binFileLoaded(null, byteArray);
		}
		
		public function saveToFile():void {
				if(!isReplaying) {
						fileReader.saveBinFile(frameEvents);
					}
				return;
			}
			
		public function loadFile():void {
				if(!isReplaying) {
						fileReader.readBinFile();
					}
				return;
			}
		
		private function onKey(e:KeyboardEvent):void{	
							
			switch (e.charCode) {
				case 32: // space, anim replay
					startReplaying();
					break;
					
				case 101: // 'e'
					stopReplaying();
					break;
					
				case 108: // 'l' load
					if(!isReplaying) {
						fileReader.readBinFile();
					}
					break;
					
				case 114: // 'r' 
					canRecord = !canRecord;
					
					trace(canRecord);
					break;
					
				case 115: // 's' save
					if(!isReplaying) {
						fileReader.saveBinFile(frameEvents);
					}
					break;
				
				case 99: // 'c' clear
					if (!isReplaying) {
						clearAll();	
					}
					break;
				
				case 112: // 'p' pause 
					if (isReplaying) {
						togglePause();
					}
					break;
					
				case 120: // 'x' stop recording
					markToStopRecording();
					break;
					
				default:
					break;
			}
		}
	}
}

import com.gestureworks.utils.*;

import flash.events.TouchEvent;
import com.gestureworks.events.*;
/**
 * ...
 * @author ...
 */
class TouchEventProxy 
{
	public var type:String;
	public var bubbles:Boolean;
	public var cancelable:Boolean;
	public var touchPointID:int;
	public var isPrimaryTouchPoint:Boolean;
	public var localX:Number;
	public var localY:Number;
	public var sizeX:Number;
	public var sizeY:Number;
	public var pressure:Number;

	public var stageX:int;
	public var stageY:int;
	public var timestamp:Number;
	
	public var frame:int = -1;
	
	public function TouchEventProxy(touchEvent:TouchEvent=null) 
	{
		if (!touchEvent) {
			return;
		}
		
		type = touchEvent.type;
		bubbles = touchEvent.bubbles;
		cancelable = touchEvent.cancelable;
		touchPointID = touchEvent.touchPointID;
		isPrimaryTouchPoint = touchEvent.isPrimaryTouchPoint;
		localX = touchEvent.localX;
		localY = touchEvent.localY;
		sizeX = touchEvent.sizeX;
		sizeY = touchEvent.sizeY;
		pressure = touchEvent.pressure;
		stageX = touchEvent.stageX;
		stageY = touchEvent.stageY;
		
		var now:Date = new Date();
		timestamp = now.valueOf();
	}
	
	public function asTouchEvent():GWTouchEvent {
		
		var event:GWTouchEvent = new GWTouchEvent(null, 
												type, 
												bubbles, 
												cancelable, 
												touchPointID, 
												isPrimaryTouchPoint, 
												localX, 
												localY,
												sizeX,
												sizeY);
				
				
		event.type	 = type;
		event.stageX = stageX;
		event.stageY = stageY;
		
		return event;
	}
}

import flash.display.*;
import flash.geom.Point;

/**
 * ...
 * @author ...
 */
class HitTestHelper 
{
	public static function getTopDisplayObjectUnderPoint(root:*, stage:Stage, point:Point):DisplayObject {
		
		var targets:Array = stage.getObjectsUnderPoint(point);
		
		var item:DisplayObject = (targets.length > 0) ? targets[targets.length - 1] : stage;
		item = resolveTarget(root, stage, item);
		return item;
	}
	
	private static function resolveTarget(root:*, stage:Stage, target:DisplayObject):DisplayObject {
		
		if (!target) {
			return null;
		}
		
		var ancestors:Array = targetAncestors(target, new Array(target));			
		var trueTarget:DisplayObject = target;
		
		for each(var t:DisplayObject in ancestors) {
			if (t is DisplayObjectContainer && 
				!DisplayObjectContainer(t).mouseChildren && 
				t != root && 
				!(t is Recorder))
			{
				trueTarget = t;
				break;
			}
		}
		
		return trueTarget;
	}
	
	private static function targetAncestors(target:DisplayObject, ancestors:Array = null):Array {
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

import adobe.utils.CustomActions;
import flash.events.Event;
import flash.utils.ByteArray;
import flash.net.FileReference;
import flash.net.FileFilter;
/**
 * ...
 * @author ...
 */
class InputFileReader 
{	
	private var bytes:ByteArray = new ByteArray;
	
	private var inputRecorder:Recorder;
	
	private var file:FileReference = null;
	
	private var fileFilter:Array = [new FileFilter("GestureWorks Binary (*.gwb)", "*.gwb")];
	
	public function InputFileReader(inputRecorder:Recorder) {
		this.inputRecorder = inputRecorder;
	}
	
	public function writeBinFile():void {

		file = new FileReference();
		file.addEventListener(Event.SELECT, onRefSelect);
		file.addEventListener(Event.CANCEL, onRefCancel);
		// Need user to save as GWB, but flash doesn't allow prompting for this
		file.save(bytes);
		file.removeEventListener(Event.SELECT, onRefSelect);
		file.removeEventListener(Event.CANCEL, onRefCancel);
	}
	
	public function readBinFile():void {
		
		file = new FileReference();
		file.addEventListener(Event.SELECT, binFileSelected);
		file.addEventListener(Event.COMPLETE, binFileLoaded);
		file.browse(fileFilter);
		
	}
	
	public function saveBinFile(frameEvents:Array):void {
		
		bytes.clear();
		bytes.position = 0;
		
		var objCount:int = 0;
		for (var frameIndex:int = 0; frameIndex != frameEvents.length; ++frameIndex) {
			
			for (var replayIndex:int = 0; replayIndex != frameEvents[frameIndex].length; ++replayIndex) {
			
				var touchProxy:TouchEventProxy = frameEvents[frameIndex][replayIndex];
				if (!touchProxy) {
					continue;
				}
				
				touchProxy.frame = frameIndex;
				
				bytes.writeObject(touchProxy);
				
				objCount++;
			}
		}
		
		writeBinFile();
		
		inputRecorder.displayText = "Saved file, wrote " + objCount + " touch events.";
	}
	
	private function onRefSelect(e:Event):void {
		// Empty
	}
	
	private function onRefCancel(e:Event):void {
		// Empty
	}
	
	private function binFileSelected (e:Event):void {
		file.load();
	}

	public function binFileLoaded(e:Event = null, preloadedBytes:ByteArray = null):void {
		
		var tmpBytes:ByteArray;
		
		if (!preloadedBytes && file) {
			tmpBytes = file.data;
		}
		else {
			tmpBytes = preloadedBytes;
		}
		
		if (!tmpBytes) {
			inputRecorder.displayText = "Unable to load file";
			
			return;
		}
		
		var obj:TouchEventProxy;
		var pos1:uint;
		
		var touchEventArray:Array = new Array();
		
		bytes.clear();
		while (tmpBytes.bytesAvailable) {
			pos1 = tmpBytes.position;
			obj = tmpBytes.readObject() as TouchEventProxy;
			bytes.writeObject(obj as TouchEventProxy);
		}
		
		var frames:Array = bytesToFrames();
		
		inputRecorder.updateFrameEvents(frames);
		
		inputRecorder.displayText = "Loaded file, " + frames.length + " frames";
		
		if (file){
			file.removeEventListener(Event.SELECT, binFileSelected);
			file.removeEventListener(Event.COMPLETE, binFileLoaded);
		}
	}
	
	private function bytesToFrames():Array {
		
		var tmpFrames:Array = new Array;
		var frameEvents:Array = new Array;
		
		bytes.position = 0;
		while (bytes.bytesAvailable) {
			
			var obj:* = bytes.readObject() as TouchEventProxy;
			if (obj) {
				tmpFrames.push(obj);
			}
		}
		
		var tmpTouches:Array = new Array;
		var frameNum:uint = 0;
		for (var i:uint = 0; i != tmpFrames.length; ++i) {
			
			if (frameNum != tmpFrames[i].frame) {
				frameEvents.push(tmpTouches);
				tmpTouches = [];
				frameNum = tmpFrames[i].frame
			}
			
			tmpTouches.push(tmpFrames[i]);
		}
		
		frameEvents.push(tmpTouches);
		
		return frameEvents;
	}
}

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.utils.getTimer;

/**
 * ...
 * @author ...
 */
class InputTestDisplay extends Sprite
{
	private var text:TextField;
	private var textHelp:TextField;
	
	private var displayText:String = "";
	public function set DisplayText(value:String):void {
		
		displayText = value;
		
		text.text = displayText;
	}
	
	private const HelpText:String = "space replay. touch to start recording. 'x' stop recording. 'e' stop replay. 'l' load. 's' save. 'c' clear.";
	
	public function InputTestDisplay(xPos:int = 100, 
									yPos:int = 0, 
									color:uint = 0x0000ff, 
									fillBackground:Boolean = false, 
									backgroundColor:uint = 0x000000, 
									addListener:Boolean = true) {
		x = xPos;
		y = yPos;
		
		textHelp = new TextField();
		textHelp.textColor = color;
		textHelp.text = HelpText;
		textHelp.selectable = false;
		textHelp.background = fillBackground;
		textHelp.backgroundColor = backgroundColor;
		textHelp.autoSize = TextFieldAutoSize.LEFT;
		addChild(textHelp);
		
		text = new TextField();
		text.y = textHelp.textHeight;
		text.textColor = color;
		text.text = "--------------------------";
		text.selectable = false;
		text.background = fillBackground;
		text.backgroundColor = backgroundColor;
		text.autoSize = TextFieldAutoSize.LEFT;
		addChild(text);
		
		width = textHelp.textWidth;
		height = textHelp.textHeight * 2;
	}
}