////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    FrameRate.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author  
	 */
	public class FrameRate extends Sprite
	{
		private var time:int;
		private var prevTime:int = 0;
		private var fps:int;
		
		private var last:uint = getTimer();
		private var ticks:uint = 0;
		private var tf:TextField;
		
		private var now:uint;
		private var delta:uint;
		
		public function FrameRate(xPos:int = 0, yPos:int = 0, color:uint = 0xffffff, fillBackground:Boolean = false, backgroundColor:uint = 0x000000, addListener:Boolean = true )
		{
			x = xPos;
			y = yPos;
			tf = new TextField();
			tf.textColor = color;
			tf.text = "----- fps";
			tf.selectable = false;
			tf.background = fillBackground;
			tf.backgroundColor = backgroundColor;
			tf.autoSize = TextFieldAutoSize.LEFT;
			addChild(tf);
			width = tf.textWidth;
			height = tf.textHeight;
			if (addListener) addEventListener(Event.ENTER_FRAME, tick);
		}
		
		public function tick(evt:Event=null):int
		{
			ticks++;
			now = getTimer();
			delta = now - last;
			if (delta >= 1000) {
				fps = ticks / delta * 1000;
				tf.text = fps.toFixed(1) + " fps";
				ticks = 0;
				last = now;
			}
			
			return fps;
		}
	
	}
}