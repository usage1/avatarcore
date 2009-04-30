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
	
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import com.myavatareditor.avatarcore.events.SimpleDataEvent;
	import com.myavatareditor.avatarcore.xml.XMLDefinitionParser;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * A collection of definitions such as Library and Avatar instances 
	 * to be used with the Avatar Core framework. These are typically 
	 * definitions acquired from XML.  One specific feature of the Definitions
	 * class is that it handles the linking of Library and Avatar instances
	 * when an avatar is added to the Definitions collection and a Library
	 * exists within the collection with the name specified in 
	 * Avatar.libraryName.  Upon adding that avatar, it's library is set to
	 * that respective Library instance.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Definitions extends Collection {
		
		private var xmlLoader:URLLoader = new URLLoader();
		
		/**
		 * Custom addItem which creates associations with avatars
		 * and libraries when avatars specify a libraryName.
		 * @param	item The item to be added to the collection.
		 * @return The item added to the collection.
		 */
		public override function addItem(item:*):* {
			var avatarItem:Avatar;
			
			if (item is Avatar){
				
				// associate avatar with library
				avatarItem = item as Avatar;
				var library:Library = getItemByName(avatarItem.libraryName) as Library;
				if (library){
					avatarItem.library = library;
				}
				
			}else if (item is Library){
				
				// work the other way around, associating
				// new libraries with any avatars
				var libraryItem:Library = item as Library;
				var libraryName:String = libraryItem.name;
				if (libraryName){
					var avatars:Array = getItemsByType(Avatar);
					var i:int = avatars.length;
					while (i--){
						avatarItem = avatars[i] as Avatar;
						if (avatarItem.libraryName == libraryName){
							avatarItem.library = libraryItem;
						}
					}
				}
			}
			
			return super.addItem(item);
		}
		
		/**
		 * Constructor for creating new Definition instances. 
		 * Definition instances are typically created through
		 * XML.
		 */
		public function Definitions() {
			xmlLoader.addEventListener(Event.COMPLETE, xmlCompleteHandler, false, 0, true);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlCompleteHandler, false, 0, true);
			xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlCompleteHandler, false, 0, true);
		}
		
		/**
		 * Loads and parses an XML file into the Definitions object. 
		 * When loaded, all collection content in this object are cleared
		 * and the first Definitions node in the XML file is found and
		 * parsed into this object.  A SimpleDataEvent of the type
		 * Event.COMPLETE is dispatched when this process is complete. If 
		 * there was an error, the COMPLETE event is still dispatched, but
		 * the DataEvent.error property will contain the error that
		 * occured.
		 * @param	request A URLRequest linking to the xml file to be loaded.
		 */
		public function loadXML(request:URLRequest):void {
			try {
				xmlLoader.load(request);
			}catch (error:Error){
				
				// synchronous error, dispatch event with the error
				var completeEvent:SimpleDataEvent = new SimpleDataEvent(Event.COMPLETE, false, false, null, error);
				dispatchEvent(completeEvent);
			}
		}
		
		private function xmlCompleteHandler(event:Event):void {
			var completeEvent:SimpleDataEvent = new SimpleDataEvent(Event.COMPLETE, false, false, xmlLoader.data);
			
			if (event is ErrorEvent){
				completeEvent.error = event;
			}else{
				var xml:XML;
				
				try {
					xml = new XML(xmlLoader.data);
				}catch (error:Error){
					completeEvent.error = error;
				}
				
				setXML(xml);
			}
			
			dispatchEvent(completeEvent);
		}
		
		/**
		 * Sets the definition of the Definitions object based on the
		 * XML provided, this works much in the same way as loadXML but
		 * does not load the XML from a URL. Rather, it is passed directly
		 * into this method.
		 * @param	xml XML to be parsed into this Definitions object.
		 * @throws Error Any error thrown by the XML object if parsing fails.
		 */
		public function setXML(xml:XML):void {
			if (xml == null) return;
			var definitions:XMLList = xml + xml.descendants("Definitions");
		
			if (definitions.length()){
				clearCollection();
				var parser:XMLDefinitionParser = new XMLDefinitionParser();
				parser.parseInto(definitions[0], this); // use the first if many
			}else{
				print("Definitions object cannot be derived from XML because no <Definitions> node exists", PrintLevel.WARNING, this);
			}
		}
	}
}