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
	 * Sprite class which contains a src property for loading content
	 * of various types including class instances or external content
	 * loaded through an internal Loader instance.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class SourceLoaderSprite extends Sprite {
		
		/**
		 * The art source as defined by the linked Art object.
		 * This is generally not set directly, instead relying
		 * on the src defined in the linked Art object.
		 */
		public function get src():Object {
			return _src;
		}
		public function set src(value:Object):void {
			var origSrc:Object = _src;
			
			_src = value;
			_srcFrame = null;
				
			// separate any frame values from src
			if (_src is String){
				var parts:Array = _src.split("#");
				if (parts.length > 1){
					_src = parts[0];
					_srcFrame = parts[1];
				}
			}
			
			// this is compared against the original
			// src value since its possible the only
			// change in the value is a new frame number
			// at which case the content doesn't need
			// to be reloaded
			if (_src != origSrc){
				_loaded = false;
			}
			
		}
		private var _src:Object;
		private var _loaded:Boolean;
		
		/**
		 * The frame defined by src.  This can be numeric in nature
		 * or the name of a frame.  In both cases, it's value is of
		 * the type String.
		 */
		public function get srcFrame():String {
			return _srcFrame;
		}
		private var _srcFrame:String;
		
		/**
		 * A reference to the content loaded into the sprite. This
		 * could reference a newly created DisplayObject instance
		 * from a class reference, or the Loader.content reference
		 * for externally loaded content.  If Loader.content is not
		 * accessible due to security restrictions, this property will
		 * instead reference the Loader instance.
		 */
		public function get content():DisplayObject {
			return _content;
		}
		private var _content:DisplayObject;
		
		private var loader:Loader;
			
		/**
		 * Constructor for creating new ArtSprite instances. ArtSprite
		 * instances are created automatically by AvatarDisplay instances
		 * when drawing an avatar.
		 * @param	art Graphic Art object associated with this sprite.
		 * A single feature may use multiple art sprites if it is using
		 * multiple Art instances to describe itself visually. The art
		 * used here is one of those instances (not necessarily the
		 * single Art reference of the feature)
		 * @param	feature The feature being rendered through this sprite.
		 */
		public function SourceLoaderSprite(src:String = null, autoLoad:Boolean = false) {
			if (src) {
				this.src = src;
				load();
			}
		}
		
		/**
		 * Reloads or reinstantiates the source (src) of the sprite.
		 */
		public function reload():void {
			loadSourceContent();
		}
		/**
		 * Loads the source content into the SourceLoaderSprite.  If the
		 * content has already been loaded, it won't be loaded again.
		 * @param	src New source content to replace the existing
		 * src value.  This is optional. If not provided, the existing
		 * src value is loaded.
		 */
		public function load(src:String = null):void {
			if (src) this.src = src;
			if (!_loaded){
				loadSourceContent();
			}
		}
		
		private function loadSourceContent():void {
			clearContent();
			if (!_loaded) _loaded = true;
			addSourceContent(_src);
		}
		
		private function addSourceContent(source:*):void {
			if (source == null) return;
			
			// try loading source as a class definition
			if (source is String){
					
				try {
					
					var displayClass:Class = getDefinitionByName(source) as Class;
					addInstance(new displayClass());
					return;
					
				}catch (error:Error){
					print("Art Generation; class definition for asset '"+source+"' not found ("+error+"). Attempting to load as external asset...", PrintLevel.DEBUG, this);
				}
				
				// try loading source as a URL
				try {
					loaderSetup();
					loader.load(new URLRequest(source));
				}catch (error:Error){
					loaderCleanup();
					print("Art Generation; failure trying to load asset '"+source+"' ("+error+")", PrintLevel.ERROR, this);
				}
				
			}else if (source is Class){
				
				try {
					addInstance(new source());
				}catch (error:Error){
					print("Art Generation; invalid class definition for art source ("+source+")", PrintLevel.DEBUG, this);
				}
				
			}else if (source is Function){
				
				try {
					addSourceContent(source());
				}catch (error:Error){
					print("Art Generation; failure in generating content ("+error+")", PrintLevel.DEBUG, this);
				}
				
			}else{
				
				try {
					addInstance(source);
				}catch (error:Error){
					print("Art Generation; failure in adding content ("+error+")", PrintLevel.DEBUG, this);
				}
				
			}
		}
		
		private function addInstance(newContent:Object):void {
			
			// class can be for bitmaps or display objects
			try {
				_content = (newContent is BitmapData)
					? new Bitmap(newContent as BitmapData)
					: DisplayObject(newContent);
					
				setContentFrame();
				addChild(_content);
				
			}catch (error:Error){}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function setContentFrame():void {
			// go to specified content frame
			var playable:MovieClip = _content as MovieClip
			if (playable && _srcFrame){
				playable.gotoAndStop(_srcFrame);
			}
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
			
			_content = null;
			loaderCleanup();
		}
		
		private function loaderCompleteHandler(event:Event):void {
			
			// make sure this complete handler is for 
			// the current loader and not some rogue loader
			// for content that got replaced during loading
			if (loader == null || event.currentTarget != loader.contentLoaderInfo){
				print("Content loaded but no longer valid; aborting", PrintLevel.WARNING, this);
				return;
			}
			
			// loader isn't added until after it's loaded
			addChild(loader);
			
			try {
				
				_content = loader.content;
				setContentFrame();
				
			}catch (error:Error){
				// likely a security error because access content 
				// (from untrusting domain?) is not allowed.
				// Instead reference Loader
				_content = loader;
			}
			
			// dispatch complete event
			dispatchEvent(new Event(Event.COMPLETE));
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
			
			var playable:MovieClip = loader.content as MovieClip;
			// if a movie clip, prevent additional playback
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