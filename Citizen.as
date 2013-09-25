package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxGroup;
    import org.flixel.FlxSound;
    
    public class Citizen extends FlxSprite{
        
        [Embed(source='/assets/gfx/beggar.png')]    private var BeggarImg:Class;
        [Embed(source='/assets/gfx/citizen.png')]   private var PoorImg:Class;
        [Embed(source='/assets/gfx/hunter.png')]    private var HunterImg:Class;
        [Embed(source='/assets/gfx/farmer.png')]    private var FarmerImg:Class;
        
        [Embed(source="/assets/sound/shoot.mp3")] private var ShootSound:Class;
        [Embed(source="/assets/sound/powerup.mp3")] private var PowerupSound:Class;
        [Embed(source="/assets/sound/hitcitizen.mp3")] private var HitSound:Class;

        
        public static const BASE_COLOR:uint = 0xFF628685;
        public static const BASE_SHADE:uint = 0xFF455e5d;
        
        public static const BEGGAR:int = 0;
        public static const POOR:int   = 1;
        public static const FARMER:int = 2;
        public static const HUNTER:int = 3;
        
        // Behaviors
        public static const IDLE:int        = 0;
        public static const SHOOT:int       = 1;
        public static const JUST_SHOT:int   = 2;
        public static const SHOVEL:int      = 3;
		public static const GIVE:int        = 4;
		public static const JUST_HACKED:int = 5;
        
        
        // Behavior times
        public static const SHOOT_COOLDOWN_GUARD:Number = 1.4;
        public static const SHOOT_COOLDOWN:Number = 2.0;
        public static const HACK_COOLDOWN:Number = 4.0;        
        public static const SHOVEL_PERIOD:Number = 4.0;
        public static const SHOVEL_TIME:Number = 1.0;
        public static const SHOVEL_GOAL_DIST:Number = 600;
		public static const GIVE_COOLDOWN:Number = 10.0;
        
        // Variables
        public var occupation:int   = BEGGAR;
        public var action:int       = IDLE;
        public var guarding:Boolean = false;
        public var t:Number         = 0;
        public var goal:Number;
        public var myColor:uint;
        public var coins:int = 0;
		public var giveCooldown:Number = 0;
        public var shovelCooldown:Number = 0;
		public var target:FlxObject;
        public var guardLeftBorder:Boolean;
                
        public var playstate:PlayState;
        public var castle:Castle;
        
        public function Citizen(X:int,Y:int){
            super(X,Y);
            goal = FlxG.worldBounds.width/2;
            drag.x = 500;
            myColor = Utils.HSVtoRGB(FlxG.random()*360, 0.1+FlxG.random()*0.2, 0.6);
            playstate = FlxG.state as PlayState;
            castle = playstate.castle;
			addAnimationCallback(this.animationFrame);
            morph(BEGGAR);    
        }
        
        public function morph(occ:int):Citizen{
            action = IDLE;
            _animations = new Array();
            switch(occ){
                case BEGGAR:
                    if (occupation != BEGGAR)
                        playstate.beggars.add(playstate.characters.remove(this,true));
                    loadGraphic(BeggarImg,true,true,32,32);
                    addAnimation('walk',[0,1,2,3,4,5],5,true);
                    addAnimation('idle',[7,8,7,8,7,6],2,true);
                    maxVelocity.x = 15;
                    break;
                case POOR:
                    if (occupation == BEGGAR)
                        playstate.characters.add(playstate.beggars.remove(this,true));
                    loadGraphic(PoorImg,true,true,32,32,true);
                    Utils.replaceColor(pixels, BASE_COLOR, myColor);
                    Utils.replaceColor(pixels, BASE_SHADE, Utils.interpolateColor(myColor,0xFF000000,0.2));
                    drawFrame(true);
                    maxVelocity.x = 17;
                    addAnimation('walk',[0,1,2,3,4,5],10,true);
                    addAnimation('idle',[0,6,0,6,0,7],2,true);
                    break;
                case HUNTER:
                    guardLeftBorder = (FlxG.random() > 0.5);
                    loadGraphic(HunterImg,true,true,32,32,true);
                    Utils.replaceColor(pixels, BASE_COLOR, myColor);
                    Utils.replaceColor(pixels, BASE_SHADE, Utils.interpolateColor(myColor,0xFF000000,0.2));
                    drawFrame(true);
                    maxVelocity.x = 18;
                    addAnimation('walk',[0,1,2,3,4,5],10,true);
                    addAnimation('idle',[6,7,6,7,6,8],2,true);
                    addAnimation('shoot',[9,10,0],6,false);
					addAnimation('give',[11,12,13],15,false);
                    break;
                case FARMER:
                    loadGraphic(FarmerImg,true,true,32,32,true);
                    Utils.replaceColor(pixels, BASE_COLOR, myColor);
                    Utils.replaceColor(pixels, BASE_SHADE, Utils.interpolateColor(myColor,0xFF000000,0.2));
                    drawFrame(true);
                    maxVelocity.x = 15;
                    addAnimation('walk',[0,1,2,3,4,5],10,true);
                    addAnimation('idle',[6,7,6,7,6,8],2,true);
                    addAnimation('shovel',[8,9,10,9],6,true)
					addAnimation('give',[11,12,13],15,false);
					addAnimation('hack',[14],15,false);
                    break;
            }
            occupation = occ;
            offset.x = 12;
            offset.y = 8;
            width = 8;
            height = 24;
            pickNewGoal();
            return this;
        }
        
        public function pickup(coin:FlxObject):void{
            if (!coin.alive) return;
			var c:Coin = coin as Coin;
			// Return if the coin doesn't belong to me.
			if (c.owner != null && c.owner != this){
				return;
			}
            c.kill();
            // flicker();
            var s:Sparkle = (FlxG.state as PlayState).fx.recycle(Sparkle) as Sparkle;
            s.reset(x-4, y+8);
            if (occupation == BEGGAR) {
                playstate.recruitedCitizen = true;
                morph(POOR);
                FlxG.play(PowerupSound).proximity(x, y, playstate.player, FlxG.width * 0.75)
            }
            coins ++;
        }
		
		public function giveTaxes(p:Player):void{
			if (occupation == HUNTER || occupation == FARMER){
				if (action == IDLE && coins > 3 && giveCooldown <= 0){
					action = GIVE;
                    coins -= 2;
					play('give');
					p.changeCoins(1);
					giveCooldown = GIVE_COOLDOWN;
				}
			}
		}
        
        public function hitByTroll(troll:Troll):void{
            // Farmers can defend.
            if (occupation == FARMER && action != JUST_HACKED){
                action = JUST_HACKED;
                play("hack");
                t = 0;
                troll.getShot();
            } else if (coins > 0 && !troll.hasCoin){
                (playstate.coins.recycle(Coin) as Coin).drop(this, playstate.player);
                FlxG.play(HitSound).proximity(x, y, playstate.player, FlxG.width);
                coins = (coins > 1) ? 1 : 0;
                Utils.explode(this, playstate.gibs);
                if (coins == 0){
                    morph(BEGGAR);
                } else if (coins == 1){
                    morph(POOR);
                }
            }
        }
        
        public function checkShootable(group:FlxGroup):void{
            var c:FlxObject;
            for (var i:int = 0; i < group.length; i++){
                c = group.members[i];
                if (c != null && c.alive && c.exists && Math.abs(c.x - x) < 96){
                    FlxG.log("Shooting "+c+" at "+c.x+','+c.y);
                    play('shoot', true);
                    FlxG.play(ShootSound).proximity(x, y, playstate.player, FlxG.width);
					// walk 1 pixel towards goal, just to get
					// the facing right
                    goal = (c.x > x) ? x + 1 : x - 1;
                    facing = (goal > x) ? RIGHT : LEFT;
					target = c;
                    action = SHOOT;
                    t = 0;
                    break;
                }
            }
        }
        
        public function checkWork(group:FlxGroup):void{
            var c:FlxObject;
            for (var i:int = 0; i < group.length; i ++){
                c = group.members[i];
                if (c != null){
                    if (x > c.x && x+width < c.x+c.width){
                        if ((c as Workable).needsWork()){
                            (c as Workable).work(this);
                            play('shovel',true);
                            action = SHOVEL;
                            shovelCooldown = SHOVEL_PERIOD;
                            t = 0;
                        }
                    }
                }
            }
        }
        
        public function checkGuard():void{
            if (action == IDLE && castle.archer_positions.length > 0){
                if (Math.abs(castle.x-x) < 192) {
                    for (var i:int = 0; i < castle.archer_positions.length; i++){
                        var pos:FlxPoint = castle.archer_positions[i];
                        if(Math.abs(castle.x+pos.x-x) < 4){
                            x = castle.x + pos.x;
                            y = castle.y + pos.y;
                            guarding = true;
                            playstate.archers.add(playstate.characters.remove(this,true));
                            castle.archer_positions.splice(i,1);
                            break;
                        }
                    }
                }
            }
        }
        
        public function leaveGuard():void{
            castle.archer_positions.push(new FlxPoint(x,y));
            playstate.characters.add(playstate.archers.remove(this));
            action == IDLE;
            guarding = false;
        }
        
        public function pickNewGoal(preset:Number = NaN):void{
            //TODO !!! Hunters don't target well at night
            var a:Attention = playstate.fx.recycle(Attention) as Attention;
            a.appearAt(this);
            if (!isNaN(preset)){
                goal = preset;
                return
            }
            if (occupation == POOR){
                var shop:Shop = (playstate.shops.getRandom() as Shop);
                goal = shop.x + shop.width/2;
                return;
            }
			if (coins > 4){
				goal = playstate.player.x;
				return;
			}
            if (occupation == FARMER) {
                // Otherwise check for a wall to work on
                var needWork:Array = new Array();
                for (var i:int = 0; i < playstate.walls.length; i++){
                    var wall:Wall = playstate.walls.members[i] as Wall;
                    if (wall != null && wall.needsWork()){
                        needWork.push(wall);
                    }                    
                }
                if (needWork.length > 0){
                    var idx:int = FlxG.random() * needWork.length;
                    goal = needWork[idx].x + needWork[idx].width / 2;
                    return;    
                }
                
            }
            
            var l:int, r:int;
            
            if (occupation == HUNTER && (playstate.weather.timeOfDay >= 0.7 || playstate.weather.timeOfDay < 0.20)) {
                // Hunters gather around borders at night
                if (guardLeftBorder){
                    l = playstate.kingdomLeft;
                    r = playstate.kingdomLeft + 32;
                } else {
                    l = playstate.kingdomRight - 32;
                    r = playstate.kingdomRight;
                }
            } else if (occupation == BEGGAR){
                // Beggars gather outside borders
                if (x < PlayState.GAME_WIDTH/2){
                    l = playstate.kingdomLeft - 256;
                    r = playstate.kingdomLeft;
                } else {
                    l = playstate.kingdomRight;
                    r = playstate.kingdomRight + 256;
                }
            } else {
                // Move anywhere within the kingdom
                l = playstate.kingdomLeft;
                r = playstate.kingdomRight;
            }
            goal = int(FlxG.random()*(r-l) + l);
            /*FlxG.log("Citizen (" + occupation + ") picked goal " + goal)*/
        }
        
		
		public function animationFrame(animName:String, frameNum:uint, frameIndex:uint):void{
			if (animName == 'give' && frameNum == 2){
				action = IDLE;
				play('idle');
			}

            if (animName == 'shovel'){
                var d:Dust = playstate.fx.recycle(Dust) as Dust;
                d.reset(x + ((facing == RIGHT) ? 14 : -6), y + 19);
            }
		}

        
        override public function update():void {
            acceleration.x = 0;
            t += FlxG.elapsed;
            shovelCooldown -= FlxG.elapsed;
			giveCooldown -= FlxG.elapsed;

            // IDLE MOVING AROUND
            
            if(guarding && occupation == HUNTER){
                play('idle');
                facing = (goal > x) ? RIGHT : LEFT;
            } else if (action == IDLE){
                facing = (goal > x) ? RIGHT : LEFT;
                // Near Goal
                if (Math.abs(goal - x) < 2){
                    if (t > 2.0 && FlxG.random() < 0.3) {
                        t = 0;
                        pickNewGoal();
                    } else {
                        play('idle');
                    }
                // Far away from goal
                } else {
                    play('walk');
                    acceleration.x = (facing == RIGHT) ? maxVelocity.x*10 : -maxVelocity.x*10;
                    y = playstate.groundHeight - height;
                    
                }                
            }
            
            // Specific Behavior
            if (occupation == HUNTER){
                // Shooting cycle
                if (action == SHOOT && t > 0.16){
                    (playstate.arrows.recycle(Arrow) as Arrow).shotFrom(this, target);
                    t = 0;
                    action = JUST_SHOT;
                } else if (action == JUST_SHOT && t > (guarding ? SHOOT_COOLDOWN_GUARD : SHOOT_COOLDOWN)){
                    t = 0;
                    action = IDLE;
                } else if (action == IDLE){
                    checkShootable(playstate.trolls);
                    // Check for idle again since we could be shooting a Troll.
                    if (action == IDLE){
                        checkShootable(playstate.bunnies);
                    }                    
                }
                // Check if we need to take up a guard post.
                checkGuard();
            } else if (occupation == FARMER){
                if (action == JUST_HACKED && t > HACK_COOLDOWN ){
                    t = 0;
                    action = IDLE;
                }
                if (shovelCooldown <= 0 && action == IDLE) {
                    checkWork(playstate.walls);
                    checkWork(playstate.farmlands);
                } else if (action == SHOVEL && t > SHOVEL_TIME){
                    t = 0;
                    action = IDLE;
                }
            }
            
            
            super.update();
        }
        
        
    }
}
