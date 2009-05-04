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
	
	import com.myavatareditor.avatarcore.Collection;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import com.myavatareditor.avatarcore.display.AvatarArt;
	import com.myavatareditor.avatarcore.events.FeatureEvent;
	import com.myavatareditor.avatarcore.events.FeatureDefinitionEvent;
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Avatars contain the data describing avatar characters.
	 * Physical (visible) characteristics are defined by Feature instances
	 * contained within avatar collections. The visual representation 
	 * of an Avatar object is controlled by an AvatarArt instance
	 * which references the Avatar object to know what to display. Other
	 * qualities such as age, creator, weight, etc. can be added separately
	 * by developer's through subclassing Avatar. 
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Avatar extends Collection implements IXMLWritable {
		
		/**
		 * Rebuild event constant.
		 */
		public static const REBUILD:String = "rebuild";
		
		/**
		 * Changed library event constant.
		 */
		public static const LIBRARY_CHANGED:String = "libraryChanged";
		
		/**
		 * The name of the library to be associated with this
		 * avatar.  Associations with libraries through this
		 * property are made when an Avatar instance is created
		 * within a Definitions object.
		 */
		public function get libraryName():String { return _libraryName; }
		public function set libraryName(value:String):void {
			_libraryName = value;
		}
		private var _libraryName:String;
		
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
		
		public override function toString():String {
			return "[Avatar name:" + name + "]";
		}
		
		public override function getPropertiesIgnoredByXML():Object {
			var obj:Object = super.getPropertiesIgnoredByXML();
			obj.library = 1;
			return obj;
		}
		
		public override function getPropertiesAsAttributesInXML():Object {
			var obj:Object = super.getPropertiesIgnoredByXML();
			obj.libraryName = 1;
			return obj;
		}
		
		/**
		 * Custom add item that will dispatch events for Feature instances
		 * added to the Avatar's collection.  If another Feature instance
		 * already exists within the avatar of the same name, that feature
		 * is replaced with the new feature and a FEATURE_CHANGED event is 
		 * dispatched.  If a Feature is added with a unique name, a
		 * FEATURE_ADDED event is dispatched.  Features added to the 
		 * avatar's collection are automatically associated with this avatar
		 * and the library assigned to the avatar if one exists (defining
		 * Feature.definition).
		 * @param	item Object to add to the avatar's collection.
		 * @return Item added to the collection.
		 */
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
				feature.avatar = this;
				coupleFeatureToLibrary(feature);
				dispatchEvent(new FeatureEvent(eventType, false, false, feature));
			}
			return added;
		}
		
		/**
		 * Custom removeItem method that removes an item from the
		 * Avatar's collection. If that item is of the type Feature
		 * a FEATURE_REMOVED event is dispatched.  Values set up in
		 * Avatar.addItem, such as Feature.avatar and Feature.definition
		 * are set to null.
		 * @param	item Object to be removed from the collection.
		 * @return Item removed if an item is removed. Null is returned
		 * if no item is removed.
		 */
		public override function removeItem(item:*):* {
			var removed:* = super.removeItem(item);
			if (removed is Feature) {
				var feature:Feature = removed as Feature;
				dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_REMOVED, false, false, feature));
				feature.avatar = null;
				feature.definition = null;
			}
			return removed;
		}
		
		/**
		 * Indicates to Avatar stakeholders (i.e. AvatarArt) that a feature
		 * has been  changed.  This does not modify the Avatar instance itself,
		 * just validates the feature as being a feature within this avatar and
		 * then sends out the respective FEATURE_CHANGED event so that other
		 * objects can react to data (feature) within the avatar being modified.
		 * @param	feature The feature having been modified. If the
		 * feature does not exist within the avatar, no action is taken.
		 */
		public function updateFeature(feature:Feature):void {
			if (feature == null) return;
			
			// if feature has no defined name, feature.name should still
			// exist since its enforced in Collection.addItem
			if (feature != getItemByName(feature.name)) {
				print(feature + " cannot be updated because it is not present in " + this, PrintLevel.WARNING, this);
				return;
			}
			dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_CHANGED, false, false, feature));
		}
		
		/**
		 * Calls updateFeature() for all Feature instances within this 
		 * Avatar instance.
		 */
		public function updateFeatures():void {
			var feature:Feature;
			var features:Array = this.collection;
			var i:int = features.length;
			while (i--){
				feature = features[i] as Feature;
				if (feature){
					updateFeature(feature);
				}
			}
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
		
		/**
		 * Calls Feature.consolidate on all features within the
		 * avatar.  This would be used to create a self-contained
		 * version of the avatar that would be able to be displayed 
		 * without the library.
		 */
		public function consolidateFeatures():void {
			var feature:Feature;
			var features:Array = this.collection;
			var i:int = features.length;
			while (i--){
				feature = features[i] as Feature;
				if (feature){
					feature.consolidate();
				}
			}
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
			if (definitionEvent.featureDefinition) {
				var featureName:String = definitionEvent.featureDefinition.name;
				var feature:Feature = getItemByName(featureName) as Feature;
				if (feature){
					coupleFeatureToLibrary(feature);
					updateFeature(feature);
				}
			}
		}
	}
}