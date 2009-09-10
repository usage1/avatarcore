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
	import com.myavatareditor.avatarcore.events.FeatureDefinitionEvent;
	
	/**
	 * A collection of FeatureDefinition objects to be associated with an Avatar
	 * object's Feature objects.  At any time an avatar can change its library to
	 * another allowing it to completely change it's appearance.  Libraries are 
	 * not required for avatars; avatars can optionally reference Art, Color, and 
	 * Adjust objects directly. Using library reduces redundancy between available
	 * assets and those used by avatars.  Libraries also allow avatar editors to
	 * know what characteristics are available to avatars as users modify them.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Library extends Collection {
		
		/**
		 * Constructor for new Library instances.
		 */
		public function Library() {
			
		}
		
		/**
		 * Custom addItem for Library objects that dispatches the appropriate
		 * ADDED or ADDED events
		 * depending on whether or not the item already exists within the
		 * library collection.
		 * @param	item
		 * @return
		 */
		public override function addItem(item:*):* {
			var eventType:String;
			
			// remove existing item by name without events
			// assumes (forces) requireUniqueNames true
			var itemName:String = (Collection.nameKey in item) ? item[Collection.nameKey] : null;
			if (itemName && super.removeItemByName(itemName)) { 
				eventType = FeatureDefinitionEvent.CHANGED;
			}else {
				eventType = FeatureDefinitionEvent.ADDED;
			}
			
			var added:* = super.addItem(item);
			if (added is FeatureDefinition) {
				dispatchEvent(new FeatureDefinitionEvent(eventType, false, false, added as FeatureDefinition));
			}
			return added;
		}
		
		/**
		 * Custom removeItem for Library objects that dispatches the
		 * REMOVED event for FeatureDefinition objects
		 * removed from the library collection.
		 * @param	item
		 * @return
		 */
		public override function removeItem(item:*):* {
			var removed:* = super.removeItem(item);
			if (removed is FeatureDefinition) {
				dispatchEvent(new FeatureDefinitionEvent(FeatureDefinitionEvent.REMOVED, false, false, removed as FeatureDefinition));
			}
			return removed;
		}
	}
}