package{
    import flash.display.BitmapData;
    import flash.filters.ConvolutionFilter;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    
    public class FlxBumpmap extends FlxSprite {
        
        private static var filter:ConvolutionFilter = new ConvolutionFilter(3,3,null,1,0,true,false,0xFF808080);
        private static var rect:Rectangle;
        private static var zeroPoint:Point = new Point(0,0);
        
        public function FlxBumpmap(){
            super();

        }
        
        public function light(target:FlxSprite, color:uint=0x55FFFFCC, blend:String="normal"):FlxBumpmap{
            process(target, [0,0,-1,0,2,-1,0,0,0], color, blend);
            return this
        }
        
        public function shade(target:FlxSprite, color:uint=0x66333355, blend:String="normal"):FlxBumpmap{
            var m:Array = [0,0, 0,0,1,
                           0,0, 0,1,0,
                           0,0,-2,0,0,
                           0,0, 0,0,0,
                           0,0, 0,0,0]
            process(target, m, color, blend);
            return this;
        }
        
        protected function process(target:FlxSprite, matrix:Array, color:uint, blend:String="normal"):void{
            rect = new Rectangle(0,0,pixels.width,pixels.height);
            
            filter.matrixX = filter.matrixY = Math.sqrt(matrix.length);
            filter.matrix = matrix;

            var regions:BitmapData = new BitmapData(pixels.width,pixels.height);
            regions.applyFilter(pixels,rect,zeroPoint,filter);
            regions.threshold(regions,rect,zeroPoint,">",0x000000,color,0x00FFFFFF);
            regions.threshold(regions,rect,zeroPoint,"==",0x000000,0x000000,0x00FFFFFF);
            
            target.pixels.draw(regions,null,null,blend);
            target.dirty = true;
            regions.dispose();
        }
        
        public static function lightFlatSprite(target:FlxSprite, color:uint=0x55FFFFCC, blend:String="normal"):void{
            processFlatSprite(target, [0,0,-1,0,2,-1,0,0,0], color, blend);
        }
        
        public static function processFlatSprite(target:FlxSprite, matrix:Array, color:uint, blend:String="normal"):void{
            rect = new Rectangle(0,0,target.pixels.width,target.pixels.height);
            
            filter.matrixX = filter.matrixY = Math.sqrt(matrix.length);
            filter.matrix = matrix;

            var regions:BitmapData = target.pixels.clone();
            regions.threshold(regions,rect,zeroPoint,">",0x00FFFFFF,0xFFFFFFFF,0xFFFFFFFF);
            regions.applyFilter(regions,rect,zeroPoint,filter);
            regions.threshold(regions,rect,zeroPoint,">",0x000000,color,0x00FFFFFF);
            regions.threshold(regions,rect,zeroPoint,"==",0x000000,0x000000,0x00FFFFFF);
            
            target.pixels.draw(regions,null,null,blend);
            target.dirty = true;
            regions.dispose();
        }
        
    }
}
