package com.gestureworks.cml.accessibility.feedback.sounds {
	import com.gestureworks.cml.accessibility.feedback.IFeedback;
	import com.gestureworks.cml.elements.Container;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import acc.ClickSound;
	
	/**
	 * ...
	 * @author Ken Willes
	 */
	public final class TriggerMenu extends Sound implements IFeedback {
		
		private var _sound:ClickSound;
		private var _soundChannel:SoundChannel;
		
		public function TriggerMenu() {
			super();
			_sound = new ClickSound();

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