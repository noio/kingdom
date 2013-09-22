package{
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class Sky extends FlxSprite{
        
        private var weather:Weather;
        private var weatherChanged:Number = 0;
        
        public function Sky(weather:Weather):void{
            this.weather = weather;
            scrollFactor.x = scrollFactor.y = 0;
            makeGraphic(FlxG.width,FlxG.height,0x00000000,true);
        }
        
        
        override public function update():void{
            if (weather.changed > weatherChanged) {
                Utils.gradientOverlay(pixels, [weather.sky, weather.horizon, weather.haze],90, 1);
                dirty = true;
                weatherChanged = weather.t;
            }
        }
        
        
    }
}