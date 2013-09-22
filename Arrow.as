package
{
    import flash.geom.Point;
    
    import org.flixel.FlxParticle;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class Arrow extends FlxParticle{
        
        [Embed(source='/assets/gfx/arrow.png')]     private var Img:Class;
        
		public var shooter:Citizen = null;
		
        public function Arrow(){
            super();
            loadRotatedGraphic(Img);
            maxVelocity.x  = 200;
            maxVelocity.y  = 275;
            acceleration.y = 500;
            offset.x = 3;
            offset.y = 3;
            height = 2;
            width = 2;
            elasticity = 0.5;
        }
        
        public function shotFrom(from:Citizen, at:FlxObject):void{
            x = from.x + from.width/2 + (from.facing == RIGHT ? 6 : -6);
            y = from.y + 10;
            revive();
            velocity.x = (from.facing == RIGHT ? maxVelocity.x : -maxVelocity.x);
            velocity.y = - Math.abs(at.x - from.x) + FlxG.random()*40;
            lifespan = 10;
			shooter = from;
        }
        
        override public function update():void{
            if (y > (FlxG.state as PlayState).water.y){
                kill();
                var s:Splash = (FlxG.state as PlayState).fx.recycle(Splash) as Splash;
                s.reset(x,y);
            }
            angle = (180/Math.PI) * Math.atan2(velocity.y, velocity.x);
        }
        
    }
}
