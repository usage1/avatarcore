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
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * Represents a feature within an avatar.  Features describe a part
	 * of an avatar and how it is represented by graphical assets and 
	 * physical transformations such as position, scale, or color. Feature
	 * values can be defined directly within the feature itself or link
	 * to definitions within a FeatureDefinitioninstance of a library which
	 * gets associated with the feature when an avatar containing the feature
	 * is linked with a Library object.
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
		 * Shortcut to art.name.  If art or art.name does not
		 * exist and the feature is linked to a feature definition
		 * the value returned is the default name specified by
		 * artSet or, if that's not available, the name of the first
		 * item within the definition's art set collection.  Otherwise
		 * the value is null. If artName is set when art is null,
		 * a new Art instance will be created and its name set
		 * to the value given to artName.
		 */
		public function get artName():String {
			if (_art && _art.name) {
				return _art.name;
			}
			if (_definition){
				if (_definition.artSet.defaultName){
					return _definition.artSet.defaultName;
				}
				
				// if a feature references a definition, but does not
				// provide specification on which art, the first is used
				// (or whatever is specified by defaultSetID)
				var defaultArt:Art = _definition.artSet.collection[defaultSetID] as Art;
				if (defaultArt){
					return defaultArt.name;
				}
			}
			
			return null;
		}
		public function set artName(value:String):void {
			if (_art == null){
				_art = new Art();
			}
			_art.name = value;
		}
		
		/**
		 * Shortcut to color.name.  If color or color.name does not
		 * exist and the feature is linked to a feature definition
		 * the value returned is the default name specified by
		 * colorSet or, if that's not available, the name of the first
		 * item within the definition's color set collection.  Otherwise
		 * the value is null. If colorName is set when color is null,
		 * a new Color instance will be created and its name set
		 * to the value given to colorName.
		 */
		public function get colorName():String {
			if (_color && _color.name) {
				return _color.name;
			}
			if (_definition){
				if (_definition.colorSet.defaultName){
					return _definition.colorSet.defaultName;
				}
				
				// if a feature references a definition, but does not
				// provide specification on which color, the first is used
				// (or whatever is specified by defaultSetID)
				var defaultColor:Color = _definition.colorSet.collection[defaultSetID] as Color;
				if (defaultColor){
					return defaultColor.name;
				}
			}
			
			return null;
		}
		public function set colorName(value:String):void {
			if (_color == null){
				_color = new Color();
			}
			_color.name = value;
		}
		
		/**
		 * Shortcut to transform.name.  If transform or transform.name does not
		 * exist and the feature is linked to a feature definition
		 * the value returned is the default name specified by
		 * transformSet or, if that's not available, the name of the first
		 * item within the definition's transform set collection.  Otherwise
		 * the value is null. If transformName is set when transform is null,
		 * a new Transform instance will be created and its name set
		 * to the value given to transformName.
		 */
		public function get transformName():String {
			if (_transform && _transform.name) {
				return _transform.name;
			}
			if (_definition){
				if (_definition.transformSet.defaultName){
					return _definition.transformSet.defaultName;
				}
				
				// if a feature references a definition, but does not
				// provide specification on which transform, the first is used
				// (or whatever is specified by defaultSetID)
				var defaultTransform:Transform = _definition.transformSet.collection[defaultSetID] as Transform;
				if (defaultTransform){
					return defaultTransform.name;
				}
			}
			
			return null;
		}
		public function set transformName(value:String):void {
			if (_transform == null){
				_transform = new Transform();
			}
			_transform.name = value;
		}
			
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
		 * A specific Art object to be applied to an avatar. This can contain
		 * an Art definition or, if a name property is defined, be linked
		 * to an Art definition within a respective FeatureDefinition object.
		 */
		public function get art():Art { return _art; }
		public function set art(value:Art):void {
			_art = value;
		}
		private var _art:Art; // if not using definition's
		
		/**
		 * A specific color to be applied to an avatar. This can contain
		 * a Color definition or, if a name property is defined, be linked
		 * to an Color definition within a respective FeatureDefinition object.
		 */
		public function get color():Color { return _color; }
		public function set color(value:Color):void {
			_color = value;
		}
		private var _color:Color; // if not using definition's
		
		/**
		 * Transformation (position, size, and rotation) to be applied
		 * to a feature and its art.  When null, no transformation is
		 * applied (x=0, y=0, scale=1, rotation=0). If a name property is
		 * defined, it can be linked to an Color definition within a 
		 * respective FeatureDefinition object.  This transform is applied
		 * on top of a definitions baseTransform if defined.
		 */
		public function get transform():Transform { return _transform; }
		public function set transform(value:Transform):void {
			_transform = value;
		}
		private var _transform:Transform;
		
		/**
		 * Base transformation on top of which other transformations
		 * are applied. If both a feature and its definition specify
		 * a base transform, only the definition's base transform will
		 * be used.  Normally Feature.baseTransform is not necessary.
		 * It is mostly useful to help maintain parity with 
		 * tranformation combinations from feature definitions. For
		 * example, when copying FeatureDefinition characteristics into
		 * Feature objects, you would want both the transform and the
		 * baseTransform objects so that the combined transform will
		 * be used for the avatar when a library and it's related 
		 * definitions are not available.
		 */
		public function get baseTransform():Transform { return _baseTransform; }
		public function set baseTransform(value:Transform):void {
			_baseTransform = value;
		}
		private var _baseTransform:Transform;
		
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
		 * These associations are made when the name of the definition
		 * and feature matches. If a definition is assigned to a 
		 * feature when it has no name, it automatically inherits the
		 * name from the definition.
		 */
		public function set definition(definition:FeatureDefinition):void {
			_definition = definition;
			
			if (_definition){
				
				// inherit name of definition if not defined here
				// usually this is a non-issue since libraries should
				// only make the association if the names match
				// this also works the other way around
				if (!_name){
					name = _definition.name;
				}else if (!_definition.name){
					_definition.name = _name;
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
			return {definition:1,artName:1,colorName:1,transformName:1};
		}
		
		public function getObjectAsXML():XML {
			return null;
		}
		
		/**
		 * Copies feature characteristics (Art, Colors, and Transforms)
		 * from the referenced feature definition into the feature's
		 * own characteristics.  This would be used to create a self-contained
		 * version of the feature that would be able to be displayed 
		 * without the library.
		 */
		public function consolidate():void {
			trace("consolidating");
			var defArt:Art;
			var defColor:Color;
			var defTransform:Transform;
			if (_definition){
				
				defArt = _definition.artSet.getItemByName(artName) as Art;
				art = (defArt) ? defArt.clone() : null;
				
				defColor = _definition.colorSet.getItemByName(colorName) as Color;
				color = (defColor) ? defColor.clone() : null;
				
				defTransform = _definition.transformSet.getItemByName(transformName) as Transform;
				transform = (defTransform) ? defTransform.clone() : null;
				
				defTransform = _definition.baseTransform;
				baseTransform = (defTransform) ? defTransform.clone() : null;
			}
		}
		
		/**
		 * Returns the art sprites needed to represent this feature.
		 * This is called internally by AvatarArt to create the sprites
		 * used to present the avatar on screen.
		 * @param	sprites Any set of pre-existing art sprites
		 * assumed to be necessary for the feature.
		 * @return An array of art sprites.
		 */
		public function getArtSprites(sprites:Array = null):Array {
			if (sprites == null){
				sprites = [];
			}
			
			// use definition art through name reference if available
			// otherwise fallback to local art object
			var featureArt:Art = getFeatureArt();
			
			if (featureArt == null){
				print("Creating Feature Art; no feature art found for Feature [name:"+_name+"]", PrintLevel.WARNING, this);
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
				
				// in the rare case that no child sprites were
				// found in the collection, revert back to
				// using the original art
				if (sprites.length == 0 && _artStyle == featureArt.style) {
					sprites.push(new ArtSprite(featureArt, this));
				}
			}
			
			// definitions also determine what sprites
			// are being used by the feature
			if (_definition){
				sprites = _definition.getArtSprites(sprites);
			}
			
			return sprites;
		}
		
		private function getFeatureArt():Art {
			var featureArt:Art;
			if (_definition){
				featureArt = _definition.artSet.getItemByName(artName) as Art;
			}
			if (featureArt == null) {
				featureArt = _art;
			}
			return featureArt;
		}
		
		/**
		 * Applies feature transformations to an art sprite. This
		 * is called internally by AvatarArt to render the sprites
		 * it creates to present the avatar on screen.
		 * @param	artSprite The art sprite to apply feature
		 * transformations to.
		 */
		public function drawArtSprite(artSprite:ArtSprite):void {
			if (artSprite == null) return;
			
			// apply transform
			var featureBaseTransform:Transform;
			var featureTransform:Transform;
			if (_definition){ 
				// transforms from definition
				if (_definition.baseTransform){
					// base transform on which other transforms are based
					featureBaseTransform = _definition.baseTransform;
				}
				// linked transform
				featureTransform = _definition.transformSet.getItemByName(transformName) as Transform;
			}
			if (featureBaseTransform == null) {
				// baseTransform in avatar if not found in definition
				featureBaseTransform = _baseTransform;
			}
			if (featureTransform == null) {
				// transform in avatar if not found in definition
				featureTransform = _transform;
			}
			
			var matrix:Matrix = (featureBaseTransform)
				? featureBaseTransform.getMatrix() // base transform
				: new Matrix();
			
			if (featureTransform){
				// additional transform 
				matrix.concat(featureTransform.getMatrix());
			}
			
			// assign matrix to art sprite
			artSprite.transform.matrix = matrix;
	
			// apply color
			var featureColor:Color;
			var spriteArt:Art = artSprite.art;
			if (spriteArt && spriteArt.colorize !== 0){ // NaN colorize -> color; 0 -> no color
				
				if (_definition){
					// color from definition
					featureColor = _definition.colorSet.getItemByName(colorName) as Color;
				}
				if (featureColor == null) {
					// color in avatar if not found in definition
					featureColor = _color;
				}
				if (featureColor){
					// assign color to art sprite
					artSprite.transform.colorTransform = featureColor;
				}else{
					// reset sprite color if color can't be resolved
					artSprite.transform.colorTransform = new ColorTransform();
				}
			}
			
			// if available, invoke feature definition drawing
			if (_definition){
				
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
					
					// parent transform correctly found/created
					// apply parent transform to sprite on top of
					// sprite's own, existing transform
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
					
					if (parentFeature.getFeatureArt() == null){
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