package com.gestureworks.cml.accessibility.behaviors {
	
	public interface IAccessibleBehavior {
		
		function init():void;
		function next():void;
		function previous():void;
		function select():void;
		function back():void;
		function home():void;
		function help():void;
		
		// activate is used for both activation and deactivation
		function activate():void;
		
		function speakComplete():void;
		function speakStop():void;
		function speakStart(duration:Number = 0.0):void;
		
	}
	
}