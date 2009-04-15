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
package com.myavatareditor.avatarcore.data {
	
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.geom.Matrix;
	
	/**
	 * Represents a postion, scale, and rotation transformation
	 * that is applied to an avatar feature.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Transform implements IXMLWritable {
		
		private static const toRadians:Number = Math.PI / 180;
		
		/**
		 * Name identifier for the Transform object.
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void {
			_name = value;
		}
		private var _name:String;
		
		/**
		 * Horizontal offset to be applied to an art sprite.
		 */
		public var x:Number = 0;
		
		/**
		 * Vertical offset to be applied to an art sprite.
		 */
		public var y:Number = 0;
		
		/**
		 * Scale multiplier to be applied to an art sprite.
		 * This accounts for scaling in both the x and y axes.
		 */
		public var scale:Number = 1;
		
		/**
		 * Rotation in degrees to be applied to an art sprite.
		 */
		public var rotation:Number = 0;
		
		public function Transform(x:Number = 0, y:Number = 0, scale:Number = 1, rotation:Number = 0) {
			this.x = x;
			this.y = y;
			this.scale = scale;
			this.rotation = rotation;
		}
		
		public function getPropertiesIgnoredByXML():Object {
			return {};
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {name:1};
		}
		
		public function getObjectAsXML():XML {
			var xml:XML = <Transform />;
			if (name){
				xml.@name = name;
			}
			var children:XMLList = new XMLList();
			if (!isNaN(x) && x != 0) children += <x>{x}</x>;
			if (!isNaN(y) && y != 0) children += <y>{y}</y>;
			if (!isNaN(scale) && scale != 1.0) children += <scale>{scale}</scale>;
			if (!isNaN(rotation) && rotation != 0) children += <rotation>{rotation}</rotation>;
			xml.setChildren(children);
			return xml;
		}
		
		/**
		 * Returns a matrix representation of this transformation
		 * that can be applied to graphics.
		 * @return A matrix object with all of the characteristics
		 * of this transform.
		 */
		public function getMatrix():Matrix {
			var matrix:Matrix = new Matrix();
			if (isNaN(scale) == false) {
				matrix.scale(scale, scale);
			}
			if (isNaN(rotation) == false) {
				matrix.rotate(rotation * toRadians);
			}
			var tx:Number = isNaN(x) ? 0 : x;
			var ty:Number = isNaN(y) ? 0 : y;
			matrix.translate(x, y);
			return matrix;
		}
		
		/**
		 * Fills the undefined properties of this object
		 * with the values of the properties within the
		 * provided transform.
		 * @param	transform The transform object to be used
		 * to fill in the undefined properties of this transform.
		 */
		public function fill(transform:Transform):void {
			if (isNaN(x)) x = transform.x;
			if (isNaN(y)) y = transform.y;
			if (isNaN(scale)) scale = transform.scale;
			if (isNaN(rotation)) rotation = transform.rotation;
		}
	}
}