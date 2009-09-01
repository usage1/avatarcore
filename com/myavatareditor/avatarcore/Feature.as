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
	import com.myavatareditor.avatarcore.events.FeatureEvent;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * Represents a feature within an avatar.  Features describe a part
	 * of an avatar and how it is represented by graphical assets and 
	 * physical adjustments such as position, scale, or color. Feature
	 * values can be defined directly within the feature itself or link
	 * to definitions within a FeatureDefinitioninstance of a library which
	 * gets associated with the feature when an avatar containing the feature
	 * is linked with a Library object.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Feature extends FeatureBase {
		
		/**
		 * Setting the name of Features automatically calls
		 * updateParentHierarchy() in the associated Avatar instance
		 * and redraws the feature.
		 */
		override public function set name(value:String):void {
			super.name = value;
			if (_avatar){
				_avatar.updateParentHierarchy();
			}
			redraw();
		}
		
		/**
		 * A specific Art object to be applied to an avatar. This can contain
		 * an Art definition or, if a name property is defined, be linked
		 * to an Art definition within a respective FeatureDefinition object.
		 * When set, the feature is automatically updated.
		 */
		public function get art():Art { return _art; }
		public function set art(value:Art):void {
			if (_art == value) return;
			_art = value;
			redraw();
		}
		private var _art:Art;
		
		/**
		 * Shortcut to art.name.  If art or art.name does not
		 * exist and the feature is linked to a feature definition
		 * the value returned is the default name specified by
		 * artSet or, if that's not available, the name of the first
		 * item within the definition's art set collection.  Otherwise
		 * the value is null. If artName is set when art is null,
		 * a new Art instance will be created and its name set
		 * to the value given to artName. When set, the feature is 
		 * automatically updated.
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
					print("Could not resolve an art name for "+this+"; using the first in the definition set as a default", PrintLevel.NORMAL, this);
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
			redraw();
		}
		
		/**
		 * The source of the thumbnail to be used for previewing the
		 * Feature for the user. This can be either a class name or a
		 * URL referencing a loaded asset. Management of a thumbnail
		 * is handled independently by the developer; the framework does 
		 * not necessarily internally depend on or otherwise use this value.
		 */
		public function get thumbnail():String { return _thumbnail; }
		public function set thumbnail(value:String):void {
			_thumbnail = value;
		}
		private var _thumbnail:String;
			
		/**
		 * Style name for this feature.  When defined, art associated
		 * with this feature must be of the same style to be visible.
		 * When set, the feature is automatically updated. artStyle is
		 * an optional helper method that is ignored when not used. It
		 * only applies when Art instances used by this feature have
		 * for them a defined Art.style property.
		 */
		public function get artStyle():String { return _artStyle; }
		public function set artStyle(value:String):void {
			if (_artStyle == value) return;
			_artStyle = value;
			redraw();
		}
		private var _artStyle:String; // defaults to not using
		
		/**
		 * A specific color to be applied to an avatar. This can contain
		 * a Color definition or, if a name property is defined, be linked
		 * to an Color definition within a respective FeatureDefinition object.
		 * When set, the feature is automatically updated.
		 */
		public function get color():Color { return _color; }
		public function set color(value:Color):void {
			if (_color == value) return;
			_color = value;
			redraw();
		}
		private var _color:Color;
		
		/**
		 * Adjustments (position, size, and rotation) to be applied
		 * to a feature and its art.  When null, no adjustment is
		 * applied (x=0, y=0, scale=1, rotation=0). If a name property is
		 * defined, it can be linked to an Color definition within a 
		 * respective FeatureDefinition object.  This adjust is applied
		 * on top of a definitions baseAdjust if defined. When set, the
		 * feature is automatically updated.
		 */
		public function get adjust():Adjust { return _adjust; }
		public function set adjust(value:Adjust):void {
			if (_adjust == value) return;
			_adjust = value;
			redraw();
		}
		private var _adjust:Adjust;
		
		/**
		 * Shortcut to adjust.name.  If adjust or adjust.name does not
		 * exist and the feature is linked to a feature definition
		 * the value returned is the default name specified by
		 * adjustSet or, if that's not available, the name of the first
		 * item within the definition's adjust set collection.  Otherwise
		 * the value is null. If adjustName is set when adjust is null,
		 * a new Adjust instance will be created and its name set
		 * to the value given to adjustName. When set, the feature is 
		 * automatically updated.
		 */
		public function get adjustName():String {
			if (_adjust && _adjust.name) {
				return _adjust.name;
			}
			if (_definition){
				if (_definition.adjustSet.defaultName){
					return _definition.adjustSet.defaultName;
				}
				
				// if a feature references a definition, but does not
				// provide specification on which adjust, the first is used
				// (or whatever is specified by defaultSetID)
				var defaultAdjust:Adjust = _definition.adjustSet.collection[defaultSetID] as Adjust;
				if (defaultAdjust){
					print("Could not resolve an adjust name for "+this+"; using the first in the definition set as a default", PrintLevel.NORMAL, this);
					return defaultAdjust.name;
				}
				
			}
			
			return null;
		}
		public function set adjustName(value:String):void {
			if (_adjust == null){
				_adjust = new Adjust();
			}
			_adjust.name = value;
			redraw();
		}
		
		/**
		 * Shortcut to color.name.  If color or color.name does not
		 * exist and the feature is linked to a feature definition
		 * the value returned is the default name specified by
		 * colorSet or, if that's not available, the name of the first
		 * item within the definition's color set collection.  Otherwise
		 * the value is null. If colorName is set when color is null,
		 * a new Color instance will be created and its name set
		 * to the value given to colorName. When set, the feature is 
		 * automatically updated.
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
					print("Could not resolve a color name for "+this+"; using the first in the definition set as a default", PrintLevel.NORMAL, this);
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
			redraw();
		}
		
		/**
		 * A reference to the parent feature referenced by parentName. This
		 * is set when parentName is set, or can be set directly.
		 */
		public function get parent():Feature { return _parent; }
		public function set parent(value:Feature):void {
			if (value){
				if (!_avatar){
					print("Parents cannot be set when a feature is not associated with an avatar", PrintLevel.ERROR, this);
					return;
				}else if (value._avatar != _avatar) {
					print("Parent features must share the same avatar", PrintLevel.ERROR, this);
					return;
				}
			}
			_parent = value;
			super.parentName = (_parent) ? _parent.name : null; // super set to prevent re-update
			redraw();
		}
		private var _parent:Feature;
		
		/**
		 * Setting the parent name for Features automatically calls
		 * updateParentHierarchy() in the associated Avatar instance
		 * and redraws the feature.
		 */
		override public function set parentName(value:String):void {
			super.parentName = value;
			if (_avatar){
				_avatar.updateParentHierarchy();
			}
			redraw();
		}
		
		/**
		 * Identifies how many parents this feature has as specified
		 * by it's parent (or parentName) property.
		 */
		public function get parentCount():int { return _parentCount; }
		private var _parentCount:int;
		
		/**
		 * The avatar that is associated with this feature.  This is 
		 * usually set automatically when the feature is added to an avatar
		 * through Avatar.addItem(). This property serves as a reference
		 * to the avatar instance in that relationship.
		 */
		public function get avatar():Avatar {
			return _avatar;
		}
		public function set avatar(value:Avatar):void {
			_avatar = value;
			
			// the avatar will need to update its parent
			// hierarchy to update the feature's parents
			_parent = null;
			_parentCount = 0;
		}
		private var _avatar:Avatar;
		
		/**
		 * The feature definition that is to be associated with this
		 * avatar feature.  This is usually set automatically
		 * when the avatar is associated with a library or when a 
		 * feature is added to an avatar that has an associated library.
		 * These associations are made when the name of the definition
		 * and feature matches. If a definition is assigned to a 
		 * feature when it has no name, it automatically inherits the
		 * name from the definition.
		 */
		public function get definition():FeatureDefinition {
			return _definition;
		}
		public function set definition(value:FeatureDefinition):void {
			if (_definition == value) return;
			
			_definition = value;
			
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
			obj.adjustName = 1;
			obj.definition = 1;
			obj.avatar = 1;
			obj.parent = 1;
			obj.parentCount = 1;
			return obj;
		}
		
		/**
		 * Indicates to Avatar stakeholders (i.e. AvatarDisplay) that this feature
		 * has been  changed.  This only applies to features contained within
		 * an Avatar instance since this operation causes the containing Avatar 
		 * instance to dispatch a FEATURE_CHANGED event so objects can react to
		 * data (feature) within the avatar being modified.
		 */
		public function redraw():void {
			if (_avatar){
				_avatar.redrawFeature(this);
			}
		}
		
		/**
		 * Copies feature characteristics (Art, Colors, Adjusts, and Behaviors)
		 * from the referenced feature definition into the feature's own
		 * characteristics.  This would be used to create a self-contained
		 * version of the feature that would be able to be displayed 
		 * without the library.
		 */
		public function consolidate():void {
			var defArt:Art;
			var defColor:Color;
			var defAdjust:Adjust;
			
			if (_definition){
				
				name = _definition.name;
				parentName = _definition.parentName;
				
				defArt = _definition.artSet.getItemByName(artName) as Art;
				art = (defArt) ? defArt.clone() : null;
				
				defColor = _definition.colorSet.getItemByName(colorName) as Color;
				color = (defColor) ? defColor.clone() : null;
				
				defAdjust = _definition.adjustSet.getItemByName(adjustName) as Adjust;
				adjust = (defAdjust) ? defAdjust.clone() : null;
				
				defAdjust = _definition.baseAdjust;
				baseAdjust = (defAdjust) ? defAdjust.clone() : null;
				
				behaviors.clearCollection();
				behaviors.copyCollectionFrom(_definition.behaviors);
			}else{
				print("Cannot consolidate Feature [name:" + name + "] because it is not linked to a library definition", PrintLevel.WARNING, this);
			}
		}
		
		/**
		 * Returns the art sprites needed to represent this feature.
		 * This is called internally by AvatarDisplay to create the sprites
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
			var featureArt:Art = getRenderedArt();
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
		
		/**
		 * Returns the Art object used by this feature to display itself
		 * visually.  This can come from one of two source, the feature's
		 * own art definition, or a referenced Art in an artSet from a
		 * linked FeatureDefinition instance.  If such an Art object does not
		 * exist, null is returned.
		 * @return The Art object used by this feature to display itself
		 * visually.
		 */
		public function getRenderedArt():Art {
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
			// unlike with adjust and color, art here can be null
			return featureArt;
		}
		
		/**
		 * Returns the Adjust object used by this feature to display itself
		 * visually. This adjustment is a combination of any baseAdjust as well
		 * as the defined adjust. This can come from one of two source, the feature's
		 * own adjust and baseAdjust definitions, or those referenced from a
		 * linked FeatureDefinition instance.  If such an Adjust object does not
		 * exist, a new, default Adjust instance is returned.  The adjust returned
		 * by getRenderedAdjust does not account for parent adjustments.
		 * @return The Adjust object used by this feature to display itself
		 * visually. This will never be a direct reference to a Feauture's or
		 * FeatureDefinition's own Adjust object.
		 */
		public function getRenderedAdjust():Adjust {
			var featureBaseAdjust:Adjust;
			var featureAdjust:Adjust;
			
			if (_definition){ 
				// adjust from definition
				if (_definition.baseAdjust){
					featureBaseAdjust = _definition.baseAdjust;
				}
				
				// linked adjust
				featureAdjust = _definition.adjustSet.getItemByName(adjustName) as Adjust;
			}
			if (featureBaseAdjust == null) {
				// baseAdjust in avatar if not found in definition
				featureBaseAdjust = baseAdjust;
			}
			if (featureAdjust == null) {
				// transform in avatar if not found in definition
				featureAdjust = _adjust;
			}
			
			// resolve final adjust from found and base
			// only return clones, not original adjusts
			if (featureAdjust){
				featureAdjust = featureAdjust.clone();
				featureAdjust.add(featureBaseAdjust);
				return featureAdjust;
			}
			
			if (featureBaseAdjust){
				return featureBaseAdjust.clone();
			}
			
			// none found; return new
			return new Adjust();
		}
		
		/**
		 * Returns the Color object used by this feature to display itself
		 * visually.  This can come from one of two source, the feature's
		 * own color definition, or a referenced Color in a colorSet from a
		 * linked FeatureDefinition instance. If such a Color object does not
		 * exist, a new, default Color instance is returned.
		 * @return The Color object used by this feature to display itself
		 * visually.
		 */
		public function getRenderedColor():Color {
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
			// new default color
			return featureColor || new Color();
		}
		
		/**
		 * Applies feature adjustments to an art sprite. This
		 * is called internally by AvatarDisplay to render the sprites
		 * it creates to present the avatar on screen.
		 * @param	artSprite The art sprite to apply feature
		 * adjustments to.
		 */
		public function drawArtSprite(artSprite:ArtSprite):void {
			if (artSprite == null) return;
			
			// apply transformation matrix
			artSprite.transform.matrix = getRenderedAdjust().getMatrix();
	
			// apply color
			// 0 colorize -> no color; NaN/other colorize -> color
			var spriteArt:Art = artSprite.art;
			artSprite.transform.colorTransform = (spriteArt && spriteArt.colorize !== 0)
					? getRenderedColor()
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
			
			// apply parent adjustments
			if (_parent){
				parentTransformArtSprite(artSprite);
			}
		}
		
		/**
		 * Returns the matrix representing the (pseudo) parent coordinate space
		 * of the feature as determined by the adjust transforms of all parent
		 * features.  This method is used by drawArtSprite to correctly render
		 * a feature's art within it's parent.
		 * @return
		 */
		public function getConcatenatedParentMatrix():Matrix {
			var concatenatedMatrix:Matrix = new Matrix();
			var par:Feature = _parent;
			while (par){
				concatenatedMatrix.concat( par.getRenderedAdjust().getMatrix() );
				par = par._parent;
			}
			return concatenatedMatrix;
		}
		
		/**
		 * Finds and updates the parent property with the Feature in 
		 * the current avatar with a name matching parentName. This 
		 * function is automatically called when parentName is set,
		 * or when redraw() is called.
		 * @private
		 */
		internal function updateParent():void {
			var parentFeatureName:String;
			if (_definition){
				parentFeatureName = _definition.parentName;
			}
			if (parentFeatureName == null){
				parentFeatureName = parentName;
			}
			
			if (parentFeatureName && _avatar){
				var foundParent:Feature = _avatar.getItemByName(parentFeatureName) as Feature;
				if (foundParent){
					parent = foundParent;
				}else{ 
				
					// if a parent is not found yet a name is given, keep the name
					// and leave the parent alone (aetting it will change the name)
					// just issue a warning in the case that a parent was expected
				
					print("Parent feature for "+this+" could not be found", PrintLevel.WARNING, this);
				}
			}else{
				_parent = null;
			}
		}
		
		/**
		 * Updates the count associated with the number of ancestors of
		 * this feature as determined by its parent and its parent's parents.
		 * Parent count is used to determine the order in which features are
		 * drawn.  Features which are the parents of other features must be 
		 * drawn first so their children can inherit their most up-to-date
		 * characteristics (namely applied adjustments and behaviors).
		 * @private
		 */
		internal function updateParentCount():void {
			_parentCount = 0;
			var recursionLookup:Dictionary = new Dictionary(true); // check to make sure parents don't create loop
			var parentFeature:Feature = _parent;
			
			while (parentFeature){
				recursionLookup[parentFeature] = true;
				parentFeature = parentFeature.parent;
								
				if (parentFeature && recursionLookup[parentFeature]) {
					// recursion occured
					print("Recursion in feature parent references", PrintLevel.ERROR, this);
					return;
				}
				_parentCount++;
			}
		}
		
		private function parentTransformArtSprite(artSprite:ArtSprite):void {
			var parentMatrix:Matrix = getConcatenatedParentMatrix();
			
			// NOTE: this approach (after v0.1.5) does not hide a sprite if its
			// parent is not correctly found
			
			// position
			var position:Point = new Point(artSprite.x, artSprite.y);
			position = parentMatrix.transformPoint(position);
			artSprite.x = position.x;
			artSprite.y = position.y;
			
			// rotation
			artSprite.rotation += Math.atan2(parentMatrix.b, parentMatrix.a) * 180/Math.PI;
			
			// scale is not inherited
		}
	}
}