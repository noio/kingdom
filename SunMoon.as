package{
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class SunMoon extends Light{
        
        [Embed(source='/assets/gfx/sunmoon.png')] public var Img:Class;
        [Embed(source='/assets/gfx/light_mid.png')] private var LightMidImg:Class;
        [Embed(source='/assets/gfx/light_reflect_wide.png')] private var LightReflectWideImg:Class;
        
		public static const ZENITH:Number = 20 // Highest point
		public static const HORIZON:Number = 100 // Sun "extinguishes" below horizon
		
        private var weatherChanged:Number = 0;
        
        public function SunMoon(weather:Weather):void{
            super(0,0);
            
            offset.x = offset.y = 16;
            
            scrollFactor.x = scrollFactor.y = 0.0;
            loadGraphic(Img,true);
            
            beam.loadGraphic(LightMidImg);
            reflected.loadGraphic(LightReflectWideImg);
            reflected.color = 0xFFfc8f53;
            
            beam.blend = 'screen';
        }
        
        override public function update():void{
			/** 
			* the timeOfDay works as follows:
			* 0 and 1 are night. 0.5 is mid-day. 
			*/
            if (weather.changed > weatherChanged) {
                var progressX:Number = (weather.timeOfDay*2+0.5)%1;
                var progressY:Number = Math.sin(Math.PI*progressX)
                x = width + (FlxG.width - 2*width) * progressX;
                y = HORIZON - progressY*(HORIZON-ZENITH);
                color = weather.sunTint;
                beam.alpha = progressY * 2;
                frame = (weather.timeOfDay > 0.25 && weather.timeOfDay < 0.75) ? 0 : 1;
                dirty = true;
                beam.drawFrame(true);
                weatherChanged = weather.t;
            }
            super.update();
        }
        
        
    }
}