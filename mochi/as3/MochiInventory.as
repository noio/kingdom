/**
 *
 */
package mochi.as3
{
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.flash_proxy;
    import flash.utils.Proxy;
    import flash.utils.Timer;
    
    dynamic public class MochiInventory extends Proxy
    {
        private static const CONSUMER_KEY:String = "MochiConsumables";
        private static const KEY_SALT:String = " syncMaint\x01";

        public static const READY:String = "InvReady";
        public static const WRITTEN:String = "InvWritten";
        public static const ERROR:String = "Error";

        public static const IO_ERROR:String = "IoError";
        public static const VALUE_ERROR:String = "InvValueError";
        public static const NOT_READY:String = "InvNotReady";

        private static var _dispatcher:MochiEventDispatcher = new MochiEventDispatcher();

        private var _timer:Timer;

        // Values used to store sync information
        private var _consumableProperties:Object;   // Sync place holder
        private var _syncPending:Boolean;           // Is a revision send request pending?
        private var _outstandingID:Number;          // Last revision sent to MochiGames
        private var _syncID:Number;                 // Revision ID of _consumableProperties
        private var _names:Array;

        private var _storeSync:Object;              // used to syncronize purchased on start

        public function MochiInventory():void
        {
            MochiCoins.addEventListener( MochiCoins.ITEM_OWNED, itemOwned );
            MochiCoins.addEventListener( MochiCoins.ITEM_NEW, newItems );
            MochiSocial.addEventListener( MochiSocial.LOGGED_IN, loggedIn );
            MochiSocial.addEventListener( MochiSocial.LOGGED_OUT, loggedOut );

            _storeSync = new Object();
            _syncPending = false;
            _outstandingID = 0;
            _syncID = 0;

            // 1 Second pooled update interval
            _timer = new Timer(1000);
            _timer.addEventListener( TimerEvent.TIMER, sync );
            _timer.start();

            // Defer property snag until a login occurs
            if( MochiSocial.loggedIn )
                loggedIn();
            else
                loggedOut();
        }

        public function release():void
        {
            MochiCoins.removeEventListener( MochiCoins.ITEM_NEW, newItems );
            MochiSocial.removeEventListener( MochiSocial.LOGGED_IN, loggedIn );
            MochiSocial.removeEventListener( MochiSocial.LOGGED_OUT, loggedOut );
        }

        private function loggedOut(args:Object = null):void
        {
            _consumableProperties = null;
        }

        private function loggedIn(args:Object = null):void
        {
            MochiUserData.get( CONSUMER_KEY, getConsumableBag );
        }

        // --- Callback system ----------
        public static function addEventListener( eventType:String, delegate:Function ):void
        {
            _dispatcher.addEventListener( eventType, delegate );
        }

        public static function triggerEvent( eventType:String, args:Object ):void
        {
            _dispatcher.triggerEvent( eventType, args );
        }

        public static function removeEventListener( eventType:String, delegate:Function ):void
        {
            _dispatcher.removeEventListener( eventType, delegate );
        }

        private function newItems(event:Object):void
        {
            if( !this[event.id+KEY_SALT] )
                this[event.id+KEY_SALT] = 0;

             if( !this[event.id] )
                 this[event.id] = 0;

            this[event.id+KEY_SALT] += event.count;
            this[event.id] += event.count;

            // Do consumables!
            if( event.privateProperties && event.privateProperties.consumable )
            {
                if( !this[event.privateProperties.tag] )
                    this[event.privateProperties.tag] = 0;

                this[event.privateProperties.tag] += event.privateProperties.inc * event.count;
            }
        }

        private function itemOwned(event:Object):void
        {
            _storeSync[event.id] = {
                properties: event.properties,
                count: event.count
                };
        }

        private function getConsumableBag(userData:MochiUserData):void
        {
            if (userData.error) {
                triggerEvent( ERROR, { type:IO_ERROR, error: userData.error } );
                return;
            }

            _consumableProperties = {};
            _names = new Array();

            if( userData.data )
            {
                for( var key:String in userData.data )
                {
                    _names.push(key);
                    _consumableProperties[key] = new MochiDigits( userData.data[key] );
                }
            }

            for( key in _storeSync )
            {
                var unsynced:Number = _storeSync[key].count;

                if( _consumableProperties[key+KEY_SALT] )
                    unsynced -= _consumableProperties[key+KEY_SALT].value;

                if( unsynced == 0 )
                    continue ;

                newItems( {id: key,
                    count:unsynced,
                    properties: _storeSync[key].properties } );
            }

            triggerEvent( READY, {} );
        }

        private function putConsumableBag(userData:MochiUserData):void
        {
            _syncPending = false;

            if (userData.error) {
                triggerEvent( ERROR, { type: IO_ERROR, error: userData.error } );
                _outstandingID = -1;
            }

            triggerEvent( WRITTEN, {} );
        }

        private function sync( e:Event = null ):void
        {
            if( _syncPending || _syncID == _outstandingID )
                return ;

            _outstandingID = _syncID;
            // Push consumables through to the server
            var output:Object = {};

            for ( var key:String in _consumableProperties )
                output[key] = MochiDigits(_consumableProperties[key]).value;

            MochiUserData.put( CONSUMER_KEY, output, putConsumableBag );

            _syncPending = true;
        }

        override flash_proxy function getProperty(name:*):*
        {
            if( _consumableProperties == null )
            {
                triggerEvent( ERROR, {type:NOT_READY} );
                return -1;
            }

            if( _consumableProperties[name] )
                return MochiDigits(_consumableProperties[name]).value;
            else
                return undefined;
        }

        override flash_proxy function deleteProperty(name:*):Boolean
        {
            if ( !_consumableProperties[name] )
                return false;

            _names.splice( _names.indexOf(name), 1 );

            delete _consumableProperties[name];
            return true;
        }

        override flash_proxy function hasProperty(name:*):Boolean
        {
            if( _consumableProperties == null )
            {
                triggerEvent( ERROR, {type:NOT_READY} );
                return false;
            }

            if( _consumableProperties[name] == undefined )
                return false;

            return true;
        }

        override flash_proxy function setProperty(name:*, value:*):void
        {
            if( _consumableProperties == null )
            {
                triggerEvent( ERROR, {type:NOT_READY} );
                return ;
            }

            if( !(value is Number) )
            {
                triggerEvent( ERROR, { type:VALUE_ERROR, error:'Invalid type', arg:value } );
                return ;
            }

            if( _consumableProperties[name] )
            {
                var d:MochiDigits = MochiDigits(_consumableProperties[name])

                if( d.value == value )
                    return ;

                d.value = value;
            }
            else
            {
                _names.push(name);
                _consumableProperties[name] = new MochiDigits(value);
            }

            _syncID ++;
        }

        override flash_proxy function nextNameIndex(index:int):int
        {
            return (index >= _names.length) ? 0 : (index + 1);
        }

        override flash_proxy function nextName(index:int):String
        {
            return _names[index - 1];
        }
    }
}
