package{
    import flash.geom.Point;
    import flash.display.BitmapData;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxGroup;
    import org.flixel.FlxG;
    
    public class FlxBackdrop extends FlxSprite{
        
        /**
        * A class that renders a single "backdrop" image repeatedly when drawn. 
        * Depending on the scrollfactor, the backdrop will move along when the 
        * camera moves. Multiple backdrop layers can be used to easily create 
        * a parralax effect.
        */
                
        private var w:int;
                
        public function FlxBackdrop(graphicClass:Class, XScroll:Number=0.333, YScroll:Number=0.2, Color:uint=0xFF474a3d):void{
            
            var graphic:BitmapData = FlxG.addBitmap(graphicClass);
            w = graphic.width;
            makeGraphic(w + FlxG.width, graphic.height, 0x00000000, true);
            
            this.y = (FlxG.height - graphic.height)/2
            
            // Copy the graphic's pixels to this sprite pixels, adding an extra "fold"
            var p:Point = new Point(0,0);
            pixels.copyPixels(graphic, graphic.rect, p);
            p.x = w;
            pixels.copyPixels(graphic, graphic.rect, p);
            dirty = true;
            
            scrollFactor.x = XScroll;
            scrollFactor.y = YScroll;
            
            this.color = Color;
        }
        
        override public function update():void{
            getScreenXY(_point);
            if (_point.x < -w){
                x += w;
            } else if (_point.x > 0){
                x -= w;
            }

            super.update();
        }
        
    }
}