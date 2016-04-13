package com.gestureworks.cml.accessibility.feedback.sounds {
	import com.gestureworks.cml.accessibility.feedback.IFeedback;
	import com.gestureworks.cml.elements.Container;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import acc.ActivateSound;
	
	/**
	 * ...
	 * @author Ken Willes
	 */
	public final class Activate extends Sound implements IFeedback {
		
		private var _sound:ActivateSound;
		private var _soundChannel:SoundChannel;
		
		public function Activate() {
			super();
			_sound = new ActivateSound();

		}
		
		/* INTERFACE com.gestureworks.cml.accessibility.feedback.IFeedback */
		public function start(item:String):void {
			if (_soundChannel == null) {
				_soundChannel = _sound.play();
			} else {
				_soundChannel.stop();
				_soundChannel = _sound.play();
			}
			
		}
		
		public function cancel():void {
			if (_soundChannel != null) {
				_soundChannel.stop();
			}
		}
		
	}

}