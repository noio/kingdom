package
{
    import flash.geom.Point;
    
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import org.flixel.FlxBasic;
    import org.flixel.FlxGroup;
    
    public class Minimap extends FlxSprite{
        
        public var members:Array = [];
        public var colors:Array = [];
        
        public function Minimap(X:Number=0, Y:Number=0, w:int=100, h:int=10){
            super(X, Y);
            scrollFactor.x = scrollFactor.y = 0;
            makeGraphic(w,h,0,true);
        }
        
        public function add(member:FlxBasic, color:uint=0xFFFF0000):void{
            members.push(member);
            colors.push(color);
        }
        
        override public function draw():void{
            fill(0x55000000);
            
            for (var i:int = 0; i < members.length; i++){
                drawDot(members[i], colors[i]);
            }
            dirty = true;
            super.draw();
        }
        
        public function drawDot(m:FlxBasic, color:uint):void{
            if (m is FlxGroup){
                var group:FlxGroup = m as FlxGroup;
                for (var i:int = 0; i < group.length; i++){
                    drawDot(group.members[i], color);
                }
            }
            else if (m is FlxSprite){
                if (!m.alive){
                    return;
                }
                if (m is Wall && (m as Wall).stage == 0){
                    return;
                }
                var sprite:FlxSprite = m as FlxSprite;
                var ex:int = (sprite.x / FlxG.worldBounds.width) * this.width;
                var ey:int = (sprite.y / FlxG.worldBounds.height) * this.height;
                this.pixels.setPixel32(ex, ey, color);
            }
        }
    }
}