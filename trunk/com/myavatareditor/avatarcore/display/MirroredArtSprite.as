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
	
	import com.myavatareditor.avatarcore.data.Feature;
	import com.myavatareditor.avatarcore.data.Art;
	
	/**
	 * ArtSprite for mirrored art defined in a
	 * MiiroredFeatureDefinition.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class MirroredArtSprite extends ArtSprite {
		
		/**
		 * A reference to the ArtSprite this object mirrors.
		 */
		public var mirror:ArtSprite;
		
		/**
		 * Constructor for creating new MirroredArtSprite instances.
		 * @param	art
		 * @param	feature
		 * @param	mirror
		 */
		public function MirroredArtSprite(art:Art = null, feature:Feature = null, mirror:ArtSprite = null) {
			this.mirror = mirror;
			super(art, feature);
		}
	}
}