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
	
	import com.myavatareditor.avatarcore.data.Art;
	import com.myavatareditor.avatarcore.data.Avatar;
	import com.myavatareditor.avatarcore.data.Feature;
	import com.myavatareditor.avatarcore.data.FeatureDefinition;
	import com.myavatareditor.avatarcore.data.Library;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import com.myavatareditor.avatarcore.events.FeatureEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * A container display object for all art used in an avatar.  All
	 * avatar art exists as child sprite of this container, irrespective
	 * of their feature parent hierarchies.  Layering of art is based 
	 * solely on the defined zIndex values within the features' 
	 * definitions. Without a zIndex, their ordering is up to chance.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class AvatarArt extends Sprite {
		
		/**
		 * The avatar associated with the avatar art. The avatar
		 * art instance listens to events from the avatar object
		 * to determine when to update and redraw its art sprites.
		 */
		public function get avatar():Avatar {
			return _avatar;
		}
		public function set avatar(value:Avatar):void {
			if (value == _avatar) return;
			
			cleanupAvatar();
			_avatar = value;
			setupAvatar();
			
			if (_avatar){
				rebuild();
			}else{
				clearContent();
			}
		}
		private var _avatar:Avatar;
		
		private var displayList:Array = [];
		private var sortKey:String = "zIndex";
		
		public function AvatarArt(avatar:Avatar = null){
			this.avatar = avatar;
		}
		
		/**
		 * Completely rebuilds an avatar's art based on the
		 * avatar object referenced in the avatar property.
		 */
		public function rebuild():void {
			clearContent();
			
			if (_avatar == null) {
				print("Avatar Rebuild; no avatar data from which to build", PrintLevel.WARNING, this);
				return;
			}
			
			var features:Array = _avatar.collection;
			var feature:Feature;
			
			var i:int = features.length;
			while (i--){
				feature = features[i] as Feature;
				if (feature){
					addFeatureArt(feature, false);
				}
			}
			
			updateArtArrangement();
			draw();
		}
		
		/**
		 * Draws the art sprites in the avatar art
		 * updating their transformations as defined
		 * in their respective features. If a feature's 
		 * art definition has changed, you should use
		 * addFeatureArt or rebuild.
		 */
		public function draw():void {
			var artSprite:ArtSprite;
			var i:int = displayList.length;
			while (i--){
				artSprite = displayList[i] as ArtSprite;
				artSprite.draw();
			}
		}
		
		/**
		 * Clears all art content from the avatar art object
		 * and removes any references to other objects.
		 */
		public function deconstruct():void {
			clearContent();
			removeReferences();
		}
		
		private function removeReferences():void {
			displayList.length = 0;
			avatar = null;
		}
		
		private function clearContent():void {
			var artSprite:ArtSprite;
			while (numChildren){
				artSprite = removeChildAt(0) as ArtSprite;
				if (artSprite){
					artSprite.deconstruct();
				}
			}
			displayList.length = 0;
		}
		
		/**
		 * Adds art related to a feature to the avatar art object.
		 * @param	feature Feature for which art is to be added
		 * @param	redraw When true, automatically draws the 
		 * sprite display list and updates arrangement.  Set this
		 * to false if you want to defer the drawing process for later.
		 */
		public function addFeatureArt(feature:Feature, redraw:Boolean = true):void {
			if (feature == null){
				print("Adding Feature Art; invalid feature definition", PrintLevel.WARNING, this);
				return;
			}
			
			removeFeatureArtByName(feature.name);
			
			var sprites:Array = feature.getArtSprites();
			var artSprite:ArtSprite;
			var i:int = sprites.length;
			while (i--){
				artSprite = sprites[i] as ArtSprite;
				displayList.push(artSprite);
				addChild(artSprite);
			}
			
			if (redraw){
				draw();
				updateArtArrangement();
			}
		}
		
		/**
		 * Removes art for the feature passed from the avatar art.
		 * @param	feature The feature to match in art sprites
		 * that need to be removed.
		 */
		public function removeFeatureArt(feature:Feature):void {
			if (feature == null) return;
				
			var artSprite:ArtSprite;
			var i:int = displayList.length;
			while (i--){
				artSprite = displayList[i] as ArtSprite;
				if (artSprite.feature == feature){
					displayList.splice(i, 1);
					removeChild(artSprite);
					artSprite.deconstruct();
				}
			}
			
			draw();
			// removing from display list shouldn't
			// require rearrangement
		}
		
		/**
		 * Removes art for a feature using its name to 
		 * find all art of the same name and removing them from
		 * the avatar art.
		 * @param	featureName The feature name used to remove art 
		 * from the avatar art object.
		 */
		public function removeFeatureArtByName(featureName:String):void {
			if (featureName == null) return;
				
			var artSprite:ArtSprite;
			var i:int = displayList.length;
			while (i--){
				artSprite = displayList[i] as ArtSprite;
				if (artSprite.featureName == featureName){
					displayList.splice(i, 1);
					removeChild(artSprite);
					artSprite.deconstruct();
				}
			}
			
			draw();
			// removing from display list shouldn't
			// require rearrangement
		}
		
		/**
		 * Reorders art sprites based on the zIndex value
		 * specified in each sprite's respective Art definition.
		 */
		public function updateArtArrangement():void {
			var artSprite:ArtSprite;
			displayList.sortOn(sortKey, Array.NUMERIC);
			
			var i:int = displayList.length;
			while (i--){
				artSprite = displayList[i] as ArtSprite;
				if (getChildIndex(artSprite) != i) {
					setChildIndex(artSprite, i);
				}
			}
		}
		
		private function setupAvatar():void {
			if (_avatar == null) return;
			_avatar.addEventListener(FeatureEvent.FEATURE_ADDED, featureAddedHandler, false, 0, true);
			_avatar.addEventListener(FeatureEvent.FEATURE_CHANGED, featureAddedHandler, false, 0, true);
			_avatar.addEventListener(FeatureEvent.FEATURE_REMOVED, featureRemovedHandler, false, 0, true);
			_avatar.addEventListener(FeatureEvent.FEATURE_TRANSFORMED, drawFeatureHandler, false, 0, true);
			_avatar.addEventListener(Avatar.REBUILD, rebuildHandler, false, 0, true);
		}
		private function cleanupAvatar():void {
			if (_avatar == null) return;
			_avatar.removeEventListener(FeatureEvent.FEATURE_ADDED, featureAddedHandler, false);
			_avatar.removeEventListener(FeatureEvent.FEATURE_CHANGED, featureAddedHandler, false);
			_avatar.removeEventListener(FeatureEvent.FEATURE_REMOVED, featureRemovedHandler, false);
			_avatar.removeEventListener(FeatureEvent.FEATURE_TRANSFORMED, drawFeatureHandler, false);
			_avatar.removeEventListener(Avatar.REBUILD, rebuildHandler, false);
		}
		
		private function featureAddedHandler(featureEvent:FeatureEvent):void {
			addFeatureArt(featureEvent.feature);
		}
		private function featureRemovedHandler(featureEvent:FeatureEvent):void {
			removeFeatureArt(featureEvent.feature);
		}
		private function rebuildHandler(event:Event):void {
			rebuild();
		}
		private function drawFeatureHandler(featureEvent:FeatureEvent):void {
			draw();
		}
	}
}