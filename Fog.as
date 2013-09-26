package
{
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxGroup;
    import org.flixel.FlxObject;
    import org.flixel.FlxG;
    import org.flixel.FlxPoint;
    
    public class Fog extends FlxGroup{
        [Embed(source='/assets/gfx/fog.png')]  private const FogImg:Class;

        public static const MAXFOG:int = 5;
        
        private var weather:Weather;
        private var weatherChanged:Number = -1;
        private var _fg:FlxSprite;
        private var _point:FlxPoint = new FlxPoint();
        
        public function Fog(weather:Weather){
            super(MAXFOG)
            this.weather = weather;
            
            for (var i:int = 0; i < MAXFOG; i++){
                _fg = new FlxSprite(0,0).loadGraphic(FogImg,true,true,256,96);
                _fg.scrollFactor.y = 1.2;
                _fg.scrollFactor.x = (FlxG.random() < 0.5) ? 1.5 : 2.5;
                _fg.facing = (FlxG.random() < 0.5) ? FlxObject.LEFT : FlxObject.RIGHT;
                _fg.frame = int(FlxG.random()*4);
                _fg.kill();
                add(_fg);
            }
        }
        
        override public function update():void{
            for (var i:int = 0; i < members.length; i++){
                _fg = members[i]
                if (_fg.exists){
                    _fg.getScreenXY(_point)
                    if (_point.x + _fg.width < -100 || _point.x > FlxG.width + 100) {
                        _fg.kill();
                    } else {
                        _fg.velocity.x = -weather.wind*20;
                    }
                }
            }
            if (weather.changed > weatherChanged){
                // TODO: Does this run every frame?
                if (countLiving() < MAXFOG * weather.fog) {
                    _fg = getFirstAvailable() as FlxSprite;
                    _fg.reset(0,0);
                    if (FlxG.random() < 0.5){
                        _fg.x = FlxG.camera.scroll.x*_fg.scrollFactor.x - _fg.width;
                    } else {
                        _fg.x = (FlxG.camera.scroll.x)*_fg.scrollFactor.x + FlxG.width
                    }
                    _fg.y = 112 + 50*FlxG.random();
                    var comp:uint = (1 - weather.darkness)*255;
                    var color:uint = comp << 16 | comp << 8 | comp;
                    _fg.color = color;
                    _fg.alpha = weather.fog/6 + 0.3;
                }
                weatherChanged = weather.t;
            }
            super.update();
        }
    }
}