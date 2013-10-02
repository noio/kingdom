package
{
	import org.flixel.*;
	import mochi.as3.MochiServices;
	import flash.events.Event;
	
	[SWF(width="864", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class king extends FlxGame
	{

		public static var strMochiGameRes:String = "864x480";

		public function king()
		{			
			super(288,160,MenuState,3, 60, 60);
			addEventListener(Event.ADDED_TO_STAGE, init);
			var _mochiads_game_id:String = "0388f37fc4182a78";
		}

		public function init(e:Event):void{
			 MochiServices.connect( "0388f37fc4182a78", this );
		}

		public function onConnectError(status:String):void{
			FlxG.log(status);
		}
	}
}
