package{

    import org.flixel.FlxSprite;
    import org.flixel.FlxPoint;
    import org.flixel.FlxG;
    
    public class Firefly extends Light{
        

        [Embed(source='/assets/gfx/light_small.png')] private var LightSmallImg:Class;
        [Embed(source='/assets/gfx/light_reflect_small.png')] private var LightReflectSmallImg:Class;        
    
        public static const COLOR:uint = 0xFF7affa0;
        public static const MAX_DIST:Number = 100;
        private var weatherChanged:Number = 0;
        private var startPos:FlxPoint = new FlxPoint();
        

                
        public function Firefly(X:Number, Y:Number){
            
            super(X,Y);
            startPos.x = X;
            startPos.y = Y;
            
            offset.x = 0;
            offset.y = 0;
            makeGraphic(1,1,COLOR,false);
            beam.loadGraphic(LightSmallImg);
            reflected.loadGraphic(LightReflectSmallImg);
            reflected.color = COLOR;
            addAnimation('on', [0], 6, true);

            addAnimationCallback(this.dim);
            play('on');
            setLight();
        }
        
        override public function update():void{
            // Move around a bit
            velocity.x += (FlxG.random() - 0.5) * 0.5;
            velocity.y += (FlxG.random() - 0.5) * 0.2;
            
            if (Math.abs(startPos.x - x) > MAX_DIST || Math.abs(startPos.y - y) > MAX_DIST){
                x = startPos.x;
                y = startPos.y;
                velocity.x = 0;
                velocity.y = 0;
            }
            
            if (weather.changed > weatherChanged) {
                beam.alpha = 1.5 * (weather.darkness) * (1 - weather.wind);
                beam.drawFrame(true);
                alpha = beam.alpha;
                if (alpha < 0.1 && visible) {
                    if (FlxG.random() < 0.05)
                        visible = false;
                }
                if (alpha >= 0.1 && !visible){
                    if (FlxG.random() < 0.05)
                        visible = true
                }
                weatherChanged = weather.t;
            }
            
            super.update()
        }
    }
}