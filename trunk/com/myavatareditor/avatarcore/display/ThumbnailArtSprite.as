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
package com.myavatareditor.avatarcore.display {
	
	import com.myavatareditor.avatarcore.Art;
	import com.myavatareditor.avatarcore.Avatar;
	import com.myavatareditor.avatarcore.Feature;
	
	/**
	 * A variation of ArtSprite that loads the thumbnail 
	 * of an Art instance.  If no thumbnail is available, the src
	 * of the Art instance is loaded. If neither the thumbnail nor
	 * the src is available, and the Art instance contains other
	 * Art instances, those instances will be rendered within a
	 * custom, child AvatarDisplay consisting of only those child art
	 * assets contained within a rendered Avatar.
	 * This class is used only to display thumbnails of an Art instance.
	 * It is not for use within an AvatarDisplay object. 
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class ThumbnailArtSprite extends SourceLoaderSprite {
		
		/**
		 * Art object associated with this art sprite. This
		 * and the feature should be set at the same time if
		 * the art for this sprite is changed so that they
		 * remain congruent.  When set, the thumbnail of the
		 * art is loaded into the ThumbnailArtSprite instance.
		 */
		public function get art():Art {
			return _art;
		}
		public function set art(value:Art):void {
			if (value == _art) return;
			
			_art = value;
			if (_art){
				if (_art.thumbnail){
					this.src = _art.thumbnail;
				}else if (_art.src){
					this.src = art.src;
				}else{
					this.src = null;
					
					// if the art collection contains
					// other Art instances, render them
					// in a custom Avatar instance
					var childArts:Array = _art.getItemsByType(Art);
					if (childArts.length){
						generateAvatarContent();
					}
				}
			}else{
				this.src = null;
			}
		}
		private var _art:Art;
		
		/**
		 * Constructor for new ThumbnailArtSprite instances.
		 * @param	art The art instance to render a thumbnail for.
		 */
		public function ThumbnailArtSprite(art:Art = null, autoLoad:Boolean = false) {
			super(null);
			
			mouseChildren = false;
			if (art) {
				this.art = art;
				if (autoLoad) load();
			}
		}
		
		private function generateAvatarContent():void {
			var avatar:Avatar = new Avatar();
			var feature:Feature = new Feature();
			feature.art = _art;
			avatar.addItem(feature);
			
			var avatarDisplay:AvatarDisplay = new AvatarDisplay(avatar);
			addChild(avatarDisplay);
		}
	}
}