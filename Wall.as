package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Wall extends FlxSprite implements Workable, Buildable{
        
        [Embed(source='/assets/gfx/wall.png')]    private var WallImg:Class;
        
        [Embed(source="/assets/sound/hitwall.mp3")] private var HitwallSound:Class;
        
        public const HEIGHT:Array = [11,38,46,54,59]; // Effective Height: [26, 34, 42, 47]
        public const HEALTH:Array = [2,38,50,60,75];
        public const HURT_COOLDOWN:Number = 1;
        public const WORK_BUILD_HEIGHT:int = 10;
        public const WORK_HEAL_AMOUNT:int = 4;
        
        private var playstate:PlayState;
        public var scaffold:Scaffold = null;
        
        public var building:Boolean = false;
        public var heightToBuild:int = 0;
        public var baseY:Number;
        public var stage:int = 0;
        private var t:Number = 0;
        
        public function Wall(X:Number, Y:Number){
            baseY = Y;
            super(X,Y);
            immovable = true;
            moves = false;
            solid = false;
            loadGraphic(WallImg, true, true, 32, 64);
            addAnimation("grow",[0,1,2,3,4,5,6,7,8,9],1);
            if (X > 1920){
                facing = LEFT;
            }
            offset.x = 4;
            width = 24;
            health = HEALTH[stage];
            updateAppearance();
            playstate = FlxG.state as PlayState;
        }
        
        public function build():void{
            buildTo(stage + 1);
        }

        public function buildTo(s:int, instant:Boolean=false):void{
            if (!instant && s < stage) return;
            building = true;
            stage = s;
            heightToBuild = HEIGHT[stage];
            health = HEALTH[stage];
            updateAppearance();
            if (scaffold != null){
                scaffold.kill();
            }
            scaffold = (playstate.indicators.recycle(Scaffold) as Scaffold).build(this);
            scaffold.y = y - HEIGHT[stage];
            solid = false;
            // Kind of hacky this.
            if (instant){
                heightToBuild = 1;
                work(null);
            }
            flicker();
        }
        
        public function work(citizen:Citizen=null):void{
            if (heightToBuild > 0) {
                heightToBuild -= WORK_BUILD_HEIGHT;
                if (heightToBuild <= 0){
                    heightToBuild = 0;
                    building = false;
                    solid = true;
                    Utils.explode(scaffold, playstate.gibs, 1);
                    scaffold.kill();
                    scaffold = null;
                }
                updateAppearance();
            } else {
                if (health < HEALTH[stage]){
                    health += Math.min(WORK_HEAL_AMOUNT, HEALTH[stage] - health);
                }
            }
        }

        override public function hurt(Damage:Number):void{
            if (t > HURT_COOLDOWN){
                health -= Damage;
                FlxG.play(HitwallSound).proximity(x, y, playstate.player, FlxG.width)
                Utils.explode(this, playstate.gibs, 0.1);
                t = 0;
            }
            if (health <= 0 && stage > 0){
                Utils.explode(this, playstate.gibs, 1.0);
                stage = 0;
                health = HEALTH[stage];
            }
            updateAppearance();
        }
        
        public function needsWork():Boolean{
            return (building || health < HEALTH[stage]);
        }
        
        public function canBuild():Boolean{
            return (!building && stage < 4)
        }
        
        private function updateAppearance():void{
            height = HEIGHT[stage] - heightToBuild;
            y = baseY + 64 - height;
            offset.y = 64 - HEIGHT[stage];
            if (health < HEALTH[stage] / 2){
                frame = stage + 5;
            } else {
                frame = stage;
            }
        }
        
        override public function update():void{
            t += FlxG.elapsed;
            if (this.stage > 0 && !building){
                if (this.x > PlayState.GAME_WIDTH/2){
                    playstate.kingdomRight = Math.max(playstate.kingdomRight, x)
                } else {
                    playstate.kingdomLeft = Math.min(playstate.kingdomLeft, x+width)
                }
            }
        }
    }
}