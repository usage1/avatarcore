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
	
	/**
	 * A collection of Art Group objects for feature definitions.
	 * When Art objects are added to an ArtSet collection, they are 
	 * automatically wrapped in ArtGroup objects which inherit the Art
	 * object's name property.  Additionally, if any Art object added 
	 * in this manner, or any Art object within an ArtGroup added to
	 * the collection will have it's zIndex value set to zIndex of the
	 * ArtSet if it's own zIndex is NaN.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class ArtSet extends Collection {
		
		public var name:String;
		public var zIndex:Number; // default: NaN
		public var colorize:Number; // default: NaN
		
		public function ArtSet() {
			
		}
		
		public override function addCollectionItem(item:*):* {
			var artItem:Art;
			var groupItem:ArtGroup;
			
			if (item is Art) {
				artItem = item as Art;
				
				// assign inherited default properties
				assignDefaults(artItem);
				
				// shortcut for automatically adding ArtGroup
				// wrappers is an art is added to an ArtSet
				// Only the addCollectionItem method has this
				// functionalty; other methods will reference
				// the ArtGroup created here.
				var wrapper:ArtGroup = new ArtGroup();
				wrapper.name = artItem.name;
				wrapper.addCollectionItem(artItem);
				item = wrapper;
				
			}else if (item is ArtGroup) {
				groupItem = item as ArtGroup;
				
				// assign defaults to group's art
				var i:int = groupItem.collection.length;
				while (i--) {
					artItem = groupItem.collection[i] as Art;
					assignDefaults(artItem);
				}
			}
			
			return super.addCollectionItem(item);
		}
		
		private function assignDefaults(art:Art):void {
			
			if (art == null) return;
			if (isNaN(zIndex) == false && isNaN(art.zIndex)) {
				art.zIndex = zIndex;
			}
			if (isNaN(colorize) == false && isNaN(art.colorize)) {
				art.colorize = colorize;
			}
		}
	}
}