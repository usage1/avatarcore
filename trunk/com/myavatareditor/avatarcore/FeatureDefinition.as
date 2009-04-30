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
	import flash.geom.Rectangle;
	
	/**
	 * Defines characteristics to be referenced by avatar features.  Characteristics
	 * include possible art, color selections, transformations and optional
	 * constraints for transformations.  Features reference these characteristics
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
		 * Variations of transformations that can be
		 * applied to art within this definition.  A transformSet
		 * cannot be null.
		 */
		public function get transformSet():SetCollection { return _transformSet; }
		public function set transformSet(value:SetCollection):void {
			if (value){
				_transformSet = value;
			}
		}
		private var _transformSet:SetCollection = new SetCollection();
		
		/**
		 * Constructor for creating new FeatureDefinition instances.
		 */
		public function FeatureDefinition() {
			
		}
	}
}