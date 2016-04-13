package com.gestureworks.utils {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	
	/**
	 * The Stats class provides a simple FPS and RAM tracking widget intended for general purpose debugging.
	 * 
	 * @author Ideum
	 */
	public class Stats extends Sprite {
		
		private var _trackFPS:Boolean = true;
		private var _trackRAM:Boolean = true;
		private var _textColor:uint;
		private var _backgroundColor:uint;
		private var _fillBackground:Boolean;
		private var _resetOnTouch:Boolean;
		
		private var padding:Number = 4;		//pixels to pad around and in-between text
		private var textFields:Vector.<TextField> = new Vector.<TextField>();
		private var fpsLabel:TextField;
		private var ramLabel:TextField;
		private var curFpsText:TextField;
		private var avgFpsText:TextField;
		private var minFpsText:TextField;
		private var maxFpsText:TextField;
		private var curRamText:TextField;
		private var avgRamText:TextField;
		private var minRamText:TextField;
		private var maxRamText:TextField;
		private var textFieldsHeight:Number = 0;
		private var textFieldsWidth:Number = 0;
		
		private var fpsHistory:Vector.<Number>;
		private var fpsHistoryStartTime:uint;
		private var fpsHistoryDuration:uint;
		private var minFps:uint = uint.MAX_VALUE;
		private var maxFps:uint = 0;
		private var fps:uint;
		private var frameSum:uint = 0;
		private var ramHistory:Vector.<uint>;
		private var ramHistoryStartTime:uint;
		private var ramHistoryDuration:uint;
		private var minRam:uint = uint.MAX_VALUE;
		private var maxRam:uint = 0;
		private var ram:uint;
		
		private var lastTime:uint = getTimer();
		private var deltaTime:uint;
		private var currentTime:uint;
		private var ticks:uint = 0;
		private var ramTimer:Timer;
		private var hitBox:Sprite;
		
		/**
		 * Constructor for the Stats class.
		 * @param	xPos desired x-position of this widget.
		 * @param	yPos desired y-position of this widget.
		 * @param	color desired text color.
		 * @param	fillBackground if true, the text background will be rendered.
		 * @param	backgroundColor The desired background color.
		 * @param	fpsHistoryDuration The duration of the running average for the FPS in milliseconds.
		 * @param	ramHistoryDuration The duration of the running average for the RAM in milliseconds.
		 * @param	resetOnTouch If true, touching the widget will cause all existing data to be reset
		 * @param	ramUpdateFrequency This parameter determines how often (in milliseconds) the ram will be updated.
		 */
		public function Stats(x:int = 0, y:int = 0, color:uint = 0xffffff, fillBackground:Boolean = true, backgroundColor:uint = 0x000000, fpsHistoryDuration:uint = 5000, ramHistoryDuration:uint = 5000, resetOnTouch:Boolean = true, ramUpdateFrequency:uint = 200) {
			super();
			super.x = x;
			super.y = y;
			_textColor = color;
			_backgroundColor = backgroundColor;
			this.fpsHistoryDuration = fpsHistoryDuration;
			this.ramHistoryDuration = ramHistoryDuration;
			
			textFieldsHeight = padding;
			textFieldsWidth = padding;
			fpsLabel = initializeField('FPS');
			curFpsText = initializeField('cur: 6000.0');
			avgFpsText = initializeField('avg: 6000.0');
			minFpsText = initializeField('min: 6000.0');
			maxFpsText = initializeField('max: 6000.0');
			fpsLabel.width = curFpsText.textWidth;
			textFieldsWidth = curFpsText.textWidth + padding * 2;
			textFieldsHeight = padding;
			ramLabel = initializeField('RAM');
			curRamText = initializeField('cur: 999.9M');
			avgRamText = initializeField('avg: 999.9M');
			minRamText = initializeField('min: 999.9M');
			maxRamText = initializeField('max: 999.9M');
			textFieldsWidth += curRamText.textWidth + padding * 2;
			textFieldsHeight += padding;
			hitBox = new Sprite();
			addChild(hitBox);
			hitBox.graphics.beginFill(0, 0);
			hitBox.graphics.drawRect(0, 0, textFieldsWidth, textFieldsHeight);
			hitBox.graphics.endFill();
			this.fillBackground = fillBackground;	//fill the bg now that we know how big the text is
			this.resetOnTouch = resetOnTouch;
			reset();
			
			//TODO: conditional add listener
			ramTimer = new Timer(ramUpdateFrequency);
			ramTimer.addEventListener(TimerEvent.TIMER, onRamTick);
			ramTimer.start();
			super.addEventListener(Event.ENTER_FRAME, framerateTick);		
		}
		
		private function initializeField(text:String = ' '):TextField {
			var tf:TextField = new TextField();
			tf.textColor = _textColor;
			tf.selectable = false;
			tf.text = text;
			tf.x = textFieldsWidth;
			tf.y = textFieldsHeight;
			tf.height = tf.textHeight + padding * 2;
			tf.width = tf.textWidth + padding * 2;
			textFieldsHeight += tf.height - padding;
			super.addChild(tf);
			textFields.push(tf);
			return tf;
		}
		
		private function formatMemoryValue(value:Number):String {
			var unit:String = 'B';
			if (value > 1048576) {
				value /= 1048576;
				unit = 'M';
			} else if (value > 1024) {
				value /= 1024;
				unit = 'K';
			}
			return value.toFixed(1) + unit;
		}
		
		private function averageVector(vector:*):Number {
			var sum:Number = 0;
			for (var i:int = 0; i < vector.length; i++) {
				sum += vector[i];
			}
			sum = sum / vector.length;
			return sum;
		}
		
		private function onRamTick(e:TimerEvent):void {
			updateRAM();
		}
		
		private function framerateTick(e:Event):void {
			updateFPS();
		}
		
		private function onTouch(e:MouseEvent):void {
			reset();
		}
		
		/**
		 * updateRam() forces an update to the RAM statistics tracking.
		 */
		public function updateRAM():void {
			if (_trackRAM) {
				ram = System.totalMemory;
				curRamText.text = 'cur: '+formatMemoryValue(ram);
				
				ramHistory.push(ram);
				currentTime = getTimer();
				if (currentTime - ramHistoryStartTime >= ramHistoryDuration) {
					avgRamText.text = 'avg: ' + formatMemoryValue(averageVector(ramHistory));
					ramHistory = new Vector.<uint>();
					ramHistoryStartTime = getTimer();
				}
				
				if (ram < minRam) {
					minRam = ram;
					minRamText.text = 'min: '+formatMemoryValue(minRam);
				}
				if (ram > maxRam) {
					maxRam = ram;
					maxRamText.text = 'max: '+formatMemoryValue(maxRam);
				}
				
			}
		}
		
		/**
		 * updateFPS forces an update to the FPS statistics tracking.
		 */
		public function updateFPS():void {
			if(_trackFPS) {
				ticks++;
				currentTime = getTimer();
				deltaTime = currentTime - lastTime;
				
				if (deltaTime >= 1000) {
					fps = ticks / deltaTime * 1000;
					curFpsText.text = 'cur: ' + fps;
					if (fps > maxFps) {
						maxFps = fps;
					}
					maxFpsText.text = 'max: ' + maxFps;
					
					if (fps < minFps) {
						minFps = fps;
					}
					minFpsText.text = 'min: ' + minFps;
					
					fpsHistory.push(fps);
					if (currentTime-fpsHistoryStartTime >= fpsHistoryDuration) {
						avgFpsText.text = 'avg: ' + averageVector(fpsHistory).toFixed(1);
						fpsHistory = new Vector.<Number>();
						fpsHistoryStartTime = getTimer();
					}
					
					ticks = 0;
					lastTime = currentTime;
				}
			}
		}
		
		/**
		 * reset forces all tracked data to be thrown out.
		 */
		public function reset():void {
			//TODO: reset all data
			ramHistory = new Vector.<uint>();
			fpsHistory = new Vector.<Number>();
			minFps = uint.MAX_VALUE;
			maxFps = 0;
			minRam = uint.MAX_VALUE;
			maxRam = 0;
			ticks = 0;
			curFpsText.text = 'cur: ----';
			minFpsText.text = 'min: ----';
			maxFpsText.text = 'max: ----';
			avgFpsText.text = 'avg: ----';
			avgRamText.text = 'avg: ' + formatMemoryValue(System.totalMemory);
			ramHistoryStartTime = getTimer();
			fpsHistoryStartTime = getTimer();
			updateRAM();
			updateFPS();
		}
		
		
		public function get trackFPS():Boolean {
			return _trackFPS;
		}
		
		/**
		 * If set to true, FPS tracking will be enabled.
		 * @default true
		 */
		public function set trackFPS(value:Boolean):void {
			_trackFPS = value;
			curFpsText.visible = _trackFPS;
			avgFpsText.visible = _trackFPS;
			minFpsText.visible = _trackFPS;
			maxFpsText.visible = _trackFPS;
		}
		
		public function get trackRAM():Boolean {
			return _trackRAM;
		}
		
		/**
		 * If set to true, RAM tracking will be enabled
		 * @default true
		 */
		public function set trackRAM(value:Boolean):void {
			_trackRAM = value;
			curRamText.visible = _trackRAM;
			avgRamText.visible = _trackRAM;
			minRamText.visible = _trackRAM;
			maxRamText.visible = _trackRAM;
		}
		
		public function get textColor():uint {
			return _textColor;
		}
		
		/**
		 * Sets the color of the text on the widget.
		 * @default 0xffffff
		 */
		public function set textColor(value:uint):void {
			if(value!=_textColor) {
				_textColor = value;
				for (var i:int = 0; i < textFields.length; i++) {
					textFields[i].textColor = _textColor;
				}
			}
		}
		
		public function get backgroundColor():uint {
			return _backgroundColor;
		}
		
		/**
		 * Sets the background color of the widget.
		 * @default 0x000000
		 */
		public function set backgroundColor(value:uint):void {
			if(value!=_backgroundColor) {
				_backgroundColor = value;
				fillBackground = fillBackground;
			}
			
		}
		
		public function get fillBackground():Boolean {
			return _fillBackground;
		}
		
		/**
		 * Determines if the background is displayed. The background will be rendered if fillBackground is set to true.
		 * @default true
		 */
		public function set fillBackground(value:Boolean):void {
			_fillBackground = value;
			if (_fillBackground) {
				super.graphics.beginFill(_backgroundColor, 0.8);
				super.graphics.drawRect(0, 0, textFieldsWidth, textFieldsHeight);
				super.graphics.endFill();
			} else {
				super.graphics.clear();
			}
		}
		
		public function get resetOnTouch():Boolean {
			return _resetOnTouch;
		}
		
		/**
		 * All data will be reset if the widget is clicked and this property is true.
		 * @default true
		 */
		public function set resetOnTouch(value:Boolean):void {
			_resetOnTouch = value;
			if (hitBox.hasEventListener(MouseEvent.CLICK)) {
				hitBox.removeEventListener(MouseEvent.CLICK, onTouch);
			}
			if (_resetOnTouch) {
				hitBox.addEventListener(MouseEvent.CLICK, onTouch);
			}
		}
		
	}
}