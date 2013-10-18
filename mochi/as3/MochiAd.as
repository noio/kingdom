/*
    Mochi Ads ActionScript 3 code

    Flash movies should be published for Flash 9 or later.

    Copyright (C) 2006-2009 Mochi Media, Inc. All rights reserved.
*/

package mochi.as3 {
    import flash.system.Security;
    import flash.display.MovieClip;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.AsyncErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.net.LocalConnection;
    import flash.utils.getTimer;
    import flash.utils.setTimeout;

    public class MochiAd {

        public static var load_options:Object;

        private static var PROD_SERVER:String = "http://x.mochiads.com/";
        private static var CDN_SERVER:String  = "http://xs.mochiads.com/";


        private static var _srv1_loader:Loader;

        public static function getVersion():String {
            return MochiServices.getVersion();
        }

        public static function doOnEnterFrame(mc:MovieClip):void {
            var f:Function = function (ev:Object):void {
                if ('onEnterFrame' in mc && mc.onEnterFrame) {
                    mc.onEnterFrame();
                } else {
                    ev.target.removeEventListener(ev.type, arguments.callee);
                }

            }
            mc.addEventListener(Event.ENTER_FRAME, f);
        }

        public static function createEmptyMovieClip(parent:Object, name:String, depth:Number):MovieClip {
            var mc:MovieClip = new MovieClip();
            if (false && depth) {
                parent.addChildAt(mc, depth);
            } else {
                parent.addChild(mc);
            }
            parent[name] = mc;
            mc["_name"] = name;
            return mc;
        }

        public static function showPreGameAd(options:Object):void {
            /*
                This function will stop the clip, load the Mochi Ad in a
                centered position on the clip, and then resume the clip
                after a timeout or when this movie is loaded, whichever
                comes first.

                options:
                    An object with keys and values to pass to the server.
                    These options will be passed to MochiAd.load, but the
                    following options are unique to showPreGameAd.

                    clip is a MovieClip reference to place the ad in.
                    clip must be dynamic.

                    color is the color of the preloader bar
                    as a number (default: 0xFF8A00)

                    background is the inside color of the preloader
                    bar as a number (default: 0xFFFFC9)

                    no_bg disables the background entirely when set to true
                    (default: false)

                    outline is the outline color of the preloader
                    bar as a number (default: 0xD58B3C)

                    no_progress_bar disables the ad's preload/progress bar when set to true
                    (default: false)

                    skip disables the loading of a pre-game ad entirely but
                    will still behave as a preloader for your game. Great for testing.
                    (default: false)

                    fadeout_time is the number of milliseconds to
                    fade out the ad upon completion (default: 250).

                    ad_started is the function to call when the ad
                    has started (may not get called if network down)
                    (default: function ():void { this.clip.stop() }).

                    ad_finished is the function to call when the ad
                    has finished or could not load
                    (default: function ():void { this.clip.play() }).

                    ad_failed is called if an ad can not be displayed,
                    this is usually due to the user having ad blocking
                    software installed or issues with retrieving the ad
                    over the network. If it is called, then it is called
                    before ad_finished.
                    (default: function ():void { }).

                    ad_loaded is called just before an ad is displayed
                    with the width and height of the ad. If it is called,
                    it is called after ad_started.
                    (default: function(width:Number, height:Number):void { }).

                    ad_skipped is called if the ad was skipped, this is
                    usually due to frequency capping, or developer initiated
                    domain filtering.  If it is called, then it is called
                    before ad_finished.
                    (default: function():void { }).

                    ad_progress is called with the progress of the ad.  The
                    progress is the percent (represented from 0 to 100) of the
                    ad show time or loading time for the host swf, whichever is more.
                    (default: function(percent:Number):void { }).
            */
            var DEFAULTS:Object = {
                ad_timeout: 5500,
                fadeout_time: 250,
                regpt: "o",
                method: "showPreloaderAd",
                color: 0xFF8A00,
                background: 0xFFFFC9,
                outline: 0xD58B3C,
                no_progress_bar: false,
                ad_started: function ():void {
                    if (this.clip is MovieClip) {
                        this.clip.stop();
                    } else {
                        throw new Error("MochiAd.showPreGameAd requires a clip that is a MovieClip or is an instance of a class that extends MovieClip.  If your clip is a Sprite, then you must provide custom ad_started and ad_finished handlers.");
                    }
                },
                ad_finished: function ():void {
                    if (this.clip is MovieClip) {
                        this.clip.play();
                    } else {
                        throw new Error("MochiAd.showPreGameAd requires a clip that is a MovieClip or is an instance of a class that extends MovieClip.  If your clip is a Sprite, then you must provide custom ad_started and ad_finished handlers.");
                    }
                },
                ad_loaded: function (width:Number, height:Number):void { },
                ad_failed: function ():void {
                    trace("[MochiAd] Couldn't load an ad, make sure your game's local security sandbox is configured for Access Network Only and that you are not using ad blocking software"); },
                ad_skipped: function ():void { },
                ad_progress: function (percent:Number):void { },
                progress_override: function (_clip:Object):Number { return NaN; },
                bar_offset: 0
            };

            options = MochiAd._parseOptions(options, DEFAULTS);

            if ("c862232051e0a94e1c3609b3916ddb17".substr(0) == "dfeada81ac97cde83665f81c12da7def") {
                options.ad_started();
                var fn:Function = function ():void {
                    options.ad_finished();
                };
                setTimeout(fn, 100);
                return;
            }

            var clip:Object = options.clip;
            var ad_msec:Number = 11000;
            var ad_timeout:Number = options.ad_timeout;
            if (options.skip) {
                ad_timeout = 0;
            }
            delete options.ad_timeout;
            var fadeout_time:Number = options.fadeout_time;
            delete options.fadeout_time;


            /* Load targeting under clip._mochiad */
            if (!MochiAd.load(options)) {
                options.ad_failed();
                options.ad_finished();
                return;
            }

            options.ad_started();

            var mc:MovieClip = clip._mochiad;
            mc["onUnload"] = function ():void {
                MochiAd._cleanup(mc);
                var fn:Function = function ():void {
                    options.ad_finished();
                };
                setTimeout(fn, 100);
            }

            /* Center the clip */
            var wh:Array = MochiAd._getRes(options, clip);

            var w:Number = wh[0];
            var h:Number = wh[1];
            mc.x = w * 0.5;
            mc.y = h * 0.5;

            var chk:MovieClip = createEmptyMovieClip(mc, "_mochiad_wait", 3);
            chk.x = w * -0.5;
            chk.y = h * -0.5;

            var bar:MovieClip = createEmptyMovieClip(chk, "_mochiad_bar", 4);
            if (options.no_progress_bar) {
                bar.visible = false;
                delete options.no_progress_bar;
            } else {
                bar.x = 10 + options.bar_offset;
                bar.y = h - 20;
            }
            var bar_w:Number = w - bar.x - 10;

            var bar_color:Number = options.color;
            delete options.color;
            var bar_background:Number = options.background;
            delete options.background;
            var bar_outline:Number = options.outline;
            delete options.outline;

            var backing_mc:MovieClip = createEmptyMovieClip(bar, "_outline", 1);
            var backing:Object = backing_mc.graphics;

            backing.beginFill(bar_background);
            backing.moveTo(0, 0);
            backing.lineTo(bar_w, 0);
            backing.lineTo(bar_w, 10);
            backing.lineTo(0, 10);
            backing.lineTo(0, 0);
            backing.endFill();

            var inside_mc:MovieClip = createEmptyMovieClip(bar, "_inside", 2);
            var inside:Object = inside_mc.graphics;
            inside.beginFill(bar_color);
            inside.moveTo(0, 0);
            inside.lineTo(bar_w, 0);
            inside.lineTo(bar_w, 10);
            inside.lineTo(0, 10);
            inside.lineTo(0, 0);
            inside.endFill();
            inside_mc.scaleX = 0;

            var outline_mc:MovieClip = createEmptyMovieClip(bar, "_outline", 3);
            var outline:Object = outline_mc.graphics;
            outline.lineStyle(0, bar_outline, 100);
            outline.moveTo(0, 0);
            outline.lineTo(bar_w, 0);
            outline.lineTo(bar_w, 10);
            outline.lineTo(0, 10);
            outline.lineTo(0, 0);

            chk.ad_msec = ad_msec;
            chk.ad_timeout = ad_timeout;
            chk.started = getTimer();
            chk.showing = false;
            chk.last_pcnt = 0.0;
            chk.fadeout_time = fadeout_time;

            chk.fadeFunction = function ():void {
                var p:Number = 100 * (1 -
                    ((getTimer() - this.fadeout_start) / this.fadeout_time));
                if (p > 0) {
                    this.parent.alpha = p * 0.01;
                } else {
                    MochiAd.unload(clip);
                    delete this["onEnterFrame"];
                }
            };

            var complete:Boolean = false;
            var unloaded:Boolean = false;
            var progress:Number = Math.min(1, options.progress_override(clip));

            var f:Function = function(ev:Event):void {
                ev.target.removeEventListener(ev.type, arguments.callee);
                complete = true;
                if (unloaded) {
                    MochiAd.unload(clip);
                }
            };

            if (!isNaN(progress)) {
                complete = (progress == 1);
            } else if (clip.loaderInfo.bytesLoaded == clip.loaderInfo.bytesTotal) {
                complete = true;
            } else if (clip.root is MovieClip) {
                var r:MovieClip = clip.root as MovieClip;

                if (r.framesLoaded >= r.totalFrames) {
                    complete = true;
                } else {
                    clip.loaderInfo.addEventListener(Event.COMPLETE, f);
                }
            } else {
                clip.loaderInfo.addEventListener(Event.COMPLETE, f);
            }

            mc.unloadAd = function ():void {
                unloaded = true;
                if (complete) {
                    MochiAd.unload(clip);
                }
            }

            mc.adLoaded = options.ad_loaded;
            mc.adSkipped = options.ad_skipped;
            mc.adjustProgress = function (msec:Number):void {
                var _chk:Object = mc._mochiad_wait;
                _chk.server_control = true;
                _chk.showing = true;
                _chk.started = getTimer();
                _chk.ad_msec = msec;
            };
            mc.rpc = function (callbackID:Number, arg:Object):void {
                MochiAd.rpc(clip, callbackID, arg);
            };
            // Only used for container RPC method call testing
            mc.rpcTestFn = function(s:String):Object {
                trace('[MOCHIAD rpcTestFn] ' + s);
                return s;
            };

            /* Container will call so we can start sending host loading progress */
            var sendHostProgress:Boolean = false;
            mc.sendHostLoadProgress = function (lc_name:String):void {
                sendHostProgress = true;
            };

            chk["onEnterFrame"] = function ():void {
                if (!this.parent || !this.parent.parent) {
                    delete this["onEnterFrame"];
                    return;
                }
                var _clip:Object = this.parent.parent.root;
                var ad_clip:Object = this.parent._mochiad_ctr;
                var elapsed:Number = getTimer() - this.started;
                var finished:Boolean = false;
                var clip_total:Number = _clip.loaderInfo.bytesTotal;
                var clip_loaded:Number = _clip.loaderInfo.bytesLoaded;
                var clip_progress:Number = Math.min(1, options.progress_override(_clip));
                if (clip_progress == 1) {
                    complete = true;
                }
                if (complete) {
                    clip_loaded = Math.max(1, clip_loaded);
                    clip_total = clip_loaded;
                }
                var clip_pcnt:Number = (100.0 * clip_loaded) / clip_total;
                if (!isNaN(clip_progress)) {
                    clip_pcnt = 100.0 * clip_progress;
                }
                var ad_pcnt:Number = (100.0 * elapsed) / chk.ad_msec;
                var _inside:Object = this._mochiad_bar._inside;
                var pcnt:Number = Math.min(100.0, Math.min((clip_pcnt || 0.0), ad_pcnt));
                pcnt = Math.max(this.last_pcnt, pcnt);
                this.last_pcnt = pcnt;
                _inside.scaleX = pcnt * 0.01;

                options.ad_progress(pcnt);

                /* Send to our targetting SWF percent of host loaded.
                   This is so we can notify the AD SWF when we're loaded.
                */
                if (sendHostProgress) {
                    clip._mochiad.lc.send(clip._mochiad._containerLCName, 'notify', {id: 'hostLoadPcnt', pcnt: clip_pcnt});
                    if (clip_pcnt >= 100) {
                        sendHostProgress = false;
                    }
                }

                if (!chk.showing) {
                    var total:Number = this.parent._mochiad_ctr.contentLoaderInfo.bytesTotal;

                    if (total > 0) {
                        // ad is now showing
                        chk.showing = true;
                        chk.started = getTimer();
                        MochiAd.adShowing(clip);
                    } else if (elapsed > chk.ad_timeout && clip_pcnt == 100) {
                        // ad failed to show - ad_timeout and game is loaded
                        options.ad_failed();
                        finished = true;
                    }
                }

                if (elapsed > chk.ad_msec) {
                    finished = true;
                }

                if (complete && finished) {
                    if (unloaded) {
                        MochiAd.unload(_clip);
                    } else if (this.server_control) {
                        delete this.onEnterFrame;
                    } else {
                        this.fadeout_start = getTimer();
                        this.onEnterFrame = chk.fadeFunction;
                    }
                }
            };
            doOnEnterFrame(chk);
        }


        public static function showClickAwayAd(options:Object):void {
            /*
                This function will load a Mochi Ad in the upper left position on the clip.
                This ad will remain there until unload() is called.

                options:
                    An object with keys and values to pass to the server.
                    These options will be passed to MochiAd.load, but the
                    following options are unique to showClickAwayAd.

                    clip is a MovieClip reference to place the ad in.

                    ad_started is the function to call when the ad
                    has started (may not get called if network down)
                    (default: function ():void { this.clip.stop() }).

                    ad_finished is the function to call when the ad
                    has finished or could not load
                    (default: function ():void { this.clip.play() }).

                    ad_failed is called if an ad can not be displayed,
                    this is usually due to the user having ad blocking
                    software installed or issues with retrieving the ad
                    over the network. If it is called, then it is called
                    before ad_finished.
                    (default: function ():void { }).

                    ad_loaded is called just before an ad is displayed
                    with the width and height of the ad. If it is called,
                    it is called after ad_started.
                    (default: function(width:Number, height:Number):void { }).

                    ad_skipped is called if the ad was skipped, this is
                    usually due to frequency capping, or developer initiated
                    domain filtering.  If it is called, then it is called
                    before ad_finished.
                    (default: function():void { })
            */
            var DEFAULTS:Object = {
                ad_timeout: 5500,
                regpt: "o",
                method: "showClickAwayAd",
                res: "300x250",
                no_bg: true,
                ad_started: function ():void { },
                ad_finished: function ():void { },
                ad_loaded: function (width:Number, height:Number):void { },
                ad_failed: function ():void { trace("[MochiAd] Couldn't load an ad, make sure your game's local security sandbox is configured for Access Network Only and that you are not using ad blocking software"); },
                ad_skipped: function ():void { }

            };
            options = MochiAd._parseOptions(options, DEFAULTS);

            var clip:Object = options.clip;
            var ad_timeout:Number = options.ad_timeout;
            delete options.ad_timeout;

            /* Load targeting under clip._mochiad */
            if (!MochiAd.load(options)) {
                options.ad_failed();
                options.ad_finished();
                return;
            }

            options.ad_started();

            var mc:MovieClip = clip._mochiad;
            mc["onUnload"] = function ():void {
                MochiAd._cleanup(mc);
                options.ad_finished();
            }

            /* Peg the 300x250 ad to the upper left of the MC */
            var wh:Array = MochiAd._getRes(options, clip);

            var w:Number = wh[0];
            var h:Number = wh[1];
            mc.x = w * 0.5;
            mc.y = h * 0.5;

            var chk:MovieClip = createEmptyMovieClip(mc, "_mochiad_wait", 3);
            chk.ad_timeout = ad_timeout;
            chk.started = getTimer();
            chk.showing = false;

            mc.unloadAd = function ():void {
                MochiAd.unload(clip);
            }

            mc.adLoaded = options.ad_loaded;
            mc.adSkipped = options.ad_skipped;
            mc.rpc = function (callbackID:Number, arg:Object):void {
                MochiAd.rpc(clip, callbackID, arg);
            };

            chk["onEnterFrame"] = function ():void {
                if (!this.parent) {
                    delete this.onEnterFrame;
                    return;
                }
                var ad_clip:Object = this.parent._mochiad_ctr;
                var elapsed:Number = getTimer() - this.started;
                var finished:Boolean = false;

                if (!chk.showing) {
                    var total:Number = this.parent._mochiad_ctr.contentLoaderInfo.bytesTotal;
                    if (total > 0) {
                        // ad is now showing
                        chk.showing = true;
                        finished = true;
                        chk.started = getTimer();
                    } else if (elapsed > chk.ad_timeout) {
                        // ad failed to show - ad_timeout and game is loaded
                        options.ad_failed();
                        finished = true;
                    }
                }

                /* Poll to see if we're not being displayed anymore */
                if (this.root == null) {
                    finished = true;
                }

                /* Ad is showing, remove this function */
                if (finished) {
                    delete this.onEnterFrame;
                }
            };
            doOnEnterFrame(chk);
        }


        public static function loadDock(options:Object):void {
            /*
                This function will load a Mochi Dock Ad into the clip.
                The Dock will load a number of small, static ads
                into an "auto-hide" dock on one edge of the game window.
                The Dock is initially visible for a short time after
                loading. It will slide off screen until invoked by the user
                mousing over a small tab which will remain
                visible in the game area.

                To completly hide the Dock, including the mouse-over tab, call
                MochiAds.closeAdGroup(clip) where clip is the same MovieClip in the options parameter above.

                The location and orientation of the Dock can be selected to
                keep it away from the gameplay area where the mouse is most active.
                Location and orientation are parsed from a 'position' property on
                the 'options' object. The available options for the value of 'position'
                are:

                "top":          A horizontal dock will be centered on the top edge.
                "bottom":       A horizontal dock will be centered on the bottom edge.
                "left":         A vertical dock will be centered on the left edge.
                "right":        A vertical dock will be centered on the right edge.
                "top_left":     A horizontal dock will be located at the left end of the top edge. .
                "top_right":    A horizontal dock will be located at the right end of the top edge.
                "bottom_left":  A horizontal dock will be located at the left end of the bottom edge. .
                "bottom_right": A horizontal dock will be located at the right end of the bottom edge.
                "left_top":     A vertical dock will be located at the top of the left edge.
                "left_bottom":  A vertical dock will be located at the bottom of the left edge.
                "right_top":    A vertical dock will be located at the top of the right edge.
                "right_bottom": A vertical dock will be located at the bottom of the right edge.

                options:
                    An object with keys and values to pass to the server.
                    These options will be passed to MochiAd.load, but the
                    following options are unique to loadDock.

                    clip is a MovieClip reference to place the ad in.

                    ad_failed is called if an ad can not be displayed,
                    this is usually due to the user having ad blocking
                    software installed or issues with retrieving the ad
                    over the network.
                    (default: function ():void { }).

                    ad_opened is called with the width and height of the dock just before
                    the dock slides open. This will occur once, automatically right after
                    the dock is loaded. Thereafter it will be called only when the user
                    opens a "hidden" dock by a mouse-over action. Or after the dock is opened
                    by an API call.
                    (default: function(width:Number, height:Number):void { }).


                    ad_closed is called when the dock auto-hides after the user moves
                    the mouse away from the dock area, or when it is closed by an API call.
                    (default: function():void { }).

                    ad_skipped is called if the ad was skipped, this is
                    usually due to frequency capping, or developer initiated
                    domain filtering.  If it is called, then it is called
                    before any dock_opened call.
                    (default: function():void { })
            */

            var clip:Object = options.clip;
            if (clip.stage == null){
                trace("[MochiAd] clip must be on stage before calling ad method");
            }
            var DEFAULTS:Object = {
                position:"bottom",
                regpt: "o",
                method: "showDock",
                ad_count:5,
                ad_loaded: function (width:Number, height:Number):void { },
                ad_opened: function (width:Number, height:Number):void { },
                ad_closed: function ():void { },
                ad_failed: function ():void { trace("[MochiAd] Couldn't load an ad, make sure your game's local security sandbox is configured for Access Network Only and that you are not using ad blocking software"); },
                ad_finished: function ():void { },
                ad_skipped: function ():void { }

            };
            options = MochiAd._parseOptions(options, DEFAULTS);

            /* Load targeting under clip._mochiad */
            if (!MochiAd.load(options)) {
                options.ad_failed();
                return;
            }

            var mc:MovieClip = clip._mochiad;
            mc["onUnload"] = function ():void {
                MochiAd._cleanup(mc);
                options.ad_finished();
            }

            mc.unloadAd = function ():void {
                MochiAd.unload(clip);
            }


            mc.adLoaded = options.ad_loaded;
            mc.adSkipped = options.ad_skipped;
            mc.rpc = function (callbackID:Number, arg:Object):void {
                MochiAd.rpc(clip, callbackID, arg);
            };

        }

        public static function loadShowcase(options:Object):void {
            /*
                This function will load a Mochi Showcase Ad into the clip.
                The Showcase loads a number of small, static ads
                into a static bar of thumbnails, and by default centers it in the game area with an optional 'close' button.
                options:
                    An object with keys and values to pass to the server.
                    These options will be passed to MochiAd.load, but the
                    following options are unique to loadShowcase.

                    clip is a MovieClip reference to place the ad in. Its x and y values should be 0.

                    ad_failed is called if an ad can not be displayed,
                    this is usually due to the user having ad blocking
                    software installed or issues with retrieving the ad
                    over the network.
                    (default: function ():void { }).

                    ad_closed is called when the showcase close button is clicked and ad is removed.
                    (default: function():void { }).

                    ad_skipped is called if the ad was skipped, this is
                    usually due to frequency capping, or developer initiated
                    domain filtering.  If it is called, then it is called
                    before any aother call.
                    (default: function():void { })
            */

            var clip:Object = options.clip;
            if (clip.stage == null){
                trace("[MochiAd] clip must be on stage before calling ad method");
            }

            var DEFAULTS:Object = {
                regpt: "o",
                method: "showCase",
                ad_count:5,
                ad_loaded: function (width:Number, height:Number):void { },
                ad_opened: function ():void { },
                ad_closed: function ():void { },
                ad_failed: function ():void { trace("[MochiAd] Couldn't load an ad, make sure your game's local security sandbox is configured for Access Network Only and that you are not using ad blocking software"); },
                ad_finished: function ():void { },
                ad_skipped: function ():void { }

            };
            options = MochiAd._parseOptions(options, DEFAULTS);

            /* Load targeting under clip._mochiad */
            if (!MochiAd.load(options)) {
                options.ad_failed();
                return;
            }

            var mc:MovieClip = clip._mochiad;
            mc["onUnload"] = function ():void {
                MochiAd._cleanup(mc);
                options.ad_finished();
            }

            mc.unloadAd = function ():void {
                MochiAd.unload(clip);
            }

            mc.adLoaded = options.ad_loaded;
            mc.adSkipped = options.ad_skipped;
            mc.rpc = function (callbackID:Number, arg:Object):void {
                MochiAd.rpc(clip, callbackID, arg);
            };

        }


        public static function showInterLevelAd(options:Object):void {
            /*
                This function will stop the clip, load the Mochi Ad in a
                centered position on the clip, and then resume the clip
                after a timeout.

                options:
                    An object with keys and values to pass to the server.
                    These options will be passed to MochiAd.load, but the
                    following options are unique to showInterLevelAd.

                    clip is a MovieClip reference to place the ad in.

                    fadeout_time is the number of milliseconds to
                    fade out the ad upon completion (default: 250).

                    ad_started is the function to call when the ad
                    has started (may not get called if network down)
                    (default: function ():void { this.clip.stop() }).

                    ad_finished is the function to call when the ad
                    has finished or could not load
                    (default: function ():void { this.clip.play() }).

                    ad_failed is called if an ad can not be displayed,
                    this is usually due to the user having ad blocking
                    software installed or issues with retrieving the ad
                    over the network. If it is called, then it is called
                    before ad_finished.
                    (default: function ():void { }).

                    ad_loaded is called just before an ad is displayed
                    with the width and height of the ad. If it is called,
                    it is called after ad_started.
                    (default: function(width:Number, height:Number):void { }).

                    ad_skipped is called if the ad was skipped, this is
                    usually due to frequency capping, or developer initiated
                    domain filtering.  If it is called, then it is called
                    before ad_finished.
                    (default: function():void { })
            */
            var DEFAULTS:Object = {
                ad_timeout: 5500,
                fadeout_time: 250,
                regpt: "o",
                method: "showTimedAd",
                ad_started: function ():void {
                    if (this.clip is MovieClip) {
                        this.clip.stop();
                    } else {
                        throw new Error("MochiAd.showInterLevelAd requires a clip that is a MovieClip or is an instance of a class that extends MovieClip.  If your clip is a Sprite, then you must provide custom ad_started and ad_finished handlers.");
                    }
                },
                ad_finished: function ():void {
                    if (this.clip is MovieClip) {
                        this.clip.play();
                    } else {
                        throw new Error("MochiAd.showInterLevelAd requires a clip that is a MovieClip or is an instance of a class that extends MovieClip.  If your clip is a Sprite, then you must provide custom ad_started and ad_finished handlers.");
                    }
                },
                ad_loaded: function (width:Number, height:Number):void {
                },
                ad_failed: function ():void {
                    trace("[MochiAd] Couldn't load an ad, make sure your game's local security sandbox is configured for Access Network Only and that you are not using ad blocking software");
                },
                ad_skipped: function ():void {
                }

            };
            options = MochiAd._parseOptions(options, DEFAULTS);

            var clip:Object = options.clip;
            var ad_msec:Number = 11000;
            var ad_timeout:Number = options.ad_timeout;
            delete options.ad_timeout;
            var fadeout_time:Number = options.fadeout_time;
            delete options.fadeout_time;

            /* Load targeting under clip._mochiad */
            if (!MochiAd.load(options)) {
                options.ad_failed();
                options.ad_finished();
                return;
            }

            options.ad_started();

            var mc:MovieClip = clip._mochiad;
            mc["onUnload"] = function ():void {
                MochiAd._cleanup(mc);
                options.ad_finished();
            }


            /* Center the clip */
            var wh:Array = MochiAd._getRes(options, clip);
            var w:Number = wh[0];
            var h:Number = wh[1];
            mc.x = w * 0.5;
            mc.y = h * 0.5;

            var chk:MovieClip = createEmptyMovieClip(mc, "_mochiad_wait", 3);
            chk.ad_msec = ad_msec;
            chk.ad_timeout = ad_timeout;
            chk.started = getTimer();
            chk.showing = false;
            chk.fadeout_time = fadeout_time;
            chk.fadeFunction = function ():void {
                if (!this.parent) {
                    delete this.onEnterFrame;
                    delete this.fadeFunction;
                    return;
                }
                var p:Number = 100 * (1 -
                    ((getTimer() - this.fadeout_start) / this.fadeout_time));
                if (p > 0) {
                    this.parent.alpha = p * 0.01;
                } else {
                    MochiAd.unload(clip);
                    delete this["onEnterFrame"];
                }
            };

            mc.unloadAd = function ():void {
                MochiAd.unload(clip);
            }

            mc.adLoaded = options.ad_loaded;
            mc.adSkipped = options.ad_skipped;
            mc.adjustProgress = function (msec:Number):void {
                var _chk:Object = mc._mochiad_wait;
                _chk.server_control = true;
                _chk.showing = true;
                _chk.started = getTimer();
                _chk.ad_msec = msec - 250;
            };
            mc.rpc = function (callbackID:Number, arg:Object):void {
                MochiAd.rpc(clip, callbackID, arg);
            };

            chk["onEnterFrame"] = function ():void {
                if (!this.parent) {
                    delete this.onEnterFrame;
                    delete this.fadeFunction;
                    return;
                }
                var ad_clip:Object = this.parent._mochiad_ctr;
                var elapsed:Number = getTimer() - this.started;
                var finished:Boolean = false;

                if (!chk.showing) {
                    var total:Number = this.parent._mochiad_ctr.contentLoaderInfo.bytesTotal;
                    if (total > 0) {
                        // ad is now showing
                        chk.showing = true;
                        chk.started = getTimer();
                        MochiAd.adShowing(clip);
                    } else if (elapsed > chk.ad_timeout) {
                        // ad failed to show - ad_timeout
                        options.ad_failed();
                        finished = true;
                    }
                }

                if (elapsed > chk.ad_msec) {
                    finished = true;
                }
                if (finished) {
                    if (this.server_control) {
                        delete this.onEnterFrame;
                    } else {
                        this.fadeout_start = getTimer();
                        this.onEnterFrame = this.fadeFunction;
                    }
                }
            };
            doOnEnterFrame(chk);
        }

        public static function showPreloaderAd(options:Object):void {
            /* Compatibility stub for Mochi Ad 1.5 terminology */
            trace("[MochiAd] DEPRECATED: showPreloaderAd was renamed to showPreGameAd in 2.0");
            MochiAd.showPreGameAd(options);
        }

        public static function showTimedAd(options:Object):void {
            /* Compatibility stub for Mochi Ad 1.5 terminology */
            trace("[MochiAd] DEPRECATED: showTimedAd was renamed to showInterLevelAd in 2.0");
            MochiAd.showInterLevelAd(options);
        }

        public static function _allowDomains(server:String):String {
            var hostname:String = server.split("/")[2].split(":")[0];

            if( flash.system.Security.sandboxType == "application")
                return hostname;

            flash.system.Security.allowDomain("*");
            flash.system.Security.allowDomain(hostname);
            flash.system.Security.allowDomain(PROD_SERVER);
            flash.system.Security.allowDomain(CDN_SERVER);
            flash.system.Security.allowInsecureDomain("*");
            flash.system.Security.allowInsecureDomain(hostname);
            return hostname;
        }

        public static function load(options:Object):MovieClip {
            /*
                Load a Mochi Ad into the given MovieClip

                options:
                    An object with keys and values to pass to the server.

                    clip is a MovieClip reference to place the ad in.

                    id should be the unique identifier for this Mochi Ad.

                    server is the base URL to the Mochi Ad server.

                    res is the resolution of the container clip or movie
                    as a string, e.g. "500x500"
            */
            abortLoad();
            var DEFAULTS:Object = {
                server: PROD_SERVER,
                method: "load",
                depth: 10333,
                id: "_UNKNOWN_"
            };
            options = MochiAd._parseOptions(options, DEFAULTS);
            // This isn't accessible yet for some reason:
            // options.clip.loaderInfo.swfVersion;
            options.swfv = 9;
            options.mav = MochiAd.getVersion();

            var clip:Object = options.clip;

            if( !(clip is DisplayObject) )
            {
                trace( "[MochiAd] Warning: Object passed as container clip not a descendant of the DisplayObject type" );
                return null;
            }
            else if( MovieClip(clip).stage == null )
            {
                trace( "[MochiAd] Warning: Container clip for ad is not attached to the stage" );
                return null;
            }

            if (!MochiAd._isNetworkAvailable()) {
                return null;
            }

            try {
                if (clip._mochiad_loaded) {
                    return null;
                }
            } catch (e:Error) {
                throw new Error("MochiAd requires a clip that is an instance of a dynamic class.  If your class extends Sprite or MovieClip, you must make it dynamic.");
            }

            var depth:Number = options.depth;
            delete options.depth;
            var mc:MovieClip = createEmptyMovieClip(clip, "_mochiad", depth);

            var wh:Array = MochiAd._getRes(options, clip);
            options.res = wh[0] + "x" + wh[1];


            clip._mochiad_loaded = true;

            if (clip.loaderInfo.loaderURL.indexOf("http") == 0) {
                options.as3_swf = clip.loaderInfo.loaderURL;
            } else {
                trace("[MochiAd] NOTE: Security Sandbox Violation errors below are normal");
                options.as3_swf = "localhost";
            }
            var init_url:String = options.server;
            // If we are using a production swf then we should use the CDN
            if (options.server == PROD_SERVER) {
               init_url = CDN_SERVER;
            }

            var hostname:String = _allowDomains(init_url);
            // Build srv1 request
            options.server = options.server + "srv/1/"+ options.id +".json?do_init=1";

            /* Set up LocalConnection recieve between here and targetting swf */
            var lc:LocalConnection = new LocalConnection();
            /* Make callbacks operate on targetting swf container */
            lc.client = mc;
            var name:String = [
                "", Math.floor((new Date()).getTime()), Math.floor(Math.random() * 999999)
            ].join("_");
            lc.allowDomain("*", "localhost");
            lc.allowInsecureDomain("*", "localhost");
            lc.connect(name);
            mc.lc = lc;
            mc.lcName = name;
            /* register our LocalConnection name with targetting swf */
            options.lc = name;

            options.st = getTimer();

            /* Container will call so we know Container LC */
            mc.regContLC = function (lc_name:String):void {
                mc._containerLCName = lc_name;
            };

            // Set current load options
            load_options = options;

            _srv1_loader = new Loader();
            var g:Function = function(ev:Object):void {
                ev.target.removeEventListener(ev.type, arguments.callee);
                MochiAd.unload(clip);
            }
            _srv1_loader.contentLoaderInfo.addEventListener(Event.UNLOAD, g);
            var req:URLRequest = new URLRequest(init_url + "container/MochiAdsCDN-AS3.swf?do_init=1&cacheBust=" + new Date().getTime());
            req.contentType = "application/x-www-form-urlencoded";
            req.method = URLRequestMethod.GET;

            _srv1_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoad );
            _srv1_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoadError );
            _srv1_loader.contentLoaderInfo.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onLoadError );
            _srv1_loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoadError );

            try {
                if (!options.skip) {
                   _srv1_loader.load(req);
                }
            } catch (e:*) {
                onLoadError(e);
            }

            mc.addChild(_srv1_loader);
            /* load targetting swf */
            mc._mochiad_ctr = _srv1_loader;

            return mc;
        }

        private static function onLoad(event:Event):void
        {
            // Initialize ad container when loaded.
            try {
                var container:* = event.target.content;
                container.initialize(load_options);
            } catch(e:*) {
               onLoadError(e);
            }
        }

        private static function onLoadError(error:*):void
        {
          trace("[MochiAds] Blocked URL");
        }

        public static function unload(clip:Object):Boolean {
            /*
                Unload a Mochi Ad from the given MovieClip

                    clip:
                        a MovieClip reference (e.g. this.stage)
            */
            if (clip.clip && clip.clip._mochiad) {
                clip = clip.clip;
            }

            if (clip.origFrameRate != undefined) {
                clip.stage.frameRate = clip.origFrameRate;
            }

            if (!clip._mochiad) {
                return false;
            }
            if (clip._mochiad._containerLCName != undefined) {
                    clip._mochiad.lc.send( clip._mochiad._containerLCName, 'notify', {id: 'unload'} );
            }

            if (clip._mochiad.onUnload) {
                clip._mochiad.onUnload();
            }
            delete clip._mochiad_loaded;
            delete clip._mochiad;
            return true;
        }

        public static function _cleanup(mc:Object):void {
            if ('lc' in mc) {
                var lc:LocalConnection = mc.lc;
                var f:Function = function ():void {
                    try {
                        lc.client = null;
                        lc.close();
                    } catch (e:Error) {
                    }
                };
                setTimeout(f, 0);
            }
            var idx:Number = DisplayObjectContainer(mc).numChildren;
            while (idx > 0) {
                idx -= 1;
                DisplayObjectContainer(mc).removeChildAt(idx);
            }
            for (var k:String in mc) {
                delete mc[k];
            }
        }

        public static function _isNetworkAvailable():Boolean {
            return Security.sandboxType != "localWithFile";
        }

        public static function _getRes(options:Object, clip:Object):Array {
            var b:Object = clip.getBounds(clip.root);
            var w:Number = 0;
            var h:Number = 0;
            if (typeof(options.res) != "undefined") {
                var xy:Array = options.res.split("x");
                w = parseFloat(xy[0]);
                h = parseFloat(xy[1]);
            } else {
                w = b.right - b.left; 
                h = b.top - b.bottom;
            }
            if (w == 0 || h == 0) {
                w = clip.stage.stageWidth;
                h = clip.stage.stageHeight;
            }


            return [w, h];
        }

        public static function _parseOptions(options:Object, defaults:Object):Object {
            var optcopy:Object = {};
            var k:String;
            for (k in defaults) {
                optcopy[k] = defaults[k];
            }
            if (options) {
                for (k in options) {
                    optcopy[k] = options[k];
                }
            }
            if (optcopy.clip == undefined) {
                throw new Error("MochiAd is missing the 'clip' parameter.  This should be a MovieClip, Sprite or an instance of a class that extends MovieClip or Sprite.");
            }
            options = optcopy.clip.loaderInfo.parameters.mochiad_options;
            if (options) {
                var pairs:Array = options.split("&");
                for (var i:Number = 0; i < pairs.length; i++) {
                    var kv:Array = pairs[i].split("=");
                    optcopy[unescape(kv[0])] = unescape(kv[1]);
                }
            }
            if (optcopy.id == 'test') {
                trace("[MochiAd] WARNING: Using the MochiAds test identifier, make sure to use the code from your dashboard, not this example!");
            }
            return optcopy;
        }

        public static function rpc(clip:Object, callbackID:Number, arg:Object):void {
            switch (arg.id) {
                case 'setValue':
                    MochiAd.setValue(clip, arg.objectName, arg.value);
                    break;
                case 'getValue':
                    var val:Object = MochiAd.getValue(clip, arg.objectName);
                    clip._mochiad.lc.send(clip._mochiad._containerLCName, 'rpcResult', callbackID, val);
                    break;
                case 'runMethod':
                    var ret:Object = MochiAd.runMethod(clip, arg.method, arg.args);
                    clip._mochiad.lc.send(clip._mochiad._containerLCName, 'rpcResult', callbackID, ret);
                    break;
                default:
                    trace('[mochiads rpc] unknown rpc id: ' + arg.id);
            }
        }

        public static function setValue(base:Object, objectName:String, value:Object):void {
            var nameArray:Array = objectName.split(".");

            // drill down through the base object until we get the parent class of object to modify
            for (var i:Number = 0; i < nameArray.length - 1; i++) {
                if (base[nameArray[i]] == undefined || base[nameArray[i]] == null) {
                    return;
                }
                base = base[nameArray[i]];
            }

            base[nameArray[i]] = value;
        }

        public static function getValue(base:Object, objectName:String):Object {
            var nameArray:Array = objectName.split(".");

            // drill down through the base object until we get the parent class of object to modify
            for (var i:Number = 0; i < nameArray.length - 1; i++) {
                if (base[nameArray[i]] == undefined || base[nameArray[i]] == null) {
                    return undefined;
                }
                base = base[nameArray[i]];
            }

            // return the object requested
            return base[nameArray[i]];
        }

        public static function runMethod(base:Object, methodName:String, argsArray:Array):Object {
            var nameArray:Array = methodName.split(".");

            // drill down through the base object until we get the parent class of method to run
            for (var i:Number = 0; i < nameArray.length - 1; i++) {
                if (base[nameArray[i]] == undefined || base[nameArray[i]] == null) {
                    return undefined;
                }
                base = base[nameArray[i]];
            }

            // run method
            if (typeof(base[nameArray[i]]) == 'function') {
                return base[nameArray[i]].apply(base, argsArray);
            } else {
                return undefined;
            }
        }

        public static function adShowing(mc:Object):void {
            // set stage framerate to 30fps for the ad undo this later in the unload
            mc.origFrameRate = mc.stage.frameRate;
            mc.stage.frameRate = 30;
        }

        public static function openAdGroup(clip:MovieClip):void
        {
            clip.dispatchEvent(new Event("Mochiad:openAdGroup"));
        }

        public static function closeAdGroup(clip:MovieClip):void
        {
            clip.dispatchEvent(new Event("Mochiad:closeAdGroup"));
        }

        public static function openDockSlider(clip:MovieClip):void
        {
            clip.dispatchEvent(new Event("Mochiad:openDockSlider"));
        }

        private static function abortLoad():void
        {
            try{
                _srv1_loader.close();
            }catch(e:*){
            }
        }
    }
}
