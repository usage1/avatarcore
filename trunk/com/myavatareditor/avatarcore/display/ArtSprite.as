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
	
	import com.myavatareditor.avatarcore.Art;
	import com.myavatareditor.avatarcore.Avatar;
	import com.myavatareditor.avatarcore.Feature;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Represents an individual sprite within an avatar art.  Art
	 * variations represent one feature's appearance and can consist
	 * of one or more art sprites to visually represent a feature.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class ArtSprite extends Sprite {
		
		/**
		 * The Avatar instance associated with the AvatarArt
		 * object that contains this art sprite.
		 */
		public function get avatar():Avatar {
			return _feature ? _feature.avatar : null;
		}
		
		/**
		 * Feature associated with this art sprite.  This feature
		 * is used to draw the art sprite after the art has
		 * been loaded from the src.  
		 */
		public function get feature():Feature {
			return _feature;
		}
		public function set feature(value:Feature):void {
			if (value == _feature) return;
			
			_feature = value;
			draw();
		}
		private var _feature:Feature;
		
		/**
		 * Art object associated with this art sprite. This
		 * and the feature should be set at the same time if
		 * the art for this sprite is changed so that they
		 * remain congruent.
		 */
		public function get art():Art {
			return _art;
		}
		public function set art(value:Art):void {
			if (value == _art) return;
			
			_art = value;
			this.src = _art ? _art.src : null;
		}
		private var _art:Art;
		
		/**
		 * Z-index, or location within sorted arrangement
		 * of the art within an AvatarArt object as defined
		 * by the linked Art instance.
		 */
		public function get zIndex():Number {
			return _art && isNaN(_art.zIndex) == false ? _art.zIndex : 0;
		}
		
		/**
		 * The name of the feature associated with
		 * this art sprite.
		 */
		public function get featureName():String {
			return _feature ? _feature.name : null;
		}
		
		/**
		 * The art source as defined by the linked Art object.
		 * This is generally not set directly, instead relying
		 * on the src defined in the linked Art object.
		 */
		public function get src():String {
			return _src;
		}
		public function set src(value:String):void {
			if (value == null){
				_src = null;
				_srcFrame = null;
			}else{
				
				// separate any frame values from src
				var parts:Array = value.split("#");
				if (parts.length > 1){
					_src = parts[0];
					_srcFrame = parts[1];
				}else{
					_src = value;
					_srcFrame = null;
				}
			}
			
			loadSourceContent();
		}
		private var _src:String;
		private var _srcFrame:String;
		
		private var loader:Loader;
			
		/**
		 * Constructor for creating new ArtSprite instances. ArtSprite
		 * instances are created automatically by AvatarArt instances
		 * when drawing an avatar.
		 * @param	art
		 * @param	feature
		 */
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
				var content:* = new displayClass();
				
				// class can be for bitmaps or display objects
				content = (content is BitmapData)
					? new Bitmap(content as BitmapData)
					: DisplayObject(content);
				
				applyContentProperties(content);
				addChild(content);
				return;
				
			}catch (error:Error){
				print("Art Generation; class definition for asset '"+_src+"' not found ("+error+"). Attempting to load as external asset...", PrintLevel.DEBUG, this);
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
			if (_feature == null) {
				print("Cannot draw art sprite because feature is not defined", PrintLevel.WARNING, this);
				return;
			}
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
				var playable:MovieClip = removeChildAt(0) as MovieClip;
				// if a movie clip, prevent additional playback
				if (playable){
					playable.stop();
				}
			}
			
			loaderCleanup();
		}
		
		private function loaderCompleteHandler(event:Event):void {
			// make sure this complete handler is for 
			// the current loader and not some rogue loader
			// for content that got replaced during loading
			if (event.currentTarget != loader){
				return;
			}
			
			// loader isn't added until after it's loaded
			addChild(loader);
			
			// update visually
			applyContentProperties(loader.content);
			applyArtTransforms();
		}
		
		private function applyContentProperties(content:DisplayObject):void {
			
			// smooth bitmaps?
			if (_art && content is Bitmap){
				Bitmap(content).smoothing = isNaN(_art.smoothing) || Boolean(_art.smoothing);
			}
			
			// go to specified content frame
			if (_srcFrame && content is MovieClip){
				MovieClip(content).gotoAndStop(_srcFrame);
			}
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
		}
		
		private function loaderCleanup():void {
			if (loader == null) return;
			
			try {
				loader.close();
			}catch (error:Error){}
			
			// if a movie clip, prevent additional playback
			var playable:MovieClip = loader.content as MovieClip;
			if (playable){
				playable.stop();
			}
			
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