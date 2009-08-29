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
package com.myavatareditor.avatarcore.display {
	
	import com.myavatareditor.avatarcore.Art;
	import com.myavatareditor.avatarcore.Avatar;
	import com.myavatareditor.avatarcore.Feature;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * Represents an individual sprite within an avatar art.  Art
	 * variations represent one feature's appearance and can consist
	 * of one or more art sprites to visually represent a feature.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class ArtSprite extends SourceLoaderSprite {
		
		/**
		 * The Avatar instance associated with the AvatarDisplay
		 * object that contains this art sprite.
		 */
		public function get avatar():Avatar {
			return _feature ? _feature.avatar : null;
		}
		
		/**
		 * Feature associated with this art sprite.  This feature
		 * is used to draw the art sprite after the art has
		 * been loaded from the src.  
		 */
		public function get feature():Feature {
			return _feature;
		}
		public function set feature(value:Feature):void {
			if (value == _feature) return;
			_feature = value;
		}
		private var _feature:Feature;
		
		/**
		 * Art object associated with this art sprite. This
		 * and the feature should be set at the same time if
		 * the art for this sprite is changed so that they
		 * remain congruent.
		 */
		public function get art():Art {
			return _art;
		}
		public function set art(value:Art):void {
			if (value == _art) return;
			
			_art = value;
			this.src = _art ? _art.src : null;
		}
		private var _art:Art;
		
		/**
		 * Z-index, or location within sorted arrangement
		 * of the art within an AvatarDisplay object as defined
		 * by the linked Art instance.
		 */
		public function get zIndex():Number {
			return _art && isNaN(_art.zIndex) == false ? _art.zIndex : 0;
		}
		
		/**
		 * The name of the feature associated with
		 * this art sprite.
		 */
		public function get featureName():String {
			return _feature ? _feature.name : null;
		}
		
		/**
		 * The number of parents as reported by the art sprite's
		 * feature.  The more parents an ArtSprite has, the later
		 * it gets drawn during an AvatarDisplay.draw.
		 */
		public function get parentCount():int {
			return _feature ? _feature.parentCount : 0;
		}
			
		/**
		 * Constructor for creating new ArtSprite instances. ArtSprite
		 * instances are created automatically by AvatarDisplay instances
		 * when drawing an avatar.
		 * @param	art Graphic Art object associated with this sprite.
		 * A single feature may use multiple art sprites if it is using
		 * multiple Art instances to describe itself visually. The art
		 * used here is one of those instances (not necessarily the
		 * single Art reference of the feature)
		 * @param	feature The feature being rendered through this sprite.
		 */
		public function ArtSprite(art:Art = null, feature:Feature = null) {
			super(null);
			
			addEventListener(Event.COMPLETE, contentCompleteHandler, false, 0, true);
			
			// we're going under the assumption here that you'll want to
			// be able to select individual AvatarDisplay objects when picking
			// a feature to change through mouse interaction, and for that
			// the target of the click event should target this instance
			// rather than some child
			mouseChildren = false;
			
			this.art = art;
			this.feature = feature;
		}
		
		/**
		 * Rebuilds the art sprite from scratch refreshing
		 * its art source and then calling draw.
		 */
		public function rebuild():void {
			reloadContent();
			draw();
		}
		
		/**
		 * Updates the transformation of the art as defined
		 * by the feature referenced by the art sprite. This is
		 * automatically called from AvatarDisplay when it
		 * draws.
		 */
		public function draw():void {
			if (_feature == null) {
				print("Cannot draw art sprite because feature is not defined", PrintLevel.WARNING, this);
				return;
			}
			_feature.drawArtSprite(this);
		}
		
		
		/**
		 * Clears all art content from the art sprite object
		 * and removes any references to other objects. This is
		 * automatically called when an AvatarDisplay removes
		 * the ArtSprite from its display list.
		 */
		public function deconstruct():void {
			clearContent();
			removeReferences();
		}
		
		private function removeReferences():void {
			_feature = null;
			_art = null;
		}
		
		private function contentCompleteHandler(event:Event):void {
			// update visually
			applyContentProperties();
			applyArtTransforms();
		}
		
		private function applyContentProperties():void {
			
			// smooth bitmaps?
			if (_art && content is Bitmap){
				Bitmap(content).smoothing = isNaN(_art.smoothing) || Boolean(_art.smoothing);
			}
			
			// go to specified content frame
			if (srcFrame && content is MovieClip){
				MovieClip(content).gotoAndStop(srcFrame);
			}
		}
		
		private function applyArtTransforms():void {
			if (_art == null) return;
			if (numChildren){
				
				// first child will be either an instantiated
				// display object or a Loader instance
				var mainContent:DisplayObject = getChildAt(0);
				mainContent.x = _art.x;
				mainContent.y = _art.y;
			}
		}
	}
}