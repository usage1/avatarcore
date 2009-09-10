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
package com.myavatareditor.avatarcore.events {
	
	import com.myavatareditor.avatarcore.FeatureDefinition;
	import flash.events.Event;
	
	/**
	 * Event class for feature definition-specific events.  In addition
	 * to standard event properties, this class includes a feature
	 * definition member representing the feature for which the event
	 * is associated.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class FeatureDefinitionEvent extends Event {
		
		public static const ADDED:String = "featureDefinitionAdded";
		public static const REMOVED:String = "featureDefinitionRemoved";
		public static const CHANGED:String = "featureDefinitionChanged";
		
		/**
		 * The FeatureDefinition object associated with this event.
		 */
		public function get featureDefinition():FeatureDefinition { return _featureDefinition; }
		public function set featureDefinition(value:FeatureDefinition):void {
			_featureDefinition = value;
		}
		private var _featureDefinition:FeatureDefinition;
		
		public function FeatureDefinitionEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, featureDefinition:FeatureDefinition = null) {
			super(type, bubbles, cancelable);
			this.featureDefinition = featureDefinition;
		}
		
		public override function clone():Event {
			return new FeatureDefinitionEvent(type, bubbles, cancelable, _featureDefinition);
		}
	}
}