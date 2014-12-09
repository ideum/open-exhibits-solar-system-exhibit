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
	[SWF(width = "1280", height = "720", backgroundColor = "0x000000", frameRate = "30")]

	public class Main extends GestureWorks
	{
		private var speech:SpeechManager;
		private var speechProperties:SSMLObject;
		private var speechProperties2:SSMLObject;
		private var speechProperties3:SSMLObject;
		private var words:Array = ["There must be some kind of way out of here", "Said the joker to the theif", "There's too much confusion, I can't get no relief."];
		private var words2:Array = ["Business men they drink my wine", "Plowmen dig my earth", "None will live on the line, Nobody of it is worth"];
		private var index:int = 0;
		
		public function Main():void 
		{
			super();
			gml = "library/gml/solar_gestures.gml";
			speech = new SpeechManager();
			speechProperties = new SSMLObject("", 1.5, "en", 100, 0, 0, true);
			speechProperties2 = new SSMLObject("", 1.5, "en", 100, 1, 0, true);
			speechProperties3 = new SSMLObject("", 1.5, "en", 100, 2, 0, true);
		}
		
		override protected function gestureworksInit():void
 		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if(e.keyCode == 13){
					speak("Welcome to the solar system exhibit. Use touch gestures to interact");
				}
				else if (e.keyCode == 191) {
					speak2("Welcome to the solar system exhibit. Use touch gestures to interact");	
				}
				else if (e.keyCode == 16) {
					speak3("Welcome to the solar system exhibit. Use touch gestures to interact");
				}
				index = index == words.length -1 ? 0 : index + 1; 
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
		
		public function speak2(value:String):void {
			var content:SSMLObject = speechProperties2.clone();
			content.content = SSMLObject.stringToParagraph(value);
			speech.speak(content.encode());
		}
		
		public function speak3(value:String):void {
			var content:SSMLObject = speechProperties3.clone();
			content.content = SSMLObject.stringToParagraph(value);
			speech.speak(content.encode());
		}		
	}
}
