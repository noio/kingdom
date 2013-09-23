package
{
    import org.flixel.*;
    import flash.geom.*;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import flash.filters.BlurFilter;
    
    public class PlayState extends FlxState
    {
        // Forcing flash to do some imports (weird)
        Reed;Castle;Treeline;Farmland;Wall;Torch;Shop;Firefly;
        
		[Embed(source="assets/aurora.ttf",fontName="Aurora",embedAsCFF="false")] protected var font:String;
		
        [Embed(source='/assets/levels/compiled/fields.oel', mimeType="application/octet-stream")] private const LevelCity:Class;
        // Graphics
        [Embed(source='/assets/gfx/tiles.png')] private const TilesImg:Class;
        [Embed(source='/assets/gfx/skyline_hills.png')]  private const SkylineHillsImg:Class;
        [Embed(source='/assets/gfx/skyline_trees.png')]  private const SkylineTreesImg:Class;
        [Embed(source='/assets/gfx/hill.png')] public const HillImg:Class;
        // Sounds
        [Embed(source="/assets/sound/hit.mp3")] private var HitSound:Class;
        [Embed(source="/assets/sound/hitbig.mp3")] private var HitbigSound:Class;
        // Env sounds
        [Embed(source="/assets/sound/cicada.mp3")] private var CicadaSound:Class;
        [Embed(source="/assets/sound/owls.mp3")] private var OwlsSound:Class;
        [Embed(source="/assets/sound/birds.mp3")] private var BirdsSound:Class;
        
        //Music
        [Embed(source="/assets/music/night1.mp3")] private var MusicNight1:Class;
        [Embed(source="/assets/music/night2.mp3")] private var MusicNight2:Class;
        [Embed(source="/assets/music/night3.mp3")] private var MusicNight3:Class;
        [Embed(source="/assets/music/night4.mp3")] private var MusicNight4:Class;
        [Embed(source="/assets/music/night5.mp3")] private var MusicNight5:Class;        
        [Embed(source="/assets/music/day1.mp3")] private var MusicDay1:Class;
        [Embed(source="/assets/music/day2.mp3")] private var MusicDay2:Class;
        [Embed(source="/assets/music/day3.mp3")] private var MusicDay3:Class;
        [Embed(source="/assets/music/day4.mp3")] private var MusicDay4:Class;
        [Embed(source="/assets/music/day5.mp3")] private var MusicDay5:Class;        

        
        // DISPLAY GROUPS
        public var sky:Sky;
        public var sunmoon:SunMoon;
        public var backdropFar:FlxBackdrop;
        public var backdropClose:FlxBackdrop;
        public var backdrop:FlxGroup;
        public var haze:Haze;
        
        public var player:FlxSprite;
        public var bunnies:FlxGroup;
        public var farmland:FlxGroup;
        public var coins:FlxGroup;
        public var beggars:FlxGroup;
        public var characters:FlxGroup;
        public var trolls:FlxGroup;
        public var gibs:FlxGroup;
        public var indicators:FlxGroup;
        
        public var walls:FlxGroup;
        public var level:FlxGroup;
        public var archers:FlxGroup;
        public var objects:FlxGroup;
        public var shops:FlxGroup;
        public var floor:FlxTilemap;
        public var farmlands:FlxGroup;
        public var props:FlxGroup;        
        public var lights:FlxGroup;
        public var darkness:FlxSprite;
        public var water:Water;
        public var arrows:FlxGroup;
        public var fx:FlxGroup;
        public var fog:Fog;
        public var text:FlxText;
        public var sack:Coinsack;
        public var noise:FlxSprite;
        
        public var weather:Weather;
        
        // Extra references
        public var castle:Castle;
        public var minimap:Minimap;
        
        public var weatherInput:FlxInputText;
        
        
        //CONSTANTS
        public static const CHEATS:Boolean = true;
        public static const WEATHERCONTROLS:Boolean = true;
        
        public static const GAME_WIDTH:int = 3840;
        public static const MIN_KINGDOM_WIDTH:int = 200;
        
        public static const MAX_BUNNIES:int = 50;
        public static const MIN_BUNNY_SPAWNTIME:Number = 6.0;
        
        public static const MIN_TROLL_SPAWNTIME:Number = 0.5;
		
		public static const TEXT_MAX_ALPHA:Number = 0.7;
		public static const TEXT_READ_SPEED:Number = 0.20;

        // Game vars
        public var kingdomLeft:Number = 1920-200;
        public var kingdomRight:Number = 1920+200;
        public var groundHeight:int = 132;
        public var phase:int = 0;
        public var phasesPaused:Boolean = false;
        public var timeToNextPhase:Number = 0;
        public var bunnySpawnTimer:Number = 0.0;
        public var trollSpawnTimer:Number = 0.0;
        public var trollsToSpawn:Array = [];
        public var minBeggars:int = 0;
        public var retreatDelay:Number = 0;
        public var gameover:Boolean = false;
        public var dayNumber:int = 0;
        
        public var trollHealth:Number = 1;
        public var trollMaxSpeed:Number = 20;
        public var trollJumpHeight:Number = 100;
        public var trollJumpiness:Number = 0.001;
        public var trollConfusion:Number = 0.001;
        public var trollBig:Boolean = false;
        
        public var grassTiles:Array;
        
        // Progress variables
        public var reachedVillage:Boolean        = false;
        public var recruitedCitizen:Boolean      = false;
        public var boughtItem:Boolean            = false;
        public var boughtItemAdvice:Boolean      = false;
        public var expandedKingdom:Boolean       = false;
        public var expandedKingdomAdvice:Boolean = false;
        
        // Internals
		public var textTimeout:Number = 0;
		public var textQueue:Array = [];
        public var cameraTarget:CameraTarget;
        public var cameraTimeout:Number = 0;
        
        public var music:FlxSound = null;
        public var cicada:FlxSound = null;
        public var owls:FlxSound = null;
        public var birds:FlxSound = null;
        
        // Cheatvars
        private var cheatNoTrolls:Boolean = false;
        
        //=== INITIALIZATION ==//
        override public function create():void
        {
            trace("CREATED")
            FlxG.camera.bgColor = 0xFFafb4c2;
            FlxG.camera.bounds = new FlxRect(0,0,GAME_WIDTH,196)
            FlxG.worldBounds.width = GAME_WIDTH;
            FlxG.worldBounds.height = 300;
            /*FlxG.framerate = 30;*/
            buildLevel(LevelCity);
            weather.tweenTo(WeatherPresets.FOGGY, 0);
            
            add(minimap = new Minimap(0, FlxG.height - 1 ,FlxG.width, 1));
            minimap.add(trolls, 0xFF87B587);
            minimap.add(player, 0xff765DB3);
            minimap.add(beggars, 0xFF7D6841);
            minimap.add(characters, 0xFFA281F8);
            minimap.add(walls, 0xFF969696);
            
            showCoins();

            // Load up environment sounds
            cicada = FlxG.play(CicadaSound, 0.0, true);
            owls = FlxG.play(OwlsSound, 0.0, true);
            birds = FlxG.play(BirdsSound, 0.0, true);
            
            // Camera
            add(cameraTarget = new CameraTarget());
            cameraTarget.target = player;
            cameraTarget.offset.y = -4;
            cameraTarget.snap();
            FlxG.camera.follow(cameraTarget,FlxCamera.STYLE_LOCKON);
            
            // Set up some debugging
            FlxG.watch(this, 'timeToNextPhase');
            FlxG.watch(weather, 'timeOfDay');
            FlxG.watch(weather, 'progress');
            FlxG.watch(weather, 'ambient');
            FlxG.watch(weather, 'ambientAmount');
            FlxG.watch(this, 'phase');
            
            // Set up weathercontrols
            if (WEATHERCONTROLS){
                weatherInput = new FlxInputText(10, 10, 400, 32, '',0, null, 16);
                weatherInput.scrollFactor.x = weatherInput.scrollFactor.y = 0;
                add(weatherInput);
                // var setWeatherButton:FlxButton = new FlxButton(10,30,"SET", setWeatherFromInput);
                // setWeatherButton.scrollFactor.x = setWeatherButton.scrollFactor.y = 0;
                // add(setWeatherButton);
                FlxG.mouse.show()
            }
        }
        
        public function setWeatherFromInput():void{
            var txt:String = weatherInput.textField.text;
            weatherInput.textField.text = '';
            var object:Object = JSON.parse(txt)
            FlxG.stage.focus = weatherInput.textField;
            var w:Object = {'sky':0,'horizon':0,'haze':0,'darknessColor':0,'darkness':0,
                            'contrast':-0,'saturation':0,'ambient':0,'wind':0,
                            'fog':0,'timeOfDay':0,'sunTint':0}
            for (var k:String in w){
                w[k] = weather.targetState[k];
                if (k in object){
                    if (object[k].substr(0, 2) == '0x'){
                        var col:uint = parseInt(object[k]);
                        FlxG.log(k + ': ' + col.toString(16));
                        w[k] = col;
                    } else {
                        var f:Number = parseFloat(object[k]);
                        w[k] = f;
                        FlxG.log(k + ': ' + f);
                    }
                }
            }
            weather.tweenTo(w, 10);
        }
        
        public function progressAll():void{
            reachedVillage = true;
            recruitedCitizen = true;
            boughtItem = true;
            boughtItemAdvice = true
            expandedKingdom = true;
            expandedKingdomAdvice = true;
        }
               
        public function buildLevel(levelXML:Class):void{
            //Load XML
            var oel:XML = new XML(new levelXML);
            //Variables
            var backdropFarGraphic:Class = this[oel.@backdropFarImg] as Class;
            var backdropCloseGraphic:Class = this[oel.@backdropCloseImg] as Class;
            var waterHeight:int = oel.@waterHeight;
            darkness = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height,0x88000000)
            
            //Basic setup
            weather = new Weather();
            add(sky = new Sky(weather));
            add(sunmoon = new SunMoon(weather));
            add(backdropFar = new FlxBackdrop(backdropFarGraphic, 0.15, 0.2, 0xFF717565));
            add(backdropClose = new FlxBackdrop(backdropCloseGraphic, 0.3, 0.2, 0xFF555849));
            add(backdrop = new FlxGroup());
            add(haze = new Haze(0,0,weather));
            // Movables
            add(archers = new FlxGroup(10))
            add(objects = new FlxGroup());
            add(shops = new FlxGroup());
            add(bunnies = new FlxGroup());
            add(beggars = new FlxGroup());
            add(player = new Player(100,68));
            add(characters = new FlxGroup());            
            
            add(trolls = new FlxGroup());
            add(walls = new FlxGroup());
            add(coins = new FlxGroup(100));
            add(gibs = new FlxGroup(200));
            add(indicators = new FlxGroup());

            // Level
            add(level = new FlxGroup());
            add(floor = new FlxTilemap());
            add(farmlands = new FlxGroup())
            add(props = new FlxGroup());
            // Effects
            add(lights = new FlxGroup());
            darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
            darkness.blend = 'multiply';            
            add(darkness);
            
            add(text = new FlxText(10, 138, FlxG.width, "TEXT"));
            text.setFormat("Aurora", 8, 0xFFFFFFFF, "left", 0xAA333333);
			text.visible = false;
			text.scrollFactor.x = 0;
			text.alpha = 0.7;
            
            add(water = new Water(-4,waterHeight,FlxG.width+8,44,lights,weather));
            add(arrows = new FlxGroup(64));
            add(fx = new FlxGroup());
						
			add(sack = new Coinsack(270, 2));
			
            add(fog = new Fog(weather));
			
            add(noise = new FlxSprite(0,0));
            noise.scrollFactor.x = noise.scrollFactor.y = 0;
            noise.makeGraphic(FlxG.width,FlxG.height,0xFFFF00FF)
            noise.pixels.noise(0,0,255,7,true);
            noise.alpha = 0.015;
            
            //Add backdrop objects
            var o:XML;
            if (oel.backdrop != undefined){
                buildObjects(oel.backdrop[0].*,backdrop);
                for (var i:int = 0; i < backdrop.length; i ++){
                    backdrop.members[i].scrollFactor.x = 0.5;
                }
            }
            // Add Ground Tiles
            if (oel.ground != undefined){
                var tileWidth:uint = oel.ground[0].@tileWidth;
                var tileHeight:uint = oel.ground[0].@tileHeight;
                var mapData:String = oel.ground.toString();
                floor.loadMap(mapData, TilesImg, tileWidth, tileHeight);
            }

            grassTiles = new Array();
            for (i = 0; i < floor.widthInTiles; i++){
                var t:int = floor.getTile(i, 4);
                if ((t >= 7 && t <= 11) || (t >= 17 && t <= 18)){
                    grassTiles.push(i);
                }
            }
            
            // Add ground collision proxy because this is a flat level.
            var floorCollider:FlxSprite = new FlxSprite(0,132.2).makeGraphic(FlxG.worldBounds.width,32,0x00FF00FF)
            floorCollider.immovable = true;
            level.add(floorCollider);
                        
            // Add Walls
            if (oel.walls != undefined){
                buildObjects(oel.walls[0].*,walls);
            }

            // Set the closest walls to a first build stage
            for (i = 0; i < walls.length; i ++){
                var w:Wall = walls.members[i] as Wall;
                if ((w.x + w.width) > kingdomLeft && w.x < kingdomRight){
                    w.build()
                }
            }
            
            // Add level objects
            if (oel.objects != undefined){
                buildObjects(oel.objects[0].Shop,shops);
                buildObjects(oel.objects[0].Castle,objects);
            }
            
             // Add level objects
            if (oel.farmlands != undefined){
                buildObjects(oel.farmlands[0].*,farmlands);
            }
            
            // Add props
            if (oel.props != undefined){
                buildObjects(oel.props[0].*,props);
            }
            
            // Add lights
            if (oel.lights != undefined){
                buildObjects(oel.lights[0].*,lights);
            }
        }
        
        /**
         * Builds and adds to groups the objects from given xml nodes
         */
        public function buildObjects(nodes:XMLList, group:FlxGroup):void{
            for each(var node:XML in nodes){
                var objType:String = node.name();
                var obj:FlxSprite;
                try {
                    var classRef:Class = getDefinitionByName(objType) as Class;
                    obj = new classRef(node.@x, node.@y);
                } catch(error:ReferenceError) {
                    var simpleGraphic:Class = this[objType+"Img"]; //getDefinitionByName(objType+"Img") as Class;
                    obj = new FlxSprite(node.@x, node.@y, simpleGraphic)
                }
                group.add(obj);
            }
        }
        
        //=== GAME LOGIC ===//       
        override public function update():void{
            // Collisions
            FlxG.collide(level, coins);
            FlxG.collide(level, trolls);
            FlxG.collide(level, gibs);
            FlxG.overlap(trolls, walls, this.trollWall);
            FlxG.overlap(arrows, trolls, this.trollShot);
            FlxG.overlap(arrows, bunnies, this.bunnyShot);
            FlxG.overlap(coins, characters,this.pickUpCoin);
            FlxG.overlap(coins, player,this.pickUpCoin);
            FlxG.overlap(coins, beggars, this.pickUpCoin);
            FlxG.overlap(coins, trolls, this.pickUpCoin);
            FlxG.overlap(trolls, characters, this.trollHit);
            FlxG.overlap(trolls, player, this.trollHit);
			FlxG.overlap(characters, player, this.giveTaxes);
            // Update weather
            weather.update();
            
            // Gamestate
            if (timeToNextPhase <= 0){
                nextPhase();
            } else if (!phasesPaused){
                timeToNextPhase -= FlxG.elapsed;
            }
            kingdomRight = Math.max(GAME_WIDTH/2 + MIN_KINGDOM_WIDTH/2, kingdomRight - FlxG.elapsed*4);
            kingdomLeft = Math.min(GAME_WIDTH/2 - MIN_KINGDOM_WIDTH/2, kingdomLeft + FlxG.elapsed*4);
            
            // Spawn bunnies using logistic growth
            var p:Number = (bunnies.countLiving() + 2) / (MAX_BUNNIES + 2);
            if (bunnySpawnTimer <= 0){
                bunnySpawnTimer = MIN_BUNNY_SPAWNTIME;
                var probAdd:Number = 0.5 + 2*p*(1-p);
                if (FlxG.random() < probAdd){
                    var rx:int = int(FlxG.random()*grassTiles.length);
                    bunnies.add(new Bunny(grassTiles[rx]*32,0));
                }
            } else {
                bunnySpawnTimer -= FlxG.elapsed;
            }
            
            // Spawn beggars
            if (beggars.countLiving() < minBeggars){
                beggars.add(new Citizen((FlxG.random() < 0.5) ? 16 : GAME_WIDTH-16,0));
            }
            
            // Spawn trolls
            updateTrollSpawn()
            trollSpawnTimer -= FlxG.elapsed;
            if (retreatDelay > 0){
                retreatDelay -= FlxG.elapsed
                if (retreatDelay <= 0){
                    trolls.callAll("retreat");
                }
            }
            
			
            // Text update
            if (textTimeout <= 0){
				showText()
            } else {
    			text.alpha = Math.min(TEXT_MAX_ALPHA, textTimeout);
                textTimeout -= FlxG.elapsed;
            }
            
            // Camera follow timeout
            if (cameraTarget.target != player){
                if (cameraTimeout <= 0){
                    // Reset the cameratarget.
                    cameraTarget.target = player;
                    cameraTarget.lead = 48;
                } else {
                    cameraTimeout -= FlxG.elapsed;
                }
            }
            
            // Progress update
            if (player.x > GAME_WIDTH/2 && !reachedVillage) {
                reachedVillage = true;
                if (beggars.length > 0){
                    panTo(beggars.members[0], 5.0);
                    showText("Throw some coins [DOWN] near them.");
                }
            }
            
            if (recruitedCitizen && !boughtItem && !boughtItemAdvice){
                boughtItemAdvice = true;
                showText("Buy them some bows or scythes.");
                panTo(shops.members[1], 5.0);
            }
            
            if (boughtItem && !expandedKingdom && !expandedKingdomAdvice && characters.length >= 3){
                expandedKingdomAdvice = true;
                showText("Expand your kingdom by building a wall here.");
                panTo(walls.members[1], 5.0, -12);
            }

            this.updateEnvironmentSounds();

            if(gameover && FlxG.mouse.justPressed())
            {
                FlxG.mouse.hide();
                FlxG.switchState(new PlayState());
            }
            
            super.update();
            
            if (CHEATS){
                if (FlxG.keys.justPressed("T")) {
                    cheatNoTrolls = !cheatNoTrolls;
                    showText("Trolls " + (cheatNoTrolls ? "disabled" : "enabled"))
                }
            
                if (FlxG.keys.justPressed("N")) {
                    timeToNextPhase = 1.0;
                    showText("Skip phase.");
                }
                
                if (FlxG.keys.justPressed("B")) {
                    beggars.add( new Citizen ((kingdomRight+kingdomLeft) / 2, 0));
                    showText("Spawned beggar.")
                }

                if (FlxG.keys.justPressed("I")) {
                    trollBig = !trollBig;
                    showText("Trolls " + (trollBig ? "big." : "normal."));
                }


                if (FlxG.keys.justPressed('A')) {
                    progressAll();
                    showText("Full progress")
                }
            
                if (FlxG.keys.justPressed("F")){
                    (player as Player).food = 10000;
                    showText("Horse speed.")
                }
                
                if (FlxG.keys.justPressed("R")){
                    spawnTrolls(2)
                    showText("Spawned 2 trolls")
                }
                
                if (FlxG.keys.justPressed("P")){
                    phasesPaused = !phasesPaused;
                    showText("Phases " + (phasesPaused ? "paused" : "resumed"))
                }

                if (FlxG.keys.justPressed("ENTER")){
                    setWeatherFromInput();
                }
                            
                if (FlxG.keys.justPressed("C")){
                    (player as Player).coins += 1;
                    showText((player as Player).coins + " coins.")
                }
                if (FlxG.keys.justPressed("S"))
    			{
    				if (FlxG.stage.displayState == 'normal')
    				{
    					FlxG.stage.displayState = 'fullScreen';
    				}else{
    					FlxG.stage.displayState = 'normal';
    				}
    			}
            }
        }
          
        public function phaseFirst():void{
            beggars.add( new Citizen (kingdomRight+300, 0)); 
            beggars.add( new Citizen (kingdomRight+300, 0));
            trollMaxSpeed = 24;
            trollJumpiness = 0.0;
            trollConfusion = 0.01;
            trollHealth = 1;
            minBeggars = 2;
        }
        public function phaseBeforeNightOne():void{
            showText("Night comes, be careful."); 
        }
        
        public function phaseNightOne():void{
            trollMaxSpeed = 24;
            trollJumpHeight = 20;
            trollJumpiness = 0.0;
            trollConfusion = 0.01;
            trollHealth = 1;
            spawnTrolls(2);
            panTo(trolls.members[0]);
            showText("They will noodle your stuff away.")
        }
        
        // These trolls still won't scale your lowest walls
        public function phaseNightTwo():void{
            trollMaxSpeed   = 26;
            trollJumpHeight = 20;
            trollJumpiness  = 0.02;
            trollConfusion  = 0.06;
            spawnTrolls(12);
        }
        
        // These WILL scale the lowest walls
        public function phaseNightThree():void{
            trollHealth = 30;
            trollJumpHeight = 40;
            spawnTrolls(16);
        }
        
        public function phaseNightFour():void{
            trollHealth = 2;
            spawnTrolls(20);
        }
        
        public function phaseNightFive():void{
            trollMaxSpeed   = 30;
            trollConfusion  = 0.05;
            spawnTrolls(36);
        }
        
        public function phaseNightSix():void{
            trollJumpHeight = 320;
            trollMaxSpeed   = 45;
            trollHealth     = 3
            spawnTrolls(8);
        }

        public function phaseNightSeven():void{
            trollJumpHeight = 140;
            trollMaxSpeed = 30;
            trollHealth = 1
            spawnTrolls(32);
            trollHealth = 4
            trollBig = true;
            trollMaxSpeed = 32;
            spawnTrolls(4);
        }

        public function phaseNightEight():void{
            trollHealth = 1;
            trollBig = false;
            spawnTrolls(60);
        }

        public function phaseNightNine():void{
            trollBig = true;
            trollHealth = 10;
            trollMaxSpeed = 24;
            spawnTrolls(10);
        }

        public function phaseNightTen():void{
            trollBig = false;
            trollHealth = 2;
            spawnTrolls(100);
        }
        
        public function phaseNightCycle():void{
            var difficulty:Number = Math.sqrt(phase) / 4;
            trollMaxSpeed = 20 * difficulty;
            trollJumpHeight = 120 * difficulty;
            trollJumpiness = 0.05 * difficulty;
            trollConfusion = 0.06 / difficulty;
            spawnTrolls(int(8 * difficulty));
        }
        
        public const PHASES:Array = [
            // INTRO (0-3)
            [WeatherPresets.FOGGY, 10, null, phaseFirst, null],
            [WeatherPresets.DAWN, 25, null, daybreak, null],
            [WeatherPresets.SUNNY, 30, null, null, null],
            [WeatherPresets.EVENING, 20, null, null, null],
            // ONE (4-9)
            [WeatherPresets.NIGHT, 20, null, phaseBeforeNightOne, MusicNight2],
            [null, 50, null, phaseNightOne, null],
            [WeatherPresets.DAWNLIGHTPINK, 20, null, daybreak, null],
            [WeatherPresets.DAYWINDYCLEAR, 30, null, null, MusicDay1],
            [WeatherPresets.DUSKYELLOW, 20, null, null, null],
            [WeatherPresets.EVENINGORANGE, 20, null, null, MusicNight3],
            // TWO (10-14)
            [WeatherPresets.NIGHTGREEN, 60, 30, phaseNightTwo, null], // GREEN
            [WeatherPresets.DAWNGREY, 20, null, daybreak, null],
            [WeatherPresets.DAYBLEAK, 50, null, null, MusicDay2],
            [WeatherPresets.DUSKWARM, 20, null, null, null],
            [WeatherPresets.EVENINGBLACK, 20, null, null, MusicNight4],
            // THREE (15-18)
            [WeatherPresets.NIGHTDARK, 60, 30, phaseNightThree, null],
            [WeatherPresets.DAWNBLEAK, 20, null, daybreak, null],
            [WeatherPresets.DAYSOFT, 40, null, null, null],
            [WeatherPresets.EVENINGMONOTONE, 20, null, null, MusicNight5],
            // FOUR (19-22)
            [WeatherPresets.NIGHTSUPERDARK, 60, 30, phaseNightFour, null],
            [WeatherPresets.DAWNLIGHTPINK, 20, null, daybreak, MusicDay3],
            [WeatherPresets.DAYBLEAK, 40, null, null, null],
            [WeatherPresets.EVENINGFOGGY, 40, null, null, MusicNight4],
            // FIVE (23-26)
            [WeatherPresets.NIGHTFOGGY, 60, 30, phaseNightFive, null],
            [WeatherPresets.DAWNBLEAK, 25, null, daybreak, MusicDay4],
            [WeatherPresets.DAYMONOCHROME, 45, null, null, null],            
            [WeatherPresets.DUSKPINK, 20, null, null, null],
            // SIX (27-30)
            // 4 TROLLS WITH EPIC JUMPING
            [WeatherPresets.NIGHTCLEAR, 70, 30, phaseNightSix, MusicNight4],
            [WeatherPresets.DAWNCLEARORANGE, 20, null, daybreak, null], 
            [WeatherPresets.DAYCLEARCOLD, 40, null, null, MusicDay3],
            [WeatherPresets.DUSKCLEAR, 20, null, null, null],
            // SEVEN (31-34)
            // RED MOON
            [WeatherPresets.NIGHTREDMOON, 60, 30, phaseNightSeven, MusicNight3],
            [WeatherPresets.DAWNREDMOON, 20, null, daybreak, MusicDay5],
            [WeatherPresets.DAYORANGESKY, 60, null, null, null],
            [WeatherPresets.DUSKFOGGY, 20, null, null, null],
            // EIGHT (35-38)
            // BIG WAVE
            [WeatherPresets.NIGHTPURPLE, 80, 30, phaseNightEight, MusicNight4],  
            [WeatherPresets.DAWNBRIGHT, 20, null, daybreak, null],
            [WeatherPresets.DAYPASTEL, 40, null, null, MusicDay2],            
            [WeatherPresets.DUSKTAN, 20, null, null, MusicNight4],
            // NINE (39-42)
            // SINGLE TROLL, MASSIVE HEALTH
            [WeatherPresets.NIGHTSHINE, 60, 30, phaseNightNine, null],
            [WeatherPresets.DAWNBROWN, 20, null, daybreak, null],
            [WeatherPresets.DAYDUSTY, 40, null, null, null],             //TODO
            [WeatherPresets.DUSKRED, 20, null, null, MusicNight3],            //TODO
            // TEN (43)
            // EVERYTHING, YOU DIE HERE.
            [WeatherPresets.NIGHTLONG, 60, 30, phaseNightTen, null]  //TODO
        ];
        
        public const PHASES_CYCLE:Array = [
            [WeatherPresets.DAWNGREY, 20, null, daybreak, null],
            [WeatherPresets.DAYBLEAK, 40, null, null, null],
            [WeatherPresets.EVENINGORANGE, 20, null, null, null],
            [WeatherPresets.NIGHTGREEN, 30, null, null, MusicNight5],
            [null, 55, null, phaseNightCycle, null]
        ];
        
        
        public function nextPhase():void{
            if (phasesPaused){
                return;
            }
            var currentPhase:Array;
            if (phase < PHASES.length){
                currentPhase = PHASES[phase];
            } else {
                var p:int = (phase - PHASES.length) % 5;
                currentPhase = PHASES_CYCLE[p]
            }
            var weatherTweenTime:Number;
            timeToNextPhase = currentPhase[1];
            // Transform weather
            if (currentPhase[2] == null){
                weatherTweenTime = timeToNextPhase * 0.7;
            } else {
                weatherTweenTime = currentPhase[2]
            }
            if (currentPhase[0] != null){
                weather.tweenTo(currentPhase[0], weatherTweenTime);
            }
            // Call the function to do custom actions if there is one
            if (currentPhase[3] != null){
                currentPhase[3]();
            }
            // Play music
            if (currentPhase[4] != null){
                if (this.music != null){
                    this.music.stop();
                }
                this.music = FlxG.play(currentPhase[4]);
                FlxG.log("Playing " + currentPhase[4]);
            }
            
            phase += 1;
        }

        public function updateEnvironmentSounds():void{
            var v:Number;
            v = 1 - Math.pow(Math.abs(weather.timeOfDay - 0.7) / 0.1, 2);
            this.cicada.volume = v;

            v = 1 - Math.pow(Math.min(weather.timeOfDay, Math.abs(weather.timeOfDay - 1.0)) / 0.2, 2);
            this.owls.volume = v;

            v = 1 - Math.pow(Math.abs(weather.timeOfDay - 0.4) / 0.25, 2);
            this.birds.volume = v;

            // if (v > 0){
            //     this.cicadas.resume();
            // } else {
            //     this.cicadas.pause();
            // }
        }
                
        public function spawnTrolls(amount:int):void{
            if (cheatNoTrolls)
                return;

            while(amount){
                amount -= 2;
                var o:Number = FlxG.random()*12;
            
                var troll:Troll = (trolls.recycle(Troll) as Troll);
                troll.reset(24-o, groundHeight - 40)
                trollsToSpawn.push(troll);
                
                troll = (trolls.recycle(Troll) as Troll);
                troll.reset(GAME_WIDTH-24+o, groundHeight - 40);
                trollsToSpawn.push(troll);

                updateTrollSpawn();    
            }
            
        }
        
        public function updateTrollSpawn():void{
            if (trollsToSpawn.length > 0 && trollSpawnTimer <= 0){
                (trollsToSpawn.shift() as Troll).go();
                (trollsToSpawn.shift() as Troll).go();
                trollSpawnTimer = MIN_TROLL_SPAWNTIME;
            }
        }

        public function daybreak():void{
            trollRetreat();
            dayNumber ++;
            showText(Utils.toRoman(dayNumber));
        }
        
        public function trollRetreat(delay:Number=10):void{
            
            retreatDelay = delay;
            
            if (retreatDelay <= 0){
                trolls.callAll("retreat");
            }
        }
        
        public function pickUpCoin(coin:FlxObject, char:FlxObject):void{
            if (char is Player){
                (char as Player).pickup(coin);
            } else if (char is Citizen){
                (char as Citizen).pickup(coin);
            } else if (char is Troll){
                (char as Troll).pickup(coin);
            }
        }
		
		public function giveTaxes(char:FlxObject, player:FlxObject):void{
			if (char != player){
				(char as Citizen).giveTaxes(player as Player);
			}
		}
        
        public function trollWall(troll:FlxObject, wall:FlxObject):void{
            FlxObject.separate(troll, wall);
            wall.hurt(5);
        }
        
        public function trollShot(arrow:FlxObject, troll:Troll):void{
            if (troll.alive && arrow.exists){
                FlxG.play(HitbigSound).proximity(arrow.x, arrow.y, player, FlxG.width);
                arrow.kill();
                (troll as Troll).getShot();
            }
        }
        
        public function bunnyShot(arrow:FlxObject, bunny:FlxObject):void{
            if (bunny.alive && arrow.exists){
                FlxG.play(HitSound).proximity(arrow.x, arrow.y, player, FlxG.width);
                arrow.kill();
                (bunny as Bunny).getShot(arrow as Arrow);
            }
        }
        
        public function trollHit(troll:FlxObject, char:FlxObject):void{
            if (char is Citizen){
                (char as Citizen).hitByTroll(troll as Troll);
            }
            if (char == player){
                (char as Player).hitByTroll(troll as Troll);
            }
        }

        public function crownStolen():void{
            gameover = true;
            trollRetreat(2);
            FlxG.mouse.show();
            showText("No crown, no king. Game over.");
            showText("Click to start again.");
            FlxG.fade(0, 30, endGame);
        }

        public function endGame():void{
            FlxG.switchState(new GameOverState());
        }
        
        //=== RENDERING ==//
        override public function draw():void{
            darkness.dirty = true;
            darkness.fill(weather.darknessColor);
            
            super.draw();
            weather.ambientTransform.applyFilter(FlxG.camera.buffer);
        }
        
		public function showCoins():void{
            var c:int = (player as Player).coins;
			sack.show(c);
		}
        
        public function showText(t:String=null):void{
			if (t != null){
				textQueue = textQueue.concat(t.split('\n'))
			}
			if (textQueue.length > 0 && textTimeout <= 0){
	            text.text = textQueue.shift();
	            text.visible = true;
				textTimeout = TEXT_READ_SPEED * text.text.length;
			}
        }
        
        public function panTo(o:FlxSprite, duration:Number=8.0, lead:Number=0):void{
            cameraTimeout = duration;
            cameraTarget.target = o;
            cameraTarget.lead = lead;
        }
    }
}
