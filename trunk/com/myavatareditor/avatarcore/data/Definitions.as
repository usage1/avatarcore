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
	
	/**
	 * A collection of definitions such as Library and Avatar instances 
	 * to be used with the Avatar Core framework. These are typically 
	 * definitions acquired from XML.  One specific feature of the Definitions
	 * class is that it handles the linking of Library and Avatar instances
	 * when an avatar is added to the Definitions collection and a Library
	 * exists within the collection with the name specified in 
	 * Avatar.libraryName.  Upon adding that avatar, it's library is set to
	 * that respective Library instance.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Definitions extends Collection {
		
		/**
		 * Custom addItem which creates associations with avatars
		 * and libraries when avatars specify a libraryName.
		 * @param	item The item to be added to the collection.
		 * @return The item added to the collection.
		 */
		public override function addItem(item:*):* {
			var avatarItem:Avatar;
			
			if (item is Avatar){
				
				// associate avatar with library
				avatarItem = item as Avatar;
				var library:Library = getItemByName(avatarItem.libraryName) as Library;
				if (library){
					avatarItem.library = library;
				}
				
			}else if (item is Library){
				
				// work the other way around, associating
				// new libraries with any avatars
				var libraryItem:Library = item as Library;
				var libraryName:String = libraryItem.name;
				if (libraryName){
					var avatars:Array = getItemsByType(Avatar);
					var i:int = avatars.length;
					while (i--){
						avatarItem = avatars[i] as Avatar;
						if (avatarItem.libraryName == libraryName){
							avatarItem.library = libraryItem;
						}
					}
				}
			}
			
			return super.addItem(item);
		}
		
		/**
		 * Constructor for creating new Definition instances. 
		 * Definition instances are typically created through
		 * XML.
		 */
		public function Definitions() {
			
		}
	}
}