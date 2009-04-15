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
	import com.myavatareditor.avatarcore.events.FeatureDefinitionEvent;
	
	/**
	 * A collection of feature definitions associated with Avatar
	 * objects.  At any time an avatar can change its library to
	 * another allowing it to completely change it's style.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Library extends Collection {
		
		/**
		 * An array of FeatureDefinition objects located in
		 * the collection of this Library.
		 */
		public function getDefinitions():Array {
			var result:Array = [];
			var source:Array = this.collection;
			var definition:FeatureDefinition;
			var i:int, n:int = source.length;
			for (i=0; i<n; i++){
				definition = source[i] as FeatureDefinition;
				if (definition){
					result.push(definition);
				}
			}
			return result;
		}
		
		
		/**
		 * Constructor for new Library instances.
		 */
		public function Library() {
			
		}
		
		public override function addItem(item:*):* {
			var eventType:String;
			
			// remove existing item by name without events
			// assumes (forces) requireUniqueNames true
			var itemName:String = (Collection.nameKey in item) ? item[Collection.nameKey] : null;
			if (itemName && super.removeItemByName(itemName)) { 
				eventType = FeatureDefinitionEvent.FEATURE_DEFINITION_CHANGED;
			}else {
				eventType = FeatureDefinitionEvent.FEATURE_DEFINITION_ADDED;
			}
			
			var added:* = super.addItem(item);
			if (added is FeatureDefinition) {
				dispatchEvent(new FeatureDefinitionEvent(eventType, false, false, added as FeatureDefinition));
			}
			return added;
		}
		
		public override function removeItem(item:*):* {
			var removed:* = super.removeItem(item);
			if (removed is FeatureDefinition) {
				dispatchEvent(new FeatureDefinitionEvent(FeatureDefinitionEvent.FEATURE_DEFINITION_REMOVED, false, false, removed as FeatureDefinition));
			}
			return removed;
		}
	}
}