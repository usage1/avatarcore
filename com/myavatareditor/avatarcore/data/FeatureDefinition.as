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
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.geom.Rectangle;
	
	/**
	 * Defines characteristics to be referenced by avatar features.  Characteristics
	 * include possible art, color selections, transformations and optional
	 * constraints for transformations.  Features reference these characteristics
	 * by name.  Features reference feature definitions when they share the same 
	 * name.  This connection is made when an Avatar instance is associated with a 
	 * Library instance.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class FeatureDefinition implements IXMLWritable {
		
		/**
		 * Identifies the feature definition by name. Features in 
		 * Avatar objects will reference FeatureDefinition objects
		 * that share the same name.
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void {
			_name = value;
		}
		private var _name:String;
		
		/**
		 * Name of the parent feature from which this feature
		 * inherits transformations such as position, scale and
		 * rotation.
		 */
		public function get parentName():String { return _parentName; }
		public function set parentName(value:String):void {
			_parentName = value;
		}
		private var _parentName:String;
		
		/**
		 * Variations of art available for this feature
		 * definition. An artSet cannot be null.
		 */
		public function get artSet():ArtSet { return _artSet; }
		public function set artSet(value:ArtSet):void {
			if (value){
				_artSet = value;
			}
		}
		private var _artSet:ArtSet = new ArtSet();
		
		/**
		 * Variations of colors (color transforms) that can be
		 * applied to art within this definition.   A colorSet
		 * cannot be null.
		 */
		public function get colorSet():ColorSet { return _colorSet; }
		public function set colorSet(value:ColorSet):void {
			if (value){
				_colorSet = value;
			}
		}
		private var _colorSet:ColorSet = new ColorSet();
		
		/**
		 * Variations of transformations that can be
		 * applied to art within this definition.  A transformSet
		 * cannot be null.
		 */
		public function get transformSet():TransformSet { return _transformSet; }
		public function set transformSet(value:TransformSet):void {
			if (value){
				_transformSet = value;
			}
		}
		private var _transformSet:TransformSet = new TransformSet();
		
		/**
		 * Base transformation on top of which other transformations
		 * are applied.  This would be a starting point for other
		 * transformations in, for example, a transformSet.  If the
		 * base transform has an x of 10, and the selected transform
		 * in a set is 20, the final transform has an x of 30.
		 */
		public function get baseTransform():Transform { return _baseTransform; }
		public function set baseTransform(value:Transform):void {
			_baseTransform = value;
		}
		private var _baseTransform:Transform;
		
		/**
		 * A constraint for moving, scaling, or rotating art in
		 * this definition.  When transformed, an art's transformation
		 * cannot exceed the values defined in this contraint.
		 */
		public function get constraint():Constraint { return _constraint; }
		public function set constraint(value:Constraint):void {
			_constraint = value;
		}
		private var _constraint:Constraint;
		
		/**
		 * Constructor for creating new FeatureDefinition instances.
		 */
		public function FeatureDefinition() {
			
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {name:1, parentName:1};
		}
		
		public function getPropertiesIgnoredByXML():Object {
			return {};
		}
		
		public function getObjectAsXML():XML {
			return null;
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
		
		/**
		 * Draws an art sprite based on the conditions defined by
		 * this definition. By default, the drawing responsibility
		 * of feature definitions is keeping art sprite(s) within
		 * the defined constraints.
		 * @param	artSprite The art sprite being drawn.
		 */
		public function drawArtSprite(artSprite:ArtSprite):void {
			if (artSprite == null) return;
			
			// restrict to constraints
			if (_constraint){
				
				// position
				if (_constraint.position){
					if (artSprite.x < _constraint.position.left){
						artSprite.x = _constraint.position.left;
					}else if (artSprite.x > _constraint.position.right){
						artSprite.x = _constraint.position.right;
					}
					if (artSprite.y < _constraint.position.top){
						artSprite.y = _constraint.position.top;
					}else if (artSprite.y > _constraint.position.bottom){
						artSprite.y = _constraint.position.bottom;
					}
				}
				
				// rotation
				if (_constraint.rotation){
					if (artSprite.rotation > _constraint.rotation.max){
						artSprite.rotation = _constraint.rotation.max;
					}else if (artSprite.rotation < _constraint.rotation.min){
						artSprite.rotation = _constraint.rotation.min;
					}
				}
				
				// scale
				// TODO: constraint.scaleX/scaleY?
				// should min/max be absolutely based? - allowing for negative
				// scales within the min/max ranges? ... I'm thinking yes
				if (_constraint.scale){
					if (artSprite.scaleX > _constraint.scale.max){
						artSprite.scaleX = artSprite.scaleY = _constraint.scale.max;
					}else if (artSprite.scaleX < _constraint.scale.min){
						artSprite.scaleX = artSprite.scaleY = _constraint.scale.min;
					}
				}
			}
		}
	}
}