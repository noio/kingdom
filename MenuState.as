package
{
	import org.flixel.*;

	public class MenuState extends FlxState
	{
        [Embed(source='/assets/gfx/title.png')]        private var TitleImg:Class;
        [Embed(source='/assets/gfx/outline_noio.png')] private var NoioImg:Class;
        [Embed(source='/assets/gfx/outline_pez.png')]  private var PezImg:Class;

        public var noioHighlight:FlxSprite;
        public var pezHighlight:FlxSprite;
        
		override public function create():void
		{   
            add(new FlxSprite(0,0, TitleImg));

			add(noioHighlight = new FlxSprite(228,123, NoioImg));
			add(pezHighlight = new FlxSprite(258,123, PezImg));
			noioHighlight.width = 30;
			noioHighlight.visible = false;
			pezHighlight.visible = false;

			var t:FlxText = new FlxText(0,0,100,king.VERSION);
			t.alignment = "left";
			t.alpha = 0.24
			add(t);

			FlxG.mouse.show();
		}

		override public function update():void
		{
			super.update();

			if (FlxG.mouse.x > noioHighlight.x && FlxG.mouse.x < noioHighlight.x + noioHighlight.width &&
				FlxG.mouse.y > noioHighlight.y && FlxG.mouse.y < noioHighlight.y + noioHighlight.height){
				noioHighlight.visible = true;
				if(FlxG.mouse.justPressed()){
					FlxU.openURL("http://www.noio.nl");
				}
			} else {
				noioHighlight.visible = false
			} 
			
			if (FlxG.mouse.x > pezHighlight.x && FlxG.mouse.x < pezHighlight.x + pezHighlight.width &&
				FlxG.mouse.y > pezHighlight.y && FlxG.mouse.y < pezHighlight.y + pezHighlight.height){
				pezHighlight.visible = true;
				if(FlxG.mouse.justPressed()){
					FlxU.openURL("http://soundcloud.com/pez_pez");
				}
			} else {
				pezHighlight.visible = false;
			}

			if(!noioHighlight.visible && !pezHighlight.visible && FlxG.mouse.justPressed())
			{
				FlxG.mouse.hide();
				FlxG.switchState(new PlayState());
			}
		}
	}
}
