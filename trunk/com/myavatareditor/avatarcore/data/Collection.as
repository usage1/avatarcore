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
	
	import flash.events.EventDispatcher;
	
	/**
	 * Standard ICollection implementation.  When possible
	 * collection objects should extend Collection.  Collection
	 * classes contain a collection array for storing generic
	 * data of non-specific types.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Collection extends EventDispatcher implements ICollection {
		
		private var lookupAttribute:String = "name";
		
		public function get collection():Array {
			return _collection;
		}
		private var _collection:Array = [];
		
		public function Collection() {
			
		}
		
		public function addCollectionItem(item:*):* {
			if (item == null) return null;
			
			if (lookupAttribute in item){
				if (item[lookupAttribute] != null){
					var lookupKey:String = item[lookupAttribute];
					_collection[lookupKey] = item;
				}else{
					// if null, force lookup key to be the
					// index at which the item is stored
					// in the collection as an array
					item[lookupAttribute] = String(_collection.length);
				}
			}
			
			_collection.push(item);
			return item;
		}
		
		public function removeCollectionItem(item:*):* {
			if (item == null) return null;
			var itemFound:Boolean = false;
			
			if (lookupAttribute in item){
				var lookupKey:String = item[lookupAttribute];
				if (_collection[lookupKey] == item){
					delete _collection[lookupKey];
					itemFound = true;
				}
			}
			
			var index:int = _collection.indexOf(item);
			if (index != -1){
				_collection.splice(index, 1);
				itemFound = true;
			}
			
			return itemFound ? item : null;
		}
		
		public function collectionItemExists(item:*):Boolean {
			if (item == null) return false;
			
			if (lookupAttribute in item){
				var lookupKey:String = item[lookupAttribute];
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
		
		public function clearCollection():void {
			var key:String;
			for (key in _collection){
				delete _collection[key];
			}
			_collection.length = 0;
		}
	}
}