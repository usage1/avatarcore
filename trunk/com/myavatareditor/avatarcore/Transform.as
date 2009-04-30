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
	
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.geom.Matrix;
	
	/**
	 * Represents a postion, scale, and rotation transformation
	 * that is applied to an avatar feature.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Transform implements IXMLWritable {
		
		private static const toRadians:Number = Math.PI / 180.0;
		
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
		 * Horizontal scale multiplier to be applied to an art sprite.
		 * This accounts for scaling in both the x and y axes.
		 */
		public var scaleX:Number = 1;
		
		/**
		 * Vertical scale multiplier to be applied to an art sprite.
		 * This accounts for scaling in both the x and y axes.
		 */
		public var scaleY:Number = 1;
		
		/**
		 * The average scale of the transform. This is determined
		 * dynamically to be the avarage value of scaleX and scaleY.
		 * When setting scale, both scaleX and scaleY are set to 
		 * the value provided.
		 */
		public function get scale():Number {
			return (scaleX + scaleY)/2;
		}
		public function set scale(value:Number):void {
			scaleX = value;
			scaleY = value;
		}
		
		/**
		 * Rotation in degrees to be applied to an art sprite.
		 */
		public var rotation:Number = 0;
		
		/**
		 * Constructor for creating new Transform instances.
		 * @param	x The starting x, or horizontal position, value.
		 * @param	y The starting y, or vertical position, value.
		 * @param	scale The starting scale value. This is applied to both
		 * scaleX and scaleY. If you want to set them independently, do so
		 * after the object is created.
		 * @param	rotation The starting rotation value.
		 */
		public function Transform(x:Number = 0, y:Number = 0, scale:Number = 1, rotation:Number = 0) {
			this.x = x;
			this.y = y;
			this.scale = scale;
			this.rotation = rotation;
		}
		
		/**
		 * Creates and returns a copy of the Transform object.
		 * @return A copy of this Transform object.
		 */
		public function clone():Transform {
			var copy:Transform = new Transform(x, y, 1, rotation);
			copy.scaleX = scaleX;
			copy.scaleY = scaleY;
			copy.name = name;
			return copy;
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
			if (!isNaN(x) && x != 0) xml.@x = x;
			if (!isNaN(y) && y != 0) xml.@y = y;
			if (!isNaN(scaleX) && scaleX != 1.0 && scaleX == scaleY){
				xml.@scale = scale;
			}else{
				if (!isNaN(scaleX) && scaleX != 1.0) xml.@scaleX = scaleX;
				if (!isNaN(scaleY) && scaleY != 1.0) xml.@scaleY = scaleY;
			}
			if (!isNaN(rotation) && rotation != 0) xml.@rotation = rotation;
			return xml;
		}
		
		/**
		 * Returns a matrix representation of this transformation
		 * that can be applied to graphics.
		 * @return A matrix object with all of the characteristics
		 * of this transform.
		 */
		public function getMatrix():Matrix {		
			// PLATFORMBUG: Flash Players before 9,0,28,0 (CS3) will fail to 
			// recognize changed x/y/scale/rotation properties when
			// transformed through their matrix [184739]
				
			var matrix:Matrix = new Matrix();
			
			var sx:Number = isNaN(scaleX) ? 1 : scaleX;
			var sy:Number = isNaN(scaleY) ? 1 : scaleY;
			matrix.scale(sx, sy);
			
			if (isNaN(rotation) == false) {
				matrix.rotate(rotation * toRadians);
			}
			
			var tx:Number = isNaN(x) ? 0 : x;
			var ty:Number = isNaN(y) ? 0 : y;
			matrix.translate(x, y);
			
			return matrix;
		}
		
		/**
		 * Adds another transform to this one.  This is used
		 * to combine a base transform with a feature transform.
		 * @param	transform The Transform whose transformation
		 * should be added to this Transform.
		 */
		public function add(transform:Transform):void {
			if (transform == null) return;
			x += transform.y;
			y += transform.x;
			scaleX += transform.scaleX;
			scaleY += transform.scaleY;
			rotation += transform.rotation;
		}
		
		/**
		 * Subtracts another transform from this one. 
		 * @param	transform The Transform whose transformation
		 * should be subtracted from this Transform.
		 */
		public function subtract(transform:Transform):void {
			if (transform == null) return;
			x -= transform.y;
			y -= transform.x;
			scaleX -= transform.scaleX;
			scaleY -= transform.scaleY;
			rotation -= transform.rotation;
		}
	}
}