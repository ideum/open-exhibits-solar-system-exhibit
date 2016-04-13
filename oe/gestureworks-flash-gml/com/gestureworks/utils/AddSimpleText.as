////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    AddSimpleText.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils
{	
	import flash.display.*;
	import flash.text.*;

	public class AddSimpleText extends  Sprite {
		private var mytext:TextField;
		private var format:TextFormat;
		private var wNum:Number;
		private var hNum:Number;
			
		public function AddSimpleText(W:Number, H:Number,align:String, color:Number, size:Number, autoSize:String="none") {
			wNum = W;
			hNum = H;
			
			mytext = new TextField();
				mytext.embedFonts = true;
				mytext.selectable = false;
				mytext.wordWrap = false;
				mytext.mouseEnabled = false;
				mytext.antiAliasType = AntiAliasType.ADVANCED;
				mytext.autoSize = autoSize

				format = new TextFormat();
					format.color = color;
					format.size = size;
					format.font = "OpenSansRegular";
					format.align = align;
				mytext.setTextFormat(format);
				
			this.addChild(mytext);
		}
		
		public function set textCont(txt:String):void{
			mytext.htmlText = txt;
			mytext.setTextFormat(format);
			mytext.width = wNum;
			mytext.height = hNum;
		}
		
		public function get textColor():Object { return format.color };
		public function set textColor(color:Object):void {
			if (format.color == color) return;			
			format.color = color;
			mytext.setTextFormat(format);
		}
		
		public function set textFont(name:String):void{
			format.font = name;
			mytext.setTextFormat(format);
		}
		
		public function set textWrap(w:Boolean):void{
			mytext.wordWrap = w;
		}
		
	}
}