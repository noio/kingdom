package
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.geom.Rectangle;
    import flash.geom.Matrix;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    import org.flixel.FlxParticle;
    import org.flixel.FlxGroup;
    import org.flixel.FlxG;
    
    public class Utils{
        
        public static const DEG_TO_RAD:Number = Math.PI/180;
        
        /**
         * Shrinks the hitbox (x,y and offset) of given FlxSprite to the pixels that are actually
         * covered by a greater portion than min{X,Y}Cover of the pixels.
         */
        static public function shrinkHitbox(sprite:FlxSprite, minXCover:Number=0, minYCover:Number=0.5):void{
            var pix:BitmapData = sprite.pixels;
            var x:int, y:int, sum:int = 0;
            var minx:int = pix.width;
            var maxx:int = 0;
            var miny:int = pix.height;
            var maxy:int = 0;
            for (x = 0; x < pix.width; x++){
                sum = 0
                for (y = 0; y < pix.height; y++){
                    if (pix.getPixel32(x,y) > 0x00FFFFFF) sum ++;
                }
                if (sum >= minXCover*pix.height) {
                    minx = Math.min(minx,x);
                    maxx = Math.max(maxx,x);
                } 
            }
            for (y = 0; y < pix.height; y++){
                sum = 0
                for (x = 0; x < pix.width; x++){
                    if (pix.getPixel32(x,y) > 0x00FFFFFF) sum ++;
                }
                if (sum >= minYCover*pix.width) {
                    miny = Math.min(miny,y);
                    maxy = Math.max(maxy,y);
                }
            }
            sprite.width  = maxx-minx;
            sprite.height = maxy-miny;
            sprite.offset.x = minx
            sprite.offset.y = miny;
            sprite.x += minx/2;
            sprite.y += miny/2;
        }

    
        static public function findRectanglesWithColor(bitmap:BitmapData, color:uint):Vector.<Rectangle> {
            var cur:Rectangle;
            var rects:Vector.<Rectangle> = new Vector.<Rectangle>();
            var i:int,j:int,k:int;
            for(i = 0; i < bitmap.height; i++){
                for(j = 0; j < bitmap.width; j++){
                    for(k = 0; k < rects.length; k++){
                        cur = rects[k];
                        // If we are in a rect, skip to the right side.
                        if (cur.contains(j,i)){
                            j = cur.right;
                            // If we are outside of the image, next line.
                            if (j >= bitmap.width){
                                j = 0;
                                i++;
                            }
                        }
                    }
                    if (bitmap.getPixel32(j,i) == color){
                        rects.push(cur = new Rectangle(j,i,1,1));
                        // Traverse to right
                        while( bitmap.getPixel32(j,i) == color){
                            j++;
                        }
                        cur.width = j - cur.x;
                        // Traverse down
                        while( bitmap.getPixel32(j-1,i) == color){
                            i++;
                        }
                        cur.height = i - cur.y;
                        // Reset I and J
                        j = cur.right;
                        i = cur.y;
                    }
                }
            }
            return rects;
        }
    
        /**
         * Replace one color with another in bitmap.
         */
        static public function replaceColor(bitmap:BitmapData,fromColor:uint, toColor:uint):void{
            for (var i:int = 0; i < bitmap.height; i++){
                for( var j:int = 0; j < bitmap.width; j++){
                    if (bitmap.getPixel32(j,i) == fromColor){
                        bitmap.setPixel32(j, i, toColor);
                    }
                }
            }
        }
        
        /**
         * Fills a bitmap with a gradient with given colors
         */
        static public function gradientOverlay(bitmap:BitmapData, colors:Array, rotation:Number=90, chunks:int = 1):void{
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(bitmap.width/chunks, bitmap.height/chunks, rotation*DEG_TO_RAD);
            var s:Shape      = new Shape();
            var ratios:Array = new Array(colors.length);
            var alphas:Array = new Array(colors.length);
            
            for (var i:int = 0; i < colors.length; i ++){
                alphas[i] = (colors[i] >>> 24)/255;
                ratios[i] = (i * (1/(colors.length-1)))*255;
            }
            
            s.graphics.beginGradientFill("linear", colors, alphas, ratios, matrix, "pad", "rgb");

            s.graphics.drawRect(0, 0, bitmap.width/chunks, bitmap.height/chunks);
            
            if (chunks == 1) {
                bitmap.draw(s);
            } else {   
                var transform:Matrix = new Matrix();
                var tempBitmap:BitmapData = new BitmapData(bitmap.width/chunks,bitmap.height/chunks,true,0x000000);
                tempBitmap.draw(s);
                transform.scale(bitmap.width/tempBitmap.width,bitmap.height/tempBitmap.height);
                bitmap.draw(tempBitmap,transform);
            }
        }
        
        /**
         * Convert a HSV (hue, saturation, lightness) color space value to an RGB color
         * 
         * @param    h Hue degree, between 0 and 359
         * @param    s Saturation, between 0.0 (grey) and 1.0
         * @param    v Value, between 0.0 (black) and 1.0
         * 
         * @return 32-bit RGB colour value (0xAARRGGBB)
         */
        public static function HSVtoRGB(h:Number, s:Number, v:Number):uint
        {
            var result:uint;
            
            if (s == 0.0)
            {
                result = getColor32(255, v * 255, v * 255, v * 255);
            }
            else
            {
                h = h / 60.0;
                var f:Number = h - int(h);
                var p:Number = v * (1.0 - s);
                var q:Number = v * (1.0 - s * f);
                var t:Number = v * (1.0 - s * (1.0 - f));
                
                switch (int(h))
                {
                    case 0:
                        result = getColor32(255, v * 255, t * 255, p * 255);
                        break;
                        
                    case 1:
                        result = getColor32(255, q * 255, v * 255, p * 255);
                        break;
                        
                    case 2:
                        result = getColor32(255, p * 255, v * 255, t * 255);
                        break;
                        
                    case 3:
                        result = getColor32(255, p * 255, q * 255, v * 255);
                        break;
                        
                    case 4:
                        result = getColor32(255, t * 255, p * 255, v * 255);
                        break;
                        
                    case 5:
                        result = getColor32(255, v * 255, p * 255, q * 255);
                        break;
                        
                    default:
                        FlxG.log("FlxColor Error: HSVtoRGB : Unknown color");
                }
            }
            
            return result;
        }
        
        
        public static function RGBtoHSV(color:uint):Object
        {
            var rgb:Object = getRGB(color);
            
            var red:Number = rgb.red / 255;
            var green:Number = rgb.green / 255;
            var blue:Number = rgb.blue / 255;
            
            var min:Number = Math.min(red, green, blue);
            var max:Number = Math.max(red, green, blue);
            var delta:Number = max - min;
            var lightness:Number = (max + min) / 2;
            var hue:Number;
            var saturation:Number;
            
            //  Grey color, no chroma
            if (delta == 0)
            {
                hue = 0;
                saturation = 0;
            }
            else
            {
                if (lightness < 0.5)
                {
                    saturation = delta / (max + min);
                }
                else
                {
                    saturation = delta / (2 - max - min);
                }
                
                var delta_r:Number = (((max - red) / 6) + (delta / 2)) / delta;
                var delta_g:Number = (((max - green) / 6) + (delta / 2)) / delta;
                var delta_b:Number = (((max - blue) / 6) + (delta / 2)) / delta;
                
                if (red == max)
                {
                    hue = delta_b - delta_g;
                }
                else if (green == max)
                {
                    hue = (1 / 3) + delta_r - delta_b;
                }
                else if (blue == max)
                {
                    hue = (2 / 3) + delta_g - delta_r;
                }
                
                if (hue < 0)
                {
                    hue += 1;
                }
                
                if (hue > 1)
                {
                    hue -= 1;
                }
            }
            
            //    Keep the value with 0 to 359
            hue *= 360;
            hue = Math.round(hue);
            
            //    Testing
            //saturation *= 100;
            //lightness *= 100;
            
            return { hue: hue, saturation: saturation, lightness: lightness, value: lightness };
        }
        
        public static function interpolateColor(color1:uint, color2:uint, f:Number):uint
        {
            var a1:uint = color1 >>> 24;
            var r1:uint = color1 >> 16 & 0xFF;
            var g1:uint = color1 >> 8 & 0xFF;
            var b1:uint = color1 & 0xFF;
            
            var a2:uint = color2 >>> 24;
            var r2:uint = color2 >> 16 & 0xFF;
            var g2:uint = color2 >> 8 & 0xFF;
            var b2:uint = color2 & 0xFF;
            
            var fi:Number = (1-f);
            
            a1 = (fi * a1) + (f * a2);
            r1 = (fi * r1) + (f * r2);
            g1 = (fi * g1) + (f * g2);
            b1 = (fi * b1) + (f * b2);
            
            return a1 << 24 | r1 << 16 | g1 << 8 | b1;
        }
        
        public static function interpolateColorAndAlpha(color1:uint, color2:uint, steps:uint, currentStep:uint):uint
        {
            var src1:Object = getRGB(color1);
            var src2:Object = getRGB(color2);

            var a:uint = (((src2.alpha - src1.alpha) * currentStep) / steps) + src1.alpha;
            var r:uint = (((src2.red - src1.red) * currentStep) / steps) + src1.red;
            var g:uint = (((src2.green - src1.green) * currentStep) / steps) + src1.green;
            var b:uint = (((src2.blue - src1.blue) * currentStep) / steps) + src1.blue;

            return getColor32(a, r, g, b);
        }
        
        /**
         * Return the component parts of a color as an Object with the properties alpha, red, green, blue
         * 
         * <p>Alpha will only be set if it exist in the given color (0xAARRGGBB)</p>
         * 
         * @param    color in RGB (0xRRGGBB) or ARGB format (0xAARRGGBB)
         * 
         * @return Object with properties: alpha, red, green, blue
         */
        public static function getRGB(color:uint):Object
        {
            var alpha:uint = color >>> 24;
            var red:uint = color >> 16 & 0xFF;
            var green:uint = color >> 8 & 0xFF;
            var blue:uint = color & 0xFF;
            
            return { alpha: alpha, red: red, green: green, blue: blue };
        }
        
        /**
         * Given an alpha and 3 color values this will return an integer representation of it
         * 
         * @param    alpha    The Alpha value (between 0 and 255)
         * @param    red        The Red channel value (between 0 and 255)
         * @param    green    The Green channel value (between 0 and 255)
         * @param    blue    The Blue channel value (between 0 and 255)
         * 
         * @return    A native color value integer (format: 0xAARRGGBB)
         */
        public static function getColor32(alpha:uint, red:uint, green:uint, blue:uint):uint
        {
            return alpha << 24 | red << 16 | green << 8 | blue;
        }
        
        
        public static function explode(object:FlxSprite, group:FlxGroup, portion:Number = 1, gibsize:int=4, rounded:Boolean=true):Vector.<FlxParticle>{
            var gibs:Vector.<FlxParticle> = new Vector.<FlxParticle>()
            var gib:FlxParticle;
            for (var x:int = 0; x < object.framePixels.width; x += gibsize){
                for (var y:int = 0; y < object.framePixels.height; y += gibsize){
                    if ((object.pixels.getPixel32(x+gibsize/2,y+gibsize/2) >>> 24) > 0){
                        if (FlxG.random() < portion){
                            gib = group.recycle(FlxParticle) as FlxParticle;
                            if (gib.frameWidth != gibsize || gib.frameHeight != gibsize){
                                gib.makeGraphic(gibsize,gibsize,0,true);
                            }
                            gib.revive();
                            gib.stamp(object, -x, -y);
                            if (rounded){
                                gib.framePixels.setPixel32(0,0,0);
                                gib.framePixels.setPixel32(0,gibsize-1,0);
                                gib.framePixels.setPixel32(gibsize-1,0,0);
                                gib.framePixels.setPixel32(gibsize-1,gibsize-1,0);
                            }
                            gibs.push(gib);
                            gib.elasticity = 0.5;
                            gib.lifespan = 7;
                            gib.x = object.x - object.offset.x + x;
                            gib.y = object.y - object.offset.y + y;
                            gib.acceleration.y = 900;
                            gib.velocity.x = FlxG.random()*80 - 40;
                            gib.velocity.y = -130-FlxG.random()*30;
                        }
                    }
                }
            }
            return gibs;
        }
    }
}
