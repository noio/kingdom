package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxGroup;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Scaffold extends FlxSprite{
        
        [Embed(source='/assets/gfx/scaffold.png')] public var Img:Class;
        
                
        public function Scaffold(){
            super(0,0);
            loadGraphic(Img);
            offset.x = 4;
            width = 24;
        }
        
        public function build(over:FlxSprite):Scaffold {
            revive();
            x = over.x;
            y = over.y;
            return this;
        }
    }
}