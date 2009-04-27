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
	import com.myavatareditor.avatarcore.display.MirroredArtSprite;
	
	/**
	 * A variation of a feature definition that creates a mirrored duplicate
	 * (along y axis) of the definition's art.  This allows characteristics
	 * like eyes to be both graphically similar and to be transformed in 
	 * a synchronous fashion.  Transformations apply to the original
	 * art. The mirror is recreated to mirror the transformation applied.
	 * This is not a piece of the core framework, but an extension of it. As
	 * such, if referenced only in XML, you will need to be sure to include
	 * a reference of the class in your SWF so that it gets compiled into
	 * the SWF bytecode and is accessible when the XML is parsed.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class MirroredFeatureDefinition extends FeatureDefinition {
		
		public function MirroredFeatureDefinition() {
			
		}
		
		public override function getArtSprites(sprites:Array = null):Array {
			var sprites:Array = super.getArtSprites(sprites);
			
			// add additional sprites (the same ones again) for the mirror
			var origArt:ArtSprite;
			var mirrorArt:MirroredArtSprite;
			var i:int = sprites.length;
			while (i--){
				origArt = sprites[i] as ArtSprite;
				mirrorArt = new MirroredArtSprite(origArt.art, origArt.feature, origArt);
				sprites.push(mirrorArt);
			}
			return sprites;
		}
		
		public override function drawArtSprite(artSprite:ArtSprite):void {
			super.drawArtSprite(artSprite);
			var mirrorArt:MirroredArtSprite = artSprite as MirroredArtSprite;
			if (mirrorArt){
				mirrorArt.x = -mirrorArt.x;
				mirrorArt.scaleX = -mirrorArt.scaleX;
				mirrorArt.rotation = -mirrorArt.rotation;
			}
		}
	}
	
}