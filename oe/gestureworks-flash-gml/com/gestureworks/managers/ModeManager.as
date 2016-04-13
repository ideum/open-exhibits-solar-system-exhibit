////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    ModeManager.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.managers 
{
	import com.gestureworks.core.*;
	import com.gestureworks.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	import images.GWSplash;
	import images.OESplash;
	
	public class ModeManager extends Sprite
	{
		/**
		 * INSTALLER DEPENDENT VARIABLES - DO NOT MODIFY:
		 * isOE
		 * isT
		 */
		private var isOE:Boolean = false; // open exhibits	
		private var isT:Boolean = false; // gw trial	
		
		private var splashTime:int = 2; // in seconds
		private var trialTime:int = 1800; // in seconds		
		private var gwURL:String = "http://gestureworks.com/collections/all";
		
		private var splash:Bitmap;
		private var timer:Timer;
		private var version:TextField;
		private var initialized:Boolean = false;
		private var openedURL:Boolean = false;
		private var txt:TextField;				
		private var timerTxt:TextField;	
		private var textString:String = "Gestureworks Trial Mode: ";
		private var tFormat:TextFormat;
		private var ttText:Sprite;
		private var trialTimer:Timer;
		
		public function ModeManager()
		{
			super();
			if (isOE) isT = false;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public final function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
					
			if (isOE) {
				splash = new OESplash(); 
				configSplash();
				timer = new Timer(splashTime*1000);				
				timer.addEventListener(TimerEvent.TIMER, onSplashComplete);
				timer.start();
				initialize();
			}
			else if (isT) {
				splash = new GWSplash();		
				configSplash();
				stage.addEventListener(MouseEvent.MOUSE_DOWN, openWebsite);
				stage.addEventListener(TouchEvent.TOUCH_BEGIN, openWebsite);	
				version = createSplashTxt(GestureWorks.version, 14, 0xFFFFFF);
				stage.addChild(version);				
				version.x = splash.x + 247;
				version.y = splash.y + 490;						
				createTrialTimer();
				initialize();
			}
			else {
				initialize();					
				dispose();
			}			
		}
		
		private function initialize():void
		{
			if (initialized) return;
					
			// initialize input managers
			TouchManager.gw_public::initialize();
			EnterFrameManager.gw_public::initialize();
			
			initialized = true;
		}		
		
		private function configSplash():void
		{
			stage.addChild(splash);
			splash.x = (stage.stageWidth - splash.width) / 2;
			splash.y = (stage.stageHeight - splash.height) / 2;
			stage.addEventListener(Event.ENTER_FRAME, keepOnTop);		
		}
		
		private function onSplashComplete(e:TimerEvent=null):void
		{
			if (timer) {
				timer.stop();			
				timer.removeEventListener(TimerEvent.TIMER, onSplashComplete);		
			}
			
			if (isOE) {
				stage.removeEventListener(Event.ENTER_FRAME, keepOnTop);
				stage.removeEventListener(Event.REMOVED_FROM_STAGE, onInvalidRemove);								
				stage.removeChild(splash);
				dispose();
			}
			else {
				splash.alpha = .07;
				version.alpha = .07;
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, openWebsite);
				stage.removeEventListener(TouchEvent.TOUCH_BEGIN, openWebsite);	
			}
		}
		
		private function dispose():void
		{
			if (timer) timer = null;
			if (splash) splash = null;
			if (parent && parent.contains(this))
				parent.removeChild(this);			
		}
		
		private function onInvalidRemove(event:Event):void
		{
			throw new Error("Illegal attempt to remove splash screen in trial mode.");
		}		
		
		private function keepOnTop(event:Event):void
		{
			if (splash)
				stage.setChildIndex( splash, stage.numChildren - 1 );
			if (version) 
				stage.setChildIndex( version, stage.numChildren - 1 );
			if (timerTxt)
				stage.setChildIndex( timerTxt, stage.numChildren - 1 );
		}
		
		private function trialTimerComplete():void
		{
			TouchManager.gw_public::deInitialize();
			openWebsite();
			throw new Error("Gestureworks Flash Trial has expired");
		}
		
		private function createSplashTxt(txt:String, size:Number=15, color:uint=0x000000, spacing:int=0, font:String="Arial"):TextField
		{			
			var textFormat:TextFormat = new TextFormat;
			textFormat.size = size;
			textFormat.align = TextFormatAlign.LEFT;
			textFormat.color = color;
			textFormat.font = font;
			textFormat.letterSpacing = spacing;
			
			var stxt:TextField = new TextField;
			stxt.defaultTextFormat = textFormat;
			stxt.text = txt;
			stxt.antiAliasType = AntiAliasType.ADVANCED;
			stxt.multiline = true;
			stxt.wordWrap = true;
			stxt.embedFonts = true;
			stxt.selectable = false;
			
			return stxt;
		}		
		
		private function openWebsite(event:*=null):void
		{
			if (openedURL) return;
			var request:URLRequest = new URLRequest(gwURL);
			navigateToURL(request, "_blank");
			openedURL = true;
		}
				
		private function createTrialTimer():void
		{			
			timerTxt = new TextField;
			timerTxt.antiAliasType = AntiAliasType.ADVANCED;
			timerTxt.autoSize = TextFieldAutoSize.RIGHT;
			timerTxt.embedFonts = true;
			timerTxt.selectable = false;
			stage.addChild(timerTxt);
			
			tFormat = new TextFormat("OpenSansRegular", 22, 0xFFFFFF);	
			tFormat.align = TextFormatAlign.RIGHT;
			timerTxt.defaultTextFormat = tFormat;			
			timerTxt.text = textString + "30:00";
			timerTxt.x = stage.stageWidth - timerTxt.width - 10;
			timerTxt.y = 5;
			
			trialTimer = new Timer(1000);
			trialTimer.addEventListener(TimerEvent.TIMER, updateDisplay);
			trialTimer.start();			
		}
		
		private function updateDisplay(event:TimerEvent):void
		{
			trialTime--;			
			
			if (trialTimer.currentCount == splashTime) {
				onSplashComplete();
			}
			
			updateTimerTxt(textString + formatTime(trialTime));
			
			if (trialTime == 0) {
				trialTimer.stop();
				trialTimer.removeEventListener(TimerEvent.TIMER, updateDisplay);
				trialTimerComplete();
				updateTimerTxt("Gestureworks Trial Ended");
			}	
		}
		
		private function updateTimerTxt(txt:String):void
		{
			timerTxt.text = txt;
			timerTxt.defaultTextFormat = tFormat;			
		}
		
		private function formatTime(seconds:Number):String
		{
			var s:Number = seconds % 60;
			var m:Number = Math.floor((seconds % 3600 ) / 60);
			 
			var minuteStr:String = doubleDigitFormat(m) + ":";
			var secondsStr:String = doubleDigitFormat(s);
			 
			return minuteStr + secondsStr;
		}
		 
		private function doubleDigitFormat(num:uint):String
		{
			if (num < 10) 
				return ("0" + num);
			return String(num);
		}	
		
	}
}