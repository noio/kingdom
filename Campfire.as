package{

    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class Campfire extends Light{
        
        [Embed(source='/assets/gfx/campfire.png')] private var CampfireImg:Class;

        [Embed(source='/assets/gfx/light_large.png')] private var LightLargeImg:Class;
        [Embed(source='/assets/gfx/light_reflect_wide.png')] private var LightReflectWideImg:Class;
        
        public function Campfire(X:Number, Y:Number){    
            Y -= 12;
            
            super(X,Y);
            
            offset.x = 16;
            offset.y = 52;
            loadGraphic(CampfireImg, true, false, 32, 64);
            beam.loadGraphic(LightLargeImg);
            reflected.loadGraphic(LightReflectWideImg);
            reflected.color = 0xFFfc8f53;
            addAnimation('on', [0,1,2,3,4,5,6,7], 10, true);
            addAnimationCallback(this.dim);
            play('on');
            setLight()
        }
    }
}