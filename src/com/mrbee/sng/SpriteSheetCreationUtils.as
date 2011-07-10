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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * Class for create spritesheet data with the sequence png items
	 * @author Poluosmak Andrew 
	 */
	public class SpriteSheetCreationUtils
	{
		/**
		 * Max spritesheet bitmap width  
		 * @private
		 */		
		public static const MAX_WIDTH:int = 3000;
		
		/**		 
		 * Sequence item width
		 * @private 
		 */		
		private var _width:Number = 100;
		
		/**
		 * @private
		 */		
		private var _height:Number = 100;
		
		/**
		 * Items in sequence pool
		 * @private  
		 */		
		private var _frameSources:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		/**
		 * Items in sequence pool original data
		 * @private  
		 */		
		private var _frameSourcesOriginal:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		/**
		 * @private 
		 */		
		private var _bitmapData:BitmapData;
		
		/**
		 * @private 
		 */		
		private var _version:int = 1;
		
		/**
		 * @private 
		 */		
		private var _minXOffset:int = 0;
		
		/**
		 * @private 
		 */		
		private var _minYOffset:int = 0;
		
		/**
		 * @private 
		 */		
		private var _maxXOffset:int = 0;
		
		/**
		 * @private 
		 */		
		private var _maxYOffset:int = 0;
		
		/**
		 * @private 
		 */		
		private var _originalSource:BitmapData;
		
		/**
		 * @private 
		 */		
		public function SpriteSheetCreationUtils(){}
				
		/**
		 * Add new item in spritesheet animation sequence
		 * @param source compared BitmapData source. Use Encoder.compareData() for create item
		 */		
		public function add(source:BitmapData):void
		{			
			if(_originalSource == null)
			{
				throw new Error("Change sequence items after added original source");
				return;
			}
			
			if(source.width != _width){
				throw new Error("Source width has been equal "+_width+" px");
				return;
			}
			
			if(source.height != _height){
				throw new Error("Source height has been equal "+_height+" px");
				return;
			}	
						
			var prevSource:BitmapData; 
				
			if(_frameSourcesOriginal.length == 0){
				prevSource = originalSource;
				_frameSourcesOriginal.push(source);
			} else {				
				prevSource = _frameSourcesOriginal[_frameSourcesOriginal.length - 1];
				_frameSourcesOriginal.push(source);
			}
						
			var itemSource:BitmapData = SNGEncoder.compareData(prevSource, source); 
			_frameSources.push(itemSource);
		}
		
		/**
		 * Remove item in spritesheet animation by item index 
		 * @param index item index
		 * @return Boolean
		 */		
		public function removeAt(index:int):Boolean
		{
			if(index < _frameSources.length){
				_frameSources[index].dispose();
				_frameSources.splice(index, 1);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Remove item in spritesheet animation 
		 * 
		 * @param source item bitmapdata source
		 * @return Boolean
		 */		
		public function remove(source:BitmapData):Boolean
		{
			for(var i:int; i < _frameSources.length; i++){
				if(_frameSources[i] == source){
					_frameSources[i].dispose();
					_frameSources.splice(i, 1);
					return true;
				}
			}
			
			return false;
		}
		
		
		/**
		 * Generate optimized animation forall sequence items
		 * @private
		 */
		public function regenerateBitmapPositions():void
		{
			checkMinPositions();
			
			var rect:Rectangle = new Rectangle();
					
			if(_maxXOffset > 0)
				rect.width = _maxXOffset;
			else
				rect.width = _width - minXOffset;
			
			if(_maxYOffset > 0)
				rect.height = _maxYOffset;
			else
				rect.height = _height - minYOffset;
			
			var tmpBitmap:BitmapData;
			
			for(var i:int = 0; i < _frameSources.length; i++){
				
				rect.x = minXOffset;
				rect.y = minYOffset;
				
				var ba:ByteArray = _frameSources[i].getPixels(rect);					
				ba.position = 0;
				
				rect.x = 0;
				rect.y = 0;
				
				tmpBitmap = new BitmapData(rect.width, rect.height, true, uint.MAX_VALUE);
				tmpBitmap.setPixels(rect, ba);
				
				_frameSources[i] = tmpBitmap;
			}
		}
		
		/**
		 *  Check minimum area for x and y offset per each item on the spritesheet
		 * @private 
		 */		
		private function checkMinPositions():void
		{ 
			var i:int;
			var recBounds:Rectangle;
			for(i = 0; i < _frameSources.length; i++){
				recBounds = _frameSources[i].getColorBoundsRect(0xFF000000, 0x00000000, false);
				
				if(minXOffset > 0)
					minXOffset = MathUtils.min(minXOffset, recBounds.x);
				else
					minXOffset = recBounds.x;
				
				if(minYOffset > 0)
					minYOffset = MathUtils.min(minYOffset, recBounds.y);
				else
					minYOffset = recBounds.y;
				
				if(recBounds.width != originalSource.width)
					_maxXOffset = MathUtils.max(_maxXOffset, recBounds.width);
				
				if(recBounds.height != originalSource.height)
				_maxYOffset = MathUtils.max(_maxYOffset, recBounds.height);
			}
		}

		/**
		 * Sequence item height  
		 */		
		public function get height():Number
		{
			return _height;
		}
		
		/**
		 * @private
		 */		
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		/**
		 * Sequence item width  
		 */	
		public function get width():Number
		{
			return _width;
		}
		
		/**
		 * @private
		 */		
		public function set width(value:Number):void
		{
			_width = value;			
		}
		
		/**
		 * Total frames in spritesheet animation without original (first) item
		 * @return int
		 */		
		public function get totalFrames():int
		{
			return _frameSources.length;
		}
		
		/**
		 * Seuence items
		 * @return Vector.<BitmapData> 
		 */		
		public function get frameSources():Vector.<BitmapData>
		{
			return _frameSources;
		}

		/**
		 * Generated spritesheet bitmapdata source 
		 * @return int
		 */		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}

		/**
		 * AMB version format number 
		 * @return int
		 */		
		public function get version():int
		{
			return _version;
		}

		/**
		 * X offset per each item in spritesheet 
		 * @return int
		 */		
		public function get minXOffset():int
		{
			return _minXOffset;
		}

		/**
		 * @private
		 */		
		public function set minXOffset(value:int):void
		{
			_minXOffset = value;
		}

		/**
		 * Y offset per each item in spritesheet 
		 * @return int
		 */		
		public function get minYOffset():int
		{
			return _minYOffset;
		}

		/**
		 * @private
		 */		
		public function set minYOffset(value:int):void
		{
			_minYOffset = value;
		}

		/**
		 * First item sequence source
		 * @return BitmapData source 
		 */		
		public function get originalSource():BitmapData
		{
			return _originalSource;
		}

		/**
		 * @private
		 */		
		public function set originalSource(value:BitmapData):void
		{
			_originalSource = value;
		}


	}
}