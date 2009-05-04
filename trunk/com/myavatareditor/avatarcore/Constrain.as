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

	import com.myavatareditor.avatarcore.Feature;
	import com.myavatareditor.avatarcore.Range;
	import com.myavatareditor.avatarcore.Rect;
	import com.myavatareditor.avatarcore.display.ArtSprite;
	
	/**
	 * A transformation (position, scale, and rotation) constraint
	 * behavior for feature art.  Constrains are applied to all art assets
	 * in an art group as though they were one. 
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Constrain implements IBehavior {
		
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
		 * The possible scaleX values for art sprites. Scale
		 * constraints are calculated based on absolute values
		 * where both negative and positive scales are constrained
		 * within the positive ranges of the range value
		 * (with negative scales remaining negative).
		 */
		public function get scaleX():Range { return _scaleX; }
		public function set scaleX(value:Range):void {
			_scaleX = value;
		}
		private var _scaleX:Range;
		
		/**
		 * The possible scaleY values for art sprites. Scale
		 * constraints are calculated based on absolute values
		 * where both negative and positive scales are constrained
		 * within the positive ranges of the range value
		 * (with negative scales remaining negative).
		 */
		public function get scaleY():Range { return _scaleY; }
		public function set scaleY(value:Range):void {
			_scaleY = value;
		}
		private var _scaleY:Range;
		
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
		 * @param	scaleX ScaleX range value.
		 * @param	scaleY ScaleY range value.
		 * @param	rotation Rotation range value.
		 */
		public function Constrain(position:Rect = null, scaleX:Range = null, scaleY:Range = null, rotation:Range = null) {
			this.position = position;
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.rotation = rotation;
		}
		
		/**
		 * Returns the same sprites defined by the feature.
		 * @param	feature
		 * @param	sprites
		 * @return
		 */
		public function getArtSprites(feature:Feature, sprites:Array):Array {
			return sprites;
		}
		
		/**
		 * Confines sprites within the region specified by the 
		 * constrain properties. 
		 * @param	artSprite The art sprite being drawn.
		 */
		public function drawArtSprite(artSprite:ArtSprite):void {
			if (artSprite == null) return;
			
			// position
			if (_position){
				if (artSprite.x < _position.left){
					artSprite.x = _position.left;
				}else if (artSprite.x > _position.right){
					artSprite.x = _position.right;
				}
				if (artSprite.y < _position.top){
					artSprite.y = _position.top;
				}else if (artSprite.y > _position.bottom){
					artSprite.y = _position.bottom;
				}
			}
			
			// rotation
			if (_rotation){
				if (artSprite.rotation > _rotation.max){
					artSprite.rotation = _rotation.max;
				}else if (artSprite.rotation < _rotation.min){
					artSprite.rotation = _rotation.min;
				}
			}
			
			// scale
			var absScale:Number;
			var negScale:Boolean;
			if (_scaleX){
				absScale = Math.abs(artSprite.scaleX);
				negScale = Boolean(artSprite.scaleX < 0);
				if (artSprite.scaleX > _scaleX.max){
					artSprite.scaleX = negScale ? -_scaleX.max : _scaleX.max;
				}else if (absScale < _scaleX.min){
					artSprite.scaleX = negScale ? -_scaleX.min : _scaleX.min;
				}
			}
			if (_scaleY){
				absScale = Math.abs(artSprite.scaleY);
				negScale = Boolean(artSprite.scaleY < 0);
				if (absScale > _scaleY.max){
					artSprite.scaleY = negScale ? -_scaleY.max : _scaleY.max;
				}else if (absScale < _scaleY.min){
					artSprite.scaleY = negScale ? -_scaleY.min : _scaleY.min;
				}
			}
		}
		
		public function clone():IBehavior {
			var copy:Constrain = new Constrain(_position.clone() as Rect, _scaleX.clone(),  _scaleY.clone(), _rotation.clone());
			return copy;
		}
	}
}