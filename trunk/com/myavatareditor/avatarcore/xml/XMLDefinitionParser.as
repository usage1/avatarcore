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
package com.myavatareditor.avatarcore.xml {
	
	import com.myavatareditor.avatarcore.Collection;
	import com.myavatareditor.avatarcore.ICollection;
	import com.myavatareditor.avatarcore.debug.print;
	import com.myavatareditor.avatarcore.debug.PrintLevel;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * A generic XML parser for parsing XML into an object of its respective
	 * type. Classes specified within XML must be able to be instantiated
	 * without constructor arguments as they are not supplied when instances
	 * are created by the parser. Attributes and child elements within a
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
		private var definitionLookup:Object = { };
		
		public function XMLDefinitionParser() {
			
		}
		
		/**
		 * Parses the content of an XML node into an existing object.
		 * It is assumed that the target object has the properties to 
		 * facilitate the properties defined in XML or is of the type
		 * ICollection to be able to store non-property definitions
		 * within an internal list in the object.
		 * @param	node The XML to parse.
		 * @param	target The object to parse the XML definition into.
		 */
		public function parseInto(node:XML, target:Object):void {
			lookup = {};
			parseNodeInto(node, target);
			lookup = null;
		}
		
		/**
		 * Parses the content of an XML node into an object and returns it.
		 * It is assumed that the created object has the properties to 
		 * facilitate the properties defined in XML or is of the type
		 * ICollection to be able to store non-property definitions
		 * within an internal list in the object.
		 * @param	node The XML to parse.
		 * @return	The object created as a result of parsing the XML.
		 */
		public function parse(node:XML):Object {
			lookup = {};
			var result:Object = createObject(node);
			lookup = null;
			return result;
		}
		
		private function parseNodeInto(node:XML, target:Object):void {
			if (node == null || target == null) return;
			
			var targetType:XML = describeType(target);
			var targetMembers:XMLList = targetType..variable + targetType..accessor + targetType..method;
			
			// assign attributes first pass for any
			// dependencies on contained objects
			assignAttributes(target, node);
			
			var element:XML;
			var attsParsed:Boolean;
			var elemName:String;
			var memberType:String;
			var ref:Object;
			var children:XMLList;
			var firstChild:XML;
			var instance:Object;
			for each(element in node.elements()){
				
				attsParsed = false;
				elemName = element.localName();
				
				// check to see if the name of the element exists
				// as a property of the target object. If so, the
				// value of the XML element will be assigned to
				// that property
				if (elemName in target){
					memberType = targetMembers.(attribute("name") == elemName).@type.toString();
				
					// ----------------------------------------------
					// referencing a pre-created object
					// in the XML if defined
					ref = lookup[element.@ref] as Object;
					if (ref == null && element.@ref != undefined){
						print("Parsing XML; couldn't find referenced object named '"+element.@ref+"' for "+elemName, PrintLevel.ERROR, this);
					}
					if (ref) {
						
						target[elemName] = ref;
						
					}else{
						// normal, non-referenced definition
						
						children = element.children();
						
						// A new object value; there should only be
						// one node; others, if present, are ignored
						var numChildren:int = children.length();
						if (numChildren != 0) {
							
							firstChild = children[0];
							
							// ----------------------------------------------
							// for simple text elements, the text is
							// converted to a primitive value
							if (numChildren == 1 && firstChild.nodeKind() == "text"){
								
								assignPrimitiveValue(target, elemName, firstChild.toString());
							
							
							// ----------------------------------------------
							// if the first and only node is of the target type,
							// that full object is the target property's full definition
							}else if (numChildren == 1 && firstChild.name().toString() == memberType) {
								
								// create definition from first child element as object
								try {
									target[elemName] = createObject(firstChild);
								}catch (error:Error){
									// likely a type error where createObject
									// created an instance of an incompatible type
									print("Parsing XML; couldn't assign an XML-generated object to an object property ("+error+")", PrintLevel.ERROR, this);
								}
								
								
							// ----------------------------------------------
							// otherwise parse the nodes into the existing value
							}else{
								
								// create object if null
								if (target[elemName] == null) {
									target[elemName] = getInstanceFromType(memberType);
								}
								
								// parse node into existing value
								if (target[elemName] != null) {
									parseNodeInto(element, target[elemName]);
									attsParsed = true; // parsing automatically parses attributes
								}
							}
						
						// no child elements
						}else {
							
							// create object if null
							if (target[elemName] == null) {
								target[elemName] = getInstanceFromType(memberType);
							}
						}
					}
					
					if (!attsParsed){
						// assign attributes on top of any existing
						// values (node parsing already adds these)
						assignAttributes(target[elemName], element);
					}
					
				
				// property elemName not in target
				}else if (target is ICollection) {
					
					// for non-property values, the only way
					// definitions can be assigned to the target
					// object is if the object is a collcetion
					instance = createObject(element);
					if (instance){
						ICollection(target).addItem(instance);
					}
				}
			}
		}
		
		private function createObject(element:XML):Object {
			var qname:QName = element.name();
			var elemName:String = (qname.uri) ? qname.uri + "::" + qname.localName : qname.localName;
			var instance:Object = getInstanceFromType(elemName);
			if (instance){
				parseNodeInto(element, instance);
			}
			return instance;
		}
		
		private function getInstanceFromType(type:String):Object {
			var instance:Object;
			var instanceClass:Class;
			try {
				instanceClass = getDefinitionByName(type) as Class;
				instance = new instanceClass();
				
			}catch (error:ArgumentError){
				print("Parsing XML; Class " + type + " cannot be instantiated because it contains required parameters", PrintLevel.WARNING, this);
				return null;
				
			}catch (error:Error){
				// likely to occur if the definition of the class
				// does not exist within the application
				print("Parsing XML; cannot locate definition for " + type, PrintLevel.WARNING, this);
				return null;
			}			
			return instance;
		}
		
		private function assignAttributes(target:Object, element:XML):void {
			if (target == null || element == null) return;
			var att:XML;
			var elemName:String;
			var value:String;
			for each (att in element.attributes()){
				elemName = att.localName();
				value = String(att);
				
				// if an attribute of the name defined by 
				// nameKey is found, be sure to
				// update the lookup table so the object
				// can be referenced through ref attributes
				if (elemName == Collection.nameKey){
					lookup[value] = target;
				}
				
				assignPrimitiveValue(target, elemName, value);
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