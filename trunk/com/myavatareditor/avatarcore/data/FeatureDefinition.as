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
	
	import com.myavatareditor.avatarcore.display.ArtSprite;
	import flash.geom.Rectangle;
	
	/**
	 * Defines guidelines for avatar features.  The guidelines include
	 * possible art, color selections and constraints for art
	 * transforms.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class FeatureDefinition {
		
		public var name:String;
		public var parentName:String;
		
		public var transform:Transform = new Transform();
		public var artSet:ArtSet = new ArtSet();
		public var colorSet:ColorSet = new ColorSet();
		public var constraint:Constraint = new Constraint();
		
		public function FeatureDefinition() {
			
		}
		
		/**
		 * Returns the art sprites needed to represent this 
		 * feature definition.
		 * @param	sprites Any set of pre-existing art sprites
		 * assumed to be necessary for the definition, which in
		 * most cases should be those created from a Feature.
		 * @return An array of art sprites.
		 */
		public function getArtSprites(sprites:Array = null):Array {
			if (sprites == null){
				sprites = [];
			}
			return sprites;
		}
		
		public function drawArtSprite(artSprite:ArtSprite):void {
			if (artSprite == null) return;
			
			// restrict to constraints
			if (constraint){
				
				// position
				if (constraint.position){
					if (artSprite.x < constraint.position.left){
						artSprite.x = constraint.position.left;
					}else if (artSprite.x > constraint.position.right){
						artSprite.x = constraint.position.right;
					}
					if (artSprite.y < constraint.position.top){
						artSprite.y = constraint.position.top;
					}else if (artSprite.y > constraint.position.bottom){
						artSprite.y = constraint.position.bottom;
					}
				}
				
				// rotation
				if (constraint.rotation){
					if (artSprite.rotation > constraint.rotation.max){
						artSprite.rotation = constraint.rotation.max;
					}else if (artSprite.rotation < constraint.rotation.min){
						artSprite.rotation = constraint.rotation.min;
					}
				}
				
				// scale
				if (constraint.scale){
					if (artSprite.scaleX > constraint.scale.max){
						artSprite.scaleX = artSprite.scaleY = constraint.scale.max;
					}else if (artSprite.scaleX < constraint.scale.min){
						artSprite.scaleX = artSprite.scaleY = constraint.scale.min;
					}
				}
			}
		}
	}
}