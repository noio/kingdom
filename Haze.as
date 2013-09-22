package{
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class Haze extends FlxSprite{
        private var weather:Weather;
        private var weatherChanged:Number = -1;
        
        public function Haze(X:int, Y:int, weather:Weather){
            super(X,Y);
            this.weather = weather;
            makeGraphic(FlxG.width,FlxG.height,0x00000000);
            scrollFactor.x = 0;
        }
        
        override public function draw():void{
            if (weather.changed > weatherChanged){
                fill(0);
                Utils.gradientOverlay(pixels,[weather.haze&0xFFFFFF,weather.haze], 90,1);
                weatherChanged = weather.t;
                dirty = true;
            }
            super.draw();
        }
    }
}