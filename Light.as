package{

    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class Light extends FlxSprite{
        

        [Embed(source='/assets/gfx/campfire.png')] private var CampfireImg:Class;
        [Embed(source='/assets/gfx/torch.png')] private var TorchImg:Class;

        [Embed(source='/assets/gfx/light_mid.png')] private var LightMidImg:Class;
        [Embed(source='/assets/gfx/light_large.png')] private var LightLargeImg:Class;
        [Embed(source='/assets/gfx/light_reflect_small.png')] private var LightReflectSmallImg:Class;
        [Embed(source='/assets/gfx/light_reflect_wide.png')] private var LightReflectWideImg:Class;
        
                
        public var beam:FlxSprite = new FlxSprite();
        public var reflected:FlxSprite = new FlxSprite();
        public var darkness:FlxSprite;
        
        public var burning:Boolean;
        
        public var playstate:PlayState;
        public var weather:Weather;
        
        public function Light(X:Number, Y:Number){
            super(X,Y);
            this.playstate = FlxG.state as PlayState
            this.darkness  = this.playstate.darkness;
            this.weather   = this.playstate.weather;
        }
        
        /* Performs some additional settings that can only be done
         * after the extending class' constructor is done.
         */
        public function setLight():void{
            beam.blend = 'screen';
        }
        
        override public function update():void{
            getScreenXY(_point)
            burning = (-128 < _point.x && _point.x < FlxG.width + 128);
        }
        
        override public function draw():void{
            if(burning){
                getScreenXY(_point);
                darkness.stamp(beam, Math.floor(_point.x - beam.width/2), Math.floor(_point.y - beam.height/2)); 
            }
            super.draw();
        }
        
        public function dim(animName:String,frameNumber:uint,frameIndex:uint):void{
            if (burning){
                beam.alpha += FlxG.random()*0.15 - 0.075;
                if (beam.alpha < 0.3){
                    beam.alpha += 0.01;
                }
                beam.drawFrame(true);
            }
        }
    }
}
