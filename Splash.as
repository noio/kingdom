package
{
    import flash.geom.Point;
    
    import org.flixel.FlxParticle;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class Splash extends FlxParticle{
        
        [Embed(source='/assets/gfx/splash.png')]     private var Img:Class;
        
        public function Splash(){
            super();
            loadGraphic(Img,true);
            addAnimation('splash',[0,1,2,3,4],10);
            
        }
        
        override public function reset(X:Number, Y:Number):void{
            super.reset(X,Y);
            lifespan = 0.5;
            play('splash');
        }
    }
}
