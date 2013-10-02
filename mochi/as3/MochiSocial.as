/**
* MochiServices
* Class that provides API access to Mochi Social Service
* @author Mochi Media
*/
package mochi.as3 {

    import flash.display.Sprite;

    public class MochiSocial {
        public static const LOGGED_IN:String = "LoggedIn";
        public static const LOGGED_OUT:String = "LoggedOut";
        public static const LOGIN_SHOW:String = "LoginShow";
        public static const LOGIN_HIDE:String = "LoginHide";
        public static const LOGIN_SHOWN:String = "LoginShown";
        public static const PROFILE_SHOW:String = "ProfileShow";
        public static const PROFILE_HIDE:String = "ProfileHide";
        public static const PROPERTIES_SAVED:String = "PropertySaved";
        public static const WIDGET_LOADED:String = "WidgetLoaded";

        public static const FRIEND_LIST:String = "FriendsList";
        public static const PROFILE_DATA:String = "ProfileData";
        public static const GAMEPLAY_DATA:String = "GameplayData";

        public static const ACTION_CANCELED:String = "onCancel";
        public static const ACTION_COMPLETE:String = "onComplete";

        // initiated with getUserInfo() call.
        // event pass object with user info.
        // {name: "name", uid: unique_identifier, profileImgURL: url_of_player_image, hasCoins: True}
        public static const USER_INFO:String = "UserInfo";

        public static const ERROR:String = "Error";
        // error types
        public static const IO_ERROR:String = "IOError";
        public static const NO_USER:String = "NoUser";
        public static const PROPERTIES_SIZE:String = "PropertiesSize"

        private static var _dispatcher:MochiEventDispatcher = new MochiEventDispatcher();
        public static var _user_info:Object = null;

        public static function getVersion():String
        {
            return MochiServices.getVersion();
        }

        public static function getAPIURL():String
        {
            if (!_user_info) return null;
            return _user_info.api_url;
        }

        public static function getAPIToken():String
        {
            if (!_user_info) return null;
            return _user_info.api_token;
        }

        // Hook default event listener behavior
        {
            MochiSocial.addEventListener( MochiSocial.LOGGED_IN, function(args:Object):void {
                _user_info = args;
            } );
            MochiSocial.addEventListener( MochiSocial.LOGGED_OUT, function(args:Object):void {
                _user_info = null;
            } );
        }

        /**
         * Method: showLoginWidget
         * Displays the MochiGames Login widget.
         * @param   options object containing variables representing the changeable parameters <see: GUI Options>
         * {x: 150, y: 10}
         */
        public static function showLoginWidget(options:Object = null):void
        {
            MochiServices.setContainer();
            MochiServices.bringToTop();
            MochiServices.send("social_showLoginWidget", { options: options });
        }

        public static function hideLoginWidget():void
        {
            MochiServices.send("social_hideLoginWidget");
        }

        public static function requestLogin(properties:Object = null):void
        {
            MochiServices.setContainer();
            MochiServices.bringToTop();
            MochiServices.send("social_requestLogin", properties);
        }

        public static function showProfile(options:Object = null):void
        {
            MochiServices.setContainer();
            MochiServices.stayOnTop();
            MochiServices.send("social_showProfile", options );
        }

        public static function saveUserProperties(properties:Object):void
        {
            MochiServices.send("social_saveUserProperties", properties);
        }

        /**
         * Method: getFriendsList
         * Asyncronously request friend graph
         * Response returned in MochiSocial.FRIEND_LIST event
         */
        public static function getFriendsList(properties:Object = null):void
        {
            MochiServices.send("social_getFriendsList",properties);
        }


        // <--- BEGIN MochiSocial experimental calls ---
        /**
         * Method: getProfileData
         * Asyncronously request mochigames user profile data (non-game specific)
         * @param   properties  Object containing user information
         * Response returned in MochiSocial.PROFILE_DATA event
         * { uid: 'user_id' }
         */
        /*
        public static function getProfileData(properties:Object = null):void
        {
            MochiServices.send("social_getProfileData", properties);
        }
        */

        /**
         * Method: getGameplayData
         * Asyncronously request mochigames user gameplay data (game specific)
         * @param   properties  Object containing user and game information
         * Response returned in MochiSocial.GAMEPLAY_DATA event
         * { uid: 'user_id', gameID: 'xxx' }
         */
        /*
        public static function getGameplayData(properties:Object = null):void
        {
            MochiServices.send("social_getGameplayData", properties);
        }
        */
        // --- END MochiSocial experimental calls --->

        /**
         * Method: postToStream
         * Post (optionally with a reward) a message to user's public stream. The stream post goes both on MochiGames as well as their other social networks.
         * Item id's must be marked as 'giftable' in your developer account.
         * Items are given as a reward only to the current player as incentive for posting about the game.
         * @param   properties  Object containing message
         * { channel: 'xxx', item: 'xxx', title: 'xxx', message: 'xxx' }
         */
        public static function postToStream(properties:Object = null):void
        {
            MochiServices.setContainer();
            MochiServices.bringToTop();
            MochiServices.send("social_postToStream", properties);
        }

        /**
         * Method: inviteFriends
         * Post (optionally with a gift) invite to friends
         * also may include prepopulated list of friends. Item id's must be marked as giftable in your developer account.
         * Each invited player and the current player will be given the gifted item.
         * @param   properties  Object containing message
         * { friends: ['xxx'], item: 'xxx', title: 'xxx', message: 'xxx' }
         */
        public static function inviteFriends(properties:Object = null):void
        {
            MochiServices.setContainer();
            MochiServices.bringToTop();
            MochiServices.send("social_inviteFriends", properties);
        }

        /**
         * Method: requestFan
         * Ask the current player to become a fan and follow your developer updates.
         * Your messages are recieved by players both through MochiGames.com and in-game via the login widget or leaderboards.
         * You can configure your update settings on mochimedia.com
         * @param   properties  Object containing message
         * { channel: 'xxx' }
         */
        public static function requestFan(properties:Object = null):void
        {
            MochiServices.setContainer();
            MochiServices.bringToTop();
            MochiServices.send("social_requestFan", properties);
        }

        // --- Callback system ----------
        public static function addEventListener( eventType:String, delegate:Function ):void
        {
            _dispatcher.addEventListener( eventType, delegate );
        }

        public static function get loggedIn():Boolean
        {
            return _user_info != null;
        }

        public static function triggerEvent( eventType:String, args:Object ):void
        {
            _dispatcher.triggerEvent( eventType, args );
        }

        public static function removeEventListener( eventType:String, delegate:Function ):void
        {
            _dispatcher.removeEventListener( eventType, delegate );
        }
    }
}
