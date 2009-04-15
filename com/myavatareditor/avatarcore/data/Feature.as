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
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	/**
	 * Represents a feature within an avatar.  Features describe a part
	 * of how an avatar is represented through physical transformations
	 * and other information through a referenced FeatureDefinition.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Feature implements IXMLWritable {
		
		/**
		 * Name of the feature. This maps this feature to FeatureDefinition
		 * objects in an associated library with the same name.
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void {
			_name = value;
		}
		private var _name:String;
		
		/**
		 * Name of the color in a linked FeatureDefinition to be
		 * associated with this feature.
		 */
		public function get colorName():String { return _colorName; }
		public function set colorName(value:String):void {
			_colorName = value;
		}
		private var _colorName:String; // defaults to first
		
		/**
		 * Name of the art group in a linked FeatureDefinition to be
		 * associated with this feature.
		 */
		public function get artName():String { return _artName; }
		public function set artName(value:String):void {
			_artName = value;
		}
		private var _artName:String; // defaults to first
		
		/**
		 * Style name for this feature.  When defined, art associated
		 * with this feature must be of the same style to be visible.
		 */
		public function get artStyle():String { return _artStyle; }
		public function set artStyle(value:String):void {
			_artStyle = value;
		}
		private var _artStyle:String; // defaults to not using
		
		/**
		 * Transformation (position, size, and rotation) to be applied
		 * to a feature and its art.  When null, no transformation is
		 * applied (x=0, y=0, scale=1, rotation=0).
		 */
		public function get transform():Transform { return _transform; }
		public function set transform(value:Transform):void {
			_transform = value;
		}
		private var _transform:Transform;
		
		/**
		 * A specific color to be applied to an avatar. Usually this
		 * is null in favor of using colorName to reference a color
		 * defined in the library, but this value can be set as an
		 * alternative so that the avatar definition can be self-contained.
		 */
		public function get color():Color { return _color; }
		public function set color(value:Color):void {
			_color = value;
		}
		private var _color:Color; // if not using definition's
		
		/**
		 * A specific Art object to be applied to an avatar. Usually this
		 * is null in favor of using artName to reference an Art object
		 * defined in the library, but this value can be set as an
		 * alternative so that the avatar definition can be self-contained.
		 */
		public function get art():Art { return _art; }
		public function set art(value:Art):void {
			_art = value;
		}
		private var _art:Art; // if not using definition's
		
		/**
		 * Gets the feature definition associated with this
		 * avatar feature.
		 */
		public function get definition():FeatureDefinition {
			return _definition;
		}
		
		/**
		 * Sets the feature definition that is to be associated
		 * with this avatar feature.  This is usually set automatically
		 * when the avatar is associated with a library or when a 
		 * feature is added to an avatar that has an associated library.
		 */
		public function set definition(definition:FeatureDefinition):void {
			_definition = definition;
			
			if (_definition){
				
				// defaults
				if (_definition.defaultTransform) {
					if (_transform == null) {
						// undefined transform object (allows defaults)
						transform = new Transform(Number.NaN, Number.NaN, Number.NaN, Number.NaN);
					}
					_transform.fill(_definition.defaultTransform);
				}
				
				if (_artName == null && _definition.defaultArtName) {
					artName = _definition.defaultArtName;
				}
				
				if (_colorName == null && _definition.defaultColorName) {
					colorName = _definition.defaultColorName;
				}
				
				// inherit name of definition if not defined here
				// usually this is a non-issue since libraries should
				// only make the association if the names match
				if (!_name){
					name = _definition.name;
				}
			}
		}
		
		// definition is not an accessor since when writing XML
		// it would parse the definition property as a node of
		// the XML which is not desirable for how definition
		// associations are made.
		private var _definition:FeatureDefinition;
		
		private var defaultSetID:String = "0"; // collection 'name' if not provided
		
		/**
		 * Constructor for creating new Feature instances.
		 * @param	definition The FeatureDefinition object this feature
		 * uses in referencing values from a library.  This value is
		 * re-defined whenever the Avatar object this feature is attached
		 * is associated with a new library.
		 */
		public function Feature(definition:FeatureDefinition = null) {
			this.definition = definition;
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {name:1};
		}
		
		public function getPropertiesIgnoredByXML():Object {
			return {definition:1};
		}
		
		public function getObjectAsXML():XML {
			return null;
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
			
			var featureArt:Art;
			// first get group from definition
			if (_definition && _definition.artSet) {
				featureArt = _definition.artSet.collection[_artName || defaultSetID] as Art;
			}
			
			// if no group from definition, use own definition
			// if available (may be null)
			if (featureArt == null) {
				featureArt = _art;
			}
			
			if (featureArt == null){
				print("Creating Feature Art; no feature art found for Feature [name:"+_name+", artName:"+_artName+"]", PrintLevel.WARNING, this);
				return sprites;
			}
			
			// if the Art for this feature doesn't contain
			// any collection items (child Art objects) use
			// it as a single art asset, otherwise use its
			// children.
			if (featureArt.collection.length == 0) {
				
				// single Art object as one art sprite
				if (_artStyle == featureArt.style) {
					sprites.push(new ArtSprite(featureArt, this));
				}
				
			}else {
				
				// multiple Art objects as a group
				var childArt:Art;
				var i:int = featureArt.collection.length;
				while (i--){
					childArt = featureArt.collection[i] as Art;
					if (childArt) {
						
						// add if style matches the art's style
						// by default, they should both be null
						// and therefore match
						if (_artStyle == childArt.style) {
							sprites.push(new ArtSprite(childArt, this));
						}
					}
				}
			}
			
			// definitions also determine what sprites
			// are being used by the feature
			if (_definition){
				sprites = _definition.getArtSprites(sprites);
			}
			
			return sprites;
		}
		
		private function hasArtSprites():Boolean {
			try {
				return Boolean(_definition.artSet.collection[artName || defaultSetID]);
			}catch (error:Error) {
				// definition or art set is null
			}
			return false;
		}
		
		/**
		 * Applies feature transformations to an art sprite.
		 * @param	artSprite The art sprite to apply feature
		 * transformations to.
		 */
		public function drawArtSprite(artSprite:ArtSprite):void {
			if (artSprite == null) return;

			artSprite.transform.matrix = _transform ? _transform.getMatrix() : new Matrix();
			// BUG: Flash Players before 9,0,28,0 (CS3) will fail to 
			// recognize changed x/y/scale/rotation properties when
			// transformed through their matrix [184739]
			
			// if available, apply definition transformations
			if (_definition){
				
				// apply color, referenced in Feature, defined in definition
				var art:Art = artSprite.art;
				if (art && art.colorize !== 0) { // NaN colorize == color; 0 == no color
					
					// apply feature's own color
					if (_color){
						artSprite.transform.colorTransform = _color;
					}
					
					// override color with definitions color from 
					// color set if available
					if (_definition.colorSet){
						var colorSetColor:Color = _definition.colorSet.collection[_colorName || defaultSetID] as Color;
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
				
				// find the next parent - this is a little involved
				if (parentFeature._definition){
					
					if (parentFeature.hasArtSprites() == false){
						print("Feature parent matrix unresolved due to lack of parent art", PrintLevel.DEBUG, this);
						return null;
					}
					
					if (parentFeature._definition.parentName){
						
						if (recursionLookup[parentFeature._definition.parentName]) {
							// recursion occured
							print("Feature definition recursion in parent references", PrintLevel.ERROR, this);
							return null;
						}
							
						recursionLookup[parentFeature._definition.parentName] = true;
						
						parentFeature = parentFeature.getParentFeature(avatar);
						if (parentFeature == null){
							// expected parent feature could not be found
							print("Feature parent matrix unresolved because parent could not be found", PrintLevel.DEBUG, this);
							return null;
						}
					}else {
						
						// end of hierarchy; no more parent features
						// exit loop returning matrix up to this point
						parentFeature = null;
					}
				}else{
					
					// unexpected missing definition
					print("Feature parent matrix unresolved due to lack of parent feature definition", PrintLevel.DEBUG, this);
					return null;
				}
			}
			
			return matrix;
		}
		
		private function getParentFeature(avatar:Avatar):Feature {
			if (_definition == null || avatar == null) return null;
			return avatar.getItemByName(_definition.parentName) as Feature;
		}
	}
}