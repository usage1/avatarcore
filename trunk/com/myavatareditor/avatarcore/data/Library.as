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
	
	import com.myavatareditor.avatarcore.data.Collection;
	
	/**
	 * A collection of feature definitions associated with Avatar
	 * objects.  At any time an avatar can change its library to
	 * another allowing it to completely change it's style.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class Library extends Collection {
		
		public function get featureDefinitions():Array {
			var result:Array = [];
			var source:Array = this.collection;
			var definition:FeatureDefinition;
			var i:int, n:int = source.length;
			for (i=0; i<n; i++){
				definition = source[i] as FeatureDefinition;
				if (definition){
					result.push(definition);
				}
			}
			return result;
		}
		
		public function Library() {
			
		}
		
	}
	
}