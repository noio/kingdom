package
{
	import org.flixel.*;

	public class MenuState extends FlxState
	{
        [Embed(source='/assets/gfx/title.png')]    private var TitleImg:Class;
        
		override public function create():void
		{
			var t:FlxText;
			t = new FlxText(0,FlxG.height/2-10,FlxG.width,"Kingdom");
			t.size = 16;
			t.alignment = "center";
			add(t);
			t = new FlxText(FlxG.width/2-50,FlxG.height-20,100,"click to play");
			t.alignment = "center";
			add(t);
			
			t = new FlxText(FlxG.width/2-50,FlxG.height-50,100,"by noio");
			t.alignment = "center";
			add(t);
            
            add(new FlxSprite(0,0, TitleImg));
            
			FlxG.mouse.show();
		}

		override public function update():void
		{
			super.update();

			if(FlxG.mouse.justPressed())
			{
				FlxG.mouse.hide();
				FlxG.switchState(new PlayState());
			}
		}
	}
}
