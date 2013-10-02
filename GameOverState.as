package
{
	import org.flixel.*;
	import flash.ui.Mouse;	
    import mochi.as3.MochiScores;

	public class GameOverState extends FlxState
	{        
		private var days:int = 0;

		public function GameOverState(daysSurvived:int){
			this.days = daysSurvived;
		}

		override public function create():void
		{
			var t:FlxText;
			t = new FlxText(0,10,FlxG.width,"Game Over");
			t.size = 16;
			t.alignment = "center";
			add(t);
			t = new FlxText(0,FlxG.height-20,FlxG.width,"click to start over");
			t.alignment = "center";
			add(t);
			
			t = new FlxText(0,32,FlxG.width,"'Kingdom' by noio");
			t.alignment = "center";
			add(t);

			FlxG.stage.displayState = 'normal';

            var o:Object = { n: [10, 7, 3, 4, 10, 0, 2, 14, 15, 9, 7, 13, 9, 3, 11, 4], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
            var boardID:String = o.f(0,"");
            MochiScores.showLeaderboard({boardID: boardID, score: days,
            	onDisplay: onLeaderboardDisplay,
            	onClose: onLeaderboardClose});
		}

		private function onLeaderboardDisplay():void{
			FlxG.mouse.hide();
			Mouse.show();
		}

		private function onLeaderboardClose():void{
			FlxG.mouse.show();
			Mouse.hide();
		}

		override public function update():void
		{
			super.update();

			if(FlxG.mouse.justPressed())
			{
				FlxG.mouse.hide();
				FlxG.switchState(new PlayState());
				MochiScores.closeLeaderboard();
			}
		}
	}
}
