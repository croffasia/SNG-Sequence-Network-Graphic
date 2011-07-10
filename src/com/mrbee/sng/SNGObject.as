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
	import flash.display.BitmapData;

	/**
	 * Class to simplify working with AMB data
	 * @author Poluosmak Andrew 
	 */	
	public class SNGObject
	{		
		/**
		 * Format version number 
		 */
		public var version:int = 0;
		
		/**
		 * Total Frames in SpriteSheet 
		 */
		public var totalFrames:int = 0;
		
		/**
		 * SpriteSheet frame width 
		 */
		public var width:int = 0;
		
		/**
		 * SpriteSheet frame heigh 
		 */
		public var height:int = 0;
		
		/**
		 * SpriteSheet frame x offset 
		 */		
		public var xOffset:int = 0;
		
		/**
		 * SpriteSheet frame y offset 
		 */		
		public var yOffset:int = 0;
		
		/**
		 * First image data  
		 */		
		public var firstData:BitmapData = null;
		
		/**
		 * Sprite sheet items bitmapdata 
		 */		
		public var sheetItems:Vector.<BitmapData> = new Vector.<BitmapData>();
	}
}