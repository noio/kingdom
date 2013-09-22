package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Treeline extends FlxSprite{
        
        [Embed(source='/assets/gfx/treeline.png')]    private var TreelineImg:Class;
        
        
        public function Treeline(X:int, Y:int){
            super(X,Y);
            loadGraphic(TreelineImg, false, true, 96, 160);
            if (X == 0)
                facing = LEFT;
        }
        
    }
}