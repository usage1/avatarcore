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
	
	import com.myavatareditor.avatarcore.Feature;
	import flash.events.Event;
	
	/**
	 * Event class for feature-specific events.  In addition to
	 * standard event properties, this class includes a feature
	 * member representing the feature for which the event is
	 * associated.
	 * @author Trevor McCauley; www.senocular.com
	 */
	public class FeatureEvent extends Event {
		
		public static const FEATURE_ADDED:String = "featureAdded";
		public static const FEATURE_REMOVED:String = "featureRemoved";
		public static const FEATURE_CHANGED:String = "featureChanged";
		
		/**
		 * The Feature object associated with this event.
		 */
		public function get feature():Feature { return _feature; }
		public function set feature(value:Feature):void {
			_feature = value;
		}
		private var _feature:Feature;
		
		public function FeatureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, feature:Feature = null) {
			super(type, bubbles, cancelable);
			this.feature = feature;
		}
		
		public override function clone():Event {
			return new FeatureEvent(type, bubbles, cancelable, _feature);
		}
	}
}