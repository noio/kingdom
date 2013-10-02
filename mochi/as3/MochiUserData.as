/**
* MochiUserData
* Connection class for all Mochi User Data Services
* @author Mochi Media
*
* This class is EXPERIMENTAL!
*
*/

package mochi.as3 {
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.ObjectEncoding;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.EventDispatcher;
    import flash.events.SecurityErrorEvent;
    import mochi.as3.Base64Encoder;
    import mochi.as3.Base64Decoder;

    public class MochiUserData extends EventDispatcher {
        public var _loader:URLLoader;
        public var key:String = null;
        public var data:* = null;
        public var error:Event = null;
        public var operation:String = null;
        public var callback:Function = null;
        public var userid:String = null;
        public var isError:Boolean = false;
        public var errorCode:String = null;

        private var enc:Base64Encoder = new Base64Encoder();
        private var dec:Base64Decoder = new Base64Decoder();

        private static var MAX_USER_ID_LENGTH:Number = 36;
        private static var MAX_KEY_LENGTH:Number = 20;
        private static var ERROR_CALLBACK_TIMEOUT:Number = 100;

        public function MochiUserData(key:String = "", callback:Function = null, userid:String = "") {
            this.key = key;
            this.callback = callback;
            this.userid = userid;
        }

        public function serialize(obj:*):ByteArray {
            var arr:ByteArray = new ByteArray();
            arr.objectEncoding = ObjectEncoding.AMF3;
            arr.writeObject(obj);
            arr.compress();
            return arr;
        }

        public function deserialize(arr:ByteArray):* {
            arr.objectEncoding = ObjectEncoding.AMF3;
            arr.uncompress();
            return arr.readObject();
        }

        public function base64encode(arr:ByteArray):String {
            enc.encodeBytes(arr);
            return enc.drain().split("\n").join("");
        }

        public function base64decode(str:String):ByteArray {
            dec.decode(str);
            return dec.toByteArray();
        }

        public function request(_operation:String, _data:ByteArray):void {
            operation = _operation;

            var api_url:String = MochiSocial.getAPIURL();
            var api_token:String = MochiSocial.getAPIToken();
            if (api_url == null || api_token == null) {
                errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "not logged in"));
                return;
            }

            _loader = new URLLoader();
            var args:URLVariables = new URLVariables();
            args.op = _operation;
            args.key = key;
            var req:URLRequest = new URLRequest(MochiSocial.getAPIURL() + "/" + "MochiUserData?" + args.toString());
            req.method = URLRequestMethod.POST;
            req.contentType = "application/x-mochi-userdata";
            req.requestHeaders = [
                new URLRequestHeader("x-mochi-services-version", MochiServices.getVersion()),
                new URLRequestHeader("x-mochi-api-token", api_token)
            ];
            req.data = _data;

            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.addEventListener(Event.COMPLETE, completeHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            try {
                _loader.load(req);
            } catch (e:SecurityError) {
                errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "security error: " + e.toString()));
            }
        }

        public function completeHandler(event:Event):void {
            try {
                if (_loader.data.length) {
                    data = deserialize(_loader.data);
                } else {
                    data = null;
                }
            } catch (e:Error) {
                errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "deserialize error: " + e.toString()));
                return;
            }
            if (callback != null) {
                performCallback();
            } else {
                dispatchEvent(event);
            }
            close();
        }

        public function errorHandler(event:IOErrorEvent):void {
            data = null;
            error = event;
            if (callback != null) {
                performCallback();
            } else {
                dispatchEvent(event);
            }
            close();
        }

        public function securityErrorHandler(event:SecurityErrorEvent):void {
            errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "security error: " + event.toString()));
        }

        public function performCallback():void {
            try {
                callback(this);
            } catch (e:Error) {
                trace("[MochiUserData] exception during callback: " + e);
            }
        }

        public function close():void {
            if (_loader) {
                _loader.removeEventListener(Event.COMPLETE, completeHandler);
                _loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
                _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                _loader.close();
                _loader = null;
            }
            error = null;
            callback = null;
        }

        public function getEvent():void {
            request("get", serialize(null));
        }

        public function putEvent(obj:*):void {
            request("put", serialize(obj));
        }

        public override function toString():String {
            return "[MochiUserData operation=" + operation + " key=\"" + key + "\" data=" + data + " error=\"" + error + "\"]";
        }

        public static function get(key:String, callback:Function):void {
            var userData:MochiUserData = new MochiUserData(key, callback);
            userData.getEvent();
        }

        public static function put(key:String, obj:*, callback:Function):void {
            var userData:MochiUserData = new MochiUserData(key, callback);
            userData.putEvent(obj);
        }

        public function onDataGet(obj:Object):void {
            if (obj.error) {
                this.isError = obj.error;
                this.errorCode = obj.errorCode;
            } else {
                var arr:ByteArray = base64decode(obj.data);
                this.data = deserialize(arr);
            }

            if (callback != null) {
                performCallback();
            }
        }

        public function onDataPut(obj:Object):void {
            if (obj.error) {
                this.isError = obj.error;
                this.errorCode = obj.errorCode;
            }

            if (callback != null) {
                performCallback();
            }
        }

        public static function getData(userid:String, key:String, callback:Function):void {
            var userData:MochiUserData = new MochiUserData(key, callback, userid);
            if (userid.length > MAX_USER_ID_LENGTH || key.length > MAX_KEY_LENGTH) {
                userData.isError = true;
                userData.errorCode = "userid or key is too long";
                setTimeout(userData.performCallback, ERROR_CALLBACK_TIMEOUT)
                return;
            }
            userData.operation = "get";
            var o:Object = {
                key: userid + "_" + key
                }
            MochiServices.send("userData_getUserData", o, userData, "onDataGet");
        }

        public static function putData(userid:String, key:String, obj:*, callback:Function):void {
            var userData:MochiUserData = new MochiUserData(key, callback, userid);
            if (userid.length > MAX_USER_ID_LENGTH || key.length > MAX_KEY_LENGTH) {
                userData.isError = true;
                userData.errorCode = "userid or key is too long";
                setTimeout(userData.performCallback, ERROR_CALLBACK_TIMEOUT)
                return;
            }
            userData.operation = "put";
            var arr:ByteArray = userData.serialize(obj);

            var o:Object = {
                key: userid + "_" + key,
                data: userData.base64encode(arr)
                }
            MochiServices.send("userData_putUserData", o, userData, "onDataPut");
        }

    }
}
