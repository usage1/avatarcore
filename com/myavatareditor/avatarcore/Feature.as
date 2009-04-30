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
	
	import com.myavatareditor.avatarcore.IBehavior;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import com.myavatareditor.avatarcore.display.ArtSprite;
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
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
	public class Feature extends FeatureBase {
		
		/**
		 * A specific Art object to be applied to an avatar. This can contain
		 * an Art definition or, if a name property is defined, be linked
		 * to an Art definition within a respective FeatureDefinition object.
		 */
		public function get art():Art { return _art; }
		public function set art(value:Art):void {
			_art = value;
		}
		private var _art:Art;
			
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
		 * A specific color to be applied to an avatar. This can contain
		 * a Color definition or, if a name property is defined, be linked
		 * to an Color definition within a respective FeatureDefinition object.
		 */
		public function get color():Color { return _color; }
		public function set color(value:Color):void {
			_color = value;
		}
		private var _color:Color;
		
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
					print("Could not resolve an art name for "+this+"; using the first in the definition set as a default", PrintLevel.WARNING, this);
					return defaultArt.name;
				}
				
				print("Could not resolve any art name for "+this, PrintLevel.WARNING, this);
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
					print("Could not resolve a color name for "+this+"; using the first in the definition set as a default", PrintLevel.WARNING, this);
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
					print("Could not resolve a transform name for "+this+"; using the first in the definition set as a default", PrintLevel.WARNING, this);
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
				if (!name){
					name = _definition.name;
				}else if (!_definition.name){
					_definition.name = name;
				}
			}
		}
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
		
		public override function getPropertiesIgnoredByXML():Object {
			var obj:Object = super.getPropertiesIgnoredByXML();
			obj.artName = 1;
			obj.colorName = 1;
			obj.transformName = 1;
			obj.definition = 1;
			return obj;
		}
		
		/**
		 * Copies feature characteristics (Art, Colors, and Transforms)
		 * from the referenced feature definition into the feature's
		 * own characteristics.  This would be used to create a self-contained
		 * version of the feature that would be able to be displayed 
		 * without the library.
		 */
		public function consolidate():void {
			var defArt:Art;
			var defColor:Color;
			var defTransform:Transform;
			
			if (_definition){
				
				name = _definition.name;
				parentName = _definition.parentName;
				
				defArt = _definition.artSet.getItemByName(artName) as Art;
				art = (defArt) ? defArt.clone() : null;
				
				defColor = _definition.colorSet.getItemByName(colorName) as Color;
				color = (defColor) ? defColor.clone() : null;
				
				defTransform = _definition.transformSet.getItemByName(transformName) as Transform;
				transform = (defTransform) ? defTransform.clone() : null;
				
				defTransform = _definition.baseTransform;
				baseTransform = (defTransform) ? defTransform.clone() : null;
				
				behaviors.clearCollection();
				behaviors.copyCollectionFrom(_definition.behaviors);
			}else{
				print("Cannot consolidate Feature [name:" + name + "] because it is not linked to a library definition", PrintLevel.WARNING, this);
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
			var i:int;
			var collection:Array;
			
			if (featureArt == null){
				print("Creating Feature Art; no feature art found for "+this, PrintLevel.WARNING, this);
				return sprites;
			}
			
			// if the Art for this feature doesn't contain
			// any collection items (child Art objects) use
			// it as a single art asset, otherwise use its
			// children.
			collection = featureArt.collection;
			if (collection.length == 0) {
				
				// single Art object as one art sprite
				if (_artStyle == featureArt.style) {
					sprites.push(new ArtSprite(featureArt, this));
				}
				
			}else{
				
				// multiple Art objects as a group
				var childArt:Art;
				i = collection.length;
				while (i--){
					childArt = collection[i] as Art;
					if (childArt) {
						
						// add if style matches the art's style
						// by default, they should both be null
						// and therefore match
						if (_artStyle == childArt.style) {
							sprites.push(new ArtSprite(childArt, this));
						}
					}
				}
				
				// in the case that no child sprites were
				// found in the collection, revert back to
				// using the original art. This would happen if the
				// Art collection had only non-Art items
				if (sprites.length == 0 && _artStyle == featureArt.style) {
					sprites.push(new ArtSprite(featureArt, this));
				}
			}
			
			// call getArtSprites for behaviors
			var behavior:IBehavior;
			collection = _definition ? _definition.behaviors.collection : behaviors.collection;
			i = collection.length;
			while (i--){
				behavior = collection[i] as IBehavior;
				if (behavior){
					sprites = behavior.getArtSprites(this, sprites);
				}
			}
			
			return sprites;
		}
		
		private function getFeatureArt():Art {
			var featureArt:Art;
			if (_definition){
				// art from definition
				featureArt = _definition.artSet.getItemByName(artName) as Art;
			}
			if (featureArt == null) {
				// art in avatar if not found in definition
				featureArt = _art;
			}
			// return featureArt whether or not its defined
			// unlike with transform and color, art here can be null
			return featureArt;
		}
				
		private function getFeatureTransform():Transform {
			var featureBaseTransform:Transform;
			var featureTransform:Transform;
			
			if (_definition){ 
				// transforms from definition
				if (_definition.baseTransform){
					featureBaseTransform = _definition.baseTransform;
				}
				
				// linked transform
				featureTransform = _definition.transformSet.getItemByName(transformName) as Transform;
			}
			if (featureBaseTransform == null) {
				// baseTransform in avatar if not found in definition
				featureBaseTransform = baseTransform;
			}
			if (featureTransform == null) {
				// transform in avatar if not found in definition
				featureTransform = _transform;
			}
			
			// resolve final transform from found and base
			if (featureTransform){
				featureTransform.add(featureBaseTransform);
			}else{
				featureTransform = featureBaseTransform
			}
			
			// if resolved, return transform or new transform
			return featureTransform || new Transform();
		}
		
		private function getFeatureColor():Color {
			var featureColor:Color;
			if (_definition){
				// color from definition
				featureColor = _definition.colorSet.getItemByName(colorName) as Color;
			}
			if (featureColor == null) {
				// color in avatar if not found in definition
				featureColor = _color;
			}
			
			// return featureColor if defined, otherwise 
			// new default color transform
			return featureColor || new Color();
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
			artSprite.transform.matrix = getFeatureTransform().getMatrix();
	
			// apply color
			// 0 colorize -> no color; NaN/other colorize -> color
			var spriteArt:Art = artSprite.art;
			artSprite.transform.colorTransform = (spriteArt && spriteArt.colorize !== 0)
					? getFeatureColor()
					: new ColorTransform();
			
			// call drawArtSprite for behaviors
			var behavior:IBehavior;
			var collection:Array = _definition ? _definition.behaviors.collection : behaviors.collection;
			var i:int = collection.length;
			while (i--){
				behavior = collection[i] as IBehavior;
				if (behavior){
					behavior.drawArtSprite(artSprite);
				}
			}
			
			// apply parent transforms
			parentTransformArtSprite(artSprite);
		}
		
		private function parentTransformArtSprite(artSprite:ArtSprite):void {
			
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
					print("Drawing Feature Art; parent feature or its art does not exist so art for "+this+" is being hidden", PrintLevel.DEBUG, this);
				}
			}
		}
		
		private function getParentTransformMatrix(avatar:Avatar):Matrix {
			
			var matrix:Matrix = new Matrix(); // does not include this feature's transform
			var recursionLookup:Dictionary = new Dictionary(true); // check to make sure parents don't create loop
			var parentFeature:Feature;
			
			try {
				parentFeature = getParentFeature(avatar);
			}catch (error:Error){
				// expected a feature and it was not found
				print(error.message, PrintLevel.DEBUG, this);
				return null;
			}
			
			if (parentFeature == null){
				// no parent feature is specified
				return matrix;
			}
			
			while (parentFeature){
			
				// make sure art is available in parent making it visible
				if (parentFeature.getFeatureArt() == null){
					print("Feature parent matrix unresolved due to lack of parent art", PrintLevel.DEBUG, this);
					return null;
				}
				
				// combine parent matrix with the current
				matrix.concat(parentFeature.getFeatureTransform().getMatrix());
				
				// find next parent
				recursionLookup[parentFeature] = true;
				try {
					parentFeature = parentFeature.getParentFeature(avatar);
				}catch (error:Error){
					// expected a feature and it was not found
					print(error.message, PrintLevel.DEBUG, this);
					return null;
				}
				
				if (parentFeature && recursionLookup[parentFeature]) {
					// recursion occured
					print("Recursion in feature parent references", PrintLevel.ERROR, this);
					return null;
				}
				
			}
			
			// end of hierarchy; no more parent features
			// return matrix up to this point
			return matrix;
		}
		
		private function getParentFeature(avatar:Avatar):Feature {
			var parentFeature:Feature;
			var parentFeatureName:String;
			if (_definition){
				parentFeatureName = _definition.parentName;
			}
			if (parentFeatureName == null){
				parentFeatureName = parentName;
			}
			if (parentFeatureName){
				parentFeature = avatar.getItemByName(parentFeatureName) as Feature;
				
				// if a parent name (parentFeatureName) is found, it's expected
				// that the parent feature exists.  If not, an error is
				// thrown. Null cannot be returned in this case since null
				// is returned when no parent name exists and a parent feature
				// is not expected
				if (parentFeature == null){
					throw new Error("Parent feature could not be found");
				}
			}
			
			return parentFeature;
		}
	}
}