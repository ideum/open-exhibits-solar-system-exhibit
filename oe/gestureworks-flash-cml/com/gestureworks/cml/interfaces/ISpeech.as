package com.gestureworks.cml.interfaces {
	
	public interface ISpeech {
		function get speechContent():String;
		/**
		 * Returns the object's id.
		 */
		function get id():String;
		
		/**
		 * Sets the object's id.
		 * @param value
		 */
		function set id(value:String):void;	
	}
	
}