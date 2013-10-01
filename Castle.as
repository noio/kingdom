package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxGroup;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Castle extends FlxSprite implements Buildable{
        
        [Embed(source='/assets/gfx/castle.png')] public var CastleImg:Class;
        
        public static const POST:int = 0;
        public static const PLATFORM:int = 1;
        public static const WATCHTOWER:int = 2;
        public static const STONETOWER:int = 3;
        public static const CASTLE:int = 4;
        
        public static const BUILD_COOLDOWN:Number = PlayState.CHEATS ? 1 : 15;
        public static const ARCHER_POSITIONS:Array = [[new FlxPoint(58-32,104-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12),new FlxPoint(60,46-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12),new FlxPoint(45,46-32-12),new FlxPoint(75,46-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12),
                                                       new FlxPoint(38,46-32-12),new FlxPoint(83,46-32-12),
                                                       new FlxPoint(27,64-32-12),new FlxPoint(93,64-32-12)]];
        public static const ARCHER_POSITION_INDEX:Array = [0,0,1,1,1,2,2,2,2,3,3,3,3,3,4]
        
        private var playstate:PlayState;
        
        private var light:Light;
        private var lights:FlxGroup;
        
        public var t:Number = 0;
        public var stage:int;
        public var archers:FlxGroup;
        public var archer_positions:Array = [];
        public var capacity:int = 0;
        public var baseY:Number;
        
        public function Castle(X:Number, Y:Number){
            super(X,Y);
            baseY            = Y+1;
            moves            = false;
            playstate        = (FlxG.state as PlayState)
            lights           = playstate.lights;
            archers          = playstate.archers;
            playstate.castle = this;
            
            loadGraphic(CastleImg, true, true, 128, 96);
            addAnimation("stages",[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],1);

            morph(POST);
            
            light            = new Campfire(x+width/2,y+height);
            lights.add(light);


        }
        
        public function morph(stage:int):void{
            archer_positions = ARCHER_POSITIONS[ARCHER_POSITION_INDEX[stage]].slice();
            for each (var archer:Citizen in archers.members){
                if (archer != null) {
                    archer.leaveGuard();
                }
            }
            frame = stage;
            // switch(stage){
            //     case POST:
            //         loadGraphic(Castle1Img);
            //         break;
            //     case PLATFORM:
            //         loadGraphic(Castle2Img);
            //         break;
            //     case WATCHTOWER:
            //         loadGraphic(Castle3Img);
            //         break;                    
            //     case STONETOWER:
            //         loadGraphic(Castle4Img);
            //         break;
            //     case CASTLE:
            //         loadGraphic(Castle5Img);
            //         break;                    
            // }
            this.stage = stage;
            height = 84;
            y = baseY + 96 - height;
            offset.y = 96 - height;
        }
        
        public function build():void{
            if (stage < ARCHER_POSITION_INDEX.length){
                t = 0;
                Utils.explode(this, playstate.gibs, 0.4);
                morph(stage + 1);
                flicker();
            }
            
        }
        
        public function canBuild():Boolean{
            return (t > BUILD_COOLDOWN && stage < 14);
        }
        
        override public function update():void{
            t += FlxG.elapsed;
            playstate.kingdomRight = Math.max(playstate.kingdomRight, x+width)
            playstate.kingdomLeft  = Math.min(playstate.kingdomLeft, x)
        }
    }
}
