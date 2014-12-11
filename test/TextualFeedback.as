package 
{	
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.cml.events.SpeechEvent;
	import com.gestureworks.cml.managers.SpeechManager;
	import com.gestureworks.cml.utils.SSMLObject;
	import com.gestureworks.core.GestureWorks;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	/**
	 * OE Solar System Exhibit
	 * @author Ideum
	 */
	[SWF(width = "1920", height = "1080", backgroundColor = "0x000222", frameRate = "30")]

	public class TextualFeedback extends GestureWorks
	{				
		private var speech:SpeechManager;
		private var speechProperties:SSMLObject;
		private var distance:Number;
		private var duration:Number; 
		private var text:Text; 
		private var tMask:Sprite; 
		private var tween:TweenLite;
		
		private var index:int = 0;
		private var speeches:Array = [
		
				"Earth formed approximately 4.54 billion years ago, and life appeared on its surface within one billion years. "+
				"Earth's biosphere then significantly altered the atmospheric and other basic physical conditions, which enabled the proliferation "+ 
				"of organisms as well as the formation of the ozone layer, which together with Earth's magnetic field blocked harmful solar radiation, "+ 
				"and permitted formerly ocean-confined life to move safely to land.", 
				
				"Jupiter is the fifth planet from the Sun and the largest planet in the Solar System.",
				
				"Mercury's axis has the smallest tilt of any of the Solar System's planets (about 1⁄30 of a degree), but it has the largest orbital "+
				"eccentricity. At aphelion, Mercury is about 1.5 times as far from the Sun as it is at perihelion. Mercury's surface is heavily cratered and similar "+
				"in appearance to Earth's Moon, indicating that it has been geologically inactive for billions of years.",
								
				"Earth is the third planet from the Sun, and the densest and fifth-largest of the eight planets in the Solar System. "+
				"It is also the largest of the Solar System's four terrestrial planets. It is sometimes referred to as the world or the Blue Planet."
				];
		
		public function TextualFeedback():void 
		{
			super();
			fullscreen = true; 
			speech = new SpeechManager();
			speech.addEventListener(SpeechEvent.START, onSpeechEvent);
			speechProperties = new SSMLObject("", 1.5, "en", 100, 0, 0, true);			
			gml = "library/gml/solar_gestures.gml";
		}
		
		override protected function gestureworksInit():void
 		{						
			var sphere:Sprite = new Sprite();
			sphere.graphics.beginFill(0xffffff, .8);
			sphere.graphics.drawCircle(0, 0, 250);
			sphere.x = 800;
			sphere.y = 500;
			addChild(sphere);
			
			tMask = new Sprite();
			tMask.graphics.beginFill(0xFFFF00, .6);
			tMask.graphics.drawRect(0, 0, 375, 150);
			tMask.x = -tMask.width / 2; 
			tMask.y = -125;
			
			text = new Text();
			text.font = "OpenSansBold";
			text.fontSize = 20;
			text.width = tMask.width; 	
			text.wordWrap = true; 
			text.autosize = true; 
			text.x = tMask.x;
			text.toBitmap = true; 
			
			sphere.addChild(text);			
			sphere.addChild(tMask);
			
			text.mask = tMask; 						
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.keyCode == 13) {
					if(tween){
						tween.kill();
					}
					text.y = tMask.y + 25;
					text.str = speeches[index];
					distance = (text.textHeight + 4 - tMask.height) + (text.y - tMask.y);		
					speak(text.str);
					index = index == speeches.length-1 ? 0 : index + 1; 
				}
			});
		}
		
		public function speak(value:String):void {
			var content:SSMLObject = speechProperties.clone();
			content.content = SSMLObject.stringToParagraph(value);
			speech.speak(content.encode());
		}
		
		public function onSpeechEvent(e:SpeechEvent):void {
			if (distance > 0) {
				tween = TweenLite.to(text, e.duration - 3, { y: text.y - distance, ease:Linear.easeNone, overwrite:true } );
			}
		}
	}
}
