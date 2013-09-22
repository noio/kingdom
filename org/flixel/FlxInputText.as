package org.flixel
{
	import flash.text.TextField;
	import org.flixel.*;
	import flash.events.Event;
	import flash.text.TextFieldType;
	
	/**
	FlxInputText v0.92, Input text field extension for Flixel
	(author Nitram_cero, Martin Sebastian Wain)
	(slight modification by Wurmy, seems to work on version 2.34 of Flixel)
	(little insignificant update by Tyranus, now works with scroll)
	(minor 2.5. update by Kevin Prein)
	(minor update by Mr_Walrus, IDE-friendly and plays nicer with Flixel)

	New members:
		getText()
		setMaxLength()
		
		backgroundColor
		borderColor
		backgroundVisible
		borderVisible
		
		forceUpperCase
		filterMode
		customFilterPattern
	
	Copyright (c) 2009 Martin Sebastian Wain
	License: Creative Commons Attribution 3.0 United States
	(http://creativecommons.org/licenses/by/3.0/us/)
	
	(A tiny "single line comment" reference in the source code is more than sufficient as attribution :)
	 */
	
	public class FlxInputText extends FlxText {
		
		static public const NO_FILTER:uint				= 0;
		static public const ONLY_ALPHA:uint				= 1;
		static public const ONLY_NUMERIC:uint			= 2;
		static public const ONLY_ALPHANUMERIC:uint		= 3;
		static public const CUSTOM_FILTER:uint			= 4;
		
		//@desc		Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
		//			(Remember to append "FlxInputText." as a prefix to those constants)
		public var filterMode:uint = NO_FILTER;
		
		//@desc		This regular expression will filter out (remove) everything that matches. This is activated by setting filterMode = FlxInputText.CUSTOM_FILTER.
		public var customFilterPattern:RegExp = /[]*/g;
		
		//@desc		If this is set to true, text typed is forced to be uppercase
		public var forceUpperCase:Boolean = false;
		
		/**
		 * Input field class that "fits in" with Flixel's workflow
		 * 
		 * @param	X				The X position of the text.
		 * @param	Y				The Y position of the text.
		 * @param	Width			The width of the text box.
		 * @param	Text			The text to be displayed.
		 * @param	Color			The text color.
		 * @param	Font			The text font.
		 * @param	Size			The width of the text box.
		 * @param	Justification	How to center the text with with regards to the box.
		 */
		public function FlxInputText(X:Number, Y:Number, Width:uint, Height:uint, Text:String, Color:uint=0x000000, Font:String=null, Size:uint=8, Justification:String=null)
		{
			//super(X, Y, Width, Height, Text, Color, Font, Size, Justification, Angle);
			super(X, Y, Width, Text);
            setFormat(Font, Size)
			
			_textField.selectable = true;
			_textField.type = TextFieldType.INPUT;
			_textField.background = false;
			_textField.backgroundColor = (~Color) & 0xffffff;
			_textField.textColor = Color;
			_textField.border = true;
			_textField.borderColor = Color;
			_textField.height = Height;
			this.height = Height;
			
			_textField.x = X;
			_textField.y = Y;
			_textField.addEventListener(Event.CHANGE, onTextChange);
			
			FlxG.stage.addChild(_textField);
		}
		
		/**
		 * Override the draw function so that the flash object shows, not the FlxSprite
		 */
		override public function draw():void 
		{
			
		}
		
		/**
		 * Clean up after ourselves
		 */
		override public function destroy():void 
		{
			_textField.removeEventListener(Event.CHANGE, onTextChange);
			FlxG.stage.removeChild(_textField);
			super.destroy();
		}
		
		/**
		 * Handles the text of the object being changed,
		 * checks it against the text field filters
		 * @param	event
		 */
		private function onTextChange(event:Event):void
		{
			if(forceUpperCase)
				_textField.text = _textField.text.toUpperCase();
				
			if(filterMode != NO_FILTER) {
				var pattern:RegExp;
				switch(filterMode) {
					case ONLY_ALPHA:		pattern = /[^a-zA-Z]*/g;		break;
					case ONLY_NUMERIC:		pattern = /[^0-9]*/g;			break;
					case ONLY_ALPHANUMERIC:	pattern = /[^a-zA-Z0-9]*/g;		break;
					case CUSTOM_FILTER:		pattern = customFilterPattern;	break;
					default:
						throw new Error("FlxInputText: Unknown filterMode ("+filterMode+")");
				}
				_textField.text = _textField.text.replace(pattern, "");
			}
		}
		
		/**
		 * The color of the background of the text box
		 */
		public function get backgroundColor():uint					
		{ 
			return _textField.backgroundColor; 
		}
		
		/**
		 * @private
		 */
		public function set backgroundColor(Color:uint):void
		{ 
			_textField.backgroundColor = Color; 
		}
		
		/**
		 * The color of the border around the text box.
		 */
		public function get borderColor():uint
		{ 
			return _textField.borderColor; 
		}
		
		/**
		 * @private
		 */
		public function set borderColor(Color:uint):void
		{ 
			_textField.borderColor = Color; 
		}
		
		/**
		 * Whether the textbox has a background.
		 */
		public function get backgroundVisible():Boolean	
		{
			return _textField.background;
		}
		
		/**
		 * @private
		 */
		public function set backgroundVisible(Enabled:Boolean):void	
		{
			_textField.background = Enabled; 
		}
		
		/**
		 * Whether the textbox has a border.
		 */
		public function get borderVisible():Boolean
		{ 
			return _textField.border;
		}
		
		/**
		 * @private
		 */
		public function set borderVisible(Enabled:Boolean):void
		{ 
			_textField.border = Enabled; 
		}
		
		/**
		 * The read-only flash object text field, compare this to 
		 * stage.focus to see if this text box is selected.
		 */
		public function get textField():TextField 
		{
			return _textField;
		}
		
		/**
		 * Set the maximum length for the field (e.g. "3" 
		 * for Arcade type hi-score initials)
		 * @param	Length		The maximum length. 0 means unlimited.
		 */
		public function setMaxLength(Length:uint):void
		{
			_textField.maxChars = Length;
		}
	}
}