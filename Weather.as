package{
    
    import org.flixel.FlxG;
    
    import com.quasimondo.geom.ColorMatrix
    
    public class Weather extends Object{
    
        public var sky:uint           = 0xFF8C8CA6;
        public var horizon:uint       = 0xFFCF7968;
        public var haze:uint          = 0xAAf3f1e8;
        public var darknessColor:uint = 0x88111114;
        public var darkness:Number    = 1.0;
        public var contrast:Number    = 0.3;
        public var saturation:Number  = 1.0
        public var ambient:uint       = 0x11FF0000;
        public var wind:Number        = 0.0;
        public var fog:Number         = 0.5;
        public var rain:Number        = 0.5;
        public var timeOfDay:Number   = 0.5;
        public var sunTint:uint       = 0xFFFFFF;
        
        public var ambientTransform:ColorMatrix = new ColorMatrix();
        
        public var t:Number        = 0;
        public var changed:Number  = 0;
        public var progress:Number = 0;
        public var ambientAmount:Number = 0;
        
        public var tweenStart:Number    = 0;
        public var tweenDuration:Number = 0.0;
        public var previousState:Object = WeatherPresets.SUNNY;
        public var targetState:Object   = WeatherPresets.SUNNY;
        
        public function Weather(){
            setVariables(WeatherPresets.SUNNY);
        }
        
        public function update():void{
            t += FlxG.elapsed;
            if (t - changed > 1/30){
                updateTween();
                changed = t;
            }
        }
        
        public function tweenTo(state:Object, d:Number=30):void{
            targetState = state;
            if (d == 0){
                setVariables(state)
                previousState = state;
            } else {
                tweenDuration = d;
                tweenStart    = t;
            }
        }
        
        public function updateTween():void{
            if (targetState === previousState) return;
            // Compute the tween factor
            progress = (t - tweenStart)/tweenDuration;
            if (tweenDuration == 0 || progress >= 1) {
                previousState = targetState;
                progress = 1;
            }
            setVariables(targetState, previousState, progress);
        }
        
        private function setVariables(target:Object, previous:Object=null, f:Number = 1):void{
            // Very ugly
            if (!target.hasOwnProperty('ambientAmount')){
                target['ambientAmount'] = ((target['ambient'] >> 24) / 0xFF);
            }

            if (previous === null){
                previous = target;
            }

            var fi:Number = 1 - f;
            // Loop through the variables and tween them
            for (var v:String in target){
                // List non-color props here.
                if (v == 'darkness' || v == 'contrast' || v == 'saturation' || v == 'fog' || v == 'rain' || v == 'wind' || v == 'ambientAmount'){
                    this[v] = (fi * previous[v]) + (f * target[v]);
                // timeOfDay is weird and circular.
                } else if (v == 'timeOfDay'){
                    if (target[v] > previous[v])
                        this[v] = (previous[v] + (target[v]-previous[v])*f)%1;
                    else
                        this[v] = (previous[v] + (target[v]+1-previous[v])*f)%1;
                } else {
                    // Interpolate a color.
                    this[v] = Utils.interpolateColor(previous[v], target[v], f);
                }
            }
            // Set the other vars
            ambientTransform.reset();

            ambientTransform.colorize(ambient, ambientAmount);
            ambientTransform.adjustContrast(contrast);
            ambientTransform.adjustSaturation(saturation);
            // Set opacity of the darknessColor to darkness.
            darknessColor = (darknessColor&0x00FFFFFF) | (uint(0xFF*darkness) << 24) ;
        }
        
    }
}
