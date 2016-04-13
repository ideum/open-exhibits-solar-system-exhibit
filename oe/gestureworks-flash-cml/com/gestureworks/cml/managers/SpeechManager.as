package com.gestureworks.cml.managers {
	import com.gestureworks.cml.events.SpeechEvent;
	import com.gestureworks.cml.utils.SSMLObject;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class SpeechManager implements IEventDispatcher {
		/// @eventType	com.gestureworks.cml.events.SpeechEvent
		[Event(name = "SpeechEvent_Start", type = "com.gestureworks.cml.events.SpeechEvent")]
		
		/// @eventType	com.gestureworks.cml.events.SpeechEvent
		[Event(name = "SpeechEvent_Stop", type = "com.gestureworks.cml.events.SpeechEvent")]
		
		/// @eventType	com.gestureworks.cml.events.SpeechEvent
		[Event(name = "SpeechEvent_Complete", type = "com.gestureworks.cml.events.SpeechEvent")]
		
		private static const STOP:String = "stop";
		private static const SPEAK:String = "speak";
		private static const COMPLETE:String = "complete";
		private static const NONE:String = "none";
		
		private static const SERVER_URL:String = "ws://localhost:81";
		private var dispatcher:EventDispatcher;
		private var websocket:WebSocket;
		private var actions:Array;
		private var stopInProgress:Boolean;
		private var timer:Timer;
		
		private var msgXML:XML;
		private var msgActions:XMLList;
		private var type:String;
		private var user:String; 
		private var duration:Number; 
		
		public function SpeechManager() {
			actions = new Array();
			dispatcher = new EventDispatcher(this);
			websocket = new WebSocket(SERVER_URL, "*");
			websocket.debug = false;
			websocket.addEventListener(WebSocketEvent.OPEN, handleSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleSocketMessage);
			websocket.addEventListener(IOErrorEvent.IO_ERROR, handleSocketError);
			websocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSocketError);
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleSocketError);
			websocket.addEventListener(WebSocketEvent.CLOSED, handleSocketClosed);
			websocket.connect();
		}
		
		public function speak(value:String):void {
			pushAction(SPEAK, value);
		}
		
		public function stop():void {
			pushAction(STOP);
		}
		
		/**
		 * Responsible for parsing server messages and firing relavent events. 
		 * @param	message - String to be converted to an XML server message
		 */
		private function processRequest(message:String):void {
			msgXML = new XML(message);
			msgActions = msgXML.descendants("action"); 
			for each(var node:XML in msgActions) {
				type = node.attribute("type");
				user = node.attribute("user");
				duration = node.attribute("duration");
				if (type == "speak") {
					dispatchEvent(new SpeechEvent(SpeechEvent.START, user, duration));
				} else if (type == "complete") {
					dispatchEvent(new SpeechEvent(SpeechEvent.COMPLETE, user, duration));
				} else if (type == "stop") {
					dispatchEvent(new SpeechEvent(SpeechEvent.STOP, user));
				} else {
					
				}
			}
		}
		
		private function handleSocketOpen(event:WebSocketEvent):void {
			//trace('Client: Socket opened. Starting heartbeat');
			sendResponse(); //Send 'empty' message to get the server heartbeat started.
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, handleTimer);
				timer = null;
			}
		}
		
		private function handleSocketMessage(event:WebSocketEvent):void {
			//trace("Client: "+event.message.utf8Data);
			processRequest(event.message.utf8Data);
			sendResponse();
		}
		
		private function sendResponse():void {
			var response:String = "<data>";
			if (actions.length == 0) {
				pushAction(NONE);
			}
			for (var i:int = 0; i < actions.length; i++) {
				response += actions[i];
				if (actions.length > 1) {
					trace();
				}
			}
			actions = new Array();
			response += "</data>";
			websocket.sendUTF(response);
		}
		
		private function handleSocketError(event:Event):void {
			//trace('Client: Socket error:' + event);
			websocket.removeEventListener(WebSocketEvent.CLOSED, handleSocketClosed);
			websocket.close();
			websocket.addEventListener(WebSocketEvent.CLOSED, handleSocketClosed);
			retry();
			//trace('Socket closed from error....');
		}
		
		private function handleSocketClosed(event:WebSocketEvent):void {
			//trace('Client: Socket closed.');
			retry();
		}
		
		private function retry():void {
			if (!timer) {
				timer = new Timer(200);
				timer.addEventListener(TimerEvent.TIMER, handleTimer);
				timer.start();
			}
		}
		
		private function handleTimer(e:TimerEvent):void {
			websocket.connect();
		}
		
		private function pushAction(type:String, speech:String = ""):void {
			var s:String = 
			 "<action type=\""+type+"\">"
			+ speech
			+"</action>";
			actions.push(s);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return dispatcher.dispatchEvent(event);
			
		}
		
		public function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		
	}
}