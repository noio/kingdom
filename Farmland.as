package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    
    public class Farmland extends FlxSprite implements Workable{
        
        [Embed(source='/assets/gfx/farmland.png')]    private var FarmlandImg:Class;
        
        public function Farmland(X:int, Y:int){
            super(X,Y);
            loadGraphic(FarmlandImg, true, false, 64, 32);
            addAnimation("grow",[0,1,2,3,4,5,6,7],10);
        }
        
        public function needsWork():Boolean {
            return true;
        }
        
        public function work(by:Citizen):void{
            if (frame == 7){
                ((FlxG.state as PlayState).coins.recycle(Coin) as Coin).drop(this, by);
                ((FlxG.state as PlayState).coins.recycle(Coin) as Coin).drop(this, by);
                by.pickNewGoal(x+width/2);
            }
            frame = (frame + 1) % 8;
        }
    }
}