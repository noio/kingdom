package
{
    import flash.geom.Point;
    
    import org.flixel.FlxG;
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    public class CoinFloat extends FlxSprite{
        
        [Embed(source='/assets/gfx/coin_drop.png')]     private var Img:Class;
        
        public function CoinFloat(){
            super();
            
            loadGraphic(Img,true,false,10,24);
            addAnimation('spin',[0,1,2,3,4,5,6,7],10,true);
            play('spin');
        }
                
        public function float(above:FlxSprite):void{
            acceleration.y = 0;
            x = above.x + above.width/2 - width/2;
            y = Math.max(above.y - height - 4, 40);
            above.color = 0xCCCC00;
            // above.flicker();
        }
        
    }
}
