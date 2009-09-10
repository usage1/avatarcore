/*
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
package com.myavatareditor.avatarcore {
	
	import com.myavatareditor.avatarcore.display.ArtSprite;
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	
	/**
	 * Defines characteristics to be referenced by avatar features.  Characteristics
	 * include possible art, color selections, adjustments and optional
	 * constraints.  Features reference these characteristics
	 * by name.  Features reference feature definitions when they share the same 
	 * name.  This connection is made when an Avatar instance is associated with a 
	 * Library instance.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class FeatureDefinition extends FeatureBase {
		
		/**
		 * Variations of art available for this feature
		 * definition. An artSet cannot be null.
		 */
		public function get artSet():ArtSet { return _artSet; }
		public function set artSet(value:ArtSet):void {
			if (value){
				_artSet = value;
			}
		}
		private var _artSet:ArtSet = new ArtSet();
		
		/**
		 * Default Art to be copied into a Feature if it does not
		 * yet already have one explicit set for it. This includes
		 * not yet having set a value for artName.
		 */
		public function get defaultArt():Art { return _defaultArt; }
		public function set defaultArt(value:Art):void {
			_defaultArt = value;
		}
		private var _defaultArt:Art;
		
		/**
		 * Variations of colors (color transforms) that can be
		 * applied to art within this definition.   A colorSet
		 * cannot be null.
		 */
		public function get colorSet():SetCollection { return _colorSet; }
		public function set colorSet(value:SetCollection):void {
			if (value){
				_colorSet = value;
			}
		}
		private var _colorSet:SetCollection = new SetCollection();
		
		/**
		 * Default Color to be copied into a Feature if it does not
		 * yet already have one explicit set for it. This includes
		 * not yet having set a value for colorName.
		 */
		public function get defaultColor():Color { return _defaultColor; }
		public function set defaultColor(value:Color):void {
			_defaultColor = value;
		}
		private var _defaultColor:Color;
		
		/**
		 * Variations of adjusts that can be applied to
		 * art within this definition.  A adjustSet
		 * cannot be null.
		 */
		public function get adjustSet():SetCollection { return _adjustSet; }
		public function set adjustSet(value:SetCollection):void {
			if (value){
				_adjustSet = value;
			}
		}
		private var _adjustSet:SetCollection = new SetCollection();
		
		/**
		 * Default Adjust to be copied into a Feature if it does not
		 * yet already have one explicit set for it. This includes
		 * not yet having set a value for adjustName.
		 */
		public function get defaultAdjust():Adjust { return _defaultAdjust; }
		public function set defaultAdjust(value:Adjust):void {
			_defaultAdjust = value;
		}
		private var _defaultAdjust:Adjust;
		
		/**
		 * Constructor for creating new FeatureDefinition instances.
		 */
		public function FeatureDefinition(name:String = null) {
			super(name);
		}
	}
}