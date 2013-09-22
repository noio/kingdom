package{
    import org.flixel.FlxObject;
    import org.flixel.FlxPoint;
    import org.flixel.FlxSprite;
    
    /** 
    * Class that provides a dummy target for FlxCamera.follow,
    * and performs tweening and following with an offset.
    */
    
    public class CameraTarget extends FlxObject{
        
        public var lead:Number = 48;
        public var speed:FlxPoint = new FlxPoint(0.1, 0.1);
        public var maxSpeed:FlxPoint = new FlxPoint(20, 20);
        public var offset:FlxPoint = new FlxPoint(0,0);

        private var _target:FlxSprite;
        private var _targetX:Number;
        private var _targetY:Number;
        
        public function CameraTarget(){
            super(0,0,1,1);
        }
        
        public function set target(object:FlxSprite):void{
            _target = object;
        }
        
        public function get target():FlxSprite{
            return _target;
        }
        
        /**
        * Snap location to target object immediatly, i.e. no tweening
        */
        public function snap():void{
            x = _target.x + _target.width/2 + offset.x;
            y = _target.y + _target.height/2 + offset.y;
        }
        
        override public function update():void{
            if (_target == null)
                return;
            // Basic target position
            _targetX = _target.x + _target.width/2 + offset.x;
            _targetY = _target.y + _target.height/2 + offset.y;
            // Incorporate the lead
            if (_target.facing == RIGHT){
                _targetX += lead;
            } else if (_target.facing == LEFT) {
                _targetX -= lead;
            } else if (_target.facing == UP) {
                _targetY -= lead;
            } else if (_target.facing == DOWN){
                _targetY += lead;
            }
            
            // Compute relative movement
            _targetX = (_targetX - x) * speed.x;
            _targetY = (_targetY - y) * speed.y;
            
            // Cap the speeds
            if (_targetX >= 1.0) {
                x += Math.min(maxSpeed.x, _targetX);
            } else if (_targetX <= -1.0){
                x += Math.max(-maxSpeed.x, _targetX);
            }
            if (_targetY >= 1.0) {
                y += Math.min(maxSpeed.y, _targetY);
            } else if (_targetY <= 1.0) {
                y += Math.max(-maxSpeed.y, _targetY);
            }
        }
        
        override public function draw():void{
        }
    }
}