package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Bunny extends FlxSprite{
        
        [Embed(source='/assets/gfx/bunny.png')]     private var Img:Class;
        
        public var DECAY_TIME:Number = 5;
        public var TURN_TIME:Number = 1;
        
        public var t:Number = 0;
        
        public function Bunny(X:int,Y:int){
            super(X,Y);
            loadGraphic(Img,true,true,16,16);
            offset.y = 4;
            height = 12;
            maxVelocity.y  = 100;
            maxVelocity.x = 30;
            drag.x = 1000;
            addAnimation('walk',[0,1,2,3,4,5,6,7,8,9,10],(10+FlxG.random()*5),true);
            addAnimation('stand',[0],10,true);
            addAnimation('dead',[11],10,true);
            y = (FlxG.state as PlayState).groundHeight - 12;
        }
        
        public function getShot(arrow:Arrow):void{
            play('dead');
            alive = false;
            velocity.x = 0;
            t = 0;
            ((FlxG.state as PlayState).coins.recycle(Coin) as Coin).drop(this, arrow.shooter);
        }
        
        override public function update():void {
            // Check for movement input
            acceleration.x = 0;
            t += FlxG.elapsed ;
            if (x+width > PlayState.GAME_WIDTH || x < 0){
                kill();
            }
            if (alive){
                if (t > TURN_TIME){
                    t = 0;
                    if (FlxG.random() < 0.4)
                        facing = (facing == LEFT) ? RIGHT : LEFT
                }
                if(facing == LEFT){
                    acceleration.x = -maxVelocity.x*4;
                    play('walk');
                } else {
                    acceleration.x = maxVelocity.x*4;
                    play('walk');
                }            
                super.update();
            } else {
                alpha = 1-(t/DECAY_TIME);
                if (t > DECAY_TIME){
                    kill();
                }
            }
        }
    }
}
