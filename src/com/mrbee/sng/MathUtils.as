/******************************************************************
 * SNG - Sequence Network Graphic
 * Copyright (C) 2011 Mr.Bee, LLC
 * For more information see http://www.mrbee.com.ua
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this lib.
 ****************************************************************/
package com.mrbee.sng
{
	/**
	 * @private 
	 * @author Poluosmak Andrew 
	 */	
	public class MathUtils
	{
		/**
		 * @private 
		 */		
		public static function min(val1:Number, val2:Number):Number {
			return val1 < val2 ? val1 : val2;
		}
		
		/**
		 * @private 
		 */
		public static function max(val1:Number, val2:Number):Number {
			return val1 > val2 ? val1 : val2;
		}
		
		/**
		 * @private 
		 */
		public static function ceilPositiveOnly(value:Number): Number {
			var valueInt:int = value;
			if (value == valueInt)
				return value;
			else
				valueInt = value + 1;
				return valueInt;
		}
		
		/**
		 * @private 
		 */
		public static function ceil(value:Number): Number {
			var valueInt:int = value;
			if (value == valueInt)
				return value;
			else if (value >= 0)
				return value + 1;
			
			return valueInt;
		}
	}
}