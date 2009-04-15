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
	import com.myavatareditor.avatarcore.events.FeatureDefinitionEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Represents an avatar.  An Avatar instance contains the feature
	 * definitions for an avatar and manages interaction with those 
	 * features such as adding, removing, and changing.  The actual 
	 * visual representation of Avatars is controlled by AvatarArt 
	 * instances which reference Avatar objects to know what to display.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Avatar extends Collection {
		
		/**
		 * Rebuild event constant.
		 */
		public static const REBUILD:String = "rebuild";
		
		/**
		 * Changed library event constant.
		 */
		public static const LIBRARY_CHANGED:String = "libraryChanged";
		
		/**
		 * The name provided to the avatar character as defined
		 * by the user that created the avatar.
		 */
		public var name:String;
		
		/**
		 * The name of the user that created the avatar.
		 */
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
			
			cleanupLibrary();
			_library = value;
			setupLibrary();
			
			rebuild();
			dispatchEvent(new Event(LIBRARY_CHANGED));
		}
		private var _library:Library;
		
		/**
		 * Constructor for creating new Avatar instances.
		 * @param	library Library to be associated with the
		 * Avatar instance.
		 */
		public function Avatar(library:Library = null) {
			this.library = library;
		}
		
		public override function getPropertiesIgnoredByXML():Object {
			var obj:Object = super.getPropertiesIgnoredByXML();
			obj.library = 1;
			return obj;
		}
		
		public override function getPropertiesAsAttributesInXML():Object {
			var obj:Object = super.getPropertiesIgnoredByXML();
			delete obj.name;
			return obj;
		}
		
		public override function addItem(item:*):* {
			var eventType:String;
			
			// remove existing item by name without events
			// assumes (forces) requireUniqueNames true
			var itemName:String = (Collection.nameKey in item) ? item[Collection.nameKey] : null;
			if (itemName && super.removeItemByName(itemName)) { 
				eventType = FeatureEvent.FEATURE_CHANGED;
			}else {
				eventType = FeatureEvent.FEATURE_ADDED;
			}
			
			var added:* = super.addItem(item);
			if (added is Feature) {
				var feature:Feature = added as Feature;
				coupleFeatureToLibrary(feature);
				dispatchEvent(new FeatureEvent(eventType, false, false, feature));
			}
			return added;
		}
		
		public override function removeItem(item:*):* {
			var removed:* = super.removeItem(item);
			if (removed is Feature) {
				dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_REMOVED, false, false, removed as Feature));
			}
			return removed;
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
			if (feature != getItemByName(feature.name)) return;
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
			var i:int = collection.length;
			while (i--){
				coupleFeatureToLibrary(collection[i] as Feature);
			}
		}
		private function coupleFeatureToLibrary(feature:Feature):void {
			if (feature == null || !feature.name) return;
			feature.definition = _library ? _library.collection[feature.name] as FeatureDefinition : null;
		}
		
		private function setupLibrary():void {
			if (_library == null) return;
			_library.addEventListener(FeatureDefinitionEvent.FEATURE_DEFINITION_ADDED, definitionChangedHandler, false, 0, true);
			_library.addEventListener(FeatureDefinitionEvent.FEATURE_DEFINITION_CHANGED, definitionChangedHandler, false, 0, true);
			_library.addEventListener(FeatureDefinitionEvent.FEATURE_DEFINITION_REMOVED, definitionChangedHandler, false, 0, true);
		}
		private function cleanupLibrary():void {
			if (_library == null) return;
			_library.removeEventListener(FeatureDefinitionEvent.FEATURE_DEFINITION_ADDED, definitionChangedHandler, false);
			_library.removeEventListener(FeatureDefinitionEvent.FEATURE_DEFINITION_CHANGED, definitionChangedHandler, false);
			_library.removeEventListener(FeatureDefinitionEvent.FEATURE_DEFINITION_REMOVED, definitionChangedHandler, false);
		}
		
		private function definitionChangedHandler(definitionEvent:FeatureDefinitionEvent):void {
			// (de)couple feature of the definition name
			if (definitionEvent.definition) {
				var featureName:String = definitionEvent.definition.name;
				var feature:Feature = getItemByName(featureName) as Feature;
				if (feature){
					coupleFeatureToLibrary(feature);
					refreshFeature(feature, true);
				}
			}
		}
	}
}