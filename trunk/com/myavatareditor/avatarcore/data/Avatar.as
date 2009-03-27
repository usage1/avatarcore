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
	
	import com.myavatareditor.avatarcore.data.Collection;
	import com.myavatareditor.avatarcore.display.AvatarArt;
	import com.myavatareditor.avatarcore.events.FeatureEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Represents an avatar.  An Avatar instance contains the feature
	 * definitions for an avatar and manages interaction with those 
	 * features such as adding, removing, and changing.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Avatar extends Collection {
		
		public static const REBUILD:String = "rebuild";
		public static const LIBRARY_CHANGED:String = "libraryChanged";
		
		public var name:String;
		public var creator:String;
		
		/**
		 * Library associated with this avatar.  When a new
		 * library is defined, that library is coupled with
		 * the avatar instance and each Feature it contains
		 * gets updated with the library's definitions.
		 * When set, both a Avatar.REBUILD event and a
		 * Avatar.LIBRARY_CHANGED event are dispatched.
		 */
		public function get library():Library {
			return _library;
		}
		public function set library(value:Library):void {
			if (value == _library) return;
			
			_library = value;
			
			rebuild();
			dispatchEvent(new Event(LIBRARY_CHANGED));
		}
		private var _library:Library;
		
		
		
		public function Avatar(library:Library = null) {
			this.library = library;
		}
		
		
		
		/**
		 * Adds a feature to or replaces a feature in the makeup of
		 * the avatar.  If a feature by the same name of the feature
		 * passed already exists within the avatar, it is removed.
		 * When adding a new feature, a FeatureEvent.FEATURE_ADDED
		 * event is added.  If the feature already exists and is 
		 * removed, instead of dispatching both the
		 * FeatureEvent.FEATURE_REMOVED and FeatureEvent.FEATURE_ADDED 
		 * events, a single FeatureEvent.FEATURE_CHANGED event is
		 * dispatched.
		 * @param	feature Feature to be a part of this
		 * avatar.
		 */
		public function addFeature(feature:Feature):void {
			if (feature == null) return;
			var eventType:String = FeatureEvent.FEATURE_ADDED;
			
			if (silentRemoveFeature(feature)){
				eventType = FeatureEvent.FEATURE_CHANGED;
			}
			
			addCollectionItem(feature);
			dispatchEvent(new FeatureEvent(eventType, false, false, feature));
		}
		
		/**
		 * Removes a feature from the makeup of the avatar. If the
		 * feature is found and removed, a FeatureEvent.FEATURE_REMOVED
		 * event is dispatched.
		 * @param	feature Feature to be removed from this
		 * avatar.
		 */
		public function removeFeature(feature:Feature):void {
			if (feature == null) return;
			
			if (silentRemoveFeature(feature)){
				dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_REMOVED, false, false, feature));
			}
		}
		
		/**
		 * Removes a feature from the makeup of the avatar by it's feature name.
		 * If the feature is found and removed, a FeatureEvent.FEATURE_REMOVED
		 * event is dispatched.
		 * @param	featureName Name of the feature to be removed from this
		 * avatar.
		 */
		public function removeFeatureByName(name:String):void {
			removeFeature(getFeatureByName(name));
		}
		
		private function silentRemoveFeature(feature:Feature):Boolean {
			return Boolean(removeCollectionItem(feature) != null);
		}
		
		/**
		 * Returns a feature in the avatar by its name.
		 * @param	key Name of the feature as stored in the
		 * avatar's collection
		 * @return The feature in the avatar by the specified
		 * name if it exists, otherwise null.
		 */
		public function getFeatureByName(name:String):Feature {
			return collection[name] as Feature;
		}
		
		/**
		 * Indicates to Avatar stakeholders that a feature has been 
		 * changed.  This does not modify the Avatar instance itself,
		 * just sends out the respective event so that other objects
		 * can react to data (features) within the avatar being modified.
		 * When art is not changed, the event dispatched is
		 * FeatureEvent.FEATURE_TRANSFORMED.  For changing art,
		 * FeatureEvent.FEATURE_CHANGED is dispatched.
		 * @param	feature The feature having been modified. If the
		 * feature does not exist within the avatar, no action is taken.
		 * @param	rebuildArt Indicates whether or not the art for the
		 * feature have changed and needs to be redrawn. This can mean the
		 * actual Art object definitions in the FeatureDefinition object or
		 * just changing the variation for the specified feature - whatever
		 * requires the actual content of the art (not color or other
		 * transformations) to be rebuilt or reloaded.
		 */
		public function refreshFeature(feature:Feature, rebuildArt:Boolean = false):void {
			if (feature == null) return;
			if (feature != getFeatureByName(feature.name)) return;
			var eventType:String = rebuildArt ? FeatureEvent.FEATURE_CHANGED : FeatureEvent.FEATURE_TRANSFORMED;
			dispatchEvent(new FeatureEvent(eventType, false, false, feature));
		}
		
		/**
		 * Rebuilds an avatar definition by reassociating the
		 * avatar's library with its feature definitions. After
		 * rebuilding, a Avatar.REBUILD event is dispatched.
		 */
		public function rebuild():void {
			coupleLibrary();
			dispatchEvent(new Event(REBUILD));
		}
		
		private function coupleLibrary():void {
			// decoupling will occur if _library is null
			var feature:Feature;
			var i:int = collection.length;
			while (i--){
				feature = collection[i] as Feature;
				if (feature){
					feature.definition = _library ? _library.collection[feature.name] as FeatureDefinition : null;
				}
			}
		}
	}
}