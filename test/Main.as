package 
{	
	import com.gestureworks.cml.managers.SpeechManager;
	import com.gestureworks.cml.utils.SSMLObject;
	import com.gestureworks.core.GestureWorks;
	import flash.events.KeyboardEvent;
	/**
	 * OE Solar System Exhibit
	 * @author Ideum
	 */
	[SWF(width = "1920", height = "1080", backgroundColor = "0x000000", frameRate = "30")]

	public class Main extends GestureWorks
	{
		private var speech:SpeechManager;
		private var speechProperties:SSMLObject;
		
		public function Main():void 
		{
			super();
			gml = "library/gml/solar_gestures.gml";
			speech = new SpeechManager();
			speechProperties = new SSMLObject();
		}
		
		override protected function gestureworksInit():void
 		{
			//speak("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ");	
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				//speak("A Yo I stand outside the gates of Buckingham Palace Selling reefer, puffin the chalice with the Beefeaters, Gettin so high that whenever I drop shit, it'll land on the window of your airplane cockpit");
				speak("testing this shit out");
			});			
		}		
		
		/**
		 * Converts the inputted value to a SSML encoded object using the prosody and language properties from the speechProperties field and speaks it.
		 * @param	value String to be spoken.
		 */
		public function speak(value:String):void {
			var content:SSMLObject = speechProperties.clone();
			content.content = SSMLObject.stringToParagraph(value);
			speech.speak(content.encode());
		}		
	}
}
