package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxCamera;
    import org.flixel.FlxGroup;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSound;

    
    public class Player extends FlxSprite{
        
        [Embed(source='/assets/gfx/king.png')]     private var PlayerImg:Class;

        [Embed(source="/assets/sound/pickup.mp3")] public static const PickupSound:Class;
        [Embed(source="/assets/sound/build.mp3")] private var BuildSound:Class;
        [Embed(source="/assets/sound/throw.mp3")] private var ThrowSound:Class;
        [Embed(source="/assets/sound/stolen.mp3")] private var StolenSound:Class;

        public static var pickupSound:FlxSound = FlxG.loadSound(PickupSound);
        
        public static const BASE_SKIN:uint = 0xFFedbebf;
        public static const BASE_DARK:uint = 0xFFbd9898;
        public static const BASE_EYES:uint = 0xFFa18383;

        public static const MAX_SPEED:Number = 80;
        public static const MIN_SPEED:Number = 25;
        public static const MAX_FOOD_BONUS:Number = 50;
        public static const MAX_FOOD:Number = 100;
        public static const HIT_RATE:Number = 0.2;
        public static const SELECT_DISTANCE:Number = 10;
        
        private var playstate:PlayState;

        private var selectedBuilding:FlxSprite = null;
        private var floatCoin:CoinFloat = null;
        private var lastMoved:Number = 0;
        public var food:Number = 100;
        
        public var hasCrown:Boolean = true;
        public var lastTrollHit:Number = 0;
        public var coins:int = 7;
        
        public function Player(X:int,Y:int){
            super(X,Y);
            y = 100 // 132 (land height) - 32 (player height)
            
            loadGraphic(PlayerImg,true,true,64,64);
            width = 20;
            height = 32;
            offset.x = 22;
            offset.y = 32;
            
            maxVelocity.x = MAX_SPEED;
            drag.x = maxVelocity.x*5;
            
            playstate = (FlxG.state as PlayState);



            addAnimation('walk_slow',[0,1,2,3,4,5,6,7],10,true);
            addAnimation('walk_fast',[0,1,2,3,4,5,6,7],15,true);
            addAnimation('stand',[8],10,true);
            addAnimation('eat',[9,10],5,true);
            addAnimation('nocrown',[11],10,true);
            play('stand');
            playstate.player = this;
            
            var d:Number = Math.random() * 20;
            var skin:uint = Utils.HSVtoRGB(d, 0.19 + (d / 100), 0.97 - (d / 33));
            Utils.replaceColor(pixels, BASE_SKIN, skin);
            Utils.replaceColor(pixels, BASE_DARK, Utils.interpolateColor(skin,0xFF000000,0.2));
            Utils.replaceColor(pixels, BASE_EYES, Utils.interpolateColor(skin,0xFF000000,0.5));
        }
		
        public function changeCoins(amt:int):void{
            if (amt > 0) {
                pickupSound.play(false);
                pickupSound.proximity(x, y, this, FlxG.width);
            }
			coins += amt;
			playstate.showCoins();
		}

        public function hitByTroll(troll:Troll):void{
            if (troll.hasCoin) return;

            if (lastTrollHit < HIT_RATE) return;
            lastTrollHit = 0;
            
            // If the player has coins, lose one and return.
            if (coins > 0){
                var c:Coin = (playstate.coins.recycle(Coin) as Coin);
                c.drop(this, null);
                c.justThrown = true;
                FlxG.play(StolenSound).proximity(x, y, this, FlxG.width);
                changeCoins(-1);
                FlxG.shake();
                return;
            }

            if (hasCrown){
                FlxG.flash(0xFFFFFFFF, 0.1);
                troll.stealCrown();
                lostCrown(troll);
                playstate.crownStolen();
            }
        }
		
        public function lostCrown(troll:FlxObject):void{
            hasCrown = false;
            facing = troll.x > x ? RIGHT : LEFT;
            play('nocrown');
            FlxG.play(StolenSound).proximity(x, y, this, FlxG.width);
            Utils.explode(this, playstate.gibs);
        }
        
        public function pickup(coin:FlxObject):void{
            if (!coin.alive) return;
			var c:Coin = coin as Coin;
			// Return if the coin doesn't belong to me.
			if (c.justThrown){
				return;
			}
            c.kill();
            changeCoins(1);
        }
        
        override public function update():void {
            
            lastTrollHit += FlxG.elapsed;
            
            // Check for movement input
            acceleration.x = 0;
            if (!hasCrown){
                return;
            }
            if(FlxG.keys.LEFT || FlxG.keys.RIGHT){
                lastMoved = 0;
                if (food > 0){
                    food -= FlxG.elapsed;
                }
                maxVelocity.x = MIN_SPEED + Math.min(1,food/MAX_FOOD_BONUS) * (MAX_SPEED-MIN_SPEED);
                if (!playstate.horseAdvice && food < 10){
                    playstate.horseAdvice = true;
                    playstate.showText("Horse is tired. Let him rest on the grass.")
                }
            }
            if(FlxG.keys.LEFT){
                acceleration.x = -maxVelocity.x*4;
                facing = LEFT;
                if (maxVelocity.x > MIN_SPEED + 15){
                    play('walk_fast');
                } else {
                    play('walk_slow');
                }
            } else if(FlxG.keys.RIGHT){
                acceleration.x = maxVelocity.x*4;
                facing = RIGHT;
                if (maxVelocity.x > MIN_SPEED + 15){
                    play('walk_fast');
                } else {
                    play('walk_slow');
                }
            } else {
                lastMoved += FlxG.elapsed;
                if (lastMoved > 1 && food < MAX_FOOD){
                    // Check if on grass
                    var headPos:Number = (x+width/2) + (facing == RIGHT ? 25: -25)
                    var onTile:int = playstate.floor.getTile(headPos/32,4)
                    if ((onTile >= 7 && onTile <= 11) || (onTile >= 17 && onTile <= 18)){
                        play('eat',false);
                        food += FlxG.elapsed*10;
                    } else {
                        play('stand');
                    }
                } else {
                    play('stand');
                }
            }
            if (FlxG.keys.SHIFT && PlayState.CHEATS) {
                velocity.x *= 10
            }
            
            if (FlxG.keys.justPressed("DOWN")){
                if (coins <= 0){
                    playstate.showCoins();
                } else {
                    if (selectedBuilding != null){
                        changeCoins(-1);
                        giveCoin(selectedBuilding);
                    } else {
                        var cit:Citizen;
                        var closestCitizen:Citizen = null;
                        var closest:Number = 1000000;
                        for (var i:int = 0; i < playstate.beggars.length; i++){
                            cit = (playstate.beggars.members[i] as Citizen)
                            if (Math.abs((cit.x + cit.width/2) - (x + width/2)) < closest){
                                closestCitizen = cit;
                                closest = Math.abs((cit.x + cit.width/2) - (x + width/2));
                            } 
                        }
                        if (playstate.recruitedCitizen || closest < 64){
                            var c:Coin = (playstate.coins.recycle(Coin) as Coin);
                            c.drop(this, closestCitizen);
                            c.justThrown = true;
                            FlxG.play(ThrowSound).proximity(x, y, this, FlxG.width);
                            changeCoins(-1);
                        }
                    }
                }
            }
            super.update();
            
            //Find selected shop/wall
            if (selectedBuilding != null){
                if (Math.abs((selectedBuilding.x + selectedBuilding.width/2) - (x + width/2)) > SELECT_DISTANCE * 2){
                    deselect(selectedBuilding);
                }
            } else if (playstate.recruitedCitizen) {
                checkSelectable(playstate.objects)
                checkSelectable(playstate.shops);
                checkSelectable(playstate.walls);
            }
        }
        
        private function checkSelectable(group:FlxGroup):void{
            for (var i:int = 0; i < group.length; i ++){
                var b:FlxSprite = group.members[i];
                if (b != null && Math.abs((b.x + b.width/2) - (x + width/2)) <= SELECT_DISTANCE){
                    if ((b as Buildable).canBuild())
                        select(b);
                }
            }
        }
        
        private function select(building:FlxSprite):void{
            selectedBuilding = building;
            if (floatCoin == null){
                playstate.add(floatCoin = new CoinFloat());
            }
            floatCoin.visible = true;
            floatCoin.float(selectedBuilding);
        }
        
        private function deselect(building:FlxSprite):void{
            selectedBuilding = null;
            floatCoin.visible = false;
        }
        
        private function giveCoin(building:FlxSprite):void{
            Buildable(building).build();
            FlxG.play(BuildSound).proximity(x, y, this, FlxG.width);
            deselect(building);
        }
    }
}
