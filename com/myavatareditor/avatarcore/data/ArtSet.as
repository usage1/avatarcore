﻿/*
Copyright (c) 2009 Trevor McCauley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
*/
package com.myavatareditor.avatarcore.data {
	
	/**
	 * A collection of Art objects for feature definitions.
	 * Defaults for some Art definitions can be defined in a
	 * ArtSet first which then get applied to Art instances
	 * when added to the art set collection.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class ArtSet extends Collection {
		
		/**
		 * Name identifying this art set.
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void {
			_name = value;
		}
		private var _name:String;
		
		/**
		 * Default zIndex for child Art objects if their
		 * zIndex is NaN when added to the ArtSet.
		 */
		public function get zIndex():Number { return _zIndex; }
		public function set zIndex(value:Number):void {
			_zIndex = value;
		}
		private var _zIndex:Number; // default: NaN
		
		/**
		 * Default colorize for child Art objects if their
		 * colorize is NaN when added to the ArtSet.
		 */
		public function get colorize():Number { return _colorize; }
		public function set colorize(value:Number):void {
			_colorize = value;
		}
		private var _colorize:Number; // default: NaN
		
		/**
		 * Constructor for new ArtSet instances.
		 */
		public function ArtSet() {
			
		}
		
		/**
		 * Custom addItem that assigns default colorize and
		 * zIndex values to added Art objects when their values are
		 * undefined.
		 * @param	item Item to be added to the art set collection.
		 * @return The collection item added.
		 */
		public override function addItem(item:*):* {
			
			// assign default properties to added art
			if (item is Art) {
				var artItem:Art = item as Art;
				artItem.assignDefaults(zIndex, colorize);
			}
			
			return super.addItem(item);
		}
	}
}