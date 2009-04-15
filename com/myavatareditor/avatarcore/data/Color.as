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
	
	import com.myavatareditor.avatarcore.xml.IXMLWritable;
	import flash.geom.ColorTransform;
	
	/**
	 * An extended version of flash.geom.ColorTransform
	 * that includes a name property for referencing
	 * through collections.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Color extends ColorTransform implements IXMLWritable {
		
		public var name:String;
		
		public function Color(redMultiplier:Number = 1.0, greenMultiplier:Number = 1.0, blueMultiplier:Number = 1.0, alphaMultiplier:Number = 1.0,
							redOffset:Number = 0, greenOffset:Number = 0, blueOffset:Number = 0, alphaOffset:Number = 0) {
						
			super(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier,
				redOffset, greenOffset, blueOffset, alphaOffset);
		}
		
		public function getPropertiesIgnoredByXML():Object {
			return {};
		}
		
		public function getPropertiesAsAttributesInXML():Object {
			return {name:1, redMultiplier:1, greenMultiplier:1, blueMultiplier:1, alphaMultiplier:1,
				redOffset:1, greenOffset:1, blueOffset:1, alphaOffset:1};
		}
		
		public function getObjectAsXML():XML {
			var xml:XML = <Color />;
			if (name){
				xml.@name = name;
			}
			if (redMultiplier == 0 && greenMultiplier == 0 && blueMultiplier == 0 && alphaMultiplier == 1.0){
				xml.@color = "#" + color.toString(16);
			}else{
				if (redMultiplier != 1.0) xml.@redMultiplier = redMultiplier;
				if (greenMultiplier != 1.0) xml.@greenMultiplier = greenMultiplier;
				if (blueMultiplier != 1.0) xml.@blueMultiplier = blueMultiplier;
				if (alphaMultiplier != 1.0) xml.@alphaMultiplier = alphaMultiplier;
				if (redOffset != 0) xml.@redOffset = redOffset;
				if (greenOffset != 0) xml.@greenOffset = greenOffset;
				if (blueOffset != 0) xml.@blueOffset = blueOffset;
				if (alphaOffset != 0) xml.@alphaOffset = alphaOffset;
			}
			return xml;
		}
	}
}