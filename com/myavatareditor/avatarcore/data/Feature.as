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
	
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import com.myavatareditor.avatarcore.display.ArtSprite;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	/**
	 * Represents a feature within an avatar.  Features describe a part
	 * of how an avatar is represented through physical transformations
	 * and other information through a referenced FeatureDefinition.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Feature {
		
		public var name:String; // maps to name of FeatureDefinition
		public var colorName:String = "0"; // defaults to first
		public var artName:String = "0"; // defaults to first
		public var artStyle:String; // defaults to not using
		
		public var transform:Transform = new Transform(Number.NaN, Number.NaN, Number.NaN, Number.NaN);
		public var color:Color = new Color();
		public var artGroup:ArtGroup = new ArtGroup();
		
		public function get definition():FeatureDefinition {
			return _definition;
		}
		public function set definition(value:FeatureDefinition):void {
			_definition = value;
			
			if (_definition){
				
				// fill holes of current transform with default
				transform.fill(_definition.transform || new Transform());
				
				// inherit name of definition if not defined here
				if (!name){
					name = _definition.name;
				}
			}
		}
		private var _definition:FeatureDefinition;

		public function Feature(definition:FeatureDefinition = null) {
			this.definition = definition;
		}
		
		/**
		 * Returns the art sprites needed to represent this feature.
		 * @param	sprites Any set of pre-existing art sprites
		 * assumed to be necessary for the feature.
		 * @return An array of art sprites.
		 */
		public function getArtSprites(sprites:Array = null):Array {
			if (sprites == null){
				sprites = [];
			}
			
			var spritesArtGroup:ArtGroup;
			// first get group from definition
			if (_definition && _definition.artSet) {
				spritesArtGroup = _definition.artSet.collection[artName] as ArtGroup;
			}
			
			// if no group from definition, use own definition
			if (spritesArtGroup == null) {
				spritesArtGroup = artGroup;
			}
				
			
			if (spritesArtGroup == null || spritesArtGroup.collection.length == 0){
				print("Creating Feature Art; no feature art found for Feature [name:"+name+", artName:"+artName+"]", PrintLevel.WARNING, this);
				return sprites;
			}
			
			var art:Art;
			var i:int = spritesArtGroup.collection.length;
			while (i--){
				art = spritesArtGroup.collection[i] as Art;
				if (art) {
					
					// add if style matches the art's style
					// by default, they should both be null
					// and therefore match
					if (artStyle == art.style) {
						sprites.push(new ArtSprite(art, this));
					}
				}
			}
			
			if (definition){
				sprites = _definition.getArtSprites(sprites);
			}
			
			return sprites;
		}
		
		private function hasArtSprites():Boolean {
			try {
				return Boolean(ArtGroup(_definition.artSet.collection[artName]).collection.length > 0);
			}catch (error:Error){}
			return false;
		}
		
		/**
		 * Applies feature transformations to an art sprite.
		 * @param	artSprite The art sprite to apply feature
		 * transformations to.
		 */
		public function drawArtSprite(artSprite:ArtSprite):void {
			if (artSprite == null) return;

			artSprite.transform.matrix = transform ? transform.getMatrix() : new Matrix();
			// BUG: Flash Players before 9,0,28,0 (CS3) will fail to 
			// recognize changed x/y/scale/rotation properties when
			// transformed through their matrix [184739]
			
			// if available, apply definition transformations
			if (_definition){
				
				// apply color, referenced in Feature, defined in definition
				var art:Art = artSprite.art;
				if (art && (isNaN(art.colorize) || art.colorize)){ // NaN colorize == do color
					// apply feature's own color
					if (color){
						artSprite.transform.colorTransform = color;
					}
					
					// override color with definitions color from 
					// color set if available
					if (_definition.colorSet){
						var colorSetColor:Color = _definition.colorSet.collection[colorName] as Color;
						if (colorSetColor){
							artSprite.transform.colorTransform = colorSetColor;
						}
					}
				}
				
				// modifications applied by definition
				_definition.drawArtSprite(artSprite);
				
				// apply parent transforms
				parentTransformArtSprite(artSprite);
			}
		}
		
		private function parentTransformArtSprite(artSprite:ArtSprite):void {
				
			// parent matrices are not affected by definitions, only
			// features as described for avatars which is why this is
			// a separate process from drawArtSprite
			if (_definition && _definition.parentName){
				
				var parentMatrix:Matrix = getParentTransformMatrix(artSprite.avatar);
				if (parentMatrix){
					
					// transform correctly found/created
					// apply transform to sprite on top of
					// existing transform
					var concatenatedMatrix:Matrix = artSprite.transform.matrix;
					concatenatedMatrix.concat(parentMatrix);
					artSprite.transform.matrix = concatenatedMatrix;
					
					// restore visibility if hidden from prior failure
					if (artSprite.visible == false){
						artSprite.visible = true;
					}
				}else{
					
					// parent matrix could not be found because parent
					// definitions could not be found, hide
					if (artSprite.visible == true){
						artSprite.visible = false;
						print("Drawing Feature Art; parent feature or its art does not exist so art for "+name+" is being hidden", PrintLevel.DEBUG, this);
					}
				}
			}
		}
		
		private function getParentTransformMatrix(avatar:Avatar):Matrix {
			if (_definition == null || !_definition.parentName) return null;

			var matrix:Matrix = new Matrix(); // does not include this feature's transform
			var parentMatrix:Matrix;
			
			var recursionLookup:Object = { }; // check to make sure parents don't create loop
			recursionLookup[_definition.parentName] = true;
			
			var parentFeature:Feature = getParentFeature(avatar);
			if (parentFeature == null){
				// expected parent feature could not be found
				return null;
			}
			
			while (parentFeature){
				
				// combine parent matrix with the current
				parentMatrix = parentFeature.transform ? parentFeature.transform.getMatrix() : new Matrix();
				matrix.concat(parentMatrix);
				
				if (parentFeature.definition){
					
					if (parentFeature.hasArtSprites() == false){
						// no art so no transform
						return null;
					}
					
					if (parentFeature.definition.parentName){
						
						if (recursionLookup[parentFeature.definition.parentName]) {
							// recursion occured
							print("Feature definition recursion in parent references", PrintLevel.ERROR, this);
							return null;
						}
							
						recursionLookup[parentFeature.definition.parentName] = true;
						
						parentFeature = parentFeature.getParentFeature(avatar);
						if (parentFeature == null){
							// expected parent feature could not be found
							return null;
						}
					}else{
						// end of hierarchy; no more parent features
						parentFeature = null;
					}
				}else{
					
					// unexpected missing definition
					return null;
				}
			}
			
			return matrix;
		}
		
		private function getParentFeature(avatar:Avatar):Feature {
			if (_definition == null || avatar == null) return null;
			return avatar.getFeatureByName(_definition.parentName);
		}
	}
}