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
	
	/**
	 * Represents the characteristics of the visual art used
	 * to graphically represent the different features of an
	 * avatar.  The Art class is also a collection allowing it
	 * to contain other objects, namely other Art objects.  This
	 * allows one Art object to be a container for multiple Art
	 * instances if a feature requires more than one art asset
	 * to represent it visually.  If an Art object is being used
	 * in that fashion, its own art definitions are ignored and
	 * only the Art instances it contains are used as feature art.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Art extends Collection {
		
		/**
		 * Name identifier for the Art object. Art is referenced
		 * by name from features through a feature's art.  If an 
		 * Art object is acting as a container for multiple Art
		 * assets, that container Art should be named and referenced
		 * by the respective feature.  The child Art object names
		 * are ignored.
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void {
			_name = value;
		}
		
		private var _name:String;
		
		/**
		 * Horizontal location (offset) of the art graphics
		 * within an art sprite. This value should be set 
		 * before the art is drawn in an art sprite. If changed
		 * while the art is being displayed for an avatar, the
		 * effects will not be seen until the feature art is
		 * rebuilt.
		 */
		public function get x():Number { return _x; }
		public function set x(value:Number):void {
			_x = value;
		}
		private var _x:Number = 0;
		
		/**
		 * Vertical location (offset) of the art graphics
		 * within an art sprite. This value should be set 
		 * before the art is drawn in an art sprite. If changed
		 * while the art is being displayed for an avatar, the
		 * effects will not be seen until the feature art is
		 * rebuilt.
		 */
		public function get y():Number { return _y; }
		public function set y(value:Number):void {
			_y = value;
		}
		private var _y:Number = 0;
		
		/**
		 * Arrangement value to be used in determining the stacking
		 * order of all the art composed within an AvatarArt instance.
		 * The higher the zIndex, the higher the art in the stacking
		 * order.  If two objects share the same zIndex, there is no
		 * guarantee as to the order of their arrangement.  You should
		 * always specify unique zIndex values for avatar art.
		 */
		public function get zIndex():Number { return _zIndex; }
		public function set zIndex(value:Number):void {
			_zIndex = value;
		}
		private var _zIndex:Number; // default NaN
		
		/**
		 * The art source. This can be either a class name or a
		 * URL referencing a loaded asset such as a JPEG file.
		 */
		public function get src():String { return _src; }
		public function set src(value:String):void {
			_src = value;
		}
		private var _src:String;
		
		/**
		 * The source of the thumbnail to be used for previewing the
		 * art for the user. This can be either a class name or a
		 * URL referencing a loaded asset. Management of a thumbnail
		 * is handled by a custom editor; the framework does not 
		 * internally depend on or otherwise use this value.
		 */
		public function get thumbnail():String { return _thumbnail; }
		public function set thumbnail(value:String):void {
			_thumbnail = value;
		}
		private var _thumbnail:String;
		
		/**
		 * Indicates whether or not the art is colorized when
		 * a color is applied to the art's feature. Zero (0)
		 * or NaN means no coloring, One (1) means coloring is
		 * applied.
		 */
		public function get colorize():Number { return _colorize; }
		public function set colorize(value:Number):void {
			_colorize = value;
		}
		private var _colorize:Number; // Number instead of Boolean for inheritance (NaN recognition)
		
		/**
		 * The style name for the art.  In specifying a style, you
		 * limit the use of the art to only features with the same
		 * artStyle defined. By default both Art.style and 
		 * Feature.artStyle are null, so all art is used.  Whenever
		 * one or the other is changed, the art will be ignored unless
		 * it's value of style matches the feature's.  This is an
		 * optional property that is used for more advanced control
		 * over the application of feature art.
		 */
		public function get style():String { return _style; }
		public function set style(value:String):void {
			_style = value;
		}
		private var _style:String;
		
		/**
		 * Constructor for creating new Art instances.
		 * @param src Source of the art content.
		 */
		public function Art(src:String = null) {
			this.src = src;	
		}
		
		/**
		 * Creates and returns a copy of the Art object.
		 * If the Art object has any Art children in its
		 * collection, they are also cloned and placed
		 * within the cloned Art's collection
		 * @return A copy of this Color object.
		 */
		public function clone():Art {
			var copy:Art = new Art(src);
			copy.name = name;
			copy.x = x;
			copy.y = y;
			copy.thumbnail = thumbnail;
			copy.zIndex = zIndex;
			copy.colorize = colorize;
			copy.style = style;
			copy.copyCollectionFrom(this);
			return copy;
		}
		
		public override function getPropertiesAsAttributesInXML():Object {
			var obj:Object = super.getPropertiesAsAttributesInXML();
			obj.x = 1;
			obj.y = 1;
			obj.src = 1;
			obj.thumbnail = 1;
			obj.zIndex = 1;
			obj.colorize = 1;
			obj.style = 1;
			return obj;
		}
		
		/**
		 * Custom addItem that assigns default colorize and
		 * zIndex values to added Art objects when their values are
		 * undefined.
		 * @param	item Item to be added to the art set collection.
		 * @return The collection item added.
		 */
		public override function addItem(item:*):* {
			
			// assign default properties to added art
			if (item is Art) {
				var artItem:Art = item as Art;
				artItem.assignDefaults(_zIndex, _colorize);
			}
			
			return super.addItem(item);
		}
		
		/**
		 * Assigns values passed as defaults to the art object if
		 * they're not already defined.  If the collection of the
		 * art object has any art objects within, they are assigned
		 * defaults as well.
		 * @param	zIndex Default zIndex.
		 * @param	colorize Default colorize.
		 */
		public function assignDefaults(zIndex:Number = Number.NaN, colorize:Number = Number.NaN):void {
			
			if (isNaN(zIndex) == false && isNaN(_zIndex)) {
				_zIndex = zIndex;
			}
			
			if (isNaN(colorize) == false && isNaN(_colorize)) {
				_colorize = colorize;
			}
			
			// assign defaults to child Art items in collection
			var children:Array = this.collection;
			if (children.length) {
				
				var childArt:Art;
				var i:int = children.length;
				while (i--) {
					childArt = children[i] as Art;
					if (childArt){
						childArt.assignDefaults(_zIndex, _colorize);
					}
				}
			}
		}
	}
}