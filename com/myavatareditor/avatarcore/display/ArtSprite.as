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
	
	import com.myavatareditor.avatarcore.data.Art;
	import com.myavatareditor.avatarcore.data.Avatar;
	import com.myavatareditor.avatarcore.data.Feature;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import flash.display.Bitmap;
	import flash.display.LoaderInfo;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Represents an individual sprite within an art group.  Art groups
	 * represent one feature's appearance and can consist of one or more
	 * art sprites to visually represent a feature.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class ArtSprite extends Sprite {
		
		public function get avatar():Avatar {
			var avatarArt:AvatarArt = parent as AvatarArt;
			if (avatarArt){
				return avatarArt.avatar;
			}
			return null;
		}
		
		public function get feature():Feature {
			return _feature;
		}
		public function set feature(value:Feature):void {
			if (value == _feature) return;
			
			_feature = value;
			draw();
		}
		private var _feature:Feature;
		
		public function get art():Art {
			return _art;
		}
		public function set art(value:Art):void {
			if (value == _art) return;
			
			_art = value;
			this.src = _art ? _art.src : null;
		}
		private var _art:Art;
		
		
		public function get zIndex():Number {
			return _art && isNaN(_art.zIndex) == false ? _art.zIndex : 0;
		}
		public function get featureName():String {
			return _feature ? _feature.name : null;
		}
		
		public function get src():String {
			return _src;
		}
		public function set src(value:String):void {
			if (value == _src) return;
			
			_src = value;
			loadSourceContent();
		}
		private var _src:String;
		
		private var loader:Loader;
			
		public function ArtSprite(art:Art = null, feature:Feature = null) {
			
			// we're going under the assumption here that you'll want to
			// be able to select individual AvatarArt objects when picking
			// a feature to change through mouse interaction, and for that
			// the target of the click event should target this instance
			// rather than some child
			mouseChildren = false;
			
			this.art = art;
			this.feature = feature;
		}
		
		/**
		 * Rebuilds the art sprite from scratch refreshing
		 * its art source and then calling draw.
		 */
		public function rebuild():void {
			loadSourceContent();
			draw();
		}
		
		private function loadSourceContent():void {
			clearContent();
			
			if (_src == null) return;
			
			// try loading source as a class definition
			try {
				var displayClass:Class = getDefinitionByName(_src) as Class;
				addChild(new displayClass() as DisplayObject);
				return;
			}catch (error:Error){
				print("Art Generation; class definition for asset '"+_src+"' not found ("+error+"). Attempting to load as external asset...", PrintLevel.NORMAL, this);
			}
			
			
			// try loading source as a URL
			try {
				loaderSetup();
				loader.load(new URLRequest(_src));
			}catch (error:Error){
				loaderCleanup();
				print("Art Generation; failure trying to load asset '"+_src+"' ("+error+")", PrintLevel.ERROR, this);
			}
		}
		
		/**
		 * Updates the transformation of the art as defined
		 * by the feature referenced by the art sprite.
		 */
		public function draw():void {
			if (parent == null || _feature == null) return;
			_feature.drawArtSprite(this);
		}
		
		
		/**
		 * Clears all art content from the art sprite object
		 * and removes any references to other objects.
		 */
		public function deconstruct():void {
			clearContent();
			removeReferences();
		}
		
		private function removeReferences():void {
			_feature = null;
			_art = null;
		}
		
		/**
		 * Clears the art content within the art sprite.
		 */
		public function clearContent():void {
			while (numChildren){
				removeChildAt(0);
			}
			
			loaderCleanup();
		}
		
		private function loaderCompleteHandler(event:Event):void {
			// smooth loaded bitmaps
			var contentAsBitmap:Bitmap = LoaderInfo(event.currentTarget).content as Bitmap;
			if (contentAsBitmap){
				contentAsBitmap.smoothing = true;
			}
			
			// update visually
			applyArtTransforms();
		}
		
		private function applyArtTransforms():void {
			if (_art == null) return;
			if (numChildren){
				var content:DisplayObject = getChildAt(0);
				content.x = _art.x;
				content.y = _art.y;
			}
		}
		
		private function loaderErrorHandler(errorEvent:ErrorEvent):void {
			print("Art Generation; failure while loading an asset URL ("+errorEvent.text+")", PrintLevel.ERROR, this);
			loaderCleanup();
		}
		
		private function loaderSetup():void {
			loaderCleanup();
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderErrorHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderErrorHandler, false, 0, true);
			addChild(loader);
		}
		
		private function loaderCleanup():void {
			if (loader == null) return;
			
			try {
				loader.close();
			}catch (error:Error){}
			
			loader.unload();
			if (loader.parent){
				loader.parent.removeChild(loader);
			}
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler, false);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderErrorHandler, false);
			loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderErrorHandler, false);
			
			loader = null;
		}
	}
}