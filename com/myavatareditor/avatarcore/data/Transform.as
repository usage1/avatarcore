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
	
	import flash.geom.Matrix;
	
	/**
	 * Represents a transformation (postion, scale, and rotation)
	 * that is applied to an avatar feature.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Transform {
		
		public var x:Number = 0;
		public var y:Number = 0;
		public var rotation:Number = 0;
		public var scale:Number = 1;
		
		public function Transform(x:Number = 0, y:Number = 0, scale:Number = 1, rotation:Number = 0) {
			this.x = x;
			this.y = y;
			this.scale = scale;
			this.rotation = rotation;
		}
		
		public function getMatrix():Matrix {
			var matrix:Matrix = new Matrix();
			matrix.scale(scale, scale);
			matrix.rotate(rotation*Math.PI/180);
			matrix.translate(x, y);
			return matrix;
		}
		
		public function fill(transform:Transform):void {
			if (isNaN(x)) x = transform.x;
			if (isNaN(y)) y = transform.y;
			if (isNaN(scale)) scale = transform.scale;
			if (isNaN(rotation)) rotation = transform.rotation;
		}
	}
}