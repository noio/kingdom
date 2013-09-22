package
{
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class Coinsack extends FlxSprite{
        
        [Embed(source='/assets/gfx/sack.png')]     private var Img:Class;
        
		public static const FADE_TIME:Number = 20;
		public static var t:Number = 0;
		
        public function Coinsack(X:Number=0, Y:Number=0){
            super(X, Y);
			
            loadGraphic(Img,true,false,16,16);
            scrollFactor.x = scrollFactor.y = 0;

        }
		
		public function show(c:int):void{
            if (c == 0) {
                frame = 0;
            } else if (c == 1) {
                frame = 1;
            } else if (c >= 2 && c <= 3){
                frame = 2;
            } else if (c >= 4 && c <= 5){
                frame = 3;
            } else if (c >= 6 && c <= 8){
                frame = 4;
            } else if (c >= 9 && c <= 11){
                frame = 5;
            } else if (c >= 12 && c <= 15){
                frame = 6;
            } else if (c >= 15){
                frame = 7
            }
			t = 0;
		}
		
		override public function update():void{
			t += FlxG.elapsed;
			alpha = FADE_TIME - t;
		}
    }
}
