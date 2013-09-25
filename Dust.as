package
{
    import flash.geom.Point;
    
    import org.flixel.FlxParticle;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class Dust extends FlxParticle{
        
        [Embed(source='/assets/gfx/dust.png')]     private var Img:Class;
        
        public function Dust(){
            super();
            loadGraphic(Img,true);
            addAnimation('fade',[0,1,2,3], 5, false);
            drag.x = drag.y = 20;
        }
        
        override public function reset(X:Number, Y:Number):void{
            super.reset(X,Y);
            x += (Math.random() < 0.5) ? 4 : -4;
            velocity.x = Math.random() * 40 - 20;
            velocity.y = - Math.random() * 20 - 4;
            lifespan = 1.0;
            play('fade', true);
        }
    }
}
