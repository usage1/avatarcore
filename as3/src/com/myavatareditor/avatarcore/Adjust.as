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
	 * Represents a postion, scale, and rotation adjustation
	 * that is applied to an avatar feature.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Adjust implements IXMLWritable {
		
		private static const toRadians:Number = Math.PI / 180.0;
		
		/**
		 * Name identifier for the Adjust object.
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
		 * This accounts for scaling in both the x axis.
		 */
		public var scaleX:Number = 1;
		
		/**
		 * When true, flips an art sprite's graphics within the x axis.
		 * This is comparable to having a negative scaleX but allows
		 * constraints to be accurately applied to that value.
		 */
		public var flipX:Boolean = false;
		
		/**
		 * Vertical scale multiplier to be applied to an art sprite.
		 * This accounts for scaling in both the y axis.
		 */
		public var scaleY:Number = 1;
		
		/**
		 * When true, flips an art sprite's graphics within the y axis.
		 * This is comparable to having a negative scaleY but allows
		 * constraints to be accurately applied to that value.
		 */
		public var flipY:Boolean = false;
		
		/**
		 * The average scale of the adjust. This is determined
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
		 * Constructor for creating new Adjust instances.
		 * @param	x The starting x, or horizontal position, value.
		 * @param	y The starting y, or vertical position, value.
		 * @param	scaleX The starting scaleX value.
		 * @param	scaleY The starting scaleY value.
		 * @param	rotation The starting rotation value.
		 */
		public function Adjust(x:Number = 0, y:Number = 0, scaleX:Number = 1, scaleY:Number = 1, rotation:Number = 0) {
			this.x = x;
			this.y = y;
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.rotation = rotation;
		}
		
		/**
		 * Creates and returns a copy of the Adjust object.
		 * @return A copy of this Adjust object.
		 */
		public function clone():Adjust {
			var copy:Adjust = new Adjust(x, y, scaleX, scaleY, rotation);
			copy.flipX = flipX;
			copy.flipY = flipY;
			copy.name = name;
			return copy;
		}
		
		public function getPropertiesIgnoredByXML():Object {
			return {};
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {name:1};
		}
		
		public function getDefaultPropertiesInXML():Object {
			return {};
		}
		
		public function getObjectAsXML():XML {
			var xml:XML = <Adjust />;
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
			if (flipX) xml.@flipX = "true";
			if (flipY) xml.@flipY = "true";
			if (!isNaN(rotation) && rotation != 0) xml.@rotation = rotation;
			return xml;
		}
		
		/**
		 * Returns a matrix representation of this adjustation
		 * that can be applied to graphics.
		 * @return A matrix object with all of the characteristics
		 * of this adjust.
		 */
		public function getMatrix():Matrix {		
			// PLATFORMBUG: Flash Players before 9,0,28,0 (CS3) will fail to 
			// recognize changed x/y/scale/rotation properties when
			// adjusted through their matrix [184739]
				
			var matrix:Matrix = new Matrix();
			
			var sx:Number = isNaN(scaleX) ? 1 : scaleX;
			var sy:Number = isNaN(scaleY) ? 1 : scaleY;
			if (flipX) sx = -sx;
			if (flipY) sy = -sy;
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
		 * Adds another adjust to this one.  This is used to combine
		 * a base adjust with a feature adjust. All values except
		 * scale are added. Scale values are multiplied.
		 * @param	adjust The Adjust whose properties
		 * should be added to this Adjust.
		 */
		public function add(adjust:Adjust):void {
			if (adjust == null) return;
			x += adjust.x;
			y += adjust.y;
			scaleX *= adjust.scaleX;
			scaleY *= adjust.scaleY;
			rotation += adjust.rotation;
		}
		
		/**
		 * Subtracts another adjust from this one. All values except
		 * scale are subtracted. Scale values are divided.
		 * @param	adjust The Adjust whose properties
		 * should be subtracted from this Adjust.
		 */
		public function subtract(adjust:Adjust):void {
			if (adjust == null) return;
			x -= adjust.x;
			y -= adjust.y;
			scaleX = adjust.scaleX ? scaleX/adjust.scaleX : 0;
			scaleY = adjust.scaleY ? scaleY/adjust.scaleY : 0;
			rotation -= adjust.rotation;
		}
	}
}