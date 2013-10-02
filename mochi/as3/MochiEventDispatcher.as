package mochi.as3 {
    public class MochiEventDispatcher
    {
        // Event table
        private var eventTable:Object;

        public function MochiEventDispatcher():void
        {
            eventTable = {};
        }

        public function addEventListener ( event:String, delegate:Function ):void
        {
            // Make sure we don't refire events
            removeEventListener( event, delegate );

            eventTable[event].push( delegate );
        }

        public function removeEventListener ( event:String, delegate:Function ):void
        {
            // Abort if event is not monitored
            if( eventTable[event] == undefined )
            {
                eventTable[event] = [];
                return ;
            }

            for( var s:Object in eventTable[event] )
            {
                if( eventTable[event][s] != delegate )
                    continue ;

                eventTable[event].splice(Number(s),1);
            }
        }

        public function triggerEvent ( event:String, args:Object ):void
        {
            // Abort if event is not monitored
            if( eventTable[event] == undefined )
                return ;

            for( var i:Object in eventTable[event] )
                eventTable[event][i](args);
        }
    }
}
