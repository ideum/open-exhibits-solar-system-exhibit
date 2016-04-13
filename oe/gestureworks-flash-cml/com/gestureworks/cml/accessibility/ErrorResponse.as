package com.gestureworks.cml.accessibility 
{
	import com.gestureworks.cml.interfaces.ISpeech;
	
	/**
	 * ...
	 * @author ...
	 */
	public final class ErrorResponse implements ISpeech 
	{
		
		private var _errorText:String;
		private var _id:String;
		
		public function ErrorResponse() {
			_errorText = "Error, speech content not found";
			id = "ErrorResponse";
		}
		
		/* INTERFACE com.gestureworks.cml.interfaces.ISpeech */
		
		public function get speechContent():String {
			return _errorText;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function set id(value:String):void {
			//TODO: might need to make sure it is unique...
			_id = value;
		}
		
	}

}