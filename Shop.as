package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxGroup;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Shop extends FlxSprite implements Buildable{
        
        [Embed(source='/assets/gfx/shop.png')] public var Img:Class;
        
        public static const SCYTHES:int = 1;
        public static const BOWS:int = 2;
        
        public var type:int;
        public var supply:int = 0;
                
        public function Shop(X:int, Y:int){
            super(X,Y+2);
            if (X > PlayState.GAME_WIDTH/2){
                type = BOWS;
            } else {
                type = SCYTHES;
            }
            loadGraphic(Img,true);
            width = 56;
            offset.x = 4;
            x += 4;
            height = 46;
            offset.y = 18;
            y += 18;
            moves = false;
            updateAppearance();
        }
        
        override public function update():void{
            if (supply > 0){
                FlxG.overlap(this, (FlxG.state as PlayState).characters, equip)
            }
        }
        
        public function equip(shop:FlxObject, char:FlxObject):void{
            if (supply <= 0)
                return;
            var cit:Citizen = char as Citizen;
            if (cit.occupation == Citizen.POOR){
                supply --;
                if (type == BOWS){
                    cit.morph(Citizen.HUNTER);
                } else {
                    cit.morph(Citizen.FARMER);
                }
                updateAppearance();
            }
        }

        public function setSupply(s:int):void{
            supply = s;
            updateAppearance();
        }
        
        public function updateAppearance():void{
            frame = supply;
            if (type == BOWS){
                frame += 5;
            }
        }
        
        public function canBuild():Boolean{
            return (supply < 4);
        }
        
        public function build():void{
            (FlxG.state as PlayState).boughtItem = true;
            supply += 1;
            flicker();
            updateAppearance();
        }
        
        
    }
}