package
{
    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    
    /**
     * This is an extension to flixel's standard Tileblock class. It autofills the block
     * with a given tilematrix ()
     * It can be filled with a random selection of tiles to quickly add detail.
     */
    public class FlxMatrixblock extends FlxSprite
    {
        static public const T:uint = 1;
        static public const R:uint = 2;
        static public const B:uint = 4;
        static public const L:uint = 8;
                
        public var tileWidth:int;
        public var tileHeight:int;
        public var widthInTiles:int;
        public var heightInTiles:int;
        
        public var tiles:Vector.<Vector.<Rectangle>> = new Vector.<Vector.<Rectangle>>(16)
        public var mapping:Array;
        
        public var refresh:Boolean = true; // Set to true to re-render.
        
        protected var _tileBitmap:BitmapData;
        protected var _bumpmap:BitmapData;
        
        public function FlxMatrixblock(X:int, Y:int, Width:uint, Height:uint){
            super(X,Y);
            makeGraphic(Width,Height,0xFF000000,true);
            moves = false;
        }
        
        public function loadTilematrix(MatrixGraphic:Class,TileWidth:uint,TileHeight:uint,TileSides:Array=null,BumpmapGraphic:Class=null):FlxMatrixblock{
            _tileBitmap     = FlxG.addBitmap(MatrixGraphic);
            var mWidth:int  = _tileBitmap.width / TileWidth;
            var mHeight:int = _tileBitmap.height / TileHeight;
            tileWidth       = TileWidth;
            tileHeight      = TileHeight;
            widthInTiles    = Math.floor(this.width / TileWidth);
            heightInTiles   = Math.floor(this.height / TileHeight)
            //Some default presets for tile mappings
            var i:int, j:int
            if (TileSides == null){
                // Automap, assume closed/seamless image
                var tileType:uint;
                this.mapping = []
                for (j = 0; j < mHeight; j++){
                    for (i = 0; i < mWidth; i++){
                        tileType = 0;
                        if (i > 0)         tileType += L;
                        if (i < mWidth-1)  tileType += R;
                        if (j > 0)         tileType += T;
                        if (j < mHeight-1) tileType += B;
                        this.mapping.push(tileType);
                    }
                }
            } else {this.mapping = TileSides;}
            
            // Create rectangles for each tile in the set
            for (i = 0; i < mWidth; i++){
                for (j = 0; j < mHeight; j++){
                    var m:uint = mapping[j*mWidth+i];
                    if (tiles[m] == null){
                        tiles[m] = new Vector.<Rectangle>();
                    }
                    tiles[m].push(new Rectangle(i*tileWidth,j*tileHeight,tileWidth,tileHeight));
                }
            }
            
            this.renderTiles();
            return this;
        }
        
        public function renderTiles():void{
            fill(0); // Fill with transparent color;
            var tileType:uint = 0;
            var srcRect:Rectangle;
            var tgtPoint:Point = new Point(0,0);
            var tileOpts:Vector.<Rectangle>
            for (var i:int = 0; i < widthInTiles; i ++){
                for (var j:int = 0; j < heightInTiles; j ++){
                    tileType = 0;
                    tgtPoint.x = i*tileWidth;
                    tgtPoint.y = j*tileHeight;
                    if (i > 0)               {tileType += L;}
                    if (i < widthInTiles-1)  {tileType += R};
                    if (j > 0)               {tileType += T};
                    if (j < heightInTiles-1) {tileType += B};
                    tileOpts = tiles[tileType];
                    if (tileOpts != null){
                        srcRect = tileOpts[Math.floor(FlxG.random()*tileOpts.length)];
                        _pixels.copyPixels(_tileBitmap,srcRect,tgtPoint,null,null,true);
                    }
                }
            }
            pixels = pixels;
        }
    }
}
