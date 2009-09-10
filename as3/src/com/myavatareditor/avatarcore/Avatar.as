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
	import com.myavatareditor.avatarcore.events.FeatureEvent;
	import com.myavatareditor.avatarcore.events.FeatureDefinitionEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Avatars contain the data describing avatar characters.
	 * Physical (visible) characteristics are defined by Feature instances
	 * contained within avatar collections. The visual representation 
	 * of an Avatar object is controlled by an AvatarDisplay instance
	 * which references the Avatar object to know what to display. Other
	 * qualities such as age, creator, weight, etc. can be added separately
	 * by developer's through subclassing Avatar. 
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
		 * The name of the library to be associated with this
		 * avatar.  Associations with libraries through this
		 * property are made when an Avatar instance is created
		 * within a Definitions object. Changing libraryName will
		 * not invoke a new lookup for the related library.
		 */
		public function get libraryName():String { 
			return _library ? _library.name : _libraryName;
		}
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
			var obj:Object = super.getPropertiesAsAttributesInXML();
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
				eventType = FeatureEvent.CHANGED;
			}else{
				eventType = FeatureEvent.ADDED;
			}
			
			var added:* = super.addItem(item);
			if (added is Feature) {
				var feature:Feature = added as Feature;
				
				// remove feature from any previous avatar
				var oldAvatar:Avatar = feature.avatar;
				if (oldAvatar && oldAvatar != this){
					oldAvatar.removeItem(feature);
				}
				
				// link feature to this avatar
				feature.avatar = this;
				coupleFeatureToLibrary(feature);
				updateParentHierarchy();
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
				dispatchEvent(new FeatureEvent(FeatureEvent.REMOVED, false, false, feature));
				feature.avatar = null;
				feature.definition = null;
			}
			return removed;
		}
		
		public function redrawFeature(feature:Feature):void {
			if (feature == null || feature.avatar != this) return;
			dispatchEvent(new FeatureEvent(FeatureEvent.CHANGED, false, false, feature));
		}
		
		/**
		 * Calls redrawFeature() for each Feature instance within this 
		 * Avatar instance.
		 */
		public function redrawFeatures():void {
			var feature:Feature;
			var features:Array = this.collection;
			var i:int = features.length;
			while (i--){
				redrawFeature(features[i] as Feature);
			}
		}
		
		/**
		 * Updates the parent hierarchy used within the features of the
		 * Avatar instance. If at any point in time, parents or parentName
		 * values change, the parent hierarchy will need to be updated so 
		 * that child features will be able to correctly reference their
		 * parents and be drawn after their parents are done drawing.
		 */
		public function updateParentHierarchy():void {
			var feature:Feature;
			var features:Array = this.collection;
			var i:int;
			
			// pass one: make sure all parent references are set
			i = features.length;
			while (i--){
				feature = features[i] as Feature;
				if (feature) feature.updateParent();
			}
			
			// pass two: update parent counts for drawing order
			i = features.length;
			while (i--){
				feature = features[i] as Feature;
				if (feature) feature.updateParentCount();
			}
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
				if (feature) feature.consolidate();
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
		
		private function coupleLibrary():void {
			// decoupling will occur if _library is null
			var i:int = collection.length;
			while (i--){
				coupleFeatureToLibrary(collection[i] as Feature);
			}
			updateParentHierarchy();
		}
		private function coupleFeatureToLibrary(feature:Feature):void {
			if (feature == null || !feature.name) return;
			feature.definition = _library ? _library.collection[feature.name] as FeatureDefinition : null;
		}
		
		private function setupLibrary():void {
			if (_library == null) return;
			_library.addEventListener(FeatureDefinitionEvent.ADDED, definitionChangedHandler, false, 0, true);
			_library.addEventListener(FeatureDefinitionEvent.CHANGED, definitionChangedHandler, false, 0, true);
			_library.addEventListener(FeatureDefinitionEvent.REMOVED, definitionChangedHandler, false, 0, true);
		}
		private function cleanupLibrary():void {
			if (_library == null) return;
			_library.removeEventListener(FeatureDefinitionEvent.ADDED, definitionChangedHandler, false);
			_library.removeEventListener(FeatureDefinitionEvent.CHANGED, definitionChangedHandler, false);
			_library.removeEventListener(FeatureDefinitionEvent.REMOVED, definitionChangedHandler, false);
		}
		
		private function definitionChangedHandler(definitionEvent:FeatureDefinitionEvent):void {
			// (de)couple feature of the definition name
			if (definitionEvent.featureDefinition) {
				var featureName:String = definitionEvent.featureDefinition.name;
				var feature:Feature = getItemByName(featureName) as Feature;
				if (feature){
					coupleFeatureToLibrary(feature);
					updateParentHierarchy();
					redrawFeature(feature);
				}
			}
		}
	}
}