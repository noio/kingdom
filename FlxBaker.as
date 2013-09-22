package{
    
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.display.BitmapData;
    import flash.utils.getQualifiedClassName
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class FlxBaker{
        private static const zeroPoint:Point = new Point(0,0);
        
        private static var _baked:Object = new Object();
        
        public static function bake(sprite:FlxSprite, key:String='base'){
            var id:String = getQualifiedClassName(sprite)+"@("+int(sprite.x)+','+int(sprite.y)+')'+key;
            var bmp:BitmapData = new BitmapData(sprite.pixels.width,sprite.pixels.height);
            bmp.copyPixels(sprite.pixels, new Rectangle(0,0,sprite.frameWidth,sprite.frameHeight),zeroPoint,null,null,true);
            _baked[id] = bmp;
        }
    }
}