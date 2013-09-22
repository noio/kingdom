package
{
	import org.flixel.*;
	[SWF(width="864", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class king extends FlxGame
	{
		public function king()
		{
			super(288,160,MenuState,3, 60, 60);
		}
	}
}
