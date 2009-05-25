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
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A cropped (masked) area for viewing display objects.  Viewports
	 * make it easy to fit and/or center content within its boundaries
	 * as well as provide an easy means to produce a bitmap (BitmapData)
	 * of that content.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Viewport extends Sprite {
		
		/**
		 * The visible width of the viewport.  This represents
		 * the width of the mask used to crop viewport content.
		 */
		public override function get width():Number { return _width; }
		public override function set width(value:Number):void {
			_width = value;
			validateDisplayList();
			drawMask();
		}
		private var _width:Number = 100;
		
		/**
		 * The visible height of the viewport.  This represents
		 * the height of the mask used to crop viewport content.
		 */
		public override function get height():Number { return _height; }
		public override function set height(value:Number):void {
			_height = value;
			validateDisplayList();
			drawMask();
		}
		private var _height:Number = 100;
		
		/**
		 * Content to be viewed in the viewport. Only one display
		 * object at a time can be set as the content of a
		 * view port.  When set, that display object is removed
		 * from its current display list and added to the display
		 * list hierarchy of the Viewport instance.
		 */
		public function get content():DisplayObject { return _content; }
		public function set content(value:DisplayObject):void {
			while (contentSprite.numChildren){
				contentSprite.removeChildAt(0);
			}
			_content = value;
			validateDisplayList();
		}
		private var _content:DisplayObject;
		
		/**
		 * Specifies the background for the viewport. The background
		 * can be one of 3 types: A solid color specified by a number
		 * (representing the hexadecimal value of that color), a bitmap
		 * specified by a BitmapData instance of a background bitmap
		 * fill, or a display object whose center is placed at the 0,0
		 * location (top left) of the viewport.
		 */
		public function get background():Object { return _background; }
		public function set background(value:Object):void {
			_background = value;
			validateDisplayList();
			drawBackground();
		}
		private var _background:Object;
		
		private var maskSprite:Sprite = new Sprite();
		private var contentSprite:Sprite = new Sprite();
		private var bgSprite:Sprite = new Sprite();
		
		/**
		 * Constructor for creating new Viewport instances.
		 * @param	width The starting width of the viewport.
		 * @param	height The starting height of the viewport.
		 */
		public function Viewport(width:Number = 100, height:Number = 100) {
			this.width = width;
			this.height = height;
		}
		
		/**
		 * Centers the content within the viewport based on the visible
		 * area of the content and the size of the viewport.
		 */
		public function centerContent():void {
			if (_content == null) return;
			validateDisplayList();
			validatedCenter();
		}
		
		/**
		 * Creates and returns a BitmapData instance with the dimensions
		 * of the viewport with the contents of the viewport drawn within it.
		 * @param	scale An additional scale factor to apply to the 
		 * size of the returned BitmapData.  For example, if the viewport is
		 * 100x100 px and scale is specified as 2, the returned BitmapData
		 * would be 200x200 px.
		 * @return A BitmapData containing the a capture of the viewport
		 * contents. Null is returned on failure.
		 */
		public function capture(scale:Number = 1):BitmapData {
			if (scale <= 0) scale = 1;
			var bmp:BitmapData = new BitmapData(_width, _height, true, 0);
			var scaleMatrix:Matrix = new Matrix(scale, 0, 0, scale, 0, 0);
			try {
				bmp.draw(this, scaleMatrix, null, null, null, false);
			}catch (error:Error){
				bmp.dispose();
				bmp = null;
			}
			return bmp;
		}
		
		private function validatedCenter():void{
			var contentRect:Rectangle = _content.getBounds(contentSprite);
			var viewportCenter:Point = new Point(_width/2, _height/2);
			var contentCenter:Point = new Point(contentRect.x + contentRect.width/2, contentRect.y + contentRect.height/2);
			var offset:Point = viewportCenter.subtract(contentCenter);
			_content.x += offset.x;
			_content.y += offset.y;
		}
		
		public function fitContent():void {
			if (_content == null) return;
			validateDisplayList();
			
			var contentRect:Rectangle = _content.getBounds(contentSprite);
			var wRatio:Number = _width/contentRect.width;
			var hRatio:Number = _height/contentRect.height;
			var scale:Number = (hRatio < wRatio) ? hRatio : wRatio;
			
			// set size; not using scaleX/Y incase content is rotated
			_content.width = _content.width * scale;
			_content.height = _content.height * scale;
			
			validatedCenter();
		}
		
		private function drawMask():void {
			with(maskSprite.graphics){
				clear();
				beginFill(0, 1);
				drawRect(0, 0, _width, _height);
				endFill();
			}
			drawBackground();
		}
		
		private function drawBackground():void {
			clearBackground();
			if (_background === null) return;
			
			if (_background is Number){
				with (bgSprite.graphics){
					beginFill(parseInt(_background));
					drawRect(0, 0, _width, _height);
					endFill();
				}
			}else if (_background is BitmapData){
				with (bgSprite.graphics){
					beginBitmapFill(BitmapData(_background));
					drawRect(0, 0, _width, _height);
					endFill();
				}
			}else if (_background is DisplayObject){
				var bg:DisplayObject = _background as DisplayObject;
				bg.x = 0;
				bg.y = 0;
				bgSprite.addChildAt(bg, 0);
			}
		}
		
		private function clearBackground():void {
			bgSprite.graphics.clear();
			while (bgSprite.numChildren){
				bgSprite.removeChildAt(0);
			}
		}
		
		private function validateDisplayList():void {
			
			if (contentSprite.parent != this){
				addChildAt(contentSprite, 0);
			}
			
			if (maskSprite.parent != this){
				addChildAt(maskSprite, 1);
			}
			
			if (contentSprite.mask != maskSprite){
				contentSprite.mask = maskSprite;
			}
			
			if (bgSprite.parent != contentSprite){
				contentSprite.addChildAt(bgSprite, 0);
			}
			
			if (_content && _content.parent != contentSprite){
				contentSprite.addChildAt(_content, 1);
			}
		}
	}
}