package
{
    import flash.geom.Point;
    
    import org.flixel.FlxParticle;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class Coin extends FlxParticle{
        
        [Embed(source='/assets/gfx/coin.png')]     private var Img:Class;
		
		public static const TOTAL_LIFESPAN:Number = 25;
		public static const OWNER_LIFESPAN:Number = 4;
		public var owner:FlxObject = null;
        public var justThrown:Boolean = false;
        public var called:Boolean = false;
        
        public function Coin(){
            super();
            
            loadGraphic(Img,true,false,10,10);
            maxVelocity.x  = 20;
            maxVelocity.y  = 275;
            acceleration.y = 900;
            addAnimation('spin',[0,1,2,3,4,5,6,7],10,true);
            play('spin');
            elasticity = 0.5;
        }
                
        public function drop(from:FlxSprite, owner:FlxObject=null):Coin{
            reset(from.x + from.width/2 - 5, from.y - 10);
            lifespan = TOTAL_LIFESPAN;
            velocity.x = FlxG.random()*60 - 30;
            velocity.y = -200;
            called = false;
		    this.owner = owner;
			if (owner != null && owner is Citizen){
				(owner as Citizen).pickNewGoal(this.x + this.width/2 + this.velocity.x)
			}
            return this;
        }
        
        override public function update():void{
            if (!called && lifespan <= TOTAL_LIFESPAN - OWNER_LIFESPAN / 2) {
                var cit:Citizen = owner as Citizen;    
                if (cit){
                    called = true;
                    justThrown = false;
                    flicker();
                    cit.pickNewGoal(x+width/2);
                }
            }
            if (owner != null && lifespan <= TOTAL_LIFESPAN - OWNER_LIFESPAN){
                flicker();
                owner = null;
            }
            super.update()
        }
    }
}
