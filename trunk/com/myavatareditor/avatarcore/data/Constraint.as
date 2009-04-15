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
	
	import flash.geom.Rectangle;
	
	/**
	 * A transformation (position, scale, and rotation) constraint
	 * for feature art.  Constraints are applied to all art assets
	 * in an art group as though they were one.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Constraint {
		
		/**
		 * Name identifying this constraint.
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void {
			_name = value;
		}
		private var _name:String;
		
		/**
		 * A rectangular area to constrain the center position
		 * of art sprites in an avatar art object.
		 */
		public function get position():Rect { return _position; }
		public function set position(value:Rect):void {
			_position = value;
		}
		private var _position:Rect;
		
		/**
		 * The possible scale values for art sprites.
		 */
		public function get scale():Range { return _scale; }
		public function set scale(value:Range):void {
			_scale = value;
		}
		private var _scale:Range;
		
		/**
		 * The possible rotation values for art sprites.
		 */
		public function get rotation():Range { return _rotation; }
		public function set rotation(value:Range):void {
			_rotation = value;
		}
		private var _rotation:Range;
		
		/**
		 * Constructor for creating new Constraint instances.
		 * @param	position Position rectagnle value.
		 * @param	scale Scale range value.
		 * @param	rotation Rotation range value.
		 */
		public function Constraint(position:Rect = null, scale:Range = null, rotation:Range = null) {
			this.position = position;
			this.scale = scale;
			this.rotation = rotation;
		}
	}
}