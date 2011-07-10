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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class SNGAnimator extends Sprite
	{
		/**
		 * @private 
		 */
		private var _ambObject:SNGObject;
		
		/**
		 * @private 
		 */
		private var _currentFrame:int = 1;
		
		/**
		 * @private 
		 */
		private var _sourceBitmap:Bitmap;
		
		/**
		 * @private 
		 */
		private var _useCache:Boolean = true;
		
		/**
		 * cached frames
		 * @private 
		 */		
		private var _cached:Dictionary = new Dictionary(true);
		
		/**
		 * Constructor
		 * @param object SNGObject for animation
		 */
		public function SNGAnimator(object:SNGObject)
		{
			_ambObject = object;
			
			_sourceBitmap = new Bitmap();
			
			var bd:BitmapData = new BitmapData(_ambObject.width  + _ambObject.xOffset, _ambObject.height + _ambObject.yOffset, true, uint.MIN_VALUE);
			bd.draw(_ambObject.firstData);
			
			_sourceBitmap.bitmapData = bd;
			_sourceBitmap.smoothing = true;

			addChild(_sourceBitmap);
		}

		public function play(frame:Number = -1):void
		{
			if(frame > 0 && frame <= _ambObject.totalFrames)
				_currentFrame = frame;
				
			if(!hasEventListener(Event.ENTER_FRAME))
				addEventListener(Event.ENTER_FRAME, onEnterFrame);			
		}
		
		public function stop():void 
		{
			if(hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);			
		}

		/**
		 * @private 
		 */
		protected function onEnterFrame(event:Event):void
		{
			draw();
			
			_currentFrame++; 
			
			if(_ambObject.totalFrames < _currentFrame){
				_currentFrame = 1;
			}
		}
		
		/**
		 * @private 
		 */
		protected function draw():void
		{
			if(_useCache == false || (_useCache == true && _cached[_currentFrame] == null)){
				if(_ambObject != null && _sourceBitmap != null){
					var bytes:ByteArray = _ambObject.sheetItems[_currentFrame - 1].getPixels(_ambObject.sheetItems[_currentFrame - 1].rect);
					bytes.position = 0;
					
					var bytes2:ByteArray = _sourceBitmap.bitmapData.getPixels(new Rectangle(_ambObject.xOffset, _ambObject.yOffset, _ambObject.sheetItems[_currentFrame - 1].rect.width, _ambObject.sheetItems[_currentFrame - 1].rect.height));
					bytes2.position = 0;
					
					var pixel:uint;
					var pos:int = 0;
					while(bytes.bytesAvailable > 0){
						pixel = bytes.readUnsignedInt();						
						if(pixel != 0){
							// set position in previous byte
							bytes2.position = bytes.position - 4;
							bytes2.writeUnsignedInt(pixel);
						}
					}
					
					bytes2.position = 0;					
					_sourceBitmap.bitmapData.setPixels(new Rectangle(_ambObject.xOffset, _ambObject.yOffset, _ambObject.sheetItems[_currentFrame - 1].rect.width, _ambObject.sheetItems[_currentFrame - 1].rect.height), bytes2);
		
					if(_useCache == true)
						_cached[_currentFrame] = _sourceBitmap.bitmapData.clone();
					
					_sourceBitmap.smoothing = true;
				}
			} else if(_useCache == true && _cached[_currentFrame] != null){
				_sourceBitmap.bitmapData = _cached[_currentFrame];
				_sourceBitmap.smoothing = true;
			}
		}
		
		/**
		 * Animation Frame Rate
		 * @return int
		 */		
		public function get frameRate():int
		{
			return this.stage.frameRate;
		}
		
		/**
		 * @private 
		 */
		public function set frameRate(value:int):void
		{
			this.stage.frameRate = value;
		}
		
		/**
		 * Total frames
		 * @rerutn int 
		 */
		public function get totalFrames():int
		{
			return _ambObject.totalFrames;
		}

		/**
		 * Use sequence cache
		 * @return  
		 */
		public function get useCache():Boolean
		{
			return _useCache;
		}

		/**
		 * @private 
		 */
		public function set useCache(value:Boolean):void
		{
			_useCache = value;
		}

		/**
		 * Current frame
		 * @private 
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

	}
}