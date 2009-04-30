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
	
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Base class for Feature and FeatureDefinition defining members
	 * shared between both of those classes
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class FeatureBase implements IXMLWritable {
		
		/**
		 * Identifies the feature object by name. Features in 
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
		 * Base transformation on top of which other transformations
		 * are applied. If both a feature and its definition specify
		 * a base transform, only the definition's base transform will
		 * be used.  Normally Feature.baseTransform is not necessary.
		 * It only really useful to help maintain parity with 
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
		 * A collection of custom behaviors that are used to help
		 * determine the final render of an avatar feature.  Each
		 * feature in the set is used when drawing the feature's art,
		 * not just one as is the case with the artSets, colorSets,
		 * and transformSets.
		 */
		public function get behaviors():Collection { return _behaviors; }
		public function set behaviors(value:Collection):void {
			if (value){
				_behaviors = value;
			}
		}
		private var _behaviors:Collection = new Collection();
		
		/**
		 * Constructor for FeatureBase.  FeatureBase instances are not meant
		 * to be instantiated.  Rather, FeatureBase exists as a base class
		 * for the FeatureDefinition and Feature classes.
		 */
		public function FeatureBase() {
			
		}
		
		public function toString():String {
			var className:String = getQualifiedClassName(this);
			var index:int = className.indexOf("::");
			if (index != -1){
				className = className.substr(index + 2);
			}
			return "[" + className + " name: " + name + "]"; 
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {name:1,parentName:1};
		}
		
		public function getPropertiesIgnoredByXML():Object {
			return {};
		}
		
		public function getObjectAsXML():XML {
			return null;
		}
	}
}