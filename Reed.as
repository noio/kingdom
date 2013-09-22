package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Reed extends FlxSprite{
        
        [Embed(source='/assets/gfx/reed.png')]    private var ReedImg:Class;
        
        private var weather:Weather;
        private var weatherChanged:Number = 0;        
        private var t:Number = 0;
        
        public function Reed(X:int, Y:int){
            super(X,Y);
            loadGraphic(ReedImg, true, false, 32, 32);
            
            this.weather = (FlxG.state as PlayState).weather;
        }
        
        override public function update():void{
            t += weather.wind;
            frame = int(3 * (0.5 + 0.5*Math.sin(0.05*t + x)) + 0.3 * Math.sin(0.2*t));
            /*if (weather.changed > weatherChanged) {
                weatherChanged = weather.t;
                var wind:Number = weather.wind;
                wind = wind * (0.5 + 0.5*Math.sin(x + weather.t*wind*3) + 0.3*Math.sin(x + weather.t*wind*5));
                frame = int(3*(1-wind))
            }*/
        }
        
    }
}