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
	
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.events.EventDispatcher;
	
	/**
	 * Standard ICollection implementation.  When possible
	 * collection objects should extend Collection.  Collection
	 * classes contain a collection array for storing generic
	 * data of non-specific types.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Collection extends EventDispatcher implements ICollection, IXMLWritable {
		
		/**
		 * The name of the property used to reference values
		 * within the collection by string key (as a hash).
		 */
		public static const nameKey:String = "name";
		
		/**
		 * When true, new items of the same name of existing
		 * items will cause the existing items to be removed
		 * before added to the collection themselves.
		 */
		public var requireUniqueNames:Boolean = true;
		
		/**
		 * Collection array where items are stored.  Items are
		 * stored both by index and by name.
		 */
		public function get collection():Array {
			return _collection;
		}
		private var _collection:Array = [];
		
		public function getPropertiesIgnoredByXML():Object {
			return {requireUniqueNames:1, collection:1};
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {name:1};
		}
		
		public function getObjectAsXML():XML {
			return null;
		}
		
		/**
		 * Constructor for creating new Collection instances. 
		 * Usually the Collection class is used as a superclass;
		 * it is not common that you would create a new
		 * Collection instance.
		 */
		public function Collection() {
			
		}
		
		/**
		 * Adds an object to the collection.  The object
		 * must be non-null.  If the lookup attribute
		 * (i.e. name) exists within the object, that value
		 * is used as a key within the collection.  If this
		 * name is changed before the object is removed from 
		 * the collection you may run into a situation where
		 * the object will continue to exist within the
		 * collection even if used with removeItem. In
		 * other words, the name value should not be modified
		 * for collection items.  If the name is not set, the 
		 * name will automatically be defined as the item's numeric
		 * location within the collection array.
		 * @param	item The object to be added to the collection.
		 * @return The object added to the collection.
		 */
		public function addItem(item:*):* {
			if (item == null) return null;
			
			if (nameKey in item){
				if (item[nameKey] != null) {
					
					var lookupKey:String = item[nameKey];
					// remove existing item of the same name if necessary
					if (requireUniqueNames) {
						removeItemByName(lookupKey);
					}
					_collection[lookupKey] = item;
					
				}else{
					// if null, force lookup key to be the
					// index at which the item is stored
					// in the collection as an array
					item[nameKey] = String(_collection.length);
				}
			}
			
			_collection.push(item);
			return item;
		}
		
		/**
		 * Returns true if an item exists within the collection.
		 * Returns false if it does not.
		 * @param	item The item to determine if within the
		 * collection.
		 * @return True if item exists within the collection, 
		 * otherwise false.
		 */
		public function collectionItemExists(item:*):Boolean {
			if (item == null) return false;
			
			if (nameKey in item){
				var lookupKey:String = item[nameKey];
				if (_collection[lookupKey] == item){
					return true;
				}
			}
			
			var index:int = _collection.indexOf(item);
			if (index != -1){
				return true;
			}
			
			return false;
		}
		
		/**
		 * Finds an item in the collection by name and returns it.
		 * @param	key The name of the item (as specified
		 * by it's name property) to be returned.
		 * @return The item found in the collection. If the item
		 * is not within the collection, null is returned.
		 */
		public function getItemByName(key:String):* {
			if (!key) return null;
			return _collection[key] as Object;
		}
		
		/**
		 * Finds items in a collection of a specific type and 
		 * returns an array of those items.
		 * @param	type The type of items to find in the collection.
		 * @return An array of collection items of the type provided.
		 */
		public function getItemsByType(type:Class):Array {
			var items:Array = [];
			var i:int, n:int = _collection.length;
			for (i=0; i<n; i++){
				var value:Object = _collection[i] as type;
				if (value){
					items.push(value);
				}
			}
			return items;
		}
		
		/**
		 * Removes an item from the collection.
		 * @param	item The item to remove from the collection.
		 * @return The item removed.  If the item is not within
		 * the collection, null is returned.
		 */
		public function removeItem(item:*):* {
			if (item == null) return null;
			var itemFound:Boolean = false;
			
			// item by key
			if (nameKey in item){
				var lookupKey:String = item[nameKey];
				if (_collection[lookupKey] == item){
					delete _collection[lookupKey];
					itemFound = true;
				}
			}
			
			// item by index
			var index:int = _collection.indexOf(item);
			if (index != -1){
				_collection.splice(index, 1);
				itemFound = true;
			}
			
			return itemFound ? item : null;
		}
		
		/**
		 * Removes an item within a collection by its name.
		 * @param	key The name of the item (as specified
		 * by it's name property) to be removed.
		 * @return The item removed.  If the item is not within
		 * the collection, null is returned.
		 */
		public function removeItemByName(key:String):* {
			return removeItem(getItemByName(key));
		}
		
		/**
		 * Removes all items from the collection.
		 */
		public function clearCollection():void {
			var key:String;
			for (key in _collection){
				delete _collection[key];
			}
			_collection.length = 0;
		}
	}
}