package
{
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.DisplacementMapFilterMode;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import org.flixel.FlxSprite;
    import org.flixel.FlxGroup;
    import org.flixel.FlxG;

    public class Water extends FlxSprite
    {
        
        public static const NOISE_BIAS:int = 100;
        public static const WIND_RIPPLE_MULTIPLIER:Number = 25;
        
        private var rect:Rectangle = new Rectangle(0, 0, 480, 160);
        //private var point:Point = new Point(0, 160);
        private var zeroPoint:Point = new Point(0, 0);
        private var perlinOffset:Point = new Point(0,0)
        private var matrix:Matrix = new Matrix();
        private var transform:ColorTransform;
        private var noiseRange:ColorTransform;
        private var displacementFilter:DisplacementMapFilter;
        private var displacementBitmap:BitmapData;
        private var baseColor:uint;
        private var currentBase:uint;
        private var timer:Number = 0;
        private var lights:FlxGroup;
        private var weather:Weather;
        private var weatherChanged:Number = -1;

        public function Water(x:int,y:int,width:int,height:int,lights:FlxGroup,weather:Weather,baseColor:uint=0xFF686C53,reflectivity:Number=0.3)
        {
           
            // Set height/width/x/y
            this.x = x;
            this.y = y;
            moves = false;
            scrollFactor.x = 0;
            
            transform          = new ColorTransform(1,1,1,reflectivity);
            rect               = new Rectangle(0,0,width,height);
            displacementBitmap = new BitmapData(width, height, false, 0);
            makeGraphic(width,height,baseColor);
            
            this.lights = lights;
            this.weather = weather;
            this.baseColor = baseColor;
            
            // This is the filter that makes the reflection ripple
            displacementFilter = new DisplacementMapFilter(displacementBitmap, zeroPoint, 1, 2, 256, 256, DisplacementMapFilterMode.COLOR, baseColor, 0.5);
            
            // Reduce the range of perlin transform
        }

        override public function update():void
        {
            
            timer += FlxG.elapsed;
            if (weather.changed > weatherChanged){
                currentBase = 0xFF000000 | Utils.interpolateColor(baseColor, weather.darknessColor, weather.darkness)
                
                var rippleScale:int = int(weather.wind*WIND_RIPPLE_MULTIPLIER);
                var xscale:int = rippleScale/2;
                var yscale:int = rippleScale;
                noiseRange = new ColorTransform(xscale/128,yscale/128,1,1,(128-xscale+(NOISE_BIAS*xscale/128)),(128-yscale+(NOISE_BIAS*yscale/128)),1,1)
                weatherChanged = weather.t
            }
        }

        override public function draw():void
        {
            if (timer > 0.1)
            { // Update the water ripple
                perlinOffset.y += 1/5;
                perlinOffset.x = FlxG.camera.scroll.x*1.5;
                displacementBitmap.perlinNoise(32, 4, 1, 12312, false, false, 1|2, true, [perlinOffset]);
                displacementBitmap.colorTransform(rect,noiseRange);
                // Adjust the base color according to the weather.
                displacementFilter.color = currentBase;
                timer = 0;
            }
            var px:BitmapData = pixels;
            matrix.identity();
            matrix.scale(1, -1);
            getScreenXY(_point);
            matrix.translate(-_point.x, _point.y);
            // Clear the reflection
            px.fillRect(rect, currentBase);
            Utils.gradientOverlay(px, [0x00000000,0x66000000], 90, 4);
            // Flip the screen and copy it to the reflection
            px.draw(FlxG.camera.buffer, matrix, transform);
            
            // Draw the lights
            var l:Light;
            for (var i:int = 0; i < lights.length; i++){
                l = lights.members[i] as Light;
                l.getScreenXY(_point);
                if(l.visible && -64 < _point.x && _point.x < FlxG.width + 64){
                    l.reflected.alpha = weather.darkness * 0.8;
                    l.reflected.alpha *= Math.min(1.0, (weather.wind * 10));
                    l.reflected.drawFrame();
                    stamp(l.reflected, _point.x - l.reflected.width/2 + 4, (y - l.y) * 0.3);
                }
            }
            
            // Apply the ripple filter
            px.applyFilter(px, rect, zeroPoint, displacementFilter); 
            dirty = true;
            super.draw()
        }
    }
}
