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
	 * shared between both of those classes.
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
		 * inherits adjustments such as position, scale and
		 * rotation.
		 */
		public function get parentName():String { return _parentName; }
		public function set parentName(value:String):void {
			_parentName = value;
		}
		private var _parentName:String;
		
		/**
		 * Base adjustment on top of which other adjustments are applied.
		 * These are useful for starting adjustments for new features and
		 * to serve as an offset that a FeatureDefinition can apply to a
		 * feature's own adjust value.
		 * If both a feature and its definition specify a base ajustment,
		 * only the definition's base adjustment will be used.  Normally
		 * Feature.baseAdjust is not necessary. It is only really useful
		 * to help maintain parity with adjust combinations from feature 
		 * definitions. For example, when copying FeatureDefinition
		 * characteristics into Feature objects, you would want both the
		 * adjust and the baseAdjust values so that the combined adjust
		 * will be used for the avatar when a library and it's related
		 * definitions are not available.
		 */
		public function get baseAdjust():Adjust { return _baseAdjust; }
		public function set baseAdjust(value:Adjust):void {
			_baseAdjust = value;
		}
		private var _baseAdjust:Adjust;
		
		/**
		 * A collection of custom behaviors that are used to help
		 * determine the final render of an avatar feature.  Each
		 * behavior in this collection is used when drawing the feature's
		 * art, not just one as is the case with the Art, Color,
		 * and Adjust.
		 */
		public function get behaviors():Collection { return _behaviors; }
		public function set behaviors(value:Collection):void {
			if (value){
				_behaviors = value;
			}
		}
		private var _behaviors:Collection = new Collection();
		
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
		 * Generic object for storing custom data (metadata).
		 */
		public function get meta():Object { return _meta; }
		public function set meta(value:Object):void {
			_meta = value;
		}
		private var _meta:Object;
		
		/**
		 * Constructor for FeatureBase.  FeatureBase instances are not meant
		 * to be instantiated.  Rather, FeatureBase exists as a base class
		 * for the FeatureDefinition and Feature classes.
		 */
		public function FeatureBase(name:String = null) {
			if (name) this.name = name;
		}
		
		public function toString():String {
			var className:String = getQualifiedClassName(this);
			var index:int = className.indexOf("::");
			if (index != -1){
				className = className.substr(index + 2);
			}
			return "[" + className + " name:" + name + "]"; 
		}
		
		public function getObjectAsXML():XML {
			return null;
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {parentName:1, name:1};
		}
		
		public function getPropertiesIgnoredByXML():Object {
			return {};
		}
		
		public function getDefaultPropertiesInXML():Object {
			return {};
		}
	}
}