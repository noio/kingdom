/**
* MochiSscores
* Class that provides API access to MochiAds Scores Service
* @author Mochi Media
*/

package mochi.as3 {

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.text.TextField;

    import mochi.as3.*;

    public class MochiScores {

        public static function onClose (args:Object = null):void {
            if (args && args.error == true && onErrorHandler) {
                if (args.errorCode == null) args.errorCode = "IOError";
                onErrorHandler(args.errorCode);
                MochiServices.doClose();
                return;
            }
            onCloseHandler();
            MochiServices.doClose();
        }

        public static var onCloseHandler:Object;
        public static var onErrorHandler:Object;
        private static var boardID:String;

        /**
         * Method: setBoardID
         * Sets the name of the mode to use for categorizing submitted and displayed scores.  The board ID is assigned in the online interface.
         * @param   boardID: The unique string name of the mode
         */
        public static function setBoardID (boardID:String):void {
            MochiServices.warnID( boardID, true );
            MochiScores.boardID = boardID; MochiServices.send("scores_setBoardID", { boardID: boardID } );
        };


        /**
         * Method: showLeaderBoard
         * Displays the leaderboard GUI showing the current top scores.  The callback event is triggered when the leaderboard is closed.
         * @param   options object containing variables representing the changeable parameters <see: GUI Options>
         */
        public static function showLeaderboard (options:Object = null):void {
            if (options != null) {

                delete options.clip;

                MochiServices.setContainer();

                //MochiServices.stayOnTop();
                MochiServices.bringToTop();

                if (options.name != null) {
                    if (options.name is TextField) {
                        if (options.name.text.length > 0) {
                            options.name = options.name.text;
                        }
                    }
                }

                if (options.score != null) {
                    if (options.score is TextField) {
                        if (options.score.text.length > 0) {
                            options.score = options.score.text;
                        }
                    }
                    else if (options.score is MochiDigits)
                    {
                        options.score = options.score.value;
                    }

                    var n:Number = Number(options.score);
                    // check if score is a numeric value
                    if( isNaN(n) ) {
                        trace( "ERROR: Submitted score '" + options.score + "' will be rejected, score is 'Not a Number'" );
                    }
                    else if( n == Number.NEGATIVE_INFINITY || n == Number.POSITIVE_INFINITY ) {
                        trace( "ERROR: Submitted score '" + options.score + "' will be rejected, score is an infinite" );
                    }
                    else {
                        if( Math.floor(n) != n )
                            trace( "WARNING: Submitted score '" + options.score + "' will be truncated" );

                        options.score = n;
                    }
                }

                if (options.onDisplay != null) {
                    options.onDisplay();
                } else {
                    if (MochiServices.clip != null) {
                        if (MochiServices.clip is MovieClip) {
                            MochiServices.clip.stop();
                        } else {
                            trace("Warning: Container is not a MovieClip, cannot call default onDisplay.");
                        }
                    }
                }
            } else {
                options = { };
                if (MochiServices.clip is MovieClip) {
                    MochiServices.clip.stop();
                } else {
                    trace("Warning: Container is not a MovieClip, cannot call default onDisplay.");
                }
            }

            if (options.onClose != null) {
                onCloseHandler = options.onClose;
            } else {
                onCloseHandler = function ():void {
                    if (MochiServices.clip is MovieClip) {
                        MochiServices.clip.play();
                    } else {
                        trace("Warning: Container is not a MovieClip, cannot call default onClose.");
                    }
                }
            }

            if (options.onError != null) {
                onErrorHandler = options.onError;
            } else {
                onErrorHandler = null;
            }

            if (options.boardID == null) {
                if (MochiScores.boardID != null) {
                    options.boardID = MochiScores.boardID;
                }
            }
            MochiServices.warnID( options.boardID, true );

            trace("[MochiScores] NOTE: Security Sandbox Violation errors below are normal");
            MochiServices.send("scores_showLeaderboard", { options: options }, null, onClose );

        }

        /**
         * Method: closeLeaderboard
         * Closes the leaderboard immediately
         */
        public static function closeLeaderboard ():void { MochiServices.send("scores_closeLeaderboard"); }


        /**
         * Method: getPlayerInfo
         * Retrieves all persistent player data that has been saved in a SharedObject. Will send to the callback an object containing key->value pairs contained in the player cookie.
         */
        public static function getPlayerInfo (callbackObj:Object, callbackMethod:Object = null):void { MochiServices.send("scores_getPlayerInfo", null, callbackObj, callbackMethod); }


        /**
         * Method: submit
         * Submits a score to the server using the current id and mode.
         * @param   name - the string name of the user as entered or defined by MochiBridge.
         * @param   score - the number representing a score.  Can be an integer or float.  If the score is time, send it in seconds - can be float
         * @param   callbackObj - the object or class instance containing the callback method
         * @param   callbackMethod - the string name of the method to call when the score has been sent
         */
        public static function submit (score:Number, name:String, callbackObj:Object = null, callbackMethod:Object = null):void
        {
            score = Number(score);

            // check if score is a numeric value
            if( isNaN(score) ) {
                trace( "ERROR: Submitted score '" + String(score) + "' will be rejected, score is 'Not a Number'" );
            }
            else if( score == Number.NEGATIVE_INFINITY || score == Number.POSITIVE_INFINITY ) {
                trace( "ERROR: Submitted score '" + String(score) + "' will be rejected, score is an infinite" );
            }
            else {
                if( Math.floor(score) != score )
                    trace( "WARNING: Submitted score '" + String(score) + "' will be truncated" );
                score = Number(score);
            }

            MochiServices.send("scores_submit", {score: score, name: name}, callbackObj, callbackMethod);
        };


        /**
         * Method: requestList
         * Requests a listing from the server using the current game id and mode. Returns an array of at most 50 score objects. Will send to the callback an array of objects [{name, score, timestamp}, ...]
         * @param   callbackObj the object or class instance containing the callback method
         * @param   callbackMethod the string name of the method to call when the score has been sent. default: "onLoad"
         */
        public static function requestList (callbackObj:Object, callbackMethod:Object = null):void { MochiServices.send("scores_requestList", null, callbackObj, callbackMethod); }


        /**
         * Method: scoresArrayToObjects
         * Converts the cols/rows array format retrieved from the server into an array of objects - one object for each row containing key-value pairs.
         * @param   scores the scores object received from the server
         * @return
         */
        public static function scoresArrayToObjects (scores:Object):Object {

            var so:Object = { };
            var i:Number;
            var j:Number;
            var o:Object;
            var row_obj:Object;

            for (var item:String in scores) {

                if (typeof(scores[item]) == "object") {

                    if (scores[item].cols != null && scores[item].rows != null) {

                        so[item] = [ ];

                        o = scores[item];

                        for (j = 0; j < o.rows.length; j++) {
                            row_obj = { };
                            for (i = 0; i < o.cols.length; i++) {
                                row_obj[o.cols[i]] = o.rows[j][i];
                            }
                            so[item].push(row_obj);
                        }

                    } else {

                        so[item] = { };
                        for (var param:String in scores[item]) {
                            so[item][param] = scores[item][param];
                        }

                    }

                } else {

                    so[item] = scores[item];

                }

            }

            return so;

        }

    }

}
