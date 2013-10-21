package
{
	import org.flixel.*;
	
	
	[SWF(width="864", height="480", backgroundColor="#000000")]

	// Just switch these two preloaders to compile without MochiAds.
	// [Frame(factoryClass="Preloader")]
	[Frame(factoryClass="MochiWrapper")]

	public class king extends FlxGame
	{	
		public static const VERSION:String = 'v1.1.2';

		public function king()
		{			
			super(288,160,MenuState,3, 60, 60, false);
			FlxG.debug = true;
		}

	}
}
