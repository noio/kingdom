package{

    import org.flixel.FlxSprite;
    import org.flixel.FlxG;
    
    public class Torch extends Light{
        
        [Embed(source='/assets/gfx/torch.png')] private var TorchImg:Class;

        [Embed(source='/assets/gfx/light_mid.png')] private var LightMidImg:Class;
        [Embed(source='/assets/gfx/light_reflect_small.png')] private var LightReflectSmallImg:Class;        
    
                
        public function Torch(X:Number, Y:Number){
            Y += 8;
            
            super(X,Y);
            
            offset.x = width/2;
            offset.y = 8;
            loadGraphic(TorchImg, true, true, 16, 32);
            beam.loadGraphic(LightMidImg);
            reflected.loadGraphic(LightReflectSmallImg);
            reflected.color = 0xFFfc8f53;
            if (FlxG.random()<0.5){
                addAnimation('on', [0,1,2,3,4,5,6,7], 6, true);
            } else {
                addAnimation('on', [8,9,10,11,12,13,14,15], 6, true);
            }
            facing = (FlxG.random() < 0.5) ? LEFT : RIGHT;
            addAnimationCallback(this.dim);
            play('on');
            setLight();
        }
        
        override public function update():void{
            if (x < playstate.kingdomRight + 64 && x > playstate.kingdomLeft - 64){
                visible = true;
            } else {
                visible = false;
            }
            super.update()
        }
    }
}