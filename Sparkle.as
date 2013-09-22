package
{
    import flash.geom.Point;
    
    import org.flixel.FlxParticle;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class Sparkle extends FlxParticle{
        
        [Embed(source='/assets/gfx/sparkle.png')]     private var Img:Class;
        
        public function Sparkle(){
            super();
            loadGraphic(Img,true);
            addAnimation('splash',[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],30,false);
        }
        
        override public function reset(X:Number, Y:Number):void{
            super.reset(X,Y);
            lifespan = 1.0;
            play('splash', true);
        }
    }
}
