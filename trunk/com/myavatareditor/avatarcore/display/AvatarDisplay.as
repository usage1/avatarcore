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
	import com.myavatareditor.avatarcore.FeatureDefinition;
	import com.myavatareditor.avatarcore.Library;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import com.myavatareditor.avatarcore.events.FeatureEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Dispatched when the AvatarDisplay redraws itself.  This usually occurs
	 * after receiving events, such as an Avatar.REBUILD or
	 * FeatureEvent.FEATURE_CHANGED from a referenced Avatar object.
	 */
	[Event(name="draw", type="flash.events.Event")]
	
	/**
	 * A controller and container display object for all art used in an avatar. 
	 * All avatar art exists as child sprite of this container, irrespective
	 * of their feature parent hierarchies.  Layering of art is based 
	 * solely on the defined zIndex values within the features' definitions.
	 * Without a zIndex, their ordering is up to chance.  Art for avatars is
	 * created in ArtSprite instances and added to the AvatarDisplay automatically
	 * as the avatar being referenced is updated.  Most of the API is not needed
	 * for normal use.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class AvatarDisplay extends Sprite {
		
		/**
		 * Constant for draw event type.
		 */
		public static const DRAW:String = "draw";
		
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
		private var artMapSortKey:String = "src";
		private var featureArtMap:Object = {};
		private var suppressDraw:Boolean = false;
		
		/**
		 * Constructor for creating new AvatarDisplay instances.
		 * @param	avatar
		 */
		public function AvatarDisplay(avatar:Avatar = null){
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
			
			suppressDraw = true;
			try {
			
				var features:Array = _avatar.collection;
				var feature:Feature;
				
				var i:int = features.length;
				while (i--){
					feature = features[i] as Feature;
					if (feature){
						addFeatureArtSprites(feature);
					}
				}
				
			}catch (error:Error){
				print("Avatar Rebuild; unknown error: " + error.message, PrintLevel.ERROR, this);
			}
			suppressDraw = false;
			
			draw();
		}
		
		/**
		 * Draws the art sprites in the avatar art updating their
		 * transformations as defined in their respective features.
		 * If a feature's art definition has changed, you should use
		 * updateFeatureArt method to update that feature.  draw()
		 * will automatically be called during those updates.
		 */
		public function draw():void {
			if (suppressDraw) return;
			var artSprite:ArtSprite;
			var i:int;
			
			// arrangement loop
			displayList.sortOn("zIndex", Array.NUMERIC);
			i = displayList.length;
			while (i--){
				artSprite = displayList[i] as ArtSprite;
				if (getChildIndex(artSprite) != i) {
					setChildIndex(artSprite, i);
				}
			}
			
			// draw loop (parents drawn first)
			displayList.sortOn("parentCount", Array.NUMERIC | Array.DESCENDING);
			i = displayList.length;
			while (i--){
				artSprite = displayList[i] as ArtSprite;
				//trace(artSprite.feature.name, artSprite.parentCount)
				artSprite.draw();
			}
			
			dispatchEvent(new Event(DRAW));
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
			featureArtMap = {};
		}
		
		/**
		 * Adds art related to a feature to the avatar art object.
		 * @param	feature Feature for which art is to be added
		 * @param	redraw When true, automatically draws the 
		 * sprite display list and updates arrangement.  Set this
		 * to false if you want to defer the drawing process for later.
		 */
		public function addFeatureArt(feature:Feature):void {
			if (feature == null){
				print("Adding Feature Art; invalid feature definition", PrintLevel.WARNING, this);
				return;
			}
			
			suppressDraw = true;
			try {
				
				addFeatureArtSprites(feature);
				
			}catch (error:Error){
				print("Avatar drawing; unknown error: " + error.message, PrintLevel.ERROR, this);
			}
			suppressDraw = false;
			
			draw();
		}
		
		private function addFeatureArtSprites(feature:Feature):void {
			
			// a new sprite list is returned from validateFeatureArt
			// if sprites returned by feature.getArtSprites doesn't
			// match the sprites currently being used to display the
			// feature (as dictated by src).  If those sprites differ
			// the feature is rebuilt
			var sprites:Array = validateFeatureArt(feature);
			if (sprites){
				removeFeatureArtByName(feature.name);
				
				var artSprite:ArtSprite;
				var i:int = sprites.length;
				while (i--){
					artSprite = sprites[i] as ArtSprite;
					displayList.push(artSprite);
					addChild(artSprite);
				}
			}
		}
		
		/**
		 * Validates a feature exists within the referenced avatar
		 * and updates it on the screen.
		 * @param	feature The feature having been modified. If the
		 * feature does not exist within the avatar, no action is taken.
		 */
		public function updateFeatureArt(feature:Feature):void {
			if (feature == null || _avatar == null) return;
			if (feature != _avatar.getItemByName(feature.name)) return;
			addFeatureArt(feature);
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
		}
		
		/**
		 * Returns all ArtSprite instances used by this ArtDisplay object
		 * to display the feature provided.  Each time a feature is changed
		 * these sprites may change as sprites used to represent features
		 * are rebuilt.
		 * @param	feature The feature for which to retrieve ArtSprites.
		 * @return An array of ArtSprite instances whose feature matches the
		 * one provided.
		 */
		public function getArtSpritesForFeature(feature:Feature):Array {
			var artSprites:Array = [];
			var artSprite:ArtSprite;
			var i:int = displayList.length;
			while (i--){
				artSprite = displayList[i] as ArtSprite;
				if (artSprite && artSprite.feature == feature){
					artSprites.push(artSprite);
				}
			}
			return artSprites;
		}
		
		/**
		 * Figures out if a feature's art has changed since the
		 * last time that feature has been drawn using a map of
		 * the feature's art sprites identified by src.
		 */
		private function validateFeatureArt(feature:Feature):Array {
			if (feature == null) return null;
			
			var featureName:String = feature.name;
			if (featureName){
				var currentSprites:Array = featureArtMap[featureName] as Array;
				var newSprites:Array = feature.getArtSprites();
				newSprites.sortOn(artMapSortKey); // spritesSrcMatch assumes sorted sprite lists
				
				if (spritesSrcMatch(newSprites, currentSprites)){
					return null;
				}else{
					featureArtMap[featureName] = newSprites;
					return newSprites;
				}
			}
			return null;
		}
		
		private function spritesSrcMatch(list1:Array, list2:Array):Boolean {
			if (list1 == null || list2 == null) return false;
			if (list1.length != list2.length) return false;
			var i:int = list1.length;
			while (i--){
				// only checking for changes in source references
				// changes in other properties are ignored
				if (ArtSprite(list1[i]).src != ArtSprite(list2[i]).src) return false;
			}
			return true;
		}
		
		private function setupAvatar():void {
			if (_avatar == null) return;
			_avatar.addEventListener(FeatureEvent.FEATURE_ADDED, featureAddedHandler, false, 0, true);
			_avatar.addEventListener(FeatureEvent.FEATURE_CHANGED, featureChangedHandler, false, 0, true);
			_avatar.addEventListener(FeatureEvent.FEATURE_REMOVED, featureRemovedHandler, false, 0, true);
			_avatar.addEventListener(Avatar.REBUILD, rebuildHandler, false, 0, true);
		}
		private function cleanupAvatar():void {
			if (_avatar == null) return;
			_avatar.removeEventListener(FeatureEvent.FEATURE_ADDED, featureAddedHandler, false);
			_avatar.removeEventListener(FeatureEvent.FEATURE_CHANGED, featureChangedHandler, false);
			_avatar.removeEventListener(FeatureEvent.FEATURE_REMOVED, featureRemovedHandler, false);
			_avatar.removeEventListener(Avatar.REBUILD, rebuildHandler, false);
		}
		
		private function featureAddedHandler(featureEvent:FeatureEvent):void {
			addFeatureArt(featureEvent.feature);
		}
		private function featureChangedHandler(featureEvent:FeatureEvent):void {
			updateFeatureArt(featureEvent.feature);
		}
		private function featureRemovedHandler(featureEvent:FeatureEvent):void {
			removeFeatureArt(featureEvent.feature);
		}
		private function rebuildHandler(event:Event):void {
			rebuild();
		}
	}
}