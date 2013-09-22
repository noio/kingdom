package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxGroup;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Castle extends FlxSprite implements Buildable{
        
        [Embed(source='/assets/gfx/castle_1_post.png')] public var Castle1Img:Class;
        [Embed(source='/assets/gfx/castle_2_platform.png')] public var Castle2Img:Class;
        [Embed(source='/assets/gfx/castle_3_watchtower.png')] public var Castle3Img:Class;
        [Embed(source='/assets/gfx/castle_4_stonetower.png')] public var Castle4Img:Class;
        [Embed(source='/assets/gfx/castle_5_castle.png')] public var Castle5Img:Class;
        
        
        public static const POST:int = 0;
        public static const PLATFORM:int = 1;
        public static const WATCHTOWER:int = 2;
        public static const STONETOWER:int = 3;
        public static const CASTLE:int = 4;
        
        public static const BUILD_COOLDOWN:Number = 10;
        public static const ARCHER_POSITIONS:Array = [[new FlxPoint(58-32,104-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12),new FlxPoint(60,46-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12),new FlxPoint(45,46-32-12),new FlxPoint(75,46-32-12)],
                                                      [new FlxPoint(48-32,91-32-12),new FlxPoint(136-32,91-32-12),
                                                       new FlxPoint(38,46-32-12),new FlxPoint(83,46-32-12),
                                                       new FlxPoint(27,64-32-12),new FlxPoint(93,64-32-12)]];
        
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
            morph(POST);
            
            light            = new Campfire(x+width/2,y+height);
            lights.add(light);
        }
        
        public function morph(stage:int):void{
            archer_positions = ARCHER_POSITIONS[stage].slice();
            for each (var archer:Citizen in archers.members){
                if (archer != null) {
                    archer.leaveGuard();
                }
            }
            switch(stage){
                case POST:
                    loadGraphic(Castle1Img);
                    break;
                case PLATFORM:
                    loadGraphic(Castle2Img);
                    break;
                case WATCHTOWER:
                    loadGraphic(Castle3Img);
                    break;                    
                case STONETOWER:
                    loadGraphic(Castle4Img);
                    break;
                case CASTLE:
                    loadGraphic(Castle5Img);
                    break;                    
            }
            this.stage = stage;
            height = 84;
            y = baseY + 96 - height;
            offset.y = 96 - height;
        }
        
        public function build():void{
            if (stage < 4){
                t = 0;
                Utils.explode(this, playstate.gibs, 0.4);
                morph(stage + 1);
                flicker();
            }
            
        }
        
        public function canBuild():Boolean{
            return (t > BUILD_COOLDOWN && stage < 4);
        }
        
        override public function update():void{
            t += FlxG.elapsed;
            playstate.kingdomRight = Math.max(playstate.kingdomRight, x+width)
            playstate.kingdomLeft  = Math.min(playstate.kingdomLeft, x)
        }
    }
}
