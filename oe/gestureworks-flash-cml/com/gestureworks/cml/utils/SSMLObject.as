package com.gestureworks.cml.utils {
	
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.elements.State;
	import com.gestureworks.cml.interfaces.IState;
	import com.gestureworks.cml.utils.StateUtils;
	import flash.utils.Dictionary;
	
	public class SSMLObject implements IState {
		
		public static const EMPTY:String = '<Speak></Speak>';
		public var state:Dictionary;
		
		/**
		 * Converts the value parameter to a SSML sentence.
		 * @param	value
		 * @return	String representation of the SSML sentence.
		 */
		public static function stringToSentence(value:String):String {
			return '<s>' + value + '</s>';
		}
		
		/**
		 * Converts the value parameter to a SSML paragraph.
		 * @param	value
		 * @return	String representation of the SSML paragraph.
		 */
		public static function stringToParagraph(value:String):String {
			return '<p>' + value + '</p>';
		}
		
		private var _rate:Number;
		private var _language:String;
		private var _volume:Number;
		private var _content:String;
		private var _user:int; 
		private var _pan:Number;
		private var _preempt:Boolean;
		
		public function SSMLObject(content:String = "", rate:Number = 1.0, language:String = "en", volume:Number = 100, user:int = 0, pan:Number = 0, preempt:Boolean=false) {
			id = "ssml";
			state = new Dictionary(false);
			state[0] = new State(false);
			_rate = rate;
			_language = language;
			_volume = volume;
			_content = content;
			_user = user;
			_pan = pan;
			_preempt = preempt;
		}
		
		public function clone():SSMLObject {
			return new SSMLObject(_content, _rate, _language, _volume, _user, _pan, _preempt);
		}
		
		public function encode():String {
			var ret:String = "<speak version=\"1.0\""
			+ " xmlns=\"http://www.w3.org/2001/10/synthesis\""
			+ " xml:lang=\""+_language+"\">"
			+'<prosody user="'+_user+'" rate="'+_rate+'" volume="'+_volume+'" pan="'+_pan+'" preempt="'+_preempt+'" >'
			+ _content
			+'</prosody>'
			+'</speak>';
			return ret;
		}
		
		public function toString():String {
			return encode();
		}
		
		public function get preempt():Boolean { return _preempt; }
		public function set preempt(value:Boolean):void {
			_preempt = value; 
		}
		
		public function get rate():Number { return _rate; }		
		public function set rate(value:Number):void {
			_rate = value;
		}
		
		/**
		 * ISO 639-1. See constants defined in LanguageCode.as
		 */
		public function get language():String { return _language; }		
		public function set language(value:String):void {
			_language = value;
		}
		
		public function get volume():Number { return _volume; }		
		public function set volume(value:Number):void {
			_volume = value;
		}
		
		public function get pan():Number { return _pan; }
		public function set pan(value:Number):void {
			_pan = value; 
		}
		
		public function get content():String { return _content; }		
		public function set content(value:String):void {
			_content = value;
		}
		
		/**
		 * IState Implementation
		 */
		
		private var _stateId:String
		
		/**
		 * @inheritDoc
		 */
		public function get stateId():* {return _stateId};
		public function set stateId(value:*):void { _stateId = value; }
		
		/**
		 * @inheritDoc
		 */
		public function loadState(sId:* = null, recursion:Boolean = false):void { 
			if (StateUtils.loadState(this, sId, recursion)){
				_stateId = sId;
			}
		}	
		
		/**
		 * @inheritDoc
		 */
		public function saveState(sId:* = null, recursion:Boolean = false):void { StateUtils.saveState(this, sId, recursion); }		
		
		/**
		 * @inheritDoc
		 */
		public function tweenState(sId:*= null, tweenTime:Number = 1):void {
			if (StateUtils.tweenState(this, sId, tweenTime))
				_stateId = sId;
		}
		
		////// partial IObject implementation
		
		private var _id:String
		/**
		 * @inheritDoc
		 */
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		/**
		 * @inheritDoc
		 */	
		public function updateProperties(state:*=0):void
		{
			CMLParser.updateProperties(this, state);		
		}
		
	}

}