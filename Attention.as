package
{
    import flash.geom.Point;
    
    import org.flixel.FlxParticle;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class Attention extends FlxParticle{
        
        [Embed(source='/assets/gfx/attention.png')]     private var Img:Class;
        
        public var citizen:Citizen;
		
        public function Attention(){
            super();
            loadGraphic(Img);
            maxVelocity.x  = 0;
            maxVelocity.y  = 0;
            height = 8;
            width = 8;
            alpha = 0.5;
        }
        
        public function appearAt(at:Citizen):void{
            citizen = at;
            y = at.y - 4;
            revive();
            lifespan = 1;
        }
        
        override public function update():void{
            x = citizen.x + citizen.width/2 - 4;
            super.update()
        }
    }
}
