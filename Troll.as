package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxCamera;
    
    public class Troll extends FlxSprite{
        
        [Embed(source='/assets/gfx/troll.png')]     private var Img:Class;
        [Embed(source='/assets/gfx/trollbig.png')]     private var ImgBig:Class;
        
        public var t:Number = 0;
        public var goal:Number = 1600;
        public var hasCoin:Boolean = false;
        public var hasCrown:Boolean = false;
        public var wait:Boolean = false;
        public var retreating:Boolean = false;
        public var maxSpeed:Number = 20;
        public var jumpHeight:Number = 100;
        public var jumpiness:Number = 0.01;
        public var confusion:Number = 0.01;
        public var big:Boolean = false;
        public var safeDistance:Number = 200;
        private var maxHeightReached:Number = 0;
        private var jumpCooldown:Number = 0;
        private var confuseCooldown:Number = 0;
        
        private var playstate:PlayState;
        
        public function Troll(){
            super(0,0);
            maxVelocity.y  = 275;
            maxVelocity.x = 60;
            acceleration.y = 900;
            loadAnims();
            playstate = (FlxG.state as PlayState);
        }
        
        override public function reset(X:Number,Y:Number):void{
            retreating = false;
            hasCoin = false;
            wait = true;
            visible = false;
            if (! big == playstate.trollBig){
                big = playstate.trollBig;
                loadAnims();
            }
            super.reset(X - width / 2, Y);
            health = playstate.trollHealth;
			maxSpeed = playstate.trollMaxSpeed;
            jumpHeight = playstate.trollJumpHeight;
			jumpiness = playstate.trollJumpiness; 
            jumpCooldown = jumpiness + Math.random() * 2 * jumpiness;
            confusion = playstate.trollConfusion;
            confuseCooldown = confusion + Math.random() * 2 * confusion;
            t = 1;
        }

        private function loadAnims():void{
            if (big){
                // scale.x = scale.y = 2;
                loadGraphic(ImgBig,true,true,64,64);
                offset.x = 24;
                offset.y = 24;
                width = 16;
                height = 40;
                addAnimation('walk',[0,1,2,3,4,5,6,7,8], 7, true);
                addAnimation('walk_crown',[9,10,11,12,13,14,15,16,17], 7, true);
                addAnimation('stand',[0],10,true);
            } else {
                // scale.x = scale.y = 1;
                loadGraphic(Img,true,true,32,32);
                offset.x = 12;
                offset.y = 12;
                width = 8;
                height = 20;
                addAnimation('walk',[0,1,2,3,4,5,6,7,8],(10+FlxG.random()*5),true);
                addAnimation('walk_crown',[9,10,11,12,13,14,15,16,17],(10+FlxG.random()*5),true);
                addAnimation('walk_coin',[18,19,20,21,22,23,24,25,26],(10+FlxG.random()*5),true);
                addAnimation('stand',[0],10,true);
            }
        }
        
        public function getsCoin():void{
            hasCoin = true;
            retreat();
        }
        
        public function pickup(coin:FlxObject):void{
            if (!hasCoin && coin.alive && !retreating && !big){
                coin.kill();
                hasCoin = true;
                retreat();
            }
        }
        
        public function stealCrown():void{
            hasCrown = true;
            playstate.panTo(this, 20);
            retreat();
        }
        
        public function getShot():void{
            if (hasCrown) return;
            health --;
            if (health > 0) {
                // flicker();
            } else {
                Utils.explode(this, playstate.gibs, 1.0);
                if (hasCoin) {
                    (playstate.coins.recycle(Coin) as Coin).drop(this);
                }    
                kill();
            }
        }
        
        public function retreat():void{
            retreating = true;
            goal = (x < FlxG.worldBounds.width/2) ? 0 : FlxG.worldBounds.width;
            wait = false;
        }

        public function go():void{
            wait = false;
            visible = true;
        }
        
        override public function update():void {
            if (wait){
                velocity.x = 0;
                return;
            }
            confuseCooldown -= FlxG.elapsed;
            jumpCooldown -= FlxG.elapsed;
            // Check for movement input
            acceleration.x = 0;
            t += FlxG.elapsed;
            if (!hasCoin && t > 1.8){
                if (retreating || confuseCooldown < 0){
                    goal = (x < FlxG.worldBounds.width/2) ? 0 : FlxG.worldBounds.width;
                    confuseCooldown = confusion + Math.random() * 2 * confusion;
                } else {
                    goal = playstate.player.x;
                }
                t = 0
            } 
                
            // I don't know why I need this, but apparently trolls can fall of the world.
            if (x <= 24 || x + width >= FlxG.worldBounds.width - 24){
                if (retreating) kill();
            }
            if (y > 200){
                // throw new Error("TROLL FELL OFF :(");
                FlxG.log("TROLL FELL")
                kill();
            }
            
            facing = (goal > x) ? RIGHT : LEFT;
            
            if(touching & FLOOR){
                maxVelocity.x = maxSpeed;
                // Sprint outside of kingdom.
                if (x > playstate.kingdomRight + safeDistance || x < playstate.kingdomLeft - safeDistance){
                    maxVelocity.x += 40;
                }
                drag.x = maxVelocity.x*10;
                if(facing == LEFT){
                    acceleration.x = -maxVelocity.x*4;
                } else {
                    acceleration.x = maxVelocity.x*4;
                }
                if (hasCrown)
                    play('walk_crown');
                else if (hasCoin)
                    play('walk_coin');
                else
                    play('walk')
                // Jump
                if(jumpCooldown < 0){
                    maxHeightReached = 0;
                    var v:Number = Math.sqrt(jumpHeight * 2 * acceleration.y)
                    velocity.y = -v;
                    maxVelocity.x = maxSpeed * 2;
                    velocity.x *= 2
                    jumpCooldown = jumpiness + Math.random() * 2 * jumpiness;
                }
            } else {
                maxHeightReached = Math.max(112 - y, maxHeightReached)
                drag.x = maxVelocity.x*0.1;
                maxVelocity.x = maxSpeed * 2;
                if(facing == LEFT)
                    acceleration.x = -maxVelocity.x;
                else
                    acceleration.x = maxVelocity.x;
            }
                        
            super.update();
        }
    }
}
