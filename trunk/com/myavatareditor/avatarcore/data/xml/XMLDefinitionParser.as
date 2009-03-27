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
package com.myavatareditor.avatarcore.data.xml {
	
	import com.myavatareditor.avatarcore.data.ICollection;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * A generic XML parser for parsing XML into an object of
	 * a non-specific type. Attributes and child elements within a
	 * parent elements match the properties of that parent element's
	 * class.  If the parent element does not have a property of that
	 * name, the value is ignored.  Child elements may not be ignored
	 * if the parent class is an ICollection at which point the child
	 * is converted to an object and added to the parent as a collection
	 * item.  For nodes with ref attributes, their values become a
	 * previously defined element's value with the matching name
	 * attribute value.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class XMLDefinitionParser {
		
		private var lookup:Object;
		private var lookupAttribute:String = "name";
		
		public function XMLDefinitionParser() {
			
		}
		
		/**
		 * Parses the content of an XML node into an object. It is
		 * assumed that the target object has the properties to 
		 * facilitate the properties defined in XML or is of the type
		 * ICollection to be able to store non-property definitions
		 * within an internal list in the object.
		 * @param	node The XML to parse.
		 * @param	target The object to parse the XML definition into.
		 */
		public function parse(node:XML, target:Object):void {
			lookup = {};
			parseNode(node, target);
			lookup = null;
		}
		
		private function parseNode(node:XML, target:Object):void {
			if (node == null || target == null) return;
			
			// assign attributes first pass for any
			// dependencies on contained objects
			assignAttributes(target, node);
			
			var element:XML;
			var attsParsed:Boolean;
			var name:String;
			var ref:Object;
			var children:XMLList;
			var firstChild:XML;
			var instance:Object;
			for each(element in node.elements()){
				
				attsParsed = false;
				name = element.localName();
				
				// check to see if the name of the element exists
				// as a property of the target object. If so, the
				// value of the XML element will be assigned to
				// that property
				if (name in target){
					
					ref = lookup[element.@ref] as Object;
					if (ref == null && element.@ref != undefined){
						print("Parsing XML; couldn't find referenced object named '"+element.@ref+"' for "+name, PrintLevel.ERROR, this);
					}
					
					if (ref){
						// referencing a pre-created object
						// in the XML 
						target[name] = ref;
						
					}else{
						
						children = element.children();
						
						// A new object value; there should only be
						// one node; others, if present, are ignored
						var numChildren:int = children.length();
						if (numChildren != 0){
							firstChild = children[0];
							
							if (numChildren == 1 && firstChild.nodeKind() == "text"){
								// for simple text elements, the text is
								// converted to a primitive value
								assignPrimitiveValue(target, name, String(firstChild));
								
							}else if (target[name] != null 
							      && firstChild.name().toString() != getQualifiedClassName(target[name])){
								// parse node into existing value
								parseNode(element, target[name]);
								attsParsed = true;
							}else{
								// create definition from first child element as object
								try {
									target[name] = createObject(firstChild);
								}catch (error:Error){
									// likely a type error where createObject
									// created an instance of an incompatible type
									print("Parsing XML; couldn't assign an XML-generated object to an object property ("+error+")", PrintLevel.ERROR, this);
								}
							}
						}
					}
					
					if (!attsParsed && target[name] != null){
						// if target value exists, assign attributes
						// these are assigned on top of any existing
						// values (node parsing already adds these)
						assignAttributes(target[name], element);
					}
					
				}else if (target is ICollection){
					// for non-property values, the only way
					// definitions can be assigned to the target
					// object is if the object is a collcetion
					instance = createObject(element);
					if (instance){
						ICollection(target).addCollectionItem(instance);
					}
				}
			}
		}
		
		private function createObject(element:XML):Object {
			var qname:QName;
			var name:String;
			var def:Class;
			var instance:Object;
			try {
				qname = element.name();
				name = (qname.uri) ? qname.uri + "::" + qname.localName : qname.localName;
				def = getDefinitionByName(name) as Class;
				instance = new def();
			}catch (error:Error){
				// likely to occur if the definition of the class
				// does not exist within the application
				print("Parsing XML; cannot create a new object instance from "+name+" ("+error+")", PrintLevel.ERROR, this);
			}
			
			if (instance){
				parseNode(element, instance);
				return instance;
			}
			
			return null;
		}
		
		private function assignAttributes(target:Object, element:XML):void {
			var att:XML;
			var name:String;
			var value:String;
			for each (att in element.attributes()){
				name = att.localName();
				value = String(att);
				
				// if an attribute of the name defined by 
				// lookupAttribute is found, be sure to
				// update the lookup table so the object
				// can be referenced through ref attributes
				if (name == lookupAttribute){
					lookup[value] = target;
				}
				
				assignPrimitiveValue(target, name, value);
			}
		}
		
		private function assignPrimitiveValue(target:Object, name:String, value:String):void {
			if (name in target == false) return;
			var origValue:* = target[name];
			
			switch(typeof origValue){
				
				case "boolean":
					value = value.toLowerCase();
					if (value == "0" || value == "false"){
						target[name] = false
					}else{
						target[name] = true;
					}
					break;
					
				case "number":
					if (value.charAt(0) == "#"){
						target[name] = parseInt(value.substr(1), 16);
					}else{
						target[name] = Number(value);
					}
					break;
					
				case "string":
				default:
					target[name] = value;
					break;
			}
		}
	}
}